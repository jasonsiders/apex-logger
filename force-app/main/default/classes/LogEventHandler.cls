public class LogEventHandler {
    System.TriggerOperation operation = Trigger.operationType;
    List<LogEvent__e> logEvents = Trigger.new;

    public void run() {
        if (this.operation == System.TriggerOperation.AFTER_INSERT) {
            List<Log__c> logs = this.convertToLogs(this.logEvents);
            Database.insert(logs, false);
        }
    }

    private List<Log__c> convertToLogs(List<LogEvent__e> events) {
        return (List<Log__c>) JSON.deserialize(JSON.serialize(events), List<Log__c>.class);
    }
}