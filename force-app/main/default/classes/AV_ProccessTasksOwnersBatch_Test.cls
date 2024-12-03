/**********************************************************************************************************************
 Name:      AV_ProccessTasksOwnersBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProccessTasksOwnersBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
   1.0            App FSC          Jashanpreet Singh    07/10/2020          Init version
   1.1			  US164515		   Sandra Gómez			28/01/2021			Remodel Test
   1.2            App FSC          David Rufo         	11/02/2021          Fix performance problem

***********************************************************************************************************************/
@isTest
private class AV_ProccessTasksOwnersBatch_Test {
	 
    /**
	 * Create 10 Accounts with the field AV_BatchProccessOwners__c 'ToBeProcess'.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		User u1 = AV_TestHelper.createUser(null, 'U0100001');
        //AV_LogDebug.printLogDebug('setup', 'User1: ' + u1);
        Contact con =  AV_TestHelper.createEmployee(null,u1);
        //AV_LogDebug.printLogDebug('setup', 'Contact: ' + con);

		List<Task> tasks = new List<Task>();
		RecordType rt = AV_AppUtilities.getRecordType('Task', 'AV_AlertaComercial');
        
		// Insertar 10 Cuentas 
		for (Integer i=0;i<10;i++) {
			Task task = new Task();
			task.Subject = 'Call' + i;
			task.OwnerId = u1.Id;
			task.AV_ExternalID__c = '01928374' + i;
			task.RecordTypeId = rt.Id;
			task.AV_CodigoGestorAsignado__c = 'U0100002';
			tasks.add(task);
		}
		insert tasks;
        
        User u2 = AV_TestHelper.createUser(null, 'U0100002');
        //AV_LogDebug.printLogDebug('setup', 'User2: ' + u2);
        con.AV_UsuarioAsociado__c = u2.Id;
        update con;
	}

	/**
	 * Execute the Batch class (AV_ProccessTasksOwnersBatch) 
	 */
	@isTest
	static void executeProccessTasksOwnersBatch() {
        User u2 = [SELECT Id FROM User where AV_ExternalID__c = 'U0100002' limit 1];
        Set<String> setUserIds = new Set<String>{u2.Id};
        AV_LogDebug.printLogDebug('executeProccessTasksOwnersBatch', 'User2: ' + u2);
		AV_ProccessTasksOwnersBatch b = new AV_ProccessTasksOwnersBatch('300', setUserIds);
        
		Test.startTest();	
		Database.executeBatch(b);
		Test.stopTest();
        
        List<Task> listTask=[SELECT id, OwnerId FROM Task];
        for (Task ta:listTask) {
            System.assertEquals(ta.OwnerId, u2.id);
        }
	}
}