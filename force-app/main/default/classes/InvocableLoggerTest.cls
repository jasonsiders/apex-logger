@IsTest 
private class InvocableLoggerTest {
    @IsTest 
    static void shouldLogWithValidLoggingLevel() {
        InvocableLogger.Input input = new InvocableLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.ERROR.name();

        Test.startTest();
        InvocableLogger.invoke(new List<InvocableLogger.Input>{input});
        Test.stopTest();

        List<Log__c> logs = Logger.pendingLogs; 
        Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created'); 
        Log__c log = logs[0];
        Assert.areEqual(InvocableLogger.class?.getName(), log?.ApexClass__c, 'Wrong Apex Class'); 
        Assert.areEqual(input?.body, log?.Body__c, 'Wrong Level'); 
        Assert.areEqual(input?.level, log?.Level__c, 'Wrong Level'); 
        Assert.isNull(log?.RelatedRecordId__c, 'RelatedRecordId was set, but how?');
        Assert.isNull(log?.Source__c, 'Source was set, but how?');
    }

    @IsTest 
    static void shouldLogWithAdvancedDetails() {
        InvocableLogger.Input input = new InvocableLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.ERROR.name();
        input.relatedRecordId = UserInfo.getUserId(); 
        input.source = 'fooBarFlow';

        Test.startTest();
        InvocableLogger.invoke(new List<InvocableLogger.Input>{input});
        Test.stopTest();

        List<Log__c> logs = Logger.pendingLogs; 
        Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created'); 
        Log__c log = logs[0];
        Assert.areEqual(InvocableLogger.class?.getName(), log?.ApexClass__c, 'Wrong Apex Class'); 
        Assert.areEqual(input?.body, log?.Body__c, 'Wrong Level'); 
        Assert.areEqual(input?.level, log?.Level__c, 'Wrong Level'); 
        Assert.areEqual(input?.relatedRecordId, log?.RelatedRecordId__c, 'Wrong RelatedRecordId'); 
        Assert.areEqual(input?.source, log?.Source__c, 'Wrong Source'); 
    }

    @IsTest 
    static void shouldHandleInvalidLevel() {
        // If an invlaid logging level is given, will default to NONE
        InvocableLogger.Input input = new InvocableLogger.Input(); 
        input.body = 'This is a test';
        input.level = 'abc123';

        Test.startTest();
        InvocableLogger.invoke(new List<InvocableLogger.Input>{input});
        Test.stopTest();

        List<Log__c> logs = Logger.pendingLogs; 
        Assert.areEqual(0, logs?.size(), 'Wrong # of logs created');
    }

    @IsTest 
    static void shouldHandleInvalidRecordId() {
        // relatedRecordId isn't a required parameter. If invalid, will default to null.
        InvocableLogger.Input input = new InvocableLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.ERROR?.name();
        input.relatedRecordId = 'abcd1234';

        Test.startTest();
        InvocableLogger.invoke(new List<InvocableLogger.Input>{input});
        Test.stopTest();

        List<Log__c> logs = Logger.pendingLogs;
        Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created'); 
        Log__c log = logs[0];
        Assert.isNull(log?.RelatedRecordId__c, 'Invalid relatedRecordId posted to log');
    }

    // **** HELPER **** //
    @TestSetup
    static void setup() {
        // Enable logging
        insert new LogSetting__c(
            Enabled__c = true, 
            SetupOwnerId = UserInfo.getUserId(),
            Threshold__c = System.LoggingLevel.FINEST.name()
        ); 
    }
}