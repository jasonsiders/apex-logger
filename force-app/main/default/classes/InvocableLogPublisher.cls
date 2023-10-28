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
				META_LOGGER?.warn(input?.publisherName + ' is not a valid instance of Logger.LogPublisher');
			}
		}
		// If the logs are still unpublished, use the default publisher
		new Logger().publish();
	}

	global class Input {
		@InvocableVariable 
		global String publisherName;

		private Logger.LogPublisher getPublisher() {
			return String.isNotBlank(this.publisherName)
				? (Logger.LogPublisher) Type.forName(this.publisherName)?.newInstance()
				: Logger.DEFAULT_PUBLISHER;
		}
	}
}
