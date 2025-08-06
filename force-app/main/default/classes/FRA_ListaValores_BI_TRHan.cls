public with sharing class FRA_ListaValores_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_Lista_Valores__c>) tp.newList, (Map<Id, CC_Lista_Valores__c>) tp.newMap);
	}

	private void process(List<CC_Lista_Valores__c> listNewObj, Map<Id, CC_Lista_Valores__c> mapNewObj) {
		validarInsercionRegistrosTablaEquivalencias(listNewObj);
	}

	private void validarInsercionRegistrosTablaEquivalencias(List<CC_Lista_Valores__c> listNewObj){
		Set<Id> listaValoresIdSet = new Set<Id>();
		Id valorRecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'FRA_TablaEquivalenciasDerivacion_CC_FRAUDE');
		for(CC_Lista_Valores__c valor: listNewObj){
			if(valor.RecordTypeId == valorRecordTypeId && valor.FRA_MotivoOrigen__c != null){
				listaValoresIdSet.add(valor.FRA_MotivoOrigen__c);
			}
		}
		if(listaValoresIdSet != null){
			List<CC_Lista_Valores__c> listaValoresBlacklist = [SELECT Id, FRA_MotivoOrigen__c FROM CC_Lista_Valores__c WHERE RecordTypeId = :valorRecordTypeId AND FRA_MotivoOrigen__c =: listaValoresIdSet LIMIT 1];	

			if(!listaValoresBlacklist.isEmpty()){
				for(CC_Lista_Valores__c valor: listNewObj){
					if(valor.FRA_MotivoOrigen__c == listaValoresBlacklist[0].FRA_MotivoOrigen__c && valor.RecordTypeId == valorRecordTypeId){
						valor.addError('Ya existe una equivalencia para el motivo origen seleccionado');
					}
				}
			}
		}
	}
}