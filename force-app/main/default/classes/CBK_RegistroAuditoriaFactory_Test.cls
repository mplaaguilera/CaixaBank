/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoriaFactory_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_RegistroAuditoriaFactory del framework de registro de auditoría.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	21/04/2021			Init version
***********************************************************************************************************************/
@IsTest private class CBK_RegistroAuditoriaFactory_Test {
    
    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 21/04/2021 
    **/
    @testSetup static void setup() {
        // Create common test accounts
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<3;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
        list <CBK_AuditLogSetting__c> lstCSAuditLog = new list <CBK_AuditLogSetting__c> ();
        CBK_AuditLogSetting__c registroRTOBligatorio = new  CBK_AuditLogSetting__c();
        registroRTOBligatorio.Name = 'RTOb';
        registroRTOBligatorio.CBK_Tipo__c = 'RTOb';
        registroRTOBligatorio.CBK_RTAudit__c = true;
        registroRTOBligatorio.CBK_Obligatoriedad__c = true;
        registroRTOBligatorio.CBK_Activo__c = true;
        lstCSAuditLog.add(registroRTOBligatorio);
        CBK_AuditLogSetting__c registrRTOpcional = new  CBK_AuditLogSetting__c();
        registrRTOpcional.Name = 'RTOp';
        registrRTOpcional.CBK_Tipo__c = 'RTOp';
        registrRTOpcional.CBK_RTAudit__c = true;
        registrRTOpcional.CBK_Obligatoriedad__c = false;
        registrRTOpcional.CBK_Activo__c = true;
        lstCSAuditLog.add(registrRTOpcional);
        CBK_AuditLogSetting__c registroAsyncOpcional = new  CBK_AuditLogSetting__c();
        registroAsyncOpcional.Name = 'AsyncOp';
        registroAsyncOpcional.CBK_Tipo__c = 'AsyncOp';
        registroAsyncOpcional.CBK_RTAudit__c = false;
        registroAsyncOpcional.CBK_Obligatoriedad__c = false;
        registroAsyncOpcional.CBK_Activo__c = true;
        lstCSAuditLog.add(registroAsyncOpcional);
        CBK_AuditLogSetting__c registroInactivo = new  CBK_AuditLogSetting__c();
        registroInactivo.Name = 'Inactivo';
        registroInactivo.CBK_Tipo__c = 'Inactivo';
        registroInactivo.CBK_RTAudit__c = true;
        registroInactivo.CBK_Obligatoriedad__c = true;
        registroInactivo.CBK_Activo__c = false;
        lstCSAuditLog.add(registroInactivo);
        insert lstCSAuditLog;
    }
    
    /**
    * @description Método de test de la factoria en el escenario de registro síncrono obligatorio
    * @author   fzaragoza | 21/04/2021 
    **/
    @IsTest static void creaRTObligatorio() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'RTOb';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 3];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaInterface retorno = CBK_RegistroAuditoriaFactory.instanciaAuditoriaLogger(datosAudit,usuarioAuditoria);
        System.assert(retorno instanceof CBK_RegistroAuditoriaRTObligatorio,'Los tipos de clase devueltos por el factory no coinciden con lo esperado.');
    }

    /**
    * @description Método de test de la factoria en el escenario de registro síncrono opcional
    * @author   fzaragoza | 21/04/2021 
    **/
    @IsTest static void creaRTOpcional() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'RTOp';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 3];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaInterface retorno = CBK_RegistroAuditoriaFactory.instanciaAuditoriaLogger(datosAudit,usuarioAuditoria);
        System.assert(retorno instanceof CBK_RegistroAuditoriaRTOpcional,'Los tipos de clase devueltos por el factory no coinciden con lo esperado.');

    }
    
    /**
    * @description Método de test de la factoria en el escenario de registro asíncrono opcional
    * @author   fzaragoza | 22/04/2021 
    **/
    @IsTest static void creaAsyncOpcional() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'AsyncOp';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 3];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaInterface retorno = CBK_RegistroAuditoriaFactory.instanciaAuditoriaLogger(datosAudit,usuarioAuditoria);
        System.assert(retorno instanceof CBK_RegistroAuditoriaAsyncOpcional,'Los tipos de clase devueltos por el factory no coinciden con lo esperado.');

    }

    /**
    * @description Método de test de la factoria en el escenario de configuración indicando que el registro está inactivo
    * @author   fzaragoza | 22/04/2021 
    **/
    @IsTest static void inactivo() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'Inactivo';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 3];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaInterface retorno = CBK_RegistroAuditoriaFactory.instanciaAuditoriaLogger(datosAudit,usuarioAuditoria);
        System.assertEquals(null, retorno,'Los tipos de clase devueltos por el factory no coinciden con lo esperado.');

    }

    /**
    * @description Método de test de la factoria en el escenario de configuración del tipo de función auditaada no exista en la configuración
    * @author   fzaragoza | 22/04/2021 
    **/
    @IsTest static void configuracionInexistente() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'NO_EXISTO!!';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 3];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaInterface retorno = CBK_RegistroAuditoriaFactory.instanciaAuditoriaLogger(datosAudit,usuarioAuditoria);
        System.assertEquals(null, retorno,'Los tipos de clase devueltos por el factory no coinciden con lo esperado.');


    }

}