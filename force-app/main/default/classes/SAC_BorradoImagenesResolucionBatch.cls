/***************************************************************************************************************
 * Name: SAC_BorradoImagenesResolucionBatch
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Eliminar todos los registros del objeto SAC_ImagenDocumento__c de las reclamaciones cerradas
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0             US934210     Sergio Martín      10/06/2024      Creación
***************************************************************************************************************/
public with sharing class SAC_BorradoImagenesResolucionBatch implements Database.batchable<sObject>{
    private static Set<String> objetos = new Set<String>{'Case','SAC_ImagenDocumento__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEIMAGENES = mapRTsObjects.get('SAC_ImagenDocumento__c').get('SAC_ImagenDocumento').getRecordTypeId();
    private static final Id RECTYPERECLAMACION =  mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    
    public Database.QueryLocator start(Database.BatchableContext dbc) {
        return Database.getQueryLocator([SELECT Id, SAC_Imagen__c, SAC_Caso__c FROM SAC_ImagenDocumento__c WHERE RecordTypeId = :RECTYPEIMAGENES AND SAC_Caso__r.RecordTypeId = :RECTYPERECLAMACION AND SAC_Caso__r.status = 'Cerrado']);
    }

    public void execute(Database.BatchableContext dbc, List<SAC_ImagenDocumento__c > imagenes){
        if(!imagenes.isEmpty()) {
            if(SAC_ImagenDocumento__c.SObjectType.getDescribe().isDeletable()) {
                Database.delete(imagenes,false);  
            }  
        }  
    }

    public void finish(Database.BatchableContext dbc){
       CBK_Log.debug('Borrado automatico ejecutado con exito');
    }
}