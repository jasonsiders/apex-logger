@IsTest 
private class LogEventPublisherTest {
    @IsTest 
    static void shouldPublishLogs() {
        List<Log__c> logs = new List<Log__c>();
        for (Integer i = 0; i < 200; i++) {
            Log__c log = new Log__c(); 
            logs?.add(log); 
        }
        
        Test.startTest();
        new LogEventPublisher()?.publish(logs);
        Test.stopTest();

        Assert.areEqual(logs?.size(), LogEventPublisher.numPublished, 'Wrong # of Logs Published');
    }
}