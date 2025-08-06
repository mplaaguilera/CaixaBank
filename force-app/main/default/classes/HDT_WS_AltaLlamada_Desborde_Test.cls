@isTest
private class HDT_WS_AltaLlamada_Desborde_Test {

    @testSetup
    private static void testSetup() {

        Id profileId = [SELECT Id FROM Profile WHERE Name LIKE 'HDT%'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName LIKE 'HDT'].Id;

        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        insert usuarioAdmin;

        System.runAs(usuarioAdmin) {
            
            
            Id recordTypeOficina = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account oficinaGestora = new Account(RecordTypeId = recordTypeOficina, Name = 'Cuenta oficina gestora', CC_Tipo_Centro__c = 'OF',  CC_Email__c = 'test@test.com', CC_Numero_Oficina__c = '00001');
        insert oficinaGestora;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'Cuenta Prueba';
        cuenta.CC_OficinaGestoraId__c = oficinaGestora.Id;
        cuenta.CC_Numero_Oficina__c = '00001';
        insert cuenta;
        
        List<Contact> listaContactos = new List<Contact>();
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Contacto Prueba Empleado';
        contacto.LastName = 'Contacto Prueba Empleado';
        contacto.CC_NumPerso__c = '25345550';
        contacto.CC_Idioma__c = 'ca';
        contacto.Email = 'correo@gmail.com';
        contacto.Phone = '973242323';
        contacto.CC_Matricula__c = 'U01000000';
        listaContactos.add(contacto);

        Contact contacto2 = new Contact();
        contacto2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contacto2.AccountId = cuenta.Id;
        contacto2.FirstName = 'Contacto Prueba Empleado2';
        contacto2.LastName = 'Contacto Prueba Empleado2';
        contacto2.CC_NumPerso__c = '7896548';
        contacto2.CC_Idioma__c = 'ca';
        contacto2.Email = 'correo@gmail.com';
        contacto2.Phone = '973242323';
        contacto2.CC_Matricula__c = 'EG0000000';
        listaContactos.add(contacto2);
        insert listaContactos;
        
        List<CC_Canal_Com__c> canales = new List<CC_Canal_Com__c>();
        CC_Canal_Com__c canal = new CC_Canal_Com__c();
        canal.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        canal.CC_Telefono__c = '650399855';
        canal.CC_ContactoId__c = contacto.Id;
        canales.add(canal);

        CC_Canal_Com__c canal2 = new CC_Canal_Com__c();
        canal2.RecordTypeId = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        canal2.CC_Telefono__c = '650399855';
        canal2.CC_ContactoId__c = contacto2.Id;
        canales.add(canal2);
        insert canales;
        
        CC_Servicio_Genesys__c svc = new CC_Servicio_Genesys__c();
        svc.RecordTypeId = Schema.SObjectType.CC_Servicio_Genesys__c.getRecordTypeInfosByDeveloperName().get('CC_Servicio').getRecordTypeId();
        svc.Name = 'Plataforma Servicios Centrales';
        svc.CC_Codigo__c = 'Plataforma Servicios Centrales';
        svc.CBK_Negocio__c = 'HDT';
        svc.CC_VDN__c = '4444444';
        svc.CC_Tipo__C = 'Servicio';
        svc.CC_Canal_Procedencia__c = 'Incidencias Técnicas';
        svc.CC_Prefijo__c = '0';
        svc.CC_Tipo_Cliente__c = 'Empleado';
        insert svc;
    }
    }
    
    @isTest
    static void altaLlamadaHdtDesbordeTest() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            HDT_WS_AltaLlamada_Desborde.Input input = new HDT_WS_AltaLlamada_Desborde.Input();
            input.requestId = '20240502130000-001';
            input.servicio = 'Plataforma Servicios Centrales';
            input.connId = '35e038b6-7f86-4d0c-b879-uwcxr3xr43l3';
            input.asunto = 'Llamada desborde test';
        input.ani = '650399855';
        input.dnis = '937654321';
        input.numPerso = '111111';
        input.canalEmpleado = '';
        input.idioma = 'Castellano';
        input.datos = '';
        input.fechaInicio = '2024-04-07 18:23:52';
        input.fechaFin = '2024-04-07 18:25:53';
        input.urlGrabacion = 'www.url.com/grabacion.mp3';

        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/wsaltaLlamada/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(JSON.serialize(input));

        RestContext.request = request;
        RestContext.response = new RestResponse();

        Test.startTest();
        HDT_WS_AltaLlamada_Desborde.Output output = HDT_WS_AltaLlamada_Desborde.altaLlamadaHdtDesborde();
        Test.stopTest();
        // List<CC_Llamada__c> llamadaList = [SELECT Id FROM CC_Llamada__c WHERE Identificacion__c = '123456789'];
        // System.assertEquals(1, llamadaList.size(), 'La lista de llamada debe tener al menos una registro');
        System.assertEquals('OK', output.resultado, 'La respuesta esperada es OK');
        System.assertEquals(null, output.error, 'La respuesta esperada es OK');
        // System.assertEquals(llamadaList[0].Id, output.idLlamada, 'El idLlamada de la respuesta debe ser el mismo que el id del llamada creado');
        }
    }
}