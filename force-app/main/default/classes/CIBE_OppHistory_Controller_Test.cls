/**********************************************************************************************************************
Name:      CIBE_OppHistory_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_OppHistory_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Alicia     		09/02/2023      Init version

***********************************************************************************************************************/
@isTest
public class CIBE_OppHistory_Controller_Test {
	
    @TestSetup
    static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGestor = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            Contact employee = CIBE_TestHelper.createEmployee(centro, usrGestor);
            Account acc = CIBE_TestHelper.createCustomer(usrGestor);
            
            Opportunity opp = CIBE_TestHelper.createOpportunityWithEmpleado(acc, employee, 'Potencial');
        }
    }

    @isTest
	public static void oppHistoryTest() {
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        
        System.runAs(usuarioGe) {
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE OwnerId = :usuarioGe.Id AND StageName = 'Potencial' LIMIT 1];
            Test.startTest();
            opp.CIBE_AmountDivisa__c = 1230131;
            update opp;
            List<CIBE_OppHistory_Controller.Wrapper> results = CIBE_OppHistory_Controller.oppHistory(opp.Id);
            System.assert(!results.isEmpty());
            Test.stopTest();
        }
    }  
    
}