public with sharing class CBK_SCH_ChangeOwner extends CBK_SCH_Queueable_Abstract {
    public override void execute(QueueableContext ctx) {
		List<CBK_SCH_PendingProcess__c> LstInfoPp = this.lstInfoProcess;
		work(LstInfoPp);
	}

	private void work(List<CBK_SCH_PendingProcess__c> LstInfoPp) {
		CBK_log.debug('CBK_SCH_Queueable - Input list: Nº '+ LstInfoPp.size()+ ' - ' + JSON.serializePretty(LstInfoPp),  LoggingLevel.INFO);
		List<String> lstIds = new List<String>();
		for(CBK_SCH_PendingProcess__c idObj :LstInfoPp){
			lstIds.add(idObj.RecordId__c);
		}

		String sObjName = Id.valueOf(lstIds[0]).getSObjectType().getDescribe().getName();
		Map<Id, SObject> lstObjChange = new Map<Id, SObject>(Database.query('SELECT Id, OwnerId FROM ' + String.escapeSingleQuotes(sObjName) + ' WHERE Id IN :lstIds'));
		List<SObject> sObjUdp =  new List<SObject>();
		for(CBK_SCH_PendingProcess__c lSch : LstInfoPp){
			if(lstObjChange.containsKey(lSch.RecordId__c)){
				lstObjChange.get(lSch.RecordId__c).put('OwnerId', lSch.Param2__c);
				sObjUdp.add(lstObjChange.get(lSch.RecordId__c));
			}
		}
		CBK_log.debug('Lista Updated: ' + json.serialize(sObjUdp), LoggingLevel.INFO);
		Database.SaveResult[] lstResp = Database.update(sObjUdp, false);
		CBK_log.debug('Response Update: ' + json.serialize(lstResp),  LoggingLevel.INFO);
		for(Database.SaveResult res : lstResp){
			if (res.success){
				CBK_log.debug('ChangeOwner: Update Schedule OK  - response: ' + json.serialize(res), LoggingLevel.INFO);
			}else{
				CBK_Log.error('Error ChangeOwner: Update Schedule - response' + json.serialize(res));
			}
		}
	}
}