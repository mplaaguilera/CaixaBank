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

        CIBE_TestInitialSetup.setupInitialDataEMP();
		User usEMP = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];

        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS, CIBE_AppConstants.CIBE_GESTORINTERNO};
        User usCIB = CIBE_TestHelper.loginUser('CIBE_Gestor', 'CIB', 'U0009003',ps);
        Test.startTest();
        System.runAs(admin) {
            Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            Contact employee = CIBE_TestHelper.createEmployeeSinInsert(centro, usCIB);
            employee.OwnerId = usCIB.Id;
            insert employee;
            Account acc = CIBE_TestHelper.createCustomer();

            Contact contactEMP = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :usEMP.Id];
            
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
            Opportunity opp = new Opportunity();
                opp.AccountId = acc.Id;
                opp.AV_ExternalID__c = '00000011';
                opp.Name = 'Alerta Test Comercial CIB';
                opp.StageName = 'En curso';
                opp.RecordTypeId =  rt.Id;
                opp.CloseDate = System.today();
                opp.AV_ToDelete__c = false;
                opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial Test';
                opp.OwnerId = usEMP.Id;
                opp.CIBE_AmountDivisa__c = 312.67;
            insert opp;

            Opportunity opp2 = CIBE_TestHelper.createOpportunityWithEmpleado(acc, employee, 'Potencial');

        }
        Test.stopTest();
    }

    @isTest 
	public static void oppHistoryTest() {

		User usCIB = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0009003'];

        Test.startTest();
        System.runAs(usCIB) {
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE OwnerId = :usCIB.Id AND StageName = 'Potencial' LIMIT 1];
            System.assert(opp != null);
            opp.CIBE_AmountDivisa__c = 1230131;
            update opp;
            List<CIBE_OppHistory_Controller.Wrapper> results = CIBE_OppHistory_Controller.oppHistoryRole(opp.Id, 0);
            System.assert(!results.isEmpty());
        }

        Test.stopTest();
        

    }  


    @isTest
	public static void oppHistoryTest2() {
		User userEMP = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        Test.startTest();
        System.runAs(userEMP) {
            Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE OwnerId = :userEMP.Id AND StageName = 'En curso' LIMIT 1];
            opp.Name = 'Alerta Test';
            opp.StageName = 'Potencial';
            update opp;
            List<CIBE_OppHistory_Controller.Wrapper> results = CIBE_OppHistory_Controller.oppHistoryRole(opp.Id, 0);
            System.assert(!results.isEmpty());
        }
        
        Test.stopTest();

    }  
    
}