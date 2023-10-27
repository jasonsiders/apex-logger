global abstract class InvocableLogPublisher {
	static final Logger META_LOGGER = new Logger().setLoggedFrom(InvocableLogPublisher.class);

	@InvocableMethod(category='Logging' label='Publish Logs')
	global static void invoke(List<Input> inputs) {
		Logger.LogPublisher publisher; 
		for (Input input : inputs) {
			try {
				publisher = (Logger.LogPublisher) Type.forName(input?.publisherName)?.newInstance();
				if (publisher != null) {
					break;
				} else {
					throw new System.NoSuchElementException();
				}
			} catch (Exception error) {
				META_LOGGER?.warn(input?.publisherName + ' is not a valid instance of Logger.LogPublisher');
			}
		}
		Logger logger = (publisher != null) 
			? new Logger()?.publish(publisher) 
			: new Logger().publish();
	}

	global class Input {
		@InvocableVariable 
		global String publisherName;
	}
}
