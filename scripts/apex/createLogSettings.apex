// Create Log Settings for self & AutomatedProcess user
Set<Id> userIds = new Map<Id, User>([SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1])?.keySet()?.clone();
userIds?.add(UserInfo.getUserId()); 
List<LogSetting__c> settings = new List<LogSetting__c>(); 
for (Id userId : userIds) {
    LogSetting__c setting = new LogSetting__c(); 
    setting.Enabled__c = true;
    setting.SetupOwnerId = userId;
    setting.Threshold__c = System.LoggingLevel.FINEST.name();
    settings?.add(setting); 
}
for (Database.SaveResult result : Database.insert(settings, false)) {
    if (result?.isSuccess() == false) {
        System.debug('Failed to insert LogSetting__c: ' + result?.getErrors()); 
    } else {
        System.debug('Inserted LogSetting__c ' + result?.getId());
    }
}