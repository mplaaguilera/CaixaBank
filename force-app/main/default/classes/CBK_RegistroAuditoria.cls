/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoria
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase principal y punto de entrada del framework de registro de auditoría.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	16/04/2021			Init version
***********************************************************************************************************************/
public with sharing class CBK_RegistroAuditoria {
    
    public CBK_RegistroAuditoriaEntry datosRegistroAuditoria;
    private User usuarioAuditoria;
    
    /**
    * @description Constructor
    * @author   fzaragoza | 16/04/2021 
    * @param    datosAuditoria  Datos para el registro y listado de objetos sobre los que se ha de registrar la actividad (CBK_RegistroAuditoria.CBK_RegistroAuditoriaEntry)
	* @return	CBK_RegistroAuditoria  Instancia de la clase CBK_RegistroAuditoria
    **/
    public CBK_RegistroAuditoria (CBK_RegistroAuditoriaEntry datosRegistro){
        this.datosRegistroAuditoria = datosRegistro;
        if (Schema.sObjectType.User.isAccessible() && Schema.sObjectType.User.fields.Name.isAccessible() 
                  && Schema.sObjectType.User.fields.Name.isAccessible() 
                  && Schema.sObjectType.User.fields.Email.isAccessible() 
                  && Schema.sObjectType.User.fields.EmployeeNumber.isAccessible()){
                this.usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        }
    }
    /**
    * @description Método de inserción de las entradas de los registros de auditoría
    * @author   fzaragoza | 16/04/2021 
    **/
    public void registroAuditoria(){
        if (datosRegistroAuditoria != null && datosRegistroAuditoria.tipo != null){
            CBK_AuditLogSetting__c configuracionAuditoria = CBK_AuditLogSetting__c.getValues(datosRegistroAuditoria.tipo);
            if (configuracionAuditoria != null && configuracionAuditoria.CBK_Activo__c){
                CBK_RegistroAuditoriaInterface loggerConcreto;
                loggerConcreto = (CBK_RegistroAuditoriaInterface) CBK_RegistroAuditoriaFactory.instanciaAuditoriaLogger (datosRegistroAuditoria,usuarioAuditoria);
                loggerConcreto.registroAuditoria();
            }
        }
    }
}