/*****************************************************************
 * Name: SAC_MCC_AU_TRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el After Update del objeto CC_MCC__c
 * Las clases test que ejecutan esta clase: SAC_MCC_AU_TRHan_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US523481      Raúl Santos    29/06/23        Creación
*****************************************************************/

public without sharing class SAC_MCC_AU_TRHan extends CC_TriggerHandlerBase {

    private static Set<String> objetos = new Set<String>{'CC_MCC__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEDETALLE = mapRTsObjects.get('CC_MCC__c').get('SAC_Detalle').getRecordTypeId();
    private static final Id RECTYPEPRODUCTO = mapRTsObjects.get('CC_MCC__c').get('CC_Producto_Servicio').getRecordTypeId();
    private static final Id RECTYPEMOTIVO = mapRTsObjects.get('CC_MCC__c').get('CC_Motivo').getRecordTypeId();


    public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CC_MCC__c>)tp.newList, (Map<Id, CC_MCC__c>)tp.newMap, (List<CC_MCC__c>)tp.oldList, (Map<Id, CC_MCC__c>)tp.oldMap);
    }

    private void process(List<CC_MCC__c> listNewObj, Map<Id, CC_MCC__c> mapNewObj, List<CC_MCC__c> listOldObj, Map<Id, CC_MCC__c> mapOldObj) { 
		
        List<CC_MCC__c> lstMCC = new List<CC_MCC__c>();

        for (CC_MCC__c mcc : listNewObj){            
            if(mcc.SAC_EscaladoObligatorio__c != mapOldObj.get(mcc.Id).SAC_EscaladoObligatorio__c && mcc.RecordTypeId != RECTYPEDETALLE){
                lstMCC.add(mcc);
            }
        }

        if(!lstMCC.isEmpty()){
            checkEscaladoObligatorio(lstMCC, mapNewObj);
        }        
    }

    /**************************************************************************
     * Proposito: Cuando se activa/desactiva el check SAC_EscaladoObligatorio__c en un MCC, los niveles de MCC que vayan por debajo de este deben activar/desactivar
     * este campo acorde con el valor del MCC superior
     *
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR          DATE        Description
     * 1.0             US523481      Raúl Santos     29/06/23       Creación
    **************************************************************************/ 
    private void checkEscaladoObligatorio(List<CC_MCC__c> lstMCC, Map<Id, CC_MCC__c> mapNewObj){

        Set<Id> idsMcc = new Set<Id>();
        Map<Id, Boolean> mapaMccEscalado = new Map<Id, Boolean>();

        for(CC_MCC__c mcc : lstMCC){
            idsMcc.add(mcc.Id);
            mapaMccEscalado.put(mcc.Id, mcc.SAC_EscaladoObligatorio__c);
        }

        List<CC_MCC__c> listaMccHijos = [SELECT id, RecordType.DeveloperName, SAC_EscaladoObligatorio__c, CC_Tematica__c, CC_Producto_Servicio__c, CC_Motivo__c, CC_Producto_Servicio__r.CC_Tematica__c, CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c FROM CC_MCC__c WHERE CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__c IN :idsMcc OR CC_Motivo__c IN :idsMcc
                                            OR CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Producto_Servicio__r.CC_Tematica__c IN :idsMcc OR CC_Motivo__r.CC_Producto_Servicio__c IN :idsMcc];

        try { 
            for(CC_MCC__c mcc : listaMccHijos) {
                if(mcc.RecordTypeId == RECTYPEPRODUCTO){
                    if(mapaMccEscalado.containsKey(mcc.CC_Tematica__c)){
                        mcc.SAC_EscaladoObligatorio__c = mapaMccEscalado.get(mcc.CC_Tematica__c);
                    }
                }else if(mcc.RecordTypeId == RECTYPEMOTIVO){
                    if(mapaMccEscalado.containsKey(mcc.CC_Producto_Servicio__c)){
                        mcc.SAC_EscaladoObligatorio__c = mapaMccEscalado.get(mcc.CC_Producto_Servicio__c);
                    }else if(mapaMccEscalado.containsKey(mcc.CC_Producto_Servicio__r.CC_Tematica__c)){
                        mcc.SAC_EscaladoObligatorio__c = mapaMccEscalado.get(mcc.CC_Producto_Servicio__r.CC_Tematica__c);
                    }
                }else if(mcc.RecordTypeId == RECTYPEDETALLE){
                    if(mapaMccEscalado.containsKey(mcc.CC_Motivo__c)){
                        mcc.SAC_EscaladoObligatorio__c = mapaMccEscalado.get(mcc.CC_Motivo__c);
                    }else if(mapaMccEscalado.containsKey(mcc.CC_Motivo__r.CC_Producto_Servicio__c)){
                        mcc.SAC_EscaladoObligatorio__c = mapaMccEscalado.get(mcc.CC_Motivo__r.CC_Producto_Servicio__c);
                    }else if(mapaMccEscalado.containsKey(mcc.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c)){
                        mcc.SAC_EscaladoObligatorio__c = mapaMccEscalado.get(mcc.CC_Motivo__r.CC_Producto_Servicio__r.CC_Tematica__c);
                    }
                }
            }
            
            SAC_DatabaseDML.updateListDML(listaMccHijos, true);
            //Database.update(listaMccHijos);

        } catch (Exception e) {
            CBK_Log.error(e);
        }    
    }
}