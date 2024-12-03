/**********************************************************************************************************************
Name:     CIBE_FichaCliOportCIB_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_FichaCliOportCIB_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Bea     		22/03/2023      Init version

***********************************************************************************************************************/
@isTest
public class CIBE_FichaCliOportCIB_Controller_Test {
	
    @TestSetup
    static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGestor = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            Contact employee = CIBE_TestHelper.createEmployee(centro, usrGestor);
            Account acc = CIBE_TestHelper.createCustomer(usrGestor);
            Opportunity opp = CIBE_TestHelper.createOpportunityWithEmpleado(acc, employee, 'Potencial');
            opp.AV_ToDelete__c = false;
            update(opp);
        }
    }

    @isTest
	public static void opportunitiesTest() {
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName= :CIBE_AppConstants.ACCOUNT_CLIENTE_RT AND AV_NumPerso__c = '123' LIMIT 1];
        
        System.runAs(usuarioGe) {
            Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :acc.Id AND StageName = 'Potencial' AND RecordType.DeveloperName LIKE 'CIBE_%' AND AV_ToDelete__c = false LIMIT 1];
            Test.startTest();
            List<CIBE_FichaCliOportCIB_Controller.Wrapper> results = CIBE_FichaCliOportCIB_Controller.opportunities(opp.AccountId);
            System.assert(!results.isEmpty());
            Test.stopTest();
        }
    }  
    
}