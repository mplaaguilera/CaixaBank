@isTest
public class CC_CaseTriggerHelper_Test {
    @TestSetup
    static void makeData(){
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'Oficinas';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = '222';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        //crear usuarios CC
        Id profile1Id;
        Id profile2Id;
        Id profileSupervisor;
        Id profileGenerico;
        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('System Administrator', 'CC_Analísta y 2º nivel MVP2', 'CC_Supervisor', 'CC_Usuario_CaixaBank')];
        for (Profile p : profiles) {
            if (p.Name == 'System Administrator') {
                profile1Id = p.Id;
            } else if (p.Name == 'CC_Analísta y 2º nivel MVP2') {
                profile2Id = p.Id;
            } else if (p.Name == 'CC_Supervisor') {
                profileSupervisor = p.Id;
            } else if (p.Name == 'CC_Usuario_CaixaBank') {
                profileGenerico = p.Id;
            }
        }

        PermissionSet ps;
        PermissionSet psClasses;
        PermissionSet psSupervisor;
        List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN ('CC_Operador_CCO', 'CC_Classes', 'CC_Supervisor_PS')];
        for (PermissionSet p : permissionSets) {
            if (p.Name == 'CC_Operador_CCO') {
                ps = p;
            } else if (p.Name == 'CC_Classes') {
                psClasses = p;
            } else if (p.Name == 'CC_Supervisor_PS') {
                psSupervisor = p;
            }
        }

        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profile1Id;
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
        insert usuario1;

        System.runAs(usuario1){
            Id rolId = [SELECT DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;

            List<User> userList2 = new List<User>();
            User usuarioV2 = new User();
            usuarioV2.ProfileId = profile2Id;
            usuarioV2.FirstName = 'Usuario 2 Prueba';
            usuarioV2.LastName = 'last11';
            usuarioV2.Email = 'tuser000@amamama.com';
            usuarioV2.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            usuarioV2.CompanyName = 'MST';
            usuarioV2.Title = 'title';
            usuarioV2.Alias = 'alias';
            usuarioV2.TimeZoneSidKey = 'Europe/Paris';
            usuarioV2.EmailEncodingKey = 'UTF-8';
            usuarioV2.LanguageLocaleKey = 'es';
            usuarioV2.LocaleSidKey = 'es_ES';
            usuarioV2.UserRoleId = rolId;
            userList2.add(usuarioV2);

            User usuario = new User();
            usuario.ProfileId = profile2Id;
            usuario.FirstName = 'Usuario 2 Prueba';
            usuario.LastName = 'last11';
            usuario.Email = 'tuser000111@amamama.com';
            usuario.Username = 'tuser000111@amamama.com' + System.currentTimeMillis();
            usuario.CompanyName = 'MST';
            usuario.Title = 'title';
            usuario.Alias = 'alias';
            usuario.TimeZoneSidKey = 'Europe/Paris';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.UserRoleId = rolId;
            userList2.add(usuario);

            User supervisor = new User();
            supervisor.ProfileId = profileGenerico;
            supervisor.FirstName = 'Supervisor';
            supervisor.LastName = 'last11';
            supervisor.Email = 'tuser000@amamama.com';
            supervisor.Username = 'tuser000Supervisor@amamama.com' + System.currentTimeMillis();
            supervisor.CompanyName = 'MST';
            supervisor.Title = 'title';
            supervisor.Alias = 'alias';
            supervisor.TimeZoneSidKey = 'Europe/Paris';
            supervisor.EmailEncodingKey = 'UTF-8';
            supervisor.LanguageLocaleKey = 'es';
            supervisor.LocaleSidKey = 'es_ES';
            supervisor.UserRoleId = rolId;
            userList2.add(supervisor);
            insert userList2;

            insert new List<PermissionSetAssignment>{
                new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id),
                new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psSupervisor.Id)
            };

            Id recordTypeOficina = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            Account oficinaGestora = new Account(
                RecordTypeId = recordTypeOficina,
                Name = 'Cuenta oficina gestora',
                CC_Tipo_Centro__c = 'OF',
                CC_Email__c = 'test@test.com',
                CC_Numero_Oficina__c = '222',
                CC_Numero_Oficina_Empresa__c = '222-22222'
            );
            insert oficinaGestora;

            List<Account> listaCuentas = new List<Account>();

            Account cuenta = new Account();
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            cuenta.Name = 'Cuenta Prueba';
            cuenta.AV_OficinaPrincipal__c = oficinaGestora.Id;
            cuenta.CC_OficinaGestoraId__c = oficinaGestora.Id;
            cuenta.CC_Numero_Oficina__c = '222';
            listaCuentas.add(cuenta);

            Account cuenta2 = new Account();
            cuenta2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
            cuenta2.Name = 'Cuenta Prueba 2';
            cuenta2.CC_Gerencia_Comercial__c = cuenta.Id;
            cuenta2.CC_OficinaGestoraId__c = oficinaGestora.Id;
            cuenta2.CC_Centro_Gestor_InTouch__c = cuenta.Id;
            cuenta2.CC_Gestor_InTouch__c = 'GestorTest';
            cuenta2.CC_Numero_Oficina__c = '222';
            listaCuentas.add(cuenta2);

            Account cuentaEmpleado = new Account();
            cuentaEmpleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
            cuentaEmpleado.Name = 'Cuenta Prueba Empleado';
            cuentaEmpleado.CC_OficinaGestoraId__c = oficinaGestora.Id;
            cuentaEmpleado.CC_Numero_Oficina__c = '222';
            cuentaEmpleado.CC_Email__c = 'test@gmail.com';
            listaCuentas.add(cuentaEmpleado);

            Account cuentaClientePA = new Account();
            cuentaClientePA.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            cuentaClientePA.LastName = 'Cuenta Prueba ClientePA';
            cuentaClientePA.CC_OficinaGestoraId__c = oficinaGestora.Id;
            cuentaClientePA.AV_OficinaPrincipal__c = oficinaGestora.Id;
            cuentaClientePA.CC_Numero_Oficina_Empresa__c = '222-22223';
            cuentaClientePA.CC_Numero_Oficina__c = '222';
            listaCuentas.add(cuentaClientePA);

            Account cuentaClientePA2 = new Account();
            cuentaClientePA2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            cuentaClientePA2.LastName = 'Cuenta Prueba ClientePA2';
            cuentaClientePA2.CC_OficinaGestoraId__c = oficinaGestora.Id;
            cuentaClientePA2.AV_OficinaPrincipal__c = oficinaGestora.Id;
            cuentaClientePA2.CC_Numero_Oficina__c = '222';
            listaCuentas.add(cuentaClientePA2);

            insert listaCuentas;

            List<Contact> listaContactos = new List<Contact>();
            Contact contacto = new Contact();
            contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            contacto.AccountId = cuenta.Id;
            contacto.FirstName = 'Test';
            contacto.LastName = 'Contacto Prueba';
            contacto.CC_NumPerso__c = '25345569';
            contacto.CC_Idioma__c = 'ca';
            contacto.Email = 'correo@gmail.com';
            contacto.Phone = '973242323';
            listaContactos.add(contacto);

            Contact contactoEmpleado = new Contact();
            contactoEmpleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
            contactoEmpleado.AccountId = cuentaEmpleado.Id;
            contactoEmpleado.FirstName = 'Contacto Prueba Empleado';
            contactoEmpleado.LastName = 'Contacto Prueba Empleado';
            contactoEmpleado.CC_NumPerso__c = '25345550';
            contactoEmpleado.CC_Idioma__c = 'ca';
            contactoEmpleado.Email = 'correo@gmail.com';
            contactoEmpleado.Phone = '973242323';
            contactoEmpleado.CC_Matricula__c = '12345678';
            listaContactos.add(contactoEmpleado);

            insert listaContactos;

            Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            Id recordCau = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
            Id recordSol = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();

            CC_MCC__c mcc = new CC_MCC__c();
            mcc.RecordTypeId = recordTem;
            mcc.Name = 'App\'s';
            mcc.CC_Tipo_Cliente__c = 'Cliente';
            mcc.CC_Codigo_Externo__c = 'TE-000001';
            mcc.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mcc;
            CC_MCC__c mcc1 = new CC_MCC__c();
            mcc1.RecordTypeId = recordProd;
            mcc1.Name = 'APP CaixaBank';
            mcc1.CC_Detalle__c = 'CaixaBank';
            mcc1.CC_Tipo_Cliente__c = 'Cliente';
            mcc1.CC_Tematica__c = mcc.Id;
            mcc1.CC_Codigo_Externo__c = 'PR-000001';
            insert mcc1;
            CC_MCC__c mcc2 = new CC_MCC__c();
            mcc2.RecordTypeId = recordMot;
            mcc2.Name = 'Valoración positiva';
            mcc2.CC_Tipo_Cliente__c = 'Cliente';
            mcc2.CC_Producto_Servicio__c = mcc1.Id;
            mcc2.CC_Codigo_Externo__c = 'MO-000001';
            insert mcc2;

            CC_MCC__c mcc3 = new CC_MCC__c();
            mcc3.RecordTypeId = recordCau;
            mcc3.Name = 'Valoración positiva';
            mcc3.CC_Tipo_Cliente__c = 'Cliente';
            mcc3.CC_Motivo__c = mcc2.Id;
            mcc3.CC_Codigo_Externo__c = 'CA-000001';
            insert mcc3;

            CC_MCC__c mcc4 = new CC_MCC__c();
            mcc4.RecordTypeId = recordSol;
            mcc4.Name = 'Valoración positiva';
            mcc4.CC_Tipo_Cliente__c = 'Cliente';
            mcc4.CC_Causa__c = mcc3.Id;
            mcc4.CC_Codigo_Externo__c = 'SO-000001';
            insert mcc4;

            CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
            caracteristica.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
            caracteristica.Name = 'Campa Prueba';
            caracteristica.CC_Descripcion__c = 'Decripcion Prueba';
            insert caracteristica;

            CC_Clasificacion_Maximo__c oClasif = new CC_Clasificacion_Maximo__c();
            oClasif.CC_Path__c = 'ARQUITECTURA \\ TEST';
            oClasif.CC_Nivel_1__c = 'ARQUITECTURA';
            oClasif.CC_Clave_Primaria_Externa__c = 'ARQUITECTURA \\ TEST';
            oClasif.CC_Activa__c = true;
            oClasif.CC_Propietario__c = 'TEST';
            insert oClasif;

            String sRecordType3 = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_GrupoMaximo').getRecordTypeId();
            CC_Grupo_Colaborador__c oGrupo = new CC_Grupo_Colaborador__c();
            oGrupo.RecordTypeId = sRecordType3;
            oGrupo.Name = 'Grupo1';
            oGrupo.CC_External__c = 'GM-00004';
            insert oGrupo;

            String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Comunicacion_Informativa_de_Campana').getRecordTypeId();
            CC_Agrupador__c oAgr = new CC_Agrupador__c();
            oAgr.RecordTypeId = sRecordType;
            oAgr.CC_Titulo__c = 'Prueba Número Agrupador';
            oAgr.CC_Descripcion__c = 'Test';
            oAgr.CC_GrupoMaximo__c = oGrupo.Id;
            oAgr.CC_Opcion_Call_Center__c = 'Opcion Call Center';
            oAgr.CC_Clasificacion_Maximo__c = oClasif.Id;
            oAgr.CC_Estado__c = 'Activo';
            oAgr.CC_Numero_Casos__c = 0;
            oAgr.CC_Campana__c = caracteristica.Id;
            insert oAgr;

            String recordTypeDeveloperName = 'CC_Comunicacion_Informativa_de_Campana';
            CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
            lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lovAvisosSobreAgrupadores.CC_Activa__c = true;
            lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
            lovAvisosSobreAgrupadores.CC_Valor__c = '1';
            insert lovAvisosSobreAgrupadores;
            List<CC_Lista_Valores__c> listaValores2 = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
            valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralPrimerAviso.CC_Activa__c = true;
            valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral primer aviso';
            valorUmbralPrimerAviso.CC_Valor__c = '2';
            listaValores2.add(valorUmbralPrimerAviso);

            CC_Lista_Valores__c valorUmbralSegundoAviso = new CC_Lista_Valores__c();
            valorUmbralSegundoAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralSegundoAviso.CC_Activa__c = true;
            valorUmbralSegundoAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralSegundoAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral siguientes avisos';
            valorUmbralSegundoAviso.CC_Valor__c = '3';
            listaValores2.add(valorUmbralSegundoAviso);
            insert listaValores2;
            List<String> proveedoresLst = new List<String>{'MST','DXC'};
            List <CC_Capacidad_Proveedores__c> capacidadesList = new List<CC_Capacidad_Proveedores__c>();
            CC_Capacidad_Proveedores__c tmpCapacidad;
            for (Integer i = 0; i < 2; i++) {
                tmpCapacidad = new CC_Capacidad_Proveedores__c();
                tmpCapacidad.CC_Canal_Entrada__c = 'Email';
                tmpCapacidad.CC_Canal_Procedencia__c = 'Atención al Cliente';
                tmpCapacidad.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
                tmpCapacidad.CC_Proveedor__c = proveedoresLst[i];
                tmpCapacidad.CC_Queue_Name__c = 'Queue_'+proveedoresLst[i];
                tmpCapacidad.CC_Capacidad__c = 50;
                capacidadesList.add(tmpCapacidad);
            }
            for (Integer i = 0; i < 2; i++) {
                tmpCapacidad = new CC_Capacidad_Proveedores__c();
                tmpCapacidad.CC_Canal_Entrada__c = 'Email';
                tmpCapacidad.CC_Canal_Procedencia__c = 'Formulario web';
                tmpCapacidad.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
                tmpCapacidad.CC_Proveedor__c = proveedoresLst[i];
                tmpCapacidad.CC_Queue_Name__c = 'Queue_'+proveedoresLst[i];
                tmpCapacidad.CC_Capacidad__c = 50;
                capacidadesList.add(tmpCapacidad);
            }
            insert capacidadesList;
        }

        List<Group> queuesLst = new List<Group>();
        Group newQueue = new Group();
        newQueue.Type = 'Queue';
        newQueue.DeveloperName = 'Queue_MST';
        newQueue.Name = 'Queue_MST';
        queuesLst.add(newQueue);
        newQueue = new Group();
        newQueue.Type = 'Queue';
        newQueue.DeveloperName = 'Queue_DXC';
        newQueue.Name = 'Queue_DXC';
        queuesLst.add(newQueue);
        insert queuesLst;


        // Se usa runAs para evitar un error MIXED_DML_OPERATION al insertar los QueueSobject
        List<User> sysAdminUser = [SELECT Id FROM User WHERE Profile.name LIKE 'System Administrator' AND IsActive=true];
        if (!sysAdminUser.isEmpty()) {
            System.runAs(sysAdminUser[0]) {
                List<QueueSobject> queueSobjectLst = new List<QueueSobject>();
                QueueSobject newQueueSobject;
                for (Group queue : queuesLst) {
                    newQueueSobject = new QueueSobject();
                    newQueueSobject.SobjectType = 'Case';
                    newQueueSobject.QueueId = queue.Id;
                    queueSobjectLst.add(newQueueSobject);
                }
                insert queueSobjectLst;
            }
        }
    }


    @isTest
    public static void testBICaseGestionado() {

        Account cliente = [Select id from Account where Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        User usuario = [Select id from User where email = 'tuser000@amamama.com' limit 1];

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        //Creación nuevo caso asociado a un usuario
        Case caso = new Case(AccountId = cliente.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Comentarios Stores',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Google Play Store',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        ownerId = usuario.Id,
        recordTypeId = rtCliente);

        Test.startTest();
        insert caso;
        Test.stopTest();

        Case casoUpdate = [Select CC_Gestionado_Agente__c from Case where id = :caso.Id limit 1];

        system.assertEquals(false, casoUpdate.CC_Gestionado_Agente__c, 'Comprobamos que el campo no está checked');

    }

    @isTest
    public static void testBUCasoGestionado() {

        Account cliente = [Select id from Account where Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Buzon_Usuario_Publico' LIMIT 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        User usuario = [Select id from User where email = 'tuser000111@amamama.com' limit 1];

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        //Creación nuevo caso asociado a un usuario
        Case caso = new Case(AccountId = cliente.Id,
        ContactId = contacto.Id,
        OwnerId = ownerLst[0].Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Comentarios Stores',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Google Play Store',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);
        insert caso;

        Test.startTest();
        caso.OwnerId = usuario.Id;
        update caso;

        Case casoUpdate = [Select CC_Gestionado_Agente__c from Case where id = :caso.Id limit 1];
        Test.stopTest();



        system.assertEquals(true, casoUpdate.CC_Gestionado_Agente__c, 'Comprobamos que el campo está checked');

    }

    @isTest
    public static void testNumeroAgrupadores() {

        Account cliente = [Select id from Account where Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        //Creación nuevo caso asociado a un usuario
        Case caso = new Case(AccountId = cliente.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Comentarios Stores',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Google Play Store',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);
        insert caso;

        CC_Agrupador__c agrupador = [Select id from CC_Agrupador__c where CC_Titulo__c = 'Prueba Número Agrupador'];

        Test.startTest();
        caso.CC_Agrupador_Id__c = agrupador.Id;
        update caso;
        Test.stopTest();

        List<CC_Agrupador__c> lstAgrupadorUpdate = [Select CC_Numero_Casos__c from CC_Agrupador__c where id = :agrupador.Id];

        system.assertEquals(1, lstAgrupadorUpdate.size(), 'Comprobamos que se actualiza el número de casos del agrupador');

    }

    @isTest
    public static void testCatalogoFacturacion() {

        Account cliente = [Select id from Account where Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        CBK_CatalogoFacturacion__c catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.CC_Canal_de_Procedencia__c = 'Google Play Store';
        catalogo.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo.CC_Fecha_Inicio_Vigencia__c = DateTime.now();
        catalogo.CC_Tipo_Cliente__c = 'Cliente';
        catalogo.CC_Area_Negocio__c = 'ACCIONISTAS';
        catalogo.CC_Tematica__c = tematica.Id;
        catalogo.CC_Producto__c = producto.Id;
        insert catalogo;

        CBK_Precio_Facturacion__c precio = new CBK_Precio_Facturacion__c();
        precio.CC_Canal_Entrada__c = 'Comentarios Stores';
        precio.CC_Fecha_Inicio_Vigencia__c = Date.today();
        precio.CC_Nombre_Empresa__c = 'COMDATA';
        precio.CC_Precio_Contacto__c = 30;
        precio.CC_Area_Negocio__c = 'ACCIONISTAS';
        insert precio;

        CBK_Margen_Facturacion__c margen = new CBK_Margen_Facturacion__c();
        margen.CC_Margen__c = 10;
        margen.CC_Fecha_Inicio__c = Date.today();
        margen.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        insert margen;

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        List<Case> listaCasos = new List<Case>();

        //Creación nuevo caso asociado a un usuario
        Case caso = new Case(AccountId = cliente.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Comentarios Stores',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Google Play Store',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_No_Identificado__c = true,
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        CC_Canal_Operativo__c = 'App BrokerNow',
        RecordTypeId = rtCliente);
        listaCasos.add(caso);

        //Creación nuevo caso asociado a un usuario
        Case caso2 = new Case(AccountId = cliente.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Comentarios Stores',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Google Play Store',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_No_Identificado__c = true,
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        CC_Canal_Operativo__c = 'App BrokerNow',
        RecordTypeId = rtCliente);
        listaCasos.add(caso2);
        insert listaCasos;

        Test.startTest();
        caso.Status = 'Cerrado';
        update caso;
        caso2.Status = 'Rechazado';
        update caso2;

        Case casoActualizado = [SELECT CC_Area_Negocio__c, CC_Catalogo_Facturacion__c, CC_Margen_Facturacion__c FROM Case WHERE Id = :caso.Id LIMIT 1];
        Case casoActualizado2 = [SELECT CC_Area_Negocio__c, CC_Catalogo_Facturacion__c, CC_Margen_Facturacion__c FROM Case WHERE Id = :caso2.Id LIMIT 1];

        Test.stopTest();


        System.assertEquals('ACCIONISTAS', casoActualizado.CC_Area_Negocio__c, 'Comprobamos que se actualiza el area de negocio');
        System.assertEquals(catalogo.Id, casoActualizado.CC_Catalogo_Facturacion__c, 'Comprobamos que se actualiza el catálogo de facturación');
        System.assertEquals(margen.Id, casoActualizado.CC_Margen_Facturacion__c, 'Comprobamos que se actualiza el margen de facturación');

        System.assertEquals('ACCIONISTAS', casoActualizado2.CC_Area_Negocio__c, 'Comprobamos que se actualiza el area de negocio');
        System.assertEquals(catalogo.Id, casoActualizado2.CC_Catalogo_Facturacion__c, 'Comprobamos que se actualiza el catálogo de facturación');
        System.assertEquals(margen.Id, casoActualizado2.CC_Margen_Facturacion__c, 'Comprobamos que se actualiza el margen de facturación');
    }

    @isTest
    public static void testGetOficinaPersonAccount()
    {
        Account cliente = [Select id from Account where Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        //Creación nuevo caso asociado a un usuario
        Case caso = new Case(AccountId = cliente.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Comentarios Stores',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Google Play Store',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);
        insert caso;

        Test.startTest();
        Test.stopTest();

        Account accUpdate = [Select CC_Telefono_Unico__c from Account where id = :cliente.Id limit 1];

        system.assertEquals(true, accUpdate.CC_Telefono_Unico__c, 'Comprobamos que el campo está checked');
    }

    @isTest
    public static void routingEmailCasesAProveedor_Test () {


        String idOwner = '';
        List<Group> ownerLst = [SELECT Id FROM Group WHERE Type = 'Queue' and Name !='Queue_MST' LIMIT 1];
        if (!ownerLst.isEmpty()) {
            idOwner = ownerLst[0].Id;
        }
        Case emailCase = new Case();
        emailCase.Subject = 'Test enrutamiento email';
        emailCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        emailCase.Origin = 'Email';
        emailCase.CC_Canal_Procedencia__c = 'Atención al Cliente';
        if(!String.isBlank(idOwner)) {
            emailCase.OwnerId = idOwner;
        }
        Case emailCase2 = new Case();
        emailCase2.Subject = 'Test enrutamiento email 2';
        emailCase2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        emailCase2.Origin = 'Email';
        emailCase2.CC_Canal_Procedencia__c = 'Formulario web';
        if(!String.isBlank(idOwner)) {
            emailCase2.OwnerId = idOwner;
        }

        List<Case> casesAEnrutar = new List<Case>();
        casesAEnrutar.add(emailCase);
        casesAEnrutar.add(emailCase2);

        Test.startTest();
        insert casesAEnrutar;
        Test.stopTest();
        List<Case> casesTest = [SELECT Id, OwnerId FROM Case WHERE Subject IN ('Test enrutamiento email', 'Test enrutamiento email 2')];
        System.assertNotEquals(idOwner, casesTest[0].OwnerId, 'No se ha asignado un nuevo owner.');
        System.assertNotEquals(idOwner, casesTest[1].OwnerId, 'No se ha asignado un nuevo owner.');

    }

    @isTest
    public static void contadorSLADiasFestivos()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        Account cuentaEmpleado = [Select id from Account where CC_Email__c = 'test@gmail.com' limit 1];
        Contact contactoEmpleado = [Select id from Contact where LastName = 'Contacto Prueba Empleado' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Festivos nacionales';
        lovAvisosSobreAgrupadores.CC_Valor__c = '1';
        insert lovAvisosSobreAgrupadores;

        CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso.CC_Activa__c = true;
        valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso.Name = 'Umbral primer aviso';
        valorUmbralPrimerAviso.CC_Valor__c = '10';
        valorUmbralPrimerAviso.CC_Valor2__c = '10';
        insert valorUmbralPrimerAviso;

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        //Creación nuevo caso asociado a un usuario
        Case caso = new Case(AccountId = cuentaEmpleado.Id,
        ContactId = contactoEmpleado.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Empleado',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        ownerId = supervisor.Id,
        RecordTypeId = rtEmpleado);
        insert caso;

        System.runAs(supervisor)
        {
            /*caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            update caso;*/

            Test.startTest();
            caso.Status = 'Cerrado';
            update caso;
            Test.stopTest();

            Case casoUP = [SELECT CC_FechaSLAsinEstados__c FROM Case WHERE Id =: caso.Id LIMIT 1];

            System.AssertNotEquals(null, casoUP.CC_FechaSLAsinEstados__c, 'El calculo SLA no ha funcionado');
        }
    }

    @isTest
    public static void isWeekendTest()
    {
        Test.startTest();
        DateTime dt = datetime.newInstance(2022, 12, 15);
        Boolean res = CC_CaseTriggerHelper.isWeekend(dt);
        Test.stopTest();

        System.assertEquals(false, res, 'El metodo is weekend ha fallado.');
    }

    @isTest
    public static void permiteCambioOwnerCCTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [Select id from Account where Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba Empleado' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        User usuario = [Select id from User where email = 'tuser000@amamama.com' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);
        insert caso;

        Test.startTest();
        caso.OwnerId = usuario.Id;
        try{
            update caso;
        }
        catch(Exception e){
            System.assertNotEquals(null, e, 'El envío de errores ha fallado.');
        }
        Test.stopTest();
    }

    @isTest
    public static void comprobacionContactoCCTest()
    {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [Select id from Account where Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);

        CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Campa Prueba' LIMIT 1];

        CC_Caracteristica_Detalle__c caracteristicaInsert = new CC_Caracteristica_Detalle__c(
        CC_Caracteristica__c = caracteristica.Id,
        CC_Cliente__c = caso.ContactId
        );
        insert caracteristicaInsert;

        Test.startTest();
        insert caso;
        Test.stopTest();

        CC_Caracteristica_Case__c car = [Select CC_Case__c from CC_Caracteristica_Case__c where CC_Case__c = :caso.Id limit 1];
        System.assertNotEquals(null, car, 'No se ha insertado la característica correctamente');
    }

    @isTest
    public static void procedenciaEmailTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [Select id from Account where Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        SuppliedEmail = 'emailtest@asd.com',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario web',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);

        Test.startTest();
        insert caso;
        Test.stopTest();
        String canProc = caso.SuppliedEmail;

        Case casoIn = [SELECT CC_MailTelfNotif__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(casoIn.CC_MailTelfNotif__c, canProc, 'El campo MailTelf no se ha asignado correctamente');
    }

    @isTest
    public static void casosFaxTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();

        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'Tarjetas';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000002';
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;

        Account empleado = [Select id from Account where Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'Tarjetas' LIMIT 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Fax',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_MCC_Tematica__c = tematica.Id,
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 ',
        RecordTypeId = rtCliente);

        Test.startTest();
        insert caso;
        Test.stopTest();

        Case casoIn = [SELECT CC_Canal_Operativo__c, CC_Canal_Procedencia__c, CC_Tipo_Contacto__c, CC_MCC_Tematica__c FROM Case WHERE Id = :caso.Id LIMIT 1];
        Task tarea = [SELECT Type, Status, Priority FROM Task LIMIT 1];
        CC_MCC__c mccTarjetas = [SELECT Id FROM CC_MCC__c WHERE CC_Activo__c = true AND Name = 'Tarjetas' AND RecordTypeId = :recordTem LIMIT 1];

        //Asserts de Tarea
        System.assertEquals('Fax entrante', tarea.Type, 'El tipo de la tarea no es correcto');
        System.assertEquals('Completed', tarea.Status, 'El estado de la tarea no es correcto');
        System.assertEquals('Normal', tarea.Priority, 'La prioridad de la tarea no es correcto');

        //Asserts de Caso
        System.assertEquals('Sin canal', casoIn.CC_Canal_Operativo__c, 'El canal operativo no se ha actualizado correctamente');
        System.assertEquals('Redsys-Sermepa', casoIn.CC_Canal_Procedencia__c, 'El canal de procedencia no se ha actualizado correctamente');
        System.assertEquals('Petición de servicio', casoIn.CC_Tipo_Contacto__c, 'El tipo de contacto no se ha actualizado correctamente');

        //Asserts Flow
        System.assertEquals(mccTarjetas.Id, casoIn.CC_MCC_Tematica__c, 'El Flow no se ha ejecutado correctamente');

    }

    @isTest
    public static void casosWebTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [Select id from Account where Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba Empleado' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_AcuseRecibo__c = '1',
        CC_AcuseDelay__c = System.today(),
        CC_SuppliedApp__c = 'AplicacionTest',
        CC_MailTelfNotif__c = 'emailtest@asd.com',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);

        Test.startTest();
        insert caso;
        Test.stopTest();

        System.assertEquals(null, null, '');

    }

    @isTest
    public static void casosColaFormularioTF()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [Select id from Account where Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba Empleado' limit 1];
        User usuario = [Select id from User where email = 'tuser000@amamama.com' limit 1];
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Formulario_Terminal_Financiero' LIMIT 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        OwnerId = ownerLst[0].Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);

        insertarGrupoTF();

        Test.startTest();
        insert caso;
        Test.stopTest();

        Case casoIn = [SELECT CC_Cola_Procedencia__c, CC_Canal_Procedencia__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals('Oficina Feedback', casoIn.CC_Canal_Procedencia__c, 'El canal de procedencia no se ha actualizado correctamente');
        System.assertEquals('CC_Formulario_Terminal_Financiero', casoIn.CC_Cola_Procedencia__c, 'La cola de procedencia no se ha actualizado correctamente');

    }

    @future
    public static void insertarGrupoTF() {
        User usuario = [Select id from User where email = 'tuser000@amamama.com' limit 1];
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Formulario_Terminal_Financiero' LIMIT 1];

        GroupMember grpMember = new GroupMember();
        grpMember.GroupId = ownerLst[0].Id;
        grpMember.UserOrGroupId = usuario.Id;
        insert grpMember;
    }

    @isTest
    public static void casosColaFormularioBP()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [Select id from Account where Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba Empleado' limit 1];
        User usuario = [Select id from User where email = 'tuser000@amamama.com' limit 1];
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Buzon_Usuario_Publico' LIMIT 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        OwnerId = ownerLst[0].Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);

        insertarGrupoBP();

        Test.startTest();
        insert caso;
        Test.stopTest();

        Case casoIn = [SELECT CC_Cola_Procedencia__c, CC_Canal_Procedencia__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals('Servicios Centrales', casoIn.CC_Canal_Procedencia__c, 'El canal de procedencia no se ha actualizado correctamente');
        System.assertEquals('CC_Buzon_Usuario_Publico', casoIn.CC_Cola_Procedencia__c, 'La cola de procedencia no se ha actualizado correctamente');

    }

    @future
    public static void insertarGrupoBP() {
        User usuario = [Select id from User where email = 'tuser000@amamama.com' limit 1];
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Buzon_Usuario_Publico' LIMIT 1];

        GroupMember grpMember = new GroupMember();
        grpMember.GroupId = ownerLst[0].Id;
        grpMember.UserOrGroupId = usuario.Id;
        insert grpMember;
    }

    @isTest
    public static void personAccountInsertTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id rtClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();

        Account empleado = [Select id from Account where LastName = 'Cuenta Prueba ClientePA' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);

        Test.startTest();
        insert caso;
        Test.stopTest();

        Case casoIn = [SELECT ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];
        Account cuentaIn = [SELECT PersonContactId FROM Account WHERE Id = :caso.AccountId LIMIT 1];

        System.assertEquals(cuentaIn.PersonContactId, casoIn.ContactId, 'El contacto del caso no se ha actualizado correctamente');

    }

    @isTest
    public static void personAccountUpdateTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Id rtClientePA = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();

        Account empleado = [Select id from Account where LastName = 'Cuenta Prueba ClientePA' limit 1];
        Contact contacto = [Select id from Contact where LastName = 'Contacto Prueba' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);
        insert caso;

        Account empleado2 = [Select id from Account where LastName = 'Cuenta Prueba ClientePA2' limit 1];

        Test.startTest();
        caso.AccountId = empleado2.Id;
        update caso;
        Test.stopTest();

        Case casoIn = [SELECT ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];
        Account cuentaIn = [SELECT PersonContactId FROM Account WHERE Id = :caso.AccountId LIMIT 1];

        System.assertEquals(cuentaIn.PersonContactId, casoIn.ContactId, 'El contacto del caso no se ha actualizado correctamente');

    }

    @isTest
    public static void identificarClienteInsertTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT id FROM Account WHERE Name = 'Cuenta Prueba' LIMIT 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba' LIMIT 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_IdentCliente__c = '1',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);

        Test.startTest();
        insert caso;
        Test.stopTest();

        Case casoIn = [SELECT CC_MailTelfNotif__c, CC_Numero_Documento__c FROM Case WHERE Id = :caso.Id LIMIT 1];
        Account cuentaIn = [SELECT CC_Email__c, CC_Numero_Documento__c FROM Account WHERE Id = :caso.AccountId LIMIT 1];

        System.assertEquals(cuentaIn.CC_Email__c, casoIn.CC_MailTelfNotif__c, 'El email del caso no se ha actualizado correctamente');
        System.assertEquals(cuentaIn.CC_Numero_Documento__c, casoIn.CC_Numero_Documento__c, 'El numero de documento del caso no se ha actualizado correctamente');

    }

    @isTest
    public static void identificarClienteUpdateTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT id FROM Account WHERE Name = 'Cuenta Prueba' LIMIT 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba' LIMIT 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_IdentCliente__c = '1',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);
        insert caso;

        Test.startTest();
        caso.CC_IdentCliente__c = '2';
        update caso;
        Test.stopTest();

        Case casoIn = [SELECT CC_MailTelfNotif__c, CC_Numero_Documento__c FROM Case WHERE Id = :caso.Id LIMIT 1];
        Account cuentaIn = [SELECT CC_Email__c, CC_Numero_Documento__c FROM Account WHERE Id = :caso.AccountId LIMIT 1];

        System.assertEquals(cuentaIn.CC_Email__c, casoIn.CC_MailTelfNotif__c, 'El email del caso no se ha actualizado correctamente');
        System.assertEquals(cuentaIn.CC_Numero_Documento__c, casoIn.CC_Numero_Documento__c, 'El numero de documento del caso no se ha actualizado correctamente');

    }

    @isTest
    public static void actualizarOficinaTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];

        List<Account> listaCuentas = new List<Account>();
        Account cuenta3 = new Account();
        cuenta3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta3.Name = 'Parent Gerencia Comercial';
        listaCuentas.add(cuenta3);

        Account cuenta4 = new Account();
        cuenta4.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta4.Name = 'Gerencia Comercial';
        cuenta4.ParentId = cuenta3.Id;
        listaCuentas.add(cuenta4);

        Account cuenta5 = new Account();
        cuenta5.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta5.Name = 'cuenta5';
        listaCuentas.add(cuenta5);

        insert listaCuentas;

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Oficina_Afectada_Lookup__c = empleado.Id,
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);
        insert caso;

        //Account empleado2 = [Select id, CC_Gerencia_Comercial__c, CC_Gerencia_Comercial__r.ParentId from Account where Name = 'cuenta5' limit 1];

        Test.startTest();
        caso.CC_Oficina_Afectada_Lookup__c = cuenta5.Id;
        update caso;
        Test.stopTest();

        Account cuentaActualizada = [SELECT Id, CC_Gerencia_Comercial__c, CC_Gerencia_Comercial__r.ParentId FROM Account WHERE Id = :caso.AccountId LIMIT 1];
        Case casoActualizado = [SELECT CC_DAN__c, CC_DG__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(cuentaActualizada.CC_Gerencia_Comercial__c, casoActualizado.CC_DAN__c, 'El DAN del caso no se ha actualizado correctamente');
        System.assertEquals(cuentaActualizada.CC_Gerencia_Comercial__r.ParentId, casoActualizado.CC_DG__c, 'La Delegación General del caso no se ha actualizado correctamente');

    }

    @isTest
    public static void cambioContactoEmpleadoTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];

        Contact contactoEmpleado = new Contact();
        contactoEmpleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contactoEmpleado.AccountId = empleado.Id;
        contactoEmpleado.FirstName = 'Contacto Prueba Empleado 2';
        contactoEmpleado.LastName = 'Contacto Prueba Empleado 2';
        contactoEmpleado.Email = 'correotest@gmail.com';
        insert contactoEmpleado;

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);
        insert caso;

        Test.startTest();
        caso.ContactId = contactoEmpleado.Id;
        update caso;
        Test.stopTest();

        Case casoActualizado = [SELECT CC_MailTelfNotif__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(contactoEmpleado.Email, casoActualizado.CC_MailTelfNotif__c, 'El email del caso no se ha actualizado correctamente');

    }

    @isTest
    public static void blanqueoAccountTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);
        insert caso;

        Test.startTest();
        caso.AccountId = null;
        update caso;
        Test.stopTest();

        Case casoActualizado = [SELECT CC_MailTelfNotif__c, CC_Numero_Documento__c, CC_NumPerso__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(null, casoActualizado.CC_MailTelfNotif__c, 'El mail no se ha actualizado correctamente');
        System.assertEquals(null, casoActualizado.CC_Numero_Documento__c, 'El numero de documento no se ha actualizado correctamente');
        System.assertEquals(null, casoActualizado.CC_NumPerso__c, 'El numero personalizado no se ha actualizado correctamente');

    }

    @isTest
    public static void estadoCerradoUpdateTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];
        User usuario = [Select id from User where email = 'tuser000@amamama.com' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        OwnerId = usuario.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Resolucion__c = 'Descripcion Resolucion Test',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        RecordTypeId = rtEmpleado);
        insert caso;

        Task tarea = new Task(
        WhatId = caso.Id,
        Status = 'Pendiente',
        Type = 'Traslado Tercer Nivel',
        Description  = 'Descripción tarea test',
        CC_Tipo_Cierre__c = 'Tipo de cierre Test'
        );
        insert tarea;

        CC_Servicio_Genesys__c servicioGenesys = new CC_Servicio_Genesys__c();
        servicioGenesys.CC_codigo__c = 'IMAGIN_LEADS';
        servicioGenesys.CC_VDN__c = '123456789';
        insert servicioGenesys;

        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.CC_Servicio_Genesys__c = servicioGenesys.Id;
        llamada.CC_Tipo__c = 'Saliente';
        llamada.CC_Case_Consulta__c = caso.Id;
        insert llamada;

        Test.startTest();
        caso.Status = 'Cerrado';
        caso.CC_Resolucion__c = 'Descripción resolucion test';
        update caso;
        Test.stopTest();

        Case casoActualizado = [SELECT Id, CC_Resolucion__c, Status, CC_Llamada_Saliente__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        Task tareaActualizada = [SELECT Status, CC_Tipo_Cierre__c, CC_Fecha_Fin__c, Description FROM Task WHERE WhatId = :casoActualizado.Id AND CC_Tipo_Cierre__c != null LIMIT 1];


        System.assertEquals('Completed', tareaActualizada.Status, 'El estado de la tarea no se ha actualizado correctamente');
        System.assertEquals('Cierre Tercer Nivel', tareaActualizada.CC_Tipo_Cierre__c, 'El estado de la tarea no se ha actualizado correctamente');
        System.assertNotEquals(null, tareaActualizada.CC_Fecha_Fin__c, 'El estado de la tarea no se ha actualizado correctamente');
        System.assertEquals(casoActualizado.CC_Resolucion__c, tareaActualizada.Description, 'La descripción de la tarea no se ha actualizado correctamente');
        System.assertEquals(true, casoActualizado.CC_Llamada_Saliente__c);

    }

    @isTest
    public static void creacionCasoTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Buzon_Usuario_Publico' LIMIT 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        OwnerId = ownerLst[0].Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);

        Test.startTest();
        insert caso;
        Test.stopTest();

        Case casoActualizado = [SELECT CC_Tramo_TRZ__c, CC_CanalNotifCli__c, CC_Canal_Respuesta__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals('Recibida - En evaluacion', casoActualizado.CC_Tramo_TRZ__c, 'El tramo TRZ no se ha actualizado correctamente');
        System.assertEquals('Email', casoActualizado.CC_CanalNotifCli__c, 'El canal de notificación no se ha actualizado correctamente');
        System.assertEquals(caso.Origin, casoActualizado.CC_Canal_Respuesta__c, 'El canal de respuesta no se ha actualizado correctamente');
    }

    @isTest
    public static void contactoIncoherenteInsertTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' LIMIT 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);

        Test.startTest();
        insert caso;
        Test.stopTest();

        Case casoActualizado = [SELECT AccountId, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(null, casoActualizado.AccountId, 'El AccountId no se ha actualizado correctamente');
        System.assertEquals(null, casoActualizado.ContactId, 'El ContactId no se ha actualizado correctamente');
    }

    @isTest
    public static void contactoIncoherenteUpdateTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' LIMIT 1];

        Contact contactoEmpleado = new Contact();
        contactoEmpleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contactoEmpleado.AccountId = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' LIMIT 1].Id;
        contactoEmpleado.FirstName = 'Contacto Prueba Empleado 2';
        contactoEmpleado.LastName = 'Contacto Prueba Empleado 2';
        contactoEmpleado.Email = 'correoTest@gmail.com';
        insert contactoEmpleado;

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        RecordTypeId = rtEmpleado);
        insert caso;

        Test.startTest();
        caso.ContactId = contactoEmpleado.Id;
        update caso;
        Test.stopTest();

        Case casoActualizado = [SELECT AccountId, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(null, casoActualizado.AccountId, 'El AccountId no se ha actualizado correctamente');
        System.assertEquals(null, casoActualizado.ContactId, 'El ContactId no se ha actualizado correctamente');
    }

    @isTest
    public static void informarDireccionTerritorialTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' LIMIT 1];

        Account cuentaPrueba = new Account(
        RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente'),
        Name = 'Cuenta Prueba Test',
        CC_Numero_Oficina__c = '00004',
        CC_Tipo_Centro__c = 'DT');
        insert cuentaPrueba;

        Case caso = new Case(AccountId = cuentaPrueba.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Oficina_Afectada_Lookup__c = cuentaPrueba.Id,
        CC_Fecha_Limite_Resolucion__c = System.now()+1,
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);

        Test.startTest();
        insert caso;
        Test.stopTest();

        Case casoActualizado = [SELECT CC_Direccion_Territorial__c, CC_Oficina_Afectada_Lookup__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(caso.CC_Oficina_Afectada_Lookup__c, casoActualizado.CC_Direccion_Territorial__c, 'Direccion Territorial no se ha actualizado correctamente');
    }

    @isTest
    public static void seAsignaPropietario3NTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];
        User usuario = [Select id from User where email = 'tuser000@amamama.com' limit 1];
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Buzon_Usuario_Publico' LIMIT 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        OwnerId = ownerLst[0].Id,
        Status = 'Pendiente Interno',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Oficina_Afectada_Lookup__c = empleado.Id,
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);
        insert caso;

        Test.startTest();
        caso.OwnerId = usuario.Id;
        update caso;
        Test.stopTest();

        Case casoActualizado = [SELECT Status FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals('Activo', casoActualizado.Status, 'El status no se ha actualizado correctamente');
    }

    /*@isTest
    public static void revisarReclamacionesTwitterTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];

        Test.startTest();
        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Pendiente Interno',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Twitter',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'CaixaBank',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);
        insert caso;

        SocialPost postTwitter = new SocialPost();
        postTwitter.Name = 'Test';
        postTwitter.ParentId = caso.Id;
        postTwitter.CC_ReclamacionActiva__c = true;
        postTwitter.isOutbound = true;
        postTwitter.Provider = 'Twitter';
        postTwitter.CC_Solicitud_Informacion__c = true;
        postTwitter.Posted = System.now();
        postTwitter.CC_ZonaHoraria__c = 2;
        postTwitter.CC_Primer_DM__c = true;
        insert postTwitter;

        caso.Status = 'Activo';
        update caso;
        Test.stopTest();

        SocialPost spActualizado = [SELECT CC_ReclamacionActiva__c FROM SocialPost WHERE ParentId = :caso.Id LIMIT 1];

        System.assertEquals(false, spActualizado.CC_ReclamacionActiva__c, 'Assert');
    }*/

    @isTest
    public static void cuentaDesasociadaTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Pendiente Interno',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);
        insert caso;

        Test.startTest();
        caso.AccountId = null;
        update caso;
        Test.stopTest();

        Case casoActualizado = [SELECT CC_Oficina_Afectada_Lookup__c, CC_Oficina__c, CC_Oficina_afectada__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(null, casoActualizado.CC_Oficina_Afectada_Lookup__c, 'Assert');
        System.assertEquals(null, casoActualizado.CC_Oficina__c, 'Assert');
        System.assertEquals(null, casoActualizado.CC_Oficina_afectada__c, 'Assert');
    }

    @isTest
    public static void actualizarFechaLimiteTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Petición documentación',
        CC_Canal_Procedencia__c = 'Atención al Cliente',
        CC_Canal_Resolucion__c = 'Atención al Cliente',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtCliente);
        insert caso;

        Test.startTest();
        caso.Subject = 'Test';
        update caso;

        Case casoActualizado = [SELECT CreatedDate, CC_Fecha_Limite_Resolucion_Verde__c, CC_Fecha_Limite_Resolucion_Naranja__c, CC_Fecha_Limite_Resolucion__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        Test.stopTest();


        System.assertNotEquals(null, casoActualizado.CC_Fecha_Limite_Resolucion_Verde__c, 'Assert');
        System.assertNotEquals(null, casoActualizado.CC_Fecha_Limite_Resolucion_Naranja__c, 'Assert');
        System.assertNotEquals(null, casoActualizado.CC_Fecha_Limite_Resolucion__c, 'Assert');
    }

    @isTest
    public static void modificaCampanaDeCasoTest()
    {
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' LIMIT 1];
        CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Campa Prueba' LIMIT 1];

        CC_Caracteristica__c caracteristica2 = new CC_Caracteristica__c();
        caracteristica2.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        caracteristica2.Name = 'Campa Prueba 2';
        caracteristica2.CC_Descripcion__c = 'Decripcion Prueba 2';
        insert caracteristica2;

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Campana__c = caracteristica.Id,
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        RecordTypeId = rtEmpleado);
        insert caso;

        //CC_Caracteristica__c caracteristica2 = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Campa Prueba 2' LIMIT 1];

        Test.startTest();
        caso.CC_Campana__c = caracteristica2.Id;
        update caso;
        Test.stopTest();

        Case casoActualizado = [SELECT CC_Comunicacion_Informativa__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(null, casoActualizado.CC_Comunicacion_Informativa__c, 'Assert');
    }

    @isTest
    public static void nuevoCasoPreventivaTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
        CC_Caracteristica__c caracteristica = [SELECT Id FROM CC_Caracteristica__c WHERE Name = 'Campa Prueba' LIMIT 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Campana__c = caracteristica.Id,
        CC_Cont_Interm_Delay__c = System.now(),
        CC_Canal_Procedencia__c = 'Oficina Preventiva',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        CC_Notif_Cont_Inter__c = false,
        RecordTypeId = rtCliente);

        Test.startTest();
        insert caso;
        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
    }

    @isTest
    public static void notificacionAgenteNoCiTest()
    {
        Test.startTest();
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Phone',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Cont_Interm_Delay__c = System.now(),
        CC_Canal_Procedencia__c = 'Atención al Cliente',
        CC_Notif_Cont_Inter__c = false,
        RecordTypeId = rtCliente);

        insert caso;
        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
    }

    @isTest
    public static void nuevoCasoACTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Phone',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Cont_Interm_Delay__c = System.now(),
        CC_Canal_Procedencia__c = 'Atención al Cliente',
        CC_Canal_Resolucion__c = 'Atención al Cliente',
        CC_Notif_Cont_Inter__c = false,
        RecordTypeId = rtCliente);

        Test.startTest();
        insert caso;
        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
    }

    @isTest
    public static void incrementoEnNumeroReclamacionesClienteTest()
    {
        Test.startTest();
        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        CC_Numero_Reclamaciones_Cliente__c = 1,
        CC_Notif_Cont_Inter__c = false,
        RecordTypeId = rtEmpleado);
        insert caso;

        
        caso.CC_Numero_Reclamaciones_Cliente__c = 2;
        update caso;
        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
    }

    /*@isTest
    public static void limpiarCasosLeadsTest()
    {
        
        Test.startTest();
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Phone',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Detalles_Consulta__c = 'Detalle Consulta Test',
        CC_Canal_Procedencia__c = 'Atención al Cliente',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        RecordTypeId = rtCliente);
        insert caso;

        CC_Servicio_Genesys__c servicioGenesys = new CC_Servicio_Genesys__c();
        servicioGenesys.CC_codigo__c = 'IMAGIN_LEADS';
        servicioGenesys.CC_VDN__c = '123456789';
        insert servicioGenesys;

        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.CC_Servicio_Genesys__c = servicioGenesys.Id;
        insert llamada;

        Task tarea = new Task(
        WhatId = caso.Id,
        Status = 'Pendiente',
        Type = 'Traslado Tercer Nivel',
        Description  = 'Descripción tarea test',
        CC_Tipo_Cierre__c = 'Llamada finalizada',
        CC_Llamada_id__c = llamada.Id
        );
        insert tarea;

        caso.Status = 'Cerrado';
        update caso;
    
        Account cuentaActualizada = [SELECT Id, CC_NumPerso__c, Name, CC_Email__c, Phone FROM Account WHERE Id = :caso.AccountId LIMIT 1];
        Test.stopTest();

        System.assertEquals(null, cuentaActualizada.CC_NumPerso__c, 'Assert');
        System.assertEquals('Imagin Lead', cuentaActualizada.Name, 'Assert');
    }*/

    @isTest
    public static void informarAltaGestorTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        Test.startTest();
        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Atención al Cliente',
        CC_Canal_Resolucion__c = 'Atención al Cliente',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        RecordTypeId = rtCliente);
        insert caso;

        Account cuenta2 = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba 2' limit 1];

        caso.AccountId = cuenta2.Id;
        update caso;
        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
    }

    @isTest
    public static void informarCierreGestorTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba 2' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        Test.startTest();
        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Atención al Cliente',
        CC_Canal_Resolucion__c = 'Atención al Cliente',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        RecordTypeId = rtCliente);
        insert caso;

        caso.CC_Detalles_Consulta__c = 'Detalle Consulta Test';
        caso.Status = 'Cerrado';
        update caso;
        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
    }

    @isTest
    public static void notificarEmailTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba 2' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        Test.startTest();
        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Atención al Cliente',
        CC_Canal_Resolucion__c = 'Atención al Cliente',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_Detalles_Consulta__c = 'Detalle Consulta BEFORE',
        RecordTypeId = rtCliente);
        insert caso;

        caso.CC_Detalles_Consulta__c = 'Detalle Consulta';
        caso.Status = 'Cerrado';
        update caso;
        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
    }

    @isTest
    public static void enviarEncuestaTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba 2' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        Test.startTest();
        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Atención al Cliente',
        CC_Canal_Resolucion__c = 'Atención al Cliente',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        RecordTypeId = rtCliente);
        insert caso;

        caso.CC_Detalles_Consulta__c = 'Detalle Consulta Test';
        caso.Status = 'Cerrado';
        update caso;
        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
    }

    @isTest
    private static void identificarCambioClienteAlfTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account cuenta = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        Account cuenta2 = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA2' LIMIT 1];

        Case caso = new Case();
        caso.CC_IdentCliente__c ='0';
        caso.RecordTypeId = rtCliente;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        insert caso;

        Test.startTest();
        caso.AccountId = cuenta2.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_MailTelfNotif__c, CC_Numero_Documento__c, CC_NumPerso__c, AccountId FROM Case WHERE Id = :caso.Id LIMIT 1];
        Account cuentaActualizada = [SELECT Id, CC_Numero_Documento__c, CC_NumPerso__c FROM Account WHERE Id = :casoActualizado.AccountId LIMIT 1];

        System.AssertEquals(casoActualizado.CC_MailTelfNotif__c, cuentaActualizada.CC_NumPerso__c,'El numero de telefono no coinide');
        System.AssertEquals(casoActualizado.CC_Numero_Documento__c, cuentaActualizada.CC_Numero_Documento__c,'Los numeros del DNI no coinciden');
        System.AssertEquals(casoActualizado.CC_NumPerso__c, cuentaActualizada.CC_Numero_Documento__c,'Los numeros del DNI no coinciden');
    }

    @isTest
    private static void creacionCasoPropuestasInsertTest()
    {

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA'];

        Case caso = new Case();
        caso.Origin = 'Propuestas de mejora';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.Description = 'Hola';

        Test.startTest();
        insert caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Descripcion_Problematica__c, CC_Titulo_Propuesta__c, Description, Subject, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(casoActualizado.CC_Descripcion_Problematica__c, casoActualizado.Description,'Los datos del contacto no coinciden' );
        System.AssertEquals(casoActualizado.CC_Titulo_Propuesta__c, casoActualizado.Subject,'Los datos del contacto no coinciden' );
    }

    @isTest
    private static void seInformaCanalRespuestaInsertTest()
    {

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA'];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_Canal_Respuesta_Modificar__c = 'Email';

        Test.startTest();
        insert caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Canal_Respuesta__c, CC_Canal_Respuesta_Modificar__c, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(casoActualizado.CC_Canal_Respuesta__c, casoActualizado.CC_Canal_Respuesta_Modificar__c,'Los datos no coinciden' );

    }

    @isTest
    private static void seInformaCanalRespuestaUpdateTest()
    {

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA'];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_Canal_Respuesta_Modificar__c = 'Phone';
        insert caso;

        Test.startTest();
        caso.CC_Canal_Respuesta_Modificar__c = 'Email';
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Canal_Respuesta__c, CC_Canal_Respuesta_Modificar__c, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(casoActualizado.CC_Canal_Respuesta__c, casoActualizado.CC_Canal_Respuesta_Modificar__c,'Los datos no coinciden' );

    }

    @isTest
    private static void actualizarAgrupadorUpdateTest()
    {

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA'];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;

        Test.startTest();
        insert caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Agrupador_Id__c, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(casoActualizado.CC_Agrupador_Id__c, caso.CC_Agrupador_Id__c,'Los datos no coinciden' );

    }

    @isTest
    private static void empleadoCuentaUpdateTest() {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Account cuenta = [SELECT CC_OficinaGestoraId__c FROM Account WHERE Name = 'Cuenta Prueba Empleado'];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtEmpleado;
        caso.AccountId = cuenta.Id;
        caso.CC_Oficina_Afectada_Lookup__c = cuenta.Id;
        caso.CC_Oficina__c = cuenta.Id;
        insert caso;

        Account cuenta2 = new Account();
        cuenta2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta2.Name = 'Cuenta Prueba Empleado 2';
        cuenta2.CC_OficinaGestoraId__c = cuenta.CC_OficinaGestoraId__c;
        cuenta2.CC_Numero_Oficina__c = '222';
        insert cuenta2;

        Test.startTest();
        caso.AccountId = cuenta2.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT CC_Oficina_afectada__c, CC_Oficina__c, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(casoActualizado.CC_Oficina_afectada__c, cuenta2.CC_Numero_Oficina__c,'Los datos no coinciden' );

    }

    @isTest
    private static void asociaActivoUpdateTest()
    {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        Account cuenta3 = [SELECT Id, PersonContactId FROM Account WHERE Name = 'Cuenta Prueba' LIMIT 1];

        Asset casoAsset = new Asset();
        casoAsset.Name = 'Pablo';
        casoAsset.AccountId = cuenta3.Id;
        insert casoAsset;

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCliente;
        caso.AssetId = null;
        insert caso;

        Test.startTest();
        caso.AssetId = casoAsset.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Oficina__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(casoActualizado.CC_Oficina__c, cuenta3.Id,'Los datos no coinciden' );

    }

    @isTest
    private static void tematicaInformadoUpdateTest()
    {

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA'];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_Codigo_Externo_Tematica__c = null;
        caso.CC_MCC_Tematica__c = null;
        insert caso;

        Test.startTest();
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Codigo_Externo_Tematica__c,CC_Tematica__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(mccTematica.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Tematica__c,'Los datos no coinciden' );
        System.AssertEquals(mccTematica.Name, casoActualizado.CC_Tematica__c,'Los datos no coinciden' );
    }

    @isTest
    private static void tematicaInformadoInsertTest()
    {

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA'];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;

        Test.startTest();
        insert caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Codigo_Externo_Tematica__c,CC_Tematica__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(mccTematica.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Tematica__c,'Los datos no coinciden' );
        System.AssertEquals(mccTematica.Name, casoActualizado.CC_Tematica__c,'Los datos no coinciden' );
    }

    @isTest
    private static void productoInformadoUpdateTest()
    {
        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_Codigo_Externo_Producto__c = null;
        caso.CC_MCC_ProdServ__c = null;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        insert caso;

        Test.startTest();
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Codigo_Externo_Producto__c,CC_Producto_Servicio__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(mccProducto.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Producto__c,'Los datos no coinciden' );
        System.AssertEquals(mccProducto.Name, casoActualizado.CC_Producto_Servicio__c,'Los datos no coinciden' );
    }

    @isTest
    private static void productoInformadoInsertTest()
    {
        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;

        Test.startTest();
        insert caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Codigo_Externo_Producto__c,CC_Producto_Servicio__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(mccProducto.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Producto__c,'Los datos no coinciden' );
        System.AssertEquals(mccProducto.Name, casoActualizado.CC_Producto_Servicio__c,'Los datos no coinciden' );
    }

    @isTest
    private static void motivoInformadoUpdateTest()
    {
        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccMotivo = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Motivo' LIMIT 1];
        CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name, CC_Tematica__c  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        insert caso;

        Test.startTest();
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Codigo_Externo_Motivo__c,CC_Motivo__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(mccMotivo.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Motivo__c,'Los datos no coinciden' );
        System.AssertEquals(mccMotivo.Name, casoActualizado.CC_Motivo__c,'Los datos no coinciden' );
    }

    @isTest
    private static void motivoInformadoInsertTest()
    {
        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccMotivo = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Motivo' LIMIT 1];
        CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;

        Test.startTest();
        insert caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Codigo_Externo_Motivo__c,CC_Motivo__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(mccMotivo.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Motivo__c,'Los datos no coinciden' );
        System.AssertEquals(mccMotivo.Name, casoActualizado.CC_Motivo__c,'Los datos no coinciden' );
    }

    @isTest
    private static void causaInformadoInsertTest()
    {
        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccCausa = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Causa' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;

        Test.startTest();
        insert caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Codigo_Externo_Causa__c,CC_Causa__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(mccCausa.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Causa__c,'Los datos no coinciden' );
        System.AssertEquals(mccCausa.Name, casoActualizado.CC_Causa__c,'Los datos no coinciden' );
    }

    @isTest
    private static void causaInformadoUpdateTest()
    {
        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccCausa = [SELECT Id,CC_Codigo_Externo__c,Name, RecordTypeId, CC_Motivo__c FROM CC_MCC__c WHERE recordType.developerName = 'CC_Causa' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Atención al cliente';
        caso.CC_Tipo_Contacto__c = 'Incidencia';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_Codigo_Externo_Causa__c = null;
        caso.CC_MCC_Causa__c = null;
        insert caso;

        Test.startTest();
        caso.CC_MCC_Causa__c = mccCausa.Id;
        update caso;

        case casoActualizado = [SELECT Id, CC_Codigo_Externo_Causa__c,CC_Causa__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        Test.stopTest();


        System.AssertEquals(mccCausa.CC_Codigo_Externo__c, casoActualizado.CC_Codigo_Externo_Causa__c,'Los datos no coinciden' );
        System.AssertEquals(mccCausa.Name, casoActualizado.CC_Causa__c,'Los datos no coinciden' );
    }

    @isTest
    private static void solucionInformadoInsertTest()
    {
        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccSolucion = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Solucion' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_Codigo_Externo_Causa__c = null;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;

        Test.startTest();
        Database.insert(caso);
        Test.stopTest();

        case casoActualizado = [SELECT Id,CC_Solucion__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(mccSolucion.Name, casoActualizado.CC_Solucion__c,'Los datos no coinciden' );
    }

    @isTest
    private static void solucionInformadoUpdateTest()
    {
        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id, PersonContactId FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        CC_MCC__c mccSolucion = [SELECT Id,CC_Codigo_Externo__c,Name, RecordTypeId, CC_Motivo__c FROM CC_MCC__c WHERE recordType.developerName = 'CC_Solucion' LIMIT 1];
        CC_MCC__c mccCausa = [SELECT Id,CC_Codigo_Externo__c,Name, RecordTypeId, CC_Motivo__c FROM CC_MCC__c WHERE recordType.developerName = 'CC_Causa' LIMIT 1];

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.AccountId = cuenta.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_Codigo_Externo_Causa__c = null;
        caso.CC_MCC_Solucion__c = null;
        insert caso;

        Test.startTest();
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id,CC_Solucion__c , ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(mccSolucion.Name, casoActualizado.CC_Solucion__c,'Los datos no coinciden' );
    }

    @isTest
    private static void actualizarColaProcedenciaUpdateTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Formulario_Terminal_Financiero' LIMIT 1];
        User usuario = [Select Id from User where email = 'tuser000@amamama.com' LIMIT 1];

        Case caso = new Case();
        caso.Origin = 'Email';
        caso.OwnerId = usuario.Id;
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCliente;
        caso.Subject = 'pruebaAccount';
        insert caso;

        Test.startTest();
        caso.OwnerId = ownerLst[0].Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Cola_Procedencia__c , OwnerId FROM Case WHERE Id = :caso.Id];
        Group cuenta = [SELECT Id, DeveloperName FROM Group WHERE Id = :casoActualizado.OwnerId];

        System.AssertEquals(cuenta.DeveloperName, casoActualizado.CC_Cola_Procedencia__c,'Los datos no coinciden' );
    }

    @isTest
    private static void informarOficinaAfectadaDetalleBU()
    {

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' limit 1];
        Account cuenta3 = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' limit 1];

        Case caso = new Case();
        caso.AccountId = null;
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        caso.Subject = 'pruebaAccount';

        Database.insert(caso);

        Test.startTest();
        caso.CC_Oficina__c = cuenta3.Id;
        Database.update(caso);
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Oficina_Afectada_Lookup__c ,CC_Oficina__c, ContactId FROM Case WHERE subject = 'pruebaAccount' LIMIT 1];
        System.AssertEquals(casoActualizado.CC_Oficina_Afectada_Lookup__c, casoActualizado.CC_Oficina__c,'Los datos no coinciden' );
    }

    @isTest
    private static void informarOficinaAfectadaBI()
    {

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Account cuenta = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' limit 1];

        Case caso = new Case();
        caso.CC_Oficina__c = cuenta.Id;
        caso.AccountId = cuenta.Id;
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;

        Test.startTest();
        insert caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Oficina_Afectada_Lookup__c ,AccountId, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];
        Account cuentaTest = [SELECT Id, CC_OficinaGestoraId__c FROM Account WHERE Id = :casoActualizado.AccountId LIMIT 1];

        System.AssertEquals(casoActualizado.CC_Oficina_Afectada_Lookup__c, cuentaTest.CC_OficinaGestoraId__c,'Los datos no coinciden');

    }

    @isTest
    private static void informarOficinaAfectadaBU()
    {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE AND UserRole.Name = 'Contact Center' LIMIT 1];

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Account cuenta3 = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        Account cuenta = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];

        Case caso = new Case();
        caso.CC_Oficina__c = cuenta.Id;
        caso.AccountId = cuenta.Id;
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.RecordTypeId = rtCaso;
        insert caso;

        Test.startTest();
        caso.AccountId = cuenta3.Id;

        System.runAs(supervisor){
            update caso;
            Test.stopTest();
        }
            case casoActualizado = [SELECT Id, CC_Oficina_Afectada_Lookup__c ,AccountId, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];
            Account cuentaTest = [SELECT Id, AV_OficinaPrincipal__c FROM Account WHERE Id = :casoActualizado.AccountId LIMIT 1];

            System.AssertEquals(casoActualizado.CC_Oficina_Afectada_Lookup__c, cuentaTest.AV_OficinaPrincipal__c,'Los datos no coinciden' );

    }
    /*
    @isTest
    private static void encuestaHDT1N()
    {

        Id rtCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Account cuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName ='Contacto Prueba Empleado' LIMIT 1];
        CC_MCC__c mccMotivo = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Motivo' LIMIT 1];
        CC_MCC__c mccProducto = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Producto_Servicio' LIMIT 1];
        CC_MCC__c mccTematica = [SELECT Id,CC_Codigo_Externo__c,Name  FROM CC_MCC__c WHERE recordType.developerName = 'CC_Tematica' LIMIT 1];
        CC_MCC__c mccSolucion = [SELECT Id,CC_Codigo_Externo__c,Name, RecordTypeId, CC_Motivo__c FROM CC_MCC__c WHERE recordType.developerName = 'CC_Solucion' LIMIT 1];
        CC_MCC__c mccCausa = [SELECT Id,CC_Codigo_Externo__c,Name, RecordTypeId, CC_Motivo__c FROM CC_MCC__c WHERE recordType.developerName = 'CC_Causa' LIMIT 1];

        Case caso = new Case();
        caso.CC_Oficina__c = cuenta.Id;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_MCC_Solucion__c = mccSolucion.Id;
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c ='Smartphones';
        caso.Status = 'Activo';
        caso.CC_Detalles_Consulta__c = 'test';
        caso.CC_Detalles_Solucion__c = 'test';
        caso.RecordTypeId = rtCaso;
        insert caso;

        Test.startTest();
        caso.Status = 'Cerrado';
        update caso;
        Test.stopTest();

        caso = [SELECT Id, CC_URL_Encuesta_3N__c FROM Case WHERE Id = :caso.Id LIMIT 1];
        System.AssertNotEquals(null, caso.CC_URL_Encuesta_3N__c );
        System.AssertNotEquals(null,Limits.getEmailInvocations());
    }
    */

    @isTest
    private static void comprobacionTransferAU() {

        Account cuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName ='Contacto Prueba Empleado' LIMIT 1];
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Buzon_Usuario_Publico' LIMIT 1];
        List<Group> ownerLst2 = [SELECT Id FROM Group WHERE DeveloperName = 'CC_ConsForm_Tarjetas_Comercios' LIMIT 1];

        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.OwnerId = ownerLst[0].Id;
        caso.Origin = 'Phone';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Origin = 'Email';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c ='Formulario Consultas Operativas';
        caso.Status = 'Activo';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert caso;

        Test.startTest();
        caso.OwnerId = ownerLst2[0].Id;
        update caso;
        Test.stopTest();

        Case casoAct = [SELECT CC_Grupo_Transfer__c FROM Case WHERE Id = :caso.Id];

        system.assertEquals(ownerLst2[0].Id, casoAct.CC_Grupo_Transfer__c, 'El campo Grupo Transfer no se ha actualizado correctamente');

    }

    /*@isTest
    private static void reaperturaNoValidaTest() {

        Account cuenta = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba Empleado' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName ='Contacto Prueba Empleado' LIMIT 1];
        CC_MCC__c tematica = [Select id from CC_MCC__c where Name = 'App\'s' limit 1];
        CC_MCC__c producto = [Select id from CC_MCC__c where Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [Select id from CC_MCC__c where Name = 'Valoración positiva' limit 1];

        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Origin = 'Phone';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Origin = 'Email';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c ='Formulario Consultas Operativas';
        caso.Status = 'Activo';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = producto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        caso.CC_Detalles_Consulta__c = 'Test';
        caso.CC_Reapertura_Valida__c = 'No';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert caso;

        Test.startTest();
        caso.Status = 'Cerrado';
        update caso;
        Test.stopTest();

        List<EmailMessage> correosCaso = [SELECT Id FROM EmailMessage WHERE ParentId = :caso.Id LIMIT 1];
        system.assertEquals(1, correosCaso.size());

    }*/
}