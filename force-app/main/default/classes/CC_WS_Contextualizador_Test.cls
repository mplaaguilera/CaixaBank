@isTest
public with sharing class CC_WS_Contextualizador_Test {
    @TestSetup
    static void setData() {

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);
        Id roleDirectorioCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center_sin_acceso_a_Directorio'].Id;
        Id profileOperadorId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        
        User operadorCliente = new User();
        operadorCliente.profileId = profileOperadorId;
        operadorCliente.UserRoleId = roleDirectorioCC;
        operadorCliente.AV_ExternalID__c = 'U0124112';
        operadorCliente.FirstName = 'Operador';
        operadorCliente.LastName = 'Operador Cliente';
        operadorCliente.Email = 'tuser001@amamama.com';
        operadorCliente.Username = 'tuser001@amamama.com' + System.currentTimeMillis();
        operadorCliente.CompanyName = 'MST';
        operadorCliente.Title = 'title';
        operadorCliente.Alias = 'alias';
        operadorCliente.TimeZoneSidKey = 'Europe/Paris';
        operadorCliente.EmailEncodingKey = 'UTF-8';
        operadorCliente.LanguageLocaleKey = 'es';
        operadorCliente.LocaleSidKey = 'es_ES';
        userList.add(operadorCliente);
  
		insert userList;    

        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet psAVGestorOp = [SELECT Id FROM PermissionSet WHERE Name = 'AV_GestorOperativa'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>();
        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psOperadorCliente.Id);
        insertPSAssOperadores.add(psaOperadorCliente);
        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psClasses.Id);
        insertPSAssOperadores.add(psaOperadorClasses);
        PermissionSetAssignment psaOperadorAV = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psAVGestorOp.Id);
        insertPSAssOperadores.add(psaOperadorAV);
        Database.insert(insertPSAssOperadores);

        
        System.runAs(usuario1) {
            List<AccountShare> totalPermisosAccount = new List<AccountShare>();
            List<ContactShare> totalPermisosContact = new List<ContactShare>();
            Account cuenta = new Account();
        Id recordTypeCuenta = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuenta.Name = 'Cuenta01';
        cuenta.CC_NumPerso__c = '12345569';
        insert cuenta;        
        Id accountId = cuenta.Id;
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        insert contacto;        
        Id cId = contacto.Id;

        for(Account a : [SELECT Id FROM Account]) {
            AccountShare acshare = new AccountShare();
            acshare.AccountId = a.Id;
            acshare.UserOrGroupId = operadorCliente.Id;
            acshare.AccountAccessLevel = 'Edit';
            acshare.OpportunityAccessLevel = 'Edit';
            acshare.CaseAccessLevel = 'Edit';
            totalPermisosAccount.add(acshare);
        }

        ContactShare contactShare = new ContactShare();
        contactShare.ContactId = contacto.Id;
        contactShare.UserOrGroupId = operadorCliente.Id;
        contactShare.ContactAccessLevel = 'Edit';
        totalPermisosContact.add(contactShare);

        Boolean excepcion = false;
        
        try {
            Database.insert(totalPermisosAccount, false);
        } catch(Exception e) {
            excepcion = true;
        }

        try {
            Database.insert(totalPermisosContact, false);
        } catch(Exception e) {
            excepcion = true;
        }

        
        CBK_IntegrationSetting__c wsc = new CBK_IntegrationSetting__c();
		wsc.Name = 'CC_Contextualizador';
		wsc.NamedCredential__c = 'callout:MyIntegrationTest';
        wsc.RegistroTrazaIntegracion__c = true;
		insert wsc;
        
    }
    
    System.runAs(operadorCliente) {
        CC_Servicio_Genesys__c s1 = crearServicioDespliegues();
        String jsonLlamadaEntrante = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '12345678');
            Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamadaEntrante);
            CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(idLlamada);
            llamada.CC_Cuenta__c = [SELECT Id FROM Account WHERE Name = 'Cuenta01'].Id;
            update llamada;
            
            Case oCaso = new Case();
            oCaso.Subject = 'Contextualizador';
            oCaso.Origin = 'Email';
            oCaso.Status = 'Activo';
            oCaso.ContactId = [SELECT Id FROM Contact WHERE Account.Name = 'Cuenta01'].Id;
            oCaso.CC_NotIncidencia__c = '1';
            oCaso.CC_MailTelfNotif__c = 'test@test.es';
            oCaso.CC_CanalNotifCli__c = 'Email';
            oCaso.CC_Idioma__c = 'es';
            oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
            insert oCaso;

        }
    }

    private static CC_Servicio_Genesys__c crearServicioDespliegues() {
		CC_Servicio_Genesys__c servicio = new CC_Servicio_Genesys__c(
			Name = 'Despliegues',
			CBK_Negocio__c = 'CC',
		CC_Codigo__c = 'TARJETAS',
		CC_VDN__c = '4444444',
		CC_Tipo__C = 'Servicio',
		CC_Canal_Procedencia__c = 'Tarjetas',
		CC_Prefijo__c = '0',
		CC_Fecha_Inicio_Salesforce__c = date.today().addDays(1),
        CC_Canal_de_Entrada__c = 'Telefono',
		CC_Tipo_Cliente__c = 'Cliente');
		insert servicio;
		return servicio;
	}

    @isTest
    public static void llamadaWSOkTestCase() {
        Map <String, Object> llamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' AND AV_ExternalID__c = 'U0124112' AND UserRole.DeveloperName = 'Contact_Center_sin_acceso_a_Directorio' LIMIT 1].Id)) {
        Case c = [SELECT CC_Info_Denegacion__c, Id FROM Case WHERE Subject = 'Contextualizador'];
        Account a = [SELECT CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(200));
            llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.CC_NumPerso__c, c.Id, 'Case');
        }
        String valorEsperado = 'SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC';
        system.assertEquals(valorEsperado, (String)llamadaWs.get('MotivoDenegacion'), 'No salio bien la llamada');
        Test.stopTest();
    }
    @isTest
    public static void sinLlamarAlWSTestCase() {
        Map <String, Object> sinLlamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' AND AV_ExternalID__c = 'U0124112' AND UserRole.DeveloperName = 'Contact_Center_sin_acceso_a_Directorio' LIMIT 1].Id)) {
        Case c = [SELECT CC_Info_Denegacion__c, Id FROM Case WHERE Subject = 'Contextualizador'];
        Account a = [SELECT CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        c.CC_Info_Denegacion__c = '{"MotivoDenegacion":"SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC"}';
        update c;
            sinLlamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.CC_NumPerso__c, c.Id, 'Case');
        }
        String valorEsperado = 'SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC';
        system.assertEquals(valorEsperado, (String)sinLlamadaWs.get('MotivoDenegacion'), 'No respeto la información que habia en el campo');
        Test.stopTest();
    }
    @isTest
    public static void llamadaWSNOkTestCase() {
        Case c = [SELECT CC_Info_Denegacion__c, Id FROM Case WHERE Subject = 'Contextualizador'];
        Account a = [SELECT CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(404));
        Map <String, Object> llamadaWs = new Map <String, Object>();
            Test.startTest();
            System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' AND AV_ExternalID__c = 'U0124112' AND UserRole.DeveloperName = 'Contact_Center_sin_acceso_a_Directorio' LIMIT 1].Id)) {
               llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.CC_NumPerso__c, c.Id, 'Case');  
            }
            Test.stopTest();
        	Boolean error = llamadaWs.containsKey('Error');
            system.assertEquals(true, error, 'No ok el mock');
        
    }

    @isTest
    public static void llamadaWSOkTestLlamada() {
        // Case c = [SELECT CC_Info_Denegacion__c, Id FROM Case WHERE Subject = 'Contextualizador'];
        Map <String, Object> llamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' AND AV_ExternalID__c = 'U0124112' AND UserRole.DeveloperName = 'Contact_Center_sin_acceso_a_Directorio' LIMIT 1].Id)) {
        Account a = [SELECT Id FROM Account WHERE Name = 'Cuenta01'];
        CC_Llamada__c l = [SELECT CC_Info_Denegacion__c FROM CC_Llamada__c WHERE CC_Cuenta__c = :a.Id];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(200));
            llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.Id, l.Id, 'Llamada');
        }
        String valorEsperado = 'SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC';
        system.assertEquals(valorEsperado, (String)llamadaWs.get('MotivoDenegacion'), 'No salio bien la llamada');
        Test.stopTest();
    }
    @isTest
    public static void sinLlamarAlWSTestLlamada() {

        Account a = [SELECT Id, CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        CC_Llamada__c l = [SELECT CC_Info_Denegacion__c FROM CC_Llamada__c WHERE CC_Cuenta__c = :a.Id];
        l.CC_Info_Denegacion__c = '{"MotivoDenegacion":"SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC"}';
        update l;
        Map <String, Object> sinLlamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' AND AV_ExternalID__c = 'U0124112' AND UserRole.DeveloperName = 'Contact_Center_sin_acceso_a_Directorio' LIMIT 1].Id)) {
            sinLlamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.Id, l.Id, 'Llamada');
        }
        Test.stopTest();
        String valorEsperado = 'SUPERADO LIMITE: NO DISPONE DE EXCEDIDO POR FALTA DE SALDO CCC';
        system.assertEquals(valorEsperado, (String)sinLlamadaWs.get('MotivoDenegacion'), 'No respeto la información que habia en el campo');
    }
    @isTest
    public static void llamadaWSNOkTestLlamada() {
        Account a = [SELECT Id, CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        CC_Llamada__c l = [SELECT CC_Info_Denegacion__c FROM CC_Llamada__c WHERE CC_Cuenta__c = :a.Id];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(404));
        Map <String, Object> llamadaWs = new Map <String, Object>();
            Test.startTest();
            System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' AND AV_ExternalID__c = 'U0124112' AND UserRole.DeveloperName = 'Contact_Center_sin_acceso_a_Directorio' LIMIT 1].Id)) {
               llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.Id, l.Id, 'Llamada');  
            }
            Test.stopTest();
        	Boolean error = llamadaWs.containsKey('Error');
            system.assertEquals(true, error, 'No ok el mock');
        
    }
    @isTest
    public static void llamadaSinNumPerso() {
        Account a = [SELECT Id, CC_NumPerso__c FROM Account WHERE Name = 'Cuenta01'];
        a.CC_NumPerso__c = null;
        update a;
        CC_Llamada__c l = [SELECT CC_Info_Denegacion__c FROM CC_Llamada__c WHERE CC_Cuenta__c = :a.Id];
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_Contextualizador(200));
        Map <String, Object> llamadaWs = new Map <String, Object>();
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' AND AV_ExternalID__c = 'U0124112' AND UserRole.DeveloperName = 'Contact_Center_sin_acceso_a_Directorio' LIMIT 1].Id)) {
            llamadaWs = CC_WS_Contextualizador.ccWSContextualizador(a.Id, l.Id, 'Llamada');
        }
        Test.stopTest();
        String valorEsperado = null;
        system.assertEquals(valorEsperado, (String)llamadaWs.get('MotivoDenegacion'), 'Hay numperso en la cuenta');
    }
}