@isTest
public with sharing class SAC_HandlerMethods_Test {
	@TestSetup
	static void makeData() {

		User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

		Test.startTest();
		//Account
		Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
		Database.insert(cuenta);

		//Contact
		Contact contacto = SAC_TestDataFactory.crearContacto(1,cuenta.id)[0];
		Database.insert(contacto);

		CC_Grupo_Colaborador__c grupoColaborador;
		CC_Grupo_Colaborador_Contact__c grupoColaboradorContact;
		System.runAs(usuarioGeneral){
			//Grupo
			grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor',1)[0];
			grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
			grupoColaborador.SAC_MaximoCasosDiarios__c = 1;
			Database.insert(grupoColaborador);

			//Contact Grupo
			grupoColaboradorContact = SAC_TestDataFactory.crearColaboradorContact(usuarioGeneral.Id, grupoColaborador.Id); 
			grupoColaboradorContact.SAC_Administrador__c = true;
			Database.insert(grupoColaboradorContact);
		}
		//MCC
		CC_MCC__c mcc = new CC_MCC__c();
		mcc.Name = 'MCC1';
		mcc.CC_Codigo_Externo__c = 'test MCC';
		mcc.SAC_EndToEnd__c = true;
		mcc.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
		mcc.SAC_GrupoColaborador__c = grupoColaborador.Id;
		Database.insert(mcc);

		//Reclamacion 1
		List<Case> reclamaciones = new List<Case>();
		Map<String, Object> camposRecl1 = new Map<String, Object>();
		camposRecl1.put('Subject', 'TestRec');
		camposRecl1.put('AccountId', cuenta.Id);
		camposRecl1.put('ContactId', contacto.Id);
		camposRecl1.put('OwnerId', usuarioGeneral.id);
		camposRecl1.put('SAC_E2E__c', false);

		Case reclamacion1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
		reclamaciones.add(reclamacion1);

		//Reclamacion 2
		Map<String, Object> camposRecl2 = new Map<String, Object>();
		camposRecl2.put('Subject', 'TestReclamacion2');
		camposRecl2.put('AccountId', cuenta.Id);
		camposRecl2.put('ContactId', contacto.Id);
		camposRecl2.put('OwnerId', usuarioGeneral.id);
		camposRecl2.put('SAC_E2E__c', true);

		Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
		reclamaciones.add(reclamacion2);
		Database.insert(reclamaciones);

		//Reclamantes
		SAC_CaseReclamante__c reclamantePrincipal = SAC_TestDataFactory.crearReclamante(true, reclamacion1, cuenta.Id);
		reclamantePrincipal.SAC_Contact__c = contacto.Id;

		SAC_CaseReclamante__c reclamanteSecundario1 = SAC_TestDataFactory.crearReclamante(false, reclamacion1, cuenta.Id);
		reclamanteSecundario1.SAC_Contact__c = contacto.Id;

		SAC_CaseReclamante__c reclamanteSecundario2 = SAC_TestDataFactory.crearReclamante(false, reclamacion1, cuenta.Id);
		reclamanteSecundario2.SAC_Contact__c = contacto.Id;
		
		List<SAC_CaseReclamante__c> listaReclamantes = new List<SAC_CaseReclamante__c>();
		listaReclamantes.add(reclamantePrincipal);
		listaReclamantes.add(reclamanteSecundario1);
		listaReclamantes.add(reclamanteSecundario2);
		Database.insert(listaReclamantes);
		Test.stopTest();

		//Pretension 1
		List<Case> pretensiones = new List<Case>();
		Map<String, Object> camposPret1 = new Map<String, Object>();
		camposPret1.put('Subject', 'pret1');
		camposPret1.put('Status', 'SAC_001');
		camposPret1.put('SuppliedCompany', 'pret1');
		camposPret1.put('SAC_Reclamacion__c', reclamacion2.id);
		camposPret1.put('SEG_Detalle__c', mcc.id);

		Case pretension1 = SAC_TestDataFactory.crearCaso('Pretension',camposPret1);
		pretensiones.add(pretension1);

		//Pretension 2
		Map<String, Object> camposPret2 = new Map<String, Object>();
		camposPret2.put('Subject', 'pret2');
		camposPret2.put('Status', 'SAC_002');
		camposPret2.put('SuppliedCompany', 'pret2');
		camposPret2.put('SAC_Reclamacion__c', reclamacion2.id);
		camposPret2.put('SEG_Detalle__c', mcc.id);

		Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
		pretensiones.add(pretension2);

		//Pretension 3
		Map<String, Object> camposPret3 = new Map<String, Object>();
		camposPret3.put('Subject', 'pret3');
		camposPret3.put('Status', 'SAC_009');
		camposPret3.put('SuppliedCompany', 'pret3');
		camposPret3.put('SAC_Reclamacion__c', reclamacion2.id);
		camposPret3.put('SEG_Detalle__c', mcc.id);

		Case pretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret3);
		pretensiones.add(pretension3);

		//Pretension 4
		Map<String, Object> camposPret4 = new Map<String, Object>();
		camposPret4.put('Subject', 'pret4');
		camposPret4.put('Status', 'SAC_009');
		camposPret4.put('SuppliedCompany', 'pret4');
		camposPret4.put('SAC_Reclamacion__c', reclamacion1.id);
		camposPret4.put('SEG_Detalle__c', mcc.id);

		Case pretension4 = SAC_TestDataFactory.crearCaso('Pretension',camposPret4);
		pretensiones.add(pretension4);
		Database.insert(pretensiones);
		
		
	}

	@isTest
	static void testinsertCaseWithAccount() {

		User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		Account cuenta = [SELECT Id FROM Account WHERE Name = 'cuentaTest0' LIMIT 1];
		Contact contacto = [SELECT Id FROM Contact WHERE FirstName = 'Test0' AND LastName = 'Apellido' LIMIT 1];

		Case casoReclamacion = new Case();
        casoReclamacion.Subject = 'TestRec';
        casoReclamacion.Origin = 'SAC_Formulario';
        casoReclamacion.Status = 'SAC_001';
        casoReclamacion.OwnerId = usuario.id;
        casoReclamacion.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		casoReclamacion.AccountId = cuenta.Id;
        casoReclamacion.SuppliedEmail = 'test@test.com';
		casoReclamacion.SAC_UsarDatos__c = true;
		
		System.runAs(usuario){	
			Test.startTest();
			Database.insert(casoReclamacion);
			Test.stopTest();
		}
		
		List<SAC_CaseReclamante__c> argumentoMetodo = [SELECT Id, SAC_Case__r.Subject, SAC_Case__c, SAC_Account__c,
		                                               SAC_Contact__c, SAC_Pretension__c, SAC_ReclamantePrincipal__c
		                                               FROM SAC_CaseReclamante__c
		                                               WHERE SAC_Case__c = :casoReclamacion.Id];

		System.assertNotEquals(null,argumentoMetodo.size(), 'Error al recoger el reclamante');
		System.assert(argumentoMetodo.get(0).SAC_ReclamantePrincipal__c, 'Error al recoger el reclamante principal');
	}
	
	@isTest
	static void testUpdateAccountCase() {

		User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		Account cuenta = [SELECT Id FROM Account WHERE Name = 'cuentaTest0' LIMIT 1];
		Contact contacto = [SELECT Id FROM Contact WHERE FirstName = 'Test0' AND LastName = 'Apellido' LIMIT 1];
		Case caso = [SELECT Id, AccountId, ContactId FROM Case WHERE Subject = 'TestRec' LIMIT 1];

		caso.AccountId = cuenta.Id;
		caso.ContactId = contacto.Id;
		SAC_Case_AU_TRHan.procesado=false;
		Test.startTest();
		system.runAs(usuario){
			Database.update(caso);
		}
		
		Test.stopTest();
		List<SAC_CaseReclamante__c> argumentoMetodo = [SELECT Id, SAC_Case__r.Subject, SAC_Case__c, SAC_Account__c,
		                                               SAC_Contact__c, SAC_Pretension__c, SAC_ReclamantePrincipal__c
		                                               FROM SAC_CaseReclamante__c
		                                               WHERE SAC_Case__c = :caso.Id];

		System.assertNotEquals(null,argumentoMetodo.size(), 'Error al recoger el reclamante');
		System.assert(argumentoMetodo.get(0).SAC_ReclamantePrincipal__c, 'Error al recoger el reclamante principal');
	}

	@isTest
	static void comprobarE2ERecTest() {
	
		User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestReclamacion2' LIMIT 1];

		List<Case> pretensiones = new List<Case>();
		Case pretension = new Case();
		pretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        pretension.Status = 'SAC_001';
        pretension.SuppliedCompany = 'pret1';
		pretension.SAC_Reclamacion__c = reclamacion.Id;
		pretensiones.add(pretension);

		Case pretension2 = new Case();
		pretension2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        pretension2.Status = 'SAC_002';
        pretension2.SuppliedCompany = 'pret2';
		pretension2.SAC_Reclamacion__c = reclamacion.Id;
		pretensiones.add(pretension2);

		Test.startTest();
		System.runAs(usuario){
			Database.insert(pretensiones);
		}
		Test.stopTest();

		Case reclamacionE2E = [SELECT Id, SAC_E2E__c FROM Case WHERE Subject = 'TestReclamacion2' LIMIT 1];

		System.assertNotEquals(false, reclamacionE2E.SAC_E2E__c, 'Error balancear el campo E2E');
	}

	@isTest
	static void comprobarE2ERecTest2() {

		Id recTypeRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		Id recTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
	
		User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		Case pret1 = [SELECT Id FROM Case WHERE Subject = 'pret1' LIMIT 1];
		Case pret2 = [SELECT Id FROM Case WHERE Subject = 'pret2' LIMIT 1];
		Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestReclamacion2' LIMIT 1];
		
		List<Id> listaIDsReclamacionGlobal = new List<Id>();
		listaIDsReclamacionGlobal.add(reclamacion.id);

		List<Case> pretensiones = new List<Case>();
		pret1.Description = 'Test';
		pretensiones.add(pret1);
		pret2.Description = 'Test';
		pretensiones.add(pret2);

		Test.startTest();
		System.runAs(usuario){
			SAC_HandlerMethods.comprobarE2ERec(pretensiones, listaIDsReclamacionGlobal, false, recTypeRec, recTypePret);
		}
		Test.stopTest();

		Case reclamacionE2E = [SELECT Id, SAC_E2E__c FROM Case WHERE Subject = 'TestReclamacion2' LIMIT 1];

		System.assertNotEquals(false, reclamacionE2E.SAC_E2E__c, 'Error balancear el campo E2E');
	}

	@isTest
	static void comprobarE2ERecTest3() {

		Id recTypeRec = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		Id recTypePret = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
	
		User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		Case pret1 = [SELECT Id FROM Case WHERE Subject = 'pret4' LIMIT 1];
		Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
		List<Id> listaIDsReclamacionGlobal = new List<Id>();
		listaIDsReclamacionGlobal.add(reclamacion.id);

		List<Case> pretensiones = new List<Case>();
		pret1.Description = 'Test';
		pretensiones.add(pret1);

		Test.startTest();
		System.runAs(usuario){
			SAC_HandlerMethods.comprobarE2ERec(pretensiones, listaIDsReclamacionGlobal, false, recTypeRec, recTypePret);
		}
		Test.stopTest();

		Case reclamacionE2E = [SELECT Id, SAC_E2E__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];

		System.assertNotEquals(true, reclamacionE2E.SAC_E2E__c, 'Error balancear el campo E2E');
	}
}