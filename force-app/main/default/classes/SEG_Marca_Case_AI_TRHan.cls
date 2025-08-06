/**
 *   @description SEG_Marca_Case_AI_TRHan
*/
public with sharing class SEG_Marca_Case_AI_TRHan extends CC_TriggerHandlerBase {
	public override void mainEntry(CC_TriggerParameters tp)
	{
		// Quedarnos solo marcas asociadas a casos de segmento
		Set<Id> caseIds = new Set<Id>();
		Set<Id> caracteIds = new Set<Id>();
		for (SEG_Marcasdeuncaso__c marcaCase : (List<SEG_Marcasdeuncaso__c>) tp.newList) {
			caseIds.add(marcaCase.SEG_Caso__c);
			caracteIds.add(marcaCase.SEG_Caracteristica__c);
		}
		Set<Id> recordTypesSeg = new Set<Id> ();
		Id recordTypeSEG = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		Id recordTypeSeguimiento = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		Id recordTypeMarcasCaso = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SEG_Caracteristicacaso').getRecordTypeId();
		recordTypesSeg.add(recordTypeSEG);
		recordTypesSeg.add(recordTypeSEG);
		Map<Id, Case> mapCases = new Map<Id, Case> ([Select Id From Case Where RecordTypeId IN :recordTypesSeg and Id IN :caseIds]);
		Map<Id, CC_Caracteristica__c> mapCaractCase = new Map<Id, CC_Caracteristica__c> ([Select Id, RecordTypeId From CC_Caracteristica__c Where RecordTypeId = :recordTypeMarcasCaso and Id IN :caracteIds]);
		List<Id> lstMarcaCaseSeg = new List<Id> ();
		for (SEG_Marcasdeuncaso__c marcaCase : (List<SEG_Marcasdeuncaso__c>) tp.newList)
		{
			if (mapCases.containsKey(marcaCase.SEG_Caso__c) && mapCaractCase.containsKey(marcaCase.SEG_Caracteristica__c)) {
				lstMarcaCaseSeg.add(marcaCase.Id);
			}
		}
		if (lstMarcaCaseSeg.size() > 0)
		{
			process(lstMarcaCaseSeg, (List<SEG_Marcasdeuncaso__c>) tp.newList, (Map<Id, SEG_Marcasdeuncaso__c>) tp.newMap, (List<SEG_Marcasdeuncaso__c>) tp.oldList, (Map<Id, SEG_Marcasdeuncaso__c>) tp.oldMap);
		}
	}

	private void process(List<Id> lstMarcaCaseSeg, List<SEG_Marcasdeuncaso__c> listNewObj, Map<Id, SEG_Marcasdeuncaso__c> mapNewObj, List<SEG_Marcasdeuncaso__c> listOldObj, Map<Id, SEG_Marcasdeuncaso__c> mapOldObj)
	{
		crearFotoFacturacion(lstMarcaCaseSeg, mapNewObj);
	}
	private void crearFotoFacturacion(List<Id> lstMarcaCaseSeg, Map<Id, SEG_Marcasdeuncaso__c> mapNewObj) {
		Map<Id, List<SEG_Marcasdeuncaso__c>> caseMarcas = new Map<Id, List<SEG_Marcasdeuncaso__c>> ();
		List<Id> lstCaseIds = new List<Id> ();
		Set<Id> idsMarcas = new Set<Id>();

		for (Id marcaCaseId : lstMarcaCaseSeg) {
			if(mapNewObj.containsKey(marcaCaseId)){
				idsMarcas.add(mapNewObj.get(marcaCaseId).SEG_Caracteristica__c);
			}	
		}

		if(!idsMarcas.isEmpty()){
			List<SEG_MarcasCSO__c> lstMarcasCSO = [SELECT Id, SEG_Marca__c, SEG_ServiciosCSO__c FROM SEG_MarcasCSO__c WHERE SEG_Marca__c IN :idsMarcas];
			Map<Id, String> mapMarcaConCSO = new Map<Id, String>();
			for (SEG_MarcasCSO__c marcaCSO : lstMarcasCSO) {
				if(marcaCSO.SEG_Marca__c != null && marcaCSO.SEG_ServiciosCSO__c != null){
					mapMarcaConCSO.put(marcaCSO.SEG_Marca__c, marcaCSO.SEG_ServiciosCSO__c);
				}
			}
			if(!mapMarcaConCSO.isEmpty()){
				for (Id marcaCaseId : lstMarcaCaseSeg) {
					if(mapNewObj.containsKey(marcaCaseId) && mapMarcaConCSO.containsKey(mapNewObj.get(marcaCaseId).SEG_Caracteristica__c) && mapMarcaConCSO.get(mapNewObj.get(marcaCaseId).SEG_Caracteristica__c) != null){
						if(caseMarcas.containsKey(mapNewObj.get(marcaCaseId).SEG_Caso__c)){
							caseMarcas.get(mapNewObj.get(marcaCaseId).SEG_Caso__c).add(mapNewObj.get(marcaCaseId));
						}else{
							caseMarcas.put(mapNewObj.get(marcaCaseId).SEG_Caso__c, new List<SEG_Marcasdeuncaso__c>{mapNewObj.get(marcaCaseId)});
						}
						lstCaseIds.add(mapNewObj.get(marcaCaseId).SEG_Caso__c);
					}
				}
				if (lstCaseIds.size() > 0) {
					SEG_FotoFacturacionHandler ffHandler = new SEG_FotoFacturacionHandler(lstCaseIds, SEG_FotoFacturacionHandler.Operativa.Marca, caseMarcas);
					System.enqueueJob(ffHandler);
					//ffHandler.createFF();
				}
			}
		}
	}
}