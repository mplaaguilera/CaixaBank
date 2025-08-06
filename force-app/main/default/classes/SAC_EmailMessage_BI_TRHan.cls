public with sharing class SAC_EmailMessage_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}    
    private void process(List<EmailMessage> newList, Map<Id, EmailMessage> mapnewMapNewObj){
        CBK_log.debug('Handler Dummy SAC - SAC_EmailMessage_BI_TRHan');
    }
}