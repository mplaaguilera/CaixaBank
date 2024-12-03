@isTest
private class AV_TaskTable_Controller_Test {
    @TestSetup
	static void setup(){
        User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true LIMIT 1];
        AV_TestHelper.insertNeededPermissions(userGestor);
        DateTime activityTime= DateTime.now();

        System.runAs(userGcf){
            Account acc=AV_TestHelper.createCustomer();
            Opportunity testOpp = AV_TestHelper.createOpportunity(acc);
        }
        System.runAs(userGestor){
            Task testTask = AV_TestHelper.createTareaExternalId(userGestor, 'ID-0001');
        }
    }
    
    @isTest
    static void testGetRecords_Opportunity() {
        Test.StartTest();
        User userGestor = [SELECT ID FROM USER WHERE AV_ExternalID__c = 'U01545454'];        
        Task tarea = [SELECT Id, AV_Task__c FROM Task WHERE AV_ExternalID__c = 'ID-0001' LIMIT 1];
        Opportunity opp = [SELECT ID FROM Opportunity LIMIT 1];
        AV_TestHelper.createTareaOportunidad(opp, tarea.AV_Task__c);
        System.runAs(userGestor){
            AV_TaskTable_Controller.DataResponse response = AV_TaskTable_Controller.getRecords(opp.Id, 'Opportunity');
            system.assertNotEquals(null, response);
        }

    }

    @isTest
    static void testGetRecords_Account() {
        Test.StartTest();
        User userGestor = [SELECT ID FROM USER WHERE AV_ExternalID__c = 'U01545454'];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        System.runAs(userGestor){
            AV_TaskTable_Controller.DataResponse response = AV_TaskTable_Controller.getRecords(acc.Id, 'Account');
            system.assertNotEquals(null, response);
        }

        Test.StopTest();
    }

}