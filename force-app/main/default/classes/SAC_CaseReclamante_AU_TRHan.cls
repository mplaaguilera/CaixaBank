public class SAC_CaseReclamante_AU_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SAC_CaseReclamante__c>) tp.newList, (Map<Id, SAC_CaseReclamante__c>) tp.newMap, (List<SAC_CaseReclamante__c>) tp.oldList, (Map<Id, SAC_CaseReclamante__c>) tp.oldMap);
	}
	private void process(List<SAC_CaseReclamante__c> listNewObj, Map<Id, SAC_CaseReclamante__c> mapNewObj, List<SAC_CaseReclamante__c> listOldObj, Map<Id, SAC_CaseReclamante__c> mapOldObj) {
		SAC_CaseReclamanteHandler.actualizaReclamanteCaso(listNewObj);
	}
}