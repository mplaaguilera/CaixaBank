public with sharing class CC_Conversation_BI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		  process((List<unblusuite__Conversation__c>)tp.newList, (Map<Id, unblusuite__Conversation__c>)tp.newMap);
	}

	private void process(List<unblusuite__Conversation__c> listNewObj, Map<Id, unblusuite__Conversation__c> mapNewObj) {
        revisarTranscriptResult(listNewObj);
	}

	private void revisarTranscriptResult(List<unblusuite__Conversation__c> listNewObj) {
		//Metodo que revisa si el campo Transcript esta completo y si es asi actualiza el campo CC_Transcript_Result__c
		for(unblusuite__Conversation__c conversation :listNewObj){
			if(conversation.unblusuite__Transcript__c	!= null  && conversation.unblusuite__Transcript__c	!= '' && conversation.CC_Transcript_Result__c == false){
				conversation.CC_Transcript_Result__c = true;
			}
		}
	}
}