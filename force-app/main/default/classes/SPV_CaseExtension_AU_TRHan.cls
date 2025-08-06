/*****************************************************************
* Name: SPV_CaseExtension_AU_TRHan
* Copyright © 2021  CaixaBank
* 
* Proposito: Trigger Handler para controlar el Before Update del objeto CBK_Case_Extension__c
* Las clases test que ejecutan esta clase:  * Name: SPV_CaseExtension_AU_TRHan_Test

* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR         DATE         Description
* 1.0                            Álex Polo       16/12/2024   Creación
*****************************************************************/
/**
*   @description SPV_CaseExtension_AU_TRHan
*/
public with sharing class SPV_CaseExtension_AU_TRHan extends CC_TriggerHandlerBase{
    private static Set<String> objetos = new Set<String>{'CBK_Case_Extension__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);
    private static final Id RECTYPERECLAMACIONEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SPV_ReclamacionCaseExt').getRecordTypeId();
    //private static final Id RECTYPEPRETENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SPV_PretensionCaseExt').getRecordTypeId();
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CBK_Case_Extension__c>)tp.newList, (Map<Id, CBK_Case_Extension__c>)tp.newMap, (List<CBK_Case_Extension__c>)tp.oldList, (Map<Id, CBK_Case_Extension__c>)tp.oldMap);
    }
    
    private void process(List<CBK_Case_Extension__c> listNewObj, Map<Id, CBK_Case_Extension__c> mapNewObj, List<CBK_Case_Extension__c> listOldObj, Map<Id, CBK_Case_Extension__c> mapOldObj) {
        
        //Llamar al método del helper para filtrar y obtener los casos
        List<CBK_Case_Extension__c> listaCaseExtSPV = SPV_CaseExtensionHelper.filtrarCasosSPV(listNewObj);
        List<CBK_Case_Extension__c> lstReclamaciones = new List<CBK_Case_Extension__c>();
        List<CBK_Case_Extension__c> lstPretensiones = new List<CBK_Case_Extension__c>();
        
        for(CBK_Case_Extension__c caso :listaCaseExtSPV){
            if(caso.RecordTypeId == RECTYPERECLAMACIONEXTENSION){
                lstReclamaciones.add(caso);
            }/*else if(caso.RecordTypeId == RECTYPEPRETENSION){
                lstPretensiones.add(caso);
            }*/
        }
        if(!lstReclamaciones.isEmpty()){
            //Si se actualiza algún campo de una reclamación que haya que registrar, crear actividades
            SPV_CaseExtensionHelper.registrarCamposActividades(listaCaseExtSPV, mapOldObj);        
        }
        /*if(!lstPretensiones.isEmpty()){
            
        }*/
    }
}