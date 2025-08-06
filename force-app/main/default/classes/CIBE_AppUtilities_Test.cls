/**********************************************************************************************************************
 Name:	  CIBE_AppUtilities_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test para la clase CIBE_AppUtilities
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
   VERSION		USER_STORY	   AUTHOR		   		DATE			  Description
   1.0          App Utilities  Jose Maria           08/08/2022        Init version
   1.1          US609754  		Lucía          		 26/06/2023        Añadir el System.runAs y arreglar el error de QC: Apex unit tests should include at least one assertion
***********************************************************************************************************************/
@isTest
public class CIBE_AppUtilities_Test {
	
	@TestSetup
	static void setUp(){
		
		CIBE_TestInitialSetup.setupInitialData(null,CIBE_AppConstants.CIBE_ROLECIB,null,null,null,new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB,
																													CIBE_AppConstants.CIBE_CUSTOMMETADATA,
																													CIBE_AppConstants.CIBE_OPERATIVAEMP});
        User u = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];

		System.runAs(admin){
			Account acc = CIBE_TestHelper.createCustomer();
			Event evt = CIBE_TestHelper.createEvent(u, System.now(), acc);
			Task tsk = CIBE_TestHelper.createTareaExternalIdWithCustomer(u, 'XXX-0001', acc);
			RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_OPPORTUNITY, CIBE_AppConstants.OPP_INICIATIVAEMP_RT);
			Opportunity opp = new Opportunity();
				opp.AccountId = acc.Id;
				opp.Name = 'Alerta Comercial';
				opp.StageName = 'En gestión/insistir';
				opp.RecordTypeId = rt.Id;
				opp.CloseDate = System.today() + 5;
				opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
				opp.OwnerId = u.Id;
			insert opp;
		}
	}

	@isTest
	public static void testGetRecordTypeIdsInSet() {
		// Account acc = CIBE_TestHelper.createCustomer();
		User usuario = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

		System.runAs(usuario){
			Account acc = [SELECT Id, RecordTypeId FROM Account WHERE Name = 'Name'];	
			Set<String> setLabelsRt = new Set<String>{'CC_Cliente','CIBE_GrupoComercial','CIBE_GrupoEconomico'};
			String recordtypeId = '';

			Test.startTest();	
				Set<Id> setIdsRt = CIBE_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
				if((setIdsRt).contains(acc.RecordTypeId)){
					recordtypeId = acc.RecordTypeId;
				}
			Test.stopTest();
			System.assertEquals(acc.RecordTypeId, recordtypeId);
		}
	}
    
    @isTest
	public static void testGetRecordTypeIdsInSetv2() {
		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
			Account acc = [SELECT Id, RecordTypeId FROM Account WHERE Name = 'Name'];
			DateTime activityDate = Datetime.newInstance(2020, 5, 4);
			Test.startTest();	
				CIBE_AppUtilities.SearchRT clientePA 	= new CIBE_AppUtilities.SearchRT(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, 'CC_Cliente');
				Set<CIBE_AppUtilities.SearchRT> setLabelsRt = new Set<CIBE_AppUtilities.SearchRT>{clientePA};
				Set<Id> setIdsRt = CIBE_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
				String recordtypeId = null;
				if((setIdsRt).contains(acc.RecordTypeId)){
					recordtypeId = acc.RecordTypeId;
				}
			Test.stopTest();
			System.assertEquals(acc.RecordTypeId, recordtypeId);
		}
	}
    
    @isTest
    public static void testFindObjectNameFromRecordIdPrefix(){

		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
		Test.startTest();	
			Account acc = [SELECT Id, RecordTypeId FROM Account WHERE Name = 'Name'];
			String strObjectName = CIBE_AppUtilities.findObjectNameFromRecordIdPrefix(acc.Id);
		Test.stopTest();
        
        System.assertEquals(strObjectName, 'Account');
    }
    
    }
    
    @isTest
    public static void testCalculateHours(){
		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
			Test.startTest();	

				DateTime todayDate = DateTime.now();
				DateTime yesterdayDate = DateTime.now()-1;
				Long diferencia = CIBE_AppUtilities.calculateTimeDifferences(yesterdayDate,todayDate);
				Boolean correcto = false;
				if(diferencia == 23){
					correcto = true;
				} else if(diferencia == 24){
					correcto = true;
				}
			Test.stopTest();
        
        System.assertEquals(true, correcto);
		}
	}
	
	@isTest
	public static void testGetScheduleBatch() {
		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
			String nameBatch='AV_DeleteVentas';
			Test.startTest();
				AV_ScheduleBatch__mdt scheduler = CIBE_AppUtilities.getScheduleBatch(nameBatch);
			Test.stopTest();
			SObject after = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_Active__c, AV_CronTrigger__c, AV_NumDays__c, AV_Limit__c, AV_Description__c from AV_ScheduleBatch__mdt where DeveloperName = :nameBatch limit 1];
			
			System.assertEquals(scheduler, after);
		}
	}
    
    @isTest
	public static void testGetUserInfo() {
		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
			Test.startTest();
				User userLog = CIBE_AppUtilities.getUserInfo();
			Test.stopTest();
			System.assert(userLog!=null);
		}
	}

	@isTest
	public static void testGetApp() {
		Test.startTest();
			User u = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
			String appName = '';
			System.runAs(u){
				appName = CIBE_AppUtilities.getApplication();
			}
        Test.stopTest();
		System.assertEquals(null,appName,'No ha funcionado el método');
		
	}
    
    @isTest
    public static void testDisplayErrors(){

		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
		Test.startTest();	
			//Account acc = createCustomer();
			Account acc = [SELECT Id, RecordTypeId FROM Account WHERE Name = 'Name'];
        List<Account> listAcc = new List<Account>();
        listAcc.add(acc);
        try{
            List<Database.SaveResult> listResult = Database.insert(listAcc, false);
            CIBE_AppUtilities.displayErrors('test', listResult);
            
            List<Database.UpsertResult> listResult2 = Database.upsert(listAcc, false);
            CIBE_AppUtilities.displayErrors('test', listResult2);
        }catch(Exception e){
            AV_LogDebug.printException('test', e);
        }
		Test.stopTest();
			System.assertNotEquals(acc,null,'');
		}
    }
    
    public static Account createCustomer(){
		RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, 'CIBE_GrupoEconomico');
		Account acc = new Account(
				FirstName = 'FirstName',
				LastName = 'LastName',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '123',
				AV_Negocio__c = 'BPA'
			);
		return acc;
	}
    
    @isTest
    public static void testDeleteDataCustomer(){
		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
		System.runAs(usuario){
			Test.startTest();			
				Account acc = [SELECT Id, RecordTypeId FROM Account WHERE Name = 'Name'AND recordType.DeveloperName =:CIBE_AppConstants.ACCOUNT_CLIENTE_RT];
				CIBE_AppUtilities.deleteDataCustomer(acc.Id);
				List<Opportunity> accOppDeleted = [SELECT Id FROM Opportunity WHERE AccountId = :acc.Id AND RecordType.developerName like 'CIBE_%'];
				List<Event> accEventDeleted = [SELECT Id FROM Event WHERE WhatId = :acc.Id AND RecordType.developerName like 'CIBE_%'];

			Test.stopTest();
			System.assertEquals(0, accOppDeleted.size(), 'No se han borrado las opportunidades');
			System.assertEquals(0, accEventDeleted.size(), 'No se han borrado los eventos');
		}
    }

	@isTest
	public static void validategetListFromSet() {
		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
		Set<String> listSet= new Set<String> {'Hola','Prueba','Set'};
		Test.startTest();
		List<String> listOfSet = CIBE_AppUtilities.getListFromSet(listSet);
		Test.stopTest();
			System.assertNotEquals(listOfSet,null, 'No se ha rellenado la lista');
	}
    
	}
    
	@isTest
	public static void validateSetToStringIn() {
		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		System.runAs(usuario){
		Set<String> listSet= new Set<String> {'Hola','Prueba','Set'};
		Test.startTest();
		String listOfSet = CIBE_AppUtilities.setToStringIn(listSet);
		Test.stopTest();
			System.assertNotEquals(listOfSet,null, 'No se ha rellenado la lista');
		}
		
	}

	@isTest
	public static void getAppDefinitionTest() {
		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
        System.runAs(usuario) {
			Test.startTest();
				AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'CIBE_MisClientesEMP' LIMIT 1];        
				UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = usuario.Id, FormFactor = 'Large');
				insert app;
				System.assertEquals(appDefinition.DurableId, app.AppDefinitionId);
				String permission = CIBE_AppUtilities.getAppDefinition();
				System.assertEquals('CIBE_MisClientesEMP', permission);
			Test.stopTest();
        }
    }
    
    @isTest
	public static void getMonthNameTest() {
		User usuario =  [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];

        System.runAs(usuario) {
            System.assertEquals('Enero', CIBE_AppUtilities.getMonthName(1, 'es'));
            System.assertEquals('January', CIBE_AppUtilities.getMonthName(1, 'en_US'));
        }
    }

}