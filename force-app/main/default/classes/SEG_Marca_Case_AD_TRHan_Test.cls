@isTest
public with sharing class SEG_Marca_Case_AD_TRHan_Test {
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
		SEG_Marcasdeuncaso__c marcaCase;
		List<SEG_Marcasdeuncaso__c> lstMarcaCase = new List<SEG_Marcasdeuncaso__c>();
		for (Case cs : listadoCasos) {
			marcaCase = new SEG_Marcasdeuncaso__c();
			marcaCase.SEG_Caso__c = cs.Id;
			marcaCase.SEG_Caracteristica__c = car1.Id;
			lstMarcaCase.add(marcaCase);
			marcaCase = new SEG_Marcasdeuncaso__c();
			marcaCase.SEG_Caso__c = cs.Id;
			marcaCase.SEG_Caracteristica__c = car2.Id;
			lstMarcaCase.add(marcaCase);
		}
		insert lstMarcaCase;
	}

	@isTest
	public static void deleteMarcaCase()
	{
		List<SEG_Marcasdeuncaso__c> lstM = [Select Id From SEG_Marcasdeuncaso__c];
		delete lstM;
		lstM = [Select Id From SEG_Marcasdeuncaso__c];
		System.assertEquals(0,lstM.size());
	}
}