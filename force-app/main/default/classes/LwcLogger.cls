global abstract class LwcLogger {
    @AuraEnabled(cacheable=false)
    global static void log(Input logInput) {
        try {
            logInput?.log();
        } catch (Exception anyError) {
            String msg = anyError?.getMessage(); 
            throw new AuraHandledException(msg); 
        }
    }

    global class Input {
        @AuraEnabled
        global String body, level, relatedRecordId, source;

        private void log() {
            System.LoggingLevel level = System.LoggingLevel.valueOf(this.level); 
            Id recordId = (this.relatedRecordId instanceOf Id) ? this.relatedRecordId : null;
            new Logger()?.setApexClass(LwcLogger.class)?.setRecordId(recordId)?.setSource(this.source)?.log(level, this.body)?.publish();
        }
    }
}