@IsTest 
private class LogEventTriggerTest {
    @IsTest 
    static void shouldCreateLogs() {
        for (Integer i = 0; i < 200; i++) {
            new Logger().info('Hello world');
        }
        List<LogEvent__e> events = (List<LogEvent__e>) JSON.deserialize(
            JSON.serialize(Logger.pendingLogs), 
            List<LogEvent__e>.class
        );

        Test.startTest();
        EventBus.publish(events);
        Test.getEventBus()?.deliver();
        Test.stopTest();

        List<Log__c> logs = LogEventTriggerTest.getLogs();
        Assert.areEqual(events?.size(), logs?.size(), 'Wrong # of Logs');
    }

    @IsTest 
    static void shouldMapCorrectValues() {
        LogEvent__e event = new LogEvent__e();
        event.Body__c = 'testing 123';
        event.Category__c = 'my category';
        event.Context__c = 'my context';
        event.Level__c = System.LoggingLevel.FINEST.name();
        event.LoggedAt__c = DateTime.now();
        event.LoggedBy__c = UserInfo.getUserId();
        event.LoggedFrom__c = LogEventTriggerTest.class?.getName();
        event.Ordinal__c = 100;
        event.RelatedRecordId__c = '001' + '0'.repeat(15);
        event.StackTrace__c = 'my stack trace';
        event.Transaction__c = 'my transaction';
        List<LogEvent__e> events = new List<LogEvent__e>{event};

        Test.startTest();
        EventBus.publish(events);
        Test.getEventBus()?.deliver();
        Test.stopTest();

        List<Log__c> logs = LogEventTriggerTest.getLogs();
        Assert.areEqual(events?.size(), logs?.size(), 'Wrong # of Logs');
        Log__c log = logs[0];
        Assert.areEqual(event?.Body__c, log?.Body__c, 'Wrong Body__c');
        Assert.areEqual(event?.Category__c, log?.Category__c, 'Wrong Category__c');
        Assert.areEqual(event?.Context__c, log?.Context__c, 'Wrong Context__c');
        Assert.areEqual(event?.Level__c, log?.Level__c, 'Wrong Level__c');
        Assert.areEqual(event?.LoggedAt__c, log?.LoggedAt__c, 'Wrong LoggedAt__c');
        Assert.areEqual(event?.LoggedBy__c, log?.LoggedBy__c, 'Wrong LoggedBy__c');
        Assert.areEqual(event?.LoggedFrom__c, log?.LoggedFrom__c, 'Wrong LoggedFrom__c');
        Assert.areEqual(event?.Ordinal__c, log?.Ordinal__c, 'Wrong Ordinal__c');
        Assert.areEqual(event?.RelatedRecordId__c, log?.RelatedRecordId__c, 'Wrong RelatedRecordId__c');
        Assert.areEqual(event?.StackTrace__c, log?.StackTrace__c, 'Wrong StackTrace__c');
        Assert.areEqual(event?.Transaction__c, log?.Transaction__c, 'Wrong Transaction__c');
    }

    // **** HELPER **** //
    @TestSetup 
    static void setup() {
        LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
    }

    static List<Log__c> getLogs() {
        return [
            SELECT 
                Id, Body__c, Category__c, Context__c, Level__c, LoggedAt__c, LoggedBy__c, 
                LoggedFrom__c, Ordinal__c, RelatedRecordId__c, StackTrace__c, Transaction__c
            FROM Log__c
        ];
    }
}