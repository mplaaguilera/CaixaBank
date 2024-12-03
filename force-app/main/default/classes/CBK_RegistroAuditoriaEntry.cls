/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoria
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase wrapper con los datos de registro de auditoría del framework de registro de auditoría.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	16/04/2020			Init version
***********************************************************************************************************************/
public with sharing class CBK_RegistroAuditoriaEntry {
    Public String aplicacion {get; set;}
    Public String tipo {get; set;}
    Public String operacion {get; set;}
    Public List <Sobject> registrosAuditados {get; set;}
    
    /**
    * @description Constructor
    * @author   fzaragoza | 16/04/2021 
    * @param    datosAuditoria  Datos para el registro y listado de objetos sobre los que se ha de registrar la actividad (CBK_RegistroAuditoria.CBK_RegistroAuditoriaEntry)
	* @return	CBK_RegistroAuditoria  Instancia de la clase CBK_RegistroAuditoria
    **/
    public CBK_RegistroAuditoriaEntry (){
        this.aplicacion = '';
        this.tipo= '';
        this.operacion = '';
        this.registrosAuditados = new List <Sobject>();
    }
}