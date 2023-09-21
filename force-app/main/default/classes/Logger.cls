public without sharing class Logger {
    // Static Logger variables
    static PublishMethod defaultMethod; 
    static Integer ordinal = 1;
    static List<Log__c> pendingLogs = new List<Log__c>(); 
    static LogSetting__c settings; 
    static System.LoggingLevel threshold;
    static final String TRANSACTION_ID = System.Request.getCurrent()?.getRequestId();

    // Log-specific members
    Type apexClass;
    Id relatedRecordId; 
    String source;

    public Logger log(System.LoggingLevel level, Object body) {
        if (this.shouldLog(level)) {
            // * Generate a Log__c record and add to pendingLogs
            Log__c log = new Log__c(
                ApexClass__c = this.apexClass?.getName(),
                Body__c = String.valueOf(body),
                Context__c = System.Request.getCurrent()?.getQuiddity()?.name(),
                Level__c = level?.name(),
                LoggedAt__c = DateTime.now(),
                LoggedBy__c = UserInfo.getUserId(),
                Ordinal__c = ordinal++,
                RelatedRecordId__c = this.relatedRecordId,
                Source__c = this.source,
                StackTrace__c = this.generateStackTrace(),
                Transaction__c = TRANSACTION_ID
            ); 
            Logger.pendingLogs?.add(log); 
        }
        return this;
    }

    public Logger error(Object body) {
        return this.log(System.LoggingLevel.ERROR, body); 
    }

    public Logger warn(Object body) {
        return this.log(System.LoggingLevel.WARN, body); 
    }

    public Logger info(Object body) {
        return this.log(System.LoggingLevel.INFO, body); 
    }

    public Logger debug(Object body) {
        return this.log(System.LoggingLevel.DEBUG, body); 
    }

    public Logger fine(Object body) {
        return this.log(System.LoggingLevel.FINE, body); 
    }

    public Logger finer(Object body) {
        return this.log(System.LoggingLevel.FINER, body); 
    }

    public Logger finest(Object body) {
        return this.log(System.LoggingLevel.FINEST, body); 
    }

    public Logger publish(PublishMethod method) {
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
        return this; 
    }

    public Logger publish() {
        // Default to the default publishing method, which is defined in Custom Settings
        return this.publish(Logger.defaultMethod); 
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

    // **** PRIVATE **** // 
    private String generateStackTrace() {
        // TODO!
        return null;
    }

    private Boolean shouldLog(System.LoggingLevel level) {
        // Returns true if Logging is enabled for the current user, 
        // and if the level meets/exceeds the defined threshold
        return false; // TODO!
    }
    
    // **** INNER **** // 
    public enum PublishMethod {
        PLATFORM_EVENT,
        SYNCHRONOUS_DML
    }
}