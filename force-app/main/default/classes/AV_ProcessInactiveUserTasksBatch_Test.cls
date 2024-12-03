/**********************************************************************************************************************
 Name:      AV_ProcessInactiveUserTasksBatch_Test
 Copyright © 2021  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProcessInactiveUserTasksBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION     USER_STORY      AUTHOR              DATE                Description
    1.0			US306420		Víctor Santiago     17/12/2021			Init version
    1.1			AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account
    1.2 		US592987	   	Laura Marrero		30/05/2023		    Changed AV_Query to SOQL queries and add runAs

***********************************************************************************************************************/
@isTest
private class AV_ProcessInactiveUserTasksBatch_Test {
    
    @TestSetup
    static void setup(){
        User u = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        //User u = AV_TestHelper.createUser(null, null);
        /*for (Integer i = 0; i < 10; i++) {
            AV_TestHelper.createTarea(u);
        }*/
        List<Task> tasks = new List<Task>();
		RecordType rt = AV_AppUtilities.getRecordType('Task', 'AV_AlertaComercial');
        for (Integer i=0;i<10;i++) {
			Task task = new Task();
			task.Subject = 'Call' + i;
			task.OwnerId = u.Id;
			task.AV_ExternalID__c = '01928374' + i;
			task.RecordTypeId = rt.Id;
			task.AV_CodigoGestorAsignado__c = 'U000900313';
			tasks.add(task);
		}
		insert tasks;
    }

    @isTest
    static void executeProcessInactiveUserTasksBatch() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true LIMIT 1];
        Set<String> extIds = new Set<String> {
            '019283740',
            '019283741',
            '019283742',
            '019283743',
            '019283744',
            '019283745',
            '019283746',
            '019283747',
            '019283748',
            '019283749'
        };
        Set<String> headersIds = new Set<String>();

        User u = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true LIMIT 1];
        
        AV_ProcessInactiveUserTasksBatch batch = new AV_ProcessInactiveUserTasksBatch('10000', new Set<String>{u.Id});
        Test.startTest();
        System.runAs(userGcf){
            Database.executeBatch(batch);
        }
        Test.stopTest();
            User asesor = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
            List<Task> tareas =  [SELECT Id, OwnerId, AV_ExternalID__c FROM Task WHERE AV_ExternalID__c IN :extIds];          
    
            for (Task t : tareas) {
                System.assertEquals(t.OwnerId, asesor.Id, 'Tasks OwnerId not changed');
            }
            List<AV_HeaderCustomActivity__c> headers = [SELECT Id, OwnerId, AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c IN :extIds];   

            for (AV_HeaderCustomActivity__c h : headers) {
                System.assertEquals(h.OwnerId, asesor.Id, 'Headers OwnerId not changed');
                headersIds.add(h.Id);
            }
            List<AV_CustomActivityOpportunity__c> tareasOps = [SELECT OwnerId, AV_Task__c FROM AV_CustomActivityOpportunity__c WHERE AV_Task__c IN :headersIds];
          
            for (AV_CustomActivityOpportunity__c to : tareasOps) {
                System.assertEquals(to.OwnerId, asesor.Id, 'Tarea-Oportunidad OwnerId not changed');
            }
        
    }
}