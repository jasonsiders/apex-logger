# apex-logger
TODO!

## Getting Started

### Installation

`apex-logger` is available as an unlocked package. Before installing the logger package, you must install the [`lwc-related-list`](https://github.com/jasonsiders/lwc-related-list) package. Run this command:
```sh
sfdx package install -p 04tDn0000011NQzIAM -w 5
```

Once installed, you are ready to install the logger package. Obtain the latest package version id (starting with `04t`) via the [Releases](https://github.com/jasonsiders/apex-logger/releases/latest) tab. Run this command to install the package to your environment. Replace 04t... with your desired package version Id:
```sh
sf package install -p 04t... -w 3
```

### Configuration
To begin logging, you will need to create `LogSetting__c` records. You can do this in the UI, via _Setup > Custom Settings > Log Settings > Manage_. 

Alternatively, you can run the included [setup script](scripts/shell/setup.sh). This will create Log Setting records for the org, system users that can't normally be accessed via the UI (like `Automated Process`), and yourself. 

### Permissions
Users do not need to have permissions to the Logger in order to use it. However, users do need access to the `Log__c` object and its fields in order to view log records in the UI. Use the `LogAccess` permission set to provision this access.

If you choose to Log from Lightning Components, you will need to ensure that any users who interact with your component have access to the `LwcLogger` apex class. Use the `LogFromLightning` permission set to provision this access. 
## Usage
Logging with `apex-logger` is a two-step process:

1. **Generate Logs**. The `log()` method(s) - and equivalent Flow and Lightning Component functions generate content to be captured in `Log__c` records. All logs generated throughout a transaction are held in a static variable until published, or until the transaction concludes. 
2. **Publish Logs**: The `publish()` method commits any pending logs generated to the database, in the `Log__c` SObject. Any unpublished logs at the end of the transaction will be lost. Since this will typically incur a DML statement, publish Logs sparingly, and never include `publish()` calls inside of a loop. 

You can leverage this framework to generate Log messages from anywhere in Salesforce, including Apex, Flows, and Lightning Components.
### In Apex
In Apex, use the `Logger` class to construct, log, and publish Log messages. Logs are stored statically, across all instances of the `Logger` class. 

#### Generate Logs

Use the `log()` method to generate Log messages:

```java
Logger myLogger = new Logger().log(System.LoggingLevel.ERROR, 'Hello world!');
```

You can also use level-specific overloads as shorthand:
```java
// In order of most to least severe:
new Logger().error('Hello world!');
new Logger().warn('Hello world!');
new Logger().info('Hello world!');
new Logger().debug('Hello world!');
new Logger().fine('Hello world!');
new Logger().finer('Hello world!');
new Logger().finest('Hello world!');
```

#### Optional: Add Additional Context

The `Logger` class also provides methods used to add additional context to Logs:
- `setLoggedFrom(Type/String)`: Sets the `LoggedFrom__c` field. In Apex, this should be the current Apex Class.
- `setRelatedRecordId(SObject/Id)`: Sets the `RelatedRecordId__c` field, which allows the Log to be displayed on that record page if desired.
- `setSource(String)`: Sets the `Source__c` field. This can be used to specify what generated the Log message in a way that's meaningful to your organization. For example, this could be the name of a managed package, or the business division that the code is running in.

```java
Logger myLogger = new Logger()
    .setLoggedFrom(MyClass.class)
    .setRelatedRecordId(account.Id)
    .setSource('apex-logger');
// All of these logs will use the context generated above
for (Integer i = 0; i < 200; i++) {
    myLogger.finest('Log #' + i);
}
// ...but this one won't!
new Logger().finest('Done logging');
```

#### Publish Logs

Once logs are generated, they will not be inserted until the `publish()` method is called:

```java
new Logger().finest('Hello world').publish();
```
Publishing behavior is governed by the `Logger.LogPublisher` interface. Read more about this interface [here](#the-loggerlogpublisher-interface).

By default, `Logger` will use the `Logger.LogPublisher` defined in the current user's `LogSetting__c.Publisher__c` field to publish the Logs. If no publisher is defined, the default behavior is for Logs to be inserted via a traditional `insert` DML statement. 

You can define your own `Logger.LogPublisher` and use this method to override the user's specified `Publisher__c`:
```java
new Logger().finest('Hello world');
Logger.LogPublisher publisher = MyCustomPublisher();
// The Logger will use this publisher to publish the pending log(s)
new Logger().publish(publisher);
``` 

### In Flows
To log from flow, use the included `Log` and `Publish Logs` invocable actions.

#### The `Log` Invocable Action (`InvocableLogger`)
![The "Log" Invocable Action](/media/loginvocable.png)
Generates a Log message, and stores it in memory. To insert the log, you must call the `Publish Logs` invocable action afterwards.
> Note: You can use flow variable notation (`{!myVar}`) to insert variables from your flow in the log body or other fields.

#### The `Publish Logs` Invocable Action (`InvocableLogPublisher`)
![The "Publish Logs" Invocable Action](media/publishlogsinvocable.png) 
Publishes any pending Logs, via a `publish()` call. It's not possible to specify the `LogPublisher` from this invocable action.

### In Lightning Components
You can use this framework to log directly from custom LWCs. Simply import the `LwcLogger.log` module:
```js
import doLog from "@salesforce/apex/LwcLogger.log";
```

This method expects a serialized `LogInput` object, consisting of the following parameters:
```js
let logInput = {
    body: "Hello world!",
    level: "FINEST", 
    // The rest are all optional
    loggedFrom: "my-lwc",
    relatedRecordId: this.recordId,
    source: "my-package"
};
doLog({ payload: JSON.stringify(logInput) });
```

Since each Apex call from LWC is its own discrete transaction, the `LwcLogger.log()` method handles both logging & publishing. It's not possible to specify the `LogPublisher` from this method.

### The `Log__c` Object
Log details are stored in the `Log__c` custom object. Read more about this object and its fields [**here**](/docs/LOGOBJECT.md). 
![A Log Record](/media/logrecord.png)

You can view Logs in the UI via the `Logs` tab:
![Log List View](/media/loglistview.png)  

You can also view logs related to a specific record via the `Related Logs` lightning component:
![Log Related List in the Builder](/media/logrelatedlist.png) 

### The `LogSetting__c` Custom Settings Object
![The Log Setting Object](/media/logsetting.png)
`LogSetting__c` is a custom settings object used to control log enablement, publishing behavior, and more. Specify a Log Setting record to determine how the Logger will run across your org, or for specific Users & Profiles.

### The `Logger.LogPublisher` Interface
The Logger uses a `LogPublisher` interface to define the logic for publishing logs. `apex-logger` ships with a built in publisher - `LogDmlPublisher`. This class inserts logs using traditional DML.

You can also define your own publishing logic by creating a class which implements this interface:
```java
global class MyPublisher implements Logger.LogPublisher {
    global void publish(List<Log__c> logs) {
        // Publishing logic goes here!
    }
}
```

You can specify which publisher to use via the `publish(Logger.LogPublisher)` method:
```java
Logger.LogPublisher pub = new MyPublisher();
new Logger().finest('Hello world!').publish(pub);
```

You can also specify a User's default Publisher class via the `LogSetting__c.Publisher__c` field:
![Log Setting w/a Custom LogPublisher](media/logpublisher.png)
```java
// Since a LogSetting__c.Publisher__c is defined, will use MyProcessor by default
new Logger().finest('Hello world!').publish();
```