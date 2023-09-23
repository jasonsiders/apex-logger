@IsTest 
private class LwcLoggerTest {
    @IsTest 
    static void shouldLogWithValidLoggingLevel() {
        LwcLogger.Input input = new LwcLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.ERROR;

        Test.startTest();
        LwcLogger.log(JSON.serialize(input));
        Test.stopTest();

        List<Log__c> logs = LwcLoggerTest.getLogs(); 
        Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created'); 
        Log__c log = logs[0];
        Assert.areEqual(LwcLogger.class?.getName(), log?.ApexClass__c, 'Wrong Apex Class'); 
        Assert.areEqual(input?.body, log?.Body__c, 'Wrong Level'); 
        Assert.areEqual(input?.level?.name(), log?.Level__c, 'Wrong Level'); 
        Assert.isNull(log?.RelatedRecordId__c, 'RelatedRecordId was set, but how?');
        Assert.isNull(log?.Source__c, 'Source was set, but how?');
    }

    @IsTest 
    static void shouldLogWithAdvancedDetails() {
        LwcLogger.Input input = new LwcLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.ERROR;
        input.relatedRecordId = UserInfo.getUserId(); 
        input.source = 'fooBarLwc';

        Test.startTest();
        LwcLogger.log(JSON.serialize(input));
        Test.stopTest();

        List<Log__c> logs = LwcLoggerTest.getLogs(); 
        Assert.areEqual(1, logs?.size(), 'Wrong # of Logs created'); 
        Log__c log = logs[0];
        Assert.areEqual(LwcLogger.class?.getName(), log?.ApexClass__c, 'Wrong Apex Class'); 
        Assert.areEqual(input?.body, log?.Body__c, 'Wrong Level'); 
        Assert.areEqual(input?.level?.name(), log?.Level__c, 'Wrong Level'); 
        Assert.areEqual(input?.relatedRecordId, log?.RelatedRecordId__c, 'Wrong RelatedRecordId'); 
        Assert.areEqual(input?.source, log?.Source__c, 'Wrong Source'); 
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

    @IsTest 
    static void shouldHandleInvalidLevel() {
        LwcLogger.Input input = new LwcLogger.Input(); 
        input.body = 'This is a test';
        // We can't set an illegal System.LoggingLevel in apex - but JS still can!
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(input));
        params?.put('level', 'abcd1234');
        Exception error; 

        Test.startTest();
        try {
            LwcLogger.log(JSON.serialize(params));
        } catch (AuraHandledException caughtError) {
            error = caughtError; 
        }  
        Test.stopTest();

        Assert.isNotNull(error, 'Error was not thrown/caught for bad LoggingLevel');
    }

    @IsTest 
    static void shouldHandleInvalidRecordId() {
        // relatedRecordId isn't a required parameter. If invalid, will default to null.
        LwcLogger.Input input = new LwcLogger.Input(); 
        input.body = 'This is a test';
        input.level = System.LoggingLevel.ERROR;
        input.relatedRecordId = 'abcd1234';

        Test.startTest();
        LwcLogger.log(JSON.serialize(input));
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