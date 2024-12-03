/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoria
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase Factory a la que se delega la creación de un tipo concreto de logger de auditoría.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	16/04/2021			Init version
***********************************************************************************************************************/
public with sharing class CBK_RegistroAuditoriaFactory {

    /**
    * @description Método estático para  la instanciación de la clase de registro deauditoría específica en base a la configuración especificada en el  custom setting CBK_AuditLogSetting__c
    * @author   fzaragoza | 16/04/2021 
    * @param    datosAuditoria  Datos para el registro y listado de objetos sobre los que se ha de registrar la actividad (CBK_RegistroAuditoria.CBK_RegistroAuditoriaEntry)
    * @param    usuarioOperativo  Usuario al que corresponden las operaciones auditadas a registrar la actividad
	* @return	CBK_RegistroAuditoriaInterface  Instancia de la clase la clase registro, devuelta  a traavés  del  iterfaz comun a todas ellas (CBK_RegistroAuditoriaInterface)
    **/
    public static CBK_RegistroAuditoriaInterface instanciaAuditoriaLogger (CBK_RegistroAuditoriaEntry datosRegistroAuditoria, User usuarioOperativo){
        //recuperamos los datos del CS
        CBK_AuditLogSetting__c configuracionAuditoria = CBK_AuditLogSetting__c.getValues(datosRegistroAuditoria.tipo);
        if(configuracionAuditoria== null){
            return null;
        }
        if(!configuracionAuditoria.CBK_Activo__c){
            return null;
        }
        if (configuracionAuditoria.CBK_RTAudit__c){
            if (configuracionAuditoria.CBK_Obligatoriedad__c){
                return new CBK_RegistroAuditoriaRTObligatorio(datosRegistroAuditoria,usuarioOperativo);
            }
            else{
                return new CBK_RegistroAuditoriaRTOpcional(datosRegistroAuditoria,usuarioOperativo);
            }
        }
        else{
            return new CBK_RegistroAuditoriaAsyncOpcional(datosRegistroAuditoria,usuarioOperativo);
        }
    }
}