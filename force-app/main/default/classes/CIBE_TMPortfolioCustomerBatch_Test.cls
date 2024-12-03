/**********************************************************************************************************************
Name:      CIBE_PortfolioEmployeeBatch_Test
Copyright © 2023 CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test de CIBE_PortfolioEmployee_Batch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY       AUTHOR           DATE                Description
    1.0            Create Batch	    Alex Perez       09/05/2023          Init version
***********************************************************************************************************************/
@istest
public with sharing class CIBE_TMPortfolioCustomerBatch_Test {
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
        AV_Book__c bk = CIBE_TestHelper.createPurse('12345');
        CIBE_TestHelper.createBookManagement(empleado, bk);
        CIBE_TestHelper.createBookMember(acc, bk);
        User usuario = CIBE_TestHelper.createUser('CIBE_Gestor', 'U46410');
   }

   @istest
   static void bookManagTest(){
        User cIBUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics'});
        }
        Contact con = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE CC_Matricula__c = 'U46410' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
        AV_bookManagementMember__c bookMan = [SELECT Id, AV_Cartera__c FROM AV_bookManagementMember__c WHERE AV_EmpleadoGestor__c = : con.Id LIMIT 1];
        list<string> conList = new list<string>{con.id + '|' + bookMan.AV_Cartera__c};
        test.startTest();
        //realmente esto lo va a acabar ejecutando un sysadmin
        System.runAs(cIBUser){
            CIBE_TMPortfolioCustomer_Batch bTest = new CIBE_TMPortfolioCustomer_Batch(conList);
            Database.executeBatch(bTest);
        }
        test.stopTest();
        system.assertEquals([SELECT ID FROM AccountTeamMember WHERE userid = : con.AV_UsuarioAsociado__c AND AccountId = : acc.Id].size(), 1);
   }

   @istest
   static void bookManagDeleteTest(){
        User cIBUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            cIBUser = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIBE_CIBEmpresas', '', new List<String>{'CIBE_OperativaCIB', 'CIBE_CustomMetadata', 'CIBE_Analytics'});
        }
        Contact con = [SELECT Id, AV_UsuarioAsociado__c FROM Contact WHERE CC_Matricula__c = 'U46410' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
        AV_bookManagementMember__c bookMan = [SELECT Id, AV_Cartera__c FROM AV_bookManagementMember__c WHERE AV_EmpleadoGestor__c = : con.Id LIMIT 1];
        list<string> conList = new list<string>{con.id + '|' + bookMan.AV_Cartera__c};
        test.startTest();
        //realmente esto lo va a acabar ejecutando un sysadmin
        System.runAs(cIBUser){
            CIBE_TMPortfolioCustomer_Batch bTest = new CIBE_TMPortfolioCustomer_Batch(conList);
            Database.executeBatch(bTest);
        }
        test.stopTest();
        system.assertEquals([SELECT ID FROM AccountTeamMember WHERE userid = : con.AV_UsuarioAsociado__c AND AccountId = : acc.Id].size(), 1);
   }
   
}