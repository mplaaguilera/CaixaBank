public with sharing class SPV_EmailMessageAITRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<EmailMessage>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
	}    
    private void process(List<EmailMessage> listNewObj, Map<Id, EmailMessage> mapNewObj){
        SPV_EmailMessageHelper.pegarInteraccionMessage(listNewObj);
    }
}