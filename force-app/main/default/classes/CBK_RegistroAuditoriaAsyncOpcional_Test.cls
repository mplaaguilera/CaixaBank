/**********************************************************************************************************************
 Name:	  CBK_RegistroAuditoriaAsyncOpcional_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_RegistroAuditoriaAsyncOpcional del framework de registro de auditoría.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	22/04/2020			Init version
***********************************************************************************************************************/
@IsTest private class CBK_RegistroAuditoriaAsyncOpcional_Test {
   
    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 22/04/2021 
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
    * @author   fzaragoza | 22/04/2021 
    **/
    @IsTest static void registroOK() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'ConsultaSaldo';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 3];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaAsyncOpcional logger = new CBK_RegistroAuditoriaAsyncOpcional(datosAudit,usuarioAuditoria);
        Test.startTest();
        logger.registroAuditoria();
        Test.stopTest();
        list <CBK_AuditLog__c> registros = [SELECT Id  FROM CBK_AuditLog__c];
        System.assertEquals(3, registros.size(),'No coincide el número de registros esperados');
    }

    /**
    * @description Método de test para validar el escenario de inserción correcta para SObjects sin campo Name y con campo Subject
    * @author   fzaragoza | 22/04/2021 
    **/
    @IsTest static void registroOKSubject() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'ConsultaSaldo';
        datosAudit.operacion= 'R';
        datosAudit.registrosAuditados = [SELECT Id, subject FROM Case LIMIT 1];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaAsyncOpcional logger = new CBK_RegistroAuditoriaAsyncOpcional(datosAudit,usuarioAuditoria);
        Test.startTest();
        logger.registroAuditoria();
        Test.stopTest();
        list <CBK_AuditLog__c> registros = [SELECT Id  FROM CBK_AuditLog__c];
        System.assertEquals(1, registros.size(),'No coincide el número de registros esperados');
    }

    /**
    * @description Método de test para validar el escenario de inserción incorrecta 
    * @author   fzaragoza | 22/04/2021 
    **/
    @IsTest static void registroKO() {
        CBK_RegistroAuditoriaEntry datosAudit = new CBK_RegistroAuditoriaEntry();
        datosAudit.aplicacion= 'AV_CRM_Intouch';
        datosAudit.tipo= 'ConsultaSaldo';
        datosAudit.operacion= 'Z';
        datosAudit.registrosAuditados = [SELECT Id, Name FROM Account LIMIT 3];
        User usuarioAuditoria = [SELECT Id,Name,Email,EmployeeNumber FROM User WHERE id =:userinfo.getUserId() LIMIT 1];
        CBK_RegistroAuditoriaAsyncOpcional logger = new CBK_RegistroAuditoriaAsyncOpcional(datosAudit,usuarioAuditoria);
        Test.startTest();
        logger.registroAuditoria();
        Test.stopTest();
        list <CBK_AuditLog__c> registros = [SELECT Id  FROM CBK_AuditLog__c];
        System.assertEquals(0, registros.size(),'No coincide el número de registros esperados');
    }

    /**
    * @description Método de test para validar en CBK_TriggerFactory la creación del dispatcher revisando nombre de un objeto custom
    * @author   fzaragoza | 22/04/2021 
    **/
    @IsTest static void registroExtra() {
        CC_Canal_Com__c objCustom = new CC_Canal_Com__c();
        Opportunity objCustom2 = new Opportunity();
        try{
            CC_TriggerFactory.createTriggerDispatcher(objCustom.getSObjectType());
            CC_TriggerFactory.createTriggerDispatcher(objCustom.getSObjectType(),'CC_Canal_Com_TRDisp');
        }
        catch(Exception e){
            System.assert(false,'No debería generar excepción');

        }
        try{
            CC_TriggerFactory.createTriggerDispatcher(objCustom.getSObjectType(),'CC_Canal_Com_TRDisp_NoExiste');
        }
        catch(Exception e){
            System.assert(true,'Debería generar excepción');

        }
        
        try{
            CC_TriggerFactory.createTriggerDispatcher(objCustom2.getSObjectType(),'CC_Opportunity_TRDisp_NoExiste');
        }
        catch(Exception e){
            System.assert(true,'Debería generar excepción');
        }

    }

}