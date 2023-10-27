global abstract class InvocableLogPublisher {
	@InvocableMethod(category='Logging' label='Publish Logs')
	global static void invoke(List<Input> inputs) {
		Logger.LogPublisher publisher; 
		for (Input input : inputs) {
			try {
				publisher = (Logger.LogPublisher) Type.forName(input?.publisherName)?.newInstance();
				if (publisher != null) {
					break;
				}
			} catch (Exception error) {
				// Nothing for now
			}
		}
		if (publisher != null) {
			// Use the publisher!
			new Logger().publish(publisher);
		} else {
			// Use the default publisher
			new Logger()?.publish();
		}
	}

	global class Input {
		@InvocableVariable 
		global String publisherName;
	}
}
