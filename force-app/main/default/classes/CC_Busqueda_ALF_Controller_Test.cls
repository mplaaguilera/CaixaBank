@IsTest
public with sharing class CC_Busqueda_ALF_Controller_Test {

	@TestSetup
	static void makeData() {
		User usuario = new User();
		usuario.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
		usuario.profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
		usuario.FirstName = 'Usuario supervisor Prueba1';
		usuario.LastName = 'last211';
		usuario.Email = 'tuser000@amamama.com';
		usuario.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
		usuario.CompanyName = 'MST';
		usuario.Title = 'title';
		usuario.Alias = 'alias';
		usuario.TimeZoneSidKey = 'Europe/Paris';
		usuario.EmailEncodingKey = 'UTF-8';
		usuario.LanguageLocaleKey = 'es';
		usuario.LocaleSidKey = 'es_ES';
		User usuarioAdmin = new User();
		usuarioAdmin.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
		usuarioAdmin.profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
		usuarioAdmin.LastName = 'Admin';
		usuarioAdmin.Email = 'tuser001@amamama.com';
		usuarioAdmin.Username = 'admin_test@amamama.com' + System.currentTimeMillis();
		usuarioAdmin.CompanyName = 'MST';
		usuarioAdmin.Title = 'title';
		usuarioAdmin.Alias = 'alias';
		usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
		usuarioAdmin.EmailEncodingKey = 'UTF-8';
		usuarioAdmin.LanguageLocaleKey = 'es';
		usuarioAdmin.LocaleSidKey = 'es_ES';
		insert new List<User>{usuario, usuarioAdmin};

		PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
		PermissionSet ccClases = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
		PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = usuario.Id, PermissionSetId = psOperadorCliente.Id);
		PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = usuario.Id, PermissionSetId = ccClases.Id);
		PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = psOperadorCliente.Id);
		PermissionSetAssignment psa4 = new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = ccClases.Id);
		insert new List<PermissionSetAssignment>{psa1, psa2, psa3, psa4};
	}

	@isTest
	static void test01SetClienteCaso01() {
		/*
		// Crear cuentas.
		List<Account> oCuentas = new List<Account>{
				new Account(name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991'),
				new Account(name='Test02',CC_Numero_Documento__c='09881783V',CC_NumPerso__c = '99999992'),
				new Account(name='Test03',CC_Numero_Documento__c='06898789P',CC_NumPerso__c = '99999993'),
				new Account(name='Test05',CC_Numero_Documento__c='71234771E'),
				new Account(name='Test07',CC_Numero_Documento__c='15197951B')
				};
		insert oCuentas;

		// Crear contactos.
		List<Contact> oContacts = new List<Contact>{
				new Contact(LastName='Test01',CC_NumPerso__c = '99999991', Account=new Account(CC_NumPerso__c = '99999991')),
				new Contact(LastName='Test02',CC_NumPerso__c = '99999992', Account=new Account(CC_NumPerso__c = '99999992')),
				new Contact(LastName='Test03',Account=new Account(CC_NumPerso__c = '99999993')),
				new Contact(LastName='Test04'),
				new Contact(LastName='Test06')
				};
		insert oContacts;
		*/

		User usuario1 = [SELECT Id FROM User WHERE FirstName = 'Usuario supervisor Prueba1' LIMIT 1];
		System.runAs(usuario1) {
			Account cuenta = new Account();
			cuenta.Name = 'Test01';
			cuenta.CC_Numero_Documento__c = '12345678Z';
			cuenta.CC_NumPerso__c = '99999991';
			insert cuenta;

			Contact contacto = new Contact();
			contacto.LastName = 'Test01';
			contacto.CC_NumPerso__c = '99999991';
			contacto.Account = cuenta;
			insert contacto;

			Case caso = new Case();
			caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			caso.Subject = 'Test01';
			caso.Description = 'Prueba2';
			caso.Status = 'Activo';
			caso.Origin = 'Comentarios Stores';
			caso.CC_Idioma__c = 'es';
			caso.CC_Tipo_Contacto__c = 'Consulta';
			caso.CC_Tipo_Cliente__c = 'Cliente';
			caso.CC_Canal_Procedencia__c = 'Google Play Store';
			caso.Account = cuenta;
			caso.Contact = contacto;
			insert caso;

			/*
			List<Case> oCasos = new List<Case>{
				new Case(Subject='Test01',Description = 'Prueba2',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
						Account=new Account(CC_NumPerso__c = '99999991'),Contact=new Contact(CC_NumPerso__c = '99999991')),
				new Case(Subject='Test02',Description = 'Prueba3',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
						Account=new Account(CC_NumPerso__c = '99999992'),Contact=new Contact(CC_NumPerso__c = '99999992')),
				new Case(Subject='Test03',Description = 'Prueba4',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
						Account=new Account(CC_NumPerso__c = '99999993')),
				new Case(Subject='Test04',Description = 'Prueba5',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
				new Case(Subject='Test05',Description = 'Prueba6',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
				new Case(Subject='Test06',Description = 'Prueba7',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
				new Case(Subject='Test07',Description = 'Prueba',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store')
			};
			insert oCasos;
			*/

			Test.startTest();
			CC_Busqueda_ALF_Controller.setClienteCaso('', '', '');
			CC_Busqueda_ALF_Controller.setClienteCaso('x', 'x', '');
			CC_Busqueda_ALF_Controller.setClienteCaso(contacto.Id, 'Contacto', caso.Id);
			Test.stopTest();

			System.assertEquals('PENDIENTE', 'PENDIENTE', 'PENDIENTE');
		}
	}

	@isTest
	private static void test01setClienteRepresentante() {
		User usuario1 = [SELECT Id FROM User WHERE FirstName = 'Usuario supervisor Prueba1' LIMIT 1];
		System.runAs(usuario1){

			Id recordTypeCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
			Account cuenta2 = new Account();
			cuenta2.FirstName = 'TestRepresentante';
			cuenta2.LastName = '2';
			cuenta2.CC_Numero_Documento__c = '05766562W';
			cuenta2.CC_NumPerso__c = '99999900';
			cuenta2.RecordTypeId = recordTypeCliente;
			cuenta2.CC_TipoPersona__c = 'F';
			cuenta2.CC_Confidencial__c = false;
			insert cuenta2;


			CC_Representante_Contrato__c representanteContrato1 = new CC_Representante_Contrato__c();
			representanteContrato1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
			representanteContrato1.CC_ClienteRepresentante__c = cuenta2.Id;
			insert representanteContrato1;

			CC_Representante_Contrato__c representanteContrato2 = new CC_Representante_Contrato__c();
			representanteContrato2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
			representanteContrato2.CC_RepresentanteAsociado__c = representanteContrato1.Id;
			insert representanteContrato2;

			//List<CC_Busqueda_ALF_Controller.RepresentanteOrContactoWrapper> resultado2 = CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(cuenta2.Id);

			Account cuentaMenor = new Account();
			cuentaMenor.FirstName = 'Menor';
			cuentaMenor.LastName = '2';
			cuentaMenor.CC_Numero_Documento__c = '36231292J';
			cuentaMenor.CC_NumPerso__c = '99999903';
			cuentaMenor.RecordTypeId = recordTypeCliente;
			cuentaMenor.CC_TipoPersona__c = 'F';
			cuentaMenor.CC_FechaNac__pc  = Date.newInstance(2020, 09,01);
			insert cuentaMenor;

			CC_Representante_Contrato__c representanteContratoMenor = new CC_Representante_Contrato__c();
			representanteContratoMenor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
			representanteContratoMenor.CC_ClienteRepresentante__c = cuentaMenor.Id;
			representanteContratoMenor.CC_Representante__c = cuenta2.Id;
			insert representanteContratoMenor;

			Case casoRepresentante = new Case();
			casoRepresentante.Subject='TestRepresentante';
			casoRepresentante.Description = 'Prueba2';
			casoRepresentante.Status = 'Activo';
			casoRepresentante.Origin = 'Phone';
			casoRepresentante.CC_Idioma__c = 'es';
			casoRepresentante.CC_Tipo_Contacto__c = 'Consulta';
			casoRepresentante.CC_Tipo_Cliente__c = 'Cliente';
			casoRepresentante.CC_Canal_Procedencia__c = 'ImaginBank ';
			//casoRepresentante.AccountId = cuentaMenor.Id;
			casoRepresentante.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
			insert casoRepresentante;


			Id recordTypeLlamada = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_Cliente');

			CC_Llamada__c llamada = new CC_Llamada__c();
			llamada.RecordTypeId = recordTypeLlamada;
			insert llamada;


			Case oCaso = [SELECT Id, ContactId FROM Case WHERE Subject = 'TestRepresentante'];

			Account cuentaRepresentante = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '05766562W' AND CC_NumPerso__c = '99999900'];
			CC_Representante_Contrato__c representante = [SELECT Id FROM CC_Representante_Contrato__c WHERE CC_Representante__c = :cuentaRepresentante.Id];


			// Contact oContacto = [SELECT Id FROM Contact WHERE AccountId = :cuentaRepresentante.Id LIMIT 1];

			Test.startTest();
			CC_Busqueda_ALF_Controller.setClienteCaso (representante.Id, 'Representante', oCaso.Id);
			CC_Busqueda_ALF_Controller.setClienteLlamada(representante.Id, 'Representante', llamada.Id);
			Test.stopTest();

			oCaso = [SELECT CC_Representante__c FROM Case WHERE Subject = 'TestRepresentante'];
			System.assertEquals(oCaso.CC_Representante__c, representante.Id, 'El representante se asocia al caso');
		}
	}


	@isTest
	static void test01setClienteCaso02() {
		/*
		// Crear cuentas y contactos
		List<Account> oCuentas = new List<Account>{
			new Account(name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991'),
			new Account(name='Test02',CC_Numero_Documento__c='09881783V',CC_NumPerso__c = '99999992'),
			new Account(name='Test03',CC_Numero_Documento__c='06898789P',CC_NumPerso__c = '99999993'),
			new Account(name='Test05',CC_Numero_Documento__c='71234771E'),
			new Account(name='Test07',CC_Numero_Documento__c='15197951B')
		};
		insert oCuentas;

		List<Contact> oContacts = new List<Contact>{
			new Contact(LastName='Test01',CC_NumPerso__c = '99999991', Account=new Account(CC_NumPerso__c = '99999991')),
			new Contact(LastName='Test02',CC_NumPerso__c = '99999992', Account=new Account(CC_NumPerso__c = '99999992')),
			new Contact(LastName='Test03',Account=new Account(CC_NumPerso__c = '99999993')),
			new Contact(LastName='Test04'),
			new Contact(LastName='Test06')
		};
		insert oContacts;

		// Crear casos.
		List<Case> oCasos = new List<Case>{
			new Case(Subject='Test01',Description = 'Prueba2',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
				CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
				Account=new Account(CC_NumPerso__c = '99999991'),Contact=new Contact(CC_NumPerso__c = '99999991')),
			new Case(Subject='Test02',Description = 'Prueba3',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
				CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
				Account=new Account(CC_NumPerso__c = '99999992'),Contact=new Contact(CC_NumPerso__c = '99999992')),
			new Case(Subject='Test03',Description = 'Prueba4',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
				CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
				Account=new Account(CC_NumPerso__c = '99999993')),
			new Case(Subject='Test04',Description = 'Prueba5',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
				CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
			new Case(Subject='Test05',Description = 'Prueba6',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
				CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
			new Case(Subject='Test06',Description = 'Prueba7',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
				CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
			new Case(Subject='Test07',Description = 'Prueba',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
				CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store')
		};
		insert oCasos;
		*/
		User usuarioAdmin = [SELECT Id FROM User WHERE LastName = 'Admin' LIMIT 1];
		System.runAs(usuarioAdmin) {

			Account cuenta1 = new Account();
			cuenta1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
			cuenta1.LastName = 'Test01';
			cuenta1.CC_Numero_Documento__c = '12345678Z';
			cuenta1.CC_NumPerso__c = '99999991';
			Account cuenta2 = new Account();
			cuenta2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
			cuenta2.LastName = 'Test02';
			cuenta2.CC_Numero_Documento__c = '09881783V';
			cuenta2.CC_NumPerso__c = '99999992';
			Account cuenta3 = new Account();
			cuenta3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
			cuenta3.LastName = 'Test03';
			cuenta3.CC_Numero_Documento__c = '06898789P';
			cuenta3.CC_NumPerso__c = '99999993';
			Account cuenta4 = new Account();
			cuenta4.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
			cuenta4.LastName = 'Test04';
			insert new List<Account>{cuenta1, cuenta2, cuenta3, cuenta4};

			/*
			AccountShare cuentaShare1 = new AccountShare();
			cuentaShare1.AccountId = cuenta1.Id;
			cuentaShare1.UserOrGroupId = usuarioAdmin.Id;
			cuentaShare1.AccountAccessLevel = 'Edit';
			cuentaShare1.CaseAccessLevel = 'Edit';
			cuentaShare1.OpportunityAccessLevel = 'Edit';
			AccountShare cuentaShare2 = new AccountShare();
			cuentaShare2.AccountId = cuenta2.Id;
			cuentaShare2.UserOrGroupId = usuarioAdmin.Id;
			cuentaShare2.AccountAccessLevel = 'Edit';
			cuentaShare2.CaseAccessLevel = 'Edit';
			cuentaShare2.OpportunityAccessLevel = 'Edit';
			AccountShare cuentaShare3 = new AccountShare();
			cuentaShare3.AccountId = cuenta3.Id;
			cuentaShare3.UserOrGroupId = usuarioAdmin.Id;
			cuentaShare3.AccountAccessLevel = 'Edit';
			cuentaShare3.CaseAccessLevel = 'Edit';
			cuentaShare3.OpportunityAccessLevel = 'Edit';
			insert new List<AccountShare>{cuentaShare1, cuentaShare2, cuentaShare3};

			Id idRecordTypeContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			Contact contacto1 = new Contact();
			contacto1.RecordTypeId = idRecordTypeContact;
			contacto1.LastName = 'Test01';
			contacto1.CC_NumPerso__c = '99999991';
			contacto1.AccountId	 = cuenta1.Id;
			Contact contacto2 = new Contact();
			contacto2.RecordTypeId = idRecordTypeContact;
			contacto2.LastName = 'Test02';
			contacto2.CC_NumPerso__c = '99999992';
			contacto2.AccountId = cuenta2.Id;
			Contact contacto3 = new Contact();
			contacto3.RecordTypeId = idRecordTypeContact;
			contacto3.LastName = 'Test03';
			contacto3.CC_NumPerso__c = '99999993';
			contacto3.AccountId = cuenta3.Id;
			Contact contacto4 = new Contact();
			contacto4.RecordTypeId = idRecordTypeContact;
			contacto4.LastName = 'Test04';
			insert new List<Contact>{contacto1, contacto2, contacto3, contacto4};

			ContactShare contactoShare1 = new ContactShare();
			contactoShare1.ContactId = contacto1.Id;
			contactoShare1.UserOrGroupId = usuarioAdmin.Id;
			contactoShare1.ContactAccessLevel = 'Edit';
			ContactShare contactoShare2 = new ContactShare();
			contactoShare2.ContactId = contacto2.Id;
			contactoShare2.UserOrGroupId = usuarioAdmin.Id;
			contactoShare2.ContactAccessLevel = 'Edit';
			ContactShare contactoShare3 = new ContactShare();
			contactoShare3.ContactId = contacto3.Id;
			contactoShare3.UserOrGroupId = usuarioAdmin.Id;
			contactoShare3.ContactAccessLevel = 'Edit';
			ContactShare contactoShare4 = new ContactShare();
			contactoShare4.ContactId = contacto4.Id;
			contactoShare4.UserOrGroupId = usuarioAdmin.Id;
			contactoShare4.ContactAccessLevel = 'Edit';
			insert new List<ContactShare>{contactoShare1, contactoShare2, contactoShare3, contactoShare4};
			*/

			Id idRecordTypeCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			Case caso1 = new Case();
			caso1.RecordTypeId = idRecordTypeCliente;
			caso1.Subject = 'Test01';
			caso1.Description = 'Prueba2';
			caso1.Status = 'Activo';
			caso1.Origin = 'Comentarios Stores';
			caso1.CC_Idioma__c = 'es';
			caso1.CC_Tipo_Contacto__c = 'Consulta';
			caso1.CC_Tipo_Cliente__c = 'Cliente';
			caso1.CC_Canal_Procedencia__c = 'Google Play Store';
			caso1.AccountId = cuenta1.Id;
			// caso1.ContactId = contacto1.Id;
			Case caso2 = new Case();
			caso2.RecordTypeId = idRecordTypeCliente;
			caso2.Subject = 'Test02';
			caso2.Description = 'Prueba3';
			caso2.Status = 'Activo';
			caso2.Origin = 'Comentarios Stores';
			caso2.CC_Idioma__c = 'es';
			caso2.CC_Tipo_Contacto__c = 'Consulta';
			caso2.CC_Tipo_Cliente__c = 'Cliente';
			caso2.CC_Canal_Procedencia__c = 'Google Play Store';
			caso2.AccountId = cuenta2.Id;
			// caso2.ContactId = contacto2.Id;
			Case caso3 = new Case();
			caso3.RecordTypeId = idRecordTypeCliente;
			caso3.Subject='Test03';
			caso3.Description = 'Prueba4';
			caso3.Status = 'Activo';
			caso3.Origin = 'Comentarios Stores';
			caso3.CC_Idioma__c = 'es';
			caso3.CC_Tipo_Contacto__c = 'Consulta';
			caso3.CC_Tipo_Cliente__c = 'Cliente';
			caso3.CC_Canal_Procedencia__c = 'Google Play Store';
			caso3.AccountId = cuenta3.Id;
			// caso3.ContactId = contacto3.Id;
			Case caso4 = new Case();
			caso4.RecordTypeId = idRecordTypeCliente;
			caso4.Subject = 'Test04';
			caso4.Description = 'Prueba5';
			caso4.Status = 'Activo';
			caso4.Origin = 'Comentarios Stores';
			insert new List<Case>{caso1, caso2, caso3, caso4};

			/*
			CaseShare casoShare1 = new CaseShare();
			casoShare1.CaseId = caso1.Id;
			casoShare1.UserOrGroupId = usuarioAdmin.Id;
			casoShare1.CaseAccessLevel = 'Edit';
			CaseShare casoShare2 = new CaseShare();
			casoShare2.CaseId = caso2.Id;
			casoShare2.UserOrGroupId = usuarioAdmin.Id;
			casoShare2.CaseAccessLevel = 'Edit';
			CaseShare casoShare3 = new CaseShare();
			casoShare3.CaseId = caso3.Id;
			casoShare3.UserOrGroupId = usuarioAdmin.Id;
			casoShare3.CaseAccessLevel = 'Edit';
			CaseShare casoShare4 = new CaseShare();
			casoShare4.CaseId = caso4.Id;
			casoShare4.UserOrGroupId = usuarioAdmin.Id;
			casoShare4.CaseAccessLevel = 'Edit';
			insert new List<CaseShare>{casoShare1, casoShare2, casoShare3, casoShare4};
			*/

			Test.startTest();
			//Vincular cuenta identificada en origen y destino.
			CC_Busqueda_ALF_Controller.setClienteCaso(cuenta2.Id, 'Cuenta', caso2.Id);
			//Vincular cuenta identificada en origen y destino (empresa)
			caso3.AccountId = cuenta3.Id;
			update caso3;
			CC_Busqueda_ALF_Controller.setClienteCaso(cuenta2.Id, 'Cuenta', caso3.Id);
			//Vincular cuenta identificada en origen (contacto sin cuenta) y destino (empresa)
			caso4.AccountId = cuenta4.Id;
			update caso4;
			CC_Busqueda_ALF_Controller.setClienteCaso(cuenta2.Id, 'Cuenta', caso4.Id);
			Test.stopTest();

			System.assertEquals('PENDIENTE', 'PENDIENTE', 'PENDIENTE');
		}
	}

	@isTest
	static void test01setClienteCaso03() {
		User usuario1 = [SELECT Id FROM User WHERE FirstName = 'Usuario supervisor Prueba1' LIMIT 1];
		System.runAs(usuario1) {

		// Crear cuentas.
		List<Account> oCuentas = new List<Account>{
				new Account(name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991'),
				new Account(name='Test02',CC_Numero_Documento__c='09881783V',CC_NumPerso__c = '99999992'),
				new Account(name='Test03',CC_Numero_Documento__c='06898789P',CC_NumPerso__c = '99999993'),
				new Account(name='Test05',CC_Numero_Documento__c='71234771E'),
				new Account(name='Test07',CC_Numero_Documento__c='15197951B')
				};
		insert oCuentas;

		// Crear contactos.
		List<Contact> oContacts = new List<Contact>{
				new Contact(LastName='Test01',CC_NumPerso__c = '99999991', Account=new Account(CC_NumPerso__c = '99999991')),
				new Contact(LastName='Test02',CC_NumPerso__c = '99999992', Account=new Account(CC_NumPerso__c = '99999992')),
				new Contact(LastName='Test03',Account=new Account(CC_NumPerso__c = '99999993')),
				new Contact(LastName='Test04'),
				new Contact(LastName='Test06')
				};
		insert oContacts;

		// Crear casos.
		List<Case> oCasos = new List<Case>{
			new Case(Subject='Test01',Description = 'Prueba2',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
						Account=new Account(CC_NumPerso__c = '99999991'),Contact=new Contact(CC_NumPerso__c = '99999991')),
			new Case(Subject='Test02',Description = 'Prueba3',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
						Account=new Account(CC_NumPerso__c = '99999992'),Contact=new Contact(CC_NumPerso__c = '99999992')),
			new Case(Subject='Test03',Description = 'Prueba4',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store',
						Account=new Account(CC_NumPerso__c = '99999993')),
			new Case(Subject='Test04',Description = 'Prueba5',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
			new Case(Subject='Test05',Description = 'Prueba6',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
			new Case(Subject='Test06',Description = 'Prueba7',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store'),
			new Case(Subject='Test07',Description = 'Prueba',Status = 'Activo',Origin = 'Comentarios Stores',CC_Idioma__c = 'es',
						CC_Tipo_Contacto__c = 'Consulta',CC_Tipo_Cliente__c = 'Cliente',CC_Canal_Procedencia__c = 'Google Play Store')
			};
		insert oCasos;

		Account oAcc;
		Contact oCont;
		Case oCaso;

		// Vincular cuenta identificada en origen (cuenta sin contacto) y destino (empresa)
		oCaso = [SELECT Id FROM Case WHERE Subject = 'Test05'];
		oAcc = [SELECT Id FROM Account WHERE Name = 'Test05'];
		oCaso.AccountId = oAcc.Id;
		update oCaso;
		oCont = [SELECT Id FROM Contact WHERE LastName = 'Test02'];
		CC_Busqueda_ALF_Controller.setClienteCaso (oCont.Id, 'Contacto', oCaso.Id);

		// Vincular cuenta identificada en origen (contacto sin cuenta) y destino (particular)
		oCaso = [SELECT Id FROM Case WHERE Subject = 'Test06'];
		oCont = [SELECT Id FROM Contact WHERE LastName = 'Test06'];
		oCaso.ContactId = oCont.Id;
		update oCaso;
		oAcc = [SELECT Id FROM Account WHERE Name = 'Test01'];
		CC_Busqueda_ALF_Controller.setClienteCaso (oAcc.Id, 'Cuenta', oCaso.Id);

		System.assertEquals(oCaso.ContactId,oCont.Id);

		// Vincular cuenta identificada en origen (cuenta sin identificar) y destino (particular)
		//oCaso = [SELECT Id FROM Case WHERE Subject = 'Test07'];
		//oAcc = [SELECT Id FROM Account WHERE Name = 'Test07'];
		//oCaso.AccountId = oAcc.Id;
		//update oCaso;
		//oAcc = [SELECT Id FROM Account WHERE Name = 'Test01'];
		//CC_Busqueda_ALF_Controller.setClienteCaso(oAcc.Id, 'Cuenta', oCaso.Id);
		}
	}

	@isTest
	static void test02getIdentidad() {
		Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_01());

		User usuarioAdmin = [SELECT Id FROM User WHERE LastName = 'Admin' LIMIT 1];
		System.runAs(usuarioAdmin) {
			Account cuenta1 = new Account();
			cuenta1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta1.name = 'Test01';
			cuenta1.CC_Numero_Documento__c = '12345678Z';
			cuenta1.CC_NumPerso__c = '99999991';
			insert cuenta1;

			Contact contacto1 = new Contact();
			contacto1.Account = new Account(CC_NumPerso__c = '99999991');
			contacto1.LastName = 'Test01';
			contacto1.CC_NumPerso__c = '99999991';
			insert contacto1;

			Test.startTest();
			Map<String, Object> data = CC_Busqueda_ALF_Controller.getIdentidad('DOC', '12345678Z');
			List<Account> dataCuentas = (List<Account>)data.get('CUENTAS');
			Test.stopTest();

			System.assertEquals(1, dataCuentas.size());
			List<Object> oListaCont = CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(cuenta1.Id);
			System.assertEquals(oListaCont.size(), 1);
		}
	}

	@isTest
	static void test03getIdentidad() {
		Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_01());

		User usuarioAdmin = [SELECT Id FROM User WHERE LastName = 'Admin' LIMIT 1];
		System.runAs(usuarioAdmin) {
			Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			Account cuenta1 = new Account();
			cuenta1.name = 'Test01';
			cuenta1.CC_Numero_Documento__c = '12345678Z';
			cuenta1.CC_NumPerso__c = '99999991';
			cuenta1.RecordTypeId = recordTypeIdCliente;
			insert cuenta1;

			Contact contacto1 = new Contact();
			contacto1.LastName = 'Test01';
			contacto1.CC_NumPerso__c = '99999991';
			contacto1.Account = new Account(CC_NumPerso__c = '99999991');
			insert contacto1;

			// Crear canal comunicación.
			String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
			CC_Canal_Com__c c1 = new CC_Canal_Com__c();
			c1.CC_NumPerso__c = '99999991';
			c1.CC_ContactoId__c = contacto1.Id;
			c1.CC_CuentaId__c = cuenta1.Id;
			c1.CC_Telefono__c = '938500000';
			c1.RecordTypeId = sRecordType1;
			insert c1;

			Test.startTest();
			Map<String,Object> oData = CC_Busqueda_ALF_Controller.getIdentidad ('TEL', '938500000');
			Test.stopTest();

			System.assertEquals(1, ((List<Account>)oData.get('CUENTAS')).size());
		}
	}

	@isTest
	private static void test04controlVacios() {
		// Control de datos vacíos.
		User usuario1 = [SELECT Id FROM User WHERE FirstName = 'Usuario supervisor Prueba1' LIMIT 1];
		System.runAs(usuario1) {
			Test.startTest();
			Map<String,Object> oData = CC_Busqueda_ALF_Controller.getIdentidad ('', '');
			List<Object> oListaCont = CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente('');
			Test.stopTest();

			System.assertEquals(oData, null);
			System.assertEquals(oListaCont, null);
		}
	}

	@isTest
	private static void buscarCasos() {
		Case c = new Case();
		c.Subject = 'Prueba';
		c.Description = 'Prueba';
		c.Status = 'Activo';
		c.Origin = 'Comentarios Stores';
		c.CC_Idioma__c = 'es';
		c.CC_Tipo_Contacto__c = 'Consulta';
		c.CC_Tipo_Cliente__c = 'Cliente';
		c.CC_Canal_Procedencia__c = 'Google Play Store';
		insert c;

		Case cs = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c='Google Play Store' LIMIT 1];
		SocialPost socPost = New SocialPost();
		socPost.Content = 'Prueba';
		socPost.Handle = 'oskiki';
		socPost.ParentId = cs.Id;
		//socPost.PersonaId = '';
		socPost.Provider = 'Other';
		socPost.Name = 'Prueba';
		socPost.IsOutbound = true;
		insert socPost;

		SocialPost sPost = [SELECT Id,PersonaId FROM SocialPost WHERE Name='Prueba' LIMIT 1];
		SocialPersona persona = New SocialPersona();
		persona.Name = 'oskiki';
		persona.RealName = 'Oscar';
		persona.Provider='Other';
		persona.ParentId = sPost.Id;
		insert persona;
		SocialPersona sp1 = [SELECT Id FROM SocialPersona WHERE RealName = 'Oscar' LIMIT 1];
		sPost.PersonaId= sp1.Id;
		update sPost;

		User usuario1 = [SELECT Id FROM User WHERE FirstName = 'Usuario supervisor Prueba1' LIMIT 1];
		System.runAs(usuario1) {
			Test.startTest();
			SocialPersona sp = [SELECT Id FROM SocialPersona WHERE RealName = 'Oscar' LIMIT 1];
			List<DataTableWrapper> response = new List<DataTableWrapper>();
			CC_Busqueda_ALF_Controller.buscarCasos(sp.Id);
			Test.stopTest();

			System.assertNotEquals(null, sp);
		}
	}

	public class DataTableWrapper {
		@AuraEnabled
		public Id caseId {get;set;}
		@AuraEnabled
		public String caseNumber {get;set;}
		@AuraEnabled
		public String caseNumberUrl {get;set;}
		@AuraEnabled
		public String status {get;set;}
		@AuraEnabled
		public String subject {get;set;}
		@AuraEnabled
		public String origin {get;set;}
	}

	@isTest
	private static void buscarPersona() {
		User usuario1 = [SELECT Id FROM User WHERE FirstName = 'Usuario supervisor Prueba1' LIMIT 1];
		System.runAs(usuario1) {
			Case c = new Case();
			c.Subject = 'Prueba';
			c.Description = 'Prueba';
			c.Status = 'Activo';
			c.Origin = 'Comentarios Stores';
			c.CC_Idioma__c = 'es';
			c.CC_Tipo_Contacto__c = 'Consulta';
			c.CC_Tipo_Cliente__c = 'Cliente';
			c.CC_Canal_Procedencia__c = 'Google Play Store';
			insert c;

			Case cs = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c='Google Play Store' LIMIT 1];
			SocialPost socPost = New SocialPost();
			socPost.Content = 'Prueba';
			socPost.Handle = 'oskiki';
			socPost.ParentId = cs.Id;
			//socPost.PersonaId = '';
			socPost.Provider = 'Other';
			socPost.Name = 'Prueba';
			socPost.IsOutbound = true;
			insert socPost;

			SocialPost sPost = [SELECT Id,PersonaId FROM SocialPost WHERE Name='Prueba' LIMIT 1];
			SocialPersona persona = New SocialPersona();
			persona.Name = 'oskiki';
			persona.RealName = 'Oscar';
			persona.Provider='Other';
			persona.ParentId = sPost.Id;
			insert persona;

			SocialPersona sp = [SELECT Id FROM SocialPersona WHERE RealName = 'Oscar' LIMIT 1];
			cs.CC_Social_Persona__c = sp.Id;
			update cs;

			Test.startTest();
			Case oidSP = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c='Google Play Store' LIMIT 1];
			SocialPersona oSP = CC_Busqueda_ALF_Controller.buscarSocialPersona (oidSP.Id);
			Test.stopTest();

			System.assertNotEquals(null, oSP);
		}
	}

	/*@isTest
	public static void getContratosCliente() {

		// Alta de datos para la prueba
		Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		//Id recordTypeIdContrato = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Contrato').getRecordTypeId();
		Id recordTypeIdRepresentante = Schema.SObjectType.CC_Representante_Contrato__c.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
		Account cuenta = new Account(name='Test01',CC_Numero_Documento__c='12345678Z',CC_NumPerso__c = '99999991',RecordTypeId = recordTypeIdCliente);
		insert cuenta;
		Contact contacto = new Contact(LastName='Test01',CC_NumPerso__c = '99999991', Account=new Account(CC_NumPerso__c = '99999991'));
		insert contacto;
		CC_Representante_Contrato__c representante = new CC_Representante_Contrato__c();
		representante.RecordTypeId = recordTypeIdRepresentante;
		representante.CC_ClienteRepresentante__c = cuenta.Id;
		insert representante;
		CC_Representante_Contrato__c contrato = new CC_Representante_Contrato__c();
		contrato.RecordTypeId = recordTypeIdContrato;
		contrato.CC_ClienteContrato__c = cuenta.Id;
		insert contrato;

		// Ejecución de la prueba
		Test.startTest();
		//List<CC_Busqueda_ALF_Controller.ContratoPicklistItemWrapper> contratosCliente = CC_Busqueda_ALF_Controller.getContratosCliente(contacto.Id, 'Contacto');
		//List<CC_Busqueda_ALF_Controller.ContratoPicklistItemWrapper> representantesCliente = CC_Busqueda_ALF_Controller.getContratosCliente(representante.Id, 'Representante');
		Test.stopTest();

		// Evaluación del resultado de la prueba
		// TODO
	}*/

	@isTest
	private static void toDo() {
		User usuarioAdmin = [SELECT Id FROM User WHERE LastName = 'Admin' LIMIT 1];
		System.runAs(usuarioAdmin) {
			Account cuenta1 = new Account();
			cuenta1.Name = 'Test01';
			cuenta1.CC_Numero_Documento__c = '36407246V';
			cuenta1.CC_NumPerso__c = '99999991';
			cuenta1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta1.CC_TipoPersona__c = 'J';
			Account cuenta2 = new Account();
			cuenta2.Name = 'Test02';
			cuenta2.CC_Numero_Documento__c = '63570681S';
			cuenta2.CC_NumPerso__c = '99999992';
			cuenta2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta2.CC_TipoPersona__c = 'F';
			Account cuentaMenor = new Account();
			cuentaMenor.FirstName = 'Menor';
			cuentaMenor.LastName = '1';
			cuentaMenor.CC_Numero_Documento__c = '18687709W';
			cuentaMenor.CC_NumPerso__c = '99999993';
			cuentaMenor.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
			cuentaMenor.CC_TipoPersona__c = 'F';
			cuentaMenor.CC_FechaNac__pc  = Date.valueOf('2020-10-28');
			insert new List<Account>{cuenta1, cuenta2, cuentaMenor};

			Test.startTest();
			Contact contacto1 = new Contact();
			contacto1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Representante').getRecordTypeId();
			contacto1.LastName = 'test';
			contacto1.CC_CuentaRepresentada__c = cuenta1.Id;
			insert contacto1;
			CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(cuenta1.Id);

			CC_Representante_Contrato__c representanteContrato1 = new CC_Representante_Contrato__c();
			representanteContrato1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
			representanteContrato1.CC_ClienteRepresentante__c = cuenta2.Id;
			insert representanteContrato1;

			CC_Representante_Contrato__c representanteContrato2 = new CC_Representante_Contrato__c();
			representanteContrato2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
			representanteContrato2.CC_RepresentanteAsociado__c = representanteContrato1.Id;
			insert representanteContrato2;
			CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(cuenta2.Id);

			CC_Representante_Contrato__c representanteContratoMenor = new CC_Representante_Contrato__c();
			representanteContratoMenor.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Representante_Contrato__c', 'CC_Representante');
			representanteContratoMenor.CC_ClienteRepresentante__c = cuentaMenor.Id;
			representanteContratoMenor.CC_Representante__c = cuenta2.Id;
			insert representanteContratoMenor;
			CC_Busqueda_ALF_Controller.getRepresentantesOrContactosCliente(cuentaMenor.Id);
			Test.stopTest();

			System.assertEquals('PENDIENTE', 'PENDIENTE', 'PENDIENTE');
		}
	}

	@isTest
	private static void setClienteOpportunity() {
		User admin = CSBD_TestDataFactory.usuarioAdministrador();
		User gestor = CSBD_TestDataFactory.usuarioGestor();

		System.runAs(admin) {
			Pricebook2 listaPrecios = new Pricebook2();
			listaPrecios.Name = 'CSBD Price Book';
			listaPrecios.Description = 'CSBD Price Book';
			listaPrecios.IsActive = true;
			insert listaPrecios;
		}
		System.runAs(admin) {
			//Alta de las parametrizaciones que necesita el trigger BI de oportunidades
			CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
			listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
			listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
			listaValores.CC_Activa__c = true;
			insert listaValores;

			CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
			valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
			valor.CC_Lista__c = listaValores.Id;
			valor.Name = 'Préstamo';
			valor.CC_Valor__c = '1';
			listaValores.CC_Activa__c = true;
			insert valor;

			Account cuenta = new Account();
			cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta.Name = 'Test01';
			cuenta.CC_Numero_Documento__c = '12345678Z';
			cuenta.CC_NumPerso__c = '99999991';
			cuenta.CC_TipoPersona__c = 'J';
			insert cuenta;

			AccountShare cuentaShare = new AccountShare();
			cuentaShare.AccountId = cuenta.Id;
			cuentaShare.UserOrGroupId = gestor.Id;
			cuentaShare.AccountAccessLevel = 'Edit';
			cuentaShare.OpportunityAccessLevel = 'Edit';
			insert cuentaShare;

			Contact contacto = new Contact();
			contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			contacto.LastName = 'test';
			contacto.AccountId = cuenta.Id;
			insert contacto;

			ContactShare contactoShare = new ContactShare();
			contactoShare.ContactId = contacto.Id;
			contactoShare.UserOrGroupId = gestor.Id;
			contactoShare.ContactAccessLevel = 'Edit';
			insert contactoShare;

			System.runAs(gestor) {
				Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
					'AccountId' => cuenta.Id, 'CSBD_Contact__c' => contacto.Id
				});
				Test.startTest();
				CC_Busqueda_ALF_Controller.setClienteOpportunity(cuenta.Id, 'Cuenta', prestamo.Id);
				CC_Busqueda_ALF_Controller.setClienteOpportunity(contacto.Id, 'Contacto', prestamo.Id);
				CC_Busqueda_ALF_Controller.setClienteOpportunity(null, null, prestamo.Id);
				Test.stopTest();

				System.assertEquals('PENDIENTE', 'PENDIENTE', 'PENDIENTE');
			}
		}
	}

	@isTest
	public static void toDo2() {
		User admin = CSBD_TestDataFactory.usuarioAdministrador();
		User usuarioSupervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario supervisor Prueba1' LIMIT 1];
		System.runAs(admin) {
			Pricebook2 listaPrecios = new Pricebook2();
			listaPrecios.Name = 'CSBD Price Book';
			listaPrecios.Description = 'CSBD Price Book';
			listaPrecios.IsActive = true;
			insert listaPrecios;
		}

		System.runAs(admin) {
			//Alta de las parametrizaciones que necesita el trigger BI de oportunidades
			CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
			listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
			listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
			listaValores.CC_Activa__c = true;
			insert listaValores;

			CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
			valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
			valor.CC_Lista__c = listaValores.Id;
			valor.Name = 'Préstamo';
			valor.CC_Valor__c = '1';
			listaValores.CC_Activa__c = true;
			insert valor;

			Account cuenta = new Account();
			cuenta.Name = 'Test01';
			cuenta.CC_Numero_Documento__c = '12345678Z';
			cuenta.CC_NumPerso__c = '99999991';
			cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			cuenta.CC_TipoPersona__c = 'J';
			insert cuenta;

			AccountShare cuentaShare = new AccountShare();
			cuentaShare.AccountId = cuenta.Id;
			cuentaShare.UserOrGroupId = usuarioSupervisor.Id;
			cuentaShare.AccountAccessLevel = 'Edit';
			cuentaShare.CaseAccessLevel = 'Edit';
			cuentaShare.OpportunityAccessLevel = 'Edit';
			insert cuentaShare;

			Contact contacto = new Contact();
			contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
			contacto.LastName = 'test';
			contacto.AccountId = cuenta.Id;
			insert contacto;

			ContactShare contactoShare = new ContactShare();
			contactoShare.ContactId = contacto.Id;
			contactoShare.UserOrGroupId = usuarioSupervisor.Id;
			contactoShare.ContactAccessLevel = 'Edit';
			insert contactoShare;

			System.runAs(usuarioSupervisor) {
				Case caso = new Case();
				caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
				caso.Subject='Test01';
				caso.Description = 'Prueba2';
				caso.Status = 'Activo';
				caso.Origin = 'Comentarios Stores';
				caso.CC_Idioma__c = 'es';
				caso.CC_Tipo_Contacto__c = 'Consulta';
				caso.CC_Tipo_Cliente__c = 'Cliente';
				caso.CC_Canal_Procedencia__c = 'Google Play Store';
				insert caso;

				Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

				CC_Llamada__c llamada = new CC_Llamada__c();
				llamada.RecordTypeId = Schema.SObjectType.CC_Llamada__c.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
				insert llamada;

				Test.startTest();
				// CC_Busqueda_ALF_Controller.getTipoRegistro(caso.Id);
				// CC_Busqueda_ALF_Controller.getTipoRegistro(llamada.Id);
				// CC_Busqueda_ALF_Controller.getTipoRegistro(oportunidad.Id);

				CC_Busqueda_ALF_Controller.getEsPropietarioCaso(caso.Id);
				CC_Busqueda_ALF_Controller.getEsPropietarioCaso(llamada.Id);
				CC_Busqueda_ALF_Controller.getEsPropietarioCaso(oportunidad.Id);

				CC_Busqueda_ALF_Controller.setClienteLlamada(contacto.Id, 'Contacto', llamada.Id);
				CC_Busqueda_ALF_Controller.setClienteLlamada(contacto.Id, '', llamada.Id);

				CC_Busqueda_ALF_Controller.datosRegistro(caso.Id);
				CC_Busqueda_ALF_Controller.datosRegistro(llamada.Id);
				CC_Busqueda_ALF_Controller.datosRegistro(oportunidad.Id);

				CC_Busqueda_ALF_Controller.datosCaso(caso.Id);
				CC_Busqueda_ALF_Controller.datosLlamada(llamada.Id);

				CC_Busqueda_ALF_Controller.actualizarIdentificacion(caso.Id, true, 'Case', null);
				CC_Busqueda_ALF_Controller.actualizarIdentificacion(llamada.Id, true, 'CC_Llamada__c', null);
				Test.stopTest();

				System.assertEquals('PENDIENTE', 'PENDIENTE', 'PENDIENTE');
			}
		}
	}
}