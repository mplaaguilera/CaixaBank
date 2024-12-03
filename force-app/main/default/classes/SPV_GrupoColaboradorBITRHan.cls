/*********************************************************************************************************
 * Name: SPV_GrupoColaboradorBITRHan
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Insert del objeto Grupo_Colaborador__c
 *              Esta clase se testea con SPV_GrupoColaboradorHelper_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0             US828257           Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

public with sharing class SPV_GrupoColaboradorBITRHan extends CC_TriggerHandlerBase{
    
    private static Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEGESTORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    private static final Id RECTYPETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador__c>)tp.newMap);
	}

    private void process(List<CC_Grupo_Colaborador__c> listNewObj, Map<Id, CC_Grupo_Colaborador__c> mapNewObj) {

        List<CC_Grupo_Colaborador__c> listaGruposSPV = new List<CC_Grupo_Colaborador__c>();

        for (CC_Grupo_Colaborador__c grupo : listNewObj) {
            if (grupo.RecordTypeId == RECTYPEGESTORES) {
                listaGruposSPV.add(grupo);
            }else if (grupo.RecordTypeId == RECTYPELETRADOS){
                listaGruposSPV.add(grupo);
            }else if(grupo.RecordTypeId == RECTYPETAREAS){
                listaGruposSPV.add(grupo);
            }
        }

        if(!listaGruposSPV.isEmpty()){
            SPV_GrupoColaboradorHelper.rellenarNegocio(listaGruposSPV);
        }
    }
}