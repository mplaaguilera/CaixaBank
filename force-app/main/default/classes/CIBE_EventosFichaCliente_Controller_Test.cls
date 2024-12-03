/**********************************************************************************************************************
Name:     CIBE_FichaCliOportCIB_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_EventosFichaCliente_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Bea     		21/04/2023      Init version

***********************************************************************************************************************/
@isTest
public class CIBE_EventosFichaCliente_Controller_Test {
	
    @TestSetup
    static void setup(){

        CIBE_TestInitialSetup.setupInitialDataEMP();
        User managerUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];

        System.runAs(managerUser) {
            // Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            // Contact employee = CIBE_TestHelper.createEmployee(centro, managerUser);
            RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_EVENT, CIBE_AppConstants.EVENT_CLIENTE_RT);

            Account acc = CIBE_TestHelper.createCustomer(managerUser);
            Datetime activityDate = Date.Today().addMonths(1); 
            Event ev = CIBE_TestHelper.createEventActivityDateTime(managerUser, activityDate, acc);
            ev.recordtypeId = rt.Id;
            ev.CSBD_Evento_Estado__c ='Pendiente';
            ev.OwnerId = managerUser.Id;
            update(ev);
        }
    }

    @isTest
	public static void eventsTest() {
        User managerUser = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName= :CIBE_AppConstants.ACCOUNT_CLIENTE_RT AND AV_NumPerso__c = '123' LIMIT 1];
        
        System.runAs(managerUser) {
            Event ev = [SELECT Id, AccountId FROM Event WHERE AccountId = :acc.Id AND StartDateTime >= TODAY AND CSBD_Evento_Estado__c IN ('Pendiente', 'Pendiente no localizado', 'Planificada') AND RecordType.DeveloperName IN ('CIBE_EventoCliente', 'CIBE_EventodelGestor', 'CIBE_EventoClienteCIB') AND IsChild = false LIMIT 1];
            Test.startTest();
            List<CIBE_EventosFichaCliente_Controller.Wrapper> results = CIBE_EventosFichaCliente_Controller.eventsFichaCli(ev.AccountId);
            System.assert(!results.isEmpty());
            Test.stopTest();
        }
    }    
}