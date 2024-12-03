/**********************************************************************************************************************
 Name:      AV_ProcessInactiveUserOppBatch_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test de la clase AV_ProcessInactiveUserOpportunitiesBatch
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION        USER_STORY       AUTHOR               DATE                Description
	1.0            App FSC          Sandra Gómez        17/12/2021          Init version
	1.1			   AV_Query IT		Daniel Rodríguez	3/02/2022			Change AV_Query to SOQL for User and Account
	1.2 		   US592987			Ángel Medina		30/05/2023			Changed AV_Query to SOQL queries

***********************************************************************************************************************/
@isTest
private class AV_ProcessInactiveUserOppBatch_Test {
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
		User u1 = AV_TestHelper.createUser(null, 'U01000012');
		Contact con =  AV_TestHelper.createEmployee(null,u1);
		
		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		insert pb;
		Test.startTest();
		Account acc = AV_TestHelper.createCustomer();
		Product2 prodPF = AV_TestHelper.createProduct(null,null);
		RecordType rt = AV_AppUtilities.getRecordType('Opportunity', 'AV_AlertaComercial');
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.Name = 'Alerta Comercial';
		opp.AV_ExternalID__c = '00000001';
		opp.StageName = 'En gestión/insistir';
		opp.RecordTypeId = rt.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c ='Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_Gestor__c = con.Id;
		opp.OwnerId = u1.Id;
		opp.AV_PF__c = prodPF.Id;
		insert opp;
        
        Task tarea = AV_TestHelper.createTarea(u1);
        
        AV_TestHelper.createTareaOportunidadExt(opp,tarea.AV_ExternalId__c);
		Test.stopTest();
	}
	
	@isTest
	static void executeProcessInactiveUserOpportunitiesBatch() {
		User u1 = [Select Id From User Where AV_ExternalID__c = 'U01000012'];
		
		Set<String> setUserIds = new Set<String>{u1.Id};
		AV_LogDebug.printLogDebug('executeProcessInactiveUserOpportunitiesBatch', 'User1: ' + u1);
		
		AV_ProcessInactiveUserOpportunitiesBatch b = new AV_ProcessInactiveUserOpportunitiesBatch('10000', setUserIds);
		
		Test.startTest();
		User userCli = [Select Id From User Where Profile.Name = 'API Only' and Alias = 'AV-TF9' limit 1];
		
		Database.executeBatch(b);
		Test.stopTest();
		Opportunity oppchange = [SELECT Id, OwnerId FROM Opportunity LIMIT 1];
		
		System.assertEquals(userCli.Id, oppchange.OwnerId);
		AV_CustomActivityOpportunity__c taskoppchange = [SELECT Id, OwnerId FROM AV_CustomActivityOpportunity__c WHERE AV_Opportunity__c = :oppchange.Id LIMIT 1];
		
        System.assertEquals(userCli.Id, taskoppchange.OwnerId);
	}
}