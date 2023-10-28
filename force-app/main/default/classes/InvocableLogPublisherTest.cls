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
		// use the default publisher defined by the user's LogSetting__c.
		// Also: post a warning log, that the defined publisher does not exist
		LogSetting__c settings = LogSetting__c.getInstance();
		settings.Threshold__c = System.LoggingLevel.WARN.name();
		update settings;
		new Logger().error('This is a test');
		InvocableLogPublisher.Input input = new InvocableLogPublisher.Input();
		input.publisherName = 'abcd1234';

		Test.startTest();
		InvocableLogPublisher.invoke(new List<InvocableLogPublisher.Input>{input});
		Test.stopTest();

		Map<String, List<Log__c>> logsByLevel = new Map<String, List<Log__c>>(); 
		for (Log__c log : [SELECT Id, Level__c FROM Log__c]) {
			String level = log?.Level__c;
			List<Log__c> matching = logsByLevel?.containsKey(level)
				? logsByLevel?.get(level)
				: new List<Log__c>();
			matching?.add(log);
			logsByLevel?.put(level, matching);
		}
		Assert.areEqual(2, logsByLevel?.size(), 'Wrong # of logs');
		for (System.LoggingLevel level : new List<System.LoggingLevel>{
			System.LoggingLevel.ERROR, 
			System.LoggingLevel.WARN
		}) {
			Assert.areEqual(1, logsByLevel?.get(level?.name())?.size(), 'Wrong # of ' + level + ' logs');
		}
	}

	@IsTest 
	static void shouldUseFirstInputValue() {
		// Because of the way Flow bulkification works, record-triggered flows produce 1 Input object for each record 
		// However, we shouldn't publish more than once; instead, take the first valid publisher and use it
		new Logger().error('This is a test');
		List<InvocableLogPublisher.Input> inputs = new List<InvocableLogPublisher.Input>();
		for (String publisher : new List<String>{ 
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

	@IsTest 
	static void shouldUseFirstValidInputValue() {
		// Because of the way Flow bulkification works, record-triggered flows produce 1 Input object for each record 
		// However, we shouldn't publish more than once; instead, take the first valid publisher and use it
		new Logger().error('This is a test');
		List<InvocableLogPublisher.Input> inputs = new List<InvocableLogPublisher.Input>();
		for (String publisher : new List<String>{ 
			'abcd1234',
			LogEventPublisher.class.getName()
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

	@IsTest 
	static void shouldTreatNullAsDefaultProvider() {
		new Logger().error('This is a test');
		List<InvocableLogPublisher.Input> inputs = new List<InvocableLogPublisher.Input>();
		for (String publisher : new List<String>{ 
			null,
			LogEventPublisher.class.getName()
		}) {
			InvocableLogPublisher.Input input = new InvocableLogPublisher.Input(); 
			input.publisherName = publisher;
			inputs?.add(input);
		}
		
		Test.startTest();
		InvocableLogPublisher.invoke(inputs);
		Assert.areEqual(0, Limits.getPublishImmediateDml(), 'Wrong # of Platform Event Publishes');
		Assert.areEqual(1, Limits.getDmlStatements(), 'Wrong # of DML statements');
		Test.stopTest();

		Assert.areEqual(0, LogEventPublisher.numPublished, 'Wrong # of Logs Published via LogEventPublisher');
	}

	// **** HELPER **** //
	@TestSetup
	static void setup() {
		LogTestUtils.enableLogging(System.LoggingLevel.ERROR);
	}
}
