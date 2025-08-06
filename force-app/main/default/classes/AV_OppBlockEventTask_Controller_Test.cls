/********************************************************************************************************************
 Name:	  AV_OppBlockEventTask_Controller_Test
 Copyright © 2023  CaixaBank
 -----------------------------------------------------------------------------------------------------------------------
 Proposito: Gives test support to AV_OppBlockEventTask_Controller
 -----------------------------------------------------------------------------------------------------------------------
 Historial
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 VERSION		USER_STORY			AUTHOR				DATE			Description
 1.0			US602653         	Sandra Gómez    	18/10/2023		Init version
 1.1            PPM100265806        Oscar Moreno        10/10/2024      Add setupOpportunities method
 *********************************************************************************************************************/
@isTest
public with sharing class AV_OppBlockEventTask_Controller_Test {
	@TestSetup
	static void setup(){
		User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
		User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
		AV_TestHelper.insertNeededPermissions(userGestor);
		List<Account> listAccounts = new List<Account>();
		System.runAs(userCli) {
			Account centro = AV_TestHelper.createCaixaCenterSinInsert();
			centro.OwnerId = userGestor.Id;
			Account acc = AV_TestHelper.createCustomerSinInsert();
			acc.OwnerId = userGestor.Id;
			listAccounts.add(centro);
			listAccounts.add(acc);
			Database.insert(listAccounts,false);
		}
		System.runAs(userGcf){
			Contact contact = AV_TestHelper.createEmployeeSinInsert(listAccounts[0],userGestor,'U01545454');
			contact.CC_Numero_Documento__c = '9446386T';
			insert contact;
			Contact representante = AV_TestHelper.createRepresentante(listAccounts[0], userGcf,'U016129361923698126');
			RecordType rt = [SELECT ID FROM RecordType where DeveloperName = 'AV_Producto'and SobjectType = 'Product2'];
			RecordType rtPF = [SELECT ID FROM RecordType where DeveloperName = 'AV_PF'and SobjectType = 'Product2'];
			List<Task> listTasks = new List<Task>();
			RecordType rtPriorizador = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKPRIORIZADOR_RT);
			RecordType rtAvisos = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKAVISOS_RT);
			RecordType rtTaskIniciativa = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
			Task taskPriorizador = AV_TestHelper.createTareaWithRTSinInsert(userGestor, 'ID-0001', listAccounts[1],rtPriorizador);
			Task taskAvisos = AV_TestHelper.createTareaWithRTSinInsert(userGestor, 'ID-0002', listAccounts[1],rtAvisos);
			Task taskIniciativa = AV_TestHelper.createTareaWithRTSinInsert(userGestor, 'ID-0003', listAccounts[1],rtTaskIniciativa);
			Task taskIniciativa2 = AV_TestHelper.createTareaWithRTSinInsert(userGestor, 'ID-0004', listAccounts[1],rtTaskIniciativa);
			listTasks.add(taskPriorizador);
			listTasks.add(taskAvisos);
			listTasks.add(taskIniciativa);
			listTasks.add(taskIniciativa2);
			Database.insert(listTasks,false);
			Event eventoCliente = AV_TestHelper.createEvent(userGestor, DateTime.now(), listAccounts[1]);
			List<Product2> prodsToInsert = new List<Product2>();
			Product2 prodPF = AV_TestHelper.createProductSinInsert(null,null,'50112',rtPF);
			Product2 prodPF2 = AV_TestHelper.createProductSinInsert(null,null,'50113',rtPF);
			Product2 prodPF3 = AV_TestHelper.createProductSinInsert(null,null,'50114',rtPF);
			Product2 prodPF4 = AV_TestHelper.createProductSinInsert(null,null,'50115',rtPF);
			prodPF.AV_Visible__c = true;
			prodsToInsert.add(prodPF);
			prodsToInsert.add(prodPF2);
			prodsToInsert.add(prodPF3);
			prodsToInsert.add(prodPF4);
			Database.insert(prodsToInsert,false);
			List<Product2> prodsToInsert20 = new List<Product2>();
			Product2 prodPF20 = AV_TestHelper.createProductSinInsert(prodPF,'20','5011220',rt);
			Product2 prodPF220 = AV_TestHelper.createProductSinInsert(prodPF2,'20','5011320',rt);
			Product2 prodPF320 = AV_TestHelper.createProductSinInsert(prodPF3,'20','5011420',rt);
			Product2 prodPF420 = AV_TestHelper.createProductSinInsert(prodPF4,'20','5011520',rt);
			prodsToInsert20.add(prodPF20);
			prodsToInsert20.add(prodPF220);
			prodsToInsert20.add(prodPF320);
			prodsToInsert20.add(prodPF420);
			Database.insert(prodsToInsert20,false);
			List<Product2> prodsToInsert10 = new List<Product2>();
			Product2 prodPF10 = AV_TestHelper.createProductSinInsert(prodPF20,'10','5011210',rt);
			Product2 prodPF210 = AV_TestHelper.createProductSinInsert(prodPF220,'10','5011310',rt);
			Product2 prodPF310 = AV_TestHelper.createProductSinInsert(prodPF320,'10','5011410',rt);
			Product2 prodPF410 = AV_TestHelper.createProductSinInsert(prodPF420,'10','5011510',rt);
			prodPF10.AV_Sale__c=true;
			prodPF210.AV_Sale__c=true;
			prodPF310.AV_Sale__c=true;
			prodPF410.AV_Sale__c=true;
			prodsToInsert10.add(prodPF10);
			prodsToInsert10.add(prodPF210);
			prodsToInsert10.add(prodPF310);
			prodsToInsert10.add(prodPF410);
			Database.insert(prodsToInsert10,false);
		}
	}

	private static void setupOpportunities(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true LIMIT 1];
        User userGestor = [SELECT ID FROM USER WHERE AV_ExternalID__c = 'U01545454'];
        Set<String> prodExtIds = new Set<String>{
        '50115',
        '50114',
        '50113'};
        List<Product2> prodForOpps = [Select Id,AV_ExternalID__c FROM Product2 WHERE AV_ExternalID__c IN :prodExtIds];
        Map<String,Product2> mapProd = new Map<String,Product2>();
        for(Product2 prod : prodForOpps){
            mapProd.put(prod.AV_ExternalID__c,prod);
        }
        RecordType rtIniciativa = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);

        Account client = [SELECT ID FROM ACCOUNT WHERE AV_NumPerso__c = '123' LIMIT 1 ];
        Contact contact = [SELECT ID FROM CONTACT WHERE CC_Numero_Documento__c = '9446386T'];
        Opportunity opp1 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(client, contact, mapProd.get('50115'), rtIniciativa,'12312131230', userGestor.Id);
        Opportunity opp2 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(client, contact, mapProd.get('50114'), rtIniciativa,'12312131231', userGestor.Id);
        Opportunity opp3 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(client, contact, mapProd.get('50113'), rtIniciativa,'12312131232', userGestor.Id);
        opp3.StageName = AV_AppConstants.OPP_STATUS_POTENCIAL;
        Opportunity opp4 = AV_TestHelper.createOpportunityIniciativaWithChecktPrioritySinInsert(client, contact, null,'12312131233');
        insert new List<Opportunity>{opp1,opp2,opp3,opp4};  
    }


	@isTest
	public static void retrieveAccountOpportunitiesTest(){
		Test.startTest();
		Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT LIMIT 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' LIMIT 1];
		setupOpportunities();
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Task tarea = [SELECT Id, AV_Task__c FROM Task WHERE AV_ExternalId__c = 'ID-0003' LIMIT 1];
		AV_HeaderCustomActivity__c headerC = [SELECT id FROM AV_HeaderCustomActivity__c WHERE id =: tarea.AV_Task__c];
		headerC.ownerId = userGestor.id;
		update headerC;
		
		System.runAs(userGestor){
			AV_TestHelper.createTareaOportunidad(opp,tarea.AV_Task__c);
			AV_OppBlockEventTask_Controller.SendOppLists result  = AV_OppBlockEventTask_Controller.retrieveAccountOpportunities(acc.Id, tarea.AV_Task__c);
			System.assertNotEquals(new AV_OppBlockEventTask_Controller.SendOppLists(), result);
		}
		Test.stopTest();
	}

	@isTest
	public static void searchProductTest(){
        Test.startTest();
		Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        Product2 pro= [Select Id, Name, AV_ExternalID__c from Product2 WHERE AV_ExternalID__c = '50112' and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true];
		System.runAs(userGestor) {
			List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
			List<AV_LookupSearchResult> results2 = new List<AV_LookupSearchResult>();
            Product2 seeProd = [SELECT Id,Name FROM Product2 WHERE AV_ExternalID__c = '50112' and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true LIMIT 1];
			List<String> listaNoEmpty = new List<String>();
			listaNoEmpty.add(seeProd.Id);
            List<Id> fixedSearchResults = new List<Id>();
            fixedSearchResults.add(seeProd.Id);
            Test.setFixedSearchResults(fixedSearchResults);
			results = AV_OppBlockEventTask_Controller.searchProduct(seeProd.Name,null, acc.Id);
			results2 = AV_OppBlockEventTask_Controller.searchProduct('No existe',listaNoEmpty, acc.Id);
			System.assertEquals(false,results.isEmpty(), 'searchProductTest');
            System.assertEquals(true,results2.isEmpty(), 'searchProductTest');
		}
        Test.stopTest();
	}
}