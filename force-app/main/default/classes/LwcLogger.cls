global abstract class LwcLogger {
    @AuraEnabled(cacheable=false)
    global static void log(Input logInput) {
        logInput?.log();
    }

    global class Input {
        @AuraEnabled
        global String body, level, relatedRecordId, source;

        private void log() {
            Logger logger = new Logger();
            // TODO!
            logger?.publish();
        }
    }
}