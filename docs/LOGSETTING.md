# The `LogSetting__c` Custom Settings Object
`LogSetting__c` is a custom settings object used to control log enablement. Because this is a [Hierarchy Custom Settings](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_customsettings.htm) object, you have fine control over settings ranging from the whole organization, to profiles, to specific users. 

At the beginning of each transaction, the framework will find the Log Setting record that matches their User. If one doesn't exist, it will find one based on their profile. If one doesn't exist, it will return the Organization-Wide Default Settings record. If that doesn't exist, the Logger will be disabled.

![The Log Setting Object](/media/logsetting.png) 

The `LogSetting__c` object contains these fields:
- **Enabled**: When checked, Logging is enabled for this User/Profile/Org. 
- **Publisher**: The fully-qualified API name of an Apex Class that implements the `Logger.LogPublisher` interface. When populated, this class will dictate publishing behavior, for the User/Profile/Org, unless otherwise specified by the `publish()` call. When blank, the framework will default to use the `LogDmlPublisher`, which inserts logs synchronously, using traditional DML. 
- **Threshold**: The minimum `System.LoggingLevel` value that can be logged by the User/Profile/Org. If a `log()` statement's level is less severe than the threshold, the message will not be logged. Ex., when Threshold is `FINE`, then `FINER` and `FINEST` messages will not be logged, but all others will. This field expects a valid `System.LoggingLevel` value. If an invalid value is used, no logs will be captured for this User/Profile/Org.