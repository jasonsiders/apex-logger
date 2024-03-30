@IsTest
private class LogRelatedListControllerTest {
	@IsTest
	static void shouldReturnRelatedLogs() {
		Account account = LogRelatedListControllerTest.getAccount();

		Test.startTest();
		List<Log__c> logs = LogRelatedListController.getLogs(account?.Id);
		Test.stopTest();

		Assert.areEqual(NUM_TEST_LOGS, logs?.size(), 'Wrong # of logs');
		for (Log__c log : logs) {
			Assert.areEqual(account?.Id, log?.RelatedRecordId__c, 'Wrong Record Id');
		}
	}

	@IsTest
	static void shouldHandleNullId() {
		Account account = LogRelatedListControllerTest.getAccount();
		Id recordId = null;

		Test.startTest();
		Exception error;
		try {
			List<Log__c> logs = LogRelatedListController.getLogs(recordId);
		} catch (AuraHandledException caughtError) {
			error = caughtError;
		}
		Test.stopTest();

		Assert.areNotEqual(null, error, 'An error was not thrown');
	}

	@IsTest
	static void shouldReturnTrueIfHasAccess() {
		User user = LogRelatedListControllerTest.getTestUser();
		// By default, this user does not have access. Assign them a permission set
		LogRelatedListControllerTest.assignPermissionSet(user);

		Test.startTest();
		Boolean results;
		System.runAs(user) {
			results = LogRelatedListController.hasAccess();
		}
		Test.stopTest();

		Assert.areEqual(true, results, 'Unexpected results');
	}

	@IsTest
	static void shouldReturnFalseIfNoAccess() {
		User user = LogRelatedListControllerTest.getTestUser();
		// By default, this user does not have access. 

		Test.startTest();
		Boolean results;
		System.runAs(user) {
			results = LogRelatedListController.hasAccess();
		}
		Test.stopTest();

		Assert.areEqual(false, results, 'Unexpected results');
	}


	// **** HELPER **** //
	static final Integer NUM_TEST_LOGS = 200;
	static final String PERMISSION_SET_NAME = 'LogAccess';
	static final String TEST_USER_ALIAS = 'tUser123';

	@TestSetup
	static void setup() {
		// Create a test user
		LogRelatedListControllerTest.createTestUser();
		// Create an Account
		Account account = new Account(Name = 'Test Account');
		insert account;
		// Create logs related to the Account
		List<Log__c> logs = new List<Log__c>();
		for (Integer i = 0; i < NUM_TEST_LOGS; i++) {
			Log__c log = new Log__c(
				Body__c = 'Test Log #' + i,
				Level__c = System.LoggingLevel.FINEST?.name(),
				RelatedRecordId__c = account?.Id
			);
			logs?.add(log);
		}
		insert logs;
	}

	static void assignPermissionSet(User user) {
		PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = :PERMISSION_SET_NAME LIMIT 1];
		insert new PermissionSetAssignment(
			AssigneeId = user?.Id, 
			PermissionSetId = permissionSet?.Id
		); 
	}

	static User createTestUser() {
		Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
		String username = 'testuser' + Crypto.getRandomInteger() + '@test.com';
		User user = new User(
			Alias = TEST_USER_ALIAS,
			EmailEncodingKey = 'UTF-8',
			Email = username,
			FirstName = 'Test',
			LanguageLocaleKey = 'en_US',
			LastName = 'User',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'GMT',
			ProfileId = standardProfile?.Id,
			Username = username
		);
		// Can't mix DML ops - this is a workaround
		User me = new User(Id = UserInfo.getUserId());
		System.runAs(me) {
			insert user;
		}
		return user;
	}

	static Account getAccount() {
		List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
		return accounts?.isEmpty() ? null : accounts[0];
	}

	static User getTestUser() {
		return [SELECT Id FROM User WHERE Alias = :TEST_USER_ALIAS ORDER BY CreatedDate DESC LIMIT 1];
	}
}
