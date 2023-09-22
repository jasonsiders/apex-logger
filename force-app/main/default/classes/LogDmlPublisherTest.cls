@IsTest 
private class LogDmlPublisherTest {
    @IsTest 
    static void shouldPublishLogs() {
        final Integer numLogs = 200; 
        List<Log__c> logs = new List<Log__c>(); 
        for (Integer i = 0; i < numLogs; i++) {
            Log__c log = new Log__c(); 
            logs?.add(log);
        }
        
        Test.startTest();
        new LogDmlPublisher().publish(logs);
        Test.stopTest();

        for (Log__c log : logs) {
            Assert.isNotNull(log?.Id, 'Log was not inserted');
        }
    }
}