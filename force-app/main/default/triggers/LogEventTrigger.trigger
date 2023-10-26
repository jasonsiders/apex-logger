trigger LogEventTrigger on LogEvent__e (after insert) {
    new LogEventHandler().run();
}