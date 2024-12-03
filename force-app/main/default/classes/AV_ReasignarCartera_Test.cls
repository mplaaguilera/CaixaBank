/**********************************************************************************************************************
Name:	  AV_ReasignarCartera_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_ReasignarCartera"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Eric Vázquez	   	   21/10/2020		Init version
2.0         Hotfix         Eric Vázquez        26/01/2021       fix the call API to purse
2.1			AV_Query IT	   Daniel Rodríguez	   3/02/2022		Change AV_Query to SOQL for User, Account, Contact
2.2         US592987	   Ángel Medina		   31/05/2023		Changed AV_Query to SOQL queries
2.3 		US649249	   Óscar Moreno	  	    27/11/2023		Include system.asserts in all methods
***********************************************************************************************************************/
@isTest
public with sharing class AV_ReasignarCartera_Test {
    
    //mio
    @TestSetup
    static void setup(){
        User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1]; 
        System.runAs(usuario) {
           User usrTest = AV_TestHelper.createUser(null);
           Account cenTest = AV_TestHelper.createCaixaCenter();
           Account accTest = AV_TestHelper.createCustomer();
           Contact conTest = AV_TestHelper.createEmployee(cenTest, usrTest);
        }
    }

    @isTest
    private static void reassignPurseTest() {
        User us1=[SELECT ID FROM User WHERE Alias = 'AV-TF9'];
        
        User usrTest = [SELECT id from User where Email = 'test@test.dev'];
        Account cenTest = [SELECT id,Name FROM ACCOUNT WHERE CC_Numero_Oficina__c = '00615' LIMIT 1]; 
        Account accTest = [SELECT id,Name FROM ACCOUNT WHERE CC_Numero_Documento__c = '9446386T' LIMIT 1]; 
        Contact conTest = [SELECT id,Name FROM CONTACT WHERE FirstName = 'Empleado']; 
        String externalId = '50071';
        AV_Book__c purseTest = AV_TestHelper.createPurse(externalId);
        purseTest.Name='12345';
        update purseTest;
        AV_BookManagementMember__c bookAssigmentTest = AV_TestHelper.createBookManagement(conTest, purseTest);
        // List<User> listUsers = [Select Id, Name From User limit 1];
        // List<Account> listAccounts= [Select Id, AV_NumPerso__c , Name From Account WHERE CC_Numero_Documento__c = '9446386T' limit 1];
        // List<Contact> listContacts= [Select Id, Name From Contact limit 1];
        List<User> listUsers = new List<User>{usrTest};
        List<Account> listAccounts= new List<Account>{accTest};
        List<Contact> listContacts= new List<Contact>{conTest};

        Set<String> setFieldsBook = new Set<String>{'Id', 'Name'};
        List<AV_Book__c> listBooks = [SELECT Id, Name FROM AV_Book__c LIMIT 1];


        Set<String> setFieldsBkManage = new Set<String>{'Id', 'Name'};
        List<AV_BookManagementMember__c> listBkManagements = [SELECT Id, Name FROM AV_BookManagementMember__c LIMIT 1];

        List<List<String>> listWords = new List<List<String>>();
        List<List<String>> listWordsFail = new List<List<String>>();
        String accId = listAccounts[0].Id;
        String usrId = listUsers[0].Id;
        
        listWords.add(new List<String>{accId, usrId, listBooks[0].Id});
        listWordsFail.add(new List<String>{cenTest.id,usrTest.id,listBooks[0].Id});
        CBK_Activity_Extension__c cbk = new CBK_Activity_Extension__c(
            AV_ReasignarCartera_Id_Cliente__c = accId
        );
        insert cbk;
        System.runAs(us1){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_CAMBIARGESTOR','OK'));
            AV_ReasignarCartera.reassignPurse(listWords);
            Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CHANNELS','KO'));
            AV_ReasignarCartera.reassignPurse(listWordsFail);
            Database.delete(cbk);
            AV_ReasignarCartera.reassignPurse(listWords);

            System.assertNotEquals( AV_ReasignarCartera.reassignPurse(listWords),null); //
            Test.stopTest();
        }
    }

    @isTest
    public static void TestValidateTaskOnboardingPositiveClosed() {
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_CAMBIARGESTOR','OK'));
        User us1=[SELECT ID FROM User WHERE Alias = 'AV-TF9'];
        Account cenTest = [SELECT id FROM ACCOUNT WHERE CC_Numero_Oficina__c = '00615' LIMIT 1]; 
        Account customer = [SELECT id FROM ACCOUNT WHERE CC_Numero_Documento__c = '9446386T' LIMIT 1]; 
		String labelProfile = 'AV_Usuario_CaixaBank';
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
		String username = AV_TestHelper.getEmail();
		Profile p = (Profile)result.get(0);
        User usuario = [SELECT id from User where Email = 'test@test.dev']; 
        Contact empleado = [SELECT id FROM CONTACT WHERE FirstName = 'Empleado'];         
        Test.startTest();

        AV_Book__c cartera= new AV_Book__c();
        cartera.Name='12345678';
        cartera.AV_Activa__c = 'S';
        insert cartera;

        AV_BookManagementMember__c carteraGestor = new AV_BookManagementMember__c();
        carteraGestor.AV_EmpleadoGestor__c = empleado.Id;
        carteraGestor.AV_Cartera__c = cartera.Id;
        insert carteraGestor;
        


       System.runAs(us1){
            RecordType rt = AV_AppUtilities.getRecordType('Task', 'AV_Onboarding');
            Task tarea  = new Task();
            tarea.Subject = 'Llamada Saliente';
            tarea.OwnerId = usuario.Id;
            tarea.WhatId = customer.Id;		
            tarea.Status = 'Gestionada positiva';
            tarea.Priority = 'Normal';
            tarea.AV_ExternalID__c = 'U0009006';
            tarea.RecordTypeId = rt.Id;
            insert tarea;
            System.assert( tarea != null, 'El registro no se insertó correctamente'); //
        }
        Test.stopTest();
    }

    

    @isTest
    private static void getPurseFromContactTest() {
        User us1=[SELECT ID FROM User WHERE Alias = 'AV-TF9'];
        
        User usrTest = [SELECT id from User where Email = 'test@test.dev'];
        Account cenTest = [SELECT id FROM ACCOUNT WHERE CC_Numero_Oficina__c = '00615' LIMIT 1]; 
        Account accTest = [SELECT id FROM ACCOUNT WHERE CC_Numero_Documento__c = '9446386T' LIMIT 1]; 
        Contact conTest = [SELECT id FROM CONTACT WHERE FirstName = 'Empleado']; 
        
        String externalId = '50071';
        AV_Book__c purseTest = AV_TestHelper.createPurse(externalId);
        AV_BookManagementMember__c bookAssigmentTest = AV_TestHelper.createBookManagement(conTest, purseTest);
        List<User> listUsers = [Select Id, Name From User limit 1];
        List<Account> listAccounts= [Select Id, Name From Account limit 1];

        List<Contact> listContacts= [Select Id, Name From Contact limit 1];

        Set<String> setFieldsBook = new Set<String>{'Id', 'Name'};
        List<AV_Book__c> listBooks = [SELECT Id, Name FROM AV_Book__c LIMIT 1]; 
        
        Set<String> setFieldsBkManage = new Set<String>{'Id', 'Name'};
        List<AV_BookManagementMember__c> listBkManagements = [SELECT Id, Name FROM AV_BookManagementMember__c LIMIT 1];

        Test.startTest();
        System.runAs(us1){
        AV_ReasignarCartera.getPurseFromContact(listContacts[0].Id);
        System.assertNotEquals( AV_ReasignarCartera.getPurseFromContact(listContacts[0].Id),null); //
        Test.stopTest();
        }
    }

    @isTest
    private static void controlVisibilityTaskTest() {
        User us1=[SELECT ID FROM User WHERE Alias = 'AV-TF9'];
        
        Account customer = [SELECT id FROM ACCOUNT WHERE CC_Numero_Documento__c = '9446386T' LIMIT 1]; 
		String labelProfile = 'AV_Usuario_CaixaBank';
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
		String username = AV_TestHelper.getEmail();
		Profile p = (Profile)result.get(0);
        User usuario = [SELECT id from User where Email = 'test@test.dev']; 
       
        RecordType rt = AV_AppUtilities.getRecordType('Task', 'AV_Onboarding');
        Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
        tarea.OwnerId = usuario.Id;
        tarea.WhatId = customer.Id;		
		tarea.Status = 'Gestionada positiva';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = 'U0009006';
        tarea.RecordTypeId = rt.Id;

        CBK_Activity_Extension__c crmTask = new CBK_Activity_Extension__c();
        crmTask.AV_ReasignarCartera_Id_Task__c = tarea.Id;
        crmTask.AV_StatusCodeAPI__c = '200';
        Database.insert(crmTask);

        Test.startTest();
        System.runAs(us1){
        AV_ReasignarCartera.controlVisibilityTask(tarea.Id);
        System.assertEquals( AV_ReasignarCartera.controlVisibilityTask(tarea.Id),false);
        Test.stopTest();
        }
    }

    @isTest
    private static void sendPurseFromTaskToAPITest() {
        User us1=[SELECT ID FROM User WHERE Alias = 'AV-TF9'];
        
        User usrTest = [SELECT id from User where Email = 'test@test.dev'];
        Account cenTest = [SELECT id FROM ACCOUNT WHERE CC_Numero_Oficina__c = '00615' LIMIT 1]; 
        String labelProfile = 'AV_Usuario_CaixaBank';
		List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + labelProfile + '\' LIMIT 1');
        String username = AV_TestHelper.getEmail();
		Profile p = (Profile)result.get(0);
        

        Account accTest = [SELECT id FROM ACCOUNT WHERE CC_Numero_Documento__c = '9446386T' LIMIT 1];
        Contact conTest = [SELECT id FROM CONTACT WHERE FirstName = 'Empleado']; 
        
        AV_Book__c cartera = new AV_Book__c();
        cartera.Name = '12345678';
        cartera.AV_Activa__c = 'S';
        Database.insert(cartera);
        AV_BookManagementMember__c bookMemb = new AV_BookManagementMember__c();
        bookMemb.AV_EmpleadoGestor__c = conTest.Id;
        bookMemb.AV_Cartera__c = cartera.Id;
        Database.insert(bookMemb);
        String usrId = usrTest.Id;
        String bookmId = bookMemb.Id;
        RecordType rt = AV_AppUtilities.getRecordType('Task', 'AV_Onboarding');
		Task tarea  = new Task();
		tarea.Subject = 'Llamada Saliente';
        tarea.OwnerId = usrTest.Id;
        tarea.WhatId = accTest.Id;		
		tarea.Status = 'Gestionada positiva';
		tarea.Priority = 'Normal';
		tarea.AV_ExternalID__c = 'U0009006';
        tarea.RecordTypeId = rt.Id;
        Database.insert(tarea);
        CBK_Activity_Extension__c crmTask = new CBK_Activity_Extension__c();
        crmTask.AV_ReasignarCartera_Id_Task__c = tarea.Id;
        crmTask.AV_StatusCodeAPI__c = '200';
        Database.insert(crmTask);
        Test.startTest();
        System.runAs(us1){
        
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_CAMBIARGESTOR','OK'));
        List<String> listWords = new List<String>{cartera.Id, tarea.Id};
        
        AV_ReasignarCartera.sendPurseFromTaskToAPI(listWords);
        System.assertNotEquals('OK', listWords[0]);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CHANNELS','KO'));
        AV_ReasignarCartera.sendPurseFromTaskToAPI(listWords);
        Test.stopTest();
        }
    }
    
    
}