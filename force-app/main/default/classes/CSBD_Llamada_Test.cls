@isTest
public class CSBD_Llamada_Test {
    /*
    @testSetup
    public static void altaDatosPrueba() {
        User adminUser = usuarioAdministrador();
        System.runAs(adminUser) {
            //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
            CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
            listaValores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
            listaValores.CC_Activa__c = true;
            insert listaValores;

            CC_Lista_Valores__c valorPrestamo = new CC_Lista_Valores__c();
            valorPrestamo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorPrestamo.CC_Lista__c = listaValores.Id;
            valorPrestamo.Name = 'Préstamo';
            valorPrestamo.CC_Valor__c = '1';
            insert valorPrestamo;

            CC_Lista_Valores__c valorTpv = new CC_Lista_Valores__c();
            valorTpv.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorTpv.CC_Lista__c = listaValores.Id;
            valorTpv.Name = 'TPV';
            valorTpv.CC_Valor__c = '5';
            insert valorTpv;

            CC_Lista_Valores__c valorLLamadaServicio = new CC_Lista_Valores__c();
            valorPrestamo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorPrestamo.CC_Lista__c = listaValores.Id;
            valorPrestamo.Name = 'LLamada Servicio';
            valorPrestamo.CC_Valor__c = '0';
            insert valorLLamadaServicio;

            Pricebook2 listaPrecios = new Pricebook2();
            listaPrecios.Name = 'Standard Price Book';
            insert listaPrecios;

            Pricebook2 listaPreciosCsbd = new Pricebook2();
            listaPreciosCsbd.Name = 'CSBD Price Book';
            listaPreciosCsbd.Description = 'CSBD Price Book';
            listaPreciosCsbd.IsActive = true;
            insert listaPreciosCsbd;

            Id userId = adminUser.Id;
            CC_Usuario_Genesys__c usuarioGen = new CC_Usuario_Genesys__c(
                CC_User__c = userId,
                Name = 'LOGINTEST',
                CC_DN__c = '1234',
                CC_Acceso__c = 'Teléfono;Chat',
                CC_Negocio__c = 'CSBD + CC'
            );
            insert usuarioGen;

            CC_Servicio_Genesys__c servicioGenesys = new CC_Servicio_Genesys__c();
            servicioGenesys.Name = 'testEntrante';
            servicioGenesys.CC_VDN__c = '2';
            servicioGenesys.CC_Tipo_Cliente__c = 'Cliente';
            servicioGenesys.CC_Codigo__c='1234';
            insert servicioGenesys;
        }
    }

    @isTest
    public static void registrarLlamadaSaliente() {

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '12312312K';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Map<String, String> campos = new Map<String, String>();
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', contacto.Id);
        campos.put('CSBD_Idioma_Solicitud__c', 'Catalán');
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuario_test@test.com'];
        System.runAs (usuarioAdmin) {
            Test.startTest();
            CC_Llamada_Input inputLlamada = new CC_Llamada_Input();
            inputLlamada.usuario = 'Usuario1';
            inputLlamada.extension = 'Extensión1';
            inputLlamada.connId = 'connId1';
            inputLlamada.ani = '123456789';
            inputLlamada.dnis = '234567890';
            inputLlamada.negocio = 'CSBD';
            inputLlamada.casoId = oportunidad.Id;
            CC_Llamada__c llamada = CSBD_Llamada.registrarLlamadaSaliente(inputLlamada);
            Test.stopTest();

            System.assertEquals(CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CSBD_Cliente'), llamada.RecordTypeId, 'RecordType de llamada incorrecto');
            System.assertEquals('Saliente', llamada.CC_Tipo__c, 'Tipo de llamada incorrecto');
            System.assertEquals(inputLlamada.usuario, llamada.CC_Agente__c, 'Agente de llamada incorrecto');
            System.assertEquals(inputLlamada.extension, llamada.CC_Extension__c, 'Extensión de llamada incorrecta');
            System.assertEquals(inputLlamada.connId, llamada.CC_ConnId__c, 'CC_ConnId__c de llamada incorrecto');
            System.assertEquals(inputLlamada.dnis, llamada.CC_DNIS__c, 'CC_DNIS__c de llamada incorrecto');
            System.assertEquals('ca', llamada.CC_Idioma__c, 'Idioma de llamada incorrecto');
            System.assertEquals(oportunidad.AccountId, llamada.CC_Cuenta__c, 'Cuenta de llamada incorrecta');
            System.assertEquals(oportunidad.CSBD_Contact__c, llamada.CC_Contacto__c, 'Contacto de llamada incorrecto');
        }
    }

    @isTest
    public static void finalizarLlamada() {

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '12312312K';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Map<String, String> campos = new Map<String, String>();
        campos.put('AccountId', cuenta.Id);
        campos.put('CSBD_Contact__c', contacto.Id);
        campos.put('CSBD_Idioma_Solicitud__c', 'Catalán');
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

        CC_Llamada_Input inputLlamada = new CC_Llamada_Input();
        inputLlamada.usuario = 'Usuario1';
        inputLlamada.extension = 'Extensión1';
        inputLlamada.connId = 'connId1';
        inputLlamada.ani = '123456789';
        inputLlamada.dnis = '234567890';
        inputLlamada.negocio = 'CSBD';
        inputLlamada.casoId = oportunidad.Id;
        CC_Llamada__c llamada = CSBD_Llamada.registrarLlamadaSaliente(inputLlamada);
        String inputLlamadaString = JSON.serialize(inputLlamada);

        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuario_test@test.com'];
        System.runAs (usuarioAdmin) {
            Test.startTest();
            CC_OpenCTI.finalizarLlamada(inputLlamadaString, 'Llamada finalizada');
            Test.stopTest();

            System.assert([SELECT CC_Fecha_Fin__c FROM CC_Llamada__c WHERE Id = :llamada.Id].CC_Fecha_Fin__c != null, 'Llamada no finalizada');
        }
    }

    @isTest
    public static void finalizarLlamadaDobleNegocio() {
        CC_Llamada_Input inputLlamada = new CC_Llamada_Input();
        inputLlamada.usuario = 'Usuario1';
        inputLlamada.extension = 'Extensión1';
        inputLlamada.connId = 'connId1';
        inputLlamada.ani = '123456789';
        inputLlamada.dnis = '234567890';
        inputLlamada.negocio = 'CSBD + CC';
        inputLlamada.numPerso = '12345678';
        inputLlamada.idioma = 'Castellano';
        inputLlamada.servicio = '1234';
        inputLlamada.asunto = ', , 1, #, 02213133, hablar con operador, 4, hablar con operador';
        Opportunity oportunidad = CSBD_Llamada.registrarLlamadaEntrante(inputLlamada);
        inputLlamada.llamadaId = oportunidad.Id;

        String inputLlamadaString = JSON.serialize(inputLlamada);

        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuario_test@test.com'];
        System.runAs (usuarioAdmin) {
            Test.startTest();
            CC_OpenCTI.finalizarLlamada(inputLlamadaString, 'Llamada finalizada');
            Test.stopTest();

            List<Task> task = [SELECT id, CC_Llamada_Id__c from Task where CC_Llamada_Id__c != null and WhatId = : oportunidad.Id];

            System.assert([SELECT CC_Fecha_Fin__c FROM CC_Llamada__c WHERE Id = :task[0].CC_Llamada_Id__c].CC_Fecha_Fin__c != null, 'Llamada no finalizada');
        }
    }

    @isTest
    public static void getIdiomaOportunidad() {
        Map<String, String> campos = new Map<String, String>();
        campos.put('CSBD_Idioma_Solicitud__c', 'Castellano');
        Opportunity oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);

        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuario_test@test.com'];
        System.runAs (usuarioAdmin) {
            Test.startTest();
            String idiomaOportunidad = CSBD_Llamada.getIdiomaOportunidad(oportunidad.Id);
            Test.stopTest();

            System.assertEquals('es', idiomaOportunidad, 'Idioma de la oportunidad incorrecto');
        }
    }

    @isTest
    public static void registrarLlamadaEntrante() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuario_test@test.com'];
        System.runAs (usuarioAdmin) {
            Test.startTest();
            CC_Llamada_Input inputLlamada = new CC_Llamada_Input();
            inputLlamada.usuario = 'Usuario1';
            inputLlamada.extension = 'Extensión1';
            inputLlamada.connId = 'connId1';
            inputLlamada.ani = '123456789';
            inputLlamada.dnis = '234567890';
            inputLlamada.negocio = 'CSBD';
			inputLlamada.numPerso = '12345678';
            inputLlamada.idioma = 'Castellano';
            inputLlamada.servicio = '1234';
            inputLlamada.asunto = ', , 1, #, 02213133, hablar con operador, 4, hablar con operador';
            Opportunity oportunidad = CSBD_Llamada.registrarLlamadaEntrante(inputLlamada);
            Test.stopTest();

            List<Opportunity> opp = [SELECT id from Opportunity where Id = :oportunidad.Id limit 1];
            List<Task> task = [SELECT id, WhatId from Task where CC_Llamada_Id__c != null and WhatId = : opp[0].Id];

            System.assertEquals(opp.isEmpty(), false, 'No se ha creado oportunidad relacionada con la llamada');
            System.assertEquals(task.isEmpty(), false, 'No se ha creado tarea relacionada con la llamada y la oportunidad');

        }
    }

    public static User usuarioAdministrador(){
        User admin = new User();
        admin.FirstName = 'Admin';
        admin.LastName = '1';
        admin.IsActive = true;
        admin.Alias = 'Admin';
        admin.Email = 'usuario_test@test.com';
        admin.EmailEncodingKey = 'ISO-8859-1';
        admin.LanguageLocaleKey = 'es';
        admin.LocaleSidKey = 'es_ES';
        admin.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
        admin.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        admin.TimeZoneSidKey = 'Europe/Madrid';
        admin.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        insert admin;

        List<PermissionSetAssignment> nuevosPermisos = new List<PermissionSetAssignment>();
        List<PermissionSet> permissionSet = [SELECT Id FROM PermissionSet WHERE Name LIKE 'CSBD%'];

        for (PermissionSet permissionSet1:permissionSet ) {
            PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
            nuevoPermiso.PermissionSetId = permissionSet1.Id;
            nuevoPermiso.AssigneeId = admin.Id;
            nuevosPermisos.add(nuevoPermiso);
        }
        insert nuevosPermisos;

        return admin;
    }
    */
}