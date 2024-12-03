/**********************************************************************************************************************
Name:	  CIBE_CXBDisplayController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_CXBDisplayController"
-----------------------------------------------------------------------------------------------------------------------
Historial
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			Test Class		Jose Maria			11/08/2022		Init version
    1.1			Test Class		Beatriz y Alicia	24/11/2022		Create createTeamMemberTest(), deleteTeamMemberTest() and getAppDefinition()
    1.1			US580860		Lucia	            19/105/2023		Update getRecordsTest() y poner System.runAs


-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public with sharing class CIBE_CXBDisplayController_Test {

    @TestSetup
    static void setup(){
        
        RecordType rtAcc = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CONTACT, CIBE_AppConstants.EMPLOYEE_RT);

        CIBE_TestInitialSetup.setupInitialDataEMP();

        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

        System.runAs(new User(Id = UserInfo.getUserId())) {   
            Contact employee = new Contact();
            employee.RecordTypeId = rt.Id;
            employee.FirstName = 'TestEmpleado';
            employee.LastName = 'Test';
            employee.CC_Idioma__c = 'es';
            employee.AV_UsuarioAsociado__c = u.Id;
            employee.OwnerId = u.Id;
            insert employee;

            Account acc = new Account(
                Name = 'TestName',
                RecordTypeId = rtAcc.Id,
                AV_NumPerso__c = '12345',
                AV_Negocio__c = 'CIB',
                OwnerId = u.Id,
                AV_EAPGestor__c = employee.Id

            );
            insert acc;

            Account acc3 = new Account(
                Name = 'Test Name Cartera 2',
                RecordTypeId = rtAcc.Id,
                AV_Negocio__c = 'BPA',
                OwnerId = u.Id
            );
        insert acc3;

            AccountTeamMember teamMember  = new AccountTeamMember();
            teamMember.UserId = u.Id;
            teamMember.AccountId = acc.Id;
            teamMember.TeamMemberRole = 'Participante';
            insert teamMember;

            AV_Book__c book  = new AV_Book__c();
            book.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA, CIBE_AppConstants.CARTERA).Id;
            book.AV_Activa__c = 'S';
            book.OwnerId = u.Id;
            insert book;

            AV_BookManagementMember__c bookMemb  = new AV_BookManagementMember__c();
            bookMemb.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_CARTERA_GESTOR, CIBE_AppConstants.CARTERA_GESTOR).Id;
            bookMemb.AV_EmpleadoGestor__c = employee.Id;
            bookMemb.AV_Cartera__c = book.Id;
            insert bookMemb;  
        
        String rtAccount2 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
        String rtAccountRelation = Schema.SObjectType.FinServ__AccountAccountRelation__c.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();
        Account acc2 = new Account(
            Name = 'Grupo Comercial',
            RecordtypeId = rtAccount2,
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
            OwnerId = u.Id
        );
        insert acc2; 
        FinServ__ReciprocalRole__c role = new FinServ__ReciprocalRole__c(
            Name = 'Parent',
            FinServ__InverseRole__c = 'Cliente',
            OwnerId = u.Id
        );
        insert role;

        FinServ__AccountAccountRelation__c accR = new FinServ__AccountAccountRelation__c(
            RecordtypeId = rtAccountRelation, 
            CIBE_FechaCargaGE__c = Date.Today().addDays(-1),
            FinServ__Account__c = acc.id,
            FinServ__RelatedAccount__c = acc2.id,
            FinServ__Role__c = role.id,
            OwnerId = u.Id
        );

        insert accR;

        AV_Book__c cartera =  CIBE_TestHelper.createPurse('00001EAP110');
        Contact contacto = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :u.Id LIMIT 1];
        AV_BookManagementMember__c bMM =  CIBE_TestHelper.createBookManagement(contacto, cartera);
        CIBE_TestHelper.createBookMember(acc3, cartera);
        CIBE_TestHelper.createBookMember(acc, cartera);

        }

    }

    /***********************************************************************************************************/
    @isTest
	private static void getRecordsTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        String rtAcc = CIBE_AppConstants.ACCOUNT_CLIENTE_RT;

        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE Name = 'TestName' AND RecordType.DeveloperName = : rtAcc AND OwnerId =:usuario.Id];
            Test.startTest();
                List<CIBE_CXBDisplayController.Wrapper> records = CIBE_CXBDisplayController.getRecords(acc.Id);
            Test.stopTest();
        System.assert(!records.isEmpty());
        }
    }

    /***********************************************************************************************************/
    @isTest
    private static void getRecordsCIBTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        String rtAcc = CIBE_AppConstants.ACCOUNT_CLIENTE_RT;

        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE Name = 'TestName' AND RecordType.DeveloperName = : rtAcc AND OwnerId =:usuario.Id];
            Test.startTest();
                List<CIBE_CXBDisplayController.Wrapper> records = CIBE_CXBDisplayController.getRecordsCIB(acc.Id);
            Test.stopTest();
        System.assert(!records.isEmpty());
        }
    }
    
    /***********************************************************************************************************/

    @isTest
    private static void createDeleteTeamMemberTest(){
        User usrTest2 = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

        Test.startTest();
        RecordType rtAcc = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        Account acc = new Account(
            Name = 'TestName01',
            AV_NumPerso__c = '00000',
            AV_Negocio__c = 'CIB',
            OwnerId = usrTest2.Id,
            RecordTypeId = rtAcc.Id
        );
        insert acc;
            System.runAs(usrTest2){
                    CIBE_CXBDisplayControllerDelete.createTeamMember(acc.Id, usrTest2.Id, CIBE_AppConstants.GESTOR_PRINCIPAL);

                    List<AccountTeamMember> accountTeamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId = :acc.Id AND TeamMemberRole = : CIBE_AppConstants.GESTOR_PRINCIPAL];
                    System.assertEquals(1, accountTeamMembers.size());

                    CIBE_CXBDisplayControllerDelete.deleteTeamMember(accountTeamMembers[0].Id);
                    List <AccountTeamMember> accTMId = [SELECT Id FROM AccountTeamMember WHERE Id = :acc.Id];
                    System.assert(accTMId.isEmpty());
            }
        Test.stopTest();

    }
    
    
    /***********************************************************************************************************/
    @isTest
	private static void updateTeamMemberTest(){
        
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        System.runAs(usuario) {
            String rtAcc = CIBE_AppConstants.ACCOUNT_CLIENTE_RT;
            Account acc = [SELECT Id FROM Account WHERE Name = 'TestName' AND RecordType.DeveloperName =:rtAcc AND OwnerId =:usuario.Id];
            AccountTeamMember accTM = [SELECT Id FROM AccountTeamMember LIMIT 1];
            accTM.TeamMemberRole='Gestor Principal';
            update accTM;

            System.assert(acc!=null);
            CIBE_CXBDisplayControllerDelete.updateTeamMember(accTM.id,acc.id,accTM.TeamMemberRole);
        }

    }

    /***********************************************************************************************************/
    @isTest
	private static void showAddMemberButtonTest(){

        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        System.runAs(usuario) {
            String rtAcc = CIBE_AppConstants.ACCOUNT_CLIENTE_RT;
            Account acc = [SELECT Id FROM Account WHERE Name = 'TestName' AND RecordType.DeveloperName = : rtAcc AND OwnerId =:usuario.Id];
            Boolean flag = CIBE_CXBDisplayController.showAddMemberButton(acc.id);
            System.assert(flag!=null);
        }
    }

    /***********************************************************************************************************/
    @isTest
	private static void searchUserTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        String rtAcc = CIBE_AppConstants.ACCOUNT_CLIENTE_RT;
        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE Name = 'TestName' AND RecordType.DeveloperName =:rtAcc AND OwnerId =:usuario.Id];
            List<String> selectedIds= new List<String>();
            List<AV_LookupSearchResult> lookSearchRT = CIBE_CXBDisplayController.searchUser('Gestor',selectedIds);
            System.assert(lookSearchRT.isEmpty());
        }
    }    
    
    /***********************************************************************************************************/
    
    @isTest
	private static void showAddMemberGCTest(){
        User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];
        String rtAccount2 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CIBE_GrupoComercial').getRecordTypeId();

        System.runAs(usuario) {
            Account acc = [SELECT Id FROM Account WHERE Name = 'Grupo Comercial' AND RecordTypeId =:rtAccount2 AND OwnerId =:usuario.Id];

            Boolean records = CIBE_CXBDisplayController.showAddMemberGC(acc.Id);
            System.assertEquals(true, records);
        }
    }
    
    /***********************************************************************************************************/
    
    @isTest
    private static void getAppDefinition(){
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

        System.runAs(usrTest) {
            AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'CIBE_MisClientesEMP' LIMIT 1];        
            UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = UserInfo.getUserId(), FormFactor = 'Small');
            insert app;
        
            String resultado = CIBE_CXBDisplayController.getAppDefinition();
            System.assert(resultado != null);
        }
    }
    /***********************************************************************************************************/

    @IsTest
    private static void createTeamMemberCartera(){
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

        System.runAs(usrTest) {
            List<Account> acc  = [SELECT Id FROM Account WHERE Name = 'Test Name Cartera 2'];
           List<String> clientes = new List<String>();
           for (Account a : acc) {
                clientes.add(a.Id);
           }
           CIBE_CXBDisplayControllerDelete.createTeamMemberCartera(clientes, usrTest.Id);
           
           System.assert(!clientes.isEmpty());
           System.assert(usrTest.Id != null);
        }
    }


    
    @IsTest
    private static void createTeamMemberCartera2(){
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name ='CIBE_Gestor' AND createdbyId = :UserInfo.getUserId()];

        System.runAs(usrTest) {
            List<Account> acc  = [SELECT Id FROM Account];
           List<String> clientes = new List<String>();
           for (Account a : acc) {
                clientes.add(a.Id);
           }
           CIBE_CXBDisplayControllerDelete.createTeamMemberCartera(clientes, usrTest.Id);
           
           System.assert(!clientes.isEmpty());
           System.assert(usrTest.Id != null);
        }
    }

}