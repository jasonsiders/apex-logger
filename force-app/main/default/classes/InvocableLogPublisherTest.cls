@IsTest 
private class InvocableLogPublisherTest {
    @IsTest 
    static void shouldPublish() {
        new Logger().error('This is a test');

        Test.startTest();
        InvocableLogPublisher.invoke();
        Test.stopTest();

        List<Log__c> logs = [SELECT Id FROM Log__c];
        Assert.areEqual(1, logs?.size(), 'Wrong # of logs');
    }

    @TestSetup 
    static void setup() {
        LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
    }
}