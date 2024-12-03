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
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGestor = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            Contact employee = CIBE_TestHelper.createEmployee(centro, usrGestor);
            Account acc = CIBE_TestHelper.createCustomer(usrGestor);
            Datetime activityDate = Date.Today().addMonths(1); 
            Event ev = CIBE_TestHelper.createEventActivityDateTime(usrGestor, activityDate, acc);
            ev.OwnerId = usrGestor.Id;
            update(ev);
        }
    }

    @isTest
	public static void eventsTest() {
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName= :CIBE_AppConstants.ACCOUNT_CLIENTE_RT AND AV_NumPerso__c = '123' LIMIT 1];
        
        System.runAs(usuarioGe) {
            Event ev = [SELECT Id, AccountId FROM Event WHERE AccountId = :acc.Id AND StartDateTime >= TODAY AND CSBD_Evento_Estado__c IN ('Pendiente', 'Pendiente no localizado') AND RecordType.DeveloperName IN ('CIBE_EventoCliente', 'CIBE_EventodelGestor') AND IsChild = false LIMIT 1];
            Test.startTest();
            List<CIBE_EventosFichaCliente_Controller.Wrapper> results = CIBE_EventosFichaCliente_Controller.eventsFichaCli(ev.AccountId);
            System.assert(!results.isEmpty());
            Test.stopTest();
        }
    }  
    
}