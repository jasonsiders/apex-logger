global abstract class LwcLogger {
    // Exposes logging functionality for use in Lightning Components.
    // Note: Users must be given access to this class in order to use its methods.
    @AuraEnabled(cacheable=false)
    global static void log(String payload) {
        try {
            // Expects a serialized JSON representation of a LwcLogger.Input object
            Input input = (Input) JSON.deserialize(payload, Input.class); 
            input?.log();
        } catch (Exception anyError) {
            String msg = anyError?.getMessage(); 
            throw new AuraHandledException(msg); 
        }
    }

    @TestVisible
    private class Input {
        public String body;
        public System.LoggingLevel level; 
        public String relatedRecordId;
        public String source;
        
        private void log() {
            Id recordId = (this.relatedRecordId instanceOf Id) ? this.relatedRecordId : null;
            new Logger()?.setApexClass(LwcLogger.class)?.setRecordId(recordId)?.setSource(this.source)?.log(this.level, this.body)?.publish();
        }
    }
}