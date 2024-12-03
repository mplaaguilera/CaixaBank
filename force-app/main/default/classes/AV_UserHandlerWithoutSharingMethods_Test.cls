/**********************************************************************************************************************
Name:	  AV_UserHandlerWithoutSharingMethods_Test
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_UserHandlerWithoutSharingMethods_Test"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	   AUTHOR		   	   DATE				Description
	1.0			IN1160717	   Manuel Ramos	   	   02/07/2024		Init version
	1.1         FIX040724844   Oscar Moreno        04/07/2024       Add executeUserTrigger and updateUsuarioAsociadoFuncionTest methods
***********************************************************************************************************************/
@istest
public with sharing class AV_UserHandlerWithoutSharingMethods_Test {
	
    /**
	 * Create Data to test.
	 */
	@TestSetup
	static void setup() {
        RecordType rt = AV_AppUtilities.getRecordType('Contact', 'CC_Empleado');
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'AV_Usuario_CaixaBank' LIMIT 1];
        List<User> users = new List<User>();
        List<Contact> contacts = new List<Contact>();
        List<AV_OfficePermission__c> permisos = new List<AV_OfficePermission__c>();
        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

        User u1 = new User(
			Alias = 'tsAlias1',
			Email ='test_1@test.dev',
			EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName_1',
			LanguageLocaleKey = 'es',
			LocaleSidKey = 'es',
			TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044_1',
            ProfileId = profileId.Id,
            UserName = 'gestor1@emailcaixa.com',
            AV_ExternalID__c = 'U0100002121',
			AV_Funcion__c = 'Oficina',
			IsActive = true
		);
		users.add(u1);

        User u2 = new User(
			Alias = 'tsAlias2',
			Email = 'test_2@test.dev',
			EmailEncodingKey = 'UTF-8',
			LastName = 'testLastName_2',
			LanguageLocaleKey = 'es',
			LocaleSidKey = 'es',
			TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044_2',
            ProfileId = profileId.Id,
			UserName = 'gestor2@emailcaixa.com',
            AV_ExternalID__c = 'U0100002123',
            AV_Funcion__c='SSCC',
			IsActive = true
		);
        users.add(u2);

        User u3 = new User(
			Alias = 'tsAlias3',
			Email = 'test_3@test.dev',
			EmailEncodingKey = 'UTF-8',
			LastName = 'testLastName_3',
			LanguageLocaleKey = 'es',
			LocaleSidKey = 'es',
			TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044_3',
            ProfileId = profileId.Id,
			UserName = 'gestor3@emailcaixa.com',
            AV_ExternalID__c = 'U0009008',
			AV_Funcion__c = 'Gestor',
			IsActive = true
		);
        users.add(u3);

        User u4 = new User(
			Alias = 'tsAlias4',
			Email = 'test_4@test.dev',
			EmailEncodingKey = 'UTF-8',
			LastName = 'testLastName_4',
			LanguageLocaleKey = 'es',
			LocaleSidKey = 'es',
			TimeZoneSidKey = 'Europe/Berlin',
            AV_NumeroOficinaEmpresa__c = '001-03044_4',
            ProfileId = profileId.Id,
			UserName = 'gestor4@emailcaixa.com',
            AV_ExternalID__c = 'U0009009',
			AV_Funcion__c = 'Gestor',
			IsActive = true
		);
        users.add(u4);

		System.runAs(userGcf){
			insert users;
		}

        Contact employee  = new Contact(
			LastName = 'testLastName_2',
			FirstName = 'Usuario',
			Email = 'test_2@test.dev',
			CC_Idioma__c = 'es',
			RecordTypeId = rt.Id,
			CC_Matricula__c = 'U0009003',
			AV_UsuarioAsociado__c = u2.Id,
			AV_DescFuncion__c = 'EMPLEADO'
		);
        contacts.add(employee);

        Contact employeeWithoutPermission  = new Contact(
			LastName = 'testLastName_3',
			FirstName = 'Usuario Inactivo',
			Email = 'test_3@test.dev',
			CC_Idioma__c = 'es',
			RecordTypeId = rt.Id,
			CC_Matricula__c = 'U0009009',
			AV_UsuarioAsociado__c = u3.Id,
			AV_DescFuncion__c = 'EMPLEADO'
		);
        contacts.add(employeeWithoutPermission);
		insert contacts;
       
        AV_OfficePermission__c userPermission = new AV_OfficePermission__c();
		userPermission.AV_Assigner__c = u1.Id;
        userPermission.AV_UsuarioCedido__c = u2.Id;
		permisos.add(userPermission);

        AV_OfficePermission__c userPermissionNoContact = new AV_OfficePermission__c();
		userPermissionNoContact.AV_Assigner__c = u1.Id;
        userPermissionNoContact.AV_UsuarioCedido__c = u4.Id;
        permisos.add(userPermissionNoContact);
        insert permisos;
    }
    
    /**
	 * Execute the Trigger class (AV_User_BU_TRHan) removes the permissions and association of the associated 
	 * user on contact when the user is deactivated bypassing user permissions.
	 */
	@isTest
	public static void prepareDeleteInactiveUserTestWithPermission() {
		
        User user = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND Alias = 'Admin 1' AND IsActive= true LIMIT 1];
		
		System.runAs(user){
			Test.startTest();
            User assigner = [SELECT Id FROM User WHERE Email = 'test_1@test.dev'];
            User assignedUser = [SELECT Id FROM User WHERE Email = 'test_2@test.dev'];
			assignedUser.IsActive = false;
			update assignedUser;
			Test.stopTest();

            Integer intUserPermissionUpdateCount = [SELECT COUNT() FROM AV_OfficePermission__c WHERE AV_UsuarioCedido__c =: assignedUser.Id AND AV_Assigner__c =: assigner.Id ];
            Integer intContactAssignedUserCount = [SELECT COUNT() FROM Contact WHERE AV_UsuarioAsociado__c =: assignedUser.Id];
			
            System.assertEquals(intUserPermissionUpdateCount, 0);
            System.assertEquals(intContactAssignedUserCount, 0);
		}
	}

    /**
	 * Execute the Trigger class (AV_User_BU_TRHan) removes the associated user on contact when the user is inactivated.
	 */
	@isTest
	public static void prepareDeleteInactiveUserTestNotPermission() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			Test.startTest();
			User assigner = [SELECT Id FROM User WHERE Email = 'test_1@test.dev'];
            User assignedUser = [SELECT Id FROM User WHERE Email = 'test_3@test.dev'];
			assignedUser.IsActive = false;
			update assignedUser;
			Test.stopTest();

            Integer intContactAssignedUserCount = [SELECT COUNT() FROM Contact WHERE AV_UsuarioAsociado__c =: assignedUser.Id];
			System.assertEquals(intContactAssignedUserCount, 0);
		}
	}

       /**
	 * Execute the Trigger class (AV_User_BU_TRHan) removes the associated user on contact when the user is inactivated.
	 */
	@isTest
	public static void prepareDeleteInactiveUserTestNoContact() {
		
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			Test.startTest();
			User assigner = [SELECT Id FROM User WHERE Email = 'test_1@test.dev'];
            User assignedUser = [SELECT Id FROM User WHERE Email = 'test_4@test.dev'];
			assignedUser.IsActive = false;
			update assignedUser;
			Test.stopTest();
            
            Integer intUserPermissionCount = [SELECT COUNT() FROM AV_OfficePermission__c WHERE AV_UsuarioCedido__c =: assignedUser.Id AND AV_Assigner__c =: assigner.Id ];
			System.assertEquals(intUserPermissionCount, 0);
		}
	}

	@isTest
	public static void updateUsuarioAsociadoFuncionTest() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			Contact contact = [SELECT Id, AV_JobLevels__c, AV_TipoCentro__c, AV_UsuarioAsociado__c FROM Contact WHERE Email = 'test_2@test.dev' LIMIT 1];
			Test.startTest();
			contact.AV_JobLevels__c = '120'; 
			Database.update(contact);
			Test.stopTest();
			User user = [SELECT Id, AV_Funcion__c FROM User WHERE AV_ExternalID__c = 'U0009008'];
			System.assertEquals(false, 'SSCC'.equals(user.AV_Funcion__c), 'Failed to update Contact.AV_JobLevels__c');
		}
	}

	
	@isTest
	public static void executeUserTrigger() {
		Test.startTest();
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		System.runAs(userGcf){
			Contact employee  = AV_TestHelper.createEmployee(null, userGcf);
			employee.AV_UsuarioAsociado__c = null;
			update employee;

			User assignedUser = [SELECT Id FROM User WHERE Email = 'test_4@test.dev'];
			assignedUser.IsActive = true;
			update assignedUser;
		}
		User user = AV_TestHelper.createUser('AV_Usuario_CaixaBank');
		Test.stopTest();
		System.assertNotEquals(null, user);
	}

}