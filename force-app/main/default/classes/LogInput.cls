global class LogInput {
	@InvocableVariable
	global String body,
		level,
		loggedFrom,
		relatedRecordId,
		source;

	global void log() {
		System.LoggingLevel level = this.getLevel();
		Id recordId = this.getRecordId();
		new Logger()
			?.setLoggedFrom(this.loggedFrom)
			?.setRelatedRecordId(recordId)
			?.setSource(this.source)
			?.log(level, this.body);
	}

	private System.LoggingLevel getLevel() {
		try {
			return System.LoggingLevel.valueOf(this.level);
		} catch (System.NoSuchElementException error) {
			return System.LoggingLevel.NONE;
		}
	}

	private Id getRecordId() {
		// relatedRecordId must be a string to be safely populated from Flows/LWCs
		return (this.relatedRecordId instanceof Id) ? (Id) this.relatedRecordId : null;
	}
}
