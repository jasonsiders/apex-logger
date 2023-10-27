@IsTest
private class InvocableLogPublisherTest {
	@IsTest 
	static void shouldPublishWithSpecificPublisher() {
		new Logger().error('This is a test');
		InvocableLogPublisher.Input input = new InvocableLogPublisher.Input();
		input.publisherName = LogEventPublisher.class.getName();

		Test.startTest();
		InvocableLogPublisher.invoke(new List<InvocableLogPublisher.Input>{input});
		Test.getEventBus()?.deliver();
		Test.stopTest();

		Assert.areEqual(1, LogEventPublisher.numPublished, 'Wrong # of Logs Published via LogEventPublisher');
		List<Log__c> logs = [SELECT Id FROM Log__c];
		Assert.areEqual(1, logs?.size(), 'Wrong # of logs');
	}

	@IsTest
	static void shouldUseDefaultPublisherIfNullProvider() {
		// If the publisher value is missing, use the default publisher defined by the user's LogSetting__c,
		new Logger().error('This is a test');
		InvocableLogPublisher.Input input = new InvocableLogPublisher.Input();
		input.publisherName = null;

		Test.startTest();
		InvocableLogPublisher.invoke(new List<InvocableLogPublisher.Input>{input});
		Test.stopTest();

		List<Log__c> logs = [SELECT Id FROM Log__c];
		Assert.areEqual(1, logs?.size(), 'Wrong # of logs');
	}

	@IsTest 
	static void shouldUseDefaultPublisherIfInvalidProvider() {
		// If the publisher value doesn't match an existing Logger.LogPublisher, 
		// use the default publisher defined by the user's LogSetting__c,
		new Logger().error('This is a test');
		InvocableLogPublisher.Input input = new InvocableLogPublisher.Input();
		input.publisherName = 'abcd1234';

		Test.startTest();
		InvocableLogPublisher.invoke(new List<InvocableLogPublisher.Input>{input});
		Test.stopTest();

		List<Log__c> logs = [SELECT Id FROM Log__c];
		Assert.areEqual(1, logs?.size(), 'Wrong # of logs');
	}

	@IsTest 
	static void shouldUseFirstValidInputValue() {
		// Because of the way Flow bulkification works, record-triggered flows produce 1 Input object for each record 
		// However, we shouldn't publish more than once; instead, take the first valid publisher and use it
		new Logger().error('This is a test');
		List<InvocableLogPublisher.Input> inputs = new List<InvocableLogPublisher.Input>();
		for (String publisher : new List<String>{ 
			'abcd1234', 
			LogEventPublisher.class.getName(), 
			LogDmlPublisher.class.getName() 
		}) {
			InvocableLogPublisher.Input input = new InvocableLogPublisher.Input(); 
			input.publisherName = publisher;
			inputs?.add(input);
		}
		
		Test.startTest();
		InvocableLogPublisher.invoke(inputs);
		Assert.areEqual(1, Limits.getPublishImmediateDml(), 'Wrong # of Platform Event Publishes');
		Assert.areEqual(0, Limits.getDmlStatements(), 'Wrong # of DML statements');
		Test.stopTest();

		Assert.areEqual(1, LogEventPublisher.numPublished, 'Wrong # of Logs Published via LogEventPublisher');
	}

	// **** HELPER **** //
	@TestSetup
	static void setup() {
		LogTestUtils.enableLogging(System.LoggingLevel.FINEST);
	}
}
