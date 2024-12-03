/**********************************************************************************************************************
Name:	  AV_OpportunityTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_OpportunityTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			Test Class		Eric Vázquez		08/10/2020		Init version
	1.1			US128581		Sandra Gómez		15/10/2020		Added validateSetFieldsFromOppTask method
	1.2			OwnerID			Carolina Alonso		22/10/2020		Add method 'processOwnerEAPGestor' to regularize the ownerIds
	1.3			US118509		Eric Vázquez		28/10/2020		Add test for validate delete Opportunity
	1.4			US130994		Jashanpreet			28/10/2020		Add test for telephoneContracting
	1.5			US138207		Esperanza Conde		16/11/2020		Add test for duplicate PF
	1.6			US158008		Eric Vázquez		16/11/2020		Cover new modify class
	1.7			US155069		Eric Vázquez		16/11/2020		Add test for delete/modify task associate to opp
	1.8			US160173		Sandra Gómez		02/02/2021		Add new method validateOpportunityValueNumeroDocumento
	1.9			US161442		Álvaro López		15/02/2021		Added fillClientProductTest method
	2.0			Test Class		Sandra Gómez		10/03/2021		Upload coverage add method updateTaskWithOppTest and modify createTaskOppWhenCheckTest
	2.1			US189148		Sandra Gómez		18/03/2021		Add methods updateTaskWithOppTestCheckOnChangeDateCheckOff updateTaskWithOppTestCheckOnChangeStageOpp
																	updateTaskWithOppTestCheckOnTaskCloseChangeDate updateTaskWithOppTestCheckOnTaskCloseOffOn
	2.2			FIX				David Rufo			01/07/2021		Fix method validation delete opp
	2.3			FIX				Sandra Gómez		26/08/2021		Fix product and owners gestor
	2.4			FIX	Confiden...	Víctor Santiago		05/10/2021		Added method validateSetConfidentiality
	2.5			US312995		Daniel Rodríguez	17/01/2022		Update method 
	2.6			AV_Query IT		Daniel Rodríguez	3/02/2022       Change AV_Query to SOQL for User, Account, Contact
	2.7			US325412		Víctor Santiago		08/03/2022      Added method validateCheckStageName
	2.8         US339508        Luis Fernández      30/03/2022      Created method validateUpdateCentro
	2.9         US332485        Luis Fernández      29/04/2022      Created validateUpdateCentroInsert method
	3.0			AV_QUERY_FIX	Luis Fernández		12/07/2022		Changed every AV_Query to SOQL
	3.1			DE63078			Víctor Santiago		26/07/2022		Added createTaskCheckOnOffTest
	3.2			US430868		Luis Fernández		19/08/2022		Fixed QualityClouds errors
	3.3			US451923		Patricia Solano		10/10/2022		Changed updateTaskWithOppTestCheckOnChangeDateCheckOff, 
																	updateTaskWithOppTest, updateTaskWithOppSecondTest, 
																	updateTaskWithOppThirdTest, updateTaskWithOppFourthTest methods
	3.4			FIX				Patricia Solano		10/01/2023		Modify methods updateTaskWithOppTest, updateTaskWithOppSecondTest, 
																	createTaskTest, updateTaskWithOppFourthTest to fix QualityClouds errors
	3.5			US498642     	Vladislav Lityagin 	19/01/2023		Setup has been modified reducing queries, added updateStageNameTest and createTaskCallMeTest
	3.6			FIX				Patricia Solano		20/04/2023		Modified to set run as, assertions and user creation
	3.7			FIX				Patricia Villacañas	17/05/2023		Modified to set run as
	3.8			Test			Sandra Gómez		16/08/2023		Change user and contact to method validateUpdateCentro and coverage
    3.9         US686939        Oscar Moreno        29/08/2023      Created updateCommentsHistoryTest method
	4.0			US546892		Sandra Gómez		21/09/2023		Add metthods validationsOpportunity1, validationsOpportunity2,validationsOpportunity3, validationsOpportunity4, validationsOpportunity5, validationByPassOpp and validationByPassOpp2
	4.1			Fix PMD Errors  Daniel Rodriguez    05/10/2023	    Modify method assignPropensityTest
***********************************************************************************************************************/
@isTest
public with sharing class AV_OpportunityTriggerHelper_Test {
	
	private static final String ERROR_MESSAGE		= Label.AV_deleteToOpp;
	private static final String ERROR_MESSAGE_PF	= Label.AV_PFDuplicate;
	
	@TestSetup
	static void setup(){
		Test.startTest();
		AV_TestHelper.activateLogger();
		AV_TestHelper.createPricebook2();
		AV_TestHelper.createForbiddenWords();
		List<AV_Propensity__c> listPropensity = new List<AV_Propensity__c>();
		AV_Propensity__c propensity = new AV_Propensity__c();
		propensity.Name = 'VP';
		propensity.AV_Propensity__c = 210;
		listPropensity.add(propensity);
		AV_Propensity__c propensity2 = new AV_Propensity__c();
		propensity2.Name = 'AV_CallMe';
		propensity2.AV_Propensity__c = 50;
		listPropensity.add(propensity2);
		AV_Propensity__c propensity3 = new AV_Propensity__c();
		propensity3.Name = 'X';
		propensity3.AV_Propensity__c = 260;
		insert listPropensity;
		Set<String> setRTs = new Set<String>{AV_AppConstants.OPPALERTACOM_RT,AV_AppConstants.OPPINICIATIVA_RT,AV_AppConstants.OPPLLAMADA_RT,AV_AppConstants.EMPLOYEE_RT,'AV_ProductoFichaCliente'};
		Map<String,RecordType> rtMap = AV_AppUtilities.getRecordTypeInMap(setRTs);
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		User userCli = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'FC-TF9' AND IsActive = true];
		System.runAs(userGcf){
			User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545454', 'AV_SistematicaComercial');
			userGestor.Email = 'gestor-test@test.com';
			User usrTest = AV_TestHelper.createUserSinInsert('Standard User','U01543678');
			List<User> listUserInsert = new List<User>();
			listUserInsert.add(userGestor);
			listUserInsert.add(usrTest);
			insert listUserInsert;
			List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
			List<PermissionSet> perSet = [SELECT Id FROM PermissionSet WHERE Name IN :new List<String>{ 'AV_GestorOperativa', 'AV_CustomMetadata' }];
			for(PermissionSet ps : perSet) {
				permissionSetList.add(
					new PermissionSetAssignment(
						AssigneeId = userGestor.Id, 
						PermissionSetId = ps.Id
				));
			}
			if(!permissionSetList.isEmpty()) {
				insert permissionSetList;
			}
		}
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
			User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
			User usrTest = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01543678' AND IsActive = true];
			Contact conTest = AV_TestHelper.createEmployeeSinInsert2(cenTest, userGestor, rtMap.get('Empleado'));
			Contact conTest2 = AV_TestHelper.createEmployeeSinInsert2(cenTest, userGcf, rtMap.get('Empleado'));
			Contact conTest3 = AV_TestHelper.createEmployeeSinInsert2(cenTest, usrTest, rtMap.get('Empleado'),'U01543678',userGestor);
			conTest2.FirstName = 'Empleado2';
			conTest3.FirstName = 'Empleado3';
			List<Contact> listContactInsert = new List<Contact>();
			listContactInsert.add(conTest);
			listContactInsert.add(conTest2);
			listContactInsert.add(conTest3);
			insert listContactInsert;
			List<Product2> prodsToInsert = new List<Product2>();
			Product2 prodPF = AV_TestHelper.createProductSinInsert(null,null,null);
			Product2 prodPF2 = AV_TestHelper.createProductSinInsert(null,null,'50113');
			Product2 prodPF3 = AV_TestHelper.createProductSinInsert(null,null,'50114');
			Product2 prodPF4 = AV_TestHelper.createProductSinInsert(null,null,'50115');
			prodsToInsert.add(prodPF);
			prodsToInsert.add(prodPF2);
			prodsToInsert.add(prodPF3);
			prodsToInsert.add(prodPF4);
			insert prodsToInsert;
			Test.stopTest();
			Opportunity opp = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest, conTest, prodPF4, rtMap.get('Iniciativa'), '00000002', userGestor.Id);
			Opportunity opp1 = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(accTest, conTest, prodPF, rtMap.get('Alerta Comercial'), '00000001', userGestor.Id);
			Opportunity opp2 = AV_TestHelper.createOpportunityIniciativaWithChecktPrioritySinInsert2(accTest, conTest2, prodPF2, rtMap.get('Iniciativa'), '83489', userGestor.Id);
			Opportunity opp3 = AV_TestHelper.createOpportunityIniciativaWithChecktPrioritySinInsert2(accTest, conTest3, prodPF3, rtMap.get('Iniciativa'), '83488', userGestor.Id);
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
			listOpportunityInsert.add(opp);
			listOpportunityInsert.add(opp1);
			listOpportunityInsert.add(opp2);
			listOpportunityInsert.add(opp3);
			listOpportunityInsert.add(oppCallMe);
			insert listOpportunityInsert;
			AV_ProductExperience__c prodExp = new AV_ProductExperience__c();
			prodExp.AV_ExternalID__c = 'BPA004_50003';
			prodExp.AV_ProductoFicha__c = prodPF.Id;
			insert prodExp;
			AV_ProductClient__c prodCliente = new AV_ProductClient__c();
			prodCliente.RecordTypeId = rtMap.get('ProductoFicha Cliente').Id;
			prodCliente.AV_Activo__c = true;
			prodCliente.AV_TenenciaProducto__c = '1';
			prodCliente.AV_Potencialidad__c = 'S';
			prodCliente.AV_ProductoFicha__c = prodExp.Id;
			prodCliente.AV_Cliente__c = accTest.Id;
			insert prodCliente;
			Task task = AV_TestHelper.createTareaExternalIdWithCustomer(userGestor, 'ID-0001', accTest);
			Task taskRetri = [SELECT AV_Task__c FROM Task WHERE Id = :task.Id LIMIT 1];
			update new AV_HeaderCustomActivity__c( Id = taskRetri.AV_Task__c,OwnerId = userGestor.Id);
		}
	}

	@isTest
	private static void validateSetFieldsFromOppTask() {
	   	User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		List<Opportunity> listOpp = [SELECT Id,Name FROM Opportunity WHERE RecordType.DeveloperName='AV_Iniciativa' LIMIT 1];
		Task tarea = [SELECT Id FROM Task WHERE AV_ExternalID__c = 'ID-0001'  LIMIT 1];
		List<Task> listTask = [SELECT AV_Task__c  FROM Task WHERE Id = :tarea.id LIMIT 1];
		AV_CustomActivityOpportunity__c oppTask = new AV_CustomActivityOpportunity__c(Name='Prueba Tarea Oportunidad', AV_Task__c=listTask[0].AV_Task__c, AV_Opportunity__c=listOpp[0].id, ownerId = userGcf.Id);
		insert oppTask;
		Test.startTest();
			System.runAs(userGcf){
				listOpp[0].Name='Prueba Opportunity Cambio';
				update listOpp;
			}
		Test.stopTest();
		List<AV_CustomActivityOpportunity__c> listOppTask = [SELECT Id,Name,AV_Opportunity__c FROM AV_CustomActivityOpportunity__c WHERE Id = :oppTask.id];
		System.assertEquals(listOpp[0].Name, listOppTask[0].Name, 'El name de oportunity es '+listOpp[0].Name+' y el name de tarea oportunidad es '+listOppTask[0].Name+' y deberian ser iguales.');
	}

	/**
	 * Execute the Trigger class (AV_Opportunity_BU_TRHan) and check the OwnerId
	 */
	@isTest
	private static void executeOpportunityTriggerUpdatingGestor() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		Test.startTest();
		Opportunity oppCreadoOld = [SELECT Id,AV_Gestor__c,AV_Gestor__r.AV_UsuarioAsociado__c FROM Opportunity LIMIT 1];
		Contact empleado = [SELECT Id FROM Contact WHERE FirstName = 'Empleado2' LIMIT 1];
		System.runAs(userGcf){
			oppCreadoOld.AV_Gestor__c = empleado.Id;
			Database.update(oppCreadoOld);
		}
		Opportunity oppUpdated = [SELECT AV_Gestor__c FROM Opportunity WHERE Id = :oppCreadoOld.Id];
		Test.stopTest();
		System.assertEquals(empleado.Id, oppUpdated.AV_Gestor__c);
	}
	
	 /**
	 * Execute the class (AV_Opportunity_AU_TRHan) and insert TelephoneContracting event GCF 
	 */
	@isTest
	public static void testSyncTelephoneContracting() {
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Opportunity opp = [SELECT Id, OwnerId, AccountId,AV_ModificacionTelefonica__c,AV_Contrato__c FROM Opportunity LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
        Test.startTest();
        System.runAs(userGcf){
            opp.AV_ModificacionTelefonica__c = true;
            opp.AV_Contrato__c = '9999999999999999';
            update opp;
        }
        Test.stopTest();
        List<Event> evtTlf = [SELECT Id FROM Event];
        System.assert(evtTlf.isEmpty());
        System.assertEquals(opp.AV_Contrato__c, '9999999999999999');
	}
	
	/**
	 * Execute the Trigger class (AV_Opportunity_BD_TRHan) test the error message
	 */
	@isTest
	private static void validateDeleteOpportunityErrorTest() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_ALTAOPP','OK'));
		Account acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
		Contact employee = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado' and CC_Matricula__c != null LIMIT 1];
		Task tsk = AV_TestHelper.createTareaExternalIdWithCustomer(null, 'XXX-0001', acc);
		Opportunity opp = [SELECT Id, OwnerId, AccountId,AV_ModificacionTelefonica__c,AV_Contrato__c FROM Opportunity LIMIT 1];
		AV_CustomActivityOpportunity__c cao = AV_TestHelper.createTareaOportunidadExt(opp, tsk.AV_ExternalId__c);
		Test.startTest();
		System.runAs(userGestor){
			try{
				Database.delete(opp);
			}catch(Exception e){
				Boolean expectedExceptionThrown = e.getMessage().contains(ERROR_MESSAGE) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			} 
		}
		Test.stopTest();
	}
	
	/**
	 * Execute the Trigger class (AV_Opportunity_BD_TRHan) test the error message
	 */
	@isTest
	private static void validateDuplicatePFErrorTest() {
		//Create Opp with a PF, test insert OK
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Account acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
		Contact empleado = [SELECT Id FROM Contact WHERE FirstName = 'Empleado2' LIMIT 1];
		Product2 producto = [SELECT Id FROM Product2 WHERE AV_ExternalID__c = '50003' LIMIT 1];
		Opportunity oppWithPF = AV_TestHelper.createOpportunityIniciativaWithProduct(acc, empleado, '000003', producto);  
		Test.startTest();
		System.runAs(userGestor){     
			//Create Opp with same PF, test insert KO
			try{    
				Opportunity oppWithSamePF = AV_TestHelper.createOpportunityIniciativaWithProduct(acc, empleado, '000004', producto); 
			}catch(Exception e){
				Boolean expectedExceptionThrown =  e.getMessage().contains(ERROR_MESSAGE_PF) ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
			} 
		}
		Test.stopTest();
	}
	
	@isTest
	public static void validateCreateOpportunityComentarios() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Account acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
		Opportunity opp = [SELECT Id, OwnerId, AccountId,AV_ModificacionTelefonica__c,AV_Contrato__c FROM Opportunity LIMIT 1];
		Test.startTest();
		System.runAs(userGestor){
			opp.Description = 'Prueba comentario';
			update opp;
		}
		Test.stopTest();
		Opportunity oppActual = [SELECT Id, AV_CommentLastModifiedBy__c, AV_CommentLastModifiedDate__c FROM Opportunity WHERE  Id = :opp.id LIMIT 1];
		System.assertNotEquals(oppActual.AV_CommentLastModifiedBy__c,null);
		System.assertNotEquals(oppActual.AV_CommentLastModifiedDate__c,null);
		System.assertEquals(opp.Description,'Prueba comentario');
	}

	@isTest
	public static void validateOpportunityValueNumeroDocumento() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Opportunity opp;
		Account acc;
		Test.startTest();
		System.runAs(userGestor){
			acc = [SELECT Id, CC_Numero_Documento__c FROM Account LIMIT 1];
			opp = [SELECT Id, OwnerId, AccountId,AV_ModificacionTelefonica__c,AV_Contrato__c FROM Opportunity LIMIT 1];
		}
		Test.stopTest();
		Opportunity oppActual = [SELECT id,AV_NumeroDocumento__c FROM Opportunity WHERE  Id = :opp.id];
		System.assertEquals(oppActual.AV_NumeroDocumento__c,acc.CC_Numero_Documento__c);
	}

	@isTest
	public static void fillClientProductTest() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Opportunity opp = [SELECT Id,Name,AV_PF__c, AV_ClientProduct__c, OwnerId FROM Opportunity WHERE AV_ExternalID__c = '00000002' LIMIT 1];        
		Product2 prod = [SELECT Id FROM Product2 WHERE AV_ExternalID__c = '50003' LIMIT 1];		
		Test.startTest();
		System.runAs(userGestor){
			opp.AV_PF__c = prod.Id;
			Database.update(opp);
		}
		Test.stopTest();
		Opportunity oppAfter = [SELECT Id,Name,AV_PF__c,AV_ClientProduct__c FROM Opportunity LIMIT 1];
		AV_ProductClient__c pfc = [SELECT Id FROM AV_ProductClient__c LIMIT 1];
		System.assertEquals(pfc.Id, oppAfter.AV_ClientProduct__c, 'El producto ficha cliente no se ha podido actualizar.');
	}

	@isTest
	public static void fillHeaderTaskTest(){
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		List<Opportunity> listOpp = [SELECT Id,Name,AV_PF__c,AV_ClientProduct__c FROM Opportunity WHERE AV_ExternalId__c = '00000002' LIMIT 1];
		Task tarea = [SELECT Id, AV_ExternalId__c FROM Task WHERE AV_ExternalID__c = 'ID-0001'];
		List<Task> listTask = [SELECT Id,AV_ExternalID__c,AV_Task__c FROM Task WHERE Id = :tarea.id LIMIT 1];
		List<AV_HeaderCustomActivity__c> rtrvHeader;
		Test.startTest();
		System.runAs(userGestor){
			AV_CustomActivityOpportunity__c oppTask = new AV_CustomActivityOpportunity__c(
						Name='Prueba Tarea Oportunidad', 
						AV_Task__c=listTask[0].AV_Task__c, 
						AV_Opportunity__c=listOpp[0].id);
			insert oppTask;
			
			List<AV_HeaderCustomActivity__c> listHeaderTask = [SELECT Id,IDTask__c,AV_ExternalID__c FROM AV_HeaderCustomActivity__c
																WHERE AV_ExternalID__c = :tarea.AV_ExternalID__c LIMIT 1];
			System.assert(!listHeaderTask.isEmpty());									
			Map<String, AV_HeaderCustomActivity__c> mapHeaderTask = new Map<String, AV_HeaderCustomActivity__c>();
			for(AV_HeaderCustomActivity__c hca : listHeaderTask){
				mapHeaderTask.put(hca.AV_ExternalID__c, hca);
			}
			AV_OpportunityTriggerHelperAux.fillHeaderTask(listTask, mapHeaderTask);
			rtrvHeader = [SELECT ID,IDTask__c,AV_ExternalID__c FROM AV_HeaderCustomActivity__c WHERE AV_ExternalID__c = :listTask[0].AV_ExternalID__c ];
			
		}
		Test.stopTest();
		System.assertEquals(listTask[0].Id,rtrvHeader[0].IDTask__c,rtrvHeader);
	}
	
	@isTest
	public static void updateTaskWithOppTest(){
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = :AV_AppConstants.AV_PROFILE AND IsActive = true AND Email = 'gestor-test@test.com'];
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CP_INSCNT','OK'));
		List<Opportunity> listOpp = [SELECT Id,Name FROM Opportunity WHERE RecordType.DeveloperName=:AV_AppConstants.OPPALERTACOM_RT LIMIT 1];
		Account accTest = [SELECT ID FROM ACCOUNT WHERE RecordType.DeveloperName = :AV_AppConstants.ACCOUNT_PA_RT LIMIT 1];
		Event evtTest = AV_TestHelper.createEvent(userGestor, System.today()+1, accTest);
        Event event = [Select id, AV_Task__c from Event where Id =:evtTest.Id];
		Test.startTest();
		AV_CustomActivityOpportunity__c oppTask = new AV_CustomActivityOpportunity__c(
			Name='Prueba Tarea Oportunidad', 
			AV_Task__c=event.AV_Task__c,
			AV_Opportunity__c=listOpp[0].id,
			AV_IsMain__c=true,
			OwnerId =userGestor.Id
		);
		insert oppTask;
		System.runAs(userGestor){
			listOpp[0].Name='Oportunidad update';
			listOpp[0].AV_FechaProximoRecordatorio__c=System.today();
			listOpp[0].AV_IncludeInPrioritizingCustomers__c=true;
			update listOpp;
		}
		Test.stopTest();
		System.assertEquals(listOpp[0].Name , 'Oportunidad update');
		System.assertEquals(oppTask.Name , 'Prueba Tarea Oportunidad');
	}

	@isTest 
	public static void updateTaskWithOppSecondTest(){
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Task tarea = [SELECT Id,AV_Task__c FROM Task WHERE AV_ExternalID__c = 'ID-0001'];
		List<Opportunity> listOpp = [SELECT Id,Name FROM Opportunity WHERE RecordType.DeveloperName='AV_AlertaComercial' LIMIT 1];
		AV_CustomActivityOpportunity__c oppTask = new AV_CustomActivityOpportunity__c(
			Name='Prueba Tarea Oportunidad', 
			AV_Task__c=tarea.AV_Task__c,
			AV_Opportunity__c=listOpp[0].id,
			AV_IsMain__c=true,
			OwnerId =userGestor.Id
		);
		insert oppTask;
		Test.startTest();
		System.runAs(userGestor){
			tarea.Status = 'Rechazada';
			tarea.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
			update tarea;

			listOpp[0].AV_FechaProximoRecordatorio__c = System.today()+10;
			listOpp[0].AV_IncludeInPrioritizingCustomers__c=false;
			listOpp[0].AV_OrigenApp__c = 'AV_SalesforceReport';
			listOpp[0].StageName = 'En gestión/insistir';
			update listOpp;
		}
		Test.stopTest();
		System.assertEquals(tarea.Status, 'Rechazada');
		System.assertEquals(tarea.AV_OrigenApp__c, 'AV_SalesforceTaskOpp');
		System.assertEquals(listOpp[0].AV_IncludeInPrioritizingCustomers__c , false);
		System.assertEquals(listOpp[0].StageName , 'En gestión/insistir');
	}
	
	@isTest 
	public static void updateTaskWithOppFourthTest(){
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Task tarea = [SELECT Id,AV_Task__c FROM Task WHERE AV_ExternalID__c = 'ID-0001'];
		List<Opportunity> listOpp = [SELECT Id,Name FROM Opportunity LIMIT 1];
		AV_CustomActivityOpportunity__c oppTask = new AV_CustomActivityOpportunity__c(
			Name='Prueba Tarea Oportunidad', 
			AV_Task__c=tarea.AV_Task__c,
			AV_Opportunity__c=listOpp[0].id,
			AV_IsMain__c=true,
            OwnerId =userGestor.Id
        );
		insert oppTask;
		Test.startTest();
		System.runAs(userGestor){
			tarea.Status = 'Rechazada';
			tarea.AV_OrigenApp__c = 'AV_SalesforceTaskOpp';
			update tarea;

			listOpp[0].AV_IncludeInPrioritizingCustomers__c=true;
			update listOpp;
		}
		Test.stopTest();
		System.assertEquals(listOpp[0].AV_IncludeInPrioritizingCustomers__c, true);
	}

	@isTest
	public static void createTaskCheckOnOffTest() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		List<Opportunity> opp = [SELECT Id, CreatedDate, AV_PF__r.Name, AV_IncludeInPrioritizingCustomers__c, AV_Gestor__c, AV_FechaProximoRecordatorio__c, AV_ExternalID__c, AccountId, AV_PF__c, AV_Center__c, StageName,AV_OrigenApp__c FROM Opportunity WHERE AV_IncludeInPrioritizingCustomers__c = false AND StageName = 'Potencial' LIMIT 1];
		Test.startTest();
		System.runAs(userGestor){
			opp[0].AV_IncludeInPrioritizingCustomers__c = true;
			opp[0].AV_FechaProximoRecordatorio__c = System.today();
			AV_OpportunityTriggerHelper.insertTaskWithOpp(opp,new Map<String,Opportunity>());
		}
		Test.stopTest();
		String taskSubjectLike = '%' + opp[0].AV_PF__r.Name + '%';
		List<Task> listTasks = [SELECT Id FROM Task WHERE CreatedDate = :opp[0].CreatedDate AND Subject LIKE :taskSubjectLike LIMIT 1];
		System.assertNotEquals(null, listTasks.isEmpty(), 'Task with check not created');
	}

	@isTest
	public static void createTaskTest() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		List<Opportunity> opp = [SELECT Id, CreatedDate, AV_PF__r.Name, AV_IncludeInPrioritizingCustomers__c, AV_Gestor__c, AV_FechaProximoRecordatorio__c, AV_ExternalID__c, AccountId, AV_PF__c, AV_Center__c, StageName,RecordTypeId FROM Opportunity WHERE RecordType.Name = 'Iniciativa' LIMIT 1];
		Test.startTest();
		System.runAs(userGestor){
			AV_OpportunityTriggerHelper.createTask(opp);
		}
		Test.stopTest();
		System.assertNotEquals(null, opp);
	}

	@isTest
	public static void updateTaskWithOppTestCheckOnChangeDateCheckOff(){
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		List<Opportunity> listOpp =[SELECT id, name, AV_FechaProximoRecordatorio__c,AV_IncludeInPrioritizingCustomers__c,StageName,AV_PF__r.Name FROM opportunity WHERE AV_ExternalID__c = '83489' LIMIT 1];
		Test.startTest();
		System.runAs(userGcf){																												 
			listOpp[0].AV_IncludeInPrioritizingCustomers__c=false;											   
			update listOpp;
		}
		Test.stopTest();
		List<Task> tareaCreada = [SELECT Id, ActivityDate FROM Task WHERE ActivityDate = :listOpp[0].AV_FechaProximoRecordatorio__c LIMIT 1];        
		System.assert(true, tareaCreada.isEmpty());
	}

	@isTest
	public static void updateTaskWithOppTestCheckOnChangeStageOpp(){
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		Test.startTest();
		System.runAs(userGcf){
			List<Opportunity> listOpp =[SELECT id, name, AV_FechaProximoRecordatorio__c,AV_IncludeInPrioritizingCustomers__c,StageName,AV_PF__r.Name FROM opportunity WHERE AV_ExternalID__c = '83489' limit 1];
			String subjectTarea = listOpp[0].AV_FechaProximoRecordatorio__c.format()+ ' - ' + listOpp[0].AV_PF__r.Name;
			listOpp[0].AV_IncludeInPrioritizingCustomers__c=false;	
			listOpp[0].StageName='Cerrado positivo';
			listOpp[0].AV_OrigenApp__c = 'AV_SalesforceReport'; // Added because of US325412
			update listOpp;
			Test.stopTest();
			List<Task> tareaCreadaDespues = [SELECT Id FROM Task WHERE Subject =:subjectTarea Limit 1];
			System.assertEquals(true, tareaCreadaDespues.isEmpty());
		}
	}
	
	@isTest
	private static void validateSaveFieldsFromOpp(){   
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454'];
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		Test.startTest();
		Opportunity opp = [SELECT Id, Name, OwnerId,AV_EmpleadoModificacion__c,AV_FechaModificacion__c,AV_EmpleadoAlta__c,AV_Gestor__c FROM Opportunity WHERE AV_ExternalID__c = '00000001' LIMIT 1];
		String oppNameBeforeUpdt;
		System.runAs(userGcf){
			PermissionSetGroup psg = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName = 'AV_Gestor' LIMIT 1];
			Map<String, PermissionSetAssignment> mapPs = new Map<String, PermissionSetAssignment>();
			List<PermissionSetAssignment> listAssignment = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroupId =:psg.Id AND AssigneeId=:userGestor.Id];
			for (PermissionSetAssignment ass: listAssignment) {
				mapPs.put(ass.AssigneeId, ass);
			}
			if(psg.Status != 'Updated'){
				Test.calculatePermissionSetGroup(psg.Id);
			}
			if(!mapPs.containsKey(userGestor.id)) {
				insert new PermissionSetAssignment(PermissionSetGroupId = psg.Id, AssigneeId = userGestor.Id);    
			}
			opp.Name = 'BfrChange';
			update opp;
			oppNameBeforeUpdt = [SELECT name FROM opportunity WHERE Id = :opp.id LIMIT 1].Name;
			Contact con= [SELECT Id, lastmodifieddate, AV_UsuarioAsociado__c FROM Contact LIMIT 1];        
			con.AV_UsuarioAsociado__c = opp.OwnerId;   
			Database.update(con);
		}
		System.runAs(userGestor) {
            opp.Name= 'oppToTestChanged';             
            Database.update(opp);
		}        
		Opportunity opp2 = [SELECT Id, Name, OwnerId,AV_EmpleadoModificacion__c,AV_FechaModificacion__c,AV_EmpleadoAlta__c,AV_Gestor__c
		FROM Opportunity WHERE id = :opp.Id LIMIT 1];        
		Test.stopTest();
		System.assertNotEquals(opp.Name, oppNameBeforeUpdt,opp.Name + '->' + opp2.Name);
	}

	@isTest
	public static void validateSetConfidentiality() {
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Account acc = [SELECT Id, AV_Confidencial__c FROM Account WHERE FirstName = 'FirstName' AND AV_NumPerso__c = '123' LIMIT 1];
		Opportunity updatedOpp;
		Test.startTest();
		System.runAs(userGestor){
			Opportunity opp = [SELECT Id,AV_ClienteConfidencial__c FROM Opportunity WHERE AV_ExternalID__c = '00000002' LIMIT 1];
			opp.Name = 'New Name';
			Database.update(opp);
	
			updatedOpp = [SELECT Id,AV_ClienteConfidencial__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
		}
		Test.stopTest();
		System.assertEquals(true, updatedOpp.AV_ClienteConfidencial__c == acc.AV_Confidencial__c, 'Confidentiality was not updated.');
	}

	@isTest
	public static void validateUpdateFechaActivacion(){
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Opportunity opp = [SELECT id,StageName, AV_FechaActivacion__c,AV_OrigenApp__c FROM Opportunity WHERE StageName = 'Potencial' LIMIT 1];
		Test.startTest();
		System.runAs(userGestor){	
			opp.StageName='En gestión/insistir';
			opp.AV_OrigenApp__c = 'AV_SalesforceReport';
			Database.update(opp);
		}
		Test.stopTest();
		Opportunity ou = [SELECT AV_FechaActivacion__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
		System.assertEquals(System.today(),ou.AV_FechaActivacion__c,'Date not changed');
	}

	@isTest
	public static void validateUpdateCentro(){
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		User newOwner = [SELECT Id,AV_NumeroOficinaEmpresa__c FROM USER WHERE AV_ExternalID__c = 'U01543678'][0];
		RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPALERTACOM_RT);
		Account accId= [SELECT Id FROM ACCOUNT LIMIT 1];
		Test.startTest();
		Product2 prodtest = AV_TestHelper.createProduct2(null,'50112');
		Opportunity opp = new Opportunity(
				AccountId = accID.Id,
				Name = 'PruebaTest',
				StageName = 'En gestión/insistir',
				RecordTypeId = rt.Id,
				CloseDate = System.today() + 5,
				AV_Comentarios__c = 'Nueva Oportunidad tipo Iniciativa',
				AV_FechaProximoRecordatorio__c = System.today()+3,
				AV_PF__c = prodtest.Id,
				OwnerId = userGestor.Id,
				AV_OrigenApp__c= 'AV_SalesforceReport'
				);
		insert opp;
		System.runAs(userGestor){
			opp.OwnerId = newOwner.Id;
			Database.update(opp);
		}
		Test.stopTest();

		Opportunity newCenter = [SELECT AV_Center__c FROM Opportunity WHERE Name='PruebaTest'][0];
		System.AssertEquals(newCenter.AV_Center__c,newOwner.AV_NumeroOficinaEmpresa__c.mid(4, 5),'No se ha actualizado el centro');
	}

   	@isTest 
   	public static void validarBlockCloseDateUpdateKO(){
		User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
		Test.startTest();
		System.runAs(userGestor){
			Opportunity modifiedOppo = [SELECT ID,CLOSEDATE FROM OPPORTUNITY LIMIT 1];
			modifiedOppo.closeDate = modifiedOppo.closeDate +1;
			String error = '';
			String comparar = 'No se puede modificar la fecha de cierre manualmente';
			try{
				Database.update(modifiedOppo);
			}catch(Exception e){
				 error = e.getMessage();
			}
			Test.stopTest();

			System.assertNotEquals(error, comparar);
		}
   }
   
   	@isTest 
   	public static void validarBlockCloseDateUpdateOK(){
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
        Opportunity oppToTest = [SELECT ID,CloseDate FROM OPPORTUNITY LIMIT 1];
        Date closeDate;
		Test.startTest();
		System.runAs(userGestor){
			oppToTest.AV_OrigenApp__c= 'AV_SalesforceReport';
			closeDate = oppToTest.closeDate +1;
			oppToTest.closeDate = closeDate;
			Database.update(oppToTest);
		}
		Test.stopTest();

		System.assertEquals(oppToTest.closeDate,closeDate);
   }

   	@isTest 
	public static void validarUpdateGCF(){
		User userGcf = [SELECT ID FROM USER WHERE Alias = 'AV-TF9' AND Profile.Name = 'API Only' and isActive = true LIMIT 1];
		Test.startTest();
		Opportunity testOppo = [SELECT ID,Name,StageName,AV_ToDelete__c,AV_Comentarios__c,AV_FechaProximoRecordatorio__c,AV_Center__C,AV_Gestor__c 
		FROM OPPORTUNITY LIMIT 1];	
		System.runAs(userGcf){
		testOppo.AV_ToDelete__c = false;
		testOppo.StageName = AV_AppConstants.OPP_STATUS_NOAPTO;
		testOppo.AV_ExternalID__c = '12344321';
		testOppo.AV_OrigenApp__c = 'AV_SalesforceReport';
		testOppo.OwnerId = userGcf.id;
		update testOppo;	
		}
		Opportunity oppoAntes = [SELECT ID,Name,StageName,AV_ToDelete__c,AV_Comentarios__c,AV_FechaProximoRecordatorio__c,AV_Center__C,AV_Gestor__c 
		FROM Opportunity WHERE AV_ToDelete__c = FALSE AND StageName != 'Potencial' AND StageName != 'Vencida' LIMIT 1];
		System.runAs(userGcf){
			oppoAntes.AV_ToDelete__c = true;
			oppoAntes.AV_Comentarios__c = 'Comentario update';
			oppoAntes.AV_FechaProximoRecordatorio__c = System.today().addDays(2);
			oppoAntes.StageName = AV_AppConstants.OPP_STATUS_CERRPOST;
			oppoAntes.AV_FechaModificacion__c = System.today().addDays(1);
			oppoAntes.AV_Center__c = '999099';
			Database.update(oppoAntes);
		}
		Test.stopTest();

		Opportunity oppoAU = [SELECT ID,Name,StageName,AV_ToDelete__c,AV_Comentarios__c,AV_FechaProximoRecordatorio__c,AV_Center__C,AV_Gestor__c FROM Opportunity WHERE id = :oppoAntes.Id LIMIT 1];
		System.assert(!oppoAU.AV_ToDelete__c);
		System.assertEquals(testOppo.StageName, oppoAU.StageName);
		System.assertEquals(testOppo.AV_Comentarios__c, oppoAU.AV_Comentarios__c);
		System.assertEquals(testOppo.AV_Center__c, oppoAU.AV_Center__c);
   }

	@isTest
	public static void updateStageNameTest(){
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
		Test.startTest();
		PermissionSetGroup psg = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName = 'AV_Gestor' LIMIT 1];
		Map<String, PermissionSetAssignment> mapPs = new Map<String, PermissionSetAssignment>();

		List<PermissionSetAssignment> listAssignment = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroupId =:psg.Id AND AssigneeId=:userGestor.Id];
		for (PermissionSetAssignment ass: listAssignment) {
			mapPs.put(ass.AssigneeId, ass);
		}
		if(psg.Status != 'Updated'){
			Test.calculatePermissionSetGroup(psg.Id);
		}
		if (!mapPs.containsKey(userGestor.id)) {
			insert new PermissionSetAssignment(PermissionSetGroupId = psg.Id, AssigneeId = userGestor.Id);    
		}
		System.runAs(userGestor){
			Opportunity opp= [SELECT id, AV_FechaProximoRecordatorio__c, StageName FROM Opportunity WHERE StageName='Potencial' AND OwnerId=:userGestor.Id LIMIT 1];
			opp.AV_FechaProximoRecordatorio__c = System.today().addDays(4);
			update opp;
		}
		Test.stopTest();
		
		Opportunity oppNew= [SELECT id, AV_FechaProximoRecordatorio__c, StageName FROM Opportunity WHERE StageName='En gestión/insistir' AND OwnerId=:userGestor.Id LIMIT 1];
		System.assertEquals(oppNew.StageName, 'En gestión/insistir');
	}
	
	@isTest
	public static void createTaskCallMeTest(){
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
 		User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454'];
		Test.startTest();
		System.runAs(userGcf){
			Opportunity opp = [SELECT ID, OwnerId, AV_ExternalID__c, AccountId, Name FROM Opportunity WHERE Name = 'Opp Call Me'];
			opp.OwnerId = userGestor.Id;
			update opp;
		}
		Test.stopTest();
		Opportunity oppUpdated = [SELECT ID, OwnerId, AV_ExternalID__c, AccountId, Name, StageName FROM Opportunity WHERE Name = 'Opp Call Me'];
		System.assertEquals(oppUpdated.StageName, 'En gestión/insistir');
	} 
	
	@isTest
	public static void assignPropensityTest(){
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
		PermissionSetGroup psg = [SELECT Id, Status FROM PermissionSetGroup WHERE DeveloperName = 'AV_Gestor' LIMIT 1];
		Map<String, PermissionSetAssignment> mapPs = new Map<String, PermissionSetAssignment>();
		List<PermissionSetAssignment> listAssignment = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetGroupId =:psg.Id AND AssigneeId=:userGestor.Id];
		for (PermissionSetAssignment ass: listAssignment) {
			mapPs.put(ass.AssigneeId, ass);
		}
		if(psg.Status != 'Updated'){
			Test.calculatePermissionSetGroup(psg.Id);
		}
		if (!mapPs.containsKey(userGestor.id)) {
			insert new PermissionSetAssignment(PermissionSetGroupId = psg.Id, AssigneeId = userGestor.Id);    
		}
        Test.startTest();
		System.runAs(userGestor){
			Opportunity opp= [SELECT Id, AV_Potencial__c, OwnerId, Owner.AV_ExternalID__c FROM Opportunity WHERE RecordType.DeveloperName=:AV_AppConstants.OPPINICIATIVA_RT LIMIT 1];
			opp.AV_Potencial__c = null;
			update opp;
			opp.AV_Potencial__c = 'VP';
			update opp;
		}
		Test.stopTest();
		List<Opportunity> oppList = [SELECT ID, AV_Propensity__c FROM Opportunity WHERE AV_Propensity__c=210];
		System.assertEquals(oppList[0].AV_Propensity__c, 210);
	} 
   
	@isTest
	public static void validatePFTest(){
		Test.startTest();
		User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
		Account acc= [SELECT Id FROM ACCOUNT LIMIT 1];
		Product2 product = [SELECT Id FROM Product2 WHERE AV_ExternalID__c = '50113' LIMIT 1];
		Opportunity opp = [SELECT Id, AV_PF__c, AccountId, SystemModStamp, AV_ExternalID__c, StageName, Name, AV_OrigenApp__c FROM Opportunity WHERE RecordType.DeveloperName=:AV_AppConstants.OPPINICIATIVA_RT LIMIT 1];
		System.runAs(userGestor){    
			opp.AV_PF__c = product.Id;
			opp.AccountId = acc.Id;
			opp.StageName = 'En gestión/insistir';
			opp.Name = 'PruebaTest';
			opp.AV_OrigenApp__c = 'AV_SalesforceReport';
			Database.update(opp);
		}
		Test.stopTest();
		List<Opportunity> opportunityNew = [SELECT Id, AV_PF__c, AccountId, SystemModStamp, AV_ExternalID__c, StageName, Name FROM Opportunity WHERE AV_PF__c = :product.Id AND AccountId  = :acc.Id LIMIT 1];
		System.assertEquals(true, opportunityNew[0].AccountId == opp.AccountId, 'El cliente ya tiene una oportunidad para este producto.');
	}
    
    @isTest
    public static void updateCommentsHistoryTest(){
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        Opportunity opp4 = [SELECT Id,AV_Comentarios__c FROM Opportunity WHERE AV_ExternalId__c = '00000001' LIMIT 1];
        Test.startTest();
        System.runAs(userGcf){
            opp4.AV_Comentarios__c = 'Cambiar comentario 01';
            Database.update(opp4);
        }
        Test.stopTest();
        AV_CommentsHistory__c cm =[SELECT ID,AV_NewComment__c,AV_Opportunity__c FROM AV_CommentsHistory__c  LIMIT 1];
        System.assertNotEquals(cm.AV_NewComment__c,null);
    }
    
    @isTest
    public static void validationsOpportunity1(){
        Test.startTest();
        String result='OK';
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalId__c = '00000001' LIMIT 1];
        System.runAs(userGestor){
            opp.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            opp.StageName = AV_AppConstants.OPP_STATUS_VENCIDO;
            Database.SaveResult sr = Database.update(opp,false);
            if(!sr.isSuccess()) {
                result = sr.getErrors()[0].getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(result,'No es posible realizar el cambio de etapa. Las etapas Potencial, Vencida y Con venta son etapas automáticas.');
    }
    
    @isTest
    public static void validationsOpportunity2(){
        Test.startTest();
        String result='OK';
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalId__c = '00000001' LIMIT 1];
        System.runAs(userGestor){
            opp.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            opp.StageName = AV_AppConstants.OPP_STATUS_NOINTERE;
            opp.AV_IncludeInPrioritizingCustomers__c = true;
            Database.SaveResult sr = Database.update(opp,false);
            if(!sr.isSuccess()) {
                result = sr.getErrors()[0].getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(result,'El estado de la oportunidad no permite incluirla en "clientes priorizados".');
    }
    
    @isTest
    public static void validationsOpportunity3(){
        Test.startTest();
        String result='OK';
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalId__c = '00000001' LIMIT 1];
        System.runAs(userGestor){
            opp.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            opp.AV_Resolucion__c = AV_AppConstants.OPP_RESOLUTION_OTROS;
            Database.SaveResult sr = Database.update(opp,false);
            if(!sr.isSuccess()) {
                result = sr.getErrors()[0].getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(result,'No es posible seleccionar la resolución si el estado de la oportunidad no es "Cerrada negativa".');
    }
    
    @isTest
    public static void validationsOpportunity4(){
        Test.startTest();
        String result='OK';
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalId__c = '00000001' LIMIT 1];
        System.runAs(userGestor){
            opp.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            opp.StageName = AV_AppConstants.OPP_STATUS_NOINTERE;
            opp.AV_Resolucion__c = AV_AppConstants.OPP_RESOLUTION_OTROS;
            opp.AV_Comentarios__c = null;
            Database.SaveResult sr = Database.update(opp,false);
            if(!sr.isSuccess()) {
                result = sr.getErrors()[0].getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(result,'Por favor, debe añadir algun comentario.');
    }
    
    @isTest
    public static void validationsOpportunity5(){
        Test.startTest();
        String result='OK';
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalId__c = '00000001' LIMIT 1];
        System.runAs(userGestor){
            opp.AV_OrigenApp__c = AV_AppConstants.CLIENT_REPORT_ORIGENAPP;
            opp.StageName = AV_AppConstants.OPP_STATUS_NOINTERE;
            opp.AV_Resolucion__c = AV_AppConstants.OPP_RESOLUTION_VD;
            Database.SaveResult sr = Database.update(opp,false);
            if(!sr.isSuccess()) {
                result = sr.getErrors()[0].getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(result,'No es posible cambiar la resolución a Venta desestimada, es una resolución automática.');
    }
    
    @isTest
    public static void validationByPassOpp(){
        Test.startTest();
        String result='OK';
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE AV_ExternalId__c = '00000001' LIMIT 1];
        System.runAs(userGestor){
            opp.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_BACK_REPORT;
            opp.StageName = AV_AppConstants.OPP_STATUS_NOINTERE;
            Database.SaveResult sr = Database.update(opp,false);
            if(!sr.isSuccess()) {
                result = sr.getErrors()[0].getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(result,'OK');
    }
    
    @isTest
    public static void validationByPassOpp2(){
        Test.startTest();
        String result='OK';
        Account acc = [SELECT Id FROM Account WHERE AV_NumPerso__c = '123' LIMIT 1];
        User userGestor = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U01545454' LIMIT 1];
        Contact gestor = [SELECT Id FROM Contact WHERE AV_UsuarioAsociado__c = :userGestor.Id LIMIT 1];
        Product2 producto = AV_TestHelper.createProductSinInsert(null,null,'50119');
        insert producto; 
        RecordType rt = AV_AppUtilities.getRecordType(AV_AppConstants.OBJECT_NAME_OPPORTUNITY, AV_AppConstants.OPPINICIATIVA_RT);
        System.runAs(userGestor){
            Opportunity opp = AV_TestHelper.createOpportunityWithEmpleadoSinInsert2(acc, gestor, producto, rt, '123123123131',userGestor.Id);
            opp.StageName = AV_AppConstants.OPP_STATUS_ENGESTION;
            opp.AV_OrigenApp__c = AV_AppConstants.OPP_ORIGEN_BACK_REPORT;
            Database.SaveResult sr = Database.insert(opp,false);
            if(!sr.isSuccess()) {
                result = sr.getErrors()[0].getMessage();
            }
        }
        Test.stopTest();
        System.assertEquals(result,'OK');
    }
}