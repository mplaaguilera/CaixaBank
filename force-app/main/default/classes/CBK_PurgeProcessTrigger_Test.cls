/**********************************************************************************************************************
 Name:	  CBK_PurgeProcessTrigger_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para el trigger CBK_PurgeProcessTrigger y las clases apx de dsipatcher y handlers asociados del framework de purgado.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	30/11/2021			Init version
***********************************************************************************************************************/
@IsTest private with sharing class CBK_PurgeProcessTrigger_Test {

    /**
    * @description Método de setup de datos para los test 
    * @author   fzaragoza | 30/11/2021 
    **/
    @testSetup
    static void setup()
    {
        User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            LastName = 'LastNameTest',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        insert user;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CBK_PurgeProcessAdmin'];
        insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = ps.Id);

    }

    /**
    * @description Método de test para validar la creación y activación de una planificación
    * @author   fzaragoza | 30/11/2021 
    **/
    @IsTest 
    static void  testAfterInsert() {
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.startTest();
        System.runAs (usr ) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_RTsDevNames__c = 'CC_Cliente,CC_CentroCaixaBank';
            procesoPurgado.CBK_diasAntiguedadMaxima__c = null;
            procesoPurgado.CBK_diasAntiguedadMinima__c = 365;
            procesoPurgado.CBK_condicionClausula__c = null;
            procesoPurgado.CBK_usoFechaSysModTimestamp__c = true;
            procesoPurgado.CBK_limitValue__c = null;
            procesoPurgado.CBK_LastExec_Sched__c = null;
            procesoPurgado.CBK_Activo__c = true;
            procesoPurgado.CBK_BatchSize__c = 200;
            procesoPurgado.CBK_Notif__c  = false;
            procesoPurgado.CBK_Email_Notif__c = null;
            procesoPurgado.CBK_Estado__c = 'Autorizado';
            procesoPurgado.CBK_Lunes__c = true;
            procesoPurgado.CBK_Martes__c = true;
            procesoPurgado.CBK_Miercoles__c = true;
            procesoPurgado.CBK_Jueves__c = true;
            procesoPurgado.CBK_Viernes__c = true;
            procesoPurgado.CBK_Sabado__c = true;
            procesoPurgado.CBK_Domingo__c  = true;
            procesoPurgado.CBK_Periodicidad__c = 7;
            insert procesoPurgado;
        }
        list<CBK_Framework_Batch__c> lstPlanificacionesActivas = new list<CBK_Framework_Batch__c> ();
        lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
        system.AssertEquals(lstPlanificacionesActivas.size(),1,'No coincide el número de resultados esperados con el valor recuperado.');
        Test.stopTest();
    }

    /**
    * @description Método de test para validar la creación y modificación de una planificación
    * @author   fzaragoza | 30/11/2021 
    **/
    @IsTest 
    static void  testAfterUpdate() {
        list<CBK_Framework_Batch__c> lstPlanificacionesActivas = new list<CBK_Framework_Batch__c> ();
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.startTest();
        System.runAs (usr ) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_RTsDevNames__c = 'CC_Cliente,CC_CentroCaixaBank';
            procesoPurgado.CBK_diasAntiguedadMaxima__c = null;
            procesoPurgado.CBK_diasAntiguedadMinima__c = 365;
            procesoPurgado.CBK_condicionClausula__c = null;
            procesoPurgado.CBK_usoFechaSysModTimestamp__c = true;
            procesoPurgado.CBK_limitValue__c = null;
            procesoPurgado.CBK_LastExec_Sched__c = null;
            procesoPurgado.CBK_Activo__c = true;
            procesoPurgado.CBK_BatchSize__c = 200;
            procesoPurgado.CBK_Notif__c  = false;
            procesoPurgado.CBK_Email_Notif__c = null;
            procesoPurgado.CBK_Estado__c = 'Autorizado';
            procesoPurgado.CBK_Lunes__c = true;
            procesoPurgado.CBK_Martes__c = true;
            procesoPurgado.CBK_Miercoles__c = true;
            procesoPurgado.CBK_Jueves__c = true;
            procesoPurgado.CBK_Viernes__c = true;
            procesoPurgado.CBK_Sabado__c = true;
            procesoPurgado.CBK_Domingo__c  = true;
            procesoPurgado.CBK_Periodicidad__c = 7;
            insert procesoPurgado;
            lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            system.AssertEquals(lstPlanificacionesActivas.size(),1,'No coincide el número de resultados esperados con el valor recuperado.');
            procesoPurgado.CBK_BatchSize__c = 1000;
            update procesoPurgado;
            lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            system.AssertEquals(lstPlanificacionesActivas.size(),1,'No coincide el número de resultados esperados con el valor recuperado.');
            procesoPurgado.CBK_Activo__c = false;
            update procesoPurgado;
            lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            system.AssertEquals(lstPlanificacionesActivas.size(),0,'No coincide el número de resultados esperados con el valor recuperado.');
            procesoPurgado.CBK_Activo__c = true;
            update procesoPurgado;
            lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            system.AssertEquals(lstPlanificacionesActivas.size(),1,'No coincide el número de resultados esperados con el valor recuperado.');
        }
        Test.stopTest();
    }

    /**
    * @description Método de test para validar la creación y eliminación de una planificación
    * @author   fzaragoza | 30/11/2021 
    **/
    @IsTest 
    static void  testBeforeDelete() {
        list<CBK_Framework_Batch__c> lstPlanificacionesActivas = new list<CBK_Framework_Batch__c> ();
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.startTest();
        System.runAs (usr) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_RTsDevNames__c = 'CC_Cliente,CC_CentroCaixaBank';
            procesoPurgado.CBK_diasAntiguedadMaxima__c = null;
            procesoPurgado.CBK_diasAntiguedadMinima__c = 365;
            procesoPurgado.CBK_condicionClausula__c = null;
            procesoPurgado.CBK_usoFechaSysModTimestamp__c = true;
            procesoPurgado.CBK_limitValue__c = null;
            procesoPurgado.CBK_LastExec_Sched__c = null;
            procesoPurgado.CBK_Activo__c = true;
            procesoPurgado.CBK_BatchSize__c = 200;
            procesoPurgado.CBK_Notif__c  = false;
            procesoPurgado.CBK_Email_Notif__c = null;
            procesoPurgado.CBK_Estado__c = 'Autorizado';
            procesoPurgado.CBK_Lunes__c = true;
            procesoPurgado.CBK_Martes__c = true;
            procesoPurgado.CBK_Miercoles__c = true;
            procesoPurgado.CBK_Jueves__c = true;
            procesoPurgado.CBK_Viernes__c = true;
            procesoPurgado.CBK_Sabado__c = true;
            procesoPurgado.CBK_Domingo__c  = true;
            procesoPurgado.CBK_Periodicidad__c = 7;
            insert procesoPurgado;
            lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            system.AssertEquals(lstPlanificacionesActivas.size(),1,'No coincide el número de resultados esperados con el valor recuperado.');       
            delete procesoPurgado;
            lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            system.AssertEquals(lstPlanificacionesActivas.size(),0,'No coincide el número de resultados esperados con el valor recuperado.');
        }
        Test.stopTest();
    }

}