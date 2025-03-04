/*****************************************************************
 * Name: SPV_CaseExtension_BU_TRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Update del objeto CBK_Case_Extension__c
 * Las clases test que ejecutan esta clase: SPV_CaseExtension_BU_TRHan_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0                            Álex Polo       16/12/2024   Creación
*****************************************************************/
/**
*   @description SPV_CaseExtension_BU_TRHan
*/
public with sharing class SPV_CaseExtension_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) { 
        process((List<CBK_Case_Extension__c>)tp.newList, (Map<Id, CBK_Case_Extension__c>)tp.newMap, (List<CBK_Case_Extension__c>)tp.oldList, (Map<Id, CBK_Case_Extension__c>)tp.oldMap);
    }

    private void process(List<CBK_Case_Extension__c> listNewObj, Map<Id, CBK_Case_Extension__c> mapNewObj, List<CBK_Case_Extension__c> listOldObj, Map<Id, CBK_Case_Extension__c> mapOldObj) {

        //Llamar al método del helper para filtrar y obtener los casos
        List<CBK_Case_Extension__c> listaCaseExtSPV = SPV_CaseExtensionHelper.filtrarCasosSPV(listNewObj);

        /*if(!listaCaseExtSPV.isEmpty()){

        }*/
    }
}