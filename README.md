# apex-logger
TODO!

## Usage
### Logging
When logging, you will typically follow a two-step process:

1. **Generate Logs**. The `log()` method(s) - and equivalent Flow and Lightning Component functions generate content to be captured in `Log__c` records. All logs generated throughout a transaction are held in a static variable until published, or until the transaction concludes. 
2. **Publish Logs**: The `publish()` method commits any pending logs generated to the database, in the `Log__c` SObject. Any unpublished logs at the end of the transaction will be lost. Since this will typically incur a DML statement, publish Logs sparingly, and never include `publish()` calls inside of a loop. 

You can leverage this framework to generate log messages from anywhere in Salesforce, including Apex, Flows, and Lightning Components:

#### From Apex
In Apex, use the `Logger` class to construct, log, and publish log messages. All methods return a `Logger` instance, and can be chained together. You do not need to use the same `Logger` instance each time, since the instance references static variables shared across all instances.

Use the `log()` method to generate log messages. The `log()` method accepts the following parameters:
- A [`System.LoggingLevel`](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_LoggingLevel.htm) value which indicates the severity of the message. Works in tandem with [Log Settings](#the-logsetting__c-custom-settings-object), to determine if the message should actually be logged.
- An `Object` representing to the Log Message. The `String.valueOf` this parameter is stored in the `Body__c` field. 
```
Logger myLogger = new Logger().log(System.LoggingLevel.ERROR, 'Hello world!');
```

You can also use overloads which set the `System.LoggingLevel` to the value matching the method name:
```
// In order of most to least severe:
new Logger().error('Hello world!');
new Logger().warn('Hello world!');
new Logger().info('Hello world!');
new Logger().debug('Hello world!');
new Logger().fine('Hello world!');
new Logger().finer('Hello world!');
new Logger().finest('Hello world!');
```

Once logs have been generated, you can insert them into the database via the `publish()` method. This typically incurs a DML statement, unless there are no logs to insert.
```
new Logger().finest('Hello world').publish();
```
Publishing behavior is governed by the `Logger.LogPublisher` interface. Read more about this interface [here](#the-loggerlogpublisher-interface).

By default, `Logger` will use the `Logger.LogPublisher` defined in the current user's `LogSetting__c.Publisher__c` field to handle publishing behavior. If no publisher is defined, the default behavior is for Logs to be inserted via a traditional `insert` DML statement. 

If you wish, you can define your own `Logger.LogPublisher` and use this method to override the user's specified `Publisher__c`:
```
new Logger().finest('Hello world');
Logger.LogPublisher publisher = MyCustomPublisher();
// Pass the publisher as an argument to the publish method.
// The Logger will use this publisher to publish the pending log(s)
new Logger().publish(publisher);
``` 
The `Logger` class also provides a number of methods that allow you to add additional context to your log messages:
- `setLoggedFrom(Type/String)`: Sets the `LoggedFrom__c` field. In Apex, It's reccommended to list the name of the current Apex Class.
- `setRelatedRecordId(SObject/Id)`: Sets the `RelatedRecordId__c` field, which represents a closely-related record. 
- `setSource(String)`: Sets the `Source__c` field. This can be used to specify more broadly what generated the log message. For example, the name of your managed package, or the business division. 

These values are stored on the `Logger` object and will apply to any logs that the specific object is used to generate:
```
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

#### From Flow
TODO!

#### From Lightning Components
TODO!

### The `Log__c` Object
TODO!

### The `LogSetting__c` Custom Settings Object
TODO!

### The `Logger.LogPublisher` Interface
TODO!

## Getting Started

`apex-logger` is available as an unlocked package. Before installing the logger package, you must install the [`lwc-related-list`](https://github.com/jasonsiders/lwc-related-list) package. Run this command:
```
sfdx package install -p 04tDn0000011NQzIAM -w 5
```

Once installed, you are ready to install the logger package. Obtain the latest package version id (starting with `04t`) via the [Releases](https://github.com/jasonsiders/apex-logger/releases/latest) tab. Run this command to install the package to your environment. Replace 04t... with your desired package version Id:
```
sf package install -p 04t... -w 3
```