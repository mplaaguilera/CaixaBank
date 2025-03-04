@isTest
public class CC_EmailSendController_Test {

    @TestSetup
    static void makeData() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet psOperadorEmpleado = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Tercer_Nivel_CBKNow'];
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> insertPSAss = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> insertPSAssAdmin = new List<PermissionSetAssignment>();
        User usuario1 = new User();
        usuario1.ProfileId = profileId;
        usuario1.FirstName = 'Usuario Prueba';
        usuario1.LastName = 'last1';
        usuario1.Email = 'tuser000@amamama.com';
        usuario1.EmployeeNumber = 'U0199999';
        usuario1.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        userList.add(usuario1);

		User usuario2 = new User();
        usuario2.ProfileId = profileId;
        usuario2.FirstName = 'Usuario Prueba 2';
        usuario2.LastName = 'last1';
        usuario2.Email = 'tuser000@amamamaaaa.com';
        usuario2.Username = 'tuser000@amamamaaaa.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'MST';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        userList.add(usuario2);

        User usuario3 = new User();
        usuario3.ProfileId = profileId;
        usuario3.LastName = 'Sin Gestor/EAP';
        usuario3.FirstName = '';
        usuario3.AV_ExternalID__c = '000000';
        usuario3.Email = 'tuser000@amamamaaaaa.com';
        usuario3.Username = 'tuser000@amamamaaaaa.com' + System.currentTimeMillis();
        usuario3.CompanyName = 'MST';
        usuario3.Title = 'title';
        usuario3.Alias = 'alias';
        usuario3.TimeZoneSidKey = 'Europe/Paris';
        usuario3.EmailEncodingKey = 'UTF-8';
        usuario3.LanguageLocaleKey = 'es';
        usuario3.LocaleSidKey = 'es_ES';
        userList.add(usuario3);

        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
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
        userList.add(usuarioAdmin);
        insert userList;

        System.runAs(usuarioAdmin) {
            Case caso = new Case(
                Origin = 'Email',
                CC_Canal_Procedencia__c = 'Formulario web',
                Subject = 'Comprobar actualizacion'
            );
            insert caso;
            List<CC_Settings__c > listCustomSetting= new List<CC_Settings__c >();
            CC_Settings__c  customSetting = new CC_Settings__c ();
            customSetting.Name = 'CC_HubGestion';
            customSetting.CC_Activa__c = true;
            listCustomSetting.add(customSetting);

            CC_Settings__c  customSetting2 = new CC_Settings__c ();
            customSetting2.Name = 'CC_HubSales';
            customSetting2.CC_Activa__c = true;
            listCustomSetting.add(customSetting2);

            CC_Settings__c  customSetting3 = new CC_Settings__c ();
            customSetting3.Name = 'CC_ToastTareaGestor';
            customSetting3.CC_Activa__c = true;
            customSetting3.CC_Configuracion_1__c = 'test';
            customSetting3.CC_Configuracion_2__c = 'test';
            customSetting3.CC_Configuracion_3__c = 'test';
            listCustomSetting.add(customSetting3);

            CC_Settings__c  customSetting4 = new CC_Settings__c ();
            customSetting4.Name = 'CC_OperativaTrasladarRemitir';
            customSetting4.CC_Activa__c = true;
            customSetting4.CC_Configuracion_1__c = 'true';
            listCustomSetting.add(customSetting4);

            CC_Settings__c  customSetting5 = new CC_Settings__c ();
            customSetting5.Name = 'CC_VisibilidadCitaTareaGestor';
            customSetting5.CC_Activa__c = true;
            customSetting5.CC_Configuracion_1__c = 'true';
            customSetting5.CC_Configuracion_2__c = 'true';
            listCustomSetting.add(customSetting5);

            CC_Settings__c  customSetting6 = new CC_Settings__c ();
            customSetting6.Name = 'CC_Agrupador_CIC_Asignacion_Casos';
            customSetting6.CC_Activa__c = true;
            listCustomSetting.add(customSetting6);

            CC_Settings__c  customSetting7 = new CC_Settings__c ();
            customSetting7.Name = 'CC_Agrupador_CI_Asignacion_Casos';
            customSetting7.CC_Activa__c = true;
            listCustomSetting.add(customSetting7);

            CC_Settings__c  customSetting8 = new CC_Settings__c ();
            customSetting8.Name = 'CC_Agrupador_CIM_Asignacion_Casos';
            customSetting8.CC_Activa__c = true;
            listCustomSetting.add(customSetting8);

            insert listCustomSetting;

            Group groupTransfer = new Group(Name='Cons Form Buildingcenter', Type='Queue');
            insert groupTransfer;
            QueuesObject queueTransfer = new QueueSObject(QueueID = groupTransfer.id, SObjectType = 'Case');
            insert queueTransfer;
            User operador = new User();
            operador.profileId = profileId;
            operador.UserRoleId = roleCC;
            operador.FirstName = '';
            operador.LastName = 'Operador Cliente';
            operador.Email = 'tuser000@amamama.com';
            operador.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            operador.CompanyName = 'MST';
            operador.Title = 'title';
            operador.Alias = 'alias';
            operador.TimeZoneSidKey = 'Europe/Paris';
            operador.EmailEncodingKey = 'UTF-8';
            operador.LanguageLocaleKey = 'es';
            operador.LocaleSidKey = 'es_ES';
            insert operador;
            PermissionSetAssignment psaAdmin1 = new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = psOperadorCliente.Id);
			insertPSAssAdmin.add(psaAdmin1);
            User operadorEmpleado = new User();
            operadorEmpleado.profileId = profileId;
            operadorEmpleado.UserRoleId = roleCC;
            operadorEmpleado.FirstName = '';
            operadorEmpleado.AV_ExternalID__c = 'U0124112';
            operadorEmpleado.LastName = 'Operador Empleado';
            operadorEmpleado.Email = 'tuser000@amamama.com';
            operadorEmpleado.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            operadorEmpleado.CompanyName = 'MST';
            operadorEmpleado.Title = 'title';
            operadorEmpleado.Alias = 'alias';
            operadorEmpleado.TimeZoneSidKey = 'Europe/Paris';
            operadorEmpleado.EmailEncodingKey = 'UTF-8';
            operadorEmpleado.LanguageLocaleKey = 'es';
            operadorEmpleado.LocaleSidKey = 'es_ES';
            insert operadorEmpleado;
            PermissionSetAssignment psaAdmin2 = new PermissionSetAssignment(AssigneeId = operadorEmpleado.Id, PermissionSetId = psOperadorEmpleado.Id);
            insertPSAssAdmin.add(psaAdmin2);

            String recordTypeDeveloperName = 'CC_Comunicacion_Informativa';
            CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
            lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            lovAvisosSobreAgrupadores.CC_Activa__c = true;
            lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
            insert lovAvisosSobreAgrupadores;
            CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
            valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralPrimerAviso.CC_Activa__c = true;
            valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral primer aviso';
            valorUmbralPrimerAviso.CC_Valor__c = '2';
            insert valorUmbralPrimerAviso;
            CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
            valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorUmbralSiguientesAvisos.CC_Activa__c = true;
            valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
            valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', recordTypeDeveloperName) + ' - Umbral siguientes avisos';
            valorUmbralSiguientesAvisos.CC_Valor__c = '50';
            insert valorUmbralSiguientesAvisos;
            Id recordTypeIdGrupo = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(Name = 'Grupo Test 3',CC_External__c = 'GC-00097',RecordTypeId = recordTypeIdGrupo);
            insert grupo;
        }

        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = psOperadorEmpleado.Id);
        insertPSAss.add(psa1);
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = psOperadorCliente.Id);
        insertPSAss.add(psa2);
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = usuarioAdmin.Id, PermissionSetId = ps3.Id);
        insertPSAss.add(psa3);

        Database.insert(insertPSAss);

        EmailTemplate plantilla = new EmailTemplate();
        plantilla.name = 'plantilla1';
        plantilla.FolderId = UserInfo.getUserId();
        plantilla.DeveloperName='plantilla1';
        plantilla.TemplateType = 'Text';
        insert plantilla;
    }

    //Test para el método datosCaso
    @isTest
    public static void obtenerDatosCaso() {
        Test.startTest();
        //Seleccionamos un usuario para poder asignar el caso
        Id usuarioId = [SELECT Id FROM User LIMIT 1].Id;
        //Se crea un caso con todos los datos necesarios informados
        Case nuevoCaso = new Case(
            Origin = 'Email',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            OwnerId = usuarioId,
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert nuevoCaso;
        }

        //Comprobamos que el método obtienen bien los campos
        Case caso = CC_EmailSendController.datosCaso(nuevoCaso.Id);
        Test.stopTest();

        System.assertEquals(nuevoCaso.Id, caso.Id);
        System.assertEquals('Email', caso.Origin);
        System.assertEquals('Activo', caso.Status);
        System.assertEquals('es', caso.CC_Idioma__c);
        System.assertEquals(usuarioId, caso.OwnerId);
        System.assertEquals('Grupo 3N', caso.CC_Grupo_3N__c);
    }

    //Test para el método buscarGruposColaboradores
    @isTest
    public static void obtenerGrupos() {
        Test.startTest();
        //Creamos grupos de colaboradores
        Id grupoColaboradorRecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        List<CC_Grupo_Colaborador__c> groupList = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo1 = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Test 1',
            CC_External__c = 'GC-00001',
            RecordTypeId = grupoColaboradorRecordTypeId,
            OS_Negocio__c = 'CC',
            CC_Tipo__c = 'Traslados y Remitidos'
        );
        groupList.add(grupo1);
        CC_Grupo_Colaborador__c grupo2 = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Test 2',
            CC_External__c = 'GC-00002',
            RecordTypeId = grupoColaboradorRecordTypeId,
            OS_Negocio__c = 'CC',
            CC_Tipo__c = 'Traslados y Remitidos'
        );
        groupList.add(grupo2);
		System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert groupList;
        }

        //Comprobamos que la búsqueda nos devuelve los grupos creados
        List<CC_Grupo_Colaborador__c> resultadoBusqueda = CC_EmailSendController.buscarGruposColaboradores('Grupo', 'CC', true, 'CC_Cliente');
        Test.stopTest();
        System.assertEquals(2, resultadoBusqueda.size());
        resultadoBusqueda.sort();
        List<String> nombresEntrada = new List<String>{grupo1.Name, grupo2.Name};
        List<String> nombresSalida = new List<String>{resultadoBusqueda[0].Name, resultadoBusqueda[1].Name};
        System.assertEquals(nombresEntrada, nombresSalida);
    }
    //Test para el método buscarColaborador
    @isTest
    public static void obenerColaboradores() {
        Test.startTest();
        Id colaboradorRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        //Creamos una cuenta y un grupo asociado a ésta, además creamos y asignamos un contacto a dicho grupo

        //Contacto para añadir a EAP/Gestor del Account
        Contact contactoEmpleadoGestor = new Contact(
            FirstName = 'Contacto',
            LastName = 'Empleado Gestor',
            CC_Idioma__c = 'es',
            Email = 'contactoempleadogestor@test.com'
        );
        insert contactoEmpleadoGestor;

		List<Account> accountList = new List<Account>();
        Account cuenta = new Account(
            Name = 'Cuenta Test',
            CC_Email__c = 'cuenta@test.com',
            AV_EAPGestor__c = contactoEmpleadoGestor.Id,
            CC_Tipo_Centro__c = 'OF'
        );
        accountList.add(cuenta);
        //insert cuenta;

        Account cuenta2 = new Account(
            Name = 'Cuenta2 Test',
            CC_Email__c = 'cuenta2@test.com',
            CC_Tipo_Centro__c = 'OF'
        );
         accountList.add(cuenta2);
        insert accountList;

        Contact contacto = new Contact(
        RecordTypeId = colaboradorRecordTypeId,
        FirstName = 'Contacto',
        LastName = 'Test',
        CC_Idioma__c = 'es',
        AccountId = cuenta2.Id,
        Email = 'contacto@test.com'
        );
        insert contacto;


        Case nuevoCaso = new Case(
            Origin = 'Email',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            CC_Canal_Procedencia__c = 'Atención al Cliente',
            AccountId = cuenta.Id
        );
        insert nuevoCaso;


        Id grupoColaboradorRecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c(
            Name = 'Grupo colaborador Test',
            CC_External__c = 'GC-00003',
            CC_Cuenta__c = cuenta.Id,
            RecordTypeId = grupoColaboradorRecordTypeId
        );
        insert grupoColaborador;


        CC_Grupo_Colaborador_Contact__c colaborador = new CC_Grupo_Colaborador_Contact__c(
            CC_Grupo_Colaborador__c = grupoColaborador.Id,
            CC_Para_CC__c = 'Para',
            CC_Contacto__c = contacto.Id
        );
		System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert colaborador;
        }



        //System.debug(colaborador);

        //Comprobamos que obtenemos el mapa con el mail y el Para/CC del colaborador

        Map<String, String> idMapContactoDevuelto = CC_EmailSendController.buscarColaboradorGestor(grupoColaborador.Id, nuevoCaso.Id);
        Map<String, String> idMapContactoDevueltoSoloColaboradores = CC_EmailSendController.buscarColaborador(grupoColaborador.Id);
        System.assert(idMapContactoDevuelto.containsKey(contacto.Email));
        System.assert(idMapContactoDevueltoSoloColaboradores.containsKey(contacto.Email));
        System.assertEquals('Para', idMapContactoDevuelto.get(contacto.Email));
        System.assertEquals('Para', idMapContactoDevueltoSoloColaboradores.get(contacto.Email));

        //Comprobamos que obtenemos el Email del Empleado Gestor.
        //System.assertNotEquals('', correoEmpleadoGestor[0].CC_Cuenta__r.AV_EAPGestor__r.Email);
        //System.assertNotEquals(null , correoEmpleadoGestor[0].CC_Cuenta__r.AV_EAPGestor__r.Email);

        System.assertEquals(contactoEmpleadoGestor.Email,[SELECT Account.AV_EAPGestor__r.Email FROM Case WHERE Id = :nuevoCaso.Id LIMIT 1].Account.AV_EAPGestor__r.Email);
        System.assertEquals('CC', idMapContactoDevuelto.get(contactoEmpleadoGestor.Email));

        Test.stopTest();

    }

    //Test para el método buscarGrupos3N
    @isTest
    public static void obtenerGrupos3N() {
        //Realizamos la búsqueda con el String 'Grupo', ya que actualmente tenemos dos registros de cmt de Grupos de 3N,
        //quizá se deba modificar entre entornos el String de búsqueda en test ya que no se puede insertar mdt en clases de test
        //Comprobamos que se encuentran grupos de 3N en la entidad

        Test.startTest();
        Id recordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Tercer_Nivel').getRecordTypeId();

        CC_Grupo_Colaborador__c grupo3N = new CC_Grupo_Colaborador__c(
            Name = '3N de CaixaBank Now',
            CC_Queue_Traslado__c = 'CC_3N_CaixaBank_Now',
            RecordTypeId = recordTypeId
        );

        insert grupo3N;
        List<CC_Grupo_Colaborador__c> grupos3N = CC_EmailSendController.buscarGrupos3N('3N de CaixaBank Now');
        Test.stopTest();
        System.assert(grupos3N.size() > 0);
    }
    //Test para el mátodo buscarCorreoContacto
    @isTest
    public static void obtenerCorreoContacto() {
        Test.startTest();
        //Si no existe el caso
        String resultado = CC_EmailSendController.buscarCorreoContacto(null);

        System.assertEquals('', resultado);

        //Creamos el caso inicialmente con los campos de SuppliedEmail y CC_MailTelfNotif__c vacío para cubrir el
        // caso de no tenerlos informados ir a buscarlo al contacto asociado
        Contact contacto = new Contact(
        FirstName = 'Contacto',
        LastName = 'Test',
        CC_Idioma__c = 'es',
        Email = 'contacto@test.com'
        );
        insert contacto;

        Case caso = new Case(
            ContactId = contacto.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        insert caso;

        //Comprobamos que el mail obtenido es el de contacto
        resultado = CC_EmailSendController.buscarCorreoContacto(caso.Id);
        System.assertEquals(contacto.Email, resultado);

        //Informamos el campo CC_MailTelfNotif__c para ver que ahora se obtiene ese mail al no encontar informado SuppliedEmail
        caso.CC_MailTelfNotif__c = 'mailtelf@test.com';
        update caso;

        resultado = CC_EmailSendController.buscarCorreoContacto(caso.Id);
        System.assertEquals(caso.CC_MailTelfNotif__c, resultado);

        //Por último comprobamos que se obtenga SuppliedEmail si éste está informado
        caso.SuppliedEmail = 'supplied@test.com';
        update caso;
        resultado = CC_EmailSendController.buscarCorreoContacto(caso.Id);
        System.assertEquals(caso.SuppliedEmail, resultado);
        Test.stopTest();
    }
    //Test para el método cambiarPropietario
    @isTest
    public static void cambiarPropietario() {
        Test.startTest();
        //Obtenemos una cola para realizar el test (nos es indiferente cuál)
        Group cola = [SELECT Id,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_3N_CaixaBank_Now' LIMIT 1];
        Id grupoId = [SELECT Id from CC_Grupo_Colaborador__c where CC_External__c = 'GC-00097'].Id;

        Case caso = new Case(
            Status = 'Activo',
            CC_En_Tercer_Nivel__c = false,
            OwnerId = [SELECT Id FROM User LIMIT 1].Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }

        //Comprobamos que se han modificado los campos del caso y se ha creado la tarea
        CC_EmailSendController.cambiarPropietario('Grupo Test', 'CC_3N_CaixaBank_Now', caso.Id.toString(), 'Se ha cambiado propietario',grupoId.toString());
        List<Case> listCasos = [SELECT OwnerId, Status, CC_En_Tercer_Nivel__c, CC_Grupo_3N__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(1, listCasos.size());
        System.assertEquals(cola.Id, listCasos[0].OwnerId);
        System.assertEquals('Pendiente Interno', listCasos[0].Status);
        System.assertEquals(true, listCasos[0].CC_En_Tercer_Nivel__c);
        System.assertEquals('Grupo Test', listCasos[0].CC_Grupo_3N__c);
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> tareas = [SELECT Description FROM Task WHERE Type = 'Traslado Tercer Nivel' AND RecordTypeId = :taskRecordTypeId];
        System.assertEquals(1, tareas.size());
        System.assertEquals('Se ha cambiado propietario', tareas[0].Description);
        Test.stopTest();
    }
     @isTest
    public static void cambiarPropietario2() {
        Test.startTest();
        //Obtenemos una cola para realizar el test (nos es indiferente cuál)
        Group cola2 = [SELECT Id,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_3N_CaixaBank_Now' LIMIT 1];
        Id grupoId = [SELECT Id from CC_Grupo_Colaborador__c where CC_External__c = 'GC-00097'].Id;

        Case caso = new Case(
            Status = 'Activo',
            CC_En_Tercer_Nivel__c = false,
            OwnerId = [SELECT Id FROM User LIMIT 1].Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
        );

        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }

        //Comprobamos que se han modificado los campos del caso y se ha creado la tarea
        CC_EmailSendController.cambiarPropietario('Grupo Test', 'Cola_3N_CSBD', caso.Id.toString(), 'Se ha cambiado propietario',grupoId.toString());
        List<Case> listCasos = [SELECT OwnerId, Status, CC_En_Tercer_Nivel__c, CC_Grupo_3N__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(1, listCasos.size());
        Test.stopTest();
    }

    //Test para el método cambiarPropietario
    @isTest
    public static void cambiarPropietario2N() {
        Test.startTest();
        //Obtenemos una cola para realizar el test (nos es indiferente cuál)
        Group cola = [SELECT Id,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'CC_2N_Domiciliaciones' LIMIT 1];
        Id grupoId = [SELECT Id from CC_Grupo_Colaborador__c where CC_External__c = 'GC-00097'].Id;

        Case caso = new Case(
            Status = 'Activo',
            CC_En_Segundo_Nivel__c = false,
            OwnerId = [SELECT Id FROM User LIMIT 1].Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }

        //Comprobamos que se han modificado los campos del caso y se ha creado la tarea
        CC_EmailSendController.cambiarPropietario2N('Grupo Test', 'CC_2N_Domiciliaciones', caso.Id.toString(), 'Se ha cambiado el propietario',grupoId.toString());
        List<Case> listCasos = [SELECT OwnerId, Status, CC_En_Segundo_Nivel__c FROM Case WHERE Id = :caso.Id LIMIT 1];
        System.assertEquals(1, listCasos.size());
        System.assertEquals(cola.Id, listCasos[0].OwnerId);
        System.assertEquals('Pendiente Interno', listCasos[0].Status);
        System.assertEquals(true, listCasos[0].CC_En_Segundo_Nivel__c);
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> tareas = [SELECT Description FROM Task WHERE Type = 'Traslado Segundo Nivel' AND RecordTypeId = :taskRecordTypeId];
        System.assertEquals(1, tareas.size());
        System.assertEquals('Se ha cambiado el propietario', tareas[0].Description);
        Test.stopTest();
    }

    @isTest
    public static void devolver3N() {
        Test.startTest();
        Id idPropietario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id;
        Id grupoId = [SELECT Id from CC_Grupo_Colaborador__c where CC_External__c = 'GC-00097'].Id;

        //Caso devolver
        //Creamos un caso y lo trasladamos a tercer nivel
        Case caso = new Case();
        caso.Status = 'Activo';
        caso.CC_En_Tercer_Nivel__c = false;
        caso.OwnerId = idPropietario;
        //caso.CC_Owner_Anterior__c = idAnteriorPropietario;
        caso.CC_Canal_Procedencia__c = 'Formulario Web';
        caso.Origin = 'Email';
        insert caso;

        CC_EmailSendController.cambiarPropietario('Grupo Test', 'CC_3N_CaixaBank_Now', caso.Id.toString(), 'Se traslada a 3N',grupoId.toString());
        Case casoActualizado = [SELECT Id, CC_Resolucion__c FROM Case WHERE Id = :caso.Id];

        //Devolvemos a primer nivel
        casoActualizado.CC_Resolucion__c = 'Resuelto';

        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            update casoActualizado;
        }

        CC_EmailSendController.devolver(casoActualizado.Id, 'Se devuelve a primer nivel', 'devolver', false);

        List<Case> listCasos = [SELECT CC_En_Tercer_Nivel__c, CC_Grupo_3N__c, Status, OwnerId FROM Case WHERE Id = :casoActualizado.Id];
        System.assertEquals(1, listCasos.size());
        System.assertEquals('Activo', listCasos[0].Status);
        System.assertEquals(false, listCasos[0].CC_En_Tercer_Nivel__c);
        System.assertEquals(idPropietario, listCasos[0].OwnerId);
        Test.stopTest();
    }

    @isTest
    public static void rechazar3N() {
		Test.startTest();
        Id idPropietario = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id;
        Id grupoId = [SELECT Id from CC_Grupo_Colaborador__c where CC_External__c = 'GC-00097'].Id;
        //Id idAnteriorPropietario = [SELECT Id FROM User where email = 'tuser000@amamamaaaa.com' LIMIT 1].Id;

        //Creamos un caso y lo trasladamos a tercer nivel
        Case caso = new Case();
        caso.Status = 'Activo';
        caso.CC_En_Tercer_Nivel__c = false;
        caso.OwnerId = idPropietario;
        caso.CC_Canal_Procedencia__c = 'Formulario web';
        caso.Origin = 'Email';
        //caso.CC_Owner_Anterior__c = idAnteriorPropietario;
        insert caso;
        CC_EmailSendController.cambiarPropietario('Grupo Test', 'CC_3N_CaixaBank_Now', caso.Id.toString(), 'Se traslada a 3N',grupoId.toString());
        Case casoActualizado = [SELECT Id, CC_Resolucion__c FROM Case WHERE Id = :caso.Id];

        //Devolvemos a primer nivel
        casoActualizado.CC_Resolucion__c = 'Resuelto';

        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            update casoActualizado;
        }


        CC_EmailSendController.devolver(casoActualizado.Id, 'Se devuelve a primer nivel', 'rechazar', false);


        List<Case> listCasos = [SELECT CC_En_Tercer_Nivel__c, CC_Grupo_3N__c, Status, OwnerId FROM Case WHERE Id = :caso.Id];
        System.assertEquals(1, listCasos.size());
        System.assertEquals('Activo', listCasos[0].Status);
        System.assertEquals(false, listCasos[0].CC_En_Tercer_Nivel__c);
        System.assertEquals(idPropietario, listCasos[0].OwnerId);
        Test.stopTest();
    }

    //Test para el método createActivityTraslados
    @isTest
    public static void actividadesTraslados() {
        Test.startTest();
        Id listaValoresId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id valorId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        Id grupoId = [SELECT Id from CC_Grupo_Colaborador__c where CC_External__c = 'GC-00097'].Id;
        //Insertamos los datos sobre configuración necesarios
        CC_Lista_Valores__c configuracionSLA = new CC_Lista_Valores__c(
            Name = 'Configuración de SLA para 3N',
            RecordTypeId = listaValoresId
        );
        insert configuracionSLA;
        CC_Lista_Valores__c grupo = new CC_Lista_Valores__c(
            Name = 'Grupo 1',
            CC_Valor__c = '12',
            CC_Activa__c = true,
            RecordTypeId = valorId,
            CC_Lista__c = configuracionSLA.Id
        );
        insert grupo;
        CC_Lista_Valores__c configuracionHorario = new CC_Lista_Valores__c(
            Name = 'Configuración de horario de oficina para 3N',
            RecordTypeId = listaValoresId
        );
        insert configuracionHorario;
        CC_Lista_Valores__c horario = new CC_Lista_Valores__c(
            Name = 'Grupo 1',
            CC_Valor__c = 'Default',
            CC_Activa__c = true,
            RecordTypeId = valorId,
            CC_Lista__c = configuracionHorario.Id
        );
        insert horario;

        //Creamos un caso sobre el que crear las tareas
        Case caso = new Case(
            Status = 'Activo',
            CC_En_Tercer_Nivel__c = false,
            OwnerId = [SELECT Id FROM User LIMIT 1].Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId()
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }
        //Comprobamos que se ha creado la tarea (lo hacemos desde el método cambiarPropietario ya que createActivityTraslados es private)
        CC_EmailSendController.cambiarPropietario('Grupo Test', 'CC_3N_CaixaBank_Now', caso.Id.toString(), 'Se ha cambiado propietario',grupoId.toString());
        Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        List<Task> listTareas = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND RecordTypeId =: taskRecordTypeId];
        Test.stopTest();
        System.assert(listTareas.size() > 0);
    }
    //Test para el método obtenerSubjectEmailTemplate
    @isTest
    public static void obtenerSubjectPlantilla() {
        Test.startTest();
        //Como no podemos realizar insert de plantillas desde clases de test trabajaremos con alguna de las existentes
        EmailTemplate plantilla = [SELECT Id, Subject FROM EmailTemplate LIMIT 1];
        //Comprobamos que el método devuelve el subject de la plantilla
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            String subject = CC_EmailSendController.obtenerSubjectEmailTemplate(plantilla.Id);
            Test.stopTest();

        System.assertEquals(plantilla.Subject, subject);
        }

    }
    //Test para los métodos mostrarBotonesPendienteColaborador, mostrarBotonesPendienteInterno y mostrarBotonesPendienteCliente
    @isTest
    public static void botonesVisibles() {
        Test.startTest();
        //Caso estado diferente de 'pendiente interno', 'pendiente colaborador' y 'pendiente cliente'
        Case caso = new Case(
            Status = 'Activo',
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }
        //Comprobamos que los botones son visibles

        Boolean visible = CC_EmailSendController.mostrarBotonesPendienteColaborador(caso.Id);

        System.assertEquals(true, visible);

        visible = CC_EmailSendController.mostrarBotonesPendienteInterno(caso.Id);

        System.assertEquals(true, visible);

        visible = CC_EmailSendController.mostrarBotonesPendienteCliente(caso.Id);

        System.assertEquals(true, visible);

        //Caso estado pendiente interno
        caso.Status = 'Pendiente Interno';
        update caso;
        //Comprobamos que los botones no son visibles

        visible = CC_EmailSendController.mostrarBotonesPendienteInterno(caso.Id);

        System.assertEquals(false, visible);
        caso.Status = 'Activo';
        update caso;

        //Caso estado pendiente interno
        caso.Status = 'Pendiente Cliente';
        update caso;
        //Comprobamos que los botones no son visibles

        visible = CC_EmailSendController.mostrarBotonesPendienteCliente(caso.Id);

        System.assertEquals(false, visible);
        caso.Status = 'Activo';
        update caso;

        //Caso estado pendiente interno
        caso.Status = 'Pendiente Colaborador';
        update caso;
        //Comprobamos que los botones no son visibles
        visible = CC_EmailSendController.mostrarBotonesPendienteColaborador(caso.Id);
        Test.stopTest();
        System.assertEquals(false, visible);
    }
    //Test para los métodos tienePermisoTrasladoColaborador, tienePermisoRemitirColaborador, tienePermisoTrasladoColaborador, tienePermisoSolicitudInformacion, tienePermisoTraslado3N,
    // tienePermisoDevolver1N, tienePermisoRechazar1N, tienePermisoResponderCliente, tienePermisoAsociarIncidencia, tienePermisoCrearIncidencia y tienePermisoAutoasignarmeCaso
    @isTest
    public static void getCustomPermissions() {
        Test.startTest();

        Case caso = new Case(
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }
        //Nombre de grupo de 3N no habilitado
        String nombreGrupoNoHabilitado = 'Grupo no habilitado';

        //Nombre de grupo de 3N habilitado
        String nombreGrupoHabilitado = 'Grupo habilitado';

        CC_Lista_Valores__c listaGruposConDevolucion = new CC_Lista_Valores__c();
        listaGruposConDevolucion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaGruposConDevolucion.Name = '3N - Grupos con devolución a 1N';
        insert listaGruposConDevolucion;

        CC_Lista_Valores__c grupoConDevolucion = new CC_Lista_Valores__c();
        grupoConDevolucion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        grupoConDevolucion.CC_Lista__c = listaGruposConDevolucion.Id;
        grupoConDevolucion.Name = nombreGrupoHabilitado;
        insert grupoConDevolucion;

        //Invocación al método con grupo de 3N habilitado
        Map<String, Boolean> permisos = new Map<String, Boolean>();
        permisos = CC_EmailSendController.getCustomPermissions(nombreGrupoHabilitado, caso);
        System.assertEquals(permisos.get('CC_Trasladar_Colaborador'), FeatureManagement.checkPermission('CC_Trasladar_Colaborador'));
        System.assertEquals(permisos.get('CC_Remitir_Colaborador'), FeatureManagement.checkPermission('CC_Remitir_Colaborador'));
        System.assertEquals(permisos.get('CC_Solicitar_Informacion'), FeatureManagement.checkPermission('CC_Solicitar_Informacion'));
        System.assertEquals(permisos.get('CC_Trasladar_3N'), FeatureManagement.checkPermission('CC_Trasladar_3N'));
        System.assertEquals(permisos.get('CC_Devolver_1N'), FeatureManagement.checkPermission('CC_Devolver_1N'));
        System.assertEquals(permisos.get('CC_Devolver_1N_LOV'), true);
        System.assertEquals(permisos.get('CC_Rechazar_1N'), FeatureManagement.checkPermission('CC_Rechazar_1N'));
        System.assertEquals(permisos.get('CC_Responder_Cliente'), FeatureManagement.checkPermission('CC_Responder_Cliente'));
        System.assertEquals(permisos.get('CC_Crear_Incidencia'), FeatureManagement.checkPermission('CC_Crear_Incidencia'));
        System.assertEquals(permisos.get('CC_Asociar_Incidencia'), FeatureManagement.checkPermission('CC_Asociar_Incidencia'));
        System.assertEquals(permisos.get('CC_Autoasignarme_Caso'), FeatureManagement.checkPermission('CC_Autoasignarme_Caso'));
        System.assertEquals(permisos.get('CC_OTP'), FeatureManagement.checkPermission('CC_OTP'));
        System.assertEquals(permisos.get('CC_Envio_Notificacion_Push'), FeatureManagement.checkPermission('CC_Envio_Notificacion_Push'));
        System.assertEquals(permisos.get('CC_GDPR'), FeatureManagement.checkPermission('CC_GDPR'));

        //Invocación al método con grupo de 3N NO habilitado
        permisos = CC_EmailSendController.getCustomPermissions(nombreGrupoNoHabilitado, caso);

        System.assertEquals(permisos.get('CC_Devolver_1N_LOV'), false);
        Test.stopTest();
    }

    //Test para los métodos getPlantillaList
    @isTest
    public static void obtenerListaPlantillas() {
        Test.startTest();
        //Caso trasladar
        //
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	List<CC_EmailSendController.picklistWrapper> plantillaListTrasladar = CC_EmailSendController.getPlantillaList('trasladar', null);
            System.assert(plantillaListTrasladar.size() > 0);

            //Caso solicitar

            List<CC_EmailSendController.picklistWrapper> plantillaListSolicitar = CC_EmailSendController.getPlantillaList('solicitar', null);

            System.assert(plantillaListSolicitar.size() > 0);
            Test.stopTest();
        }

    }
    //Test para los métodos getPlantillaGrupoList
    @isTest
    public static void obtenerListaPlantillasGrupo() {
        Test.startTest();
        Id recordTypeIdGrupo = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Test',
            CC_External__c = 'GC-00004',
            RecordTypeId = recordTypeIdGrupo

        );
        insert grupo;
        List<EmailTemplate> plantillas = [SELECT Name, DeveloperName FROM EmailTemplate];
        List<CC_Grupo_Colaborador_Plantilla__c> grupoPlantillas = new List<CC_Grupo_Colaborador_Plantilla__c>();
        for (EmailTemplate plantilla : plantillas) {
            CC_Grupo_Colaborador_Plantilla__c plantillaGrupo = new CC_Grupo_Colaborador_Plantilla__c(
                CC_Grupo_Colaborador__c = grupo.Id,
                CC_Plantilla_Name__c = plantilla.Name,
                CC_Plantilla_DeveloperName__c = plantilla.DeveloperName,
                CC_Operativa__c = 'Trasladar'
            );
            grupoPlantillas.add(plantillaGrupo);
        }
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert grupoPlantillas;
        }
        //Comprobamos que obtenemos la lista de plantillas
        List<CC_EmailSendController.picklistWrapper> plantillaListGrupo = CC_EmailSendController.getPlantillaGrupoList(grupo.Id, 'Trasladar');
        Test.stopTest();
        System.assertEquals(plantillas.size(), plantillaListGrupo.size());
    }
    //Test para el método obtenerIdioma
    @isTest
    public static void obtenerIdioma() {
        Test.startTest();
        Case caso = new Case(
            CC_Idioma__c = 'es',
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }
        //Comprobamos que obtenemos el idioma
        String idioma = CC_EmailSendController.obtenerIdioma(caso.Id);
        Test.stopTest();
        System.assertEquals('es', idioma);
    }
    //Test para el método obtenerCanalRespuesta
    @isTest
    public static void obtenerCanalRespuesta() {
        Test.startTest();
        Case caso = new Case(
            CC_Canal_Respuesta__c = 'Email',
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }
        //Comprobamos que obtenemos el canal de respuesta
        String canalRespuesta = CC_EmailSendController.obtenerCanalRespuesta(caso.Id);
        Test.stopTest();
        System.assertEquals('Email', canalRespuesta);
    }
    //Test para el método buscarPlantillasResponder
    @isTest
    public static void obtenerPlantillasResponder() {
        Test.startTest();
        List<EmailTemplate> plantillas = CC_EmailSendController.buscarPlantillasResponder('C', 'CC_Responder_ca_informal');
        Test.stopTest();
        System.assert(plantillas.size() > 0);
    }
    //Test para el método getPlantillasResponder
    @isTest
    public static void obtenerListaPlantillasResponder() {
        Test.startTest();
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;

        Case caso = new Case(
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }

        //Comprobamos en el caso de que no haya plantillas asociadas
        List<CC_EmailSendController.picklistWrapper> plantillasList = CC_EmailSendController.getPlantillasResponder(caso.Id, 'CC_Responder_ca_informal');
        System.assert(plantillasList.size() > 0);

        //Comprobamos en el caso de que haya alguna plantilla asociada
        EmailTemplate plantilla = [SELECT Name, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'CC_Responder_es_informal' LIMIT 1];
        CC_MCC_Plantilla__c mccPlantilla = new CC_MCC_Plantilla__c(
            CC_MCC__c = tematica.Id,
            CC_MCC_Plantilla_Name__c = plantilla.Name,
            CC_MCC_Plantilla_DeveloperName__c = plantilla.DeveloperName
            );
            insert mccPlantilla;
            //No perteneciente a la carpeta

            plantillasList = CC_EmailSendController.getPlantillasResponder(caso.Id, 'CC_Responder_es_informal');

            System.assert(plantillasList.size() > 0);
            //Perteneciente a la carpeta

            plantillasList = CC_EmailSendController.getPlantillasResponder(caso.Id, 'CC_Responder_ca_informal');

            System.assert(plantillasList.size() > 0);
            Test.stopTest();
    }
    //Test para el método getCarpetas
    @isTest
    public static void obtenerCarpetas() {
        Test.startTest();
        Boolean existeCarpeta = CC_EmailSendController.existeCarpeta('CC_Responder');
        System.assert(existeCarpeta, false);

        //Caso de no dar carpeta raíz
        List<Folder> carpetas = CC_EmailSendController.getCarpetas(null,'CC_Responder');
        System.assert(carpetas.size() > 0);

        //Caso de dar carpeta raíz
        carpetas = CC_EmailSendController.getCarpetas('CC_Operativas','CC_Responder');
        System.assert(carpetas.size() > 0);
        Test.stopTest();
    }
    //Test para el método getGrupoList
    @isTest
    public static void obtenerGrupoList() {
        Test.startTest();
        Id recordTypeIdCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Id recordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();

        //Insertamos un grupo colaborador
        CC_Grupo_Colaborador__c grupoColaborador = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Colaborador Test',
            CC_External__c = 'GC-00005',
            RecordTypeId = recordTypeId
        );
        insert grupoColaborador;

        //Insertamos cuenta de tipo OF y GC (el process builder CC_Account_Procesado ya se encarga de crear los grupos)
        Account cuentaGC = new Account(
            Name = 'Cuenta Test GC',
            CC_Tipo_Centro__c = 'GC',
            RecordTypeId = recordTypeIdCentro
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert cuentaGC;
        }
        Account cuentaOF = new Account(
            Name = 'Cuenta Test OF',
            CC_Tipo_Centro__c = 'OF',
            RecordTypeId = recordTypeIdCentro
        );
        insert cuentaOF;
       // System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
         //Comprobamos que la función nos devuelve una lista con los tres grupos
            List<CC_EmailSendController.picklistWrapper> listaGrupos = CC_EmailSendController.getGrupoList();
            System.assertEquals(4, listaGrupos.size());
            Test.stopTest();

       // }
    }
    //Test para el método getMCCGrupoList
    @isTest
    public static void obtenerGrupoMCCList() {
        Test.startTest();
        Id recordTypeIdGrupo = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_Grupo_Colaborador__c grupoTematica = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Temática Test',
            CC_External__c = 'GC-00006',
            RecordTypeId = recordTypeIdGrupo,
            CC_Tipo__c = 'Traslados y Remitidos'
        );
        insert grupoTematica;
        CC_MCC_Grupo_Colaborador__c mccGrupoTematica = new CC_MCC_Grupo_Colaborador__c(
            CC_MCC__c = tematica.Id,
            CC_Grupo_Colaborador__c = grupoTematica.Id
        );
        insert mccGrupoTematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_Grupo_Colaborador__c grupoProducto = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Producto Test',
            CC_External__c = 'GC-00007',
            RecordTypeId = recordTypeIdGrupo,
            CC_Tipo__c = 'Traslados y Remitidos'
        );
        insert grupoProducto;
        CC_MCC_Grupo_Colaborador__c mccGrupoProducto = new CC_MCC_Grupo_Colaborador__c(
            CC_MCC__c = producto.Id,
            CC_Grupo_Colaborador__c = grupoProducto.Id
        );
        insert mccGrupoProducto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;
        CC_Grupo_Colaborador__c grupoMotivo = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Motivo Test',
            CC_External__c = 'GC-00007',
            RecordTypeId = recordTypeIdGrupo,
            CC_Tipo__c = 'Traslados y Remitidos'
        );
        insert grupoMotivo;
        CC_MCC_Grupo_Colaborador__c mccGrupoMotivo = new CC_MCC_Grupo_Colaborador__c(
            CC_MCC__c = motivo.Id,
            CC_Grupo_Colaborador__c = grupoMotivo.Id
        );
        insert mccGrupoMotivo;

        Case caso = new Case(
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        insert caso;

        //Comprobamos que obtenemos una lista con los tres grupos
        List<CC_EmailSendController.picklistWrapperTraslados> listaGrupos = CC_EmailSendController.getMCCGrupoList(caso.Id, '', true);
        System.assertEquals(3, listaGrupos.size());
        Test.stopTest();
    }
    //Test para el método vaciarPlantilla
    @isTest
    public static void comprobarPlantillaVacia() {
        Test.startTest();
        Case caso = new Case(
            CC_MCC_Plantilla__c = 'Plantilla MCC',
            CC_Email_Cabecera__c = 'Cabecera',
            CC_Email_Pie__c = 'Pie',
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        insert caso;

        //Comprobamos que el método vacía la plantilla
        CC_EmailSendController.vaciarPlantilla(caso.Id);
        caso = [SELECT CC_MCC_Plantilla__c, CC_Email_Cabecera__c, CC_Email_Pie__c FROM Case WHERE Id =: caso.Id LIMIT 1];
        System.assertEquals(null, caso.CC_MCC_Plantilla__c);
        System.assertEquals(null, caso.CC_Email_Cabecera__c);
        System.assertEquals(null, caso.CC_Email_Pie__c);
        Test.stopTest();
    }
    //Test para el método actualizarCaso
    @isTest
    public static void comprobarActualizacion() {
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Comprobar actualizacion'];

        //Caso respuesta formal ca
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Plantilla_Test_ca_formal';
        template1.DeveloperName = 'Plantilla_Test_ca_formal';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }
        CC_EmailSendController.actualizarCaso(caso.Id, template1.Id, true, 'CC_Responder_Accionista_ca_formal', 'responder', 'Email','Accionista', 'CC_Cliente');
        Case casoFormalCa = [SELECT CC_MCC_Plantilla__c, CC_Email_Cabecera__c, CC_Email_Pie__c, CC_Referencia_Correo_Saliente__c, CC_Canal_Respuesta__c FROM Case WHERE Id =: caso.Id];
        System.assertEquals(template1.Id, casoFormalCa.CC_MCC_Plantilla__c);
        System.assertEquals('Cabecera_ca_formal_accionista', casoFormalCa.CC_Email_Cabecera__c);
        System.assertEquals('Pie_ca_formal_accionista', casoFormalCa.CC_Email_Pie__c);
        System.assert(casoFormalCa.CC_Referencia_Correo_Saliente__c != null);
        Test.stopTest();
    }

    @isTest
    public static void comprobarActualizacion2() {
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Comprobar actualizacion'];
        EmailTemplate template2 = new EmailTemplate();
        template2.FolderId = UserInfo.getUserId();
        template2.Name = 'Plantilla_Test_ca_informal';
        template2.DeveloperName = 'Plantilla_Test_ca_informal';
        template2.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template2;
        }
        CC_EmailSendController.actualizarCaso(caso.Id, template2.Id, true, 'CC_Responder_ca_informal', 'responder', 'Email','Formulario web', 'CC_Cliente');
        Case casoInormalCa = [SELECT CC_MCC_Plantilla__c, CC_Email_Cabecera__c, CC_Email_Pie__c, CC_Referencia_Correo_Saliente__c, CC_Canal_Respuesta__c FROM Case WHERE Id =: caso.Id];
        System.assertEquals(template2.Id, casoInormalCa.CC_MCC_Plantilla__c);
        System.assertEquals('Cabecera_ca_informal', casoInormalCa.CC_Email_Cabecera__c);
        System.assertEquals('Pie_ca_informal', casoInormalCa.CC_Email_Pie__c);
        System.assert(casoInormalCa.CC_Referencia_Correo_Saliente__c != null);
        Test.stopTest();
    }

    @isTest
    public static void comprobarActualizacion3() {
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Comprobar actualizacion'];
        EmailTemplate template3 = new EmailTemplate();
        template3.FolderId = UserInfo.getUserId();
        template3.Name = 'Plantilla_Test_es_formal';
        template3.DeveloperName = 'Plantilla_Test_es_formal';
        template3.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template3;
        }
        CC_EmailSendController.actualizarCaso(caso.Id, template3.Id, true, 'CC_Responder_Accionista_es_formal', 'responder', 'Email','Accionista', 'CC_Cliente');
        Case casoFormalEs = [SELECT CC_MCC_Plantilla__c, CC_Email_Cabecera__c, CC_Email_Pie__c, CC_Referencia_Correo_Saliente__c, CC_Canal_Respuesta__c FROM Case WHERE Id =: caso.Id];
        System.assertEquals(template3.Id, casoFormalEs.CC_MCC_Plantilla__c);
        System.assertEquals('Cabecera_es_formal_accionista', casoFormalEs.CC_Email_Cabecera__c);
        System.assertEquals('Pie_es_formal_accionista', casoFormalEs.CC_Email_Pie__c);
        System.assert(casoFormalEs.CC_Referencia_Correo_Saliente__c != null);
        Test.stopTest();
    }

    @isTest
    public static void comprobarActualizacion4() {
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Comprobar actualizacion'];
        EmailTemplate template4 = new EmailTemplate();
        template4.FolderId = UserInfo.getUserId();
        template4.Name = 'Plantilla_Test_es_informal';
        template4.DeveloperName = 'Plantilla_Test_es_informal';
        template4.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template4;
        }
        CC_EmailSendController.actualizarCaso(caso.Id, template4.Id, true, 'CC_Responder_es_informal', 'responder', 'Email','Formulario web', 'CC_Cliente');
        Case casoInormalEs = [SELECT CC_MCC_Plantilla__c, CC_Email_Cabecera__c, CC_Email_Pie__c, CC_Referencia_Correo_Saliente__c, CC_Canal_Respuesta__c FROM Case WHERE Id =: caso.Id];
        System.assertEquals(template4.Id, casoInormalEs.CC_MCC_Plantilla__c);
        System.assertEquals('Cabecera_es_informal', casoInormalEs.CC_Email_Cabecera__c);
        System.assertEquals('Pie_es_informal', casoInormalEs.CC_Email_Pie__c);
        System.assert(casoInormalEs.CC_Referencia_Correo_Saliente__c != null);
        Test.stopTest();
    }

    @isTest
    public static void comprobarActualizacion5() {
        Test.startTest();
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Comprobar actualizacion'];
        EmailTemplate template5 = new EmailTemplate();
        template5.FolderId = UserInfo.getUserId();
        template5.Name = 'Plantilla_Test_en';
        template5.DeveloperName = 'Plantilla_Test_en';
        template5.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template5;
        }
        CC_EmailSendController.actualizarCaso(caso.Id, template5.Id, true, 'CC_Responder_en_generico', 'responder', 'Email','Formulario web', 'CC_Cliente');
        Case casoEn = [SELECT CC_MCC_Plantilla__c, CC_Email_Cabecera__c, CC_Email_Pie__c, CC_Referencia_Correo_Saliente__c, CC_Canal_Respuesta__c FROM Case WHERE Id =: caso.Id];
        System.assertEquals(template5.Id, casoEn.CC_MCC_Plantilla__c);
        System.assertEquals('Cabecera_en', casoEn.CC_Email_Cabecera__c);
        System.assertEquals('Pie_en', casoEn.CC_Email_Pie__c);
        System.assert(casoEn.CC_Referencia_Correo_Saliente__c != null);
        Test.stopTest();
    }
    //Test para el método habilitarOperativas
    // @isTest
    // public static void estadoOperativas() {
    //     Id tematicaId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
    //     Id productoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
    //     Id motivoId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

    //     //Caso en el que no esté clasificado el caso
    //     Case caso = new Case(
    //         Status = 'Activo',
    //         Origin = 'Email',
    //         CC_Canal_Procedencia__c = 'Formulario web',
    //         CC_Idioma__c = 'es',
    //         CC_Tipo_Contacto__c = 'Consulta'
    //     );
    //     insert caso;
    //     //Comprobamos que las operativas no están habilitadas
    //     //Boolean habilitadas = CC_EmailSendController.habilitarOperativas(caso.Id);
    //     //System.assertEquals(false, habilitadas);

    //     //Caso en el que esté clasificado el caso
    //     CC_MCC__c tematica = new CC_MCC__c(
    //         Name = 'Tematica Test',
    //         RecordTypeId = tematicaId,
    //         CC_Tipo_Cliente__c = 'Cliente',
    //         CC_Canal_Operativo__c = 'Cajero',
    //         CC_Codigo_Externo__c = 'TE-000001'
    //     );
    //     insert tematica;
    //     CC_MCC__c producto = new CC_MCC__c(
    //         Name = 'Producto Test',
    //         RecordTypeId = productoId,
    //         CC_Tematica__c = tematica.Id,
    //         CC_Tipo_Cliente__c = 'Cliente',
    //         CC_Codigo_Externo__c = 'PR-000001'
    //     );
    //     insert producto;
    //     CC_MCC__c motivo = new CC_MCC__c(
    //         Name = 'Motivo Test',
    //         RecordTypeId = motivoId,
    //         CC_Producto_Servicio__c = producto.Id,
    //         CC_Tipo_Cliente__c = 'Cliente',
    //         CC_Codigo_Externo__c = 'MO-000001'
    //     );
    //     insert motivo;
    //     caso.CC_MCC_Tematica__c = tematica.Id;
    //     caso.CC_MCC_ProdServ__c = producto.Id;
    //     caso.CC_MCC_Motivo__c = motivo.Id;
    //     update caso;
    //     //Comprobamos que las operativas están habilitadas
    //     //habilitadas = CC_EmailSendController.habilitarOperativas(caso.Id);
    //     //System.assertEquals(true, habilitadas);
    // }
    //Test para el método obtenerEmailFrom
    @isTest
    public static void obtenerFrom() {
        //Comprobamos que obtenemos el correo correctamente
        //Caso idioma ca
        Test.startTest();
        String fromCas = CC_EmailSendController.obtenerEmailFrom('es');
        Test.stopTest();
        System.assert(fromCas != null);
        //Caso idioma cas
        String fromCat = CC_EmailSendController.obtenerEmailFrom('ca');
        System.assert(fromCat != null);
        //Caso idioma cas
        String fromEng = CC_EmailSendController.obtenerEmailFrom('en');
        System.assert(fromEng != null);

    }
    //Test para el método autoasignarmeCaso
    @isTest
    public static void autoasignarme() {
        Case caso = new Case(
            Status = 'Activo',
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        insert caso;
        Id idUsuario = UserInfo.getUserId();
        //Comprobamos que se ha autoasignado el caso
        Test.startTest();
        CC_EmailSendController.autoasignarmeCaso(caso.Id);
        Test.stopTest();
        Case casoAutoasignado = [SELECT OwnerId, CC_Autoasignado_Coordinador__c FROM Case WHERE Id =: caso.Id];
        System.assertEquals(idUsuario, casoAutoasignado.OwnerId);
        System.assertEquals(true, casoAutoasignado.CC_Autoasignado_Coordinador__c);
    }

    //Test para el método recuperaMailEmpleado
    @isTest
    public static void recuperaMailEmpleadoTest() {
        Contact contacto = new Contact(
            FirstName = 'Contacto',
            LastName = 'Test',
            CC_Idioma__c = 'es',
            Email = 'contacto@test.com'
        );
        insert contacto;

        Case caso = new Case(
            ContactId = contacto.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        insert caso;

        //Comprobamos que se ha recuperado el email
        Contact contactoSelect = [Select Id, Email, Name FROM Contact where Email = 'contacto@test.com'];
        Test.startTest();
        List<Case> lCaso = CC_EmailSendController.recuperaMailEmpleado(String.valueOf(caso.Id));
        Test.stopTest();
        System.assertEquals(lCaso[0].Contact.Email, contactoSelect.Email);
        System.assertEquals(lCaso[0].Contact.Name, contactoSelect.Name);
    }

        //Test para los métodos crearTaskWebCollab y updateTaskWebCollab
    @isTest
    public static void crearModificarTaskWebCollabTest() {
        Account cuenta = new Account(
            Name = 'Cuenta Test',
            CC_Email__c = 'cuenta@test.com'
        );
        insert cuenta;

        //Devuelve el Id de la tarea creada
        Test.startTest();
        String respuesta = CC_EmailSendController.crearTaskWebCollab(String.valueOf(cuenta.Id), 'Juan');
        Test.stopTest();
    Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();

        //Comprobamos que se ha creado la tarea correctamente
        Task tarea = [SELECT Status, Subject, Description FROM Task WHERE Id =: respuesta AND RecordTypeId =: taskRecordTypeId];
        System.assertEquals(tarea.Status, 'Open');
        System.assertEquals(tarea.Subject, 'Solicitud de Compartición de pantalla');
        System.assertEquals(tarea.Description, 'Se comparte pantalla con el empleado: Juan');


        //Devuelve el Id de la tarea modificada
        respuesta = CC_EmailSendController.updateTaskWebCollab(String.valueOf(cuenta.Id));

        //Comprobamos que se ha modificado la tarea correctamente
        tarea = [SELECT Status, Subject, Description FROM Task WHERE Id =: respuesta AND RecordTypeId =: taskRecordTypeId];
        System.assertEquals(tarea.Status, 'Completed');
    }

    @isTest
    public static void recuperarCarpetasYCuerpoPlantillaTest()
    {
        // CC_Solicitar contiene 3 carpetas y una plantilla
        Test.startTest();
        List<Folder> folderList = CC_EmailSendController.subdirectorios('CC_Solicitar');
        Test.stopTest();
        System.assertEquals(3, folderList.size());

        List<EmailTemplate> templateList = CC_EmailSendController.plantillas('CC_Solicitar_es_formal');
        System.assert(templateList.size()>0);

        // Utilizamos una plantilla con cuerpo en este ultimo test
        //String cuerpoMensaje = CC_EmailSendController.plantillaCuerpo('Acuse_Recibo_FORMWEB_CA_1561052736047', true);
        //System.assert(String.isNotBlank(cuerpoMensaje));

    }

    @isTest
    public static void obtenerDatosCasoGDPRTest()
    {
        Case caso = new Case();
        insert caso;

        Test.startTest();
        CC_EmailSendController.DatosCasoGDPRWrapper datos = CC_EmailSendController.obtenerDatosCasoGDPR(caso.Id);
        Test.stopTest();
        System.assertEquals(false, datos.productoGDPR);
        System.assertEquals('',    datos.tipoContacto);
        System.assertEquals('',    datos.numPerso);
        System.assertEquals('',    datos.numeroDocumento);
        System.assertEquals(0,     datos.edad);
        System.assertEquals(false, datos.confidencial);
        System.assertEquals('',    datos.tipoPersona);
        System.assertEquals(false, datos.fallecido);
        System.assertEquals(false, datos.incapacitado);
    }

    @isTest
    public static void validarCamposCasoTest() {
        Id recordTypeIdTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordTypeIdProducto = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordTypeIdMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'Ahorro a la vista';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        insert mccTematica;

        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;

        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Apertura sin autorización';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today().addDays(7);
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        List<Case> caseList = new List<Case>();
        caseList.add(new Case(CC_Idioma__c = null));
        caseList.add(new Case(Origin = 'Phone', CC_Detalles_Consulta__c= 'AAAAA', CC_Canal_Procedencia__c = 'Cajeros', CC_Tipo_Contacto__c = 'Consulta',
        CC_MCC_Tematica__c = mccTematica.Id, CC_MCC_ProdServ__c = mccProducto.Id, CC_MCC_Motivo__c = mccMotivo.Id, CC_Canal_Operativo__c = 'Sin canal'));
        insert caseList;

        // Todos los campos fallan, excepto el que requiere una comprobación a los MCCs
        Test.startTest();
        List<String> invalidFieldsList = CC_EmailSendController.validarCamposCaso(caseList[0].Id);
        Test.stopTest();
        System.assertEquals(8, invalidFieldsList.size());

        // Sólo falla que el MCC se encuentra inactivo
        invalidFieldsList = CC_EmailSendController.validarCamposCaso(caseList[1].Id);
        System.assertEquals(1, invalidFieldsList.size());
        System.assertEquals('Clasificación inactiva', invalidFieldsList[0]);
    }

    //Test para el método buscarGruposColaboradores
    @isTest
    public static void obtenerGruposCSIBankia() {
        Test.startTest();
        //Creamos grupos de colaboradores
        Id grupoColaboradorRecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        List<CC_Grupo_Colaborador__c> groupList = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo1 = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Test 1',
            CC_External__c = 'GC-00001',
            RecordTypeId = grupoColaboradorRecordTypeId,
            OS_Negocio__c = 'CSI_Bankia'
        );
        groupList.add(grupo1);
        CC_Grupo_Colaborador__c grupo2 = new CC_Grupo_Colaborador__c(
            Name = 'Grupo Test 2',
            CC_External__c = 'GC-00002',
            RecordTypeId = grupoColaboradorRecordTypeId,
            OS_Negocio__c = 'CSI_Bankia'
        );
        groupList.add(grupo2);

        insert groupList;

        //Comprobamos que la búsqueda nos devuelve los grupos creados
        List<CC_Grupo_Colaborador__c> resultadoBusqueda = CC_EmailSendController.buscarGruposColaboradores('Grupo', 'CSI_Bankia', false, 'CC_Empleado');
        Test.stopTest();

        System.assertEquals(2, resultadoBusqueda.size());
        List<String> nombresEntrada = new List<String>{grupo1.Name, grupo2.Name};
        List<String> nombresSalida = new List<String>{resultadoBusqueda[0].Name, resultadoBusqueda[1].Name};
        System.assertEquals(nombresEntrada, nombresSalida);
    }

    @isTest
    public static void validarCanalAutenticacionTest() {
        Test.startTest();
        CC_Lista_Valores__c listaAutenticacionCliente = new CC_Lista_Valores__c();
        listaAutenticacionCliente.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        listaAutenticacionCliente.CC_Activa__c = true;
        listaAutenticacionCliente.Name = 'CC_Autenticacion_Cliente';
        insert listaAutenticacionCliente;

        CC_Lista_Valores__c valorTelefono = new CC_Lista_Valores__c();
        valorTelefono.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorTelefono.CC_Activa__c = true;
        valorTelefono.CC_Lista__c = listaAutenticacionCliente.Id;
        valorTelefono.Name = 'Teléfono';
        valorTelefono.CC_Valor__c = 'Teléfono';
        insert valorTelefono;
        /*
        CC_Lista_Valores__c valorDesactivado = new CC_Lista_Valores__c();
        valorDesactivado.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorDesactivado.CC_Activa__c = false;
        valorDesactivado.CC_Lista__c = listaAutenticacionCliente.Id;
        valorDesactivado.Name = 'Twitter';
        valorDesactivado.CC_Valor__c = 'Twitter';
        insert valorDesactivado;
        */
        Case caso = new Case(
            Status = 'Activo',
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Accionista'
        );
        insert caso;

        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        Case casoInvalido = new Case(
            recordTypeId=recordTypeCaso,
            Status = 'Activo',
            Origin = 'Chat',
            CC_Canal_Procedencia__c = 'App'
        );
        insert casoInvalido;

        System.assertEquals(true,  CC_EmailSendController.validarCanalAutenticacion(caso.Id));
        System.assertEquals(false,  CC_EmailSendController.validarCanalAutenticacion(casoInvalido.Id));
        Test.stopTest();
    }

    @isTest
    static void derivarAlSac() {
        Test.startTest();
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id causaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id solucionId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;
        CC_MCC__c causa = new CC_MCC__c(
            Name = 'Causa Test',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivo.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001'
        );
        insert causa;
        CC_MCC__c solucion = new CC_MCC__c(
            Name = 'Solucion Test',
            RecordTypeId = solucionId,
            CC_Producto_Servicio__c = causa.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'SO-000001'
        );
        insert solucion;

        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'test';
        contacto.LastName = 'test';
        insert contacto;

        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center para Derivar al SAC';
        casoCC.Description = 'Caso de Contact Center para Derivar al SAC';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Formulario web';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center para Derivar al SAC';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuenta.Id;
        casoCC.ContactId = contacto.Id;
        casoCC.CC_Canal_Operativo__c = 'App CaixaBankSign';
        casoCC.CC_MCC_Tematica__c = tematica.Id;
        casoCC.CC_MCC_ProdServ__c = producto.Id;
        casoCC.CC_MCC_Motivo__c = motivo.Id;
        casoCC.CC_MCC_Causa__c = causa.Id;
        casoCC.CC_MCC_Solucion__c = solucion.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert casoCC;
            CC_EmailSendController.derivarCasoAlSAC(casoCC, 'Motivo derivar');
        }

        List<Case> casoSAC = [SELECT Id, CC_Motivo__c   FROM Case WHERE ParentId = :casoCC.Id];
        Test.stopTest();
        System.assertEquals(1, casoSAC.size(), 'La creación de la reclamación desde CC no ha funcionado.');
        System.assertEquals('Motivo derivar', casoSAC.get(0).CC_Motivo__c  , 'El motivo no coincide');
    }


    @isTest
    static void devolverAlSac() {

        Test.startTest();
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id causaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        Id solucionId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;
        CC_MCC__c causa = new CC_MCC__c(
            Name = 'Causa Test',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivo.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001'
        );
        insert causa;
        CC_MCC__c solucion = new CC_MCC__c(
            Name = 'Solucion Test',
            RecordTypeId = solucionId,
            CC_Producto_Servicio__c = causa.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'SO-000001'
        );
        insert solucion;

        Account cuenta = new Account();
        cuenta.Name = 'cuentaTest';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'test';
        contacto.LastName = 'test';
        insert contacto;

        Case casoSac = new Case();
        casoSac.Subject = 'CASO SAC Derivar a CC';
        casoSac.Description = 'Luego devolveremos nuestro caso de CC a este caso SAC';
        casoSac.CC_Idioma__c = 'es';
        casoSac.Origin = 'SAC_Manual';
        casoSac.Status = 'SAC_001';
        casoSac.SAC_StatusAuxiliar__c = 'SAC_001';
        casoSac.CC_Tipo_Contacto__c = 'Consulta';
        casoSac.CC_Canal_Procedencia__c = 'Junta Andalucia';
        casoSac.SAC_TipoConsumidor__c = 'Si';
        casoSac.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        insert casoSac;

        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center para devolver al SAC';
        casoCC.Description = 'Caso de Contact Center para devolver al SAC';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Formulario web';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center para devolver al SAC';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuenta.Id;
        casoCC.ContactId = contacto.Id;
        casoCC.ParentId = casoSac.Id;
        casoCC.CC_Canal_Operativo__c = 'App BrokerNow';
        casoCC.CC_MCC_Tematica__c = tematica.Id;
        casoCC.CC_MCC_ProdServ__c = producto.Id;
        casoCC.CC_MCC_Motivo__c = motivo.Id;
        casoCC.CC_MCC_Causa__c = causa.Id;
        casoCC.CC_MCC_Solucion__c = solucion.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert casoCC;

        casoSac.Status = 'SAC_003';
        casoSac.SAC_StatusAuxiliar__c = 'SAC_003';
        update casoSac;


        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            Case casoCCAfter = [SELECT Id, RecordTypeId, ParentId, Status, SAC_MotivoReabrir__c, CC_Motivo__c FROM Case WHERE Subject = 'Caso de Contact Center para devolver al SAC' LIMIT 1];
            System.debug('CASO AF ' + casoCCAfter.Id);
            CC_EmailSendController.devolverCasoAlSAC('Motivo devolución', casoCCafter);
        }

        List<Case> casos = [SELECT Id, Status, CC_Motivo__c FROM Case WHERE Id = :casoSac.Id];
        Test.stopTest();
        System.assertEquals('Motivo devolución', casos.get(0).CC_Motivo__c);
        System.assertEquals('SAC_001', casos.get(0).Status);
    }

    @isTest
    private static void crearTareaGestor() {
        Test.startTest();
        Id recordTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id recordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

        CC_Lista_Valores__c lista = new CC_Lista_Valores__c ();
        lista.Name = 'Gestor por defecto CC';
        lista.RecordTypeId = recordTypeLista;
        insert lista;

        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c ();
        valor1.Name = 'ExternalID';
        valor1.RecordTypeId = recordTypeValor;
        valor1.CC_Lista__c = lista.Id;
        valor1.CC_Valor__c ='000000';
        valores.add(valor1);

        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c ();
        valor2.Name = 'Nombre';
        valor2.RecordTypeId = recordTypeValor;
        valor2.CC_Lista__c = lista.Id;
        valor2.CC_Valor__c ='Sin Gestor/EAP';
        valores.add(valor2);
        insert valores;

        //Cuentas cliente
        List<Account> accountsInsert = new List<Account>();
        Account cuentaCliente = new Account();
        cuentaCliente.LastName = 'Cliente Senior';
        cuentaCliente.CC_NumPerso__c = '0000012';
        cuentaCliente.AV_IndicadoresClientes__c = '01';
        cuentaCliente.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        accountsInsert.add(cuentaCliente);
        insert accountsInsert;

        //Casos
        List<Case> casosInsert = new List<Case>();
        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center';
        casoCC.Description = 'Caso de Contact Center';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Formulario web';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuentaCliente.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casosInsert.add(casoCC);
        insert casosInsert;

        CC_EmailSendController.crearTareaGestor(casoCC.Id, true, null, 'asunto tarea', '2022-06-20', 'comentarios tarea');
        Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'asunto tarea' AND AV_Case__c = :casoCC.Id];
        Test.stopTest();
        System.assert(!tarea.isEmpty());
    }

    @isTest
    private static void crearTareaGestorOficina() {
        Test.startTest();
        Id recordTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id recordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_Lista_Valores__c lista = new CC_Lista_Valores__c ();
        lista.Name = 'Gestor por defecto CC';
        lista.RecordTypeId = recordTypeLista;
        insert lista;

        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c ();
        valor1.Name = 'ExternalID';
        valor1.RecordTypeId = recordTypeValor;
        valor1.CC_Lista__c = lista.Id;
        valor1.CC_Valor__c ='000000';
        valores.add(valor1);

        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c ();
        valor2.Name = 'Nombre';
        valor2.RecordTypeId = recordTypeValor;
        valor2.CC_Lista__c = lista.Id;
        valor2.CC_Valor__c ='Sin Gestor/EAP';
        valores.add(valor2);
        insert valores;

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivoOficina = new CC_MCC__c(
            Name = 'Motivo Test Oficina',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001',
            CC_AmbitoTareas__c = 'Oficina'
        );
        insert motivoOficina;

        Account centro = new Account();
        centro.Name = 'Cliente Senior';
        centro.CC_Email__c = 'test@test.com';
        centro.CC_Numero_Oficina_Empresa__c = '000-14141';
        centro.CC_Numero_Oficina__c = '14141';
        centro.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert centro;

        //Cuentas cliente
        List<Account> accountsInsert = new List<Account>();
        Account cuentaCliente = new Account();
        cuentaCliente.LastName = 'Cliente Senior';
        cuentaCliente.CC_NumPerso__c = '0000012';
        cuentaCliente.AV_IndicadoresClientes__c = '28';
        cuentaCliente.AV_OficinaPrincipal__c = centro.Id;
        cuentaCliente.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        accountsInsert.add(cuentaCliente);
        insert accountsInsert;

        Case casoCCOficina = new Case();
        casoCCOficina.Subject = 'Caso de Contact Center';
        casoCCOficina.Description = 'Caso de Contact Center';
        casoCCOficina.CC_Idioma__c = 'es';
        casoCCOficina.Origin = 'Email';
        casoCCOficina.CC_Tipo_Contacto__c = 'Consulta';
        casoCCOficina.CC_Canal_Procedencia__c = 'Formulario web';
        casoCCOficina.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCCOficina.Status = 'Activo';
        casoCCOficina.AccountId = cuentaCliente.Id;
        casoCCOficina.CC_MCC_Tematica__c = tematica.Id;
        casoCCOficina.CC_MCC_ProdServ__c = producto.Id;
        casoCCOficina.CC_MCC_Motivo__c = motivoOficina.Id;
        casoCCOficina.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert casoCCOficina;
    	CC_EmailSendController.crearTareaGestor(casoCCOficina.Id, true, null, 'asunto tarea', '2022-06-20', 'comentarios tarea');
        Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'asunto tarea'];
        Test.stopTest();

        System.assert(!tarea.isEmpty());
    }

    @isTest
    private static void crearTareaGestorVenta() {
        Test.startTest();
        Id recordTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id recordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_Lista_Valores__c lista = new CC_Lista_Valores__c ();
        lista.Name = 'Gestor por defecto CC';
        lista.RecordTypeId = recordTypeLista;
        insert lista;

        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c ();
        valor1.Name = 'ExternalID';
        valor1.RecordTypeId = recordTypeValor;
        valor1.CC_Lista__c = lista.Id;
        valor1.CC_Valor__c ='000000';
        valores.add(valor1);

        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c ();
        valor2.Name = 'Nombre';
        valor2.RecordTypeId = recordTypeValor;
        valor2.CC_Lista__c = lista.Id;
        valor2.CC_Valor__c ='Sin Gestor/EAP';
        valores.add(valor2);
        insert valores;

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivoVentas = new CC_MCC__c(
            Name = 'Motivo Test Ventas',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000002',
            CC_AmbitoTareas__c = 'Ventas'
        );
        insert motivoVentas;

        Account centro = new Account();
        centro.Name = 'Cliente Senior';
        centro.CC_Email__c = 'test@test.com';
        centro.CC_Numero_Oficina_Empresa__c = '000-14141';
        centro.CC_Numero_Oficina__c = '14141';
        centro.CC_Tipo_Oficina__c = 'I';
        centro.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert centro;

        Contact contactoEmple = new Contact();
        contactoEmple.LastName = 'Cliente Senior';
        contactoEmple.FirstName = 'Prueba empleado';
        contactoEmple.CC_Inactivo__c = false;
        contactoEmple.Email = 'test@test.com';
        contactoEmple.CC_Matricula__c = 'U0124112';
        contactoEmple.AccountId = centro.Id;
        contactoEmple.AV_DescFuncion__c = 'DIRECCION';
        contactoEmple.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        insert contactoEmple;

        //Cuentas cliente
        List<Account> accountsInsert = new List<Account>();
        Account cuentaCliente = new Account();
        cuentaCliente.LastName = 'Cliente Senior';
        cuentaCliente.AV_EAPGestor__c = contactoEmple.Id;
        cuentaCliente.CC_NumPerso__c = '0000012';
        cuentaCliente.AV_IndicadoresClientes__c = '28';
        cuentaCliente.AV_OficinaPrincipal__c = centro.Id;
        cuentaCliente.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        accountsInsert.add(cuentaCliente);
        insert accountsInsert;

        Case casoCCVentas = new Case();
        casoCCVentas.Subject = 'Caso de Contact Center';
        casoCCVentas.Description = 'Caso de Contact Center';
        casoCCVentas.CC_Idioma__c = 'es';
        casoCCVentas.Origin = 'Email';
        casoCCVentas.CC_Tipo_Contacto__c = 'Consulta';
        casoCCVentas.CC_Canal_Procedencia__c = 'Formulario web';
        casoCCVentas.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCCVentas.Status = 'Activo';
        casoCCVentas.AccountId = cuentaCliente.Id;
        casoCCVentas.CC_MCC_Tematica__c = tematica.Id;
        casoCCVentas.CC_MCC_ProdServ__c = producto.Id;
        casoCCVentas.CC_MCC_Motivo__c = motivoVentas.Id;
        casoCCVentas.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert casoCCVentas;
    	CC_EmailSendController.crearTareaGestor(casoCCVentas.Id, true, null, 'asunto tarea', '2022-06-20', 'comentarios tarea');
        Task[] tarea = [SELECT Id FROM Task WHERE Subject = 'asunto tarea'];
        Test.stopTest();

        System.assert(!tarea.isEmpty());
    }

     @isTest
    private static void buscarEmpleadoOficina() {
        Test.startTest();
        //Cuentas cliente
        List<Account> accountsInsert = new List<Account>();
        Account cuentaEmple = new Account();
        cuentaEmple.Name = 'Cliente Senior';
        cuentaEmple.CC_NumPerso__c = '0000012';
        cuentaEmple.CC_Email__c = 'test@test.com';
        cuentaEmple.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        accountsInsert.add(cuentaEmple);
        insert accountsInsert;

        List<Contact> contactInsert = new List<Contact>();
        Contact contactoEmple = new Contact();
        contactoEmple.LastName = 'Cliente Senior';
        contactoEmple.FirstName = 'Prueba empleado';
        contactoEmple.CC_Inactivo__c = false;
        contactoEmple.Email = 'test@test.com';
        contactoEmple.AV_DescFuncion__c = 'DIRECCION';
        contactoEmple.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactInsert.add(contactoEmple);
        insert contactInsert;

        //Casos
        List<Case> casosInsert = new List<Case>();
        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center';
        casoCC.Description = 'Caso de Contact Center';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Servicios Centrales';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuentaEmple.Id;
        casoCC.ContactId = contactoEmple.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        casosInsert.add(casoCC);
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert casosInsert;
        }

        List<Map<String,String>> listaResult = new List<Map<String,String>>();
		List<Contact> listaEmpleados = new List<Contact>();
        List<Account> listaOficinas = new List<Account>();


        listaResult.add(CC_EmailSendController.buscarEmpleadoOficina(String.valueOf(cuentaEmple.Id), cuentaEmple.CC_Email__c, cuentaEmple.Name, true, contactoEmple.Id, null));
        listaResult.add(CC_EmailSendController.buscarEmpleadoOficina(String.valueOf(contactoEmple.Id), cuentaEmple.CC_Email__c, cuentaEmple.Name, false, contactoEmple.Id, null));
        listaEmpleados = CC_EmailSendController.buscarEmpleado('Prueba');
        listaOficinas = CC_EmailSendController.buscarOficina('Senior', '');
        Test.stopTest();

        System.assertEquals(2, listaResult.size());
        /*System.assertEquals(1, listaEmpleados.size());
        System.assertEquals(1, listaOficinas.size());*/

    }

    @isTest
    private static void obtenerPlantillasOficina() {
        Test.startTest();
        Id recordTypeLista = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id recordTypeValor = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

        CC_Lista_Valores__c lista = new CC_Lista_Valores__c ();
        lista.Name = 'CC_Relacion_plantilla_Objeto';
        lista.RecordTypeId=recordTypeLista;

        insert lista;

        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c ();
        valor1.Name = 'valor1';
        valor1.RecordTypeId = recordTypeValor;
        valor1.CC_Lista__c = lista.Id;
        valor1.CC_Valor_SFDC__c = 'plantilla1';
        valor1.CC_Servicio__c = 'trasladar';
        valor1.CC_Valor2__c = 'CC_Empleado';
        valor1.CC_Valor__c ='CC_CentroCaixaBank';

        valores.add(valor1);

        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c ();
        valor2.Name = 'valor1';
        valor2.RecordTypeId = recordTypeValor;
        valor2.CC_Lista__c = lista.Id;
        valor2.CC_Valor_SFDC__c = 'plantilla1';
        valor2.CC_Servicio__c = 'trasladar';
        valor2.CC_Valor2__c = 'CC_Empleado';
        valor2.CC_Valor__c ='CC_CentroCaixaBank';
        insert valores;


        List<Account> accountsInsert = new List<Account>();
        Account cuentaEmple = new Account();
        cuentaEmple.Name = 'Cliente Senior';
        cuentaEmple.CC_NumPerso__c = '0000012';
        cuentaEmple.CC_Email__c = 'test@test.com';
        cuentaEmple.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        accountsInsert.add(cuentaEmple);

        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert accountsInsert;
        }

        List<Contact> contactInsert = new List<Contact>();
        Contact contactoEmple = new Contact();
        contactoEmple.LastName = 'Cliente Senior';
        contactoEmple.Email = 'test@test.com';
        contactoEmple.AV_DescFuncion__c = 'DIRECCION';
        contactoEmple.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactInsert.add(contactoEmple);
        insert contactInsert;

        //Casos
        List<Case> casosInsert = new List<Case>();
        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center';
        casoCC.Description = 'Caso de Contact Center';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Servicios Centrales';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuentaEmple.Id;
        casoCC.ContactId = contactoEmple.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        casosInsert.add(casoCC);
        insert casosInsert;

        List<List<CC_EmailSendController.pickListWrapper>> listaResult = new List<List<CC_EmailSendController.pickListWrapper>>();



        listaResult.add(CC_EmailSendController.getPlantillaOficinaList(cuentaEmple.Id,'trasladar','CC_Empleado',Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId()));
        listaResult.add(CC_EmailSendController.getPlantillaEmpleadoList(cuentaEmple.Id,'trasladar','CC_Empleado',Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId()));
        Test.stopTest();


        System.assertEquals(2 , listaResult.size());

    }

    @isTest
    private static void getCuentaConfidencial() {
        Test.startTest();
        List<Account> cuentas = new List<Account>();
        Account cuenta = new Account(
            Name = 'Cuenta Test Confidencial',
            CC_Email__c = 'cuenta@test.com',
            CC_NumPerso__c = '123456'
        );
        cuentas.add(cuenta);

        Account cuentaConfidencial = new Account(
            Name = 'Cuenta Test Confidencial AV',
            CC_Email__c = 'cuenta@test.com',
            AV_NumPerso__c = '123456'
        );
        cuentas.add(cuentaConfidencial);

        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert cuentas;
        }

		String accountId = [SELECT Id FROM Account WHERE Name = 'Cuenta Test Confidencial' LIMIT 1].Id;

        Account cuentaFinal = new Account();
         cuentaFinal = CC_EmailSendController.getCuentaConfidencial(accountId);
         System.assertEquals(cuentaFinal.Id , cuentaFinal.Id);
         Test.stopTest();
    }

    @isTest
    private static void llamadaEnvioPoseidon() {

        List<CBK_IntegrationSetting__c> integracionSettings = new List<CBK_IntegrationSetting__c>();
        CBK_IntegrationSetting__c envio = new CBK_IntegrationSetting__c();
        envio.Name = 'CC_MCD_Envio_PUSH';
        envio.RegistroTrazaIntegracion__c = true;
        envio.NamedCredential__c = 'callout:MyIntegrationTest';
        integracionSettings.add(envio);

        CBK_IntegrationSetting__c enrollment = new CBK_IntegrationSetting__c();
        enrollment.Name = 'CC_MCD_Gestion_PUSH_uuIds';
        enrollment.RegistroTrazaIntegracion__c = false;
        enrollment.NamedCredential__c = 'callout:MyIntegrationTest';
        integracionSettings.add(enrollment);

        insert integracionSettings;

        List<Account> accountsInsert = new List<Account>();
        Account cuentaEmple = new Account();
        cuentaEmple.Name = 'Cliente Senior';
        cuentaEmple.CC_NumPerso__c = '0000012';
        cuentaEmple.CC_Email__c = 'test@test.com';
        cuentaEmple.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        accountsInsert.add(cuentaEmple);

        insert accountsInsert;

        List<Contact> contactInsert = new List<Contact>();
        Contact contactoEmple = new Contact();
        contactoEmple.LastName = 'Cliente Senior';
        contactoEmple.Email = 'test@test.com';
        contactoEmple.AV_DescFuncion__c = 'DIRECCION';
        contactoEmple.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactInsert.add(contactoEmple);

        insert contactInsert;

        //Casos
        List<Case> casosInsert = new List<Case>();
        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center';
        casoCC.Description = 'Caso de Contact Center';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Servicios Centrales';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuentaEmple.Id;
        casoCC.ContactId = contactoEmple.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        casosInsert.add(casoCC);
        insert casosInsert;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoEnroll());
        System.runAs ( new User(Id = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            Test.startTest();
            Boolean resultadoPoseidon = CC_EmailSendController.envioPoseidon(casoCC.Id, 'IMAGIN', '12345', 'textoPublico', 'textoPrivado', 'asunto', 'deeplink', casoCC.CC_Idioma__c, 'titulo', 'sobreTitulo', 'textoBoton', '');
            Test.stopTest();
            System.assertEquals(resultadoPoseidon, true, 'La solicitud del enrollment no ha funcionado como se esperaba.');
            //System.assertEquals();
        }

    }

    @isTest
    private static void llamadaEnrollmentPoseidon() {
        Test.startTest();

        List<CBK_IntegrationSetting__c> integracionSettings = new List<CBK_IntegrationSetting__c>();
        CBK_IntegrationSetting__c envio = new CBK_IntegrationSetting__c();
        envio.Name = 'CC_MCD_Envio_PUSH';
        envio.RegistroTrazaIntegracion__c = true;
        envio.NamedCredential__c = 'callout:MyIntegrationTest';
        integracionSettings.add(envio);

        CBK_IntegrationSetting__c enrollment = new CBK_IntegrationSetting__c();
        enrollment.Name = 'CC_MCD_Gestion_PUSH_uuIds';
        enrollment.RegistroTrazaIntegracion__c = false;
        enrollment.NamedCredential__c = 'callout:MyIntegrationTest';
        integracionSettings.add(enrollment);

        insert integracionSettings;

        List<Account> accountsInsert = new List<Account>();
        Account cuentaEmple = new Account();
        cuentaEmple.Name = 'Cliente Senior';
        cuentaEmple.CC_NumPerso__c = '0000012';
        cuentaEmple.CC_Email__c = 'test@test.com';
        cuentaEmple.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        accountsInsert.add(cuentaEmple);

        insert accountsInsert;


        List<Contact> contactInsert = new List<Contact>();
        Contact contactoEmple = new Contact();
        contactoEmple.LastName = 'Cliente Senior';
        contactoEmple.Email = 'test@test.com';
        contactoEmple.AV_DescFuncion__c = 'DIRECCION';
        contactoEmple.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactInsert.add(contactoEmple);

        insert contactInsert;

        //Casos
        List<Case> casosInsert = new List<Case>();
        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center';
        casoCC.Description = 'Caso de Contact Center';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Servicios Centrales';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuentaEmple.Id;
        casoCC.ContactId = contactoEmple.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        casosInsert.add(casoCC);
        insert casosInsert;

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseErrorEnroll());
        System.runAs ( new User(Id = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            List<CC_EmailSendController.CustomWrappedObj> resultadoEnrollment = CC_EmailSendController.validarEnrollment('12345');

            System.assertEquals(resultadoEnrollment[0].app == 'IMAGIN', false, 'La solicitud del enrollment no ha funcionado como se esperaba.');
        }
        Test.stopTest();
    }

    private class MockHttpResponseExitoEnroll implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('[AD6572B4-5322-3B7B-85EF-DEF4FE907602]');
            res.setStatusCode(200);
            return res;
        }
    }

    private class MockHttpResponseErrorEnroll implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            res.setBody('[AD6572B4-5322-3B7B-85EF-DEF4FE907602]');
            res.setStatusCode(404);
            return res;
        }
    }

    @isTest
    private static void getDeeplinkTest() {
        Test.startTest();
        List<Account> accountsInsert = new List<Account>();
        Account cuentaEmple = new Account();
        cuentaEmple.Name = 'Cliente Senior';
        cuentaEmple.CC_NumPerso__c = '0000012';
        cuentaEmple.CC_Email__c = 'test@test.com';
        cuentaEmple.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        accountsInsert.add(cuentaEmple);

        insert accountsInsert;


        List<Contact> contactInsert = new List<Contact>();
        Contact contactoEmple = new Contact();
        contactoEmple.LastName = 'Cliente Senior';
        contactoEmple.Email = 'test@test.com';
        contactoEmple.AV_DescFuncion__c = 'DIRECCION';
        contactoEmple.RecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactInsert.add(contactoEmple);

        insert contactInsert;

        //Casos
        List<Case> casosInsert = new List<Case>();
        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center';
        casoCC.Description = 'Caso de Contact Center';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Servicios Centrales';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC.CC_Canal_Operativo__c = 	'App BrokerNow';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuentaEmple.Id;
        casoCC.ContactId = contactoEmple.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        casosInsert.add(casoCC);
        insert casosInsert;

        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();


        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;

        CC_Deeplink__c deeplink = new CC_Deeplink__c(CC_App__c = 'Imagin', CC_Asunto_Cas__c = 'AsuntoTest' , CC_Deeplink__c = 'testDeeplink', CC_TextoPrivado_Cas__c = 'txt privado', CC_TextoPublico_Cas__c = 'txt publico');
        insert deeplink;

        CC_MCC_Poseidon__c mccPoseidon = new CC_MCC_Poseidon__c(CC_Deeplink__c = deeplink.Id, CC_MCC__c = motivo.Id);
        insert mccPoseidon;

        System.runAs ( new User(Id = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1].Id) ) {

            List<String> apps = new List<String>();
            apps.add('IMAGIN');
            CC_Deeplink__c obtenerDatosSeleccionadoResult = CC_EmailSendController.obtenerDatosSeleccionado(deeplink.Id);

            List<CC_EmailSendController.PickListWrapper> getDeeplinksResult = CC_EmailSendController.getDeeplinks(motivo.Id, casoCC.CC_Canal_Operativo__c, apps, 'es');
            Test.stopTest();

            System.assertEquals(deeplink.CC_App__c, obtenerDatosSeleccionadoResult.CC_App__c, 'No se ha recuperado el registro específico que ha sido seleccionado.');
            System.assertEquals(getDeeplinksResult.size(), 1, 'No se han recuperado los registros del objeto CC_Deeplink__c');
        }
    }

    @isTest
    private static void oficinaPermiteTrasladarRemitir() {
        Test.startTest();
        Id listaValoresId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id valorId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        Id recordTypeIdCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();

        CC_Lista_Valores__c listaOficinas = new CC_Lista_Valores__c(
            Name = 'Centros CaixaBank que no permiten remitidos o traslados',
            RecordTypeId = listaValoresId
        );
        insert listaOficinas;

        CC_Lista_Valores__c grupo = new CC_Lista_Valores__c(
            Name = '16450 - OFICINAS DIGITALES',
            CC_Valor__c = '16450',
            CC_Activa__c = true,
            RecordTypeId = valorId,
            CC_Lista__c = listaOficinas.Id
        );
        insert grupo;

        Account cuentaGC = new Account(
            Name = '16450 - OFICINAS DIGITALES',
            CC_Tipo_Centro__c = 'OF',
            RecordTypeId = recordTypeIdCentro,
            CC_Numero_Oficina__c = '16450',
            CC_Numero_Oficina_Empresa__c = '001-16450'
        );
        insert cuentaGC;

        Account cuentaCliente = new Account();
        cuentaCliente.LastName = 'Cliente Senior';
        cuentaCliente.CC_NumPerso__c = '0000012';
        cuentaCliente.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        cuentaCliente.AV_OficinaPrincipal__c = cuentaGC.Id;
        insert cuentaCliente;

        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center';
        casoCC.Description = 'Caso de Contact Center';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Accionista';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC.CC_Canal_Operativo__c = 	'App BrokerNow';
        casoCC.Status = 'Activo';
        casoCC.OwnerId = [SELECT Id FROM User LIMIT 1].Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casoCC.AccountId = cuentaCliente.Id;

        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert casoCC;
        }

        Boolean estado = CC_EmailSendController.oficinaPermiteTrasladarRemitir(casoCC.Id, true, '');
        Test.stopTest();

        System.assertEquals(false, estado, 'No se puede realizar la operativa con esa oficina');

    }

    @isTest
    public static void cambiarPropietarioTransfer() {
        Test.startTest();
        List<Group> ownerLst = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Buzon_Usuario_Publico' LIMIT 1];
        List<Group> ownerLst2 = [SELECT Id FROM Group WHERE DeveloperName = 'CC_ConsForm_Tarjetas_Comercios' LIMIT 1];
        Case caso = new Case(
            Status = 'Activo',
            CC_En_Segundo_Nivel__c = true,
            OwnerId = ownerLst[0].Id,
            CC_Tipo_Cliente__c = 'Cliente',
            Origin = 'Email',
			CC_Fecha_Traslado_2N__c = Date.today(),
            CC_Tipo_Contacto__c = 'Consulta',
            CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
            CC_Grupo_Transfer__c = ownerLst[0].Id,
            CC_Resolucion2Nivel__c = 'test',
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId()
        );
		System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
            insert caso;
            caso.Description = 'test';
            update caso;
        }
        CC_EmailSendController.devolver(caso.Id, '', 'devolver', false);
        Case casoAct = [SELECT OwnerId, CC_En_Segundo_Nivel__c, CC_Grupo_Transfer__c FROM Case WHERE Id = :caso.Id LIMIT 1];
        Test.stopTest();

        system.assertEquals(ownerLst[0].Id, casoAct.OwnerId, 'El OwnerId se ha actualizado correctamente');

    }

    @isTest
    public static void buscarGrupos2N() {
        Test.startTest();
        User operador = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1];
        Id recordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Segundo_Nivel').getRecordTypeId();
        System.runAs (operador){
            CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(
                Name = 'buscar grupos 2N',
                CC_External__c = 'GC-00001',
                RecordTypeId = recordTypeId,
                OS_Negocio__c = 'CC',
                CC_Queue_Traslado__c = 'test'
            );
            insert grupo;
        }
        List<CC_Grupo_Colaborador__c> grupos = CC_EmailSendController.buscarGrupos2N('buscar');
        Test.stopTest();
        system.assertEquals(grupos.size() > 0, true, 'Ha encontrado resultados');
    }

    @isTest
    public static void validacionParametroDeeplinkTest() {
        Test.startTest();
        User operador = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1];
        CC_EmailSendController.ParametrosDeeplinkWrapper parametross = new CC_EmailSendController.ParametrosDeeplinkWrapper(false, '', 0);

        CC_Deeplink__c deeplink = new CC_Deeplink__c(
            CC_Asunto_Cas__c = 'Consulta activación tarjeta',
            CC_App__c = 'CaixaBank'
        );
        insert deeplink;

        System.runAs (operador) {
        List<CC_Lista_Valores__c> listas = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c lista1 = new CC_Lista_Valores__c(
            Name = 'Deeplinks dinamicos',
            CC_Activa__c = true,
            RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId()
        );
        listas.add(lista1);

        CC_Lista_Valores__c lista2 = new CC_Lista_Valores__c(
            Name = 'Parametros Deeplink',
            CC_Activa__c = true,
            RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId()
        );
        listas.add(lista2);
        insert listas;

        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c (
            CC_Lista__c = lista1.Id,
            Name = 'Consulta activación tarjeta',
            CC_Valor_SFDC__c = 'Consulta activación tarjeta',
            CC_Valor__c = 'Consulta activación tarjeta',
            CC_Valor2__c =  'Tarjeta',
            CC_Activa__c = true,
            RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId()
        );
        valores.add(valor1);

        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c (
            CC_Lista__c = lista2.Id,
            Name = 'Tarjeta',
            CC_Valor_SFDC__c = 'Tarjeta',
            CC_Valor__c = 'Tarjeta',
            CC_Valor2__c =  '4',
            CC_Activa__c = true,
            RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId()
        );
        valores.add(valor2);
        insert valores;
        }

        //List<CC_Lista_Valores__c> lista = [SELECT Name FROM CC_Lista_Valores__c WHERE CC_Valor__c = :deeplink.CC_Asunto_Cas__c];
        CC_EmailSendController.ParametrosDeeplinkWrapper parametros = CC_EmailSendController.validacionParametroDeeplink(deeplink.Id);
        Test.stopTest();
        System.assertEquals(true, parametros.bool);
        System.assertEquals('Tarjeta', parametros.valorLabel);
        System.assertEquals(4, parametros.valor2);
    }

    @isTest
    public static void cambiarPropietarioEntreColas() {
        Test.startTest();
        User operador = [SELECT Id FROM User Where LastName = 'Operador Empleado' LIMIT 1];
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case(
        Status = 'Activo',
        OwnerId = operador.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        Origin = 'Email',
        CC_Tipo_Contacto__c = 'Consulta',
        CC_Canal_Procedencia__c = 'Formulario Consultas Operativas',
        RecordTypeId = recordTypeId
        );

        System.runAs(operador) {
            insert caso;
        }

        List<QueueSobject> listaColas = CC_EmailSendController.buscarColasTransfer('Build');
        CC_EmailSendController.cambiarPropietarioTransferApex(caso.Id, listaColas[0].QueueId);
        Case casoAct = [SELECT OwnerId FROM Case WHERE Id = :caso.Id LIMIT 1];
        Test.stopTest();
        System.assertEquals(casoAct.OwnerId, listaColas[0].QueueId, 'El proceso ha funcionado correctamente');
    }

    @isTest
    public static void devolverMensaje() {
        Test.startTest();
        User operador = [SELECT Id FROM User Where Name = 'Administrador de sistema' LIMIT 1];
        Id recordTypeIdCentro = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        Account cuentaGC;
        System.runAs(operador) {
            cuentaGC = new Account(
            Name = '16450 - OFICINAS DIGITALES',
            CC_Tipo_Centro__c = 'OF',
            RecordTypeId = recordTypeIdCentro,
            CC_Numero_Oficina__c = '16450',
            CC_Numero_Oficina_Empresa__c = '001-16450'
        );
        insert cuentaGC;
        }
        Test.stopTest();
        System.assertNotEquals(CC_EmailSendController.devolverMensaje(cuentaGC.Id), null, 'El proceso ha funcionado correctamente');
    }

    @isTest
    public static void getMostrarBotonOficinaEmpleadoCaixaBank() {
        Test.startTest();
        User operador = [SELECT Id FROM User Where Name = 'Administrador de sistema' LIMIT 1];
        System.runAs(operador) {
            Map<String, Object> resultado = CC_EmailSendController.getMostrarBotonOficinaEmpleadoCaixaBank();
            System.assertEquals(true, resultado.get('mostrarBoton'));
        }
        Test.stopTest();
    }

    @isTest
    public static void comprobarVisibilidadBotonTareaCitaGestor() {
        Test.startTest();
        User operador = [SELECT Id FROM User Where Name = 'Administrador de sistema' LIMIT 1];
        System.runAs(operador) {
                Map<String, Boolean> resultado = CC_EmailSendController.comprobarVisibilidadBotonTareaCitaGestor();
                System.assertEquals(true, resultado.get('botonCita'));
                System.assertEquals(true, resultado.get('botonTarea'));
            }
            Test.stopTest();
    }

    @isTest
    public static void reiniciarDerivar() {
        Test.startTest();
        User operador = [SELECT Id FROM User Where Name = 'Administrador de sistema' LIMIT 1];
        System.runAs(operador) {

        Case caso = new Case(
        Status = 'Activo',
        CC_Derivar__c =false
        );
        insert caso;
        Case casoOriginal = [SELECT CC_Derivar__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(false, casoOriginal.CC_Derivar__c);

        CC_EmailSendController.reiniciarDerivar(caso.Id);

        Case casoActualizado = [SELECT CC_Derivar__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(true, casoActualizado.CC_Derivar__c);

        Test.stopTest();
        }
    }


    @isTest
    public static void mostrarToastPoseidon() {
        Test.startTest();
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;

        Case caso = new Case(
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }

        CC_Deeplink__c deeplink = new CC_Deeplink__c(
            CC_App__c = 'Imagin', CC_Asunto_Cas__c = 'AsuntoTest' ,
            CC_Deeplink__c = 'testDeeplink',
            CC_TextoPrivado_Cas__c = 'txt privado',
            CC_TextoPublico_Cas__c = 'txt publico',
            CC_TituloConsentimientoCliente__c = 'Título de consentimiento',
            CC_CuerpoConsentimientoCliente__c = 'Cuerpo de consentimiento'
            );
        insert deeplink;

        CC_MCC_Poseidon__c poseidon = new CC_MCC_Poseidon__c(
            CC_MCC__c = caso.CC_MCC_Motivo__c, CC_Deeplink__c = deeplink.id
        );
        insert poseidon;

        Map<String, String> resultado = CC_EmailSendController.mostrarToastPoseidon(caso.Id);

        System.assertEquals('Título de consentimiento', resultado.get('titulo'));
        System.assertEquals('Cuerpo de consentimiento', resultado.get('cuerpo'));
        Test.stopTest();

    }

    // Test para el método obtenerCCLink
    @isTest
    public static void testObtenerCCLink() {
        Test.startTest();
        Id tematicaId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id productoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id motivoId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test2',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
        );
        insert tematica;
        CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test2',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
        );
        insert producto;
        CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test2',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Link__c = 'https://test.com',
            CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;

        Case caso = new Case(
            CC_MCC_Tematica__c = tematica.Id,
            CC_MCC_ProdServ__c = producto.Id,
            CC_MCC_Motivo__c = motivo.Id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web'
        );
        System.runAs ( new User(Id = [SELECT Id FROM User Where LastName = 'Administrador de sistema' LIMIT 1].Id) ) {
        	insert caso;
        }
       // Crear lista de valores para la prueba de obtenerValorDesdeMccMotivo
       CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
       listaValores.Name = 'Test MCC';
       listaValores.CC_Valor__c = 'Valor Test';
       insert listaValores;

        // Obtener el ID del MCC Motivo
        CC_MCC__c mccMotivo2 = [SELECT Id FROM CC_MCC__c WHERE Name = 'Motivo Test2' LIMIT 1];

        // Llamar al método obtenerCCLink
        String link = CC_EmailSendController.obtenerCCLink(mccMotivo2.Id);
        Test.stopTest();

        // Verificar que el link devuelto es correcto
        System.assertEquals('https://test.com', link, 'El enlace del MCC Motivo debe coincidir con el valor insertado');
    }
}