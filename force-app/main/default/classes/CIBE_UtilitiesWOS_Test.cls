/**********************************************************************************************************************
Name:	  CIBE_UtilitiesWOS_Test
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de cobertura para CIBE_UtilitiesWOS
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US776107    	Alicia				08/01/2024		Init version
	1.1         IN1184391    	Lucia				12/07/2024      Add 'createTeamMemberTest1()', 'createTeamMemberTest2()', 'updateTeamMemberTest()'

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_UtilitiesWOS_Test {

	@TestSetup
	static void setup() {
		
		CIBE_TestInitialSetup.setupInitialData(null,CIBE_AppConstants.CIBE_ROLECIB,null,null,null,new List<String>{CIBE_AppConstants.CIBE_OPERATIVACIB, CIBE_AppConstants.CIBE_CUSTOMMETADATA, CIBE_AppConstants.CIBE_OPERATIVAEMP});
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001'];
		User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
		
// ----------------------------------------------------------

        Account accTest = CIBE_TestHelper.createCustomer();
        Account centroCaixa = CIBE_TestHelper.createCaixaCenter();
        Contact conTest = CIBE_TestHelper.createEmployee(centroCaixa, us);
        AccountTeamMember accTM = CIBE_TestHelper.createAccountTeamMember(us, accTest);
        AV_Book__c book = CIBE_TestHelper.createPurse('04380EAP004');
        AV_BookManagementMember__c member = CIBE_TestHelper.createBookManagement(conTest, book);
		
// ----------------------------------------------------------

		Test.startTest();
			List<Task> listaTareas = new List<Task>();

			Task tareaAC = CIBE_TestHelper.createTareaOtherExternalID(us);
			RecordType rtAcc = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
			Account acc = new Account(
				Name = 'Name',
				RecordTypeId = rtAcc.Id,
				AV_NumPerso__c = '9123459',
				AV_Negocio__c = 'CIB',
				OwnerId = us.Id
			);
			insert acc;
			Contact contactAux = CIBE_TestHelper.createRepresentante(null, us, '000000000');
			Task experiencia = CIBE_TestHelper.createTareaExternalIdWithCustomerExp(us,'01928374', acc);
				experiencia.RecordTypeId = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_EXPERIENCIACLIENTE_CIB_RT).Id;
				experiencia.Status='Closed';
				experiencia.AV_Valor1__c = 'Momento - Visita All-in-one';
				experiencia.AV_SurveyValue__c = 14;
				experiencia.OwnerId = us.Id;
			listaTareas.add(experiencia);

			CBK_Activity_Extension__c actExt = new CBK_Activity_Extension__c();
				actExt.AV_AccionesARealizar__c = 'OECP';
				actExt.AV_ActivityId__c = experiencia.Id;
			Database.insert(actExt);

			RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
			Task tarea  = new Task();
				tarea.Subject = 'Prueba';
				if (us!=null){
					tarea.OwnerId = us.Id;
				}else{
					tarea.OwnerId = admin.Id;
				}		
				tarea.Status = 'Pendiente no localizado';
				tarea.Priority = 'Normal';
				tarea.RecordTypeId = rt.Id;
				tarea.ActivityDate = System.today()-3;
			listaTareas.add(tarea);
			
			AppDefinition appDefinition = [SELECT DurableId, Label FROM AppDefinition LIMIT 1];        
			UserAppInfo app = new UserAppInfo(AppDefinitionId = appDefinition.DurableId, UserId = admin.Id, FormFactor = 'Small');

			Database.insert(app);

			RecordType rt2 = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_OTROS_CIB_RT);
			Task tareaNoGest  = new Task();
				tareaNoGest.Subject = 'Prueba';
				if (us!=null){			
					tareaNoGest.OwnerId = us.Id;
				}else{
					tareaNoGest.OwnerId = admin.Id;
				}	
				tareaNoGest.Status = 'Pendiente no localizado';
				tareaNoGest.Priority = 'Normal';
				tareaNoGest.RecordTypeId = rt2.Id;
				tareaNoGest.ActivityDate = System.today();
				tareaNoGest.AV_NoGestionable__c = true;
			listaTareas.add(tareaNoGest);
			upsert listaTareas;
		Test.stopTest();
	}
    
    @isTest
	private static void deleteTeamMemberTest(){
		User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR];
		Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        AccountTeamMember accTM;
		List<String> listAccTest;

		System.runAs(admin) {
            accTM = CIBE_TestHelper.createAccountTeamMember(us, accTest);
            listAccTest = new List<String>{accTest.Id};
        } 
		System.runAs(us) {
            CIBE_UtilitiesWOS.deleteTeamMember(us.Id, listAccTest);
            List <AccountTeamMember> accTMId = [SELECT Id FROM AccountTeamMember WHERE Id = :accTM.Id];
            System.assert(accTMId.isEmpty());
        } 
    }

	@isTest
    public static void getContactTestWithAccountIdTest(){
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR];
		System.runAs(us) {
			Test.startTest();   
				String searchTerm = '';
				List<Task> taskId = [SELECT id From Task LIMIT 10];
				List<String> selectedIds = new List<String>();     
				for(Task auxId : taskId){
					selectedIds.add(auxId.id);
				}
				Account accountAux = [SELECT Id FROM Account Limit 1];
				String accountId = accountAux.Id;
				List<AV_LookupSearchResult> results =CIBE_UtilitiesWOS.getContact(searchTerm, selectedIds, accountId);
			Test.stopTest();      
			System.assertNotEquals(null, results);
		}
    }
    
    @isTest
    public static void getContactTestWithoutAccountIdTest(){
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR];
		System.runAs(us) {
			Test.startTest();   
				String searchTerm = '';
				List<String> selectedIds = new List<String>();     
				Account accountAux = [SELECT Id FROM Account Limit 1];
				String accountId = accountAux.Id;
				List<AV_LookupSearchResult> results =CIBE_UtilitiesWOS.getContact(searchTerm, selectedIds, accountId);
			Test.stopTest();      
			System.assertNotEquals(null, results);
		}
    }

	@isTest
    public static void reLinkOppToEventTest(){
		User admin = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000000'];
		User us = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR];
		Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
		DateTime activityDate = System.now();
		RecordType rt = AV_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_TASK, CIBE_AppConstants.TASK_ALERTACOMERCIAL_CIB_RT);
		String externalId = '999999';

		System.runAs(us) {
			Test.startTest();   

			Event event = CIBE_TestHelper.createEvent(us, activityDate,  accTest);
			Task task = new Task(
				Subject = 'Task',
				RecordTypeId = rt.Id,
				OwnerId = us.Id,
				AV_Task__c = event.AV_Task__c,
				Status = 'Pendiente no localizado',
				Priority = 'Normal',
				AV_ExternalID__c = externalId,
				ActivityDate = System.today()-3
			);
			insert task;
			Opportunity opp = CIBE_TestHelper.createOpportunity(accTest);
			AV_CustomActivityOpportunity__c tareaOpp = CIBE_TestHelper.createTareaOportunidad(opp, task.AV_Task__c);
			
			String results = CIBE_UtilitiesWOS.reLinkOppToEvent(event.Id,task.AV_Task__c) ;
			Test.stopTest();      
			System.assertNotEquals(null, results);
		}
    }


	@isTest
	private static void updateTeamMemberTest(){
        User admin = [SELECT id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        User usrTest = [SELECT id FROM User WHERE AV_ExternalID__c = 'U0000001' AND Profile.Name = :CIBE_AppConstants.CIBE_GESTOR];
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
        
            System.runAs(admin) {
                List<Account> accIds = new List<Account>();
                Account accTest1 = new Account(
                    Name = 'Name1',
                    RecordTypeId = rt.Id,
                    AV_NumPerso__c = '1234',
                    AV_Negocio__c = 'CIB',
                    OwnerId = usrTest.Id
                );              

                accIds.add(accTest1);
                insert accIds;
            }

            System.runAs(usrTest){
                Test.startTest();
                    Account accTest = [SELECT Id FROM Account WHERE Name = 'Name1' LIMIT 1];
                    System.assert(accTest!=null);
                    AccountTeamMember accTM = CIBE_TestHelper.createAccountTeamMember(usrTest, accTest);
                    accTM.TeamMemberRole='Gestor Principal';
                    update accTM;
                    List<String> listAccTest = new List<String>{accTest.Id};

                    CIBE_UtilitiesWOS.updateTeamMember(accTM.id,listAccTest,accTM.TeamMemberRole, usrTest.Id);
                
                Test.stopTest();
            }
    }

	@isTest
    private static void createTeamMemberTest1(){
        User admin = [SELECT id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        User usrTest3 = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0000003');

        System.runAs(admin){
            Test.startTest();
				CIBE_UtilitiesWOS.createTeamMember(new List<String>{accTest.Id}, usrTest3.Id, CIBE_AppConstants.GESTOR_PRINCIPAL);

                List<AccountTeamMember> accountTeamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId = :accTest.Id];
                System.assert(!accountTeamMembers.isEmpty());
                Test.stopTest();
        }
    }
    
    
    @isTest
    private static void createTeamMemberTest2(){
        User admin = [SELECT id FROM User WHERE AV_ExternalID__c = 'U0000000'];
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        User usrTest3 = CIBE_TestHelper.createUser(CIBE_AppConstants.CIBE_GESTOR,'U0000003');

        System.runAs(admin){
            Test.startTest();
            CIBE_UtilitiesWOS.createTeamMember(new List<String>{accTest.Id}, usrTest3.Id, CIBE_AppConstants.GESTOR_PRINCIPAL);
            List<AccountTeamMember> accountTeamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId = :accTest.Id];
            accountTeamMembers = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId = :accTest.Id];
			System.assert(!accountTeamMembers.isEmpty());

            Integer participantes = 0;
            Integer gestoresPrincipales = 0;
            for(AccountTeamMember teamMember : accountTeamMembers) {
                if(teamMember.TeamMemberRole == CIBE_AppConstants.GESTOR_PRINCIPAL) {
                    gestoresPrincipales++;
                } else if(teamMember.TeamMemberRole == CIBE_AppConstants.PARTICIPANTE) {
                    participantes++;
                }
            }
            System.assertEquals(1, participantes);
            System.assertEquals(1, gestoresPrincipales);
            Test.stopTest();
        }
    }
}