public class CBK_EmailMessage_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
    }

    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj) {
		boolean hasByPassVRCBK = FeatureManagement.checkPermission('CBK_BypassEmailMessageVR');
        List<EmailMessage> outboundEmails = CBK_EmailMessageTriggerHelper.outboundEmailsFilter(listNewObj);
        if (!hasByPassVRCBK && !outboundEmails.isEmpty() && !mapNewObj.isEmpty()) {
            CBK_EmailMessageTriggerHelper.checkFileExtensions(outboundEmails, mapNewObj);
        }
     }

}