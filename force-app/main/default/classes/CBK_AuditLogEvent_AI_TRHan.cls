/**********************************************************************************************************************
 Name:	  CBK_AuditLogEvent_AI_TRHan
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase Handler After Insert del trigger del platform event CBK_AuditLogEvent__e del FW de auditoría para el escenario de registro asíncrono opcional.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	21/04/2021			Init version
***********************************************************************************************************************/
public with sharing class CBK_AuditLogEvent_AI_TRHan extends CC_TriggerHandlerBase  {

    /**
    * @description Metodo de entrada invocado en el after insert del trigger 
    * @author   fzaragoza | /04/2021 
    * @param    tp  Parametros del trigger (CC_TriggerParameters)
    **/
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CBK_AuditLogEvent__e>)tp.newList, (Map<Id, CBK_AuditLogEvent__e>)tp.newMap, (List<CBK_AuditLogEvent__e>)tp.oldList, (Map<Id, CBK_AuditLogEvent__e>)tp.oldMap);
    }
    
    /**
    * @description Método de procesamiento invocado desde el método entrada invocado en el after insert del trigger 
    * @author   fzaragoza | 21/04/2021 
    * @param    listNewObj  Lista de los nuevos valores de objetos del trigger  (List<CBK_AuditLogEvent__e>)
    * @param    mapNewObj  Mapa por el ID de objeto de los nuevos valores de objetos del trigger (Map<Id, CBK_AuditLogEvent__e>)
    * @param    listOldObj Lista de los anteriores valores de objetos del trigger (List<CBK_AuditLogEvent__e>)
    * @param    mapOldObj  Mapa por el ID de objeto de los anteriores valores de objetos del trigger (Map<Id, CBK_AuditLogEvent__e>)
    **/
    private void process(List<CBK_AuditLogEvent__e> listNewObj, Map<Id, CBK_AuditLogEvent__e> mapNewObj, List<CBK_AuditLogEvent__e> listOldObj, Map<Id, CBK_AuditLogEvent__e> mapOldObj) {
        generarRegistrosAuditoria(listNewObj);
    }

    /**
    * @description Método de inserción de registros de auditoría, uno por cada evento de plataforma recibido
    * @author   fzaragoza | 21/04/2021 
    * @param    eventos  Lista de los eventos de plataforma CBK_AuditLogEvent__e  (List<CBK_AuditLogEvent__e>)
    **/
    private void generarRegistrosAuditoria(List<CBK_AuditLogEvent__e> eventos){
        list <CBK_AuditLog__c> lstRegistrosAuditoria = new List <CBK_AuditLog__c>();
        for(CBK_AuditLogEvent__e evento : eventos){
            CBK_AuditLog__c auxiliar = new CBK_AuditLog__c();
            auxiliar.CBK_Aplicacion__c = evento.CBK_Aplicacion__c;
            auxiliar.CBK_Tipo__c = evento.CBK_Tipo__c;
            auxiliar.CBK_Operacion__c = evento.CBK_Operacion__c;
            auxiliar.CBK_RegistroTipoObjeto__c = evento.CBK_RegistroTipoObjeto__c;
            auxiliar.CBK_RegistroAccount__c = evento.CBK_RegistroAccount__c;
            auxiliar.CBK_RegistroEsCuenta__c = evento.CBK_RegistroEsCuenta__c;
            auxiliar.CBK_RegistroId__c = evento.CBK_RegistroId__c;
            auxiliar.CBK_RegistroName__c = evento.CBK_RegistroName__c;
            auxiliar.CBK_FechaHoraAuditoria__c = evento.CBK_FechaHoraAuditoria__c;
            auxiliar.CBK_UsuarioAuditoria__c = evento.CBK_UsuarioAuditoria__c;
            auxiliar.CBK_UsuarioAuditoriaEmployeeNumber__c = evento.CBK_UsuarioAuditoriaEmployeeNumber__c;
            auxiliar.CBK_UsuarioAuditoriaEmail__c = evento.CBK_UsuarioAuditoriaEmail__c;
            lstRegistrosAuditoria.add(auxiliar);
        }
        if (lstRegistrosAuditoria.size()>0 && Schema.sObjectType.CBK_AuditLog__c.isCreateable()){
            Database.SaveResult[] srList = Database.insert(lstRegistrosAuditoria, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('campos del registro de auditoría afectados por el error: ' + err.getFields());
                    }
                }
            }
        }
    }
}