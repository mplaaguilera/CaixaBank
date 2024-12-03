/**********************************************************************************************************************
Name:	  CIBE_UserTriggerHelper_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_UserTriggerHelper"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	    AUTHOR		   	    DATE				Description
	1.0			US394910	    Alex Campos			27/06/2022			Init version
	1.0			US542103		Lucía Muñoz			22/02/2023			Cobertura del método userRol

***********************************************************************************************************************/
@isTest
public with sharing class CIBE_UserTriggerHelper_Test {
    
    @testSetup
    public static void setup() {
        List<PermissionSetGroup> psgs = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName IN ('CIBE_GestorEMP', 'CIBE_GestorCIB', 'CIBE_GestorCIBEInterno')];
        List<String> psgIds = new List<String>();
        for(PermissionSetGroup psg : psgs) {
            psgIds.add(psg.Id);
        }
        Test.calculatePermissionSetGroup(psgIds);
		Contact empleado  = new Contact();
		empleado.LastName = 'Paco';
		empleado.FirstName = 'Pelaes';
		empleado.Email = 'pacoPelaes@emailcaixa.com';
		empleado.CC_Idioma__c = 'es';
		empleado.RecordTypeId = Schema.SObjectType.Contact.RecordTypeInfosByDeveloperName.get('CC_Empleado').getRecordTypeId(); 
		empleado.CC_Matricula__c = 'U46410';
		empleado.AV_UsuarioAsociado__c = null;
		empleado.AV_DescFuncion__c = 'EMPLEADO';
		insert empleado;
		account acc = new Account(Name = 'Test Account 1',
		AV_NumPerso__c = '123',
		AV_Negocio__c = 'CIB',
		RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByDeveloperName.get('CC_Cliente').getRecordTypeId());
		insert acc;
		AV_Book__c bk = CIBE_TestHelper.createPurse('12345');
		CIBE_TestHelper.createBookManagement(empleado, bk);
		CIBE_TestHelper.createBookMember(acc, bk);
    }
    
    /**
	 * Execute the Trigger class (AV_User_BI_TRHan) and check if the AV_UsuarioAsociado is correct.
	 */
	@isTest
	public static void executeUserBITrigger() {
		//Test Data
		Profile pr = [SELECT Id FROM Profile WHERE Name = 'CIBE_Gestor'];
		RecordType rt = AV_AppUtilities.getRecordType('Contact', 'CC_Empleado');

		Test.startTest();

        Account centro = AV_TestHelper.createCaixaCenter();
		System.runAs(new User(Id = UserInfo.getUserId())) {

		Contact empleado  = new Contact();
        empleado.AccountId = centro.Id;
		empleado.LastName = 'Alonso';
		empleado.FirstName = 'Diana';
		empleado.Email = 'empleadoalonso@emailcaixa.com';
		empleado.CC_Idioma__c = 'es';
		empleado.RecordTypeId = rt.Id;
		empleado.CC_Matricula__c = 'U0009003';
        empleado.AV_JobLevels__c = '120';
        empleado.AV_DescFuncion__c = 'Funcion Prueba';
		insert empleado;

		User usuario = new User();
		usuario.FirstName = 'Diana';
		usuario.LastName = 'Alonso';
		usuario.Username = 'dianaalonso@emailcaixa.com';
		usuario.Alias = 'dalon';
		usuario.TimeZoneSidKey = 'Europe/Paris';
		usuario.LocaleSidKey = 'es_ES';
		usuario.EmailEncodingKey = 'UTF-8';
		usuario.ProfileId = pr.Id;
		usuario.LanguageLocaleKey = 'es';
		usuario.Email ='empleadoalonso@caixabank.com';
		usuario.AV_ExternalID__c = 'U0009003';
		insert usuario;
		//Contact empleadoCreado = [select AV_UsuarioAsociado__c from Contact where AV_UsuarioAsociado__c=:usuario.Id];
		//System.assertEquals(empleadoCreado.AV_UsuarioAsociado__c, usuario.Id);
		
        empleado.AV_JobLevels__c = '110';
        empleado.AV_UsuarioAsociado__c = usuario.Id;
		update empleado;
        
		usuario.AV_ExternalID__c = 'X0009003';
		usuario.AV_Funcion__c = null;
		usuario.CIBE_Centro__c = null;
		usuario.CIBE_FuncionEmpleado__c = null;
		update usuario;
        
        usuario.AV_ExternalID__c = 'U0009003';
		update usuario;

        usuario = [SELECT Id, CIBE_Centro__c, CIBE_FuncionEmpleado__c FROM User WHERE AV_ExternalID__c = 'U0009003'];
		
        System.assert(String.isNotBlank(usuario.CIBE_Centro__c));
        System.assert(String.isNotBlank(usuario.CIBE_FuncionEmpleado__c));
		Test.stopTest();
		}
	}

 /**
	 * Execute the Trigger class (AV_User_BI_TRHan) and check if the AV_UsuarioAsociado is correct.
	 */
	@isTest
	public static void updatePermissionTest() {
		//Test Data
		Profile pr = [SELECT Id FROM Profile WHERE Name = 'CIBE_Gestor'];
		UserRole urC = [SELECT Id FROM UserRole WHERE DeveloperName = 'CIB' LIMIT 1];
		UserRole urE = [SELECT Id FROM UserRole WHERE DeveloperName = 'EMP' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {

			Test.startTest();
				User usuario = new User();
				usuario.FirstName = 'Diana';
				usuario.LastName = 'Alonso';
				usuario.Username = 'dianaalonso@emailcaixa.com';
				usuario.Alias = 'dalon';
				usuario.TimeZoneSidKey = 'Europe/Paris';
				usuario.LocaleSidKey = 'es_ES';
				usuario.EmailEncodingKey = 'UTF-8';
				usuario.ProfileId = pr.Id;
				usuario.LanguageLocaleKey = 'es';
				usuario.Email ='empleadoalonso@caixabank.com';
				usuario.AV_ExternalID__c = 'U0009003';
				usuario.UserRoleId = urC.id;
				insert usuario;

				List<PermissionSetAssignment> listPSA = [SELECT Id, PermissionSetId, PermissionSetGroupId, AssigneeId 
														FROM PermissionSetAssignment 
														WHERE AssigneeId =:usuario.Id AND Assignee.Profile.name =:CIBE_AppConstants.CIBE_GESTOR];
				
				System.assert(listPSA.size()>0);
				usuario.Email ='empleadoalonso@caixabankbi.com';
				usuario.UserRoleId = urE.id;
				update usuario;
			Test.stopTest();
		}
	}

	/**
	 * Execute the Trigger class (AV_User_BI_TRHan) and check if the AV_UsuarioAsociado is correct.
	 */
	@isTest
	public static void insertPermissionTest() {
		//Test Data
		Profile pr = [SELECT Id FROM Profile WHERE Name = 'CIBE_Gestor'];
        System.runAs(new User(Id = UserInfo.getUserId())) {
			Test.startTest();
				User usuario = new User();
				usuario.FirstName = 'Diana';
				usuario.LastName = 'Alonso';
				usuario.Username = 'empleadoalonso@caixabanktech.com';
				usuario.Alias = 'dalon';
				usuario.TimeZoneSidKey = 'Europe/Paris';
				usuario.LocaleSidKey = 'es_ES';
				usuario.EmailEncodingKey = 'UTF-8';
				usuario.ProfileId = pr.Id;
				usuario.LanguageLocaleKey = 'es';
				usuario.Email ='empleadoalonso@caixabanktech.com';
				usuario.AV_ExternalID__c = 'U0009004';
				insert usuario;

				List<PermissionSetAssignment> listPSA = [SELECT Id, PermissionSetId, PermissionSetGroupId, AssigneeId 
														FROM PermissionSetAssignment 
														WHERE AssigneeId =:usuario.Id AND Assignee.Profile.name =:CIBE_AppConstants.CIBE_GESTOR];
				
				System.assert(listPSA.size()>0);
			Test.stopTest();
		}
	}



	@isTest
	public static void userRolTest(){
		//User
		Profile profile = [SELECT Id FROM Profile WHERE Name = 'CIBE_Gestor'];
		UserRole role = [SELECT Id FROM UserRole WHERE DeveloperName = 'CIB' LIMIT 1];

		Contact contacto = new Contact();
				contacto.LastName = 'Test';
				contacto.CC_Matricula__c = 'U0122222';
				insert contacto;

		System.runAs(new User(Id = UserInfo.getUserId())) {
			
			Test.startTest();
			User usuario = new User();
				usuario.FirstName = 'Manuel';
				usuario.LastName = 'Garcia';
				usuario.Username = 'manuelgarcia@email.com';
				usuario.Alias = 'manugar';
				usuario.TimeZoneSidKey = 'Europe/Paris';
				usuario.LocaleSidKey = 'es_ES';
				usuario.EmailEncodingKey = 'UTF-8';
				usuario.ProfileId = profile.Id;
				usuario.LanguageLocaleKey = 'es';
				usuario.Email ='manuel@email.com.invalid';
				usuario.AV_ExternalID__c = contacto.CC_Matricula__c;
				usuario.UserRoleId = role.id;
				insert usuario;
			Test.stopTest();
			List<Contact> c = [SELECT Id, CIBE_EmpleadoCIB__c FROM Contact WHERE Id = :contacto.Id];
			System.assertEquals(true, c[0].CIBE_EmpleadoCIB__c);
		}

	}

	@isTest
	public static void executeUserAITrigger() {

        User usuario = AV_TestHelper.createUserSinInsert('CIBE_Gestor', 'U46410');
		List<CBK_Framework_Batch__c> cbkFJ = [Select id from CBK_Framework_Batch__c];
		system.debug('@@cbkFJ : '+cbkFJ);
        Test.startTest();
		List<CBK_Framework_Batch__c> cbkFJ2 = [Select id from CBK_Framework_Batch__c];
		system.debug('@@cbkFJ2 : '+cbkFJ2);
		//debe ser ejecutado por un admin que es el que crea los users
		System.runAs(new User(Id = UserInfo.getUserId())) {
        	insert usuario;
			List<CBK_Framework_Batch__c> cbkFJ3 = [Select id from CBK_Framework_Batch__c];
			system.debug('@@cbkFJ3 : '+cbkFJ3);
		}
		Test.stopTest();
		system.debug([SELECT ID, params__c FROM CBK_Framework_Batch__c where Class_Name__c = 'CIBE_PortfolioEmployee_Batch' LIMIT 1].params__c);	
        System.assertNotEquals([SELECT ID FROM CBK_Framework_Batch__c].size(), 0);	
        
	}

	@isTest
	public static void executeUserAUTrigger() {

        User usuario = CIBE_TestHelper.createUser('CIBE_Gestor');
		List<CBK_Framework_Batch__c> cbkFJ = [Select id from CBK_Framework_Batch__c];
		system.debug('@@cbkFJ : '+cbkFJ);
        Test.startTest();
		List<CBK_Framework_Batch__c> cbkFJ2 = [Select id from CBK_Framework_Batch__c];
		system.debug('@@cbkFJ2 : '+cbkFJ2);
		//debe ser ejecutado por un admin que es el que crea los users
		System.runAs(new User(Id = UserInfo.getUserId())) {
			usuario.AV_ExternalID__c = 'U46410';
			update usuario;
			List<CBK_Framework_Batch__c> cbkFJ3 = [Select id from CBK_Framework_Batch__c];
			system.debug('@@cbkFJ3 : '+cbkFJ3);
		}
		Test.stopTest();
		system.debug([SELECT ID, params__c FROM CBK_Framework_Batch__c where Class_Name__c = 'CIBE_PortfolioEmployee_Batch' LIMIT 1].params__c);	
        System.assertNotEquals([SELECT ID FROM CBK_Framework_Batch__c].size(), 0);	
        
	}

}