/**********************************************************************************************************************
 Name:	  CIBE_EventsFromGroupController_Test
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de Test para el controlador CIBE_EventsFromGroupController
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App FSC			Jose Maria			28/09/2022			Test Class
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_EventsFromGroupController_Test {

    @TestSetup
	static void setup() {
        CIBE_TestInitialSetup.setupInitialDataEMP();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
            Account acc = CIBE_TestHelper.createCustomer(u);

            Product2 prodPF = CIBE_TestHelper.createProduct(null,null);
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVACIB_RT);
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = rt.Id;
            opp.AccountId = acc.Id;
            opp.Name = 'Alerta Comercial';
            opp.StageName = 'En curso';
            opp.CloseDate = System.today() + 5;
            opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
            opp.AV_PF__c = prodPF.Id;
            opp.ownerId = u.Id;
            insert opp;
            
            DateTime activityDate = Datetime.newInstance(2022, 9, 9);
            Event event  = CIBE_TestHelper.createEvent(u, activityDate, acc);
            CIBE_TestHelper.createTareaOportunidad(opp, event.AV_Task__c);
        }
    }
    
	@isTest
	public static void getDataTest() {
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        
        System.runAs(u) {
            Map<Id, Account> clients = new Map<Id, Account>([SELECT Id FROM Account WHERE Recordtype.DeveloperName = 'CC_Cliente']);
           	
            Test.startTest();
            List<CIBE_EventsFromGroupController.EventWrapper> result = CIBE_EventsFromGroupController.getRecords(0, new List<Id>(clients.keySet()));
                                                                                                                  
            System.assert(!result.isEmpty()); 
            Test.stopTest();
        }
    }

}