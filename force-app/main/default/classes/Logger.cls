global without sharing virtual class Logger {
    // Static Logger variables
    static LogPublisher defaultPublisher = Logger.getDefaultPublisher(); 
    static Integer ordinal = 1;
    static List<Log__c> pendingLogs = new List<Log__c>(); 
    static System.LoggingLevel threshold = Logger.getThreshold();
    static final String TRANSACTION_ID = System.Request.getCurrent()?.getRequestId();

    // Log-specific members
    Type apexClass;
    Id relatedRecordId; 
    String source;

    // **** VIRTUAL **** // 
    global virtual Log__c generateLog(System.LoggingLevel level, Object body) {
        return new Log__c(
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
    }

    global virtual Logger log(System.LoggingLevel level, Object body) {
        if (this.shouldLog(level)) {
            // * Generate a Log__c record and add to pendingLogs
            Log__c log = this.generateLog(level, body);
            pendingLogs?.add(log); 
        }
        return this;
    }

    global virtual Logger publish(LogPublisher publisher) {
        publisher?.publish(pendingLogs);
        pendingLogs?.clear(); 
        return this; 
    }

    // **** PUBLIC **** // 
    global Logger error(Object body) {
        return this.log(System.LoggingLevel.ERROR, body); 
    }

    global Logger warn(Object body) {
        return this.log(System.LoggingLevel.WARN, body); 
    }

    global Logger info(Object body) {
        return this.log(System.LoggingLevel.INFO, body); 
    }

    global Logger debug(Object body) {
        return this.log(System.LoggingLevel.DEBUG, body); 
    }

    global Logger fine(Object body) {
        return this.log(System.LoggingLevel.FINE, body); 
    }

    global Logger finer(Object body) {
        return this.log(System.LoggingLevel.FINER, body); 
    }

    global Logger finest(Object body) {
        return this.log(System.LoggingLevel.FINEST, body); 
    }

    global Logger publish() {
        // Default to the default publishing method, which is defined in Custom Settings
        return this.publish(defaultPublisher); 
    }

    global Logger relateTo(Id recordId) {
        this.relatedRecordId = recordId; 
        return this; 
    }
    
    global Logger relateTo(SObject record) {
        return this.relateTo(record?.Id);
    }

    global Logger setApexClass(Type apexClass) {
        this.apexClass = apexClass;
        return this; 
    }

    global Logger setSource(String source) {
        this.source = source;
        return this; 
    }

    // **** PRIVATE **** // 
    private String generateStackTrace() {
        // TODO!
        return null;
    }

    private Boolean meetsThreshold(System.LoggingLevel level) {
        // Returns true if the level meets/exceeds the threshold
        // With the exception of NONE - which has an ordinal of 0, and should never be valid
        Integer currentSev = (level != null) ? level?.ordinal() : 0; 
        Integer thresholdSev = (threshold != null) ? threshold?.ordinal() : 0;
        return threshold != System.LoggingLevel.NONE && currentSev <= thresholdSev; 
    }

    private Boolean shouldLog(System.LoggingLevel level) {
        // Returns true if Logging is enabled for the current user, 
        // and if the level meets/exceeds the defined threshold
        Boolean isEnabled = LogSetting__c.getInstance()?.Enabled__c == true; 
        Boolean meetsThreshold = this.meetsThreshold(level);
        return isEnabled && meetsThreshold; 
    }

    // **** STATIC **** // 
    static System.LoggingLevel getThreshold() {
        return null; // TODO!
    }

    static LogPublisher getDefaultPublisher() {
        return null; 
    }
    
    // **** INNER **** // 
    global interface LogPublisher {
        void publish(List<Log__c> logs);
    }
}