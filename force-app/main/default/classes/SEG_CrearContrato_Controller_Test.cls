@IsTest
public with sharing class SEG_CrearContrato_Controller_Test {


    @TestSetup
    static void datosIniciales(){
        
        // Creación cuentas a tratar.
        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111111H';
        insert cuentaSEG1;

        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.CC_Idioma__c = 'es';
        insert contactoSEG1;


        //Crear reclamaciones
        SEG_Reclamaciones__c recl = new SEG_Reclamaciones__c();
        recl.Name = 'Testreclamaciones';
        recl.SEG_Plazo1Reclamacion__c = 1;
        recl.SEG_Plazo2Reclamacion__c = 2;
        recl.SEG_Plazo3Reclamacion__c = 3;
        recl.SEG_PlazoEnvioGestor__c = 4;
        recl.SEG_PlazoLlamada__c = 1;

        insert recl;
        
        
        //Crear MCC para CR

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'Tematica1';
        mccTematica.CC_Tipo_Cliente__c = 'Segmentos';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;
        
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Producto1';
        mccProducto.CC_Tipo_Cliente__c = 'Segmentos';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001'; 
        insert mccProducto; 
        
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
       	CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Motivo1';
        mccMotivo.CC_Tipo_Cliente__c = 'Segmentos';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SEG_Detalle').getRecordTypeId();
       	CC_MCC__c mccDetalle = new CC_MCC__c();
        mccDetalle.Name = 'Detalle1';
        mccDetalle.CC_Tipo_Cliente__c = 'Segmentos';
        mccDetalle.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccDetalle.RecordTypeId = recordTypeIdDetalle;
        mccDetalle.CC_Tematica__c = mccTematica.Id;
        mccDetalle.CC_Producto_Servicio__c = mccProducto.Id;
        mccDetalle.CC_Motivo__c = mccMotivo.Id;
        mccDetalle.CC_Codigo_Externo__c = 'DE-000001';
        insert mccDetalle;

       
        SEG_ClasificacionRapida__c regla1 = new SEG_ClasificacionRapida__c();
        regla1.Name = 'CR1';
        regla1.SEG_Tematica__c = mccTematica.Id;
        regla1.SEG_Producto__c = mccProducto.Id;
        regla1.SEG_Motivo__c = mccMotivo.Id;
        regla1.SEG_Detalle__c = mccDetalle.Id;
        regla1.SEG_ReclamacionesContratos__c = recl.Id;
        regla1.CBK_Negocio__c = 'Segmentos';
        regla1.SEG_CRContratos__c  = true;

        insert regla1;

        // Crear casos de los clientes.
        Case caso1 = new Case();
        //caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Seguimiento').getRecordTypeId();
        caso1.AccountId = cuentaSEG1.Id;
        caso1.ContactId = contactoSEG1.Id;
        caso1.Subject = 'test 1';
        
        caso1.SEG_ClasificacionRapida__c = regla1.Id;

        insert caso1;


    }

    /*@IsTest
    static void getLCVistaTest(){
        
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 1'];
        

        //Se ejecuta el batch
		Test.startTest();
        	String url = SEG_CrearContrato_Controller.getLCVista(listaCasos[0].Id);
        Test.stopTest();

        System.assert(listaCasos.size() > 0);
        System.assert(url != null);
        
    }*/


    @IsTest
    static void getCaseNumTest(){
        
        List<Case> listaCasos = [SELECT Id, casenumber FROM Case WHERE Subject = 'test 1'];
        

        //Se ejecuta el batch
		Test.startTest();
        	String casenumber = SEG_CrearContrato_Controller.getCaseNum(listaCasos[0].Id);
        Test.stopTest();

        System.assert(listaCasos.size() > 0);
        System.assert(casenumber == listaCasos[0].caseNumber);
    }
    
    @IsTest
    static void buscadorAccountsTest(){
        
        List<Account> listaAccount = [SELECT Id, Name FROM Account WHERE Name = 'Empresa segmentos'];
        Map<Id, Account> mapAccounts = new Map<Id, Account> ();
        String searchkey = 'Empresa segmentos';
        
		Test.startTest();
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = listaAccount[0].Id;
            Test.setFixedSearchResults(fixedSearchResults);
        	mapAccounts = SEG_CrearContrato_Controller.buscadorAccounts(searchkey);
        Test.stopTest();

        //TODO ASSERTS
        System.assert(mapAccounts.size() > 0);
    }
    
    @IsTest
    static void buscadorContactsTest(){
        
        List<Account> listaAccount = [SELECT Id, Name FROM Account WHERE Name = 'Empresa segmentos'];
        List<Contact> listaContact = [SELECT Id, AccountId,LastName  FROM Contact WHERE LastName = 'Contacto SEG 1'];
        Map<Id, Contact> mapContacts = new Map<Id, Contact> ();
        String searchkey = 'Contacto SEG 1';
        String relatedAccount = listaContact[0].AccountId;

		Test.startTest();
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = listaContact[0].Id;
            Test.setFixedSearchResults(fixedSearchResults);
        	mapContacts = SEG_CrearContrato_Controller.buscadorContacts(searchkey,relatedAccount);
        Test.stopTest();

        //TODO ASSERTS
        System.assert(mapContacts.size() > 0);
    }
    
    @IsTest
    static void buscadorCRTest(){
        
        Map<Id, SEG_ClasificacionRapida__c> mapCRs = new Map<Id, SEG_ClasificacionRapida__c> ();
        List<SEG_ClasificacionRapida__c> listCR = [Select Id,Name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR1'];
        String searchkey = 'CR1';

		Test.startTest();
            Id [] fixedSearchResults= new Id[1];
            fixedSearchResults[0] = listCR[0].Id;
            Test.setFixedSearchResults(fixedSearchResults);
        	mapCRs = SEG_CrearContrato_Controller.buscadorCR(searchkey);
        Test.stopTest();
        
        //TODO ASSERTS
        System.assert(mapCRs.size() > 0);
    }
    
    @IsTest
    static void crearSRTest(){
        List<Account> listaAccount = [SELECT Id, Name FROM Account WHERE Name = 'Empresa segmentos'];
        List<Contact> listaContact = [SELECT Id, AccountId,LastName  FROM Contact WHERE LastName = 'Contacto SEG 1'];
        List<SEG_ClasificacionRapida__c> listCR = [Select Id,Name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR1'];
        String caseId;
        String crId = listCR[0].Id;
        String accountId = listaContact[0].AccountId;
        String contactId = listaContact[0].Id;
        
        Map<Id, SEG_ClasificacionRapida__c> mapCRs = new Map<Id, SEG_ClasificacionRapida__c> ();
        String searchkey = 'CR1';

		Test.startTest();
        	caseId = SEG_CrearContrato_Controller.crearSR(crId,2,accountId,contactId);
        Test.stopTest();
        
        //TODO ASSERTS
        System.assert(caseId != null);
    }

    @IsTest
    static void crearContratoTest(){
        List<Account> listaAccount = [SELECT Id, Name FROM Account WHERE Name = 'Empresa segmentos'];
        List<Contact> listaContact = [SELECT Id, AccountId,LastName  FROM Contact WHERE LastName = 'Contacto SEG 1'];
        List<SEG_ClasificacionRapida__c> listCR = [Select Id,Name FROM SEG_ClasificacionRapida__c WHERE Name = 'CR1'];
        List<Case> listaCasos = [SELECT Id FROM Case WHERE Subject = 'test 1'];
        String contratoId;
        String crId = listCR[0].Id;
        String accountId = listaContact[0].AccountId;
        String contactId = listaContact[0].Id;
        
        Map<Id, SEG_ClasificacionRapida__c> mapCRs = new Map<Id, SEG_ClasificacionRapida__c> ();
        String searchkey = 'CR1';

		Test.startTest();
        	contratoId = SEG_CrearContrato_Controller.crearContrato('TestDescript','testIDcontract',Date.today(),Date.today(),listaCasos[0].Id,'No firmado');
        Test.stopTest();
        
        //TODO ASSERTS
        System.assert(contratoId != null);
    }
}