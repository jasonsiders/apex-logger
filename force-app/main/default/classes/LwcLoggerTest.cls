@IsTest 
private class LwcLoggerTest {
    @IsTest 
    static void shouldLogWithValidLoggingLevel() {
        Assert.fail('You still need to build this test'); 
    }

    @IsTest 
    static void shouldThrowErrorIfInvalidLoggingLevel() {
        Assert.fail('You still need to build this test'); 
    }

    @IsTest 
    static void shouldLogWithAdvancedDetails() {
        Assert.fail('You still need to build this test'); 
    }

    @IsTest 
    static void shouldHandleInvalidRecordId() {
        Assert.fail('You still need to build this test'); 
    }

    // **** HELPER **** // 
    @TestSetup
    static void setup() {
        // Enable logging
        insert new LogSetting__c(
            Enabled__c = true, 
            SetupOwnerId = UserInfo.getUserId(),
            Threshold__c = System.LoggingLevel.FINEST.name()
        ); 
    }

}