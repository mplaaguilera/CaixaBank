/*****************************************************************
 * Name: SPV_MCCAUTRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el After Update del objeto CC_MCC__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US909081      Raúl Santos    10/06/24        Creación
*****************************************************************/

public with sharing class SPV_MCCAUTRHan extends CC_TriggerHandlerBase {

    private static Set<String> objetos = new Set<String>{'CC_MCC__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEDETALLE = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();


    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_MCC__c>)tp.newList, (Map<Id, CC_MCC__c>)tp.newMap, (List<CC_MCC__c>)tp.oldList, (Map<Id, CC_MCC__c>)tp.oldMap);
    }

    private void process(List<CC_MCC__c> listNewObj, Map<Id, CC_MCC__c> mapNewObj, List<CC_MCC__c> listOldObj, Map<Id, CC_MCC__c> mapOldObj) { 
		
        List<CC_MCC__c> lstMCC = new List<CC_MCC__c>();

        for (CC_MCC__c mcc : listNewObj){            
            if(mcc.SPV_BalanceoForzado__c != mapOldObj.get(mcc.Id).SPV_BalanceoForzado__c && mcc.RecordTypeId != RECTYPEDETALLE && mcc.CC_Tipo_Cliente__c == 'SAC'){
                lstMCC.add(mcc);
            }
        }

        if(!lstMCC.isEmpty()){
            SPV_MCCHelper.checkBalaceoForzado(lstMCC, mapNewObj);
        }        
    }
}