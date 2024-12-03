/**********************************************************************************************************************
Name:     CIBE_HomeTareasHoyCIB_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_HomeTareasHoyCIB_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Bea     		17/04/2023      Init version

***********************************************************************************************************************/
@isTest
public class CIBE_HomeTareasHoyCIB_Controller_Test {
	
    @TestSetup
    static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGestor = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            Contact employee = CIBE_TestHelper.createEmployee(centro, usrGestor);
            Account acc = CIBE_TestHelper.createCustomer(usrGestor);
            RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
            Task task = CIBE_TestHelper.createTareaOrigenAppToday(usrGestor, rt);
            
        }
    }

    @isTest
	public static void tasksTest() {
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];

        System.runAs(usuarioGe) {
            Task task = [SELECT Id FROM Task WHERE ActivityDate = TODAY and RecordType.DeveloperName = 'CIBE_OtrosCIB' and Status in ('Open','Pendiente no localizado') and AV_OrigenApp__c != 'AV_SalesforceTaskOpp' and AV_VisibleByLoggedUser__c = true LIMIT 1];
            Test.startTest();
            List<CIBE_HomeTareasHoyCIB_Controller.Wrapper> results = CIBE_HomeTareasHoyCIB_Controller.tasksHoyCIB();
            System.assert(!results.isEmpty());
            Test.stopTest();
        }
    }  
    
}