/**********************************************************************************************************************
 Name:	  CBK_PurgeProcess_Utils_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_PurgeProcess_Utils del framework de purgado.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	30/11/2021			Init version
***********************************************************************************************************************/
@IsTest private with sharing class CBK_PurgeProcess_Utils_Test {
   
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
    * @description Método de test para añadir planificación
    * @author   fzaragoza | 30/11/2021 
    **/
    @IsTest 
    static void  testAltaPlanificacion() {
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.startTest();
        System.runAs (usr ) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_Project__c = generateProjectId();
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
    * @description Método de test para modificar planificación
    * @author   fzaragoza | 30/11/2021 
    **/
    @IsTest 
    static void  testModificacionPlanificacion() {
        list<CBK_Framework_Batch__c> lstPlanificacionesActivas = new list<CBK_Framework_Batch__c> ();
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.startTest();
        System.runAs (usr ) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_Project__c = generateProjectId();
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
        }
        Test.stopTest();
    }

    /**
    * @description Método de test para eliminar planificación
    * @author   fzaragoza | 30/11/2021 
    **/    
    @IsTest 
    static void  testBajaPlanificacion() {
        list<CBK_Framework_Batch__c> lstPlanificacionesActivas = new list<CBK_Framework_Batch__c> ();
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.startTest();
        System.runAs (usr ) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_Project__c = generateProjectId();
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
            procesoPurgado.CBK_Activo__c = false;
            update procesoPurgado;
            lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            system.AssertEquals(lstPlanificacionesActivas.size(),0,'No coincide el número de resultados esperados con el valor recuperado.');
        }
        Test.stopTest();
    }

    /**
    * @description Método de test para refrescar la planificación
    * @author   fzaragoza | 30/11/2021 
    **/
    @IsTest 
    static void  testRecalculoPlanificacion() {
        list<CBK_Framework_Batch__c> lstPlanificacionesActivas = new list<CBK_Framework_Batch__c> ();
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.startTest();
        System.runAs (usr ) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_Project__c = generateProjectId();
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
            lstPlanificacionesActivas = [SELECT id,NextExec__c FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            lstPlanificacionesActivas[0].NextExec__c = null;
            update lstPlanificacionesActivas;
            CBK_PurgeProcess_Utils.recalculoPlanificaciones();
            lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            system.AssertEquals(lstPlanificacionesActivas.size(),1,'No coincide el número de resultados esperados con el valor recuperado.');
        }
        Test.stopTest();
    }
    
    /**
    * @description Método de test para validar la gestión de las dependencias hacia las planificaciones
    * @author   fzaragoza | 30/11/2021 
    **/
    @IsTest 
    static void  testAltaDependencia() {
        list<CBK_Framework_Batch__c> lstPlanificacionesActivas = new list<CBK_Framework_Batch__c> ();
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        Test.startTest();
        System.runAs (usr) {
            String sProjectId = generateProjectId();
            
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_Project__c = sProjectId;
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
            CBK_PurgeProcess__c procesoPurgadoDependiente = new CBK_PurgeProcess__c();
            procesoPurgadoDependiente.CBK_objetoPurgado__c = 'Account';
            procesoPurgadoDependiente.CBK_Project__c = sProjectId;
            procesoPurgadoDependiente.CBK_RTsDevNames__c = 'CC_Cliente,CC_CentroCaixaBank';
            procesoPurgadoDependiente.CBK_diasAntiguedadMaxima__c = null;
            procesoPurgadoDependiente.CBK_diasAntiguedadMinima__c = 365;
            procesoPurgadoDependiente.CBK_condicionClausula__c = null;
            procesoPurgadoDependiente.CBK_usoFechaSysModTimestamp__c = true;
            procesoPurgadoDependiente.CBK_limitValue__c = null;
            procesoPurgadoDependiente.CBK_LastExec_Sched__c = null;
            procesoPurgadoDependiente.CBK_Activo__c = true;
            procesoPurgadoDependiente.CBK_BatchSize__c = 200;
            procesoPurgadoDependiente.CBK_Notif__c  = false;
            procesoPurgadoDependiente.CBK_Email_Notif__c = null;
            procesoPurgadoDependiente.CBK_Estado__c = 'Autorizado';
            procesoPurgadoDependiente.CBK_Lunes__c = true;
            procesoPurgadoDependiente.CBK_Martes__c = true;
            procesoPurgadoDependiente.CBK_Miercoles__c = true;
            procesoPurgadoDependiente.CBK_Jueves__c = true;
            procesoPurgadoDependiente.CBK_Viernes__c = true;
            procesoPurgadoDependiente.CBK_Sabado__c = true;
            procesoPurgadoDependiente.CBK_Domingo__c  = true;
            procesoPurgadoDependiente.CBK_Periodicidad__c = 7;
            procesoPurgadoDependiente.CBK_Priority__c = 2;
            procesoPurgadoDependiente.CBK_Dependencia__c = procesoPurgado.Id;
            insert procesoPurgadoDependiente;
            lstPlanificacionesActivas = [SELECT id FROM CBK_Framework_Batch__c WHERE Activo__c = true];
            system.AssertEquals(lstPlanificacionesActivas.size(),2,'No coincide el número de resultados esperados con el valor recuperado.');  
            CBK_Framework_Batch__c planifPadre = [SELECT id FROM CBK_Framework_Batch__c WHERE Dependencia__c = null LIMIT 1];
            CBK_Framework_Batch__c planifHija = [SELECT id,Dependencia__c FROM CBK_Framework_Batch__c WHERE Dependencia__c != null LIMIT 1];
            system.AssertEquals(planifPadre.Id,planifHija.Dependencia__c,'No coincide el número de resultados esperados con el valor recuperado.');  
       }
        Test.stopTest();
    }
    
    private static String generateProjectId(){
        copado__Project__c project = New copado__Project__c(Name='TestProyecto');
        insert project;
        return project.Id;
    }
}