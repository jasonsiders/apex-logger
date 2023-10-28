global abstract class InvocableLogPublisher {
	static final Logger META_LOGGER = new Logger().setLoggedFrom(InvocableLogPublisher.class);

	@InvocableMethod(category='Logging' label='Publish Logs')
	global static void invoke(List<Input> inputs) {
		// Iterate through the inputs and retrieve the first valid LogPublisher
		// Then use this publisher to publish any pending logs
		for (Input input : inputs) {
			Logger.LogPublisher publisher = input?.getPublisher();
			if (publisher != null) {
				new Logger().publish(publisher);
				break; 
			} else {
				META_LOGGER?.warn(input?.publisher + ' is not a valid instance of Logger.LogPublisher');
			}
		}
		// If the logs are still unpublished, use the default publisher
		new Logger().publish();
	}

	global class Input {
		@InvocableVariable(label='Publisher Class' required=true)
		global String publisher;

		private Logger.LogPublisher getPublisher() {
			return String.isNotBlank(this.publisher)
				? (Logger.LogPublisher) Type.forName(this.publisher)?.newInstance()
				: Logger.DEFAULT_PUBLISHER;
		}
	}
}
