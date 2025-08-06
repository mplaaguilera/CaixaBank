public class SEG_Operacion_BI_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp)
	{
		// Quedarnos solo operaciones asociadas a casos de segmento
		System.debug('Trigger SEG_Operacion_BI_TRHan: ');
		Set<Id> caseIds = new Set<Id> ();
		for (SEG_Operacion__c oper : (List<SEG_Operacion__c>) tp.newList) {
			caseIds.add(oper.SEG_SR__c);
		}
		Set<Id> recordTypesSeg = new Set<Id> ();
		Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		Id recordTypeCSO = Schema.SObjectType.SEG_Operacion__c.getRecordTypeInfosByDeveloperName().get('CSO').getRecordTypeId();
		recordTypesSeg.add(recordTypeSEG);
		recordTypesSeg.add(recordTypeSeguimiento);
		Map<Id, Case> mapCases = new Map<Id, Case> ([Select Id, SEG_N_operaciones_CSO__c From Case Where RecordTypeId IN :recordTypesSeg and Id IN :caseIds]);
		List<SEG_Operacion__c> lstOperacionesSegCSO = new List<SEG_Operacion__c> ();
		for (SEG_Operacion__c op : (List<SEG_Operacion__c>) tp.newList)
		{
			if (mapCases.containsKey(op.SEG_SR__c) && op.RecordTypeId == recordTypeCSO) {
				lstOperacionesSegCSO.add(op);
			}
		}
		if (lstOperacionesSegCSO.size() > 0)
		{
			process(lstOperacionesSegCSO, (List<SEG_Operacion__c>) tp.newList);
		}
	}

	private void process(List<SEG_Operacion__c> lstOperacionesSegCSO, List<SEG_Operacion__c> listNewObj)
	{
		updateUsuario(lstOperacionesSegCSO);
	}

	private void updateUsuario(List<SEG_Operacion__c> lstOperacionesSegCSO) {
		for (SEG_Operacion__c op : lstOperacionesSegCSO) {
			if (op.SEG_Usuario__c == null) {
				op.SEG_Usuario__c = UserInfo.getUserId();
			}
		}
	}
}