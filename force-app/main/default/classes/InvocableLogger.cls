global abstract class InvocableLogger {
    @InvocableMethod(category='Logging') // configurationEditor='c-logger-cpe' label='Log')
	global static void invoke(List<Input> inputs) {
		// Exposes the logger to Flows
		// Note: This flow action does not publish logs
		// To do this, flow developers must call the `InvocableLogPublisher.invoke()` action separately
		// This is done to give flow developers the same flexibility as in Apex
		for (Input input : inputs) {
            input?.log();
        }
	}

    global class Input {
        @InvocableVariable
		global String body;
        
        @InvocableVariable
		global String level;

        @InvocableVariable
        global Id relatedRecordId;

        @InvocableVariable 
        global String source;

		public void log() {
			System.LoggingLevel level = this.getLevel();
            new Logger()
                ?.setApexClass(InvocableLogger.class)
                ?.setRecordId(this.relatedRecordId)
                ?.setSource(this.source)
                ?.log(level, this.body);
		}

        private System.LoggingLevel getLevel() {
            System.LoggingLevel level;
            try {
                level = System.LoggingLevel.valueOf(this.level);
            } catch (Exception error) {
                // Invalid level name 
            }
            return level != null ? level : System.LoggingLevel.NONE;
        }
    }
}