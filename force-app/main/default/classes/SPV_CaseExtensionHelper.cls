/*****************************************************************
 * Name: SPV_CaseExtensionHelper
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Operaciones con el objeto Case Extension en SPV
 * Las clases test que ejecutan esta clase: SPV_CaseExtensionHelper_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0                            Álex Polo       16/12/2024   Creación
*****************************************************************/
/**
*   @description SPV_CaseExtensionHelper
*/
public with sharing class SPV_CaseExtensionHelper {

    private static Set<String> objetos = new Set<String>{'CBK_Case_Extension__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    //Record Type de Case Extension para SPV
    private static final Id RECTYPERECLAMACIONEXTENSION = mapRTsObjects.get('CBK_Case_Extension__c').get('SPV_ReclamacionCaseExt').getRecordTypeId();

    public static List<CBK_Case_Extension__c> filtrarCasosSPV(List<CBK_Case_Extension__c> listCasosExt){

        List<CBK_Case_Extension__c> listaCaseExtension = new List<CBK_Case_Extension__c>();

        for(CBK_Case_Extension__c casoExt : listCasosExt){
            if(casoExt.RecordTypeId == RECTYPERECLAMACIONEXTENSION){
                listaCaseExtension.add(casoExt);
            }
        }

        return listaCaseExtension;
    }



}