@IsTest
public class LogTestUtils {
	public static LogSetting__c enableLogging(System.LoggingLevel level) {
		LogSetting__c settings = new LogSetting__c(
			Enabled__c = true,
			SetupOwnerId = UserInfo.getUserId(),
			Threshold__c = level?.name()
		);
		insert settings;
		return settings;
	}
}
