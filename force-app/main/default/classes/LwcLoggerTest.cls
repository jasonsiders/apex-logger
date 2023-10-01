@IsTest
private class LwcLoggerTest {
	@IsTest
	static void shouldLogWithAdvancedDetails() {
		LogInput input = new LogInput();
		input.body = 'This is a test';
		input.level = System.LoggingLevel.ERROR?.name();
		input.loggedFrom = 'c-my-lwc';
		input.relatedRecordId = UserInfo.getUserId();
		input.source = 'fooBarLwc';

		Test.startTest();
		LwcLogger.log(JSON.serialize(input));
		Test.stopTest();

		List<Log__c> logs = LwcLoggerTest.getLogs();
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
		input.level = System.LoggingLevel.ERROR?.name();

		Test.startTest();
		LwcLogger.log(JSON.serialize(input));
		Test.stopTest();

		List<Log__c> logs = LwcLoggerTest.getLogs();
		Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created');
		Log__c log = logs[0];
		Assert.areEqual(input?.body, log?.Body__c, 'Wrong Level');
		Assert.areEqual(input?.level, log?.Level__c, 'Wrong Level');
		Assert.isNull(log?.LoggedFrom__c, 'LoggedFrom was set, but how?');
		Assert.isNull(log?.RelatedRecordId__c, 'RelatedRecordId was set, but how?');
		Assert.isNull(log?.Source__c, 'Source was set, but how?');
	}

	@IsTest
	static void shouldHandleInvalidPayload() {
		String badPayload = 'abcd1234';
		Exception error;

		Test.startTest();
		try {
			LwcLogger.log(badPayload);
		} catch (AuraHandledException caughtError) {
			error = caughtError;
		}
		Test.stopTest();

		Assert.isNotNull(error, 'Error was not thrown/caught for a bad payload');
	}

	// **** HELPER **** //
	@TestSetup
	static void setup() {
		LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
	}

	static List<Log__c> getLogs() {
		return [SELECT Id, LoggedFrom__c, Body__c, Level__c, RelatedRecordId__c, Source__c FROM Log__c];
	}
}
