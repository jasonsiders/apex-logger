@IsTest 
private class LogEventPublisherTest {
    @IsTest 
    static void shouldPublishLogs() {
        LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
        Integer numLogs = Integer.valueOf(Math.random() * 10) + 1; 
        for (Integer i = 0; i < numLogs; i++) {
            new Logger().info('Hello world!'); 
        }
        
        Test.startTest();
        new LogEventPublisher()?.publish(Logger.pendingLogs);
        Test.stopTest();

        Assert.areEqual(numLogs, LogEventPublisher.numPublished, 'Wrong # of Logs Published');
    }
}