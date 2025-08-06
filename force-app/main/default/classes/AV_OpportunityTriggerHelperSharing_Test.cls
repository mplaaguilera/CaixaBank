/**********************************************************************************************************************
Name:	  AV_OpportunityTriggerHelperSharing_Test
Copyright © 2019  CaixaBank
------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_OpportunityTriggerHelperSharing"
------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Fix      	   Elisabeth R.	        11/09/2023		Init version
***********************************************************************************************************************/
@isTest
public without sharing class AV_OpportunityTriggerHelperSharing_Test {
	@TestSetup
	static void setup(){
        
		AV_TestHelper.activateLogger(); 
		Set<String> setRTs = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.EMPLOYEE_RT,'AV_ProductoFichaCliente'};
		Map<String,RecordType> rtMap = AV_AppUtilities.getRecordTypeInMap(setRTs);

		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
	   
		System.runAs(userCli) {
			Account accTest = AV_TestHelper.createConfidencialCustomerSinInsert();
			Account cenTest = AV_TestHelper.createCaixaCenterSinInsert();
			List<Account> listAccountInsert = new List<Account>();
			listAccountInsert.add(accTest);
			listAccountInsert.add(cenTest);
			insert listAccountInsert;
		}

		System.runAs(userGcf){
			Account accTest = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
			Account cenTest = [SELECT Id FROM Account WHERE CC_Numero_Oficina_Empresa__c = '00615' LIMIT 1];
			Contact conTest2 = AV_TestHelper.createEmployeeSinInsert2(cenTest, userGcf, rtMap.get('Empleado'));
			conTest2.FirstName = 'Empleado2';
			List<Contact> listContactInsert = new List<Contact>();
			listContactInsert.add(conTest2);
			insert listContactInsert;

			Opportunity oppCallMe = new Opportunity();
			oppCallMe.AV_IncludeInPrioritizingCustomers__c =  true;
			oppCallMe.AccountId = accTest.Id;
			oppCallMe.AV_ExternalID__c = '50777';
			oppCallMe.Name = 'Opp Call Me';
			oppCallMe.StageName = 'Potencial';
			oppCallMe.RecordTypeId = rtMap.get('Call Me').Id;
			oppCallMe.CloseDate = System.today() + 5;
			oppCallMe.AV_Comentarios__c = 'Nueva Oportunidad tipo Call Me';
			oppCallMe.AV_Gestor__c = conTest2.Id;
			oppCallMe.OwnerId = userGcf.Id;
			oppCallMe.AV_FechaProximoRecordatorio__c = System.today();
			List<Opportunity> listOpportunityInsert = new List<Opportunity>();
			listOpportunityInsert.add(oppCallMe);
			insert listOpportunityInsert;
        
		}
    }

  

	@isTest
	public static void createTaskCallMeFromJSONTest(){
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		Opportunity opp = [SELECT ID, OwnerId, AV_ExternalID__c, AccountId, Name FROM Opportunity WHERE Name = 'Opp Call Me'];
		
		Test.startTest();
		System.runAs(userGcf){
			AV_OpportunityTriggerHelperSharing.createTaskCallMeFromJSON(opp);
		}
		Test.stopTest();

		List<Task> tskList = [SELECT ID FROM Task WHERE Subject='Opp Call Me'];
		System.assert(!tskList.isEmpty());
	} 
}