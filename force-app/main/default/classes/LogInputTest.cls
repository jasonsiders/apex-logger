@IsTest
private class LogInputTest {
	@IsTest
	static void shouldLog() {
		LogInput input = new LogInput();
		input.body = 'foo';
		input.category = 'foo-bar';
		input.level = System.LoggingLevel.ERROR.name();
		input.loggedFrom = LogInputTest.class?.getName();
		input.relatedRecordId = UserInfo.getUserId();

		Test.startTest();
		input?.log();
		Test.stopTest();

		Assert.areEqual(1, Logger.pendingLogs?.size(), 'Wrong # of logs created');
		Log__c log = Logger.pendingLogs[0];
		Assert.areEqual(input?.body, log?.Body__c, 'Wrong Body');
		Assert.areEqual(input?.category, log?.Category__c, 'Wrong Category');
		Assert.areEqual(input?.level, log?.Level__c, 'Wrong Level');
		Assert.areEqual(input?.loggedFrom, log?.LoggedFrom__c, 'Wrong LoggedFrom');
		Assert.areEqual(input?.relatedRecordId, log?.RelatedRecordId__c, 'Wrong RelatedRecordId');
	}

	@IsTest
	static void shouldHandleInvalidLoggingLevel() {
		LogInput input = new LogInput();
		input.body = 'foo';
		input.level = null;

		Test.startTest();
		input?.log();
		Test.stopTest();

		Assert.areEqual(0, Logger.pendingLogs?.size(), 'Wrong # of logs created');
	}

	@IsTest
	static void shouldHandleInvalidRecordId() {
		LogInput input = new LogInput();
		input.body = 'foo';
		input.level = System.LoggingLevel.ERROR.name();
		input.relatedRecordId = 'abcd1324'; // Not an Id!

		Test.startTest();
		input?.log();
		Test.stopTest();

		Assert.areEqual(1, Logger.pendingLogs?.size(), 'Wrong # of logs created');
		Log__c log = Logger.pendingLogs[0];
		Assert.isNull(log?.RelatedRecordId__c, 'Invalid RelatedRecordId was populated');
	}

	// **** SETUP **** //
	@TestSetup
	static void setup() {
		LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
	}
}
