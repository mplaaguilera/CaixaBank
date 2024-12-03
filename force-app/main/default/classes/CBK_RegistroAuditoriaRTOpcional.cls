/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoriaRTOpcional
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase para el registro de auditoría para el escenario de registro síncrono opcional.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	21/04/2021			Init version
***********************************************************************************************************************/
public with sharing class CBK_RegistroAuditoriaRTOpcional implements CBK_RegistroAuditoriaInterface {

    public CBK_RegistroAuditoriaEntry datosRegistroAuditoria;
    public User usuarioOperativo;

    /**
	* @description Constructor 
    * @author   fzaragoza | 21/04/2021 
	* @param datosAuditoria		-> datos para el registro y listado de objetos sobre los que se ha de registrar la actividad (CBK_RegistroAuditoria.CBK_RegistroAuditoriaEntry)
	* @param usuarioAuditoria		-> datos del usuario  ue ha ejecutaoo las operaciones auditadas
	* @return	CBK_RegistroAuditoriaRTOpcional	-> Instancia de la clase CBK_RegistroAuditoriaRTOpcional
	*/
    public CBK_RegistroAuditoriaRTOpcional(CBK_RegistroAuditoriaEntry datosAuditoria, User usuarioAuditoria) {
        this.datosRegistroAuditoria = datosAuditoria;
        this.usuarioOperativo = usuarioAuditoria;
    }

    /**
	 * Método de inserción de las entradas de los registros de auditoría
	 */
    public void registroAuditoria(){
        List <CBK_AuditLog__c> lstRegistrosAuditoria = new List <CBK_AuditLog__c>();
        DateTime selloTiempo = DateTime.now();
        if (datosRegistroAuditoria != null && datosRegistroAuditoria.registrosAuditados != null){
            for (SObject registroAuditado : datosRegistroAuditoria.registrosAuditados){
                //valores del registro y rev tipo account
                CBK_AuditLog__c auxiliar = new CBK_AuditLog__c();
                auxiliar.CBK_Aplicacion__c = datosRegistroAuditoria.aplicacion;
                auxiliar.CBK_Tipo__c = datosRegistroAuditoria.tipo;
                auxiliar.CBK_Operacion__c = datosRegistroAuditoria.operacion;
                auxiliar.CBK_RegistroTipoObjeto__c = registroAuditado.getSObjectType().getDescribe().getName();
                if(auxiliar.CBK_RegistroTipoObjeto__c == 'Account'){
                    auxiliar.CBK_RegistroEsCuenta__c = true;
                    auxiliar.CBK_RegistroAccount__c = registroAuditado.Id;
                }
                else{
                    auxiliar.CBK_RegistroEsCuenta__c = false;
                }
                auxiliar.CBK_RegistroId__c = registroAuditado.Id;
                try{
                    auxiliar.CBK_RegistroName__c = (string)registroAuditado.get('Name');
                }
                catch (SObjectException ex){
                    try{
                        auxiliar.CBK_RegistroName__c = (string)registroAuditado.get('Subject');
                    }
                    catch (SObjectException e){auxiliar.CBK_RegistroName__c = '';}
                }
                auxiliar.CBK_FechaHoraAuditoria__c = selloTiempo;
                auxiliar.CBK_UsuarioAuditoria__c = usuarioOperativo.Id;
                auxiliar.CBK_UsuarioAuditoriaEmployeeNumber__c = usuarioOperativo.EmployeeNumber;
                auxiliar.CBK_UsuarioAuditoriaEmail__c = usuarioOperativo.Email;
                lstRegistrosAuditoria.add(auxiliar);
            }
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