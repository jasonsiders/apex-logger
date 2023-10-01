@IsTest
private class InvocableLoggerTest {
	@IsTest
	static void shouldLogWithAdvancedDetails() {
		LogInput input = new LogInput();
		input.body = 'This is a test';
		input.level = System.LoggingLevel.ERROR.name();
		input.loggedFrom = 'My_Flow';
		input.relatedRecordId = UserInfo.getUserId();
		input.source = 'fooBarFlow';

		Test.startTest();
		InvocableLogger.invoke(new List<LogInput>{ input });
		Test.stopTest();

		List<Log__c> logs = Logger.pendingLogs;
		Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created');
		Log__c log = logs[0];
		Assert.areEqual(input?.body, log?.Body__c, 'Wrong Level');
		Assert.areEqual(input?.level, log?.Level__c, 'Wrong Level');
		Assert.areEqual(input?.loggedFrom, log?.LoggedFrom__c, 'Wrong LoggedFrom');
		Assert.areEqual(input?.relatedRecordId, log?.RelatedRecordId__c, 'Wrong RelatedRecordId');
		Assert.areEqual(input?.source, log?.Source__c, 'Wrong Source');
	}

	@IsTest
	static void shouldLogWithMinimalDetail() {
		LogInput input = new LogInput();
		input.body = 'This is a test';
		input.level = System.LoggingLevel.ERROR.name();

		Test.startTest();
		InvocableLogger.invoke(new List<LogInput>{ input });
		Test.stopTest();

		List<Log__c> logs = Logger.pendingLogs;
		Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created');
		Log__c log = logs[0];
		Assert.areEqual(input?.body, log?.Body__c, 'Wrong Level');
		Assert.areEqual(input?.level, log?.Level__c, 'Wrong Level');
		Assert.isNull(log?.LoggedFrom__c, 'LoggedFrom was set, but how?');
		Assert.isNull(log?.RelatedRecordId__c, 'RelatedRecordId was set, but how?');
		Assert.isNull(log?.Source__c, 'Source was set, but how?');
	}

	// **** HELPER **** //
	@TestSetup
	static void setup() {
		LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
	}
}
