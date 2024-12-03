/**********************************************************************************************************************
Name:      CIBE_PortfolioEmployeeBatch_Test
Copyright © 2023 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test de CIBE_PortfolioEmployee_Batch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0            Create Batch	    Alex Perez       08/05/2023          Init version
***********************************************************************************************************************/
@istest
public with sharing class CIBE_PortfolioEmployeeBatch_Test {
   @TestSetup
   static void makeData(){
        Contact empleado  = new Contact();
        empleado.LastName = 'Paco';
        empleado.FirstName = 'Pelaes';
        empleado.Email = 'pacoPelaes@emailcaixa.com';
        empleado.CC_Idioma__c = 'es';
        empleado.RecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByDeveloperName.get('CC_Empleado').getRecordTypeId(); 
        empleado.CC_Matricula__c = 'U46410';
        empleado.AV_UsuarioAsociado__c = null;
        empleado.AV_DescFuncion__c = 'EMPLEADO';
        insert empleado;
        account acc = new Account(Name = 'Test Account 1',
        AV_NumPerso__c = '123',
        AV_Negocio__c = 'CIB',
        RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('CC_Cliente').getRecordTypeId());
        insert acc;
        AV_Book__c book  = new AV_Book__c();
        book.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA, CIBE_AppConstants.CARTERA).Id;
        book.AV_ExternalID__c = '12345';
        book.AV_Activa__c = 'S';
        book.AV_Negocio__c = 'CIB';
        insert book;
        AV_BookManagementMember__c bookMemb  = new AV_BookManagementMember__c();
        bookMemb.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA_GESTOR, CIBE_AppConstants.CARTERA_GESTOR).Id;
        bookMemb.AV_EmpleadoGestor__c = empleado.Id;
        bookMemb.AV_Cartera__c = book.Id;
        insert bookMemb;
        AV_BookMember__c bookm  = new AV_BookMember__c();
        bookm.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA_CLIENTE, CIBE_AppConstants.CARTERA_CLIENTE).Id;
		bookm.AV_Cliente__c = acc.Id;
		bookm.AV_Cartera__c = book.Id;
		bookm.AV_CarteraPrincipal__c = true;
		insert bookm;
        User usuario = CIBE_TestHelper.createUser('CIBE_Gestor', 'U46410');
   }

   @istest
   static void bookManagTest(){
        User cIBUser;
        CIBE_OppAccActivitiesController.ActivitiesWrapper wrapper;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics'});
        }
        Contact con = [SELECT Id FROM Contact WHERE CC_Matricula__c = 'U46410' LIMIT 1];
        list<Id> conList = new list<Id>{con.id};
        test.startTest();
        //realmente esto lo va a acabar ejecutando un sysadmin
        System.runAs(cIBUser){
            CIBE_PortfolioEmployee_Batch bTest = new CIBE_PortfolioEmployee_Batch(conList);
            Database.executeBatch(bTest);
        }
        test.stopTest();
        system.assertEquals([SELECT ID FROM CBK_Framework_Batch__c WHERE Class_Name__c = 'CIBE_TMPortfolioCustomer_Batch'].size(), 1);
   }
   
}