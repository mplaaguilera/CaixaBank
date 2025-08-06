/**********************************************************************************************************************
Name:     CIBE_HomeEventos7Dias_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_HomeEventos7Dias_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Bea     		18/04/2023      Init version

***********************************************************************************************************************/
@isTest
public class CIBE_HomeEventos7Dias_Controller_Test {
	
    @TestSetup
    static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGestor = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            Contact employee = CIBE_TestHelper.createEmployee(centro, usrGestor);
            Account acc = CIBE_TestHelper.createCustomer(usrGestor);
           // RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
            Datetime activityDate = Date.Today()-4; 
            Event ev = CIBE_TestHelper.createEventActivityDateTime(usuarioGe, activityDate, acc);
            ev.OwnerId = usuarioGe.Id;
            update(ev);
        }
    }

    @isTest
	public static void eventsTest() {
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];

        System.runAs(usuarioGe) {
           
            Test.startTest();
            List<CIBE_HomeEventos7Dias_Controller.Wrapper> results = CIBE_HomeEventos7Dias_Controller.events7Days();
            System.assert(!results.isEmpty());
            Test.stopTest();
        }
    }  
    
}