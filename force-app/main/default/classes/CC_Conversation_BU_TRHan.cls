public with sharing class CC_Conversation_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
		  process((Map<Id, unblusuite__Conversation__c>)tp.newMap, (Map<Id, unblusuite__Conversation__c>)tp.oldMap);
	}

	private void process(Map<Id, unblusuite__Conversation__c> newMap, Map<Id, unblusuite__Conversation__c> oldMap) {
        revisarTranscriptResult(newMap, oldMap);
	}

    private void revisarTranscriptResult(Map<Id, unblusuite__Conversation__c> newMap, Map<Id, unblusuite__Conversation__c> oldMap) {
		//Metodo que revisa si el campo Transcript esta completo y si es asi actualiza el campo CC_Transcript_Result__c
		for(unblusuite__Conversation__c conversation :newMap.values()){
			if(conversation.unblusuite__Transcript__c	!= null  && conversation.unblusuite__Transcript__c	!= '' && conversation.CC_Transcript_Result__c == false){
				conversation.CC_Transcript_Result__c = true;
			}
            if((conversation.unblusuite__Transcript__c == null  || conversation.unblusuite__Transcript__c == '') && conversation.CC_Transcript_Result__c == true){
				conversation.CC_Transcript_Result__c = false;
			}
		}
	}
}