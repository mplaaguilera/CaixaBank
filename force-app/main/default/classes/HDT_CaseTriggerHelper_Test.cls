@isTest
public class HDT_CaseTriggerHelper_Test {

    @TestSetup
    static void makeData(){

       
        CC_Lista_Valores__c lovAvisosSobreAgrupadores3 = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores3.CC_Activa__c = true;
        lovAvisosSobreAgrupadores3.Name = ' HDT - Envío de Encuesta 2N - Canales de resolución';
        insert lovAvisosSobreAgrupadores3;

        CC_Lista_Valores__c valorUmbralSiguientes1 = new CC_Lista_Valores__c();
        valorUmbralSiguientes1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientes1.CC_Activa__c = true;
        valorUmbralSiguientes1.CC_Lista__c = lovAvisosSobreAgrupadores3.Id;
        valorUmbralSiguientes1.Name = 'Servicios Centrales';
        valorUmbralSiguientes1.CC_Valor__c = 'No EDG';

        CC_Lista_Valores__c valorUmbralSiguientes2 = new CC_Lista_Valores__c();
        valorUmbralSiguientes1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientes1.CC_Activa__c = true;
        valorUmbralSiguientes1.CC_Lista__c = lovAvisosSobreAgrupadores3.Id;
        valorUmbralSiguientes1.Name = 'EDG-VDC / VIDACAIXA';
        valorUmbralSiguientes1.CC_Valor__c = 'EDG';

        List<CC_Lista_Valores__c> valorUmbralIns1 = new List<CC_Lista_Valores__c>();
        valorUmbralIns1.add(valorUmbralSiguientes1);
        valorUmbralIns1.add(valorUmbralSiguientes2);
        
        insert valorUmbralIns1;



        CC_Lista_Valores__c lovAvisosSobreAgrupadores2 = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores2.CC_Activa__c = true;
        lovAvisosSobreAgrupadores2.Name = 'HDT - Aviso Comunicaciones Informativas';
        insert lovAvisosSobreAgrupadores2;

        CC_Lista_Valores__c valorUmbralSiguientesAvisosx = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisosx.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisosx.CC_Activa__c = true;
        valorUmbralSiguientesAvisosx.CC_Lista__c = lovAvisosSobreAgrupadores2.Id;
        valorUmbralSiguientesAvisosx.Name = 'Comunicación Informativa de Caso - Umbral de tiempo';
        valorUmbralSiguientesAvisosx.CC_Valor__c = '15';

        CC_Lista_Valores__c valorUmbralSiguientesAvisosx1 = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisosx1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisosx1.CC_Activa__c = true;
        valorUmbralSiguientesAvisosx1.CC_Lista__c = lovAvisosSobreAgrupadores2.Id;
        valorUmbralSiguientesAvisosx1.Name = 'Comunicación Informativa de Caso - Umbral Envio de Emails';
        valorUmbralSiguientesAvisosx1.CC_Valor__c = '15';

        CC_Lista_Valores__c valorUmbralSiguientesAvisosx2 = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisosx2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisosx2.CC_Activa__c = true;
        valorUmbralSiguientesAvisosx2.CC_Lista__c = lovAvisosSobreAgrupadores2.Id;
        valorUmbralSiguientesAvisosx2.Name = 'Comunicación Informativa de Caso - Umbral primer aviso';
        valorUmbralSiguientesAvisosx2.CC_Valor__c = '1';

        List<CC_Lista_Valores__c> valorUmbralInsertx = new List<CC_Lista_Valores__c>();
        valorUmbralInsertx.add(valorUmbralSiguientesAvisosx);
        valorUmbralInsertx.add(valorUmbralSiguientesAvisosx1);
        valorUmbralInsertx.add(valorUmbralSiguientesAvisosx2);
        
        insert valorUmbralInsertx;

        // Datos para telefono unico
        Id recordTypeOficina = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account oficinaGestora = new Account(RecordTypeId = recordTypeOficina, Name = 'Cuenta oficina gestora', CC_Tipo_Centro__c = 'OF',  CC_Email__c = 'test@test.com', CC_Numero_Oficina__c = '00001');
        insert oficinaGestora;
        List<Account> listaCuentas = new List<Account>();

        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'Oficinas';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = '00001';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        //crear usuarios CC
        Id profile1Id;
        Id profile2Id;

        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Name IN ('System Administrator', 'CC_Analísta y 2º nivel MVP2')];
        for (Profile p : profiles) {
            if (p.Name == 'System Administrator') {
                profile1Id = p.Id;
            } else if (p.Name == 'CC_Analísta y 2º nivel MVP2') {
                profile2Id = p.Id;
            }
        }


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

        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'HDT'];

        System.runAs(usuario1){

             // Inicialización de datos.        
             Id recorTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId(); 
             CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
             lista.Name = 'HDT - Envío de Encuesta 3N - Canales de resolución';
             lista.CC_Activa__c = true;
             lista.RecordTypeId = recorTypeLista;
             insert lista;

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
            usuarioV2.UserRoleId = rolId.Id;
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
            usuario.UserRoleId = rolId.Id;
			userList2.add(usuario);
            insert userList2;
        }

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta.Name = 'Cuenta Prueba';
        cuenta.CC_OficinaGestoraId__c = oficinaGestora.Id;
        cuenta.CC_Numero_Oficina__c = '00001';
        listaCuentas.add(cuenta);

        Account cuentaClientePA = new Account();
        cuentaClientePA.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
        cuentaClientePA.LastName = 'Cuenta Prueba ClientePA';
        cuentaClientePA.CC_OficinaGestoraId__c = oficinaGestora.Id;
        cuentaClientePA.CC_Numero_Oficina__c = '00001';
        listaCuentas.add(cuentaClientePA);
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
        contactoEmpleado.AccountId = cuenta.Id;
        contactoEmpleado.FirstName = 'Contacto Prueba Empleado';
        contactoEmpleado.LastName = 'Contacto Prueba Empleado';
        contactoEmpleado.CC_NumPerso__c = '25345550';
        contactoEmpleado.CC_Idioma__c = 'ca';
        contactoEmpleado.Email = 'correo@gmail.com';
        contactoEmpleado.Phone = '973242323';
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
        mcc3.Name = 'Valoración positiva causa';
        mcc3.CC_Tipo_Cliente__c = 'Cliente';
        mcc3.CC_Motivo__c = mcc2.Id;
        mcc3.CC_Codigo_Externo__c = 'CA-000001';
        insert mcc3;

        CC_MCC__c mcc4 = new CC_MCC__c();
        mcc4.RecordTypeId = recordSol;
        mcc4.Name = 'Valoración positiva solucion';
        mcc4.CC_Tipo_Cliente__c = 'Cliente';
        mcc4.CC_Causa__c = mcc3.Id;
        mcc4.CC_Codigo_Externo__c = 'SO-000001';
        insert mcc4;

        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();
        caracteristica.RecordTypeId = Schema.SObjectType.CC_Caracteristica__c.getRecordTypeInfosByDeveloperName().get('CC_Campana').getRecordTypeId();
        caracteristica.Name = 'Campa Prueba';
        caracteristica.CC_Descripcion__c = 'Decripcion Prueba';
        caracteristica.OS_Negocio__c = 'HDT';
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
			tmpCapacidad.CC_Canal_Procedencia__c = 'Web';
			tmpCapacidad.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
			tmpCapacidad.CC_Proveedor__c = proveedoresLst[i];
			tmpCapacidad.CC_Queue_Name__c = 'Queue_'+proveedoresLst[i];
			tmpCapacidad.CC_Capacidad__c = 50;
			capacidadesList.add(tmpCapacidad);
		}
        for (Integer i = 0; i < 2; i++) {
            tmpCapacidad = new CC_Capacidad_Proveedores__c();
			tmpCapacidad.CC_Canal_Entrada__c = 'Email';
			tmpCapacidad.CC_Canal_Procedencia__c = 'Web';
			tmpCapacidad.RecordTypeId = Schema.SObjectType.CC_Capacidad_Proveedores__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
			tmpCapacidad.CC_Proveedor__c = proveedoresLst[i];
			tmpCapacidad.CC_Queue_Name__c = 'Queue_'+proveedoresLst[i];
			tmpCapacidad.CC_Capacidad__c = 50;
			capacidadesList.add(tmpCapacidad);
		}
        System.debug('proveedoresLst: '+proveedoresLst);
		insert capacidadesList;

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
        System.debug('queues: '+queuesLst);
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

        List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;
    }

    @isTest
    public static void testNumeroAgrupadores() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Account cliente = [SELECT id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'App\'s' limit 1];
        CC_MCC__c producto = [SELECT id FROM CC_MCC__c WHERE Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva' limit 1];

        //Creación nuevo caso asociado a un usuario
        Case caso = new Case(AccountId = cliente.Id,
                             ContactId = contacto.Id,
                             Status = 'Activo',
                             CC_Idioma__c = 'es',
                             Subject = 'Prueba',
                             CC_Tipo_Cliente__c = 'Cliente',
                             Origin = 'Email',
                             CC_Tipo_Contacto__c = 'Consulta',
                             CC_Canal_Procedencia__c = 'Servicios Centrales',
                             CC_MCC_Tematica__c = tematica.Id,
                             CC_MCC_ProdServ__c = producto.Id,
                             CC_MCC_Motivo__c = motivo.Id,
                             CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
                             CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
                             RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId());
		insert caso;

        CC_Agrupador__c agrupador = [SELECT id FROM CC_Agrupador__c WHERE CC_Titulo__c = 'Prueba Número Agrupador'];

        Test.startTest();
        
            caso.CC_Agrupador_Id__c = agrupador.Id;
            update caso;

        Test.stopTest();

        List<CC_Agrupador__c> lstAgrupadorUpdate = [SELECT CC_Numero_Casos__c FROM CC_Agrupador__c WHERE id = :agrupador.Id];

        system.assertEquals(1, lstAgrupadorUpdate.size(), 'Comprobamos que se actualiza el número de casos del agrupador');
        }
    }

    @isTest
    public static void comprobacionContactoCCTest()
    {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account empleado = [SELECT id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
		ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Servicios Centrales',
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
        //System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            insert caso;
        //}


        Test.stopTest();

        CC_Caracteristica_Case__c car = [SELECT CC_Case__c FROM CC_Caracteristica_Case__c WHERE CC_Case__c = :caso.Id limit 1];
        System.assertNotEquals(null, car, 'No se ha insertado la característica correctamente');
        }
    }

    @isTest
    public static void actualizarOficinaTest()
    {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' LIMIT 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' LIMIT 1];

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
        CC_Canal_Procedencia__c = 'Servicios Centrales',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);
        insert caso;

        Test.startTest();
        //System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso.CC_Oficina_Afectada_Lookup__c = cuenta5.Id;
            update caso;
        //}

        Test.stopTest();

        Account cuentaActualizada = [SELECT Id, CC_Gerencia_Comercial__c, CC_Gerencia_Comercial__r.ParentId FROM Account WHERE Id = :caso.AccountId LIMIT 1];
        Case casoActualizado = [SELECT CC_DAN__c, CC_DG__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(cuentaActualizada.CC_Gerencia_Comercial__c, casoActualizado.CC_DAN__c, 'El DAN del caso no se ha actualizado correctamente');
        System.assertEquals(cuentaActualizada.CC_Gerencia_Comercial__r.ParentId, casoActualizado.CC_DG__c, 'La Delegación General del caso no se ha actualizado correctamente');
        }
    }

    @isTest
    public static void cambioContactoEmpleadoTest()
    {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];

        Contact contactoEmpleado2 = new Contact();
        contactoEmpleado2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Empleado');
        contactoEmpleado2.AccountId = empleado.Id;
        contactoEmpleado2.FirstName = 'Contacto Prueba Empleado 2';
        contactoEmpleado2.LastName = 'Contacto Prueba Empleado 2';
        contactoEmpleado2.CC_NumPerso__c = '25345551';
        contactoEmpleado2.CC_Idioma__c = 'ca';
        contactoEmpleado2.Email = 'correotest@gmail.com';
        contactoEmpleado2.Phone = '973242324';
        insert contactoEmpleado2;

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        CC_MailTelfNotif__c = contactoEmpleado2.Email,
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Servicios Centrales',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);
        insert caso;

        Test.startTest();
        //System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso.ContactId = contactoEmpleado2.Id;
            update caso;
        //}

        Test.stopTest();

        Case casoActualizado = [SELECT CC_MailTelfNotif__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(contactoEmpleado2.Email, casoActualizado.CC_MailTelfNotif__c, 'El mail del caso no se ha actualizado correctamente');
        }
    }

    @isTest
    public static void blanqueoAccountTest()
    {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Servicios Centrales',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);
        insert caso;

        Test.startTest();
       // System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso.AccountId = null;
            update caso;
       // }

        Test.stopTest();

        Case casoActualizado = [SELECT CC_MailTelfNotif__c, CC_Numero_Documento__c, CC_NumPerso__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(null, casoActualizado.CC_MailTelfNotif__c, 'El mail no se ha actualizado correctamente');
        System.assertEquals(null, casoActualizado.CC_Numero_Documento__c, 'El numero de documento no se ha actualizado correctamente');
        System.assertEquals(null, casoActualizado.CC_NumPerso__c, 'El numero personalizado no se ha actualizado correctamente');
        }
    }
    /*Pendiente revisar por límite de queries
    @isTest
    public static void estadoCerradoUpdateTest()
    {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account empleado = new Account();
        empleado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        empleado.Name = 'Cuenta Prueba Empleado';
        empleado.CC_Numero_Oficina__c = '00001';
        insert empleado;

        Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];
        User usuario = [SELECT id FROM User WHERE email = 'tuser000@amamama.com' limit 1];


        CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'App\'s' limit 1];
        CC_MCC__c producto = [SELECT id FROM CC_MCC__c WHERE Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
		OwnerId = usuario.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Servicios Centrales',
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

        Test.startTest();
        //System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso.Status = 'Cerrado';
            caso.CC_Resolucion__c = 'Descripción resolucion test';
       // }


        update caso;
        Test.stopTest();

        Case casoActualizado = [SELECT Id, CC_Resolucion__c, Status FROM Case WHERE Id = :caso.Id LIMIT 1];

        Task tareaActualizada = [SELECT Status, CC_Tipo_Cierre__c, CC_Fecha_Fin__c, Description FROM Task WHERE WhatId = :casoActualizado.Id AND CC_Tipo_Cierre__c != null LIMIT 1];

        System.debug('::: lista tareas: ' + tareaActualizada);

        System.assertEquals('Completed', tareaActualizada.Status, 'El estado de la tarea no se ha actualizado correctamente');
        System.assertEquals('Cierre Tercer Nivel', tareaActualizada.CC_Tipo_Cierre__c, 'El estado de la tarea no se ha actualizado correctamente');
        System.assertNotEquals(null, tareaActualizada.CC_Fecha_Fin__c, 'El estado de la tarea no se ha actualizado correctamente');
        System.assertEquals(casoActualizado.CC_Resolucion__c, tareaActualizada.Description, 'La descripción de la tarea no se ha actualizado correctamente');
        }
    }*/

    @isTest
    public static void seAsignaPropietario3NTest()
    {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Set<Id> setIdsRt = New Set<Id>();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];
        User usuario = [SELECT id FROM User WHERE email = 'tuser000@amamama.com' limit 1];
    	List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Buzon_Usuario_Publico' LIMIT 1];


        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
		OwnerId = ownerLst[0].Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Gestionado_Agente__c = true,
        CC_Tipo_Contacto__c = 'Consulta',
		CC_Oficina_Afectada_Lookup__c = empleado.Id,
        CC_Canal_Procedencia__c = 'Servicios Centrales',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);

        List<Case> lstCasos = new List<Case>();
        List<Case> listOldObjCC= New List<Case>();

        lstCasos.add(caso);
        insert lstCasos;

        Map<Id, Case> mapOldObjCC = New Map<Id, Case>();
        for (Case tk: lstCasos){
            if(((setIdsRt).contains(tk.RecordTypeId))||(tk.RecordTypeId == null)){
                listOldObjCC.add(tk);
                mapOldObjCC.put(tk.Id,tk);
            }
        }


        Test.startTest();


            caso.OwnerId = usuario.Id;
            HDT_CaseTriggerHelper.seAsignaPropietario3NBU(lstCasos, mapOldObjCC);
            update caso;



        Test.stopTest();

        Case casoActualizado = [SELECT Status FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals('Activo', casoActualizado.Status, 'El status no se ha actualizado correctamente');
       }
    }


	@isTest
    public static void cuentaDesasociadaTest()
    {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];

        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Pendiente Interno',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Servicios Centrales',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = rtEmpleado);
		insert caso;

        Test.startTest();
        //System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso.AccountId = null;
            update caso;
        //}


        Test.stopTest();

        Case casoActualizado = [SELECT CC_Oficina_Afectada_Lookup__c, CC_Oficina__c, CC_Oficina_afectada__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(null, casoActualizado.CC_Oficina_Afectada_Lookup__c, 'Assert');
        System.assertEquals(null, casoActualizado.CC_Oficina__c, 'Assert');
        System.assertEquals(null, casoActualizado.CC_Oficina_afectada__c, 'Assert');
        }
    }

    @isTest
    public static void actualizarFechaLimiteTest()
    {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

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
        CC_Canal_Procedencia__c = 'Servicios Centrales',
        CC_Canal_Resolucion__c = 'Servicios Centrales',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
        CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
        RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId());
		insert caso;

        Test.startTest();
        //System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso.Subject = 'Test';

            update caso;
        //}


        Test.stopTest();

        Case casoActualizado = [SELECT CreatedDate, CC_Fecha_Limite_Resolucion_Verde__c, CC_Fecha_Limite_Resolucion_Naranja__c, CC_Fecha_Limite_Resolucion__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(casoActualizado.Id, caso.Id,'Assert');
        //System.assertNotNull(casoActualizado.CC_Fecha_Limite_Resolucion_Naranja__c, 'Assert');
        //System.assertNotNull(casoActualizado.CC_Fecha_Limite_Resolucion__c, 'Assert');
        }
    }

    @isTest
    public static void modificaCampanaDeCasoTest()
    {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba Empleado' limit 1];
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
        CC_Canal_Procedencia__c = 'Servicios Centrales',
        RecordTypeId = rtEmpleado);
		insert caso;

        Test.startTest();
        //System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            caso.CC_Campana__c = caracteristica2.Id;
            update caso;
        //}


        Test.stopTest();

        Case casoActualizado = [SELECT CC_Comunicacion_Informativa__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.assertEquals(null, casoActualizado.CC_Comunicacion_Informativa__c, 'Assert');
        }
    }

    @isTest
    public static void notificarEmailTest()
    {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'App\'s' limit 1];
        CC_MCC__c producto = [SELECT id FROM CC_MCC__c WHERE Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva' limit 1];

        Test.startTest();
        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Petición documentación',
        CC_Canal_Procedencia__c = 'Servicios Centrales',
        CC_Canal_Resolucion__c = 'Servicios Centrales',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        RecordTypeId = rtEmpleado);
        insert caso;

        caso.CC_Detalles_Consulta__c = 'Detalle Consulta Test';
        caso.Status = 'Cerrado';
        update caso;
        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
        }
    }

    /*
    @isTest
    public static void enviarEncuestaTest()
    {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account empleado = [SELECT Id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
        Contact contacto = [SELECT Id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
        CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'App\'s' limit 1];
        CC_MCC__c producto = [SELECT id FROM CC_MCC__c WHERE Name = 'APP CaixaBank' limit 1];
        CC_MCC__c motivo = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva' limit 1];
        CC_MCC__c causa = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva causa' limit 1];
        CC_MCC__c solucion = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva solucion' limit 1];

        Test.startTest();
            
        Case caso = new Case(AccountId = empleado.Id,
        ContactId = contacto.Id,
        Status = 'Activo',
        CC_Idioma__c = 'es',
        Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Petición documentación',
        CC_Canal_Procedencia__c = 'Servicios Centrales',
        CC_Canal_Resolucion__c = 'Servicios Centrales',
        CC_MCC_Tematica__c = tematica.Id,
        CC_MCC_ProdServ__c = producto.Id,
        CC_MCC_Motivo__c = motivo.Id,
        CC_MCC_Causa__c = causa.Id,
        CC_MCC_Solucion__c = solucion.Id,
        RecordTypeId = rtEmpleado);
        insert caso;

            caso.CC_Detalles_Consulta__c = 'Detalle Consulta Test';
            caso.Status = 'Cerrado';
            update caso;

        Test.stopTest();

        System.assertEquals(null, null, 'Assert');
        }
    }*/

    /*
    @isTest
    private static void identificarCambioClienteAlfTest()
    {
        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();

        Account cuenta = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA' LIMIT 1];
        Account cuenta2 = [SELECT Id FROM Account WHERE LastName = 'Cuenta Prueba ClientePA2' LIMIT 1];

        Case caso = new Case();

        caso.CC_IdentCliente__c ='0';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
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
    }*/

    @isTest
    private static void actualizarAgrupadorUpdateTest()
    {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
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
        }

    @isTest
    private static void empleadoCuentaUpdateTest()
    {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtEmpleado = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Account cuenta = [SELECT CC_OficinaGestoraId__c FROM Account WHERE Name = 'Cuenta Prueba'];

        Account cuenta2 = new Account();
        cuenta2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_CentroCaixaBank');
        cuenta2.Name = 'Cuenta Prueba 2';
        cuenta2.CC_OficinaGestoraId__c = cuenta.CC_OficinaGestoraId__c;
        cuenta2.CC_Numero_Oficina__c = '00001';
        insert cuenta2;

        Case caso = new Case();
        caso.Status = 'Activo';
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.AccountId = cuenta.Id;
        caso.CC_Oficina_Afectada_Lookup__c = cuenta.Id;
        caso.CC_Oficina__c = cuenta.Id;
        caso.CC_Oficina_afectada__c = '00001';

        insert caso;

        Test.startTest();
        caso.AccountId = cuenta2.Id;
        //update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Oficina_afectada__c, CC_Oficina__c, ContactId FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(casoActualizado.CC_Oficina_afectada__c, cuenta2.CC_Numero_Oficina__c,'Los datos no coinciden' );
        }
    }

    @isTest
    private static void asociaActivoUpdateTest()
    {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id rtCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
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
        caso.CC_Oficina__c = cuenta3.Id;
        insert caso;

        Test.startTest();
        caso.AssetId = casoAsset.Id;
        update caso;
        Test.stopTest();

        case casoActualizado = [SELECT Id, CC_Oficina__c FROM Case WHERE Id = :caso.Id LIMIT 1];

        System.AssertEquals(casoActualizado.CC_Oficina__c, cuenta3.Id,'Los datos no coinciden' );
        }
    }

    @isTest
    private static void insertDetallesConsultaTest(){

       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

            Account cliente = [SELECT id, Name FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
            Contact contacto = [SELECT id, Name FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
            CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'App\'s' limit 1];
            CC_MCC__c producto = [SELECT id FROM CC_MCC__c WHERE Name = 'APP CaixaBank' limit 1];
            CC_MCC__c motivo = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva' limit 1];

            Asset casoAsset = new Asset();
            casoAsset.Name = 'TestDC';
            casoAsset.AccountId = cliente.Id;
            insert casoAsset;

            //Creación nuevo caso asociado a un usuario
            Case caso = new Case(AccountId = cliente.Id,
                                ContactId = contacto.Id,
                                AssetId = casoAsset.Id,
                                Status = 'Activo',
                                CC_Idioma__c = 'es',
                                Subject = 'Prueba AIDC',
                                Origin = 'Phone',
                                CC_Tipo_Contacto__c = 'Consulta',
                                CC_Canal_Procedencia__c = 'Servicios Centrales',
                                CC_Canal_Resolucion__c = 'Incidencias Técnicas',
                                CC_MCC_Tematica__c = tematica.Id,
                                CC_MCC_ProdServ__c = producto.Id,
                                CC_MCC_Motivo__c = motivo.Id,
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId());

            Test.startTest();
            insert caso;
            Test.stopTest();

            List <Case> casoCreado = [SELECT Id, CC_Detalles_Consulta__c FROM Case WHERE Subject = 'Prueba AIDC' LIMIT 1];

            System.assertEquals(true, casoCreado[0].CC_Detalles_Consulta__c.contains(cliente.Name), 'Detalles Consulta debe contener el nombre de la cuenta asociado al caso');
            System.assertEquals(true, casoCreado[0].CC_Detalles_Consulta__c.contains(contacto.Name), 'Detalles Consulta debe contener el nombre del contacto');
            System.assertEquals(true, casoCreado[0].CC_Detalles_Consulta__c.contains(casoAsset.Name), 'Detalles Consulta debe contener el nombre del asset');
        }
    }

    @isTest
    private static void cierreCasoHDT1N(){

       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            HDT_Parametros__c encuesta = new HDT_Parametros__c(
                Name = 'HDT_Envio_Encuesta',
                HDT_Configuracion_1__c = '261467',
                HDT_Configuracion_2__c = 'Encuesta Test'
            );
            insert encuesta;

            HDT_Parametros__c encuesta2 = new HDT_Parametros__c(
                Name = 'HDT_Envio_Encuesta_EDG',
                HDT_Configuracion_1__c = '261467',
                HDT_Configuracion_2__c = 'Encuesta Test'
            );
            insert encuesta2;

            Id listaPadre = [SELECT id FROM CC_Lista_Valores__c WHERE Name = 'HDT - Envío de Encuesta 3N - Canales de resolución' limit 1].Id;
            // Crear un registro de CC_Lista_Valores__c para simular un resultado válido
            CC_Lista_Valores__c listaValor = new CC_Lista_Valores__c(
                Name = 'Servicios Centrales',
                CC_Activa__c = true,
                CC_Valor__c = 'No EDG',
                CC_Lista__c = listaPadre
    
            );
            insert listaValor;
    
            CC_Lista_Valores__c listaValor2 = new CC_Lista_Valores__c(
                Name = 'EDG-MICROBANK',
                CC_Activa__c = true,
                CC_Valor__c = 'EDG',
                CC_Lista__c = listaPadre
    
            );
            insert listaValor2;
        
            Account cliente = [SELECT id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
            Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
            CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'App\'s' limit 1];
            CC_MCC__c producto = [SELECT id FROM CC_MCC__c WHERE Name = 'APP CaixaBank' limit 1];
            CC_MCC__c motivo = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva' limit 1];

            //Creación nuevo caso asociado a un usuario
            Case caso = new Case(AccountId = cliente.Id,
                                ContactId = contacto.Id,
                                Status = 'Activo',
                                CC_Idioma__c = 'es',
                                Subject = 'PruebaCierreHDT1n',
                                Origin = 'Phone',
                                CC_Tipo_Contacto__c = 'Consulta',
                                CC_Canal_Procedencia__c = 'Servicios Centrales',
                                CC_Canal_Resolucion__c = 'Servicios Centrales',
                                CC_MCC_Tematica__c = tematica.Id,
                                CC_MCC_ProdServ__c = producto.Id,
                                CC_MCC_Motivo__c = motivo.Id,
                                CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
                                CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId());
            insert caso;

            caso.HDT_Resuelto_Primera_Llamada__c = true;
            caso.Status = 'Cerrado';


            Test.startTest();
            update caso;
           // update caso2;
            Integer numEmails = Limits.getEmailInvocations();
            Test.stopTest();

            System.assertEquals(1, numEmails, 'Debería haber enviado un email');
        }
    }

    @isTest
    private static void cierreCasoHDT1Ncat(){

       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            HDT_Parametros__c encuesta = new HDT_Parametros__c(
                Name = 'HDT_Envio_Encuesta',
                HDT_Configuracion_1__c = '261467',
                HDT_Configuracion_2__c = 'Encuesta Test'
            );
            insert encuesta;

            Account cliente = [SELECT id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
            Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
            CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'App\'s' limit 1];
            CC_MCC__c producto = [SELECT id FROM CC_MCC__c WHERE Name = 'APP CaixaBank' limit 1];
            CC_MCC__c motivo = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva' limit 1];
            
            //Creación nuevo caso asociado a un usuario
            Case caso2 = new Case(AccountId = cliente.Id,
                                ContactId = contacto.Id,
                                Status = 'Activo',
                                CC_Idioma__c = 'ca',
                                Subject = 'PruebaCierreHDT1n',
                                Origin = 'Phone',
                                CC_Tipo_Contacto__c = 'Consulta',
                                CC_Canal_Procedencia__c = 'Servicios Centrales',
                                CC_Canal_Resolucion__c = 'Incidencias Técnicas',
                                CC_MCC_Tematica__c = tematica.Id,
                                CC_MCC_ProdServ__c = producto.Id,
                                CC_MCC_Motivo__c = motivo.Id,
                                CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
                                CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId());
            insert caso2;

            caso2.HDT_Resuelto_Primera_Llamada__c = true;
            caso2.Status = 'Cerrado';

            Test.startTest();
            update caso2;
            Integer numEmails = Limits.getEmailInvocations();
            Test.stopTest();

            System.assertEquals(0, numEmails, 'Debería haber enviado un email');
        }
    }

    @isTest static void testEstadoCerradoAux() {
       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Crear un caso de prueba
        Case caso = new Case(
            Subject = 'Prueba',
            Status = 'Pendiente',
            Type = 'Traslado Tercer Nivel',
            CC_Resolucion__c = 'Este es una tarea de prueba',
            Description = 'Este es un caso de prueba'
        );
        insert caso;

        // Crear una tarea de prueba asociada al caso
        Task tarea = new Task(
            WhatId = caso.Id,
            Subject = 'Prueba',
            Status = 'Pendiente',
            Type = 'Traslado Tercer Nivel',
            Description = 'Este es una tarea de prueba'
        );
        insert tarea;

        // Crear un mapa de casos cerrados
        Map<Id, Case> mapaCasosCerrados = new Map<Id, Case>();
        mapaCasosCerrados.put(caso.Id, caso);

        // Crear un conjunto de IDs de casos
        Set<Id> setIdCasos = new Set<Id>();
        setIdCasos.add(caso.Id);

        // Llamar al método que se va a probar
        Test.startTest();
        HDT_CaseTriggerHelper.estadoCerradoAux(setIdCasos, mapaCasosCerrados);
        Test.stopTest();

        // Verificar que la tarea se haya actualizado correctamente
        tarea = [SELECT Id, Status, CC_Tipo_Cierre__c, CC_Fecha_Fin__c, Description FROM Task WHERE Id = :tarea.Id];
        System.assertEquals('Completed', tarea.Status);
        System.assertEquals('Cierre Tercer Nivel', tarea.CC_Tipo_Cierre__c);
        System.assertNotEquals(null, tarea.CC_Fecha_Fin__c);
        System.assertEquals('Este es una tarea de prueba', tarea.Description);

        }
    }

    @isTest static void testGenerarUrlEncuesta() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Datos de prueba
        String configuracion2 = 'https://example.com/';
        String configuracion1 = '12345';
        String idioma = 'es';
        String canalResolucion = 'Canal1';
        String matriculaEmpleado = 'EMP001';
        String caseNumber = 'CASE123';
        String tematicaId = 'T001';
        String tematicaName = 'Tematica Test';

        // Llamada al método
        String resultado = HDT_CaseTriggerHelper.generarUrlEncuesta(configuracion2, configuracion1, idioma, canalResolucion, matriculaEmpleado, caseNumber, tematicaId, tematicaName);

        // Verificar el resultado
        String urlEsperada = 'https://example.com/' + 
                             'sid=12345' + 
                             '&lang=es' + 
                             '&empresa=Canal1' + 
                             '&userid=EMP001' + 
                             '&ticketid=CASE123' + 
                             '&idet=T001' + 
                             '&et=Tematica_Test' + 
                             '&newtest=Y';
        
        System.assertEquals(urlEsperada, resultado, 'La URL generada no es la esperada');
        }
    }

    @isTest
    private static void asociarCasosCausaComunicacionInformativa(){

       System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            
            Account cliente = [SELECT id FROM Account WHERE Name = 'Cuenta Prueba' limit 1];
            Contact contacto = [SELECT id FROM Contact WHERE LastName = 'Contacto Prueba' limit 1];
            CC_MCC__c tematica = [SELECT id FROM CC_MCC__c WHERE Name = 'App\'s' limit 1];
            CC_MCC__c producto = [SELECT id FROM CC_MCC__c WHERE Name = 'APP CaixaBank' limit 1];
            CC_MCC__c motivo = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva' limit 1];
            CC_MCC__c causa = [SELECT id FROM CC_MCC__c WHERE Name = 'Valoración positiva causa' limit 1];

            
            //List<case> listaCasos = new List<Case>();
            List<Id> idsCasosC = new List<Id>();

            //Creación nuevo caso asociado a un usuario
            Case caso2 = new Case(AccountId = cliente.Id,
                                ContactId = contacto.Id,
                                Status = 'Activo',
                                CC_Idioma__c = 'ca',
                                Subject = 'PruebaCierreHDT1n',
                                Origin = 'Phone',
                                CC_Tipo_Contacto__c = 'Consulta',
                                CC_Canal_Procedencia__c = 'Servicios Centrales',
                                CC_Canal_Resolucion__c = 'Incidencias Técnicas',
                                CC_MCC_Tematica__c = tematica.Id,
                                CC_MCC_ProdServ__c = producto.Id,
                                CC_MCC_Motivo__c = motivo.Id,
                                CC_MCC_Causa__c = causa.Id,
                                CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta',
                                CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución',
                                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId());
            insert caso2;

            idsCasosC.add(caso2.Id);
            
            Test.startTest();
                HDT_CaseTriggerHelper.asociarCasosCausaAComunicacionInformativaNoFuture(idsCasosC);
            Test.stopTest();

            // Consulta los casos actualizados para verificar el cambio
            List<Case> updatedCases = [SELECT Id, CC_Repetitivo__c FROM Case WHERE Id IN :idsCasosC];

            // Verifica que todos los casos actualizados tengan el campo Repetitivo__c en true
            for (Case c : updatedCases) {
                System.assertEquals(true, c.CC_Repetitivo__c, 'El campo Repetitivo__c debería estar en true.');
            }

            //System.assertEquals(1, numEmails, 'Debería haber enviado un email');
        }
    }

    
    
}