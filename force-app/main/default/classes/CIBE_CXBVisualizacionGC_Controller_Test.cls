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
    
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/



@isTest
public with sharing class CIBE_CXBVisualizacionGC_Controller_Test {
    
    @TestSetup
    static void setup() {
        User usuario =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' and IsActive = true LIMIT 1];
        User usrTest = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0000001');
        //User usrTest2 = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0000002');


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
        User usuarioGe = [SELECT id FROM User WHERE Alias = 'AV-TF9'];
        Account accTest = [SELECT Id from Account WHERE Name = 'Name' LIMIT 1];
        System.runAs(usuarioGe){
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
    private static void createTeamMemberTest1(){
        User usuarioGe = [SELECT id FROM User WHERE Alias = 'AV-TF9'];
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        User usrTest3 = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0000003');

        System.runAs(usuarioGe){
            Test.startTest();
                CIBE_CXBVisualizacionGC_Controller.createTeamMember(new List<String>{accTest.Id}, usrTest3.Id, CIBE_AppConstants.GESTOR_PRINCIPAL);

                List<AccountTeamMember> accountTeamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId = :accTest.Id];
                System.assertEquals(2, accountTeamMembers.size());
                Test.stopTest();
        }
    }
    
    
    /***********************************************************************************************************/
    @isTest
    private static void createTeamMemberTest2(){
        User usuarioGe = [SELECT id FROM User WHERE Alias = 'AV-TF9'];
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        User usrTest3 = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0000003');

        System.runAs(usuarioGe){
            Test.startTest();
            CIBE_CXBVisualizacionGC_Controller.createTeamMember(new List<String>{accTest.Id}, usrTest3.Id, CIBE_AppConstants.GESTOR_PRINCIPAL);
            List<AccountTeamMember> accountTeamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId = :accTest.Id];
            accountTeamMembers = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId = :accTest.Id];
            System.assertEquals(2, accountTeamMembers.size());

            Integer participantes = 0;
            Integer gestoresPrincipales = 0;
            for(AccountTeamMember teamMember : accountTeamMembers) {
                if(teamMember.TeamMemberRole == CIBE_AppConstants.GESTOR_PRINCIPAL) {
                    gestoresPrincipales++;
                } else if(teamMember.TeamMemberRole == CIBE_AppConstants.PARTICIPANTE) {
                    participantes++;
                }
            }
            System.assertEquals(1, participantes);
            System.assertEquals(1, gestoresPrincipales);
            Test.stopTest();
        }
    }
    
    
    /***********************************************************************************************************/

    @isTest
    private static void showAddMemberButtonTest(){
        User usuarioGe = [SELECT id FROM User WHERE Alias = 'AV-TF9'];
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuarioGe){
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
        User usuarioGe = [SELECT id FROM User WHERE Alias = 'AV-TF9'];
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        List<String> selectedIds= new List<String>();
        System.runAs(usuarioGe){
            Test.startTest();
            List<AV_LookupSearchResult> lookSearchRT = CIBE_CXBVisualizacionGC_Controller.searchUser('Gestor',selectedIds);
            System.assert(lookSearchRT.isEmpty());
            Test.stopTest();
        }
    }

    /***********************************************************************************************************/
    
    @isTest
	private static void updateTeamMemberTest(){
        List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA};
        User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        
            System.runAs(new User(Id = UserInfo.getUserId())) {
                List<Account> accIds = new List<Account>();
                Account accTest1 = new Account(
                    Name = 'Name1',
                    RecordTypeId = rt.Id,
                    AV_NumPerso__c = '1234',
                    AV_Negocio__c = 'CIB',
                    OwnerId = usuario.Id
                );              

                accIds.add(accTest1);
                insert accIds;
            }

            System.runAs(usuario){
                Test.startTest();
                    Account accTest = [SELECT Id FROM Account WHERE Name = 'Name1' LIMIT 1];
                    System.assert(accTest!=null);
                    AccountTeamMember accTM = CIBE_TestHelper.createAccountTeamMember(usuario, accTest);
                    accTM.TeamMemberRole='Gestor Principal';
                    update accTM;
                    List<String> ListAccTest = new List<String>{accTest.Id};

                    CIBE_CXBVisualizacionGC_Controller.updateTeamMember(accTM.id,ListAccTest,accTM.TeamMemberRole, usuario.Id);
                
                Test.stopTest();
            }
    }

    /***********************************************************************************************************/

    @isTest
	private static void deleteTeamMemberTest(){
        // List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS};
        // User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
        User usuarioGe = [SELECT id FROM User WHERE Alias = 'AV-TF9'];
        System.runAs(usuarioGe) {
            // User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
            // usrTest.AV_ExternalID__c='U0000008';
            // update usrTest;
            Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
            AccountTeamMember accTM = CIBE_TestHelper.createAccountTeamMember(usuarioGe, accTest);
            List<String> ListAccTest = new List<String>{accTest.Id};
            CIBE_CXBVisualizacionGC_Controller.deleteTeamMember(usuarioGe.Id, ListAccTest);
            List <AccountTeamMember> accTMId = [SELECT Id FROM AccountTeamMember WHERE Id = :accTM.Id];
            System.assert(accTMId.isEmpty());
        } 
    }

        /***********************************************************************************************************/

        @isTest
        private static void getUserRoleTest(){
            List<String> listPermissionsSet = new List<String>{CIBE_AppConstants.CIBE_OPERATIVAEMP,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS};
            User usuario = CIBE_TestHelper.loginUser(null, null, null,listPermissionsSet);
            User usuarioGe = [SELECT id FROM User WHERE Alias = 'AV-TF9'];
            System.runAs(new User(Id = UserInfo.getUserId())) {
                User usrTest = [SELECT Id, CIBE_RoleName__c  FROM User WHERE AV_ExternalID__c = 'U0000001'];
                Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
                AccountTeamMember accTM = CIBE_TestHelper.createAccountTeamMember(usrTest, accTest);
                String result  = CIBE_CXBVisualizacionGC_Controller.getUserRole(usrTest.Id);
                System.assert(result== null);
            }
        }
    
}