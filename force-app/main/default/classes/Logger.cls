global without sharing virtual class Logger {
    // Static Logger variables
    @TestVisible
    static List<Log__c> pendingLogs = new List<Log__c>(); 
    static LogPublisher configuredPublisher = Logger.getConfiguredPublisher(); 
    static Integer ordinal = 1;
    static System.LoggingLevel threshold = Logger.getThreshold();
    // Constants
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
        // Default to the configured publishing method from Custom Settings
        return this.publish(configuredPublisher); 
    }

    global Logger setApexClass(Type apexClass) {
        this.apexClass = apexClass;
        return this; 
    }

    global Logger setRecordId(Id recordId) {
        this.relatedRecordId = recordId; 
        return this; 
    }

    global Logger setSource(String source) {
        this.source = source;
        return this; 
    }

    // **** PRIVATE **** // 
    private String generateStackTrace() {
        return new LogException()?.sourceStackTrace();
    }

    private Boolean meetsThreshold(System.LoggingLevel level) {
        // Returns true if the level meets/exceeds the threshold
        // With the exception of NONE - which has an ordinal of 0, and should never be valid
        Integer currentSev = (level != null) ? level?.ordinal() : 0; 
        Integer thresholdSev = (threshold != null) ? threshold?.ordinal() : 0;
        System.debug('meetsThreshold() -> currentSev: ' + currentSev + '. thresholdSev: ' + thresholdSev);
        return thresholdSev != 0 && currentSev >= thresholdSev; 
    }

    private Boolean shouldLog(System.LoggingLevel level) {
        // Returns true if Logging is enabled for the current user, 
        // and if the level meets/exceeds the defined threshold
        Boolean isEnabled = LogSetting__c.getInstance()?.Enabled__c == true; 
        Boolean meetsThreshold = this.meetsThreshold(level);
        System.debug('Is Enabled: ' + isEnabled + '. Meets Threshold? ' + meetsThreshold);
        return isEnabled && meetsThreshold; 
    }

    // **** STATIC **** // 
    static System.LoggingLevel getThreshold() {
        // Returns the Threshold__c value expressed as a LoggingLevel enum
        // Defaults to NONE if illegal or missing values configured
        try {
            LogSetting__c settings = LogSetting__c.getInstance();
            String thresholdName = settings?.Threshold__c?.toUpperCase();
            System.LoggingLevel threshold = System.LoggingLevel.valueOf(thresholdName);
            return threshold != null ? threshold : System.LoggingLevel.NONE;
        } catch (Exception error) {
            // Enum.valueOf() throws errors for illegal values
            return System.LoggingLevel.NONE;
        }
    }

    static LogPublisher getConfiguredPublisher() {
        // TODO: Get from CMDT
        LogPublisher publisher = new LogDmlPublisher();
        return publisher; 
    }
    
    // **** INNER **** // 
    global interface LogPublisher {
        void publish(List<Log__c> logs);
    }

    private class LogException extends Exception {
        // This exception will never be thrown - used to generate a stack trace string for log messages
        final String loggerPrefix = 'Class.' + Logger.class?.getName() + '.';

		private String sourceStackTrace() {
            // Returns a stack trace string w/out Logger class internals
            // This allows callers to view the stack trace up until they called the logger method
			List<String> stackTraceLines = new List<String>();
			for (String stackTraceLine : this.getStackTraceString()?.split('\n')) {
				if (!stackTraceLine?.startsWith(this.loggerPrefix)) {
					stackTraceLines.add(stackTraceLine);
				}
			}
			return String.join(stackTraceLines, '\n');
		}
	}
}