@isTest
public with sharing class SEG_Fotosdefacturacion_AI_TRHan_Test{
	//User operativo = SEG_Usuarios.usuarioOperativo();
	//User supervisor = SEG_Usuarios.usuarioSupervisor();	
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

		Id recordTypeMarcasCaso = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('SEG_Caracteristicacaso').getRecordTypeId();
		List<CC_Caracteristica__c> lstCar = new List<CC_Caracteristica__c> ();
		CC_Caracteristica__c car1 = new CC_Caracteristica__c();
		car1.RecordTypeId = recordTypeMarcasCaso;
		car1.CC_Descripcion__c = 'Caracteristica Test';
		car1.Name = 'TestCaracteristica1';
		insert car1;
            
	}
	@isTest
	public static void informarOperacionFF_Test()
    { 
		User supervisor = SEG_Usuarios.usuarioSupervisor();

        Case caso = [SELECT id FROM Case WHERE Subject = 'test 1'];
        CC_Caracteristica__c car = [SELECT id FROM CC_Caracteristica__c WHERE Name = 'TestCaracteristica1'];
        
		List<SEG_Fotosdefacturacion__c> lstFF = new List<SEG_Fotosdefacturacion__c>();
		SEG_Fotosdefacturacion__c ff = new SEG_Fotosdefacturacion__c();
		ff.SEG_NumeroSR__c = caso.Id;
		ff.SEG_Usuariogenerador__c = UserInfo.getUserId();
		ff.SEG_Estado__c = 'Revisar';
		ff.SEG_Operativa__c = 'Marca';
		ff.SEG_Marcadelcaso__c = car.Id;
        
		SEG_Operacion__c operacion = new SEG_Operacion__c();
        operacion.SEG_Foto_de_Facturacion__c = ff.id;
        operacion.SEG_SR__c = caso.id;
        insert operacion; 
		
		ff.SEG_Operacion__c=operacion.id;
		insert ff;

		System.runAs ( supervisor ) {
			Test.startTest();
			Test.stopTest();
			
			System.assertNotEquals(null , operacion,'El valor viene vacío');
		
		}	
    }
}