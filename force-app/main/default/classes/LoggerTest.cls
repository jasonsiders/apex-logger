@IsTest
private class LoggerTest {
	@IsTest
	static void shouldLogIfMeetsThreshold() {
		System.LoggingLevel level = System.LoggingLevel.INFO;
		LogSetting__c settings = LogTestUtils.enableLogging(level);
		String logMsg = 'This is a test';

		Test.startTest();
		new Logger().log(level, logMsg);
		Test.stopTest();

		Assert.areEqual(1, Logger.pendingLogs?.size(), 'Wrong # of Logs');
		// Only this test - assert that fields are mapped correctly
		Log__c log = Logger.pendingLogs[0];
		Assert.isNull(log?.LoggedFrom__c, 'Has Logged From, but one wasn\'t set');
		Assert.areEqual(logMsg, log?.Body__c, 'Wrong Log');
		Assert.isNotNull(log?.Context__c, 'Missing Context');
		Assert.areEqual(level?.name(), log?.Level__c, 'Wrong Level');
		Assert.isNotNull(log?.LoggedAt__c, 'Missing Logged At');
		Assert.areEqual(UserInfo.getUserId(), log?.LoggedBy__c, 'Wrong Logged By');
		Assert.areEqual(1, log?.Ordinal__c, 'Wrong Ordinal');
		Assert.isNull(log?.RelatedRecordId__c, 'Has Related Record Id, but one wasn\'t set');
		Assert.isNull(log?.Source__c, 'Has Source, but one wasn\'t set');
		Assert.isNotNull(log?.StackTrace__c, 'Missing Stack Trace');
		Assert.isNotNull(log?.Transaction__c, 'Missing Transaction');
		// Only this test - assert that logs weren't actually inserted up to this point
		Assert.isTrue([SELECT Id FROM Log__c]?.isEmpty(), 'Logs were inserted before publish() was called');
	}

	@IsTest
	static void shouldLogIfExceedsThreshold() {
		LogSetting__c settings = LogTestUtils.enableLogging(System.LoggingLevel.FINEST);

		Test.startTest();
		new Logger().log(System.LoggingLevel.INFO, 'This is a test');
		Test.stopTest();

		Assert.areEqual(1, Logger.pendingLogs?.size(), 'Wrong # of Logs');
	}

	@IsTest
	static void shouldNotLogIfDisabled() {
		System.LoggingLevel level = System.LoggingLevel.INFO;
		LogSetting__c settings = LogTestUtils.enableLogging(level);
		settings.Enabled__c = false;
		update settings;

		Test.startTest();
		new Logger().log(level, 'This is a test');
		Test.stopTest();

		Assert.areEqual(0, Logger.pendingLogs?.size(), 'Wrong # of Logs');
	}

	@IsTest
	static void shouldNotLogIfBelowThreshold() {
		LogSetting__c settings = LogTestUtils.enableLogging(System.LoggingLevel.INFO);

		Test.startTest();
		new Logger().log(System.LoggingLevel.FINEST, 'This is a test');
		Test.stopTest();

		Assert.areEqual(0, Logger.pendingLogs?.size(), 'Wrong # of Logs');
	}

	@IsTest
	static void shouldNotLogIfThresholdIsNone() {
		LogSetting__c settings = LogTestUtils.enableLogging(System.LoggingLevel.NONE);

		Test.startTest();
		new Logger().log(System.LoggingLevel.ERROR, 'This is a test');
		Test.stopTest();

		Assert.areEqual(0, Logger.pendingLogs?.size(), 'Wrong # of Logs');
	}

	@IsTest
	static void shouldNotLogIfMissingSettings() {
		delete [SELECT Id FROM LogSetting__c]; // Just to be safe

		Test.startTest();
		new Logger().log(System.LoggingLevel.ERROR, 'This is a test');
		Test.stopTest();

		Assert.areEqual(0, Logger.pendingLogs?.size(), 'Wrong # of Logs');
	}

	@IsTest
	static void shouldPublishViaDefaultMethod() {
		System.LoggingLevel level = System.LoggingLevel.INFO;
		LogSetting__c settings = LogTestUtils.enableLogging(level);
		String logMsg = 'This is a test';
		Logger myLogger = new Logger()?.log(level, logMsg);

		Test.startTest();
		myLogger?.publish();
		Test.stopTest();

		List<Log__c> published = [SELECT Id FROM Log__c];
		Assert.areEqual(1, published?.size(), 'Wrong # of logs published');
		// Assert that the pendingLogs were cleared
		Assert.areEqual(0, Logger.pendingLogs?.size(), 'Pending Logs were not cleared post-publish');
	}

	@IsTest
	static void shouldPublishViaSpecifiedMethod() {
		System.LoggingLevel level = System.LoggingLevel.INFO;
		LogSetting__c settings = LogTestUtils.enableLogging(level);
		String logMsg = 'This is a test';
		Logger myLogger = new Logger();
		Logger.LogPublisher publisher = new TestPublisher();

		Test.startTest();
		myLogger?.log(level, logMsg);
		myLogger?.publish(publisher);
		Test.stopTest();

		// The TestPublisher simply inserts logs
		List<Log__c> published = [SELECT Id FROM Log__c];
		Assert.areEqual(1, published?.size(), 'Wrong # of logs published');
		// Assert that the pendingLogs were cleared
		Assert.areEqual(0, Logger.pendingLogs?.size(), 'Pending Logs were not cleared post-publish');
	}

	@IsTest
	static void shouldIncrementOrdinal() {
		System.LoggingLevel level = System.LoggingLevel.INFO;
		LogSetting__c settings = LogTestUtils.enableLogging(level);
		final Integer numLogs = 200;

		Test.startTest();
		for (Integer i = 0; i < numLogs; i++) {
			new Logger().log(level, 'This is a test');
		}
		Test.stopTest();

		Assert.areEqual(numLogs, Logger.pendingLogs?.size(), 'Unexpected # of Logs');
		for (Integer i = 0; i < numLogs; i++) {
			Log__c log = Logger.pendingLogs[i];
			Integer expectedOrdinal = (i + 1);
			Assert.areEqual(expectedOrdinal, log?.Ordinal__c, 'Unexpected Ordinal');
		}
	}

	@IsTest
	static void shouldLogWithOptionalArguments() {
		System.LoggingLevel level = System.LoggingLevel.INFO;
		LogSetting__c settings = LogTestUtils.enableLogging(level);
		Type apexClass = LoggerTest.class;
		User me = new User(Id = UserInfo.getUserId());
		String source = 'foo';
		String logMsg = 'This is a test';
		Logger myLogger = new Logger()?.setLoggedFrom(apexClass)?.setRelatedRecordId(me)?.setSource(source);

		Test.startTest();
		myLogger?.log(level, logMsg);
		Test.stopTest();

		Assert.areEqual(1, Logger.pendingLogs?.size(), 'Wrong # of Logs');
		// Only this test - assert that fields are mapped correctly
		Log__c log = Logger.pendingLogs[0];
		Assert.areEqual(apexClass?.getName(), log?.LoggedFrom__c, 'Wrong Logged From');
		Assert.areEqual(logMsg, log?.Body__c, 'Wrong Log');
		Assert.isNotNull(log?.Context__c, 'Missing Context');
		Assert.areEqual(level?.name(), log?.Level__c, 'Wrong Level');
		Assert.isNotNull(log?.LoggedAt__c, 'Missing Logged At');
		Assert.areEqual(UserInfo.getUserId(), log?.LoggedBy__c, 'Wrong Logged By');
		Assert.areEqual(1, log?.Ordinal__c, 'Wrong Ordinal');
		Assert.areEqual(me?.Id, log?.RelatedRecordId__c, 'Wrong Related Record Id');
		Assert.areEqual(source, log?.Source__c, 'Wrong Source');
		Assert.isNotNull(log?.StackTrace__c, 'Missing Stack Trace');
		Assert.isNotNull(log?.Transaction__c, 'Missing Transaction');
	}

	@IsTest
	static void shouldLogUsingShorthandOverloads() {
		LogSetting__c settings = LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
		String logMsg = 'This is a test';

		Test.startTest();
		new Logger().error(logMsg);
		Assert.areEqual(1, Logger.pendingLogs?.size(), 'error() did not log');
		Assert.areEqual(System.LoggingLevel.ERROR.name(), Logger.pendingLogs[0]?.Level__c, 'Wrong Level');
		Logger.pendingLogs?.clear();

		new Logger().warn(logMsg);
		Assert.areEqual(1, Logger.pendingLogs?.size(), 'warn() did not log');
		Assert.areEqual(System.LoggingLevel.WARN.name(), Logger.pendingLogs[0]?.Level__c, 'Wrong Level');
		Logger.pendingLogs?.clear();

		new Logger().info(logMsg);
		Assert.areEqual(1, Logger.pendingLogs?.size(), 'info() did not log');
		Assert.areEqual(System.LoggingLevel.INFO.name(), Logger.pendingLogs[0]?.Level__c, 'Wrong Level');
		Logger.pendingLogs?.clear();

		new Logger().debug(logMsg);
		Assert.areEqual(1, Logger.pendingLogs?.size(), 'debug() did not log');
		Assert.areEqual(System.LoggingLevel.DEBUG.name(), Logger.pendingLogs[0]?.Level__c, 'Wrong Level');
		Logger.pendingLogs?.clear();

		new Logger().fine(logMsg);
		Assert.areEqual(1, Logger.pendingLogs?.size(), 'fine() did not log');
		Assert.areEqual(System.LoggingLevel.FINE.name(), Logger.pendingLogs[0]?.Level__c, 'Wrong Level');
		Logger.pendingLogs?.clear();

		new Logger().finer(logMsg);
		Assert.areEqual(1, Logger.pendingLogs?.size(), 'finer() did not log');
		Assert.areEqual(System.LoggingLevel.FINER.name(), Logger.pendingLogs[0]?.Level__c, 'Wrong Level');
		Logger.pendingLogs?.clear();

		new Logger().finest(logMsg);
		Assert.areEqual(1, Logger.pendingLogs?.size(), 'finest() did not log');
		Assert.areEqual(System.LoggingLevel.FINEST.name(), Logger.pendingLogs[0]?.Level__c, 'Wrong Level');
		Logger.pendingLogs?.clear();
		Test.stopTest();
	}

	@IsTest
	static void shouldLogRegardlessOfUserAccess() {
		User testUser = LoggerTest.createTestUser();
		LogSetting__c settings = new LogSetting__c(
			Enabled__c = true,
			SetupOwnerId = testUser?.Id,
			Threshold__c = System.LoggingLevel.FINEST.name()
		);
		insert settings;

		Test.startTest();
		System.runAs(testUser) {
			// Test both logging + publishing - both should be allowed
			new Logger()?.error('This is a test')?.publish();
		}
		Test.stopTest();

		List<Log__c> published = [SELECT Id FROM Log__c];
		Assert.areEqual(1, published?.size(), 'Wrong # of published logs');
	}

	@IsTest
	static void shouldHandleIllegalPublisherValue() {
		// If Publisher__c is set, but isn't a valid Logger.LogPublisher, should use the default publisher
		LogSetting__c settings = LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
		settings.Publisher__c = 'abc123'; // Not a real publisher
		update settings;

		Test.startTest();
		new Logger()?.error('This is a test')?.publish();
		Test.stopTest();

		List<Log__c> published = [SELECT Id FROM Log__c];
		Assert.areEqual(1, published?.size(), 'Wrong # of published logs');
	}

	@IsTest
	static void shouldHandleIllegalThresholdValue() {
		// If Threshold__c is set, but isn't a valid System.LoggingLevel, should default to NONE
		LogSetting__c settings = new LogSetting__c(
			Enabled__c = true,
			SetupOwnerId = UserInfo.getUserId(),
			Threshold__c = 'abc123' // Not a real LoggingLevel
		);
		insert settings;

		Test.startTest();
		new Logger()?.error('This is a test');
		Test.stopTest();

		Assert.areEqual(0, Logger.pendingLogs?.size(), 'Wrong # of Logs');
	}

	@IsTest
	static void shouldHandleTextFieldsBeyondLength() {
		// The logger should abbreviate any user-set String variables if they exceed their fields' length,
		// Note: This also applies to stack trace - which isn't set by the user, but it's much harder to test for this,
		// since you cannot manually set an Exception's stack trace string value
		LogSetting__c settings = LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
		Integer badLen = 150000; // No Salesforce field supports this # of characters!

		Test.startTest();
		try {
			new Logger()?.setSource('S'?.repeat(badLen))?.finest('B'?.repeat(badLen))?.publish();
		} catch (Exception error) {
			Assert.fail('Failed to log: ' + error);
		}
		Test.stopTest();

		List<Log__c> logs = [SELECT Id, Body__c, Source__c FROM Log__c];
		Assert.areEqual(1, logs?.size(), 'Wrong # of Logs');
		Log__c log = logs[0];
		Assert.areEqual(
			Log__c.Body__c?.getDescribe()?.getLength(),
			log?.Body__c?.length(),
			'Did not abbreviate Body to max length'
		);
		Assert.areEqual(
			Log__c.Source__c?.getDescribe()?.getLength(),
			log?.Source__c?.length(),
			'Did not abbreviate Source to max length'
		);
	}

	// **** HELPER **** //
	static User createTestUser() {
		List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
		Profile profile = profiles?.isEmpty() == false ? profiles[0] : null;
		String username = Crypto.getRandomLong() + '@test.com.invalid';
		User user = new User(
			Alias = 'testuser',
			Email = username,
			EmailEncodingKey = 'UTF-8',
			FirstName = 'John',
			LastName = 'Doe',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = profile?.Id,
			TimeZoneSidKey = 'GMT',
			Username = username
		);
		insert user;
		return user;
	}

	// **** INNER **** //
	public class TestPublisher extends LogDmlPublisher {
	}
}
