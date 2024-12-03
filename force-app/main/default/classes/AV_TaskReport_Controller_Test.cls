/********************************************************************************************************************
 Name:	  AV_TaskReport_Controller_Test
 Copyright © 2023  CaixaBank
 -----------------------------------------------------------------------------------------------------------------------
 Proposito: Gives test support to AV_TaskReport_Controller
 -----------------------------------------------------------------------------------------------------------------------
 Historial
 - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 VERSION		USER_STORY			AUTHOR				DATE			Description
 1.0			US602653         	Sandra Gómez    	17/10/2023		Init version
 *********************************************************************************************************************/
@isTest
public with sharing class AV_TaskReport_Controller_Test {
	@TestSetup
	static void setup(){
		User userCli = [Select Id from User where Profile.Name = 'API Only' and Alias = 'FC-TF9' and IsActive = true limit 1];
		User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		User userGestor = AV_TestHelper.createUser('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
        AV_TestHelper.insertNeededPermissions(userGestor);
		AV_TestHelper.insertPermissionSet(userGestor.Id,AV_AppConstants.PS_OLDHOMETASK); 
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
			Contact contact = AV_TestHelper.createEmployeeSinInsert(listAccounts[0], userGestor, 'U01545454');
			contact.CC_Numero_Documento__c = '9446386T';
			contact.OwnerId = userGestor.Id;
			contact.CC_Matricula__c = '6714471MAT';
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
            taskIniciativa.ActivityDate = Date.today();
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

	@isTest
	public static void getTaskDataTest(){
		Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		Task tarea = [SELECT Id FROM Task WHERE AV_ExternalId__c = 'ID-0003' limit 1];
		System.runAs(userGestor){
			AV_TaskReport_Controller.TaskWrapper result  = AV_TaskReport_Controller.getTaskData((String)tarea.Id);
			System.assertNotEquals(new AV_TaskReport_Controller.TaskWrapper(), result);
		}
		Test.stopTest();
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
			results = AV_TaskReport_Controller.searchOffice(centro.Name.substring(0, 4), null);
			results2 = AV_TaskReport_Controller.searchOffice('Acc test', selectedId);
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
			results = AV_TaskReport_Controller.searchContact(gestor.Name, null, acc.Id);
			results2 = AV_TaskReport_Controller.searchContact('Gestor test', selectedId, acc.Id);
			System.assertEquals(false,results.isEmpty(), 'searchContactTest');
		}
		Test.stopTest();
	}

	@isTest
	public static void insertOrUpdateOppInsertTest(){
		Test.startTest();
		Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		setupOpportunities();
		Opportunity opp = [SELECT Id,Name,AV_PF__c,CloseDate FROM Opportunity LIMIT 1];
		Product2 product = [SELECT Id FROM Product2 WHERE AV_ExternalId__c = '50112' and AV_Nivel__c = null limit 1];
		Map<String,AV_TaskReport_Controller.OpportunityReport> opportunities = new Map<String,AV_TaskReport_Controller.OpportunityReport>();
		AV_TaskReport_Controller.OpportunityReport mapOpp = new AV_TaskReport_Controller.OpportunityReport();
		mapOpp.id = 'idProvisional01';
		mapOpp.newPath = AV_AppConstants.OPP_STATUS_NOINTERE;
		mapOpp.Name = opp.Name;
		mapOpp.ProdId = product.Id;
		mapOpp.proximaGestion = opp.CloseDate;
		mapOpp.expectativa = null;
		mapOpp.resolucion = null;
		mapOpp.importe = '232,23';
		mapOpp.comentario = 'Comentario nuevo';
		mapOpp.tenencia = true;
		mapOpp.otraEntidad = 'Santander';
		mapOpp.fechaOtraEntidad = opp.CloseDate;
		mapOpp.subProducto = null;
		mapOpp.margin = '232,23';
		mapOpp.cuota = '232,23';
		mapOpp.importeOtraEntidad = '232,23';
		mapOpp.closedate = opp.CloseDate;
		mapOpp.mainVinculed = true;
		mapOpp.isVinculed = true;
		mapOpp.agendado = false;
		mapOpp.validable = true;
		opportunities.put('idProvisional01',mapOpp);
		System.runAs(userGestor) {
            SObjectAccessDecision securityDecision = Security.stripInaccessible( AccessType.READABLE, [Select id, lastmodifieddate, AV_UsuarioAsociado__c From Contact Where RecordType.DeveloperName = 'CC_Empleado']);
			AV_TaskReport_Controller.OppResulWrap result = AV_TaskReport_Controller.insertOrUpdateOpp(opportunities,acc.Id, true);
			System.assertEquals('OK', result.results);
		}
		Test.stopTest();
	}

	@isTest
	public static void insertOrUpdateOppUpdateTest(){
		Test.startTest();
		User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		Contact contact = [SELECT ID FROM CONTACT WHERE CC_Numero_Documento__c = '9446386T'];
		Product2 prodPF4 = [Select Id,AV_ExternalID__c FROM Product2 LIMIT 1];
		RecordType rtIniciativa = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
		Opportunity opp = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(acc, contact, prodPF4, rtIniciativa,'12312131230', userGestor.Id);
		insert opp;
		System.runAs(userGcf) {
			Product2 subPro = [SELECT Id FROM Product2 WHERE AV_NombrePF__c = :opp.AV_PF__c limit 1];
			Map<String,AV_TaskReport_Controller.OpportunityReport> opportunities = new Map<String,AV_TaskReport_Controller.OpportunityReport>();
			AV_TaskReport_Controller.OpportunityReport mapOpp = new AV_TaskReport_Controller.OpportunityReport();
			mapOpp.id = opp.Id;
			mapOpp.newPath = AV_AppConstants.OPP_STATUS_ENGESTION;
			mapOpp.Name = opp.Name;
			mapOpp.ProdId = opp.AV_PF__c;
			mapOpp.proximaGestion = opp.AV_FechaProximoRecordatorio__c;
			mapOpp.expectativa = 'M';
			mapOpp.resolucion = null;
			mapOpp.importe = '231,23';
			mapOpp.comentario = 'Nuevo comentario';
			mapOpp.tenencia = true;
			mapOpp.otraEntidad = 'Santander';
			mapOpp.fechaOtraEntidad = Date.today();
			mapOpp.subProducto = subPro.Id;
			mapOpp.margin = '231,23';
			mapOpp.cuota = '231,23';
			mapOpp.importeOtraEntidad = '231,23';
			mapOpp.closedate = opp.AV_FechaProximoRecordatorio__c;
			mapOpp.mainVinculed = true;
			mapOpp.isVinculed = true;
			mapOpp.agendado = false;
			mapOpp.validable = true;
			opportunities.put(opp.Id,mapOpp);
			AV_TaskReport_Controller.OppResulWrap result = AV_TaskReport_Controller.insertOrUpdateOpp(opportunities,acc.Id, false);
			System.assertEquals('OK', result.results);
		}
		Test.stopTest();
	}

	@isTest
	public static void eventAndTaskProcessTest(){
		Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		List<Task> listTask = [SELECT Id, AccountId, AV_ExternalId__c  FROM Task WHERE AV_ExternalId__c in ('ID-0001', 'ID-0002', 'ID-0003')];
		Task tareaIni;
		Task tareaAviso;
		Task tareaPrio;
		for (Task ta : listTask) {
			if (ta.AV_ExternalId__c == 'ID-0003') {
				tareaIni = ta;
			} else if (ta.AV_ExternalId__c == 'ID-0002') {
				tareaAviso = ta;
			} else if (ta.AV_ExternalId__c == 'ID-0001') {
				tareaPrio = ta;
			}
		}
		Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		
		setupOpportunities();
		List<Opportunity> listOpp = [Select Id, Name, AV_PF__c, AV_IncludeInPrioritizingCustomers__c,AV_FechaProximoRecordatorio__c, StageName, AV_Potencial__c, Amount, CloseDate, AV_Cuota__c, AV_Resolucion__c, AV_AmountEuro__c, AV_Comentarios__c, AV_Tenencia__c, AV_Entidad__c, AV_FechaVencimiento__c,AV_MarginEuro__c, AV_ByProduct__c from Opportunity limit 4];
		Account centro = [SELECT Id, CC_Numero_Oficina__c FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT limit 1];
		Contact gestor = [SELECT Id, Name, CC_CargoRepresentante__c FROM Contact WHERE CC_Matricula__c = 'U016129361923698126' and RecordType.DeveloperName='CIBE_Apoderado' and AccountId = :centro.Id LIMIT 1];
		AV_TaskReport_Controller.EventReport evento = new AV_TaskReport_Controller.EventReport();
		evento.type = 'Event';
		evento.typeEvent = 'CTO';
		evento.duracion = 30;
		evento.activityDateTime = DateTime.now();
		evento.accountId = acc.Id;
		evento.memorableInterview = false;
		evento.comercial = true;
		evento.comment = 'Comentario Nuevo';
		evento.office = centro.CC_Numero_Oficina__c;
		evento.contactPerson = gestor.Id;
		evento.location = centro.CC_Numero_Oficina__c;
		AV_TaskReport_Controller.TaskReport tarea = new AV_TaskReport_Controller.TaskReport();
		tarea.type = 'Task';
		tarea.idTask = tareaIni.Id;
		tarea.typeTask = 'LMD';
		tarea.statusTask = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
		tarea.accountId = tareaIni.AccountId;
		tarea.ownerid = userGestor.Id;
		Map<String,AV_TaskReport_Controller.TaskBlockReport> mapTaskBlock = new Map<String,AV_TaskReport_Controller.TaskBlockReport>();
		AV_TaskReport_Controller.TaskBlockReport taskBlock = new AV_TaskReport_Controller.TaskBlockReport();
		taskBlock.id = tareaAviso.Id;
		taskBlock.status = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
		taskBlock.comment = 'Nuevo comentario';
		AV_TaskReport_Controller.TaskBlockReport taskBlock2 = new AV_TaskReport_Controller.TaskBlockReport();
		taskBlock2.id = tareaPrio.Id;
		taskBlock2.status = AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO;
		taskBlock2.comment = 'Nuevo comentario';
		mapTaskBlock.put(tareaAviso.Id,taskBlock);
		mapTaskBlock.put(tareaPrio.Id,taskBlock2);
		Map<String,AV_TaskReport_Controller.OpportunityReport> opportunities = new Map<String,AV_TaskReport_Controller.OpportunityReport>();
		AV_TaskReport_Controller.OpportunityReport mapOpp = new AV_TaskReport_Controller.OpportunityReport();
		mapOpp.id = listOpp[0].Id;
        mapOpp.newPath = AV_AppConstants.OPP_STATUS_NOINTERE;
        mapOpp.Name = listOpp[0].Name;
        mapOpp.ProdId = listOpp[0].AV_PF__c;
        mapOpp.proximaGestion = listOpp[0].CloseDate;
        mapOpp.expectativa = 'A';
        mapOpp.resolucion = 'O';
        mapOpp.importe = '232,23';
        mapOpp.comentario = 'Comentario nuevo';
        mapOpp.tenencia = true;
        mapOpp.otraEntidad = 'Santander';
        mapOpp.fechaOtraEntidad = listOpp[0].CloseDate;
        mapOpp.subProducto = null;
        mapOpp.margin = '232,23';
        mapOpp.cuota = '232,23';
        mapOpp.importeOtraEntidad = '232,23';
        mapOpp.closedate = listOpp[0].CloseDate;
        mapOpp.mainVinculed = false;
        mapOpp.isVinculed = true;
        mapOpp.agendado = false;
		mapOpp.validable = true;
        opportunities.put(listOpp[0].Id,mapOpp);
        AV_TaskReport_Controller.OpportunityReport mapOpp2 = new AV_TaskReport_Controller.OpportunityReport();
        mapOpp2.id = 'idProvisional01';
        mapOpp2.newPath = AV_AppConstants.OPP_STATUS_ENGESTION;
        mapOpp2.Name = listOpp[1].Name;
        mapOpp2.ProdId = listOpp[1].AV_PF__c;
        mapOpp2.proximaGestion = listOpp[1].CloseDate;
        mapOpp2.expectativa = 'A';
        mapOpp2.resolucion = null;
		mapOpp2.importe = '232,23';
        mapOpp2.comentario = 'Comentario nuevo';
		mapOpp2.tenencia = true;
        mapOpp2.otraEntidad = 'Santander';
        mapOpp2.fechaOtraEntidad = listOpp[1].CloseDate;
        mapOpp2.subProducto = null;
        mapOpp2.margin = '232,23';
        mapOpp2.cuota = '232,23';
        mapOpp2.importeOtraEntidad = '232,23';
        mapOpp2.closedate = listOpp[1].CloseDate;
        mapOpp2.mainVinculed = true;
        mapOpp2.isVinculed = true;
        mapOpp2.agendado = false;
		mapOpp2.validable = true;
        opportunities.put('idProvisional01',mapOpp2);
        AV_TaskReport_Controller.OpportunityReport mapOpp3 = new AV_TaskReport_Controller.OpportunityReport();
		mapOpp3.id = listOpp[2].Id;
        mapOpp3.newPath = AV_AppConstants.OPP_STATUS_ENGESTION;
        mapOpp3.Name = listOpp[2].Name;
        mapOpp3.ProdId = listOpp[2].AV_PF__c;
        mapOpp3.proximaGestion = listOpp[2].CloseDate;
        mapOpp3.expectativa = 'A';
        mapOpp3.resolucion = 'O';
        mapOpp3.importe = '232,23';
        mapOpp3.comentario = 'Comentario nuevo';
        mapOpp3.tenencia = true;
        mapOpp3.otraEntidad = 'Santander';
        mapOpp3.fechaOtraEntidad = listOpp[2].CloseDate;
        mapOpp3.subProducto = null;
        mapOpp3.margin = '232,23';
        mapOpp3.cuota = '232,23';
        mapOpp3.importeOtraEntidad = '232,23';
        mapOpp3.closedate = listOpp[2].CloseDate;
        mapOpp3.mainVinculed = false;
        mapOpp3.isVinculed = true;
        mapOpp3.agendado = false;
		mapOpp3.validable = true;
        opportunities.put(listOpp[2].Id,mapOpp3);
        AV_TaskReport_Controller.OpportunityReport mapOpp4 = new AV_TaskReport_Controller.OpportunityReport();
		mapOpp4.id = listOpp[3].Id;
        mapOpp4.newPath = AV_AppConstants.OPP_STATUS_ENGESTION;
        mapOpp4.Name = listOpp[3].Name;
        mapOpp4.ProdId = listOpp[3].AV_PF__c;
        mapOpp4.proximaGestion = listOpp[3].CloseDate;
        mapOpp4.expectativa = 'A';
        mapOpp4.resolucion = 'O';
        mapOpp4.importe = '232,23';
        mapOpp4.comentario = 'Comentario nuevo';
        mapOpp4.tenencia = true;
        mapOpp4.otraEntidad = 'Santander';
        mapOpp4.fechaOtraEntidad = listOpp[3].CloseDate;
        mapOpp4.subProducto = null;
        mapOpp4.margin = '232,23';
        mapOpp4.cuota = '232,23';
        mapOpp4.importeOtraEntidad = '232,23';
        mapOpp4.closedate = listOpp[3].CloseDate;
        mapOpp4.mainVinculed = false;
        mapOpp4.isVinculed = true;
        mapOpp4.agendado = false;
		mapOpp4.validable = true;
        opportunities.put(listOpp[3].Id,mapOpp4);
		List<String> opposId = new List<String>();
        opposId.add(listOpp[1].Id);
        Map<String,Opportunity> mapOldOpp = new Map<String,Opportunity>();
        mapOldOpp.put(listOpp[0].Id, listOpp[0]);
        mapOldOpp.put(listOpp[2].Id, listOpp[2]);
        mapOldOpp.put(listOpp[3].Id, listOpp[3]);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		System.runAs(userGestor){
			AV_TaskReport_Controller.ResultEventTask result = AV_TaskReport_Controller.eventAndTaskProcess(evento, tarea, mapTaskBlock, opportunities, mapOldOpp, opposId);
			System.assertEquals('OK', result.result);
		}
		Test.stopTest();
	}
    
    @isTest
	public static void eventAndTaskProcessWithOutOppTest(){
		Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' limit 1];
		List<Task> listTask = [SELECT Id, AccountId, AV_ExternalId__c  FROM Task WHERE AV_ExternalId__c in ('ID-0001', 'ID-0002', 'ID-0003')];
		Task tareaIni;
		Task tareaAviso;
		Task tareaPrio;
		for (Task ta : listTask) {
			if (ta.AV_ExternalId__c == 'ID-0003') {
				tareaIni = ta;
			} else if (ta.AV_ExternalId__c == 'ID-0002') {
				tareaAviso = ta;
			} else if (ta.AV_ExternalId__c == 'ID-0001') {
				tareaPrio = ta;
			}
		}
		Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT limit 1];
		Account centro = [SELECT Id, CC_Numero_Oficina__c FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_CTO_RT limit 1];
		Contact gestor = [SELECT Id, Name, CC_CargoRepresentante__c FROM Contact WHERE CC_Matricula__c = 'U016129361923698126' and RecordType.DeveloperName='CIBE_Apoderado' and AccountId = :centro.Id LIMIT 1];
		AV_TaskReport_Controller.EventReport evento = new AV_TaskReport_Controller.EventReport();
		evento.type = 'Event';
		evento.typeEvent = 'CTO';
		evento.duracion = 30;
		evento.activityDateTime = DateTime.now();
		evento.accountId = acc.Id;
		evento.memorableInterview = false;
		evento.comercial = true;
		evento.comment = 'Comentario Nuevo';
		evento.office = centro.CC_Numero_Oficina__c;
		evento.contactPerson = gestor.Id;
		evento.location = centro.CC_Numero_Oficina__c;
		AV_TaskReport_Controller.TaskReport tarea = new AV_TaskReport_Controller.TaskReport();
		tarea.type = 'Task';
		tarea.idTask = tareaIni.Id;
		tarea.typeTask = 'LMD';
		tarea.statusTask = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
		tarea.accountId = tareaIni.AccountId;
		tarea.OwnerId = userGestor.Id;
		Map<String,AV_TaskReport_Controller.TaskBlockReport> mapTaskBlock = new Map<String,AV_TaskReport_Controller.TaskBlockReport>();
		AV_TaskReport_Controller.TaskBlockReport taskBlock = new AV_TaskReport_Controller.TaskBlockReport();
		taskBlock.id = tareaAviso.Id;
		taskBlock.status = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
		taskBlock.comment = 'Nuevo comentario';
		AV_TaskReport_Controller.TaskBlockReport taskBlock2 = new AV_TaskReport_Controller.TaskBlockReport();
		taskBlock2.id = tareaPrio.Id;
		taskBlock2.status = AV_AppConstants.GESTIONADO_NEGATIVA_ESTADO;
		taskBlock2.comment = 'Nuevo comentario';
		mapTaskBlock.put(tareaAviso.Id,taskBlock);
		mapTaskBlock.put(tareaPrio.Id,taskBlock2);
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT', 'OK'));
		System.runAs(userGestor){
			AV_TaskReport_Controller.ResultEventTask result = AV_TaskReport_Controller.eventAndTaskProcess(evento, tarea, mapTaskBlock, null, null, null);
			System.assertEquals('OK', result.result);
		}

		Test.stopTest();
	}

	@isTest
	public static void createTaskOppTest(){
        Test.startTest();
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT LIMIT 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' LIMIT 1];
		setupOpportunities();
		Opportunity opp = [SELECT Id,Name,AV_PF__c,AV_PF__r.Name,CloseDate FROM Opportunity LIMIT 1];
        System.runAs(userGcf) {
			Event evento = [SELECT Id, Subject, AV_Task__c, ActivityDate FROM Event LIMIT 1];
			Task tareaIni = [SELECT Id, AccountId, Subject, AV_Task__c, ActivityDate FROM Task WHERE AV_ExternalId__c = 'ID-0003' limit 1];
            List<Task> listTask = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c FROM Task WHERE AV_ExternalId__c = 'ID-0002' or AV_ExternalId__c = 'ID-0004' limit 2];
            listTask[1].AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            listTask[0].Subject = opp.AV_PF__r.Name;
            Map<Id,AV_TaskReport_Controller.TaskEvent> headerActivitys = new Map<Id,AV_TaskReport_Controller.TaskEvent>();
            Map<String,String> mapProducNameId = new Map<String,String>();
            Map<String,String> mapProducIdOpp = new Map<String,String>();
            Map<String,AV_TaskReport_Controller.OpportunityReport> opportunities = new Map<String,AV_TaskReport_Controller.OpportunityReport>();
            AV_TaskReport_Controller.TaskEvent taskEvent = new AV_TaskReport_Controller.TaskEvent();
            taskEvent.idTaskEvent = listTask[0].Id;
            taskEvent.taskHeader = listTask[0].AV_Task__c;
            taskEvent.subject = opp.AV_PF__r.Name;
            taskEvent.activityDate = listTask[0].ActivityDate;
            taskEvent.origenApp = '';
            AV_TaskReport_Controller.TaskEvent taskEvent2 = new AV_TaskReport_Controller.TaskEvent();
            taskEvent2.idTaskEvent = listTask[1].Id;
            taskEvent2.taskHeader = listTask[1].AV_Task__c;
            taskEvent2.subject = opp.AV_PF__r.Name;
            taskEvent2.activityDate = listTask[1].ActivityDate;
            taskEvent2.origenApp = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
			AV_TaskReport_Controller.TaskEvent taskEvent3 = new AV_TaskReport_Controller.TaskEvent();
            taskEvent3.idTaskEvent = evento.Id;
            taskEvent3.taskHeader = evento.AV_Task__c;
            taskEvent3.subject = opp.AV_PF__r.Name;
            taskEvent3.activityDate = evento.ActivityDate;
            taskEvent3.origenApp = '';
            AV_TaskReport_Controller.TaskEvent taskEvent4 = new AV_TaskReport_Controller.TaskEvent();
            taskEvent4.idTaskEvent = tareaIni.Id;
            taskEvent4.taskHeader = tareaIni.AV_Task__c;
            taskEvent4.subject = tareaIni.Subject;
            taskEvent4.activityDate = tareaIni.ActivityDate;
            taskEvent4.origenApp = '';
            headerActivitys.put(tareaIni.Id,taskEvent4);
            headerActivitys.put(listTask[0].Id,taskEvent);
            headerActivitys.put(listTask[1].Id,taskEvent2);
			headerActivitys.put(listTask[1].Id,taskEvent3);
            mapProducNameId.put(opp.AV_PF__r.Name,opp.AV_PF__c);
            mapProducIdOpp.put(opp.AV_PF__c,opp.Id);
            AV_TaskReport_Controller.OpportunityReport mapOpp = new AV_TaskReport_Controller.OpportunityReport();
            mapOpp.id = opp.Id;
            mapOpp.mainVinculed = true;
            opportunities.put(opp.Id, mapOpp);
            AV_TaskReport_Controller.TaskEventBack backLists = new AV_TaskReport_Controller.TaskEventBack();
            backLists.insertTasksDelete = new List<Task>();
            backLists.insertTaskOppDelete = new List<AV_CustomActivityOpportunity__c>();
            backLists.deleteIdTasksInsert = new List<String>();
            backLists.deleteIdEventInsert = new List<String>();
            backLists.deleteManageHistInsert = new List<String>();
            backLists.updateTaskUpdated = new List<Task>();
            backLists.mapNewHeader = new Map<String,String>();
            AV_TaskReport_Controller.ResultEventTask sendMethod = new AV_TaskReport_Controller.ResultEventTask();
            sendMethod.headerActivitys = headerActivitys;
            sendMethod.mapProducNameId = mapProducNameId;
            sendMethod.mapProducIdOpp = mapProducIdOpp;
            sendMethod.opportunities = opportunities;
            sendMethod.result = 'OK';
            sendMethod.listTaskChangeDate = new List<Task>();
            sendMethod.listTaskToDelete = new List<Task>();
            sendMethod.listTaskOpportunityDelete = new List<AV_CustomActivityOpportunity__c>();
            sendMethod.dataBack = backLists;
            String jsonSend = Json.serialize(sendMethod);
			AV_TaskReport_Controller.TaskReport tarea = new AV_TaskReport_Controller.TaskReport();
			tarea.type = 'Task';
			tarea.idTask = tareaIni.Id;
			tarea.typeTask = 'LMD';
			tarea.statusTask = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
			tarea.accountId = tareaIni.AccountId;
            String result = AV_TaskReport_Controller.createTaskOpp(jsonSend,tarea);
            System.assertEquals('OK', result);
        }
        Test.stopTest();
	}
    
    @isTest
	public static void createTaskOppWithOppTaskTest(){
        Test.startTest();
		
        User userGcf = [Select Id from User where Profile.Name = 'API Only' and Alias = 'AV-TF9' and IsActive = true limit 1];
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT LIMIT 1];
		setupOpportunities();
		List<Opportunity> opp = [SELECT Id, AV_PF__c, AV_PF__r.Name FROM Opportunity limit 2];
		
        System.runAs(userGcf) {
			Event evento = [SELECT Id, Subject, AV_Task__c, ActivityDate FROM Event LIMIT 1];
			Task tareaIni = [SELECT Id, AccountId, Subject, AV_Task__c, ActivityDate FROM Task WHERE AV_ExternalId__c = 'ID-0003' limit 1];
            List<Task> listTask = [SELECT Id, AV_Task__c, Subject, ActivityDate, AV_OrigenApp__c FROM Task WHERE AV_ExternalId__c = 'ID-0002' or AV_ExternalId__c = 'ID-0004' limit 2];
            listTask[1].AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
           	AV_CustomActivityOpportunity__c cao = AV_TestHelper.createTareaOportunidadSinInsert(opp[1],tareaIni.AV_Task__c);
            cao.AV_IsMain__c = true;
            insert cao;
            listTask[0].Subject = opp[0].AV_PF__r.Name;
            Map<Id,AV_TaskReport_Controller.TaskEvent> headerActivitys = new Map<Id,AV_TaskReport_Controller.TaskEvent>();
            Map<String,String> mapProducNameId = new Map<String,String>();
            Map<String,String> mapProducIdOpp = new Map<String,String>();
            Map<String,AV_TaskReport_Controller.OpportunityReport> opportunities = new Map<String,AV_TaskReport_Controller.OpportunityReport>();
            AV_TaskReport_Controller.TaskEvent taskEvent = new AV_TaskReport_Controller.TaskEvent();
            taskEvent.idTaskEvent = listTask[0].Id;
            taskEvent.taskHeader = listTask[0].AV_Task__c;
            taskEvent.subject = opp[0].AV_PF__r.Name;
            taskEvent.activityDate = listTask[0].ActivityDate;
            taskEvent.origenApp = '';
            AV_TaskReport_Controller.TaskEvent taskEvent2 = new AV_TaskReport_Controller.TaskEvent();
            taskEvent2.idTaskEvent = listTask[1].Id;
            taskEvent2.taskHeader = listTask[1].AV_Task__c;
            taskEvent2.subject = opp[0].AV_PF__r.Name;
            taskEvent2.activityDate = listTask[1].ActivityDate;
            taskEvent2.origenApp = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
			AV_TaskReport_Controller.TaskEvent taskEvent3 = new AV_TaskReport_Controller.TaskEvent();
            taskEvent3.idTaskEvent = evento.Id;
            taskEvent3.taskHeader = evento.AV_Task__c;
            taskEvent3.subject = opp[0].AV_PF__r.Name;
            taskEvent3.activityDate = evento.ActivityDate;
            taskEvent3.origenApp = '';
            AV_TaskReport_Controller.TaskEvent taskEvent4 = new AV_TaskReport_Controller.TaskEvent();
            taskEvent4.idTaskEvent = tareaIni.Id;
            taskEvent4.taskHeader = tareaIni.AV_Task__c;
            taskEvent4.subject = tareaIni.Subject;
            taskEvent4.activityDate = tareaIni.ActivityDate;
            taskEvent4.origenApp = '';
            headerActivitys.put(tareaIni.Id,taskEvent4);
            headerActivitys.put(listTask[0].Id,taskEvent);
            headerActivitys.put(evento.Id,taskEvent2);
			headerActivitys.put(listTask[1].Id,taskEvent3);
            mapProducNameId.put(opp[0].AV_PF__r.Name,opp[0].AV_PF__c);
            mapProducIdOpp.put(opp[0].AV_PF__c,opp[0].Id);
            AV_TaskReport_Controller.OpportunityReport mapOpp = new AV_TaskReport_Controller.OpportunityReport();
            mapOpp.id = opp[0].Id;
            mapOpp.mainVinculed = true;
            opportunities.put(opp[0].Id, mapOpp);
            AV_TaskReport_Controller.TaskEventBack backLists = new AV_TaskReport_Controller.TaskEventBack();
            backLists.insertTasksDelete = new List<Task>();
            backLists.insertTaskOppDelete = new List<AV_CustomActivityOpportunity__c>();
            backLists.deleteIdTasksInsert = new List<String>();
            backLists.deleteIdEventInsert = new List<String>();
            backLists.deleteManageHistInsert = new List<String>();
            backLists.updateTaskUpdated = new List<Task>();
            backLists.mapNewHeader = new Map<String,String>();
            AV_TaskReport_Controller.ResultEventTask sendMethod = new AV_TaskReport_Controller.ResultEventTask();
            sendMethod.headerActivitys = headerActivitys;
            sendMethod.mapProducNameId = mapProducNameId;
            sendMethod.mapProducIdOpp = mapProducIdOpp;
            sendMethod.opportunities = opportunities;
            sendMethod.result = 'OK';
            sendMethod.listTaskChangeDate = new List<Task>();
            sendMethod.listTaskToDelete = new List<Task>();
            sendMethod.listTaskOpportunityDelete = new List<AV_CustomActivityOpportunity__c>();
            sendMethod.dataBack = backLists;
            String jsonSend = Json.serialize(sendMethod);
			AV_TaskReport_Controller.TaskReport tarea = new AV_TaskReport_Controller.TaskReport();
			tarea.type = 'Task';
			tarea.idTask = tareaIni.Id;
			tarea.typeTask = 'LMD';
			tarea.statusTask = AV_AppConstants.GESTIONADO_POSITIVO_ESTADO;
			tarea.accountId = tareaIni.AccountId;
            String result = AV_TaskReport_Controller.createTaskOpp(jsonSend,tarea);
            System.assertEquals('OK', result);
        }
        Test.stopTest();
	}

	@isTest
    public static void unlinkOppTest() {
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalId__c = 'U01545454' LIMIT 1];        
        Account acc = [SELECT Id FROM Account WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT LIMIT 1];
        Task tsk = [SELECT Id,AV_Task__c FROM TASK WHERE AV_ExternalId__c = 'ID-0003' LIMIT 1];
		
		Test.startTest();
		update new AV_HeaderCustomActivity__c(Id = tsk.AV_Task__c, OwnerId = userGestor.Id);
        System.runAs(userGestor){
			Opportunity opp = AV_TestHelper.createOpportunity(acc);
			List<Id> oppIds= new List<Id>();
            oppIds.add(opp.Id);
            AV_CustomActivityOpportunity__c testCustomActivity = new AV_CustomActivityOpportunity__c(AV_Opportunity__c = opp.Id, AV_Task__c = tsk.AV_Task__c);
            insert testCustomActivity;
			
            AV_TaskReport_Controller.unlinkOpp(oppIds, tsk.AV_Task__c);
            List<AV_CustomActivityOpportunity__c> updatedOppTasks = [SELECT Id, OwnerId FROM AV_CustomActivityOpportunity__c WHERE Id = :testCustomActivity.Id];
            System.assertEquals(0, updatedOppTasks.size());
            Test.stopTest();
        }
		
    }

}