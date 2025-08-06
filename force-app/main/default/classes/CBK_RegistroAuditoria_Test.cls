/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoria_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_RegistroAuditoria del framework de registro de auditoría.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	20/04/2021			Init version
***********************************************************************************************************************/
@IsTest private class CBK_RegistroAuditoria_Test {
    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 20/04/2021 
    **/
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
        list <CBK_AuditLogSetting__c> lstCSAuditLog = new list <CBK_AuditLogSetting__c> ();
        CBK_AuditLogSetting__c registroRTOBligatorio = new  CBK_AuditLogSetting__c();
        registroRTOBligatorio.Name = 'ConsultaSaldo';
        registroRTOBligatorio.CBK_Tipo__c = 'ConsultaSaldo';
        registroRTOBligatorio.CBK_RTAudit__c = true;
        registroRTOBligatorio.CBK_Obligatoriedad__c = true;
        registroRTOBligatorio.CBK_Activo__c = true;
        insert registroRTOBligatorio;
    }
    /**
    * @description Método de test para validar la invocación de la funcionalidad a través de la clase CBK_RegistroAuditoria
    * @author   fzaragoza | 20/04/2021 
    **/
    @IsTest static void accesoFuncionalidad() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'ConsultaSaldo';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 2];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoria logger = new CBK_RegistroAuditoria(datosAudit);
        logger.registroAuditoria();
        list <CBK_AuditLog__c> registros = [SELECT Id  FROM CBK_AuditLog__c];
        System.assertEquals(2, registros.size(),'No coincide el número de registros esperados');
    }
}