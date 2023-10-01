global abstract class LwcLogger {
	// Exposes logging functionality for use in Lightning Components.
	// Note: Users must be given access to this class in order to use its methods.
	@AuraEnabled(cacheable=false)
	global static void log(String payload) {
		try {
			// Expects a serialized JSON representation of a LwcLogger.Input object
			LogInput input = (LogInput) JSON.deserialize(payload, LogInput.class);
			input?.log();
			// Each call from LWC -> Apex happens in its own transaction.
			// No need to separate log/publish logic into separate calls.
			new Logger()?.publish();
		} catch (Exception anyError) {
			String msg = anyError?.getMessage();
			throw new AuraHandledException(msg);
		}
	}
}
