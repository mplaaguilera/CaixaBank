/**********************************************************************************************************************
Name:     CIBE_TareasFichaCliente_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Class Test of CIBE_TareasFichaCliente_Controller
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION  USER_STORY				AUTHOR			DATE            Description
    1.0      Initial				Bea     		21/04/2023      Init version

***********************************************************************************************************************/
@isTest
public class CIBE_TareasFichaCliente_Controller_Test {
	
    @TestSetup
    static void setup(){
        List <String> ps = new list<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,CIBE_AppConstants.CIBE_CUSTOMMETADATA,CIBE_AppConstants.CIBE_ANALYTICS,CIBE_AppConstants.CIBE_OPERATIVAEMP};
        User usrGestor = CIBE_TestHelper.loginUser('CIBE_Gestor', null, 'U0009003',ps);
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Account centro = CIBE_TestHelper.createCaixaCenter('00615 STORE DOS DE MAIG-ROSSELLO','00615');
            Contact employee = CIBE_TestHelper.createEmployee(centro, usrGestor);
            Account acc = CIBE_TestHelper.createCustomer(usrGestor);
            Datetime activityDate = Date.Today().addMonths(1); 
            RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
            Task task = CIBE_TestHelper.createTareaOrigenAppToday(usrGestor, rt);
            task.OwnerId = usrGestor.Id;
            task.whatId = acc.Id;
            
            update(task);
        }
    }

    @isTest
	public static void tasksTest() {
        User usuarioGe = [SELECT Id, Name, AV_ExternalId__c FROM User WHERE profile.name = 'CIBE_Gestor' AND AV_ExternalID__c = 'U0009003' LIMIT 1];
        Account acc = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName= :CIBE_AppConstants.ACCOUNT_CLIENTE_RT AND AV_NumPerso__c = '123' LIMIT 1];

        System.runAs(usuarioGe) {

            Task task = [SELECT Id, AccountId FROM Task WHERE AccountId = :acc.Id AND RecordType.DeveloperName LIKE 'CIBE_%' AND (ActivityDate=LAST_N_DAYS:3 OR ActivityDate>=TODAY) AND Status IN ('Open','Pendiente no localizado') LIMIT 1];
            Test.startTest();
            List<CIBE_TareasFichaCliente_Controller.Wrapper> results = CIBE_TareasFichaCliente_Controller.tasksFichaCli(task.AccountId);
            System.assert(!results.isEmpty());
            Test.stopTest();
        }
    }  
    
}