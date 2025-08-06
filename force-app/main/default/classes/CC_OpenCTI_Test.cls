@isTest
public with sharing class CC_OpenCTI_Test {

    @testSetup
    public static void altaDatosPrueba() {
        List<User> usuariosInsert = new List<User>();

        User adminCSBD = new User();
        adminCSBD.FirstName = 'Admin';
        adminCSBD.LastName = '1';
        adminCSBD.IsActive = true;
        adminCSBD.Alias = 'Admin';
        adminCSBD.Email = 'usuarioCSBD_test@test.com';
        adminCSBD.EmailEncodingKey = 'ISO-8859-1';
        adminCSBD.LanguageLocaleKey = 'es';
        adminCSBD.LocaleSidKey = 'es_ES';
        adminCSBD.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
        adminCSBD.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        adminCSBD.TimeZoneSidKey = 'Europe/Madrid';
        adminCSBD.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        usuariosInsert.add(adminCSBD);

        User adminCC = new User();
        adminCC.FirstName = 'Admin';
        adminCC.LastName = '1';
        adminCC.IsActive = true;
        adminCC.Alias = 'Admin';
        adminCC.Email = 'usuarioCC_test@test.com';
        adminCC.EmailEncodingKey = 'ISO-8859-1';
        adminCC.LanguageLocaleKey = 'es';
        adminCC.LocaleSidKey = 'es_ES';
        adminCC.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
        adminCC.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        adminCC.TimeZoneSidKey = 'Europe/Madrid';
        adminCC.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        usuariosInsert.add(adminCC);

        User adminSACH = new User();
        adminSACH.FirstName = 'Admin';
        adminSACH.LastName = '1';
        adminSACH.IsActive = true;
        adminSACH.Alias = 'Admin';
        adminSACH.Email = 'usuarioSACH_test@test.com';
        adminSACH.EmailEncodingKey = 'ISO-8859-1';
        adminSACH.LanguageLocaleKey = 'es';
        adminSACH.LocaleSidKey = 'es_ES';
        adminSACH.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'CSBD Genérico'].Id;
        adminSACH.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        adminSACH.TimeZoneSidKey = 'Europe/Madrid';
        adminSACH.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';
        usuariosInsert.add(adminSACH);

        Insert usuariosInsert;
        
        List<PermissionSetAssignment> nuevosPermisos = new List<PermissionSetAssignment>();
        List<PermissionSet> permissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name LIKE 'CSBD%' OR Name LIKE 'CC%' OR Name LIKE 'SACH%'];

        for (PermissionSet permissionSet1: permissionSet ) {
            PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
            if(permissionSet1.Name.startsWith('CSBD')) {
                nuevoPermiso.PermissionSetId = permissionSet1.Id;
                nuevoPermiso.AssigneeId = adminCSBD.Id;
            }
            if(permissionSet1.Name.startsWith('CC')) {
                nuevoPermiso.PermissionSetId = permissionSet1.Id;
                nuevoPermiso.AssigneeId = adminCC.Id;
            }
            if(permissionSet1.Name.startsWith('SACH')) {
                nuevoPermiso.PermissionSetId = permissionSet1.Id;
                nuevoPermiso.AssigneeId = adminSACH.Id;
            }
            nuevosPermisos.add(nuevoPermiso);
        }
        insert nuevosPermisos;
    }

    @isTest
    public static void ccOpenCTITest() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioCC_test@test.com'];

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        insert caso;

        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = 'TSF3';
        input.extension = 'PRUEBA';
        input.connId = 'connId01';
        input.transferConnId = '';
        input.ani = '666 123 456';
        input.dnis = '666 456 789';
        input.servicio = 'Accionista Eventos';
        input.asunto = 'llamada de prueba';
        input.numPerso = '12345678';
        input.idioma = 'es';
        input.datos = '';
        input.connIdCognitivo = '';
        input.llamadaId = '';
        input.casoId = caso.Id;
        input.salesforceParentId = '';
        input.canalEmpleado = '';
        input.cognitivoId = '';
        input.empleadoId = '';
        input.empleadoTelefono = '';
        input.negocio = 'CC';

        System.runAs (usuarioAdmin) {
            Test.startTest();
            Id idllamada = CC_OpenCTI.registrarLlamadaSaliente(JSON.serialize(input));
            Test.stopTest();
            
            List<CC_Llamada__c> llamada = [SELECT id,CC_Cuenta__c from CC_Llamada__c where id = :idllamada limit 1];
                List<Task> task = [SELECT id, WhatId from Task where CC_Llamada_Id__c = :idllamada and WhatId = : caso.Id];
                System.assertEquals(llamada.isEmpty(), false, 'No se ha creado llamada relacionada con el caso');
                System.assertEquals(task.isEmpty(), false, 'No se ha creado tarea relacionada con la llamada y el caso');
        }
    }

    @isTest
	public static void testObtenerServicioEncuestaDesdeCaso() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioCC_test@test.com'];

        CC_Servicio_Genesys__c servicioEncuesta = CC_Llamada_Test.crearServicioEncuesta();
        CC_Servicio_Genesys__c servicio = CC_Llamada_Test.crearServicio1();
        servicio.CC_Encuesta__c = servicioEncuesta.Id;
        update servicio;

        Case caso = CC_Llamada_Test.crearCaso();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(null, null, caso.Id, null);
        Id llamadaId = CC_OpenCTI.registrarLlamadaSaliente(jsonLlamada);
        System.runAs (usuarioAdmin) {
            Test.startTest();
            CC_Servicio_Genesys__c servicioEncuestaSaliente = CC_OpenCTI.obtenerServicioEncuestaDesdeCaso(caso.Id);
            Test.stopTest();

            System.assertNotEquals(null, servicioEncuestaSaliente);
            System.assertEquals(servicioEncuesta.Id, servicioEncuestaSaliente.CC_Encuesta__c);
        }

    }

    @isTest
	public static void testObtenerServicioEncuestaDesdeCasoServicioSinEncuesta() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioCC_test@test.com'];

        //Creamos servicio sin encuesta
        CC_Servicio_Genesys__c servicio = CC_Llamada_Test.crearServicio1();

        Case caso = CC_Llamada_Test.crearCaso();
        String jsonLlamada = CC_Llamada_Test.obtenerJsonLlamada(null, null, caso.Id, null);
        Id llamadaId = CC_OpenCTI.registrarLlamadaSaliente(jsonLlamada);
        System.runAs (usuarioAdmin) {
            Test.startTest();
            CC_Servicio_Genesys__c servicioEncuestaSaliente = CC_OpenCTI.obtenerServicioEncuestaDesdeCaso(caso.Id);
            Test.stopTest();

            System.assertEquals(null, servicioEncuestaSaliente);
        }
    }
    
    @isTest
    public static void obtenerServicioSalienteGenesysTest() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioCC_test@test.com'];
        System.runAs(usuarioAdmin) {
            Case caso = new Case();
            caso.recordtypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caso.Subject = 'Caso de prueba TF7 Empleado';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Atención al cliente';
            caso.CC_Tipo_Contacto__c = 'Consulta';
            caso.CC_Canal_Operativo__c = 'Cajero';
            Insert caso;

            CC_Servicio_Genesys__c servicioGenesys = new CC_Servicio_Genesys__c();
            servicioGenesys.Name = 'Test';
            servicioGenesys.CC_Canal_Procedencia__c = 'Atención al cliente';
            servicioGenesys.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Servicio_Genesys__c','CC_Servicios_Salientes');
            servicioGenesys.CC_Codigo__c = '0001';
            servicioGenesys.CC_VDN__c = '0001';
            insert servicioGenesys;

            CC_Servicio_Genesys__c servicio = CC_OpenCTI.obtenerServicioSalienteGenesys(caso.Id);
            System.assert(servicio != null);
        }
    }

    @isTest
	public static void comprobacionesSach() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioSACH_test@test.com'];

        Case casoNoSach = CC_Llamada_Test.crearCaso();

        Case casoSach = new Case();
        casoSach.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
        casoSach.Origin = 'Phone';
        insert casoSach;

        CC_Servicio_Genesys__c servicioNoSach = new CC_Servicio_Genesys__c();
        servicioNoSach.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Servicio_Genesys__c', 'CC_Servicio');
        servicioNoSach.CC_Codigo__c = 'SERVICIO_NO_SACH';
        servicioNoSach.CBK_Negocio__c = 'CC';
        servicioNoSach.CC_VDN__c = '123';
        insert servicioNoSach;

        CC_Servicio_Genesys__c servicioSach = new CC_Servicio_Genesys__c();
        servicioSach.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Servicio_Genesys__c', 'CC_Servicio');
        servicioSach.CC_Codigo__c = 'SERVICIO_SACH';
        servicioSach.CBK_Negocio__c = 'SACH';
        servicioSach.CC_VDN__c = '123';
        insert servicioSach;
        System.runAs (usuarioAdmin) {
            Test.startTest();
            Boolean s1 = CC_OpenCTI.esServicioSach(servicioNoSach.CC_Codigo__c);
            Boolean s2 = CC_OpenCTI.esServicioSach(servicioSach.CC_Codigo__c);
            Test.stopTest();

            System.assertEquals(false, s1, 'esServicioSach debería retornar true');
            System.assertEquals(true, s2, 'esServicioSach debería retornar true');
        }
    }

    @isTest
	public static void obtenerIdiomaRegistro() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioCC_test@test.com'];

        Case caso = CC_Llamada_Test.crearCaso();
        System.runAs (usuarioAdmin) {
            Test.startTest();
            String idiomaCaso = CC_OpenCTI.obtenerIdiomaRegistro(caso.Id);
            Test.stopTest();

            System.assert(String.isNotBlank(idiomaCaso));
        }
    }
    
    @isTest 
    public static void registrarLlamadaEntranteCSBD() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioCSBD_test@test.com'];

        CC_Servicio_Genesys__c servicioGenesys = new CC_Servicio_Genesys__c();
        servicioGenesys.Name = 'testEntrante';
        servicioGenesys.CC_VDN__c = '2';
        servicioGenesys.CC_Tipo_Cliente__c = 'Cliente'; 
        servicioGenesys.CC_Codigo__c='1234';
        servicioGenesys.CBK_Negocio__c='CSBD';
        insert servicioGenesys;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '12312312K';
        cuenta.CC_NumPerso__c = '12345678';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;
      
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
        System.runAs (usuarioAdmin) {
            Test.startTest();
            Id idOportunidad = CC_OpenCTI.registrarLlamadaEntrante(JSON.serialize(inputLlamada));
            Test.stopTest();
                List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE Id = :idOportunidad LIMIT 1];
                List<Task> task = [SELECT Id, CC_Llamada_Id__c FROM Task WHERE CC_Llamada_Id__c != null AND WhatId = :opp[0].Id];
                List<CC_Llamada__c> llamada = [SELECT Id FROM CC_Llamada__c WHERE Id = :task[0].CC_Llamada_Id__c LIMIT 1];

                System.assertEquals(opp.isEmpty(), false, 'No se ha creado oportunidad relacionada con la llamada');
                System.assertEquals(task.isEmpty(), false, 'No se ha creado tarea relacionada con la llamada y la oportunidad');
                System.assertEquals(llamada.isEmpty(), false, 'No se ha creado llamada');
        }
    }
    
    @isTest 
    public static void registrarLlamadaEntranteSACH() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioSACH_test@test.com'];

        CC_Servicio_Genesys__c servicioGenesys = new CC_Servicio_Genesys__c();
        servicioGenesys.Name = 'testEntrante';
        servicioGenesys.CC_VDN__c = '2';
        servicioGenesys.CC_Tipo_Cliente__c = 'Cliente'; 
        servicioGenesys.CC_Codigo__c='1234';
        servicioGenesys.CBK_Negocio__c='SACH';
        insert servicioGenesys;
        
        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'test@test.com';
        cuenta.CC_Numero_Documento__c = '12312312K';
        cuenta.CC_NumPerso__c = '12345678';
        insert cuenta;
        
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'test@test.com';
        contacto.FirstName = 'Nombre';
        contacto.LastName = 'Apellido';
        contacto.AccountId = cuenta.Id;
        insert contacto;
      
        CC_Llamada_Input inputLlamada = new CC_Llamada_Input();
            inputLlamada.usuario = 'Usuario1';
            inputLlamada.extension = 'Extensión1';
            inputLlamada.connId = 'connId1';
            inputLlamada.ani = '123456789';
            inputLlamada.dnis = '234567890';
            inputLlamada.negocio = 'SACH';
			inputLlamada.numPerso = '12345678';
            inputLlamada.idioma = 'Castellano';
            inputLlamada.servicio = '1234';
            inputLlamada.asunto = ', , 1, #, 02213133, hablar con operador, 4, hablar con operador';

        System.runAs (usuarioAdmin) {
            Test.startTest();
            //Id idllamada = CC_OpenCTI.registrarLlamadaEntrante(JSON.serialize(inputLlamada));
            Id casoId = CC_OpenCTI.registrarLlamadaEntrante(JSON.serialize(inputLlamada));
            Test.stopTest();
            List<Case> caso = [SELECT id from Case where Id = :casoId limit 1];
            //List<CC_Llamada__c> llamada = [SELECT id,CC_Cuenta__c from CC_Llamada__c where id = :idllamada limit 1];
            //List<Case> caso = [SELECT id from Case where AccountId = :llamada[0].CC_Cuenta__c limit 1];
            List<Task> task = [SELECT id, CC_Llamada_Id__c from Task where CC_Llamada_Id__c != null and WhatId = : caso[0].Id];
            List<CC_Llamada__c> llamada = [SELECT id,CC_Cuenta__c from CC_Llamada__c where Id = :task[0].CC_Llamada_Id__c LIMIT 1];
            System.assertEquals(caso.isEmpty(), false, 'No se ha creado caso relacionado con la llamada');
            System.assertEquals(task.isEmpty(), false, 'No se ha creado tarea relacionada con la llamada y la oportunidad');
        }
    }
    
    
    @isTest
    public static void registrarLlamadaSalienteCSBD() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioCSBD_test@test.com'];

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
        
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = 'TSF3';
        input.extension = 'PRUEBA';
        input.connId = 'connId01';
        input.transferConnId = '';
        input.ani = '666 123 456';
        input.dnis = '666 456 789';
        input.servicio = 'Accionista Eventos';
        input.asunto = 'llamada de prueba';
        input.numPerso = '12345678';
        input.idioma = 'es';
        input.datos = '';
        input.connIdCognitivo = '';
        input.llamadaId = '';
        input.casoId = oportunidad.Id;
        input.salesforceParentId = '';
        input.canalEmpleado = '';
        input.cognitivoId = '';
        input.empleadoId = '';
        input.empleadoTelefono = '';
        input.negocio = 'CSBD';

        System.runAs (usuarioAdmin) {
        Test.startTest();
            Id idllamada = CC_OpenCTI.registrarLlamadaSaliente(JSON.serialize(input));
            Test.stopTest();
            
            List<CC_Llamada__c> llamada = [SELECT id,CC_Cuenta__c from CC_Llamada__c where id = :idllamada limit 1];
        	List<Opportunity> opp = [SELECT id from Opportunity where AccountId = :llamada[0].CC_Cuenta__c limit 1];
            List<Task> task = [SELECT id, WhatId from Task where CC_Llamada_Id__c = :idllamada and WhatId = : opp[0].Id];
            System.assertEquals(opp.isEmpty(), false, 'No se ha creado oportunidad relacionada con la llamada');
            System.assertEquals(task.isEmpty(), false, 'No se ha creado tarea relacionada con la llamada y la oportunidad');
        }
    }
    
    @isTest
    public static void registrarLlamadaSalienteCSBDCCOpportunity() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioCSBD_test@test.com'];

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
        
        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = 'TSF3';
        input.extension = 'PRUEBA';
        input.connId = 'connId01';
        input.transferConnId = '';
        input.ani = '666 123 456';
        input.dnis = '666 456 789';
        input.servicio = 'Accionista Eventos';
        input.asunto = 'llamada de prueba';
        input.numPerso = '12345678';
        input.idioma = 'es';
        input.datos = '';
        input.connIdCognitivo = '';
        input.llamadaId = '';
        input.casoId = oportunidad.Id;
        input.salesforceParentId = '';
        input.canalEmpleado = '';
        input.cognitivoId = '';
        input.empleadoId = '';
        input.empleadoTelefono = '';
        input.negocio = 'CSBD + CC';

        System.runAs (usuarioAdmin) {
            Test.startTest();
            Id idllamada = CC_OpenCTI.registrarLlamadaSaliente(JSON.serialize(input));
            Test.stopTest();
            
            List<CC_Llamada__c> llamada = [SELECT id,CC_Cuenta__c from CC_Llamada__c where id = :idllamada limit 1];
        	List<Opportunity> opp = [SELECT id from Opportunity where AccountId = :llamada[0].CC_Cuenta__c limit 1];
            List<Task> task = [SELECT id, WhatId from Task where CC_Llamada_Id__c = :idllamada and WhatId = : opp[0].Id];
            System.assertEquals(opp.isEmpty(), false, 'No se ha creado oportunidad relacionada con la llamada');
            System.assertEquals(task.isEmpty(), false, 'No se ha creado tarea relacionada con la llamada y la oportunidad');
        }
    }
    
    @isTest
    public static void registrarLlamadaSalienteCSBDCC() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioCSBD_test@test.com'];

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        insert caso;

        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = 'TSF3';
        input.extension = 'PRUEBA';
        input.connId = 'connId01';
        input.transferConnId = '';
        input.ani = '666 123 456';
        input.dnis = '666 456 789';
        input.servicio = 'Accionista Eventos';
        input.asunto = 'llamada de prueba';
        input.numPerso = '12345678';
        input.idioma = 'es';
        input.datos = '';
        input.connIdCognitivo = '';
        input.llamadaId = '';
        input.casoId = caso.Id;
        input.salesforceParentId = '';
        input.canalEmpleado = '';
        input.cognitivoId = '';
        input.empleadoId = '';
        input.empleadoTelefono = '';
        input.negocio = 'CSBD + CC';

        System.runAs (usuarioAdmin) {
            Test.startTest();
            Id idllamada = CC_OpenCTI.registrarLlamadaSaliente(JSON.serialize(input));
            Test.stopTest();
        
            List<CC_Llamada__c> llamada = [SELECT id,CC_Cuenta__c from CC_Llamada__c where id = :idllamada limit 1];
            List<Task> task = [SELECT id, WhatId from Task where CC_Llamada_Id__c = :idllamada and WhatId = : caso.Id];
            System.assertEquals(llamada.isEmpty(), false, 'No se ha creado llamada relacionada con el caso');
            System.assertEquals(task.isEmpty(), false, 'No se ha creado tarea relacionada con la llamada y el caso');
        }
    }
    
     @isTest
    public static void registrarLlamadaSalienteSACH() {
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioSACH_test@test.com'];

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
        insert caso;

        CC_Llamada_Input input = new CC_Llamada_Input();
        input.usuario = 'TSF3';
        input.extension = 'PRUEBA';
        input.connId = 'connId01';
        input.transferConnId = '';
        input.ani = '666 123 456';
        input.dnis = '666 456 789';
        input.servicio = 'Accionista Eventos';
        input.asunto = 'llamada de prueba';
        input.numPerso = '12345678';
        input.idioma = 'es';
        input.datos = '';
        input.connIdCognitivo = '';
        input.llamadaId = '';
        input.casoId = caso.Id;
        input.salesforceParentId = '';
        input.canalEmpleado = '';
        input.cognitivoId = '';
        input.empleadoId = '';
        input.empleadoTelefono = '';
        input.negocio = 'SACH';
        System.runAs (usuarioAdmin) {
            Test.startTest();
            Id idllamada = CC_OpenCTI.registrarLlamadaSaliente(JSON.serialize(input));
            Test.stopTest();
            
            List<CC_Llamada__c> llamada = [SELECT id,CC_Cuenta__c from CC_Llamada__c where id = :idllamada limit 1];
            List<Task> task = [SELECT id, WhatId from Task where CC_Llamada_Id__c = :idllamada and WhatId = : caso.Id];
            System.assertEquals(llamada.isEmpty(), false, 'No se ha creado llamada relacionada con el caso');
            System.assertEquals(task.isEmpty(), false, 'No se ha creado tarea relacionada con la llamada y el caso');
        }
    }
}