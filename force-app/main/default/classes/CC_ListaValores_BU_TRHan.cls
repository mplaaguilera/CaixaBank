public class CC_ListaValores_BU_TRHan extends CC_TriggerHandlerBase {

	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_Lista_Valores__c>) tp.newList, (Map<Id, CC_Lista_Valores__c>) tp.newMap, (List<CC_Lista_Valores__c>) tp.oldList, (Map<Id, CC_Lista_Valores__c>) tp.oldMap);
	}

	private void process(List<CC_Lista_Valores__c> listNewObj, Map<Id, CC_Lista_Valores__c> mapNewObj, List<CC_Lista_Valores__c> listOldObj, Map<Id, CC_Lista_Valores__c> mapOldObj) {
		validarInsercionRegistrosBlacklist(listNewObj, mapOldObj);
	}

	private void validarInsercionRegistrosBlacklist(List<CC_Lista_Valores__c> listNewObj, Map<Id, CC_Lista_Valores__c> mapOldObj ){
		Set<Id> listaValoresIdSet = new Set<Id>();
		Id valorRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
		for(CC_Lista_Valores__c valor: listNewObj){
			if(valor.CC_Valor__c != mapOldObj.get(valor.Id).CC_Valor__c && valor.RecordTypeId == valorRecordTypeId && valor.CC_Lista__c != null){
				listaValoresIdSet.add(valor.CC_Lista__c);
			}
		}
		if(listaValoresIdSet != null){
			List<CC_Lista_Valores__c> listaValoresBlacklist = [SELECT Id, Name FROM CC_Lista_Valores__c WHERE Id =: listaValoresIdSet AND Name = 'CSBD: Blacklist'];		
			if(!listaValoresBlacklist.isEmpty()){
				Set<String> camposAdmitidosBlacklist = new Set<String>();
				for(CSBD_Campos_blacklist__mdt metadatoBlacklist: [SELECT MasterLabel FROM CSBD_Campos_blacklist__mdt]){
					camposAdmitidosBlacklist.add(metadatoBlacklist.MasterLabel);
				}
				for(CC_Lista_Valores__c valor: listNewObj){
					if(valor.CC_Lista__c == listaValoresBlacklist[0].Id && valor.RecordTypeId == valorRecordTypeId){
						if(!camposAdmitidosBlacklist.contains(valor.CC_Valor__c)){
							valor.addError('El nombre indicado para el campo Valor de la lista '+ listaValoresBlacklist[0].Name + ' no es válido. Valores disponibles: ' + String.valueOf(camposAdmitidosBlacklist).replace('{', '"').replace('}', '"'));
						}
					}
				}
			}
		}
	}
}