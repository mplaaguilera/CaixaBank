/**********************************************************************************************************************
Name:	  AV_UserTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_UserTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	   AUTHOR		   	   DATE				Description
	1.0			Test Class	   Jashanpreet	   	   13/10/2020		Init version
	1.1			US170549	   Sandra Gómez		   09/02/2021		Add method permissionUser
	1.2			DE45035 	   Sandra Gómez		   22/04/2021		Add validateAutomiticProcessOwner and setup
	1.3			US208429	   Víctor Santiago	   30/04/2021		Added setup, updateUsuarioAsociadoFuncionTest
	1.4			FIX Profile	   David Rufo	   	   19/05/2021		Fix to use only the profile for MC project
	1.5		    AV_Query IT	   Daniel Rodríguez	   3/02/2022		Change AV_Query to SOQL for User, Account, Contact
	1.6			Fix Azure	   Sandra Gómez		   09/03/2022		Add method userAzureId
    1.7         US423397       Patricia Solano     03/11/2022       Add test method visibilityUserTest
	1.8         US423397       Patricia Solano     04/11/2022       Modified test method userAzureIdTest and added method userAzureIdExpiredTest
	1.9         US448874       Patricia Solano     21/12/2022       Add method prepareDeleteInactiveUserTest
	2.0         Fix            Patricia Solano     09/03/2023       Modified method prepareDeleteInactiveUserTest and added runAs
	2.1 		US592987	   Patricia Villacañas 30/05/2023		Changed AV_Query to SOQL queries
	2.2         US592987	   Ángel Medina		   30/05/2023		Changed AV_Query to SOQL queries
	2.3			DE82170		   Lucia Muñoz         20/09/2023		Modified method setup
    2.4          QC            Oscar Moreno        12/06/2024       Delete UserInfo.geetUserId()
	2.5			IN1160717	   Manuel Ramos        02/07/2024       Isolate user deactivation methods in AV_UserHandlerWithoutSharing class
    2.6			FIX040724844   Oscar Moreno        04/07/2024       Isolate updateUsuarioAsociado methods in AV_UserHandlerWithoutSharing class
	2.7         FIX20091243    Oscar Moreno        26/09/2024       Create testGroupConfidenProfileRol method
***********************************************************************************************************************/
@isTest
public with sharing class AV_UserTriggerHelper_Test {

	/**
	 * Create Data to test.
	 */
	@TestSetup
	static void setup() {
		AV_TestHelper.activateLogger();
        RecordType rt = AV_AppUtilities.getRecordType('Contact', 'CC_Empleado');
		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank' LIMIT 1];
        List<User> users = new List<User>();
        List<sObject> result = Database.query('SELECT Id FROM Profile WHERE Name = \'' + 'AV_Usuario_CaixaBank' + '\' LIMIT 1');
		Profile profile = (Profile)result.get(0);
        String email = AV_TestHelper.getEmail();
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        User u1 = new User(
			Alias = 'tsAlias',
			Email = 'test@test.dev',
			EmailEncodingKey = 'UTF-8',
			LastName = 'testLastName',
			LanguageLocaleKey = 'es',
			LocaleSidKey = 'es',
			TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044',
            ProfileId = profile.Id,
			UserName = email,
            AV_ExternalID__c = 'U0009003',
			AV_Funcion__c = 'Gestor',
			IsActive = true
		);
        users.add(u1);

		User u2 = new User(
			FirstName = 'Diana',
			LastName = 'Alonso',
			Username = 'dianaalonso@emailcaixa.com',
			Alias = 'dalon',
			Email ='test_2@test.dev',
			TimeZoneSidKey = 'Europe/Paris',
			LocaleSidKey = 'es_ES',
			EmailEncodingKey = 'UTF-8',
			ProfileId = profileId.Id,
			LanguageLocaleKey = 'es',
			AV_Funcion__c = 'Oficina',
			IsActive = true
		);
		users.add(u2);

		String email2 = AV_TestHelper.getEmail();
        User u3 = new User(
			Alias = 'tsAlias3',
			Email = 'test_3@test.dev',
			EmailEncodingKey = 'UTF-8',
			LastName = 'testLastName_2',
			LanguageLocaleKey = 'es',
			LocaleSidKey = 'es',
			TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044_2',
            ProfileId = profile.Id,
			UserName = email2,
            AV_ExternalID__c = 'U0100002123',
            AV_Funcion__c='SSCC',
			IsActive = true
		);
        users.add(u3);

		User u4 = new User(
			Alias = 'tsAlias4',
			Email = 'test@test.dev',
			EmailEncodingKey = 'UTF-8',
			LastName = 'testLastName',
			LanguageLocaleKey = 'es',
			LocaleSidKey = 'es',
			TimeZoneSidKey = 'Europe/Berlin',
			AV_NumeroOficinaEmpresa__c = '1111112',
			ProfileId = profile.Id,
			UserName = 'gestor@emailcaixa.com',
			AV_ExternalID__c = 'U0009005',
			AV_Funcion__c = 'Oficina',
			IsActive = true
		);

		users.add(u4);

		
		System.runAs(userGcf){
			User oficeUser = AV_TestHelper.createUserSinInsert(null,'009090909','AV_SistematicaComercial');
			oficeUser.AV_Funcion__c = 'Oficina';
			users.add(oficeUser);
			
			insert users;
		}
		

		Contact employee  = new Contact(
			LastName = 'Alonso',
			FirstName = 'Diana',
			Email = 'empleadoalonso@emailcaixa.com',
			CC_Idioma__c = 'es',
			RecordTypeId = rt.Id,
			CC_Matricula__c = 'U0009003',
			AV_UsuarioAsociado__c = u2.Id,
			AV_DescFuncion__c = 'EMPLEADO'
		);
		insert employee;

        List<Task> tasks = new List<Task>();
		Task t1 = new Task();
        t1.OwnerId = userGcf.Id;
        tasks.add(t1);
        insert tasks;
	}

	/**
	 * Execute the Trigger class (AV_User_AI_TRHan) and check if the AV_UsuarioAsociado is correct.
	 */
	@isTest
	public static void executeUserTrigger() {
		Test.startTest();
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		System.runAs(userGcf){
			Contact employee  = AV_TestHelper.createEmployee(null, userGcf);
			employee.AV_UsuarioAsociado__c = null;
			update employee;
		}
		User user = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
		Test.stopTest();
		System.assertNotEquals(null, user);
	}
	
	/**
	 * Execute the Trigger class (AV_User_AU_TRHan) and check if the AV_UsuarioAsociado is correct.
	 */
	@isTest
	public static void executeUserAUTrigger() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			User user = [SELECT Id, AV_ExternalID__c FROM User WHERE Username = 'dianaalonso@emailcaixa.com'];
			Contact empleado = [SELECT Id, CC_Matricula__c FROM Contact WHERE Email = 'empleadoalonso@emailcaixa.com' LIMIT 1];
			Test.startTest();
			user.AV_ExternalID__c = 'U0009003';
			update user;
			Test.stopTest();
			User usuarioNew = [SELECT Id, AV_ExternalID__c FROM User WHERE Username = 'dianaalonso@emailcaixa.com'];
			System.assertEquals(empleado.CC_Matricula__c, usuarioNew.AV_ExternalID__c);		
		}
	}
	
	/**
	 * Execute the Trigger class (AV_User_BI_TRHan) and check if the AV_UsuarioAsociado is correct.
	 */
	@isTest
	public static void executeUserBITrigger() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			User user = AV_TestHelper.createUserSinInsert(null, '11111111');
			Test.startTest();
			insert user;
			Test.stopTest();
			User usuarioNew = [SELECT Id, AV_ExternalID__c FROM User WHERE AV_ExternalID__c='11111111'];
			System.assertEquals('11111111', usuarioNew.AV_ExternalID__c);	
		}
	}
	
	/**
	 * Execute the Trigger class Permission is correct.
	 */
	@isTest
	public static void validatePermissionUser() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			Test.startTest();
			User user = [SELECT Id, AV_Funcion__c FROM User WHERE AV_ExternalID__c = 'U0100002123'];
			Profile profile = [SELECT Id FROM Profile WHERE Name = :AV_AppConstants.AV_PROFILE LIMIT 1];
			Account center = AV_TestHelper.createCaixaCenterSinInsert();
			center.CC_Tipo_Oficina__C = 'I';
			insert center;
			Contact cnt = AV_TestHelper.createEmployeeSinInsert(center,userGcf);
			cnt.AV_UsuarioAsociado__c = null;
			insert cnt;
			User oficeUser = new User(
				Alias = 'tsAlias',
				Email = 'test@test.dev',
				EmailEncodingKey = 'UTF-8',
				LastName = 'testLastName',
				LanguageLocaleKey = 'es',
				LocaleSidKey = 'es',
				TimeZoneSidKey = 'Europe/Berlin',
				AV_NumeroOficinaEmpresa__c = null,
				ProfileId = profile.Id,
				UserName = AV_TestHelper.getEmail(),
				AV_ExternalID__c = cnt.CC_Matricula__c
			);
	
			insert oficeUser;
		
			// delete psToDelete;
			user.Email = 'test@caixabank.com';
			Contact retri = [SELECT AV_EmpleadoIntouch__c,AV_UsuarioAsociado__r.AV_ExternalID__c,AV_UsuarioAsociado__r.AV_Funcion__c FROM Contact WHERE ID = :cnt.Id LIMIT 1];
			SObject externo = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'AV_Externo' LIMIT 1];
			user.AV_Funcion__c = 'Gestor';
			oficeUser.AV_Funcion__c = 'Oficina';
	
			update new List<User>{user,oficeUser};
			SObject gestor = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'AV_Gestor' LIMIT 1];
	
			List<SObject> permisoObtenidoActualizado2 = [SELECT id,PermissionSetGroupId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:user.id AND PermissionSetGroupId=:gestor.id];
			Test.stopTest();
			List<SObject> permisoObtenidoEliminado2 = [SELECT id,PermissionSetGroupId, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId=:user.id AND PermissionSetGroupId=:externo.id];
			System.assertEquals(permisoObtenidoEliminado2.isEmpty(),true);
		}
	}

	/**
	 * Execute the Trigger class run ProcessOwner Insert.
	 */
	@isTest
	public static void validateAutomiticProcessOwnerInsert() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		System.runAs(userGcf){
			Test.startTest();
			User user = [SELECT Id FROM User WHERE AV_ExternalID__c = 'U0100002123'];
			Test.stopTest();
			List<Task> listTask = [SELECT id, OwnerId FROM Task];
			System.assertEquals(listTask.isEmpty(), false);
		}
	}
    /**
	 * Execute the Trigger class run ProcessOwner.
	 */
	@isTest
	public static void validateAutomiticProcessOwner() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			Test.startTest();
			User user = [SELECT Id, IsActive FROM User WHERE AV_ExternalID__c = 'U0100002123'];
			user.IsActive = true;
			update user;
			Test.stopTest();
			List<Task> listTask = [SELECT id, OwnerId FROM Task];
			System.assertEquals(listTask.isEmpty(), false);
		}
	}

	
    
	/**
	 * Execute the Trigger class for inactive user.
	 */
    @isTest
	public static void reassignmentInactiveUserTest() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			User user = [SELECT Id, AV_Funcion__c FROM User WHERE AV_ExternalID__c = 'U0100002123'];
			Test.startTest();
			user.IsActive = true;
			Database.update(user);
			Test.stopTest();
			List<CBK_Framework_Batch__c> listJobs = [SELECT Id FROM CBK_Framework_Batch__c];
			System.assertNotEquals(0, listJobs.size());
		}
	}
    
	/**
	 * Execute the Trigger class to validate user.
	 */
    @isTest
	public static void userExternalIdTest() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			AdminSettings__c customSetting = new AdminSettings__c();
			customSetting.LogDEBUG__c=true;
			customSetting.LogERROR__c=true;
			customSetting.LogINFO__c=true;
			customSetting.LogViaEvents__c=true;
			customSetting.LogWARN__c=true;
			customSetting.Validaciones__c=true;
			customSetting.ScheduleJob__c=1;
			insert customSetting;  
			User user  = [SELECT Id, AV_Funcion__c FROM User WHERE AV_ExternalID__c = 'U0100002123'];
			Test.startTest();
			user.AV_ExternalID__c = 'U01000021';
			Database.update(user);
			Test.stopTest();
			List<CBK_Log__c> listLogs = [SELECT Id FROM CBK_Log__c];
			System.assertNotEquals(0, listLogs.size());
		}
	}

	/**
	 * Execute the Trigger class to validate token.
	 */
    @isTest
	public static void userAzureIdTest() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			Test.startTest();
			AV_AzureTeamsToken__c azureToken = new AV_AzureTeamsToken__c();
			azureToken.Name = 'AzureTeamToken';
			azureToken.AV_ExpiresIn__c = 10; 
			insert azureToken;
			User user  = [SELECT Id, AV_AzureId__c, FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U0100002123'];
			user.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
			Database.update(user);
			CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
			String tenant=dataInterface.CC_SoapAction__c.substringAfter('=');
			String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
			Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
			header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
			header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
			HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
			Test.stopTest();
			System.assertNotEquals(null, header2TestResp);
		}
	} 

	/**
	 * Execute the Trigger class to validate expired token.
	 */
	@isTest
	public static void userAzureIdExpiredTest() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			Test.startTest();
			AV_AzureTeamsToken__c azureToken = new AV_AzureTeamsToken__c();
			azureToken.Name = 'AzureTeamToken';
			azureToken.AV_ExpiresIn__c = -3599;
			insert azureToken;
			User user = [SELECT Id, AV_AzureId__c, FederationIdentifier FROM User WHERE AV_ExternalID__c = 'U0100002123'];
			user.FederationIdentifier = 'U01test_teams_caixa@caixabankpre.com';
			Database.update(user);
			CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_Teams_Integration.AV_TEAMSLOGIN);
			String tenant = dataInterface.CC_SoapAction__c.substringAfter('=');
			String urlLogin = 'callout:MICROSOFT_TEAMS/{tenant}/oauth2/v2.0/token'.replace('{tenant}',tenant);
			Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
			header2TestResp.put(urlLogin, new AV_MockCallout_Test('TEAMS_LOGIN','OK'));
			header2TestResp.put('callout:MICROSOFT/v1.0/users/U01test_teams_caixa@caixabankpre.com',new AV_MockCallout_Test('TEAMS_GETUSERID','OK'));
			HttpCalloutMock multiCalloutMock = new AV_MultiRequestMock_Test(header2TestResp);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
			Test.stopTest();
			System.assertNotEquals(null, header2TestResp);
		}
	}

	/**
	 * Execute the Trigger class (AV_User_BU_TRHan) to validate user visibility.
	 */
	@isTest
	public static void visibilityUserTest() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			Test.startTest();
			User user = [SELECT Id, AV_Funcion__c FROM User WHERE Alias = 'tsAlias4']; 
			Test.stopTest();
			System.assertNotEquals(user, null);
		}
	}

	@isTest
    public static void testGroupConfidenProfileRol() {

		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		Profile profileId = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank' LIMIT 1];
		Profile profile2Id = [SELECT Id FROM Profile WHERE Name != 'AV_Usuario_CaixaBank' LIMIT 1];

		UserRole idRol = [SELECT Id FROM UserRole WHERE name ='Sistemática Comercial' LIMIT 1];
		Group grp = [SELECT Id FROM Group WHERE DeveloperName = 'AV_Confidencial' LIMIT 1];
		List<User> userList = [SELECT Id, ProfileId, UserRoleId FROM User WHERE ProfileId = :profileId.Id OR UserRoleId = :idRol.Id LIMIT 1];
		
        GroupMember groupMemberNew = new GroupMember(GroupId = grp.Id, UserOrGroupId = userList[0].Id);
        insert groupMemberNew;
		
		User usOld= userList[0];
		usOld.ProfileId = profile2Id.Id;
		update usOld;
		Map<Id, User> mapUsers = new Map<Id, User>();
		mapUsers.put(usOld.Id,usOld);
		
		GroupMember groupMemberOld = new GroupMember(GroupId = grp.Id, UserOrGroupId = usOld.Id);
        insert groupMemberOld;
		
		 
		System.runAs(userGcf){
			Test.startTest();
			AV_UserTriggerHelper.groupConfidenProfileRol(userList, mapUsers);
			Test.stopTest();
			List<GroupMember> deletedGroupMembers = [SELECT Id FROM GroupMember WHERE GroupId = :grp.Id];
            System.assertNotEquals(true, deletedGroupMembers.isEmpty());
		}

	}
}