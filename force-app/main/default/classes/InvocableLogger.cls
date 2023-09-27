global abstract class InvocableLogger {
    @InvocableMethod(category='Logging' configurationEditor='c-logger-cpe' label='Log')
	global static void invoke(List<Input> inputs) {
		// Exposes the logger to Flows
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
        global String relatedRecordId;

        @InvocableVariable 
        global String source;

		private void log() {
			System.LoggingLevel level = this.getLevel();
            Id relatedRecordId = this.getRelatedRecordId();
            new Logger()
                ?.setLoggedFrom(InvocableLogger.class)
                ?.setRecordId(relatedRecordId)
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

        private Id getRelatedRecordId() {
            return (this.relatedRecordId instanceOf Id) ? (Id) this.relatedRecordId : null;
        }
    }
}