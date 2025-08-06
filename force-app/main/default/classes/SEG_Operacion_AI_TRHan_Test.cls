@isTest
public with sharing class SEG_Operacion_AI_TRHan_Test {
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
		caso1.Subject = 'test 1';
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
	}

	@isTest
	public static void insertarOperaciones()
	{
		List<Case> lstcaso = [SELECT Id, OwnerId, Subject FROM Case];
		Case cs1;
		Case cs2;
		for (Case cs : lstcaso) {
			if (cs.Subject == 'test 1') {
				cs1 = cs;
			} else {
				cs2 = cs;
			}
		}
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {

		Test.startTest();
			Id recordTypeCSO = Schema.SObjectType.SEG_Operacion__c.getRecordTypeInfosByDeveloperName().get('CSO').getRecordTypeId();
			List<SEG_Operacion__c> lstOp = new List<SEG_Operacion__c> ();
			SEG_Operacion__c op1 = new SEG_Operacion__c();
			op1.RecordTypeId = recordTypeCSO;
			op1.SEG_N_Operaciones__c = 3;
			op1.SEG_SR__c = cs1.Id;
			op1.SEG_Usuario__c = UserInfo.getUserId();
			lstOp.add(op1);
			SEG_Operacion__c op2 = new SEG_Operacion__c();
			op2.RecordTypeId = recordTypeCSO;
			op2.SEG_N_Operaciones__c = 4;
			op2.SEG_SR__c = cs2.Id;
			op2.SEG_Usuario__c = UserInfo.getUserId();
			lstOp.add(op2);
			SEG_Operacion__c op3 = new SEG_Operacion__c();
			op3.RecordTypeId = recordTypeCSO;
			op3.SEG_N_Operaciones__c = 2;
			op3.SEG_SR__c = cs2.Id;
			op3.SEG_Usuario__c = UserInfo.getUserId();
			lstOp.add(op3);
			insert lstOp;
		Test.stopTest();
		List<Case> lstcs = [SELECT Id, OwnerId, Subject, SEG_N_operaciones_CSO__c FROM Case];
		
		System.assertNotEquals(lstcs,null,'SEG_Desmarcado_Segmentos_Batch_Test');
		}
	}
}