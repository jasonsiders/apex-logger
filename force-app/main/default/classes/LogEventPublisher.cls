global class LogEventPublisher implements Logger.LogPublisher {
    @TestVisible
    static Integer numPublished = 0; 
    
    global void publish(List<Log__c> logs) {
        List<LogEvent__e> events = (List<LogEvent__e>) JSON.deserialize(
            JSON.serialize(logs), 
            List<LogEvent__e>.class
        );
        EventBus.publish(events);
        LogEventPublisher.numPublished += events?.size();
    }
}