@IsTest 
private class LwcLoggerTest {
    @IsTest 
    static void shouldLogWithValidLoggingLevel() {
        LwcLogger.Input input = new LwcLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.ERROR.name();

        Test.startTest();
        LwcLogger.log(input);
        Test.stopTest();

        List<Log__c> logs = LwcLoggerTest.getLogs(); 
        Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created'); 
        Log__c log = logs[0];
        Assert.areEqual(LwcLogger.class?.getName(), log?.ApexClass__c, 'Wrong Apex Class'); 
        Assert.areEqual(input?.body, log?.Body__c, 'Wrong Level'); 
        Assert.areEqual(input?.level, log?.Level__c, 'Wrong Level'); 
        Assert.isNull(log?.RelatedRecordId__c, 'RelatedRecordId was set, but how?');
        Assert.isNull(log?.Source__c, 'Source was set, but how?');
    }

    @IsTest 
    static void shouldLogWithAdvancedDetails() {
        LwcLogger.Input input = new LwcLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.ERROR.name();
        input.relatedRecordId = UserInfo.getUserId(); 
        input.source = 'fooBarLwc';

        Test.startTest();
        LwcLogger.log(input);
        Test.stopTest();

        List<Log__c> logs = LwcLoggerTest.getLogs(); 
        Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created'); 
        Log__c log = logs[0];
        Assert.areEqual(LwcLogger.class?.getName(), log?.ApexClass__c, 'Wrong Apex Class'); 
        Assert.areEqual(input?.body, log?.Body__c, 'Wrong Level'); 
        Assert.areEqual(input?.level, log?.Level__c, 'Wrong Level'); 
        Assert.areEqual(input?.relatedRecordId, log?.RelatedRecordId__c, 'Wrong RelatedRecordId'); 
        Assert.areEqual(input?.source, log?.Source__c, 'Wrong Source'); 
    }

    @IsTest 
    static void shouldThrowErrorIfInvalidLoggingLevel() {
        LwcLogger.Input input = new LwcLogger.Input(); 
        input.body = 'This is a test';
        input.level = 'abcd1234'; // Not a real logging level
        Exception error; 

        Test.startTest();
        try {
            LwcLogger.log(input);
        } catch (AuraHandledException caughtError) {
            error = caughtError;
        }
        Test.stopTest();

        Assert.isNotNull(error, 'An error was not thrown for an invalid type'); 
    }

    @IsTest 
    static void shouldNotLogIfLevelIsNone() {
        // NONE is still a valid level! No error, but will not log either
        LwcLogger.Input input = new LwcLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.NONE.name();

        Test.startTest();
        LwcLogger.log(input);
        Test.stopTest();

        List<Log__c> logs = LwcLoggerTest.getLogs(); 
        Assert.areEqual(0, logs?.size(), 'Wrong # of Logs created'); 
    }

    @IsTest 
    static void shouldHandleInvalidRecordId() {
        // relatedRecordId isn't a required parameter. If invalid, will default to null.
        LwcLogger.Input input = new LwcLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.FINEST.name();
        input.relatedRecordId = 'abcd1234'; // Not a real record id

        Test.startTest();
        LwcLogger.log(input);
        Test.stopTest();

        List<Log__c> logs = LwcLoggerTest.getLogs(); 
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

    static List<Log__c> getLogs() {
        return [SELECT Id, ApexClass__c, Body__c, Level__c, RelatedRecordId__c, Source__c FROM Log__c];
    }
}