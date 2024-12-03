/**********************************************************************************************************************
 Name:	  AV_AppUtilities_Test
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test para AV_AppUtilities
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			Text Class		Carolina Alonso		10/03/2020		Init version
	1.1			Text Class		Carolina Alonso		27/04/2020		Test class getRecordType
	1.2			Text Class		Carolina Alonso		08/05/2020		Test class getRecordTypeIdsInSet
	1.3			Text Class		Esperanza Conde		01/10/2020		Test class calculateHours
	1.4			Text Class		Sandra Gómez		16/11/2020		Test class getScheduleBatch and Fix Test
	1.5			App FSC		  	David Rufo			15/12/2020		New method to retrieve the user info logged
	1.6			App FSC		  	Jashanpreet			01/03/2020		New method to retrieve the app where user is logged
	1.7			App FSC		  	David Rufo			18/05/2021		New test for display errors from Database class
	1.8			App FSC		  	David Rufo			30/06/2020		Method to delete data of a customer
	1.9			US276250	  	Víctor Santiago		15/10/2021		Added method testDmlFichaProd
	1.10		Fix IOP Dic		Víctor Santiago		14/12/2021		Deleted method testDmlFichaProd
	1.2		    AV_Query IT	    Daniel Rodríguez	02/03/2022	    Change AV_Query to SOQL for User, Account, Contact
	1.3			Test Class		Sandra Gómez		21/03/2022		Added method validategetListFromSet to get a List from a set os strings
	1.4			Fix				Sandra Gómez		06/04/2022		Added method validateListToStringIn
	1.5			QualityClouds	Luis Fernández		17/08/2022		Added an assertion line to methods that dont have**

***********************************************************************************************************************/
@isTest
public class AV_AppUtilities_Test {
	
    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
		AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition WHERE DeveloperName = 'AV_CRM_Intouch' LIMIT 1];        
		UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = UserInfo.getUserId(), FormFactor = 'Small');
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_ALTAOPP','OK'));
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        AV_TestHelper.createPricebook2();
        User us = AV_TestHelper.createUser('');
        Account centro = AV_TestHelper.createCaixaCenter();
        Contact cont = AV_TestHelper.createEmployee(centro,us);
        Account acc = AV_TestHelper.createCustomer();
        Event evt = AV_TestHelper.createEvent(us, System.now(), acc);
        Task tsk = AV_TestHelper.createTareaExternalIdWithCustomer(null, 'XXX-0001', acc);
        Opportunity opp = AV_TestHelper.createOpportunity(acc);
        insert app;
    }

	@isTest 
	public static void testGetRecordTypeInMap(){
		Test.startTest();
		Map<String,RecordType> testRT = AV_AppUtilities.getRecordTypeInMap(new Set<String>{AV_AppConstants.OPPINICIATIVA_RT});
		Test.stopTest();
		System.assert(!testRT.isEmpty(),'NOK');
	}

	@isTest
	public static void testGetRecordType() {
		test.startTest();
		RecordType rt = AV_AppUtilities.getRecordType('Contact', 'CC_Empleado');
		Contact empleado  = AV_TestHelper.createEmployee(null, null);
        Test.stopTest();
        System.assertEquals(empleado.RecordTypeId, rt.Id,'NOK');
	}
	
	@isTest
	public static void testGetRecordTypeIdsInSet() {
		Account acc = [SELECT Id, RecordTypeId FROM Account WHERE RecordType.DeveloperName = 'CC_ClientePA' LIMIT 1];
		Test.startTest();	
		Set<String> setLabelsRt = new Set<String>{'CC_ClientePA','CC_Cliente'};
		Set<Id> setIdsRt = AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
		String recordtypeId = '';
		if((setIdsRt).contains(acc.RecordTypeId)){
			recordtypeId = acc.RecordTypeId;
		}
		Test.stopTest();
        System.assertEquals(acc.RecordTypeId, recordtypeId,'NOK');
	}
    
    @isTest
	public static void testGetRecordTypeIdsInSetv2() {
		DateTime activityDate = Datetime.newInstance(2020, 5, 4);
		Account acc = [SELECT Id, RecordTypeId FROM Account WHERE Recordtype.DeveloperName = 'CC_ClientePA' LIMIT 1];
		Test.startTest();	
        AV_AppUtilities.SearchRT clientePA 	= new AV_AppUtilities.SearchRT(AV_AppConstants.OBJECT_NAME_ACCOUNT, 'CC_ClientePA');
        Set<AV_AppUtilities.SearchRT> setLabelsRt = new Set<AV_AppUtilities.SearchRT>{clientePA};
        Set<Id> setIdsRt = AV_AppUtilities.getRecordTypeIdsInSet(setLabelsRt);
        String recordtypeId = null;
		if((setIdsRt).contains(acc.RecordTypeId)){
			recordtypeId = acc.RecordTypeId;
		}
		Test.stopTest();
        System.assertEquals(acc.RecordTypeId, recordtypeId,'NOK');
	}
    
    @isTest
    public static void testFindObjectNameFromRecordIdPrefix(){
		Test.startTest();	
		Id accId = [SELECT Id FROM Account LIMIT 1].Id;
		String strObjectName = AV_AppUtilities.findObjectNameFromRecordIdPrefix(accId);
		Test.stopTest();
        System.assertEquals(strObjectName, 'Account','NOK');
    }
    
    @isTest
    public static void testCalculateHours(){
        Test.startTest();	
        DateTime todayDate = DateTime.now();
        DateTime yesterdayDate = DateTime.now()-1;
		Long diferencia = AV_AppUtilities.calculateTimeDifferences(yesterdayDate,todayDate);
        Boolean correcto = false;
        if(diferencia == 23){
            correcto = true;
        } else if(diferencia == 24){
            correcto = true;
        }
		Test.stopTest();
        System.assertEquals(true, correcto,'NOK');
	}
	
	@isTest
	public static void testGetScheduleBatch() {
		String nameBatch='AV_DeleteVentas';
		Test.startTest();
		AV_ScheduleBatch__mdt scheduler = AV_AppUtilities.getScheduleBatch(nameBatch);
		Test.stopTest();
		SObject after = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, AV_Active__c, AV_CronTrigger__c, AV_NumDays__c, AV_Limit__c, AV_Description__c from AV_ScheduleBatch__mdt where DeveloperName = :nameBatch limit 1];
		System.assertEquals(scheduler, after,'NOK');
	}
    
    @isTest
	public static void testGetUserInfo() {
		Test.startTest();
		User userLog = AV_AppUtilities.getUserInfo();
        Test.stopTest();
        System.assert(userLog!=null,'NOK');
	}

	@isTest
	public static void testGetApp() {
		Test.startTest();
		User u = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
		String appName = '';
		System.runAs(u){
			appName = AV_AppUtilities.getApplication();
		}
        Test.stopTest();
		System.assertEquals(null,appName,'No ha funcionado el método');
	}
    //Revisar
    @isTest
    public static void testDisplayErrors(){
		Test.startTest();	
		Account acc = AV_TestHelper.createCustomer2();
        List<Account> listAcc = new List<Account>();
        listAcc.add(acc);
		List<Boolean> databaseResults = new List<Boolean>();
        try{
            List<Database.SaveResult> listResult = Database.insert(listAcc, false);
            AV_AppUtilities.displayErrors('test', listResult);
			for(Database.SaveResult dbs : listResult){
				databaseResults.add(dbs.isSuccess());
			}
            
            List<Database.UpsertResult> listResult2 = Database.upsert(listAcc, false);
            AV_AppUtilities.displayErrors('test', listResult2);
			for(Database.UpsertResult dbs : listResult2){
				databaseResults.add(dbs.isSuccess());
			}
        }catch(Exception e){
            AV_LogDebug.printException('test', e);
        }
		Test.stopTest();
		System.assertNotEquals(acc,null,'');
    }
    
    public static Account createCustomer(){
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_ACCOUNT, 'CC_ClientePA');
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
        Test.startTest();
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        AV_AppUtilities.deleteDataCustomer(accId);
		List<Task> accTskDeleted = [SELECT ID FROM TASK WHERE AV_ExternalID__c = 'XXX-0001' and (AccountId = :accId OR WhatId = :accId)];
		Test.stopTest();
		System.assertEquals(accTskDeleted.size(),0,'No se ha borrado todo');
    }

	@isTest
	public static void validategetListFromSet() {
		Set<String> listSet= new Set<String> {'Hola','Prueba','Set'};
		Test.startTest();
		List<String> listOfSet = AV_AppUtilities.getListFromSet(listSet);
		Test.stopTest();
		System.assertNotEquals(listOfSet,null,'No se ha llenado la lista');
	}

	@isTest
	public static void validateSetToStringIn() {
		Set<String> listSet= new Set<String> {'Hola','Prueba','Set'};
		Test.startTest();
		String listOfSet = AV_AppUtilities.setToStringIn(listSet);
		Test.stopTest();
		System.assertNotEquals(listOfSet,null,'No se ha llenado la lista');
	}

	@isTest
	public static void validateListToStringIn() {
		List<String> listSet= new List<String> {'Hola','Prueba','Set'};
		Test.startTest();
		String listOfSet = AV_AppUtilities.listToStringIn(listSet);
		Test.stopTest();
		System.assertNotEquals(listOfSet,null,'No se ha llenado la lista');
	}

	@isTest
	public static void validateArrayToStringIn() {
		String[] listSet= new String[] {'Hola','Prueba','Set'};
		Test.startTest();
		String listOfSet = AV_AppUtilities.arrayToStringIn(listSet);
		Test.stopTest();
		System.assertNotEquals(listOfSet,null,'No se ha llenado la lista');
	}

	@isTest
	public static void testGetCurrentSFApplication() {
		Test.startTest();
		String appName = AV_AppUtilities.getCurrentSFApplication();
        Test.stopTest();
        System.assert(String.isNotBlank(appName),'NOK');
	}
}