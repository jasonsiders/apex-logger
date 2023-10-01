# The `Log__c` Object

![A Log Record](/media/logrecord.png)

Log details are stored in the `Log__c` custom object. The object contains these fields:

-   **Body**: Displays the Log message.
-   **Context**: The [`System.Quiddity`](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_Quiddity.htm) of the current transaction. Ex., `ANONYMOUS`.
-   **Level**: Displays the severity of the Log, expressed as a [`System.LoggingLevel`](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_enum_System_LoggingLevel.htm). Ex., `FINEST`.
-   **Logged At**: The Date/Time that the `log()` method was called. This may differ slightly from the `CreatedDate`.
-   **Logged By**: The User who called the `log()` method. This may differ from the `CreatedById`, depending on the publishing method used.
-   **Logged From**: (Optional) Displays the name of the Apex Class, Flow, or Lightning Component which generated the Log, if provided. If `setLoggedFrom()` is not called, this field will be null.
-   **Ordinal**: Indicates the Log's index relative to other logs made in the same transaction. The first Log has an Ordinal of `1`, then `2`, `3`, and so on.
-   **Related Record**: (Optional) The Salesforce Id of a record deemed to be closely related to the Log, if provided. If `setRelatedRecordId()` is not called, this field will be null.
-   **Source**: (Optional) Displays the package, division, or other user-defined "Source" of the Log. If `setSource()` is not called, this field will be null.
-   **Stack Trace**: A stack trace string describing where the Log was generated.
    > Note: This field will always be null when run in a managed package context. If using in a managed package, you can use `LoggedFrom__c` / `setLoggedFrom()` to provide at least some context.
-   **Transaction**: The [unique Id](https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_class_System_Request.htm#apex_System_Request_getRequestId) of the Apex transaction that generated the Log.
