public without sharing class Logger {
    // Static Logger variables
    static PublishMethod defaultMethod; 
    static Integer ordinal = 1;
    static List<Log__c> pendingLogs = new List<Log__c>(); 
    @TestVisible
    static LogSetting__c settings; 
    static System.LoggingLevel threshold;
    static final String TRANSACTION_ID = System.Request.getCurrent()?.getRequestId();

    // Log-specific members
    Type apexClass;
    Id relatedRecordId; 
    String source;

    public void log(System.LoggingLevel level, Object body) {
        // TODO!
        // 1. Determine whether logging is enabled for the user
        // 2. Determine whether the level meets/exceeds the threshold
        // 3. Generate a Log__c record and add to pendingLogs
    }

    public void error(Object body) {
        this.log(System.LoggingLevel.ERROR, body); 
    }

    public void warn(Object body) {
        this.log(System.LoggingLevel.WARN, body); 
    }

    public void info(Object body) {
        this.log(System.LoggingLevel.INFO, body); 
    }

    public void debug(Object body) {
        this.log(System.LoggingLevel.DEBUG, body); 
    }

    public void fine(Object body) {
        this.log(System.LoggingLevel.FINE, body); 
    }

    public void finer(Object body) {
        this.log(System.LoggingLevel.FINER, body); 
    }

    public void finest(Object body) {
        this.log(System.LoggingLevel.FINEST, body); 
    }

    public void publish(PublishMethod method) {
        switch on method {
            when PLATFORM_EVENT {
                // TODO! Publish an event, somehow
                // Probably involves serializing pendingLogs and trying to force it into a LogEvent__e payload?
            }
            when SYNCHRONOUS_DML {
                insert Logger.pendingLogs; 
            }
        }
        Logger.pendingLogs?.clear(); 
    }

    public void publish() {
        // Default to the default publishing method, which is defined in Custom Settings
        this.publish(Logger.defaultMethod); 
    }

    public Logger relateTo(Type apexClass) {
        this.apexClass = apexClass;
        return this; 
    }

    public Logger relateTo(Id recordId) {
        this.relatedRecordId = recordId; 
        return this; 
    }
    
    public Logger relateTo(SObject record) {
        return this.relateTo(record?.Id);
    }

    public Logger setSource(String source) {
        this.source = source;
        return this; 
    }
    
    // **** INNER **** // 
    public enum PublishMethod {
        PLATFORM_EVENT,
        SYNCHRONOUS_DML
    }
}