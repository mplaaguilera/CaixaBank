/**********************************************************************************************************************
 Name:	  CBK_PurgeRecordsBatch_Test
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase test para la clase CBK_PurgeRecordsBatch del framework de purgado.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	30/11/2021			Init version
***********************************************************************************************************************/
@IsTest private with sharing class CBK_PurgeRecordsBatch_Test {
    
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
    * @description Método de test para validar la invocación del batch (proceso de purgado con RTs)
    * @author   fzaragoza | 30/11/2021
    **/
    @IsTest static void  testBatchwithRTs() {
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
        Datetime unAnio = Datetime.now().addDays(-365);
        for (Account acc : testAccts){
            Test.setCreatedDate(acc.Id, unAnio);
        }
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
        }
        
        CBK_PurgeProcess__c purgeProcess = [SELECT Id FROM CBK_PurgeProcess__c LIMIT 1];
        CBK_PurgeRecordsBatch batch = new CBK_PurgeRecordsBatch(purgeProcess.Id);
		Database.executeBatch(batch);
        
    }

    /**
    * @description Método de test para validar la invocación del batch (proceso de purgado con intervalos)
    * @author   fzaragoza | 30/11/2021
    **/
    @IsTest static void  testBatchDateRange() {
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
        Datetime unAnio = Datetime.now().addDays(-365);
        for (Account acc : testAccts){
            Test.setCreatedDate(acc.Id, unAnio);
        }
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        System.runAs (usr) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_RTsDevNames__c = 'CC_Cliente,CC_CentroCaixaBank';
            procesoPurgado.CBK_diasAntiguedadMaxima__c = 600;
            procesoPurgado.CBK_diasAntiguedadMinima__c = 365;
            procesoPurgado.CBK_condicionClausula__c = null;
            procesoPurgado.CBK_usoFechaSysModTimestamp__c = false;
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
            procesoPurgado.CBK_DeleteDetails__c = true;
            insert procesoPurgado;
        }
        Test.StartTest();
        CBK_PurgeProcess__c purgeProcess = [SELECT Id FROM CBK_PurgeProcess__c LIMIT 1];
        CBK_PurgeRecordsBatch batch = new CBK_PurgeRecordsBatch(purgeProcess.Id);
		Database.executeBatch(batch);
        Test.stopTest();
    }
    
    /**
    * @description Método de test para validar la invocación del batch (proceso de purgado con limite de registros)
    * @author   fzaragoza | 30/11/2021
    **/
    @IsTest static void  testBatchLimit() {
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
        Datetime unAnio = Datetime.now().addDays(-365);
        for (Account acc : testAccts){
            Test.setCreatedDate(acc.Id, unAnio);
        }
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        System.runAs (usr) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_RTsDevNames__c = 'CC_Cliente,CC_CentroCaixaBank';
            procesoPurgado.CBK_diasAntiguedadMaxima__c = null;
            procesoPurgado.CBK_diasAntiguedadMinima__c = 100;
            procesoPurgado.CBK_condicionClausula__c = 'CC_Confidencial__c = false';
            procesoPurgado.CBK_usoFechaSysModTimestamp__c = false;
            procesoPurgado.CBK_limitValue__c = 10000;
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
        Test.StartTest();
        CBK_PurgeProcess__c purgeProcess = [SELECT Id FROM CBK_PurgeProcess__c LIMIT 1];
        CBK_PurgeRecordsBatch batch = new CBK_PurgeRecordsBatch(purgeProcess.Id);
		Database.executeBatch(batch);
        Test.stopTest();
        List<Account> lstAccounts = new List<Account>();
        lstAccounts = [SELECT id,name,createddate FROM Account];
        system.AssertEquals(lstAccounts.size(),0,'No coincide el número de resultados recuperados con el valor esperado.');
        lstAccounts = [SELECT id,name,createddate FROM Account WHERE isDeleted=true ALL ROWS];
        system.AssertEquals(lstAccounts.size(),2,'No coincide el número de resultados recuperados con el valor esperado.');
    }

    /**
    * @description Método de test para validar la invocación del batch (proceso de purgado con limite de registros)
    * @author   fzaragoza | 30/11/2021
    **/
    @IsTest static void  testBatchRecycleBin() {
        List<Account> testAccts = new List<Account>();
        for(Integer i=0;i<2;i++) {
            Account acc = new Account();
            acc.Name = 'Prueba Test ' + i;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            testAccts.add(acc);
        }
        insert testAccts;
        Datetime unAnio = Datetime.now().addDays(-365);
        for (Account acc : testAccts){
            Test.setCreatedDate(acc.Id, unAnio);
        }
        User usr = [SELECT id FROM User WHERE LastName = 'LastNameTest' LIMIT 1];
        System.runAs (usr) {
            CBK_PurgeProcess__c procesoPurgado = new CBK_PurgeProcess__c();
            procesoPurgado.CBK_objetoPurgado__c = 'Account';
            procesoPurgado.CBK_RTsDevNames__c = 'CC_Cliente,CC_CentroCaixaBank';
            procesoPurgado.CBK_diasAntiguedadMaxima__c = null;
            procesoPurgado.CBK_diasAntiguedadMinima__c = 100;
            procesoPurgado.CBK_condicionClausula__c = 'CC_Confidencial__c = false';
            procesoPurgado.CBK_usoFechaSysModTimestamp__c = false;
            procesoPurgado.CBK_limitValue__c = 10000;
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
            procesoPurgado.CBK_HardDelete__c = true;
            insert procesoPurgado;
        }
        Test.StartTest();
        CBK_PurgeProcess__c purgeProcess = [SELECT Id FROM CBK_PurgeProcess__c LIMIT 1];
        CBK_PurgeRecordsBatch batch = new CBK_PurgeRecordsBatch(purgeProcess.Id);
		Database.executeBatch(batch);
        Test.stopTest();
        List<Account> lstAccounts = new List<Account>();
        lstAccounts = [SELECT id,name,createddate FROM Account];
        system.AssertEquals(lstAccounts.size(),0,'No coincide el número de resultados recuperados con el valor esperado.');
        List<Account> lstAccounts2 = [SELECT id FROM Account WHERE isDeleted=true ALL ROWS];
        //aunque se han eliminado de la papelera, al lanzar la consulta isdeleted=true con ALL ROWS devuelve los registros eliminados de la papelera de reciclaje
        system.AssertEquals(lstAccounts2.size(),2,'No coincide el número de resultados recuperados con el valor esperado.');
    }


    /**
    * @description Método de test para validar la invocación del batch (proceso de purgado con RTs)
    * @author   fzaragoza | 30/11/2021
    **/
    @IsTest static void  testBatchConstructor() {  
        CBK_PurgeRecordsBatch batch2 = new CBK_PurgeRecordsBatch();
        system.AssertNotEquals(batch2,null,'No coincide el valor esperado con el valor recuperado.');
    }
    public class TestException extends Exception {
    }
    @IsTest static void createLogTest() {  
        List<Object> det = new List<Object>();
        try{
            det.add('detalle error1');
            det.add('detalle error2');
            CBK_PurgeRecordsBatch tt =  new CBK_PurgeRecordsBatch();
            tt.createLog('ERROR', det, null);
            throw new TestException('Exception Test Error');
        }catch(Exception ex){
            CBK_PurgeRecordsBatch tt =  new CBK_PurgeRecordsBatch();
            tt.createLog('ERROR', det, ex);
        }
    }
}