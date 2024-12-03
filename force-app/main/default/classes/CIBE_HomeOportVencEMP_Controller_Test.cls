/**********************************************************************************************************************
Name:     CIBE_HomeOportVencEMP_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_HomeOportVencEMP_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Bea     		17/11/2023      Init version

***********************************************************************************************************************/
    @isTest
    public class CIBE_HomeOportVencEMP_Controller_Test {
        
        @TestSetup
        static void setup(){
            List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
            CIBE_TestInitialSetup.setupInitialData(null, null, null, null, null, ps);
            User usrSetup = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000' LIMIT 1];
            User managerUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
            
            System.runAs(usrSetup) {
                Contact employee = [SELECT Id FROM Contact WHERE Account.Name = '00001 - CENTER' LIMIT 1];
                employee.AV_UsuarioAsociado__c = managerUser.Id;
                update(employee);
                Account acc = [SELECT Id FROM Account WHERE CC_Numero_Oficina__c = '00001' LIMIT 1];
                Date today = Date.today();
                Opportunity opp = CIBE_TestHelper.createOpportunityWithEmpleado(acc, employee, 'CIBE_Vencido', today, null, managerUser.Id);
            }
        }
    
        @isTest
        public static void opportunitiesTest() {
            User managerUser = [SELECT Id, name, AV_ExternalId__c FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
    
            System.runAs(managerUser) {
    
                Test.startTest();
                List<CIBE_HomeOportVencEMP_Controller.Wrapper> results = CIBE_HomeOportVencEMP_Controller.homeOppVencidas();
                System.assert(!results.isEmpty());
                Test.stopTest();
            }
        }  
        
    }