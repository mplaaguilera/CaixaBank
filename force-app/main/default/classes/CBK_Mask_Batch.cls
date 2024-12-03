/**********************************************************************************************************************
 Name:	  CBK_Mask_Batch
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase Batch del FW de enascaramiento.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	8/06/2021			Init version
***********************************************************************************************************************/
global class CBK_Mask_Batch implements Database.Batchable<sObject>, Database.Stateful{
//global class CBK_Mask_Batch implements Database.Batchable<sObject>{
    //public class CBK_MaskObjectException extends Exception {}
    private final String strObject;
    private final integer intLimitQuery;
    private final boolean esEncadenadoBatch;
    private final boolean esPrimeraEjecucion;
 
    private final CBK_MaskObject__mdt currentMaskObject;
    private final List<CBK_MaskField__mdt> lstMaskFieldsObject;
    
    //variables para truncado por numero de registros
    private final Id idChunk;
    private final Id endIdChunk;
    private Id initId;
    private Id firstId;
    private Id lastId;
    private final List<Map<String, String>> rangeListChunked;
    private final Map <ID,String> objectRecordTypes;

    list <Id> iniciosIntervalos;
    list <Id> finalesIntervalos;

    public CBK_Mask_Batch(String strObject,Integer intLimit,Boolean esEncadenado, Id idChunk, Boolean esPrimeraEjecucion) {
        intLimitQuery = intLimit;
        esEncadenadoBatch = esEncadenado;
        idChunk = idChunk;
        initId = idChunk;
        esPrimeraEjecucion = esPrimeraEjecucion;
        currentMaskObject = CBK_MaskUtilities.getMaskObjectConfig(strObject);
        strObject = currentMaskObject.CBK_Objeto__c;
        lstMaskFieldsObject = CBK_MaskUtilities.getMaskFieldsConfig(currentMaskObject.Id);
        objectRecordTypes = CBK_MaskUtilities.getObjectRTs(strObject);
        if (currentMaskObject.CBK_ChunkSize__c != null && currentMaskObject.CBK_ChunkSize__c > 0){
            rangeListChunked = CBK_MaskUtilities.chunkIdRange (CBK_MaskUtilities.getFirstId(currentMaskObject.CBK_Objeto__c),CBK_MaskUtilities.getLastId(currentMaskObject.CBK_Objeto__c),currentMaskObject.CBK_ChunkSize__c);
            endIdChunk = CBK_Mask_Batch.getRangeEndingId(idChunk,rangeListChunked);
        }
    }
    public CBK_Mask_Batch() {
        intLimitQuery = 0;
        esEncadenadoBatch = true;
        esPrimeraEjecucion = true;
        currentMaskObject = CBK_MaskUtilities.getMaskObjectConfig(null);
        strObject = currentMaskObject.CBK_Objeto__c;
        idChunk = CBK_MaskUtilities.getFirstId(currentMaskObject.CBK_Objeto__c);
        initId = idChunk;
        lstMaskFieldsObject = CBK_MaskUtilities.getMaskFieldsConfig(currentMaskObject.Id);
        objectRecordTypes = CBK_MaskUtilities.getObjectRTs(strObject);
        if (currentMaskObject.CBK_ChunkSize__c != null && currentMaskObject.CBK_ChunkSize__c > 0){
            rangeListChunked = CBK_MaskUtilities.chunkIdRange (CBK_MaskUtilities.getFirstId(currentMaskObject.CBK_Objeto__c),CBK_MaskUtilities.getLastId(currentMaskObject.CBK_Objeto__c),currentMaskObject.CBK_ChunkSize__c);
            endIdChunk = CBK_Mask_Batch.getRangeEndingId(idChunk,rangeListChunked);
        }
    }
    public CBK_Mask_Batch(Integer intLimit) {
        intLimitQuery = intLimit;
        esEncadenadoBatch = true;
        esPrimeraEjecucion = true;
        currentMaskObject = CBK_MaskUtilities.getMaskObjectConfig(null);
        strObject = currentMaskObject.CBK_Objeto__c;
        idChunk = CBK_MaskUtilities.getFirstId(currentMaskObject.CBK_Objeto__c);
        initId = idChunk;
        lstMaskFieldsObject = CBK_MaskUtilities.getMaskFieldsConfig(currentMaskObject.Id);
        objectRecordTypes = CBK_MaskUtilities.getObjectRTs(strObject);
        if (currentMaskObject.CBK_ChunkSize__c != null && currentMaskObject.CBK_ChunkSize__c > 0){
            rangeListChunked = CBK_MaskUtilities.chunkIdRange (CBK_MaskUtilities.getFirstId(currentMaskObject.CBK_Objeto__c),CBK_MaskUtilities.getLastId(currentMaskObject.CBK_Objeto__c),currentMaskObject.CBK_ChunkSize__c);
            endIdChunk = CBK_Mask_Batch.getRangeEndingId(idChunk,rangeListChunked);
        }
    }
    public CBK_Mask_Batch(String strObject,Integer intLimit,Boolean esEncadenado) {       
        intLimitQuery = intLimit;
        esEncadenadoBatch = esEncadenado;
        esPrimeraEjecucion = true;
        currentMaskObject = CBK_MaskUtilities.getMaskObjectConfig(strObject);
        strObject = currentMaskObject.CBK_Objeto__c;
        idChunk = CBK_MaskUtilities.getFirstId(currentMaskObject.CBK_Objeto__c);
        initId = idChunk;
        lstMaskFieldsObject = CBK_MaskUtilities.getMaskFieldsConfig(currentMaskObject.Id);
        objectRecordTypes = CBK_MaskUtilities.getObjectRTs(strObject);
        if (currentMaskObject.CBK_ChunkSize__c != null && currentMaskObject.CBK_ChunkSize__c > 0){
            rangeListChunked = CBK_MaskUtilities.chunkIdRange (CBK_MaskUtilities.getFirstId(currentMaskObject.CBK_Objeto__c),CBK_MaskUtilities.getLastId(currentMaskObject.CBK_Objeto__c),currentMaskObject.CBK_ChunkSize__c);
            endIdChunk = CBK_Mask_Batch.getRangeEndingId(idChunk,rangeListChunked);
        }
    }

   


    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        if (currentMaskObject.CBK_ChunkSize__c != null && currentMaskObject.CBK_ChunkSize__c > 0){
            query = CBK_MaskUtilities.queryString(idChunk, endIdChunk, currentMaskObject, intLimitQuery);
        }
        else{
            query = CBK_MaskUtilities.queryString(currentMaskObject,intLimitQuery);
        }
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Sobject> objList) {
        Object aux;
        firstId = idChunk;
        lastId = endIdChunk;
        List<Sobject> objListUpdate = new List<Sobject> ();
        for(SObject obj : objList) { 
            if(obj!= null){
                //validamos si el registro debe enmascararse
                if(!currentMaskObject.CBK_CheckMaskRecord__c || (Boolean)obj.get(Schema.getGlobalDescribe().get(currentMaskObject.CBK_Objeto__c).getDescribe().fields.getMap().get(currentMaskObject.CBK_ObjectMaskFlagField__c) )){
                    //Recorremos la lista de campos a tratar del objeto segun metadato
                    if (lstMaskFieldsObject.size()>0){
                        for(CBK_MaskField__mdt fieldToMask : lstMaskFieldsObject){
                            if(fieldToMask.CBK_Activo__c == true){
                                if(fieldToMask.CBK_RecordType__c == null 
                                    || (obj.isSet('RecordTypeId') 
                                        && fieldToMask.CBK_RecordType__c == objectRecordTypes.get((Id)obj.get('RecordTypeId'))
                                )){
                                    if(obj.isSet(Schema.getGlobalDescribe().get(currentMaskObject.CBK_Objeto__c).getDescribe().fields.getMap().get(fieldToMask.CBK_FieldAPIName__c))){
                                        aux = obj.put(Schema.getGlobalDescribe().get(currentMaskObject.CBK_Objeto__c).getDescribe().fields.getMap().get(fieldToMask.CBK_FieldAPIName__c),CBK_MaskUtilities.valorEnmascarado(fieldToMask.CBK_Funcion__c));
                                    }
                                }
                            }                        
                        }
                    }
                    //Seteamos el campo fecha de enmascaramiento en caso de requerirse validar en el objeto
                    if(currentMaskObject.CBK_CheckMaskRecord__c){
                        aux = obj.put(Schema.getGlobalDescribe().get(currentMaskObject.CBK_Objeto__c).getDescribe().fields.getMap().get(currentMaskObject.CBK_ObjectMaskDateField__c),DATE.TODAY());
                    }
                    objListUpdate.add(obj);
                }
            }
        }
        try {
            if(objListUpdate.size() > 0){
                List<Database.SaveResult> results =Database.update(objListUpdate, false);
                List<Object> errores = new List<Object>();
                for (Database.SaveResult result : results) {
                    if (!result.isSuccess()){
                        errores.addAll(result.getErrors());
                    }
                }
                if (errores.size()>0){
                    CBK_Log.error('Error Mask Batch','Error batch update contacts.',errores);
                }
            }
         
        } catch(Exception e) {
            CBK_Log.error(e);
        }
    }   
     
    global void finish(Database.BatchableContext BC) {
        // validamos si hay que lanzar más (y si es en paralelo o secuencial) y por el esPrimera vez
        //secuencial lanzamos si quedan intervalos (solo este parámetro)
        //paralelo solo lanza si es primera vez
        if(rangeListChunked==null || rangeListChunked.size() <= 1){
            //lanza el siguiente objeto
            lanzarBatchSiguienteObjeto(currentMaskObject);
        }
        else{//si ha más de un rango
            if(currentMaskObject.CBK_ParallelBatch__c == true){
                if(esPrimeraEjecucion == true){
                    //lanzamos el resto 
                    for (Integer i=0;i<rangeListChunked.size();i++){
                        if(rangeListChunked[i].get('first') == initId){Object segmentoRetirado = rangeListChunked.remove(i);break;}
                    }
                    for (Map<String, String> range :rangeListChunked){
                        Database.executeBatch(new CBK_Mask_Batch(currentMaskObject.CBK_Objeto__c,intLimitQuery,esEncadenadoBatch,range.get('first'),false), Integer.valueOf(currentMaskObject.CBK_BatchSize__c));
                    }
                }
                else {
                    Integer count = database.countQuery('SELECT Count() FROM AsyncApexJob WHERE ApexClassId IN (SELECT Id from ApexClass WHERE NamespacePrefix = null AND Name = \'CBK_Mask_Batch\') AND Status NOT IN (\'Completed\',\'Aborted\',\'Failed\')');
                    if (count <= 1) {
                        //lanza el siguiente objeto
                        lanzarBatchSiguienteObjeto(currentMaskObject);
                    }
                }
            }
            else{//lanzamos el siguiente en la secuencia (salvo que sea el último, donde entonces lanzaríamos el siguietne)
                if(CBK_MaskUtilities.valorMaximoId(initId, rangeListChunked)){
                    //lanza el siguiente objeto
                    lanzarBatchSiguienteObjeto(currentMaskObject);
                }
                else{
                    //lanzar batch del siguiente segmento (con primeravez false y initId = valor recuperado)
                    Database.executeBatch(new CBK_Mask_Batch(currentMaskObject.CBK_Objeto__c,intLimitQuery,esEncadenadoBatch,CBK_MaskUtilities.valorIdSiguiente(initId,rangeListChunked),false), Integer.valueOf(currentMaskObject.CBK_BatchSize__c));
                }
            }
        }
    }

    private void lanzarBatchSiguienteObjeto(CBK_MaskObject__mdt currentMaskObject){
        if (esEncadenadoBatch){
            CBK_MaskObject__mdt nextMaskObject =  CBK_MaskUtilities.getNextMaskObject(currentMaskObject);
            if (nextMaskObject != null){
                CBK_Mask_Batch b = new CBK_Mask_Batch(nextMaskObject.CBK_Objeto__c,intLimitQuery,esEncadenadoBatch, null,true);
                Database.executeBatch(b, Integer.valueOf(nextMaskObject.CBK_BatchSize__c));
            }
        }
    }
    @TestVisible 
    private static String getRangeEndingId(string idChunk,List<Map<String, String>> rangeListChunks){
        for (Map<String, String> range :rangeListChunks){
            if(((id)range.get('first')) == idChunk){
                return range.get('last');
            }
        }
        return null;
    }
}