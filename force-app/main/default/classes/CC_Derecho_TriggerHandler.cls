public class CC_Derecho_TriggerHandler {
    public static void handleAfterInsert(List<CC_Derecho__c> newRecords) {
        for (CC_Derecho__c derecho : newRecords) {
            Flow.Interview.CC_Alta_GDPR_AutoLaunched flow = new Flow.Interview.CC_Alta_GDPR_AutoLaunched();
            flow.start();
        }
    }
}
