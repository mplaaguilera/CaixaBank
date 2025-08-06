/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoria
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase para el registro de auditoría para el escenario de registro síncrono obligatorio.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	16/04/2021			Init version
***********************************************************************************************************************/

public with sharing class CBK_RegistroAuditoriaRTObligatorio implements CBK_RegistroAuditoriaInterface {
    private CBK_RegistroAuditoriaEntry datosRegistroAuditoria;
    private User usuarioOperativo;
    public class AuditLogException extends Exception {}

    /**
	 * @description Constructor
     * @author   fzaragoza | 16/04/2021 
	 * @param datosAuditoria		-> Datos para el registro y listado de objetos sobre los que se ha de registrar la actividad (CBK_RegistroAuditoria.CBK_RegistroAuditoriaEntry)
	 * @param usuarioAuditoria		-> Datos del usuario  ue ha ejecutaoo las operaciones auditadas
	 * @return	CBK_RegistroAuditoriaRTObligatorio -> Instancia de la clase CBK_RegistroAuditoriaRTObligatorio
	 */
    public CBK_RegistroAuditoriaRTObligatorio(CBK_RegistroAuditoriaEntry datosAuditoria, User usuarioAuditoria) {
        this.datosRegistroAuditoria = datosAuditoria;
        this.usuarioOperativo = usuarioAuditoria;
    }

    /**
     * @description Método de inserción de las entradas de los registros de auditoría
     * @author   fzaragoza | 16/04/2021 
	 */
    public void registroAuditoria(){
        try{
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
            if (lstRegistrosAuditoria.size()>0 && Schema.sObjectType.CBK_AuditLog__c.isCreateable() ){
                insert lstRegistrosAuditoria;
            }      
        }
        catch (Exception e){
            throw new AuditLogException(Label.CBK_ErrorRegistroAuditoria,e);
        }
    }
}