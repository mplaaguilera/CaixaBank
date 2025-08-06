/*****************************************************************
 * Name: SPV_MCCGrupoColaboradorAUTRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger para procesar el After Update del objeto CC_MCC_Grupo_colaborador__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US909081      Raúl Santos    24/06/24        Creación
****************************************************************/ 

public with sharing class SPV_MCCGrupoColaboradorAUTRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_MCC_Grupo_Colaborador__c>)tp.newList, (Map<Id, CC_MCC_Grupo_Colaborador__c>)tp.newMap, (List<CC_MCC_Grupo_Colaborador__c>)tp.oldList, (Map<Id, CC_MCC_Grupo_Colaborador__c>)tp.oldMap);
    }
    
    private void process(List<CC_MCC_Grupo_Colaborador__c> listNewObj, Map<Id, CC_MCC_Grupo_Colaborador__c> mapNewObj, List<CC_MCC_Grupo_Colaborador__c> listOldObj, Map<Id, CC_MCC_Grupo_Colaborador__c> mapOldObj) {

        List<CC_MCC_Grupo_Colaborador__c> lstMCCColaborador = new List<CC_MCC_Grupo_Colaborador__c>();

        for (CC_MCC_Grupo_Colaborador__c mccColaborador : listNewObj){    
         
            if(mccColaborador.SPV_Tipo_Cliente__c == 'SPV' && mapOldObj.containsKey(mccColaborador.Id)){
                lstMCCColaborador.add(mccColaborador);
            }
        }

        if(!lstMCCColaborador.isEmpty()){
            SPV_MCCGrupoColaboradorHelper.heredarActGrupoColaborador(lstMCCColaborador, mapOldObj);
        }

    }
}