/**
 * @description       : Apex Trigger para llamara antes de actualizar
 * @app               : HDT
 * @last modified on  : 13/11/2023
 * @last modified by  : moises.cano.ortiz@ibm.com
 * Modifications Log 
 * Ver   Date         Author                          Modification
 * 1.0   13/11/2023   moises.cano.ortiz@ibm.com   Initial Version
**/
public with sharing class HDT_Llamada_BU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_Llamada__c>)tp.newList, (Map<Id, CC_Llamada__c>)tp.oldMap);
    }

     private void process(List<CC_Llamada__c> listNewObj, Map<Id, CC_Llamada__c> mapOldObj) {
       
        listNewObj = descartarLlamadasNoOutbound(listNewObj);
        if (!listNewObj.isEmpty()) {
            personAccountBU(listNewObj, mapOldObj);
        }
    }

    
    private static List<CC_Llamada__c> descartarLlamadasNoOutbound(List<CC_Llamada__c> llamadas) {
        
        List<CC_Llamada__c> llamadasOutbound = new List<CC_Llamada__c>();
        for (CC_Llamada__c llamada : llamadas) {
            if (Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosById().get(llamada.RecordTypeId).getDeveloperName().startsWith('HDT_')) {
                llamadasOutbound.add(llamada);
            }
        }
        return llamadasOutbound;
    }


    public static void personAccountBU(List<CC_Llamada__c> lstllamada, Map<Id, CC_Llamada__c> mapOldObj) {
        
        Set<Id> setIdCuentas = new Set<Id>();
        List<CC_Llamada__c> llamadas = new List<CC_Llamada__c>();

        for (CC_Llamada__c llamada : lstllamada) {
            if (llamada.CC_Contacto__c != null && mapOldObj.get(llamada.Id).CC_Contacto__c != llamada.CC_Contacto__c) {
                if(!setIdCuentas.contains(llamada.CC_Contacto__c)){
                    setIdCuentas.add(llamada.CC_Contacto__c);
                }
                llamadas.add(llamada);
            }
        }
        
        if(!setIdCuentas.isEmpty()){
            
            Map<Id,Contact> mapAccount = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE Id IN :setIdCuentas AND RecordType.DeveloperName = 'CC_Empleado']);
            
            for (CC_Llamada__c llamada : llamadas) {
                if (mapAccount.containsKey(llamada.CC_Contacto__c)) {
                    llamada.CC_Cuenta__c = mapAccount.get(llamada.CC_Contacto__c).AccountId;
                }
            }
        }
    }


}