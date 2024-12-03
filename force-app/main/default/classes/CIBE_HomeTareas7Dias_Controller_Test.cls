/**********************************************************************************************************************
Name:     CIBE_HomeTareas7Dias_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_HomeTareas7Dias_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Bea     		14/04/2023      Init version

***********************************************************************************************************************/
@isTest
public class CIBE_HomeTareas7Dias_Controller_Test {
	
    @TestSetup
    static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGestor = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            Contact employee = CIBE_TestHelper.createEmployee(centro, usrGestor);
            Account acc = CIBE_TestHelper.createCustomer(usrGestor);
            RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_EMP_RT);
            Task task = CIBE_TestHelper.createTareaOrigenApp(usrGestor, rt);
           // task.AV_VisibleByLoggedUser__c = 'true';
        }
    }

    @isTest
	public static void tasksTest() {
        User usuarioGe = [SELECT Id, name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        
        System.runAs(usuarioGe) {
            Task task = [SELECT Id FROM Task WHERE ActivityDate >= LAST_N_DAYS:7 AND ActivityDate < TODAY AND RecordType.DeveloperName LIKE 'CIBE_OtrosEMP' AND Status in ('Open','Pendiente no localizado') AND AV_OrigenApp__c != 'AV_SalesforceTaskOpp' AND AV_VisibleByLoggedUser__c = true LIMIT 1];
            Test.startTest();
            List<CIBE_HomeTareas7Dias_Controller.Wrapper> results = CIBE_HomeTareas7Dias_Controller.tasks();
            System.assert(!results.isEmpty());
            Test.stopTest();
        }
    }  
    
}