@isTest
private class CC_Gestion_Derivar_CSBD_Test {
    @TestSetup
    static void makeData() {

        Map<String, User> usuarios = CC_TestDataFactory.insertUserAdminOperador('U0123456');
        User usuarioAdmin = usuarios.get('admin');
        User operadorCliente = usuarios.get('operador');

        System.runAs(usuarioAdmin) {

        //Listas de valores
        Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        Id recordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');

        List<CC_Lista_Valores__c> listas = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c listaDerivar = new CC_Lista_Valores__c();
        listaDerivar.Name = 'Textos operativa Derivar';
        listaDerivar.RecordTypeId = recordTypeLista;
        listas.add(listaDerivar);
        insert listas;

        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.Name = 'Texto oportunidad tarea existente';
        valor.RecordTypeId = recordTypeValor;
        valor.CC_Lista__c = listaDerivar.Id;
        valor.CC_Mensajes_Mostrar__c = 'No es posible crear una oportunidad porque ya existe una cita o tarea creada';
        valores.add(valor);

        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.Name = 'Oportunidad formalizada';
        valor2.RecordTypeId = recordTypeValor;
        valor2.CC_Lista__c = listaDerivar.Id;
        valor2.CC_Mensajes_Mostrar__c = 'Mensaje parametrizable de la oportunidad formalizada';
        valores.add(valor2);


        CC_Lista_Valores__c valor3 = new CC_Lista_Valores__c();
        valor3.Name = 'Oportunidad en curso contexto';
        valor3.RecordTypeId = recordTypeValor;
        valor3.CC_Lista__c = listaDerivar.Id;
        valor3.CC_Mensajes_Mostrar__c = 'Mensaje parametrizable de la oportunidad formalizada';
        valores.add(valor3);

        CC_Lista_Valores__c valor4 = new CC_Lista_Valores__c();
        valor4.Name = 'Oportunidad en curso';
        valor4.RecordTypeId = recordTypeValor;
        valor4.CC_Lista__c = listaDerivar.Id;
        valor4.CC_Mensajes_Mostrar__c = 'Mensaje parametrizable de la oportunidad formalizada';
        valores.add(valor4);


        insert valores;

        List<CC_MCC__c> tematicas = new List<CC_MCC__c>();
        List<CC_MCC__c> productos = new List<CC_MCC__c>();
        List<CC_MCC__c> motivos = new List<CC_MCC__c>();
        List<CC_MCC__c> mccCreado = new List<CC_MCC__c>();

        Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id productoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
        Id motivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');

        List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();

        CC_MCC__c tematica = new CC_MCC__c(
        Name = 'Tematica Test',
        RecordTypeId = tematicaId,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Canal_Operativo__c = 'Cajero',
        CC_Codigo_Externo__c = 'TE-000001'
        );
        tematicas.add(tematica);
        mccCreado.add(tematica);
        insert tematicas;

        CC_MCC__c producto = new CC_MCC__c(
        Name = 'Producto Test',
        RecordTypeId = productoId,
        CC_Tematica__c = tematica.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'PR-000001'
        );
        productos.add(producto);
        mccCreado.add(producto);
        insert productos;

        CC_MCC__c motivoCSBD3N = new CC_MCC__c(
        Name = 'CSBD 3N',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'CSBD 3N',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000013'
        );
        motivos.add(motivoCSBD3N);
        mccCreado.add(motivoCSBD3N);

        CC_MCC__c motivoCSBDContratar = new CC_MCC__c(
        Name = 'CSBD Contratar',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'CSBD Contratar',
        CC_Ambito_Tareas_Imagin__c = 'CSBD Contratar',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000014'
        );
        motivos.add(motivoCSBDContratar);
        mccCreado.add(motivoCSBDContratar);

        CC_MCC__c motivoCSBDNoContratar = new CC_MCC__c(
        Name = 'CSBD No Contratar',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'CSBD No Contratar',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000015'
        );
        motivos.add(motivoCSBDNoContratar);
        mccCreado.add(motivoCSBDNoContratar);

        CC_MCC__c motivoEnrollment = new CC_MCC__c(
        Name = 'Enrollment Sign',
        RecordTypeId = motivoId,
        CC_Ambito_Tareas_Caixa__c = 'Testamentaría',
        CC_Ambito_Tareas_Imagin__c = 'Testamentaría',
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000012'
        );
        motivos.add(motivoEnrollment);
        mccCreado.add(motivoEnrollment);
        insert motivos;

        for(CC_MCC__c record : mccCreado) {
            CC_MCC__Share mccShare = new CC_MCC__Share();
            mccShare.ParentId = record.Id;
            mccShare.UserOrGroupId = operadorCliente.Id;
            mccShare.AccessLevel = 'Edit';
            totalPermisosMCC.add(mccShare);
        }
        insert totalPermisosMCC;

        //RecordType
        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Id rtClientePA = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        Id rtCliente = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');

        List<AccountShare> totalPermisosAccount = new List<AccountShare>();
        List<ContactShare> totalPermisosContact = new List<ContactShare>();

        List<Account> accounts = new List<Account>();

        Account cuenta2 = new Account(
            Name = 'Cuenta02'
        );
        accounts.add(cuenta2);

        Account cuentaImagin = new Account(
            FirstName = 'Cuenta Test',
            LastName = 'test',
            CC_Email__c = 'cuenta@test.com',
            AV_IndicadoresClientes__c = '28',
            CC_Numero_Documento__c = '45729937A',
            AV_Cliente__c = true,
            RecordtypeId =  rtClientePA
        );
        accounts.add(cuentaImagin);
        insert accounts;

        for(Account a : accounts){
            AccountShare acshare = new AccountShare();
            acshare.AccountId = a.Id;
            acshare.UserOrGroupId = operadorCliente.Id;
            acshare.AccountAccessLevel = 'Edit';
            acshare.OpportunityAccessLevel = 'Edit';
            acshare.CaseAccessLevel = 'Edit';
            totalPermisosAccount.add(acshare);
        }

        insert totalPermisosAccount;

        //Contactos

        List <Contact> insertContact = new List <Contact>();

        Contact contacto2 = new Contact(
            FirstName = 'Contacto',
            LastName = '02',
            CC_NumPerso__c = '12345568',
            AccountId = cuenta2.Id,
            CC_Idioma__c = 'Es',
            RecordTypeId = rtCliente
        );

        insertContact.add(contacto2);

        insert insertContact;

        ContactShare contactShare = new ContactShare();
        contactShare.ContactId = contacto2.Id;
        contactShare.UserOrGroupId = CC_TestDataFactory.getUserOperadorCliente().Id;
        contactShare.ContactAccessLevel = 'Edit';
        totalPermisosContact.add(contactShare);

        Boolean excepcion = false;

        try {
            //Database.insert(totalPermisosAccount, true);
            insert totalPermisosAccount;
        } catch(Exception e) {
            excepcion = true;
        }

        try {
            //Database.insert(totalPermisosContact, true);
            insert totalPermisosContact;
        } catch(Exception e) {
            excepcion = true;
        }

        //Casos
        List <Case> insertCase = new List <Case>();

        Case casoEnrollment = new Case(
            Description = 'casoEnrollmentPreguntaSi',
            Subject = 'casoEnrollmentPreguntaSi',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoEnrollment.Id,
            CC_Motivo__c = 'Enrollment Sign',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
        );
        insertCase.add(casoEnrollment);

        Case casoCSBDNoContratar = new Case(
            Description = 'casoCSBDNoContratar',
            Subject = 'casoCSBDNoContratar',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoCSBDNoContratar.Id,
            CC_Motivo__c = 'CSBD No contratar',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
        );
        insertCase.add(casoCSBDNoContratar);

        Case casoConOportunidad = new Case(
            Description = 'casoConOportunidad',
            Subject = 'casoConOportunidad',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuentaImagin.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivoCSBDNoContratar.Id,
            CC_Motivo__c = 'CSBD No contratar',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            RecordTypeId = recordTypeCaso
        );
        insertCase.add(casoConOportunidad);
        insert insertCase;
        }
    }

    @isTest
    static void devolverCasoCSBD() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoConOportunidad' LIMIT 1];
        Id rtOportunidad = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_MAC');
           Opportunity oportunidad = new Opportunity(
            RecordTypeId = rtOportunidad,
            Name = 'Oportunidad Test',
            StageName = 'Solicitud',
            CSBD_Estado__c = 'Activa',
            CSBD_CasoOrigen__c = caso.Id
        );

        insert oportunidad;

        Test.startTest();
        Map<String, Object> respuesta = new Map<String, Object>();
        respuesta.put('casoId', caso.Id);
        respuesta.put('oportunidadId', oportunidad.Id);
        Boolean excepcion = false;
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            try {
                CC_Gestion_Derivar_CSBD.devolverCasoCSBD(respuesta);
            } catch (Exception e) {
                excepcion = true;
            }
            System.assertEquals(excepcion, false);
            try {
                respuesta.put('casoId', '');
                CC_Gestion_Derivar_CSBD.devolverCasoCSBD(respuesta);
            } catch (Exception e) {
                excepcion = true;
            }
            System.assertEquals(excepcion, true);
        }
        Test.stopTest();
    }

    @isTest
    static void crearOportunidadConTarea() {
        Test.startTest();


        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Case caso = [SELECT Id FROM Case WHERE Subject = 'casoCSBDNoContratar' LIMIT 1];
            Id rtTareaCC = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            Task tarea = new Task(
                recordTypeId = rtTareaCC,
                WhatId = caso.Id,
                Type = 'Cita gestor',
                Status = 'Completed',
                Subject = 'Prueba',
                Description = 'Esto es una prueba',
                ActivityDate = System.today()
            );
            insert tarea;
            CC_Gestion_Derivar_CSBD.crearOportunidad(caso.Id);
        }
        Case casoSinOportunidad = [SELECT CC_Oportunidad_Creada__c FROM Case WHERE Subject = 'casoCSBDNoContratar' LIMIT 1];
        System.assertEquals(casoSinOportunidad.CC_Oportunidad_Creada__c, false);
        Test.stopTest();
    }

    @isTest
    static void testCrearOportunidadValidacionOk() {
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Map<String, Object> resultado = CC_Gestion_Derivar_CSBD.crearOportunidad(caso.Id);
            System.assertEquals((Boolean) resultado.get('validacionCrearOportunidad'), true);
        }
        Test.stopTest();
    }

    @isTest
    static void testCrearOportunidadExitoso() {
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoEnrollmentPreguntaSi' LIMIT 1];
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Map<String, Object> resultado = CC_Gestion_Derivar_CSBD.crearOportunidadCSBD(caso.Id);
            System.assertEquals((Boolean) resultado.get('oppCreada'), true);
        }
        Test.stopTest();
    }

    // @isTest
    // static void testCrearTareasRellamada() {
    //     // Crear un caso de prueba
    //     Case caso = new Case(
    //         Subject = 'Caso de prueba',
    //         Description = 'Descripción del caso de prueba',
    //         CC_Oportunidad_creada__c = false,
    //         CC_Numero_Documento__c = '123456789',
    //         CC_MCC_Tematica__c = null,
    //         CC_MCC_ProdServ__c = null,
    //         CC_Producto_Servicio__c = null
    //     );
    //     insert caso;

    //     // Crear una oportunidad relacionada con el caso
    //     RecordType oportunidadRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'CSBD_MAC'].get(0);
    //     Opportunity oportunidad = new Opportunity(
    //         Name = 'Oportunidad de prueba',
    //         StageName = 'En curso',
    //         CSBD_Contact__c = caso.ContactId,
    //         CSBD_CasoOrigen__c = caso.Id,
    //         RecordTypeId = oportunidadRecordType.Id
    //     );
    //     insert oportunidad;

    //     System.runAs(CC_TestDataFactory.getUserAdmin()) {
    //         Test.startTest();

    //         // Llamar al método crearTareasRellamada
    //         CC_Gestion_Derivar_CSBD.crearTareasRellamada(caso.Id, 'Descripción de la tarea de rellamada');
    //         Test.StopTest();

    //         // Verificar que se crearon las tareas de rellamada

    //         //List<Task> tareas = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Consulta oportunidad en curso'];
    //         System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id AND Type = 'Consulta oportunidad en curso']);
    //     }
    //     //System.assert(tareas.size() > 0, 'No se crearon las tareas de rellamada');

    // }

    @isTest
    static void testCrearOportunidadConTareasRellamadas() {
        // Crear un caso de prueba
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoConOportunidad' LIMIT 1];

        // Crear una tarea de rellamada existente para el caso
        Task tareaRellamada = new Task(
            WhatId = caso.Id,
            Type = 'Consulta oportunidad en curso',
            Status = 'Completed',
            Subject = 'Prueba',
            Description = 'Esto es una prueba',
            ActivityDate = System.today()
        );
        insert tareaRellamada;

        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Test.startTest();
            Map<String, Object> resultado = CC_Gestion_Derivar_CSBD.crearOportunidad(caso.Id);
            System.assert(resultado.get('tareasRellamadas') == true);
            Test.StopTest();
        }

    }

    @isTest
    static void testIdentificarTareasRellamadasExistentes() {
        // Crear un caso de prueba
        Case caso = [SELECT Id FROM Case WHERE Subject = 'casoConOportunidad' LIMIT 1];

        // Crear una tarea de rellamada existente para el caso
        Task tareaRellamada = new Task(
            WhatId = caso.Id,
            Type = 'Consulta oportunidad en curso',
            Status = 'Completed',
            Subject = 'Prueba',
            Description = 'Esto es una prueba',
            ActivityDate = System.today()
        );
        insert tareaRellamada;


        // Invocar el método identificarTareasRellamadasExistentes
        System.runAs(CC_TestDataFactory.getUserAdmin()) {
            Test.startTest();
            Map<String, Object> resultado = CC_Gestion_Derivar_CSBD.identificarTareasRellamadasExistentes(caso);

            System.assert(resultado.get('tareasRellamadas') == true);

            Test.StopTest();
        }
    }

    @isTest
    static void testOportunidadRecienteExistenteCerrado() {
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta02' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = '02' LIMIT 1];

        Case caso = new Case(
            Description = 'casoConOportunidad',
            Subject = 'casoConOportunidad',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuenta.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            OwnerId =  CC_TestDataFactory.getUserOperadorCliente().Id,
            ContactId = contacto.Id
        );
        insert caso;



        RecordType oportunidadRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'CSBD_MAC'].get(0);
        Opportunity oportunidad = new Opportunity(
            Name = 'Oportunidad de prueba',
            StageName = 'Formalizada',
            CSBD_Contact__c = caso.ContactId,
            CSBD_CasoOrigen__c = caso.Id,
            RecordTypeId = oportunidadRecordType.Id,
            OwnerId =CC_TestDataFactory.getUserOperadorCliente().Id,
            CSBD_Motivo_MAC__c = 'motivo',
            AccountId = cuenta.Id
        );

        insert oportunidad;

        Opportunity oportunidadCerrada =  CSBD_Opportunity.cerrarOportunidad(oportunidad.Id, 'Formalizada', 'Tarjeta crédito');

        update oportunidadCerrada;


        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Test.startTest();

            CC_Gestion_Derivar_CSBD.identificarOportunidadesSimilares(caso);

            System.assertEquals(1, [SELECT COUNT() FROM Task WHERE WhatId = :caso.Id]);

            Test.stopTest();
        }
    }

    @isTest
    static void testOportunidadRecienteExistenteAbierto() {
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta02' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = '02' LIMIT 1];

        Case caso = new Case(
            Description = 'casoConOportunidad',
            Subject = 'casoConOportunidad',
            Origin = 'Email',
            Status = 'Activo',
            accountId = cuenta.Id,
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario web',
            CC_Detalles_Consulta__c = 'Caso de Contact Center',
            OwnerId =  CC_TestDataFactory.getUserOperadorCliente().Id,
            ContactId = contacto.Id
        );
        insert caso;

        RecordType oportunidadRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'CSBD_MAC'].get(0);
        Opportunity oportunidad = new Opportunity(
            Name = 'Oportunidad de prueba',
            StageName = 'Solicitud',
            CSBD_Contact__c = caso.ContactId,
            CSBD_CasoOrigen__c = caso.Id,
            RecordTypeId = oportunidadRecordType.Id,
            OwnerId =CC_TestDataFactory.getUserOperadorCliente().Id,
            CSBD_Motivo_MAC__c = 'motivo',
            AccountId = cuenta.Id
        );
        insert oportunidad;

        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {
            Test.startTest();

            CC_Gestion_Derivar_CSBD.identificarOportunidadesSimilares(caso);

            System.assertEquals(caso.Subject, 'casoConOportunidad');

            Test.stopTest();
        }
    }
}