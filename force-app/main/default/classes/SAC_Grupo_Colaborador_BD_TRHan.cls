/*********************************************************************************************************
 * Name: SAC_Grupo_Colaborador_BD_TRHan
 * Copyright © 2019  CaixaBank
 * =======================================================================================================
 * Proposito: Trigger Handler para controlar el Before Delete  del objeto Grupo_Colaborador__c
 * =======================================================================================================
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0            US206848              Marcela Neira        22/04/21            Creación
**********************************************************************************************************/

public with sharing class SAC_Grupo_Colaborador_BD_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador__c>)tp.newMap, (List<CC_Grupo_Colaborador__c>)tp.oldList, (Map<Id, CC_Grupo_Colaborador__c>)tp.oldMap);
    }
    
    private void process(List<CC_Grupo_Colaborador__c> listNewObj, Map<Id, CC_Grupo_Colaborador__c> mapNewObj, List<CC_Grupo_Colaborador__c> listOldObj, Map<Id, CC_Grupo_Colaborador__c> mapOldObj) {
        //Obtener record Type
        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        Id recTypeTareas =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();  
        
        List<CC_Grupo_Colaborador_Contact__c> grupoColaboradorContact = new List<CC_Grupo_Colaborador_Contact__c>();
        if(Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isAccessible()){
            grupoColaboradorContact = [SELECT id, CC_Grupo_Colaborador__c, CC_Usuario__c
                                            FROM CC_Grupo_Colaborador_Contact__c
                                            WHERE CC_Grupo_Colaborador__c IN :listOldObj
                                            AND (CC_Grupo_Colaborador__r.RecordTypeId =:recTypeProveedores
                                                                                OR CC_Grupo_Colaborador__r.RecordTypeId =:recTypeTareas)];
        }
        if(!grupoColaboradorContact.isEmpty()){
            if(Schema.sObjectType.CC_Grupo_Colaborador_Contact__c.isDeletable()){
                delete grupoColaboradorContact ;
            }
            
        }

        //Recorrer la lista del trigger new y asignar los grupos que tengan el record type SAC_GrupoProveedores a la lista con la que queremos trabajar.
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        for (CC_Grupo_Colaborador__c grupo : listOldObj) {
            if (grupo.RecordTypeId == recTypeProveedores) {
                listaGrupos.add(grupo);
            }
        }
        //Si la lista con los grupos no está vacia, trabajamos con nuestros métodos
        if (!listaGrupos.isEmpty()) {
            SAC_PorcentajesGrupoColaborador.comprobarPorcentajeDelete(listaGrupos); //Comprueba que el porcenatje de todos los grupos sea igual a 100 cuando borras un registro
        }
        
    }
    
}