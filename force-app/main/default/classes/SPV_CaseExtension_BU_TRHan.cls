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
        //List en la que almacenar aquellas reclamaciones a las que se les debe mandar alertas sobre cambios en la fecha de prórroga
        List<CBK_Case_Extension__c> listRecAlertasProrroga = new List<CBK_Case_Extension__c>();
        
        //Llamar al método del helper para filtrar y obtener los casos
        List<CBK_Case_Extension__c> listaCaseExtSPV = SPV_CaseExtensionHelper.filtrarCasosSPV(listNewObj);

        //Se recupera el grupo para utilizar como cola
        Group cola;
        List<Group> listaColas = [SELECT Id, DeveloperName, Name
                                  FROM Group
                                  WHERE Type = 'Queue'
                                  AND DeveloperName = 'SPV_PendienteAsignar'];
        if(!listaColas.isEmpty()){
            for(Group grupoAux : listaColas) {
                if(grupoAux.DeveloperName == 'SPV_PendienteAsignar'){
                    cola = grupoAux;
                }
            }
        }

        //Se procesan las Case Extensions
        if(!listaCaseExtSPV.isEmpty()){
            for(CBK_Case_Extension__c oCaseExtension : listaCaseExtSPV){
                //Se comprueba si se debe enviar alerta para esa reclamación por anulación de prórroga
                if(mapOldObj.containsKey(oCaseExtension.Id) && mapOldObj.get(oCaseExtension.Id).SPV_FechaAnulacionProrroga__c != oCaseExtension.SPV_FechaAnulacionProrroga__c){
                    listRecAlertasProrroga.add(oCaseExtension);
                }
            }

            //En el caso de que se hayan encontrado reclamaciones a las que enviar sus Alertas sobre cambio de fecha de prórroga, se procesan
            if(!listRecAlertasProrroga.isEmpty()){
                SPV_CaseExtensionHelper.comprobarAlertasProrroga(listRecAlertasProrroga, cola);
            }
        }
    }
}