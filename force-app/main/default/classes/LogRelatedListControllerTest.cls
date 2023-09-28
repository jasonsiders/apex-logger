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

    // **** HELPER **** // 
    static final Integer NUM_TEST_LOGS = 200; 

    @TestSetup 
    static void setup() {
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

    static Account getAccount() {
        List<Account> accounts = [SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 1];
        return accounts?.isEmpty() ? null : accounts[0];
    }
}