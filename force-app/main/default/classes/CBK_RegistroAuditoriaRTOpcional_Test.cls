/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoriaRTOpcional_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_RegistroAuditoriaRTOpcional del framework de registro de auditoría.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	21/04/2021			Init version
***********************************************************************************************************************/
@IsTest private class CBK_RegistroAuditoriaRTOpcional_Test {
   
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
        
        Case casoTest = new Case();
        casoTest.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        casoTest.Status = 'Activo';
        casoTest.CC_Idioma__c = 'ca';
        casoTest.CC_CanalNotifCli__c = 'SMS';
        casoTest.CC_NotIncidencia__c = '1';
        insert casoTest;

    }

    /**
    * @description Método de test para validar el escenario de inserción correcta
    * @author   fzaragoza | 21/04/2021 
    **/
    @IsTest static void registroOK() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'ConsultaSaldo';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 2];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaRTOpcional logger = new CBK_RegistroAuditoriaRTOpcional(datosAudit,usuarioAuditoria);
        logger.registroAuditoria();
        list <CBK_AuditLog__c> registros = [SELECT Id  FROM CBK_AuditLog__c];
        System.assertEquals(2, registros.size(),'No coincide el número de registros esperados');
    }

    /**
    * @description Método de test para validar el escenario de inserción correcta para SObjects sin campo Name y con campo Subject
    * @author   fzaragoza | 21/04/2021 
    **/
    @IsTest static void registroOKSubject() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'ConsultaSaldo';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, subject FROM Case LIMIT 1];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaRTOpcional logger = new CBK_RegistroAuditoriaRTOpcional(datosAudit,usuarioAuditoria);
        logger.registroAuditoria();
        list <CBK_AuditLog__c> registros = [SELECT Id  FROM CBK_AuditLog__c];
        System.assertEquals(1, registros.size(),'No coincide el número de registros esperados');
    }

    /**
    * @description Método de test para validar el escenario de inserción incorrecta 
    * @author   fzaragoza | 21/04/2021 
    **/
    @IsTest static void registroKO() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'ConsultaSaldo';
        datosAudit.operacion= 'Z';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 3];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaRTOpcional logger = new CBK_RegistroAuditoriaRTOpcional(datosAudit,usuarioAuditoria);
        logger.registroAuditoria();
        list <CBK_AuditLog__c> registros = [SELECT Id  FROM CBK_AuditLog__c];
        System.assertEquals(0, registros.size(),'No coincide el número de registros esperados');
    }
}