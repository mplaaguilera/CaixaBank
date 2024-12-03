/********************************************************************************************************************
 Name:	  AV_ReportAppointment_Controller_Test
 Copyright © 2023  CaixaBank
 -----------------------------------------------------------------------------------------------------------------------
 Proposito: Gives test support to AV_ReportAppointmentController
 -----------------------------------------------------------------------------------------------------------------------
 Historial
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 VERSION		USER_STORY			AUTHOR				DATE			Description
 1.0			US546892         	Luis Fernandez		30/06/2023		Init version
 1.1			US546892			Sandra Gómez		21/09/2023		Add All methods
 *********************************************************************************************************************/
@isTest
public with sharing class AV_ReportAppointment_Controller_Test {
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
           Contact contact = AV_TestHelper.createEmployee(listAccounts[0], userGestor);
           Contact representante = AV_TestHelper.createRepresentante(listAccounts[0], null,'U016129361923698126');
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
           update new List<AV_HeaderCustomActivity__c>{

               new AV_HeaderCustomActivity__c(Id = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = 'ID-0003' LIMIT 1].AV_Task__C , OwnerId = userGestor.Id),
               new AV_HeaderCustomActivity__c(Id = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = 'ID-0002' LIMIT 1].AV_Task__C , OwnerId = userGestor.Id),
               new AV_HeaderCustomActivity__c(Id = [SELECT AV_Task__c FROM Task WHERE AV_ExternalID__c = 'ID-0004' LIMIT 1].AV_Task__C , OwnerId = userGestor.Id)
            };
           Event eventoCliente = AV_TestHelper.createEvent(userGestor, DateTime.now(), listAccounts[1]);
           List<Product2> prodsToInsert = new List<Product2>();
           Product2 prodPF = AV_TestHelper.createProductSinInsert(null,null,'50112',rtPF);
           Product2 prodPF2 = AV_TestHelper.createProductSinInsert(null,null,'50113',rtPF);
           Product2 prodPF3 = AV_TestHelper.createProductSinInsert(null,null,'50114',rtPF);
           Product2 prodPF4 = AV_TestHelper.createProductSinInsert(null,null,'50115',rtPF);
           Product2 prodPF5 = AV_TestHelper.createProductSinInsert(null,null,'50116',rtPF);
           prodPF.AV_Visible__c = true;
           prodsToInsert.add(prodPF);
           prodsToInsert.add(prodPF2);
           prodsToInsert.add(prodPF3);
           prodsToInsert.add(prodPF4);
           prodsToInsert.add(prodPF5);
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
           RecordType rtIniciativa = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
           Opportunity opp1 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(listAccounts[1], contact, prodPF4, rtIniciativa,'12312131230', userGestor.Id);
           Opportunity opp2 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(listAccounts[1], contact, prodPF3, rtIniciativa,'12312131231', userGestor.Id);
           Opportunity opp3 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(listAccounts[1], contact, prodPF2, rtIniciativa,'12312131232', userGestor.Id);
           Opportunity opp4 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(listAccounts[1], contact, prodPF, rtIniciativa,'12312131233', userGestor.Id);
           opp2.StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
           opp3.StageName = AV_AppConstants.OPP_STATUS_VENCIDO;
           opp4.StageName = AV_AppConstants.OPP_STATUS_VENCIDO;
           
           List<Opportunity> listOpps = new List<Opportunity>();
           Database.insert(new List<Opportunity>{opp1,opp2,opp3,opp4},false);

           AV_ReportAppointment_Controller.OppoWrap p1 = new AV_ReportAppointment_Controller.OppoWrap(opp1);
           AV_ReportAppointment_Controller.OppoWrap p2 = new AV_ReportAppointment_Controller.OppoWrap(opp2);
           p1.Propension = 10;
           p2.Propension = 10;
           p1.compareTo(p2);
           p2.Propension = 20;
           p1.compareTo(p2);
           p2.Propension = 5;
           p1.compareTo(p2);
       }
   }

   @isTest
   public static void retrieveAccountOpportunitiesTest(){
       Test.startTest();
       User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
       Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
       System.runAs(userGestor){
           List<AV_ReportAppointment_Controller.OppoWrap> result  = AV_ReportAppointment_Controller.retrieveAccountOpportunities(acc.Id);
           System.assertEquals(4, result.size());
       }
       Test.stopTest();
   }

   @isTest
   public static void getPicklistValuesTest(){
       Test.startTest();
       User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
       System.runAs(userGestor){
           String[] fieldsToTest = new String[]{'StageName',AV_AppConstants.OPPO_POTENCIAL_FIELD};
           List<List<Map<String, String>>> picklistValues = AV_ReportAppointment_Controller.getPicklistValues(fieldsToTest);
           System.assertNotEquals(null, picklistValues);
           System.assertNotEquals(0, picklistValues.size());
       }
       Test.stopTest();
   }

   @isTest
   public static void retrieveAccountTaskTest(){
       Test.startTest();
		Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		System.runAs(userGestor){
			List<AV_ReportAppointment_Controller.TaskWrapp> results  = AV_ReportAppointment_Controller.retrieveAccountTask(acc.Id);
            System.assertEquals(2, results.size());
		}
		Test.stopTest();
   }

   @isTest
	public static void searchByProductTest(){
        Test.startTest();
		User usuario =[Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Product2 seeProd10 = [SELECT Id,Name,AV_NombrePF__c FROM Product2 WHERE AV_ExternalID__c = '5011310' LIMIT 1];
        Product2 resultFatherProd = [SELECT Id,Name,AV_NombrePF__c FROM Product2 WHERE AV_ExternalID__c = '5011320' LIMIT 1];
		System.runAs(usuario) {
			List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
			List<AV_LookupSearchResult> results2 = new List<AV_LookupSearchResult>();
			results = AV_ReportAppointment_Controller.searchByProduct(seeProd10.Name, seeProd10.AV_NombrePF__c);
			results2 = AV_ReportAppointment_Controller.searchByProduct('No Existe', seeProd10.AV_NombrePF__c);
			System.assertEquals(false,results.isEmpty(), 'tiene datos');
            System.assertEquals(false,results2.isEmpty(), 'es false por el onclick');
            Id[] fixedResults = new Id[2];
            fixedResults[0] = resultFatherProd.Id;
            fixedResults[1] = seeProd10.Id;
            Test.setFixedSearchResults(fixedResults);
			List<AV_LookupSearchResult> results3 = AV_ReportAppointment_Controller.searchByProduct(seeProd10.Name, resultFatherProd.Id);
            
		}
        Test.stopTest();
	}

   @isTest
	public static void searchOfficeTest() {
        Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		Account centro = [SELECT Id,Name FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT limit 1];
		System.runAs(userGestor) {
			List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
			List<AV_LookupSearchResult> results2 = new List<AV_LookupSearchResult>();
			List<String> selectedId = new List<String>();
			selectedId.add(centro.Id);
            List<Id> fixedSearchResults = new List<Id>();
            fixedSearchResults.add(centro.Id);
            Test.setFixedSearchResults(fixedSearchResults);
			results = AV_ReportAppointment_Controller.searchOffice(centro.Name.substring(0, 4), null);
			results2 = AV_ReportAppointment_Controller.searchOffice('Acc test', selectedId);
			System.assertEquals(false,results.isEmpty(), 'searchOfficeTest');
		}
        Test.stopTest();
	}

	@isTest
	public static void searchContactTest(){
        Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		Account acc = [SELECT Id,Name FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT limit 1];
        Contact gestor = [SELECT Id, Name, CC_CargoRepresentante__c FROM Contact WHERE CC_Matricula__c = 'U016129361923698126' and RecordType.DeveloperName='CIBE_Apoderado' and AccountId = :acc.Id LIMIT 1];
		System.runAs(userGestor) {
			List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
			List<AV_LookupSearchResult> results2 = new List<AV_LookupSearchResult>();
			List<String> selectedId = new List<String>();
			selectedId.add(gestor.Id);
            List<Id> fixedSearchResults = new List<Id>();
            fixedSearchResults.add(gestor.Id);
            Test.setFixedSearchResults(fixedSearchResults);
			results = AV_ReportAppointment_Controller.searchContact(gestor.Name, null, acc.Id);
			results2 = AV_ReportAppointment_Controller.searchContact('Gestor test', selectedId, acc.Id);
			System.assertEquals(false,results.isEmpty(), 'searchContactTest');
		}
        Test.stopTest();
	}

	@isTest
	public static void updateBackReportTest(){
        Test.startTest();
        Set<String> opposExternalIds = new Set<String>{
                '12312131230',
                '12312131231',
                '12312131232',
                '12312131233'
        };
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        List<Opportunity> listOpps = [SELECT Id, AV_IncludeInPrioritizingCustomers__c,AV_FechaProximoRecordatorio__c, StageName, AV_Potencial__c, Amount, CloseDate, AV_Cuota__c, AV_Resolucion__c, AV_AmountEuro__c, AV_Comentarios__c, AV_Tenencia__c, AV_Entidad__c, AV_FechaVencimiento__c,AV_MarginEuro__c, AV_ByProduct__c FROM Opportunity WHERE AV_ExternalID__c IN :opposExternalIds];

		listOpps[0].StageName = AV_AppConstants.OPP_STATUS_NOINTERE;
        Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
		oppMap.put(listOpps[0].Id, listOpps[0]);
		String jsonListOpp = JSON.serialize(oppMap);
		List<String> listIdsOpp = new List<String>{listOpps[1].Id};
		System.runAs(userGestor){
			String response = AV_ReportAppointment_Controller.updateBackReport(jsonListOpp, listIdsOpp);
            listOpps[2].RecordTypeId = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY,AV_AppConstants.OPPALERTACOM_RT).Id;
            oppMap.put(listOpps[2].Id,listOpps[2]);
            String errorResponse = AV_ReportAppointment_Controller.updateBackReport(JSON.serialize(oppMap), listIdsOpp);

            String errorResponse2 = AV_ReportAppointment_Controller.updateBackReport(
                JSON.serialize(
                    new Map<String,Opportunity>{
                        listOpps[0].Id => listOpps[0]
                    }
                ),new List<String>{listOpps[1].Id}
            );
		}
		List<Opportunity> deletedOpps = [SELECT Id FROM Opportunity WHERE Id = :listOpps[1].Id];
		System.assertEquals(0, deletedOpps.size());
        Test.stopTest();
	}

	@isTest
	public static void updateTaskBlockTest(){
        Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        Task tarea = [SELECT Id FROM Task WHERE RecordType.DeveloperName = :AV_AppConstants.TASKAVISOS_RT limit 1];
		System.runAs(userGestor){
			Map<Object, Object> eventOrTsk = new Map<Object, Object>();
            eventOrTsk.put('type','Task');   
            eventOrTsk.put('typeTask','CTO');
			Map<String, Map<Object, Object>> testTasks = new Map<String, Map<Object, Object>>();
            Map<Object, Object> mapTask = new Map<Object, Object> ();
            mapTask.put('id',tarea.Id);
            mapTask.put('comment','Comentario nuevo');
            mapTask.put('status','Gestionada positiva');
            testTasks.put(tarea.Id,mapTask);
			AV_ReportAppointment_Controller.TaskBlockResult result = AV_ReportAppointment_Controller.updateTaskBlock(eventOrTsk, testTasks);
            System.assertEquals('OK', result.results);
		}
		Test.stopTest();
	}

	@isTest
	public static void updateDeleteTaskCheckOnOffTest(){
		Test.startTest();
		Account acc = [SELECT Id FROM Account LIMIT 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		List<Task> listTask = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c FROM Task WHERE AV_ExternalId__c = 'ID-0003' or AV_ExternalId__c = 'ID-0004' limit 2];
		Opportunity opp = [Select Id from Opportunity limit 1];
		AV_CustomActivityOpportunity__c taOpp = AV_TestHelper.createTareaOportunidadSinInsert(opp, listTask[0].AV_Task__c);
        taOpp.OwnerId = userGestor.Id;
        insert taOpp;
		listTask[1].ActivityDate = Date.today().addDays(4);
		List<Task> listTaskChangeDate = new List<Task>();
		listTaskChangeDate.add(listTask[1]);
		List<Task> listTaskToDelete = new List<Task>();
		listTaskToDelete.add(listTask[0]);
		List<AV_CustomActivityOpportunity__c> listTaskOpportunityDelete = new List<AV_CustomActivityOpportunity__c>();
		listTaskOpportunityDelete.add(taOpp);
		System.runAs(userGestor){
			String result = AV_ReportAppointment_Controller.updateDeleteTaskCheckOnOff(listTaskChangeDate, listTaskToDelete, listTaskOpportunityDelete);
			System.assertEquals('OK', result);
		}
		Test.stopTest();
	}

	@isTest
	public static void structureTaskOppInsertBackTest(){
        Test.startTest();
		Account acc = [SELECT Id FROM Account LIMIT 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		Product2 prodPF2 = AV_TestHelper.createProduct(null,null);
		RecordType rt2 = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Opportunity opp = new Opportunity();
		opp.AccountId = acc.Id;
		opp.Name = 'Wivai';
		opp.StageName = AV_AppConstants.OPP_STATUS_POTENCIAL;
		opp.RecordTypeId = rt2.Id;
		opp.CloseDate = System.today() + 5;
		opp.AV_Comentarios__c = 'Nueva Oportunidad tipo Alerta Comercial';
		opp.AV_PF__c = prodPF2.Id;
		opp.ownerId = userGestor.Id;
		System.runAs(userGestor){
			RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TAREA_OPOR, AV_AppConstants.TAREA_OPOR_RT);
			AV_CustomActivityOpportunity__c taOpp = new AV_CustomActivityOpportunity__c();
			taOpp.OwnerId = userGestor.Id;
			taOpp.RecordTypeId = rt.Id;
			taOpp.AV_Opportunity__c = opp.Id;
			taOpp.AV_ExternalID__c = '12344321';
			taOpp.AV_OrigenApp__c = 'AV_SalesforceReport';
			taOpp.AV_Amount__c = 1000;
			taOpp.AV_Commentary__c = 'comentario';
			taOpp.AV_Concepto1__c = 'concepto1';
			taOpp.AV_Concepto2__c = 'concepto2';
			taOpp.AV_Concepto3__c = 'concepto3';
			taOpp.AV_Concepto4__c = 'concepto4';
			taOpp.AV_Concepto5__c = 'concepto5';
			taOpp.AV_Entity__c = 'Oviedo';
			taOpp.AV_FeeAmount__c = 230;
			taOpp.AV_Gestor__c =  userGestor.Id;
			taOpp.AV_HoldingAnotherEntity__c = 'S';
			taOpp.AV_Priority__c = 'S';
			taOpp.AV_Stage__c = 'No interesado';
			taOpp.AV_Valor1__c = 'Valor 1';
			taOpp.AV_Valor2__c = 'Valor 2';
			taOpp.AV_Valor3__c = 'Valor 3';
			taOpp.AV_Valor4__c = 'Valor 4';
			taOpp.AV_Valor5__c = 'Valor 5';
			taOpp.AV_IncludeInPrioritizingCustomers__c = false;
			taOpp.AV_Status__c = 'Open';
			taOpp.AV_Channel__c = 'CTO';
			taOpp.AV_AmountEuro__c = 1000;
			taOpp.AV_MarginEuro__c = 0.3;
			AV_CustomActivityOpportunity__c taskOppInsert = AV_ReportAppointment_Controller.structureTaskOppInsertBack(taOpp);
			System.assertEquals(taOpp.OwnerId, taskOppInsert.OwnerId);
			System.assertEquals(taOpp.RecordTypeId, taskOppInsert.RecordTypeId);
			System.assertEquals(taOpp.AV_ExternalID__c, taskOppInsert.AV_ExternalID__c);
			System.assertEquals(taOpp.AV_Opportunity__c, taskOppInsert.AV_Opportunity__c);
			System.assertEquals(taOpp.AV_Task__c, taskOppInsert.AV_Task__c);
			System.assertEquals(taOpp.AV_OrigenApp__c, taskOppInsert.AV_OrigenApp__c);
			System.assertEquals(taOpp.AV_Commentary__c, taskOppInsert.AV_Commentary__c);
			System.assertEquals(taOpp.AV_Concepto1__c, taskOppInsert.AV_Concepto1__c);
			System.assertEquals(taOpp.AV_Concepto2__c, taskOppInsert.AV_Concepto2__c);
			System.assertEquals(taOpp.AV_Concepto3__c, taskOppInsert.AV_Concepto3__c);
			System.assertEquals(taOpp.AV_Concepto4__c, taskOppInsert.AV_Concepto4__c);
			System.assertEquals(taOpp.AV_Concepto5__c, taskOppInsert.AV_Concepto5__c);
			System.assertEquals(taOpp.AV_Entity__c, taskOppInsert.AV_Entity__c);
			System.assertEquals(taOpp.AV_FeeAmount__c, taskOppInsert.AV_FeeAmount__c);
			System.assertEquals(taOpp.AV_Gestor__c, taskOppInsert.AV_Gestor__c);
			System.assertEquals(taOpp.AV_HoldingAnotherEntity__c, taskOppInsert.AV_HoldingAnotherEntity__c);
			System.assertEquals(taOpp.AV_Priority__c, taskOppInsert.AV_Priority__c);
			System.assertEquals(taOpp.AV_Stage__c, taskOppInsert.AV_Stage__c);
			System.assertEquals(taOpp.AV_Valor1__c, taskOppInsert.AV_Valor1__c);
			System.assertEquals(taOpp.AV_Valor2__c, taskOppInsert.AV_Valor2__c);
			System.assertEquals(taOpp.AV_Valor3__c, taskOppInsert.AV_Valor3__c);
			System.assertEquals(taOpp.AV_Valor4__c, taskOppInsert.AV_Valor4__c);
			System.assertEquals(taOpp.AV_Valor5__c, taskOppInsert.AV_Valor5__c);
			System.assertEquals(taOpp.AV_IncludeInPrioritizingCustomers__c, taskOppInsert.AV_IncludeInPrioritizingCustomers__c);
			System.assertEquals(taOpp.AV_Status__c, taskOppInsert.AV_Status__c);
			System.assertEquals(taOpp.AV_Channel__c, taskOppInsert.AV_Channel__c);
			System.assertEquals(taOpp.AV_AmountEuro__c, taskOppInsert.AV_AmountEuro__c);
			System.assertEquals(taOpp.AV_MarginEuro__c, taskOppInsert.AV_MarginEuro__c);
		}
        Test.stopTest();
	}

	@isTest
	public static void structureTaskInsertBackTest(){
        Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        Contact cnt = [SELECT ID FROM Contact WHERE AV_UsuarioAsociado__c = :userGestor.Id];
        Id taskc = [select av_task__c from task where AV_ExternalID__c = 'ID-0003'].AV_Task__C;
		System.runAs(userGestor){
			RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKPRIORIZADOR_RT);
			Task ta = new Task();
			ta.RecordTypeId = rt.Id;
			ta.Subject = 'Tarea';
            ta.WhoId = cnt.Id;
			ta.Status  = 'Open';
			ta.Priority = 'Normal';
            ta.ActivityDate = System.today().addDays(2);
            ta.ReminderDateTime = System.today().addDays(2);
			ta.OwnerId = userGestor.Id;
            ta.AV_ALVEN__c = 'alven';
			ta.Description = 'Prueba';
            ta.AV_Type__c = 'campotype';
            ta.AV_Task__c = taskc;
			ta.IsReminderSet = false;
			ta.AV_CodigoGestorAsignado__c = 'U0154221';
			ta.AV_Concepto1__c = 'Concepto1';
			ta.AV_Concepto2__c = 'Concepto2';
			ta.AV_ExternalID__c = 'U0009006';
			ta.AV_ConVenta__c = false;
			ta.AV_Tipo__c  = 'LT';
			ta.AV_Valor1__c = 'Valor';
			ta.AV_Valor2__c = 'Valor';
			ta.AV_Valor3__c = 'Valor';
			ta.AV_Valor4__c = 'Valor';
			ta.AV_Valor5__c = 'Valor';
			ta.AV_OrigenApp__c = 'Priorizador';
			ta.AV_PriorityTask__c = false;
			ta.AV_OrigenAct__c = 'AV_Priorizador';
			ta.AV_VisiblePorElClienteEnNow__c = false;
            ta.AV_BranchPhysicalMeet__c = '001-00615';
            ta.AV_ColorEtiqueta__c = 'rojo';
            ta.AV_DurationToNoticeToManager__c = 10;
            ta.AV_FechaFinAccionComercial__c = System.today() ;
            ta.AV_PrioritizingSort__c = 10;
            ta.AV_FechaInicioVigencia__c = System.today() ;
            ta.AV_Chanel__c = '001' ;
            ta.AV_PEA__c = 'www.peafalsa.com' ;
            ta.AV_Purpose__c = '001' ;
            ta.AV_IdDelActaMifid__c = 'campo id del acta midfid';
            ta.AV_CenterRtIndex__c = '00615-'+rt.Id;
            ta.AV_UrlsQR__c = 'www.urlfalsa.com';
			Task tskInsert = AV_ReportAppointment_Controller.structureTaskInsertBack(ta);
			System.assertEquals(ta.RecordTypeId, tskInsert.RecordTypeId);
		}
        Test.stopTest();
	}

	@isTest
	public static void createTaskOppTest(){
        Test.startTest();
		Account acc = [SELECT Id FROM Account LIMIT 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        System.runAs(userGcf) {
            List<Task> listTask = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c FROM Task WHERE AV_ExternalId__c = 'ID-0003' or AV_ExternalId__c = 'ID-0004' limit 2];
            listTask[1].AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            Opportunity opp = [SELECT Id, AV_PF__c, AV_PF__r.Name FROM Opportunity limit 1];
            listTask[0].Subject = opp.AV_PF__r.Name;
            Map<Id,AV_ReportAppointment_Controller.TaskEvent> headerActivitys = new Map<Id,AV_ReportAppointment_Controller.TaskEvent>();
            Map<String,String> mapProducNameId = new Map<String,String>();
            Map<String,String> mapProducIdOpp = new Map<String,String>();
            Map<String,Map<String,String>> opportunities = new Map<String,Map<String,String>>();
            AV_ReportAppointment_Controller.TaskEvent taskEvent = new AV_ReportAppointment_Controller.TaskEvent();
            taskEvent.idTaskEvent = listTask[0].Id;
            taskEvent.taskHeader = listTask[0].AV_Task__c;
            taskEvent.subject = opp.AV_PF__r.Name;
            taskEvent.activityDate = listTask[0].ActivityDate;
            taskEvent.origenApp = '';
            AV_ReportAppointment_Controller.TaskEvent taskEvent2 = new AV_ReportAppointment_Controller.TaskEvent();
            taskEvent.idTaskEvent = listTask[1].Id;
            taskEvent.taskHeader = listTask[1].AV_Task__c;
            taskEvent.subject = opp.AV_PF__r.Name;
            taskEvent.activityDate = listTask[1].ActivityDate;
            taskEvent.origenApp = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            headerActivitys.put(listTask[0].Id,taskEvent);
            headerActivitys.put(listTask[1].Id,taskEvent2);
            mapProducNameId.put(opp.AV_PF__r.Name,opp.AV_PF__c);
            mapProducIdOpp.put(opp.AV_PF__c,opp.Id);
            Map<String,String> mapOpp = new Map<String,String>();
            mapOpp.put('id',opp.Id);
            mapOpp.put('mainVinculed','true');
            opportunities.put(opp.Id, mapOpp);
            AV_ReportAppointment_Controller.TaskEventBack backLists = new AV_ReportAppointment_Controller.TaskEventBack();
            backLists.insertTasksDelete = new List<Task>();
            backLists.insertTaskOppDelete = new List<AV_CustomActivityOpportunity__c>();
            backLists.deleteIdTasksInsert = new List<String>();
            backLists.deleteIdEventInsert = new List<String>();
            backLists.deleteManageHistInsert = new List<String>();
            backLists.updateTaskUpdated = new List<Task>();
            backLists.mapNewHeader = new Map<String,String>();
            AV_ReportAppointment_Controller.TaskEventGet sendMethod = new AV_ReportAppointment_Controller.TaskEventGet();
            sendMethod.headerActivitys = headerActivitys;
            sendMethod.mapProducNameId = mapProducNameId;
            sendMethod.mapProducIdOpp = mapProducIdOpp;
            sendMethod.opportunities = opportunities;
            sendMethod.results = 'OK';
            sendMethod.listTaskChangeDate = new List<Task>();
            sendMethod.listTaskToDelete = new List<Task>();
            sendMethod.listTaskOpportunityDelete = new List<AV_CustomActivityOpportunity__c>();
            sendMethod.dataBack = backLists;
            String jsonSend = Json.serialize(sendMethod);
            String result = AV_ReportAppointment_Controller.createTaskOpp(jsonSend);
            System.assertEquals('OK', result);
        }
        Test.stopTest();
	}

	@isTest
	public static void searchProductTest(){
        Test.startTest();
		Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        // Product2 pro= [Select Id, Name, AV_ExternalID__c from Product2 WHERE AV_ExternalID__c = '50112' and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true];
		System.runAs(userGestor) {
			List<AV_LookupSearchResult> results = new List<AV_LookupSearchResult>();
			List<AV_LookupSearchResult> results2 = new List<AV_LookupSearchResult>();
            Product2 seeProd = [SELECT Id,Name FROM Product2 WHERE AV_ExternalID__c = '50116' and RecordType.DeveloperName = 'AV_PF' and AV_Nivel__c=null and AV_ExternalID__c!=null and AV_Visible__c = true LIMIT 1];
			List<String> listaNoEmpty = new List<String>();
			listaNoEmpty.add(seeProd.Id);
            List<Id> fixedSearchResults = new List<Id>();
            fixedSearchResults.add(seeProd.Id);
            Test.setFixedSearchResults(fixedSearchResults);
			results = AV_ReportAppointment_Controller.searchProduct(seeProd.Name,null, acc.Id);
			results2 = AV_ReportAppointment_Controller.searchProduct('No existe',listaNoEmpty, acc.Id);
			System.assertEquals(false,results.isEmpty(), 'searchProductTest');
            System.assertEquals(true,results2.isEmpty(), 'searchProductTest');
		}
        Test.stopTest();
	}

	@isTest
	public static void sendOppToGCFTest(){
        Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		List<Opportunity> listOpps = [SELECT Id FROM Opportunity];
		List<String> oppIds = new List<String>();
		for (Opportunity opp1 : listOpps) {
			oppIds.add(opp1.Id);
		}
        System.runAs(userGestor) {
            String result = AV_ReportAppointment_Controller.sendOppToGCF(oppIds);
			System.assertEquals('OK', result);
        }
        Test.stopTest();
	}
    
    @isTest
	public static void unWrappOpportunitiesInsertTest(){
        Test.startTest();
		Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		Opportunity opp = [SELECT Id,Name,AV_PF__c,CloseDate FROM Opportunity limit 1];
        Product2 product = [SELECT Id FROM Product2 WHERE AV_ExternalId__c = '50116' and AV_Nivel__c = null limit 1];
        Map<String,Map<Object,Object>> opportunities = new Map<String,Map<Object,Object>>();
        Map<Object,Object> mapOpp = new Map<Object,Object>();
        mapOpp.put('id','idProvisional01');
        mapOpp.put('validable',true);
        mapOpp.put('newPath',AV_AppConstants.OPP_STATUS_NOINTERE);
        mapOpp.put('Name',opp.Name);
        mapOpp.put('ProdId',product.Id);
        mapOpp.put('proximaGestion',String.valueOf(opp.CloseDate));
        mapOpp.put('expectativa',null);
        mapOpp.put('resolucion',null);
        mapOpp.put('importe','232,23');
        mapOpp.put('comentario','Comentario nuevo');
        mapOpp.put('tenencia','true');
        mapOpp.put('otraEntidad','Santander');
        mapOpp.put('fechaOtraEntidad',String.valueOf(opp.CloseDate));
        mapOpp.put('subProducto',null);
        mapOpp.put('margin','232,23');
        mapOpp.put('cuota','232,23');
        mapOpp.put('importeOtraEntidad','232,23');
        mapOpp.put('closedate',String.valueOf(opp.CloseDate));
        mapOpp.put('mainVinculed','true');
        mapOpp.put('isVinculed','true');
        mapOpp.put('agendado','false');
        opportunities.put('idProvisional01',mapOpp);
        System.runAs(userGestor) {
            AV_ReportAppointment_Controller.OppResulWrap result = AV_ReportAppointment_Controller.unWrappOpportunities(opportunities,acc.Id, true);
			System.assertEquals('OK', result.results);
            mapOpp.put('validable',false);
            result = AV_ReportAppointment_Controller.unWrappOpportunities(opportunities,acc.Id, true);
        }
        Test.stopTest();
	}
    
    @isTest
	public static void unWrappOpportunitiesUpdateTest(){
        Test.startTest();
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
        System.runAs(userGcf) {
            Opportunity opp = [SELECT Id,Name,AV_PF__c,AV_FechaProximoRecordatorio__c, OwnerId FROM Opportunity limit 1];
            Product2 subPro = [SELECT Id FROM Product2 WHERE AV_NombrePF__c = :opp.AV_PF__c limit 1];
            Map<String,Map<Object,Object>> opportunities = new Map<String,Map<Object,Object>>();
            Map<Object,Object> mapOpp = new Map<Object,Object>();
            mapOpp.put('id',opp.Id);
            mapOpp.put('validable',true);
            mapOpp.put('newPath',AV_AppConstants.OPP_STATUS_ENGESTION);
            mapOpp.put('Name',opp.Name);
            mapOpp.put('ProdId',opp.AV_PF__c);
            mapOpp.put('proximaGestion',String.valueOf(opp.AV_FechaProximoRecordatorio__c));
            mapOpp.put('expectativa','M');
            mapOpp.put('resolucion',null);
            mapOpp.put('importe','231,23');
            mapOpp.put('comentario','Nuevo comentario');
            mapOpp.put('tenencia',true);
            mapOpp.put('otraEntidad','Santander');
            mapOpp.put('fechaOtraEntidad',String.valueOf(Date.today()));
            mapOpp.put('subProducto',subPro.Id);
            mapOpp.put('margin','231,23');
            mapOpp.put('cuota','231,23');
            mapOpp.put('importeOtraEntidad','231,23');
            mapOpp.put('closedate',String.valueOf(opp.AV_FechaProximoRecordatorio__c));
            mapOpp.put('mainVinculed',true);
            mapOpp.put('isVinculed',true);
            mapOpp.put('agendado',false);
            opportunities.put(opp.Id,mapOpp);
            AV_ReportAppointment_Controller.OppResulWrap result = AV_ReportAppointment_Controller.unWrappOpportunities(opportunities,acc.Id, false);
			System.assertEquals('OK', result.results);
            mapOpp.put('validable',false);
            AV_ReportAppointment_Controller.unWrappOpportunities(opportunities,acc.Id, false);

        }
        Test.stopTest();
	}
    
	@isTest
	public static void updateBackReportTaskEventTest(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		List<Task> listTask = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c FROM Task WHERE AV_ExternalId__c = 'ID-0003' or AV_ExternalId__c = 'ID-0004' limit 2];
		Opportunity opp = [Select Id from Opportunity limit 1];
        Event eventoCliente = [Select Id,AccountId from Event limit 1];
        RecordType rtTaskIniciativa = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_TASK, AV_AppConstants.TASKINICIATIVA_RT);
        Task tarea = AV_TestHelper.createTareaWithRTSinInsert(userGestor, 'ID-0005', acc,rtTaskIniciativa);
		AV_CustomActivityOpportunity__c taOpp = AV_TestHelper.createTareaOportunidadSinInsert(opp, listTask[0].AV_Task__c);
        AV_ManagementHistory__c manaHis = AV_TestHelper.createManagementHistoryWithOwner(listTask[0],Date.today(),DateTime.now(),userGestor);
		listTask[1].ActivityDate = Date.today().addDays(4);
        AV_ReportAppointment_Controller.TaskEventBack backLists = new AV_ReportAppointment_Controller.TaskEventBack();
        List<Task> insertTasksDelete = new List<Task>();
        insertTasksDelete.add(tarea);
        List<AV_CustomActivityOpportunity__c> insertTaskOppDelete = new List<AV_CustomActivityOpportunity__c>();
        insertTaskOppDelete.add(taOpp);
        List<String> deleteIdTasksInsert = new List<String>();
        deleteIdTasksInsert.add(listTask[0].Id);
        List<String> deleteIdEventInsert = new List<String>();
        deleteIdEventInsert.add(eventoCliente.Id);
        List<String> deleteManageHistInsert = new List<String>();
        deleteManageHistInsert.add(manaHis.Id);
        List<Task> updateTaskUpdated = new List<Task>();
        updateTaskUpdated.add(listTask[1]);
        Map<String,String> mapNewHeader = new Map<String,String>();
        mapNewHeader.put('ID-0005', listTask[0].AV_Task__c);
        backLists.insertTasksDelete = insertTasksDelete;
        backLists.insertTaskOppDelete = insertTaskOppDelete;
        backLists.deleteIdTasksInsert = deleteIdTasksInsert;
        backLists.deleteIdEventInsert = deleteIdEventInsert;
        backLists.deleteManageHistInsert = deleteManageHistInsert;
        backLists.updateTaskUpdated = updateTaskUpdated;
        backLists.mapNewHeader = mapNewHeader;
        String jsonBackAll = JSON.serialize(backLists);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_DELCNT', 'OK'));
        System.runAs(userGestor) {
            String result = AV_ReportAppointment_Controller.updateBackReportTaskEvent(jsonBackAll);
			System.assertEquals(null, result);
        }
        Test.stopTest();
	}
    
    @isTest
	public static void processReportDataTaskTest(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		List<Opportunity> listOpp = [Select Id, Name, AV_PF__c, AV_IncludeInPrioritizingCustomers__c,AV_FechaProximoRecordatorio__c, StageName, AV_Potencial__c, Amount, CloseDate, AV_Cuota__c, AV_Resolucion__c, AV_AmountEuro__c, AV_Comentarios__c, AV_Tenencia__c, AV_Entidad__c, AV_FechaVencimiento__c,AV_MarginEuro__c, AV_ByProduct__c from Opportunity limit 3];
        Map<Object, Object> eventOrTsk = new Map<Object, Object>();
        eventOrTsk.put('type','Task');   
        eventOrTsk.put('typeTask','LMD');
        eventOrTsk.put('accountId',acc.Id);
        eventOrTsk.put('statusTask',AV_AppConstants.TASK_STATUS_PENDIENTE);
        Map<String,Map<Object,Object>> opportunities = new Map<String,Map<Object,Object>>();
        Map<Object,Object> mapOpp = new Map<Object,Object>();
        mapOpp.put('id',listOpp[0].Id);
        mapOpp.put('newPath',AV_AppConstants.OPP_STATUS_NOINTERE);
        mapOpp.put('Name',listOpp[0].Name);
        mapOpp.put('ProdId',listOpp[0].AV_PF__c);
        mapOpp.put('proximaGestion',String.valueOf(listOpp[0].CloseDate));
        mapOpp.put('expectativa','A');
        mapOpp.put('resolucion','O');
        mapOpp.put('importe','232,23');
        mapOpp.put('comentario','Comentario nuevo');
        mapOpp.put('tenencia','true');
        mapOpp.put('otraEntidad','Santander');
        mapOpp.put('fechaOtraEntidad',String.valueOf(listOpp[0].CloseDate));
        mapOpp.put('subProducto',null);
        mapOpp.put('margin','232,23');
        mapOpp.put('cuota','232,23');
        mapOpp.put('importeOtraEntidad','232,23');
        mapOpp.put('closedate',String.valueOf(listOpp[0].CloseDate));
        mapOpp.put('mainVinculed',false);
        mapOpp.put('isVinculed',true);
        mapOpp.put('agendado',false);
        opportunities.put(listOpp[0].Id,mapOpp);
        Map<Object,Object> mapOpp2 = new Map<Object,Object>();
        mapOpp2.put('id','idProvisional01');
        mapOpp2.put('newPath',AV_AppConstants.OPP_STATUS_NOINTERE);
        mapOpp2.put('Name',listOpp[1].Name);
        mapOpp2.put('ProdId',listOpp[1].AV_PF__c);
        mapOpp2.put('proximaGestion',String.valueOf(listOpp[1].CloseDate));
        mapOpp2.put('expectativa','A');
        mapOpp2.put('resolucion','O');
        mapOpp2.put('importe','232,23');
        mapOpp2.put('comentario','Comentario nuevo');
        mapOpp2.put('tenencia','true');
        mapOpp2.put('otraEntidad','Santander');
        mapOpp2.put('fechaOtraEntidad',String.valueOf(listOpp[1].CloseDate));
        mapOpp2.put('subProducto',null);
        mapOpp2.put('margin','232,23');
        mapOpp2.put('cuota','232,23');
        mapOpp2.put('importeOtraEntidad','232,23');
        mapOpp2.put('closedate',String.valueOf(listOpp[1].CloseDate));
        mapOpp2.put('mainVinculed',true);
        mapOpp2.put('isVinculed',true);
        mapOpp2.put('agendado',false);
        opportunities.put('idProvisional01',mapOpp2);
        List<String> opposId = new List<String>();
        opposId.add(listOpp[1].Id);
        Map<String,Opportunity> mapOldOpp = new Map<String,Opportunity>();
        mapOldOpp.put(listOpp[0].Id, listOpp[0]);
        System.runAs(userGestor) {
            Map<String,Map<Object,Object>> opportunitiesCopy = opportunities.clone();
            Map<String,Opportunity> mapOldOppCopy = mapOldOpp.clone();
            AV_ReportAppointment_Controller.TaskEventResult result = AV_ReportAppointment_Controller.processReportData(eventOrTsk, opportunities, mapOldOpp, opposId);
			System.assertEquals('OK', result.results);
            // mapOldOpp.put(listOpp[0].Id, listOpp[0]); 
            // mapOldOpp.put(listOpp[1].Id, listOpp[1]);
            listOpp[1].AV_IncludeInPrioritizingCustomers__c = false;
            mapOldOppCopy.put('idProvisional01',listOpp[1]);
            opportunitiesCopy.get('idProvisional01').put('newPath',AV_AppConstants.OPP_STATUS_ENGESTION); 
            opportunitiesCopy.get('idProvisional01').put('agendado',false); 
            result = AV_ReportAppointment_Controller.processReportData(eventOrTsk, opportunitiesCopy, mapOldOppCopy, null);
            listOpp[0].AV_IncludeInPrioritizingCustomers__c = true;
            Task t0 = [SELECT Id,Status,Priority,ActivityDate, AV_Task__c,AV_ExternalID__c FROM Task WHERE AV_ExternalID__c = 'ID-0002' LIMIT 1];  
            Task t = [SELECT Id,Status,Priority,ActivityDate, AV_Task__c,AV_ExternalID__c FROM Task WHERE AV_ExternalID__c = 'ID-0003' LIMIT 1];  
            Task t2 = [SELECT Id,Status,Priority,ActivityDate, AV_Task__c,AV_ExternalID__c FROM Task WHERE AV_ExternalID__c = 'ID-0004' LIMIT 1];  
            update new List<Task> {
                new Task(Id = t0.Id, AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF),
                new Task(Id = t.Id, AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF),
                new Task(Id = t2.Id, AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_CHECK_ON_OFF)
            };
            Map<Object,Object> closedOppo = mapOpp2.clone();
            listOpp[1].StageName = AV_AppConstants.OPP_STATUS_NOINTERE;
            closedOppo.put('id',listOpp[1].Id);
            mapOldOppCopy.put(listOpp[1].Id,listOpp[1]);
            opportunitiesCopy.put(listOpp[1].Id,closedOppo);
            insert new List<AV_CustomActivityOpportunity__c>{
                AV_TestHelper.createTareaOportunidadSinInsert(listOpp[0],t.AV_Task__c),
                AV_TestHelper.createTareaOportunidadSinInsert(listOpp[0],t2.AV_Task__c),
                AV_TestHelper.createTareaOportunidadSinInsert(listOpp[1],t0.AV_Task__c)
            };
            mapOldOppCopy.put(listOpp[0].Id,listOpp[0]);

            result = AV_ReportAppointment_Controller.processReportData(eventOrTsk, opportunitiesCopy, mapOldOppCopy, null);
        }
        Test.stopTest();
	}
    
    @isTest
	public static void processReportDataEventTest(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		List<Opportunity> listOpp = [Select Id, Name, AV_PF__c, AV_IncludeInPrioritizingCustomers__c,AV_FechaProximoRecordatorio__c, StageName, AV_Potencial__c, Amount, CloseDate, AV_Cuota__c, AV_Resolucion__c, AV_AmountEuro__c, AV_Comentarios__c, AV_Tenencia__c, AV_Entidad__c, AV_FechaVencimiento__c,AV_MarginEuro__c, AV_ByProduct__c from Opportunity limit 2];
        Account centro = [SELECT Id, CC_Numero_Oficina__c FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT limit 1];
        Contact gestor = [SELECT Id, Name, CC_CargoRepresentante__c FROM Contact WHERE CC_Matricula__c = 'U016129361923698126' and RecordType.DeveloperName='CIBE_Apoderado' and AccountId = :centro.Id LIMIT 1];
        List<Task> listTask = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c FROM Task WHERE AV_ExternalId__c = 'ID-0003' or AV_ExternalId__c = 'ID-0004' limit 2];
		Opportunity opp = [Select Id from Opportunity limit 1];
		AV_CustomActivityOpportunity__c taOpp = AV_TestHelper.createTareaOportunidadSinInsert(opp, listTask[0].AV_Task__c);
        Map<Object, Object> eventOrTsk = new Map<Object, Object>();
        eventOrTsk.put('type','Event');   
        eventOrTsk.put('typeEvent','CTO');
        eventOrTsk.put('accountId',acc.Id);
        eventOrTsk.put('comment','Comentario Nuevo');
        eventOrTsk.put('activityDateTime',DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
        eventOrTsk.put('duracion','30');
        eventOrTsk.put('memorableInterview',false);
        eventOrTsk.put('office',centro.CC_Numero_Oficina__c);
        eventOrTsk.put('location',centro.CC_Numero_Oficina__c);
        eventOrTsk.put('contactPerson',gestor.Id);
        eventOrTsk.put('comercial',true);
        Map<String,Map<Object,Object>> opportunities = new Map<String,Map<Object,Object>>();
        Map<Object,Object> mapOpp = new Map<Object,Object>();
        mapOpp.put('id',listOpp[0].Id);
        mapOpp.put('newPath',AV_AppConstants.OPP_STATUS_NOINTERE);
        mapOpp.put('Name',listOpp[0].Name);
        mapOpp.put('ProdId',listOpp[0].AV_PF__c);
        mapOpp.put('proximaGestion',String.valueOf(listOpp[0].CloseDate));
        mapOpp.put('expectativa','A');
        mapOpp.put('resolucion','O');
        mapOpp.put('importe','232,23');
        mapOpp.put('comentario','Comentario nuevo');
        mapOpp.put('tenencia','true');
        mapOpp.put('otraEntidad','Santander');
        mapOpp.put('fechaOtraEntidad',String.valueOf(listOpp[0].CloseDate));
        mapOpp.put('subProducto',null);
        mapOpp.put('margin','232,23');
        mapOpp.put('cuota','232,23');
        mapOpp.put('importeOtraEntidad','232,23');
        mapOpp.put('closedate',String.valueOf(listOpp[0].CloseDate));
        mapOpp.put('mainVinculed',false);
        mapOpp.put('isVinculed',true);
        mapOpp.put('agendado',false);
        opportunities.put(listOpp[0].Id,mapOpp);
        Map<Object,Object> mapOpp2 = new Map<Object,Object>();
        mapOpp2.put('id','idProvisional01');
        mapOpp2.put('newPath',AV_AppConstants.OPP_STATUS_ENGESTION);
        mapOpp2.put('Name',listOpp[1].Name);
        mapOpp2.put('ProdId',listOpp[1].AV_PF__c);
        mapOpp2.put('proximaGestion',String.valueOf(listOpp[1].CloseDate));
        mapOpp2.put('expectativa','A');
        mapOpp2.put('resolucion',null);
		mapOpp2.put('importe','232,23');
        mapOpp2.put('comentario','Comentario nuevo');
		mapOpp2.put('tenencia','true');
        mapOpp2.put('otraEntidad','Santander');
        mapOpp2.put('fechaOtraEntidad',String.valueOf(listOpp[1].CloseDate));
        mapOpp2.put('subProducto',null);
        mapOpp2.put('margin','232,23');
        mapOpp2.put('cuota','232,23');
        mapOpp2.put('importeOtraEntidad','232,23');
        mapOpp2.put('closedate',String.valueOf(listOpp[1].CloseDate));
        mapOpp2.put('mainVinculed',true);
        mapOpp2.put('isVinculed',true);
        mapOpp2.put('agendado',false);
        opportunities.put('idProvisional01',mapOpp2);
        List<String> opposId = new List<String>();
        opposId.add(listOpp[1].Id);
        Map<String,Opportunity> mapOldOpp = new Map<String,Opportunity>();
        mapOldOpp.put(listOpp[0].Id, listOpp[0]);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
        System.runAs(userGestor) {
            AV_ReportAppointment_Controller.TaskEventResult result = AV_ReportAppointment_Controller.processReportData(eventOrTsk, opportunities, mapOldOpp, opposId);
			System.assertEquals('OK', result.results);
        }
        Test.stopTest();
	} 
}