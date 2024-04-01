public abstract class LogRelatedListController {
	@AuraEnabled(cacheable=true)
	public static List<Log__c> getLogs(String recordId) {
		try {
			if (String.isBlank(recordId)) {
				throw new AuraHandledException('Missing Record Id');
			}
			return [
				SELECT
					Id,
					Body__c,
					Context__c,
					Level__c,
					LoggedAt__c,
					LoggedBy__c,
					LoggedBy__r.Name,
					Name,
					RelatedRecordId__c
				FROM Log__c
				WHERE RelatedRecordId__c = :recordId
				ORDER BY Id DESC
				LIMIT 50000
			];
		} catch (Exception error) {
			throw new AuraHandledException(error?.getMessage());
		}
	}

	@AuraEnabled(cacheable=true)
	public static Boolean hasAccess() {
		return SObjectType.Log__c?.isAccessible() == true;
	}
}
