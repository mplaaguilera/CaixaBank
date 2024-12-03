/**********************************************************************************************************************
Name:	  CIBE_CXBVisualizacionGC_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_CXBVisualizacionGC_Controller"
-----------------------------------------------------------------------------------------------------------------------
Historial
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Test Class		Mikel Lezama		11/10/2022		Init version
1.1			Test Class		Beatriz y Alicia	24/11/2022		Modify setup() and create createTeamMemberTest()
1.2                         Ali                 10/05/2023      Create 'getUserRole()', 'updateTeamMemberTest()', 'deleteTeamMemberTest()' and edit 'getRecords()'
1.3         IN1184391    	Lucia				12/07/2024      Move 'createTeamMemberTest1()', 'createTeamMemberTest2()', 'updateTeamMemberTest()' to CIBE_UtilitiesWOS_Test

    
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/

@isTest
public with sharing class CIBE_CXBVisualizacionGC_Controller_Test {
    
    @TestSetup
    static void setup() {
        CIBE_TestInitialSetup.setupInitialData(null,CIBE_AppConstants.CIBE_ROLECIB,null,null,null,new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB, CIBE_AppConstants.CIBE_CUSTOMMETADATA, CIBE_AppConstants.CIBE_OPERATIVAEMP});
		User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
		User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        Account accTest = CIBE_TestHelper.createCustomer();
        Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
        Contact conTest = CIBE_TestHelper.createEmployee(centroCaixa, usrTest);
        //Contact conTest2 = CIBE_TestHelper.createEmployee(centroCaixa, usrTest2);
        
        AccountTeamMember accTM = CIBE_TestHelper.createAccountTeamMember(usrTest, accTest);
        
        AV_Book__c book = CIBE_TestHelper.createPurse('04380EAP004');
        AV_BookManagementMember__c member = CIBE_TestHelper.createBookManagement(conTest, book);
    }
    /***********************************************************************************************************/
    @isTest
    private static void getRecordsTest(){
        User admin = [SELECT id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        Account accTest = [SELECT Id from Account WHERE Name = 'Name' LIMIT 1];
        System.runAs(admin){
            Test.startTest();
            List<String> accIds = new List<String>();
            accIds.add(accTest.id);
            
            List<CIBE_CXBVisualizacionGC_Controller.Wrapper> recordsCIB = CIBE_CXBVisualizacionGC_Controller.getRecords(0, accIds, true);
            System.assert(!recordsCIB.isEmpty());
            List<CIBE_CXBVisualizacionGC_Controller.Wrapper> recordsEMP = CIBE_CXBVisualizacionGC_Controller.getRecords(0, accIds, false);
            System.assert(!recordsEMP.isEmpty());
            Test.stopTest();
        }
    }
    
    /***********************************************************************************************************/

    @isTest
    private static void showAddMemberButtonTest(){
        User admin = [SELECT id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        System.runAs(usrTest){
            Test.startTest();
            List<String> accIds = new List<String>();
            accIds.add(accTest.Id);
            
            Boolean flag = CIBE_CXBVisualizacionGC_Controller.showAddMemberButton(accIds);
            System.assert(flag!=null);
            Test.stopTest();
        }
    }
    
    /***********************************************************************************************************/
    
    @isTest
    private static void searchUserTest(){
        User admin = [SELECT id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        List<String> selectedIds= new List<String>();

        System.runAs(usrTest){
            Test.startTest();
            List<AV_LookupSearchResult> lookSearchRT = CIBE_CXBVisualizacionGC_Controller.searchUser('Gestor',selectedIds);
            System.assert(lookSearchRT.isEmpty());
            Test.stopTest();
        }
    }

    /***********************************************************************************************************/

        @isTest
        private static void getUserRoleTest(){
            User admin = [SELECT id FROM User WHERE AV_ExternalID__c = 'U0000000'];
            User usrTest = [SELECT id FROM User WHERE AV_ExternalID__c = 'U0000001'];
            Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
            System.runAs(admin) {
                AccountTeamMember accTM = CIBE_TestHelper.createAccountTeamMember(usrTest, accTest);
                String result  = CIBE_CXBVisualizacionGC_Controller.getUserRole(usrTest.Id);
                System.assert(result == 'CIB');
            }
        }
    
}