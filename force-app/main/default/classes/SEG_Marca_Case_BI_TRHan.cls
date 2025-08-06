public class SEG_Marca_Case_BI_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp)
	{
		System.debug('BeforeInsert MarcaCase');
		// Quedarnos solo marcas asociadas a casos de segmento
		Set<Id> caseIds = new Set<Id> ();
		Set<Id> caracteIds = new Set<Id> ();
		for (SEG_Marcasdeuncaso__c marcaCase : (List<SEG_Marcasdeuncaso__c>) tp.newList) {
			caseIds.add(marcaCase.SEG_Caso__c);
			caracteIds.add(marcaCase.SEG_Caracteristica__c);
		}
		Set<Id> recordTypesSeg = new Set<Id> ();
		Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		Id recordTypeMarcasCaso = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SEG_Caracteristicacaso').getRecordTypeId();
		recordTypesSeg.add(recordTypeSEG);
		recordTypesSeg.add(recordTypeSeguimiento);
		Map<Id, Case> mapCases = new Map<Id, Case> ([Select Id From Case Where RecordTypeId IN :recordTypesSeg and Id IN :caseIds]);
		Map<Id, CC_Caracteristica__c> mapCaractCase = new Map<Id, CC_Caracteristica__c> ([Select Id, RecordTypeId From CC_Caracteristica__c Where RecordTypeId = :recordTypeMarcasCaso and Id IN :caracteIds]);
		List<SEG_Marcasdeuncaso__c> lstMarcaCaseSeg = new List<SEG_Marcasdeuncaso__c> ();
		for (SEG_Marcasdeuncaso__c marcaCase : (List<SEG_Marcasdeuncaso__c>) tp.newList)
		{
			if (mapCases.containsKey(marcaCase.SEG_Caso__c) && mapCaractCase.containsKey(marcaCase.SEG_Caracteristica__c)) {
				lstMarcaCaseSeg.add(marcaCase);
			}
		}
		if (lstMarcaCaseSeg.size() > 0)
		{
			process(lstMarcaCaseSeg, (List<SEG_Marcasdeuncaso__c>) tp.newList);
		}
	}
	private void process(List<SEG_Marcasdeuncaso__c> lstMarcaCaseSeg, List<SEG_Marcasdeuncaso__c> listNewObj)
	{
		updateUser(lstMarcaCaseSeg);
	}

	private void updateUser(List<SEG_Marcasdeuncaso__c> lstOperacionesSegCSO) {
		for (SEG_Marcasdeuncaso__c ma : lstOperacionesSegCSO) {
			if (ma.SEG_Usuario__c == null) {
				ma.SEG_Usuario__c = UserInfo.getUserId();
			}
		}
	}
}