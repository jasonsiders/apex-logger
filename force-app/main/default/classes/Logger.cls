global without sharing virtual class Logger {
	// Constants
	public static final LogPublisher DEFAULT_PUBLISHER = Logger.getDefaultPublisher();
	static final Integer LONG_TEXT_LENGTH = Log__c.Body__c?.getDescribe()?.getLength();
	static final Integer SHORT_TEXT_LENGTH = Log__c.Category__c?.getDescribe()?.getLength();
	static final System.Quiddity QUIDDITY = System.Request.getCurrent()?.getQuiddity();
	static final System.LoggingLevel THRESHOLD = Logger.getThreshold();
	static final String TRANSACTION_ID = System.Request.getCurrent()?.getRequestId();
	// Static Logger variables
	@TestVisible
	static List<Log__c> pendingLogs = new List<Log__c>();
	static Integer ordinal = 1;
	// Non-static members
	String category;
	String loggedFrom;
	Id relatedRecordId;

	// **** VIRTUAL **** //
	global virtual Log__c generateLog(System.LoggingLevel level, Object body) {
		return new Log__c(
			Body__c = String.valueOf(body)?.abbreviate(LONG_TEXT_LENGTH),
			Category__c = this.category?.abbreviate(SHORT_TEXT_LENGTH),
			Context__c = QUIDDITY?.name(),
			Level__c = level?.name(),
			LoggedAt__c = DateTime.now(),
			LoggedBy__c = UserInfo.getUserId(),
			LoggedFrom__c = this.loggedFrom,
			Ordinal__c = ordinal++,
			RelatedRecordId__c = this.relatedRecordId,
			StackTrace__c = new LogException()?.getStackForLog()?.abbreviate(LONG_TEXT_LENGTH),
			Transaction__c = TRANSACTION_ID
		);
	}

	global virtual Logger log(System.LoggingLevel level, Object body) {
		if (Test.isRunningTest()) {
			// Print to traditional Apex Debug Logs in @IsTest context
			System.debug(body);
		}
		if (this.shouldLog(level)) {
			// Generate a log and add it to the list of pending logs to publish
			// Logs will not be committed to the database until publish() is called
			Log__c log = this.generateLog(level, body);
			pendingLogs?.add(log);
		}
		return this;
	}

	global virtual Logger publish(LogPublisher publisher) {
		// Commit any pending logs to the database, then purge the list of pending logs
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
		return this.publish(DEFAULT_PUBLISHER);
	}

	global Logger setCategory(String category) {
		this.category = category;
		return this;
	}

	global Logger setLoggedFrom(String componentName) {
		this.loggedFrom = componentName;
		return this;
	}

	global Logger setLoggedFrom(Type apexClass) {
		return this.setLoggedFrom(apexClass?.getName());
	}

	global Logger setRelatedRecordId(Id recordId) {
		this.relatedRecordId = recordId;
		return this;
	}

	global Logger setRelatedRecordId(SObject record) {
		return this.setRelatedRecordId(record?.Id);
	}

	global Logger setSource(String source) {
		// This method used to update the Source__c field
		// Since v1.0.1, this was been replaced with the Category__c field
		// Keep the method around for backwards compatibility, but point at the new field.
		return this.setCategory(source);
	}

	// **** PRIVATE **** //
	static System.LoggingLevel getThreshold() {
		// Returns the Threshold__c value expressed as a LoggingLevel enum
		// Defaults to NONE if illegal or missing values configured
		System.LoggingLevel threshold;
		try {
			LogSetting__c settings = LogSetting__c.getInstance();
			String levelName = settings?.Threshold__c?.toUpperCase();
			threshold = System.LoggingLevel.valueOf(levelName);
		} catch (Exception error) {
			// Enum.valueOf() throws errors for illegal values
		}
		return threshold != null ? threshold : System.LoggingLevel.NONE;
	}

	static LogPublisher getDefaultPublisher() {
		// Returns the LogPublisher class defined in custom settings
		// If none defined, returns an instance of LogDmlPublisher
		LogPublisher publisher;
		try {
			LogSetting__c settings = LogSetting__c.getInstance();
			String publisherName = settings?.Publisher__c;
			publisher = (LogPublisher) Type.forName(publisherName)?.newInstance();
		} catch (Exception error) {
			// May get a Type error if type not found, or if not an instance of LogPublisher
		}
		return publisher != null ? publisher : new LogDmlPublisher();
	}

	private Boolean meetsThreshold(System.LoggingLevel level) {
		// Returns true if the level meets/exceeds the threshold
		// With the exception of NONE - which has an ordinal of 0, and should never be valid
		Integer currentSev = (level != null) ? level?.ordinal() : 0;
		Integer thresholdSev = (THRESHOLD != null) ? THRESHOLD?.ordinal() : 0;
		return thresholdSev != 0 && currentSev >= thresholdSev;
	}

	private Boolean shouldLog(System.LoggingLevel level) {
		// Returns true if Logging is enabled for the current user,
		// and if the level meets/exceeds the defined threshold
		Boolean isEnabled = LogSetting__c.getInstance()?.Enabled__c == true;
		Boolean meetsThreshold = this.meetsThreshold(level);
		return isEnabled && meetsThreshold;
	}

	// **** INNER **** //
	global interface LogPublisher {
		void publish(List<Log__c> logs);
	}

	private class LogException extends Exception {
		// This exception will never be thrown - used to generate a stack trace string for log messages
		final String loggerPrefix = 'Class.' + Logger.class?.getName() + '.';

		private String getStackForLog() {
			// Returns a stack trace string w/out Logger class internals
			// This allows callers to view the stack trace up until they called the logger method
			List<String> stackLines = new List<String>();
			for (String stackLine : this.getStackTraceString()?.split('\n')) {
				if (!stackLine?.startsWith(this.loggerPrefix)) {
					stackLines.add(stackLine);
				}
			}
			return String.join(stackLines, '\n');
		}
	}
}
