// Create Log Settings for self & system users
Set<Id> userIds = new Map<Id, User>([SELECT Id FROM User WHERE Alias IN ('autoproc', 'platint')])?.keySet()?.clone();
userIds?.add(UserInfo.getUserId());
userIds?.add(UserInfo.getOrganizationId());
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
