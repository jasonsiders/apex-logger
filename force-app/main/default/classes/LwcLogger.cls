global abstract class LwcLogger {
    @AuraEnabled(cacheable=false)
    global static void log(LogInput logInput) {
        logInput?.log();
    }

    global class LogInput {
        @AuraEnabled
        global String body, level, relatedRecordId, source;

        private void log() {
            Logger logger = new Logger();
            // TODO!
            logger?.publish();
        }
    }
}