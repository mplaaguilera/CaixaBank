@isTest
public with sharing class SEG_Marca_Case_AI_TRHan_Test {
	@testSetup
	static void datosIniciales()
	{
		// Creación cuentas a tratar.
		Account cuentaSEG1 = new Account();
		cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
		cuentaSEG1.Name = 'Empresa segmentos';
		cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
		cuentaSEG1.CC_Numero_Documento__c = '11111111H';
		insert cuentaSEG1;

		// Crear contactos para cuentas SEG.
		Contact contactoSEG1 = new Contact();
		contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		contactoSEG1.LastName = 'Contacto SEG 1';
		contactoSEG1.AccountId = cuentaSEG1.Id;
		contactoSEG1.Email = 'test@test.com';
		insert contactoSEG1;

		// Crear casos de los clientes.
		List<Case> listadoCasos = new List<Case> ();

		Case caso1 = new Case();
		caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
		caso1.AccountId = cuentaSEG1.Id;
		caso1.ContactId = contactoSEG1.Id;
		caso1.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso1.SEG_Idioma__c = 'en';
		caso1.CC_AcuseRecibo__c = '1';
		caso1.Subject = 'Activo';
		caso1.Status = 'Pendiente';
		listadoCasos.add(caso1);

		Case caso2 = new Case();
		caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
		caso2.AccountId = cuentaSEG1.Id;
		caso2.ContactId = contactoSEG1.Id;
		caso2.CC_MailTelfNotif__c = contactoSEG1.Email;
		caso2.SEG_Idioma__c = 'es';
		caso2.CC_AcuseRecibo__c = '1';
		caso2.ParentId = caso1.Id;
		caso2.Status = 'Activo';
		caso2.Subject = 'test 2';
		listadoCasos.add(caso2);
		insert listadoCasos;

		Id recordTypeMarcasCaso = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SEG_Caracteristicacaso').getRecordTypeId();
		List<CC_Caracteristica__c> lstCar = new List<CC_Caracteristica__c> ();
		CC_Caracteristica__c car1 = new CC_Caracteristica__c();
		car1.RecordTypeId = recordTypeMarcasCaso;
		car1.CC_Descripcion__c = 'Caracteristica Test';
		car1.Name = 'TestCaracteristica1';
		car1.OS_Negocio__c = 'SEGMENTOS';
		insert car1;
		CC_Caracteristica__c car2 = new CC_Caracteristica__c();
		car2.RecordTypeId = recordTypeMarcasCaso;
		car2.CC_Descripcion__c = 'Caracteristica Test2';
		car2.Name = 'TestCaracteristica2';
		car2.OS_Negocio__c = 'SEGMENTOS';
		insert car2;

		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			//Creación de usuario segmentos
			Profile p = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
			UserRole r = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
			User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com', 
				emailencodingkey='UTF-8', lastname='Smith', 
				languagelocalekey='en_US', 
				localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
				timezonesidkey='America/Los_Angeles', 
				username='testSEGBI@acme.com',
				SEG_Tipo_usuario_SEG__c = 'CSO',
				SEG_TipousuarioCSO__c = 'General');
				insert thisUser;	
		
		PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SEG_Operativo'];
		insert new PermissionSetAssignment(AssigneeId = thisUser.id, PermissionSetId = ps.Id);
		}
	}

	@isTest
	public static void insertarMarcaCase()
	{
		
		List<Case> lstcaso = [SELECT Id, OwnerId FROM Case];
		List<CC_Caracteristica__c> lsCara = [SELECT Id FROM CC_Caracteristica__c];
		List<SEG_Marcasdeuncaso__c> lstMarcaCase = new List<SEG_Marcasdeuncaso__c> ();
		SEG_Marcasdeuncaso__c marcaCase;

		User thisUser = [SELECT Id FROM User WHERE alias = 'tsegmen' LIMIT 1];

		for (Case cs : lstcaso) {
			for (CC_Caracteristica__c car : lsCara) {
				marcaCase = new SEG_Marcasdeuncaso__c();
				marcaCase.SEG_Caso__c = cs.Id;
				marcaCase.SEG_Caracteristica__c = car.Id;
				lstMarcaCase.add(marcaCase);
			}
		}
		insert lstMarcaCase;
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {

			Test.startTest();
			Test.stopTest();
	
			System.assertNotEquals(lstcaso,null,'SEG_Marca_Case_AI_TRHan_Test');
	
			}
	}

	@isTest
	public static void insertarMarcaCase2()
	{
	
		List<Case> lstcaso = [SELECT Id, OwnerId FROM Case];

		User thisUser = [SELECT Id FROM User WHERE alias = 'tsegmen' LIMIT 1];
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {

			Id recordTypeMarcasCaso = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SEG_Caracteristicacaso').getRecordTypeId();
			Id recordTypeGrupo = Schema.SObjectType.SEG_ServiciosCSO__c.getRecordTypeInfosByDeveloperName().get('Marca').getRecordTypeId();

			List<CC_Caracteristica__c> lstCar = new List<CC_Caracteristica__c> ();

			CC_Caracteristica__c car1 = new CC_Caracteristica__c();
			car1.RecordTypeId = recordTypeMarcasCaso;
			car1.CC_Descripcion__c = 'Caracteristica Test';
			car1.Name = 'TestCaracteristica1';
			car1.OS_Negocio__c = 'SEGMENTOS';

			insert car1;

			SEG_ServiciosCSO__c servCsoGrupo = new SEG_ServiciosCSO__c();
			servCsoGrupo.SEG_Activo__c = true;
			servCsoGrupo.RecordTypeId = recordTypeGrupo;
			servCsoGrupo.SEG_Organizacion__c = 'Banca Corporativa;Instituciones';
			servCsoGrupo.SEG_Zona__c = 'Corporativa';
			servCsoGrupo.SEG_TMO__c = 10;
			servCsoGrupo.Name = 'Test Grupo';
			insert servCsoGrupo;

			SEG_MarcasCSO__c marcaCSO = new SEG_MarcasCSO__c();
			marcaCSO.SEG_Marca__c = car1.id;
			marcaCSO.SEG_ServiciosCSO__c = servCsoGrupo.id;
			insert marcaCSO;

			Test.startTest();
			SEG_Marcasdeuncaso__c marcaCase = new SEG_Marcasdeuncaso__c();
				marcaCase.SEG_Caso__c = lstcaso[0].Id;
				marcaCase.SEG_Caracteristica__c = car1.Id;
				insert marcaCase;
			Test.stopTest();
	
			System.assertNotEquals(lstcaso,null,'SEG_Marca_Case_AI_TRHan_Test');
	
		}
	}
}