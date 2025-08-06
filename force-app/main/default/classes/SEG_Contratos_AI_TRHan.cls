/**
*   @description SEG_Contratos_AI_TRHan
*/
public with sharing class SEG_Contratos_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<SEG_Contratos__c>)tp.newList, (Map<ID, SEG_Contratos__c>)tp.newMap);
	}
    
    private void process(List<SEG_Contratos__c> listObj, Map<ID, SEG_Contratos__c> newMap) {
		
		// Calcular las excepciones de los contratos creados.
		Set<Id> setContratos = newMap.keySet();
		List<Id> listadoContratosEvaluar = new List<Id>(setContratos);
		SEG_ExcepcionesHandler.calcularExcepcionesCasosYContratos(0, null, false, listadoContratosEvaluar);

	}
}