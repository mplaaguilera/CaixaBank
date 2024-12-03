/**********************************************************************************************************************
Name:	  CIBE_gestorClient
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase test de la clase CIBE_GestorClient
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY       AUTHOR			DATE			Description
1.0			US561277         Lucía Muñoz    13/04/2023		Init Version
    
***********************************************************************************************************************/
@IsTest
public with sharing class CIBE_GestorClient_ControllerTest {

    @TestSetup
    static void testSetUp(){
        String rtAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        String rtAccountRelation = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
        String rtCont = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CIBE_ContactoComercial').getRecordTypeId();

        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS};
        User usuario = CIBE_TestHelper.loginUser('CIBE_Gestor', null, null,listPermissionsSet);

        System.runAs(new User(Id = UserInfo.getUserId())){
            Account acc = new Account(
            Name = 'Grupo Comercial',
            RecordtypeId = rtAccount,
            OwnerId = usuario.Id
        );
        insert acc;

        Account acc1 = new Account(
            Name = 'Grupo Comercial2',
            RecordtypeId = rtAccount,
            OwnerId = usuario.Id
        );
        insert acc1;

        Contact conTest = new Contact(
            RecordTypeId = rtCont,
            FirstName = 'Empleado',
            LastName = '1',
            CC_Idioma__c = 'es',
            OwnerId = usuario.Id
        );
        insert conTest;

        //cuentas ej.
        Account a1 = new Account(
            Name = 'Name 1',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '1232',
            AV_Negocio__c = 'CIB',
            AV_EAPGestor__c = conTest.Id,
            OwnerId = usuario.Id
        );
        insert a1;

        Account a2 = new Account(
            Name = 'Name 2',
            RecordTypeId = rt.Id,
            AV_NumPerso__c = '32',
            AV_Negocio__c = 'CIB',
            OwnerId = usuario.Id
        );

        insert a2;


        FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
            Name = 'Parent',
            FinServ__InverseRole__c = 'Cliente',
            OwnerId = usuario.Id
        );
        insert role;
        
        FinServ__AccountAccountRelation__c accR1 = new FinServ__AccountAccountRelation__c(
            RecordtypeId = rtAccountRelation, 
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
            FinServ__Account__c = acc.id,
            FinServ__RelatedAccount__c = a1.id,
            CIBE_Matriz__c = true,
            FinServ__Role__c = role.id,
            OwnerId = usuario.Id
        );

        insert new List<FinServ__AccountAccountRelation__c> {accR1};


        FinServ__AccountAccountRelation__c accR2 = new FinServ__AccountAccountRelation__c(
            RecordtypeId = rtAccountRelation, 
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
            FinServ__Account__c = acc.id,
            CIBE_Matriz__c = true,
            FinServ__Role__c = role.id,
            OwnerId = usuario.Id
        );
        insert accR2;

        }
    }

    @IsTest
    static void getGestorTest(){
      

        User usuario  = [SELECT Id FROM User WHERE Alias = 'tsAlias'];
       
        System.runAs(usuario){
            Test.startTest();
            List<Account> acc = [SELECT Id, Name FROM Account WHERE Name = 'Grupo Comercial' LIMIT 1];
            List<FinServ__AccountAccountRelation__c> accR1 = [SELECT Id, FinServ__Account__c,FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.AV_EAPGestor__c, FinServ__RelatedAccount__r.AV_EAPGestor__r.Name FROM FinServ__AccountAccountRelation__c LIMIT 1];
            List<String> groupInfo = CIBE_GestorClient_Controller.getGestor(acc[0].Id);
            System.assert(groupInfo != null);
        }
        Test.stopTest();

 
       
    }

    @IsTest
    static void getGestorSinClientesTest(){
        User usuario  = [SELECT Id FROM User WHERE Alias = 'tsAlias'];
        List<String> groupInfo = new List<String>();

            Test.startTest();
            System.runAs(usuario){
                try{
                    List<Account> acc = [SELECT Id, Name FROM Account WHERE Name = 'Grupo Comercial2' LIMIT 1];
                    List<FinServ__AccountAccountRelation__c> accR1 = [SELECT Id, FinServ__Account__c,FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.AV_EAPGestor__c, FinServ__RelatedAccount__r.AV_EAPGestor__r.Name FROM FinServ__AccountAccountRelation__c];
                    groupInfo = CIBE_GestorClient_Controller.getGestor(acc[0].Id);
                    System.assert(groupInfo != null);
                }catch(Exception e){
                    Boolean expectedExceptionThrown =  e.getMessage().contains('El grupo comercial no tiene ningún cliente.') ? true : false;
                    System.AssertEquals(true, expectedExceptionThrown);
                }
            }
        Test.stopTest();
        
    }


}