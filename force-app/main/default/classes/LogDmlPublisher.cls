global without sharing virtual class LogDmlPublisher implements Logger.LogPublisher {
    // This publisher class insert logs w/standard DML
    global virtual void publish(List<Log__c> logs) {
        insert logs;
        System.debug('LogDmlPublisher.publish(): ' + JSON.serializePretty(logs));
    }
}