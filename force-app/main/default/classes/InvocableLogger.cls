global abstract class InvocableLogger {
	@InvocableMethod(category='Logging' configurationEditor='c-logger-cpe' label='Log')
	global static void invoke(List<LogInput> inputs) {
		// Exposes the logger to Flows
		for (LogInput input : inputs) {
			input?.log();
		}
	}
}
