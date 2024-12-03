@isTest
public class HDT_Case_BU_TRHan_Test {

    @TestSetup
    static void makeData() {
        //Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'HDT_Usuario_CaixaBank'].Id;
        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HDT_Operador'];

        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileIdAdmin;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211';
        usuario1.Email = 'aalsdna@kfsb.com';
        usuario1.Username = 'tuser0001@amamama.com' + System.currentTimeMillis();
        usuario1.CompanyName = 'MST';
        usuario1.Title = 'title';
        usuario1.Alias = 'alias';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';

        userList.add(usuario1);

        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'HDT'];
        //crear usuarios CC



        User usuario2 = new User();
        usuario2.ProfileId = profileId;
        usuario2.FirstName = 'first2';
        usuario2.LastName = 'last2';
        usuario2.Email = 'tuser000@amamama.com';
        usuario2.Username = 'tuser002@amamama.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'DXC';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        userList.add(usuario2);

        User usuario3 = new User();
        usuario3.ProfileId = profileId;
        usuario3.FirstName = 'first3';
        usuario3.LastName = 'last3';
        usuario3.Email = 'tuser000@amamama.com';
        usuario3.Username = 'tuser003@amamama.com' + System.currentTimeMillis();
        usuario3.CompanyName = 'INDRA';
        usuario3.Title = 'title';
        usuario3.Alias = 'alias';
        usuario3.TimeZoneSidKey = 'Europe/Paris';
        usuario3.EmailEncodingKey = 'UTF-8';
        usuario3.LanguageLocaleKey = 'es';
        usuario3.LocaleSidKey = 'es_ES';
        userList.add(usuario3);
        insert userList;

        System.runAs(usuario1){

            User usuario = new User();
            usuario.ProfileId = profileId;
            usuario.FirstName = 'first 11212';
            usuario.LastName = 'last1';
            usuario.Email = 'tuser000@amamama.com';
            usuario.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            usuario.CompanyName = 'MST';
            usuario.Title = 'title';
            usuario.Alias = 'alias';
            usuario.TimeZoneSidKey = 'Europe/Paris';
            usuario.EmailEncodingKey = 'UTF-8';
            usuario.LanguageLocaleKey = 'es';
            usuario.LocaleSidKey = 'es_ES';
            usuario.UserRoleId = rolId.Id;
            insert usuario;
        }

        insert new PermissionSetAssignment(AssigneeId = usuario1.Id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario3.Id, PermissionSetId = ps.Id);

        /************************/

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

                List <String> owaEmails = new List<String>{('Atención Empleados Contact Center IT Grupo CaixaBank')};

        List <OrgWideEmailAddress> owa = new List <OrgWideEmailAddress>([SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName IN : owaEmails]);

        HDT_Parametros__c params = new HDT_Parametros__c();
        params.Name = 'HDT_Email_Respuesta_Empleados_New';
        params.HDT_Configuracion_1__c = owa[0].Address;
        params.HDT_Configuracion_2__c = owa[0].Address;
        insert params;




        
        //Creación nueva cuenta
       Account cuenta = new Account();
       cuenta.recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
       cuenta.Name = 'Smith';
       cuenta.CC_Numero_Documento__c = '64850344G';
       insert cuenta;

       Contact contacto = new Contact();
            contacto.recordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
            contacto.LastName = 'Smith';
            contacto.CC_Numero_Documento__c = '64850344G';
            contacto.AccountId = cuenta.Id;
        	contacto.CC_Matricula__c = 'U011152';
            insert contacto;

            User usuario = HDT_TestDataFactory.usuarioPruebasHdt();

            }
        }

        

    }

    @isTest
    public static void testBU() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        //Creación nueva cuenta
        Account cuenta = new Account(Name='Cuenta');
        insert cuenta;

        //Creación nuevo contacto asociado a la cuenta anterior
        Contact contacto = new Contact(LastName='Contacto', AccountId=cuenta.Id);
        insert contacto;

        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

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

        //Creación nuevo caso asociado al contacto anterior
        Case caso = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente', Origin = 'Phone', CC_Tipo_Contacto__c = 'Consulta', recordTypeId = recordCaso,
        CC_Canal_Procedencia__c = 'Servicios Centrales',CC_MCC_Motivo__c = mcc2.Id,CC_MCC_ProdServ__c = mcc1.Id,CC_MCC_Tematica__c = mcc.Id,
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta', CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución');
        insert caso;

        SocialPost socialPost = new SocialPost(
        Name = 'Name',
        ParentId = caso.Id,
        Provider = 'Other');
        insert socialPost;

        SocialPersona persona = New SocialPersona();
        persona.Name = 'oscar';
        persona.RealName = 'Oscar';
        persona.Provider='Other';
        persona.ParentId = socialPost.Id;
        insert persona;

        caso.CC_Social_Persona__c = persona.Id;
        update caso;

        //Creación nueva tarea ABIERTA asociada al caso anterior
        Task tarea = new Task(WhatId=caso.Id, Status='Pendiente');
        insert tarea;

        //Modificación de la tarea anterior para cerrarla
        tarea.Status = 'Completado';
        update tarea;

        //Intentamos cerrar el caso nuevamente
        caso.Status = 'Cerrado';
        update caso;

        /* En esta ocasión el caso sí se cierra al no tener ninguna tarea abierta */
        List<Case> casosCerrados = [SELECT Id FROM Case WHERE Id = :caso.Id AND Status = 'Cerrado'];
        System.assertEquals(casosCerrados.size(), 1);

        }
    }

    @isTest
    public static void testAgrupadoresInactivos() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        CC_Agrupador__c ag = new CC_Agrupador__c();
        ag.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        ag.CC_Titulo__c = 'Prueba';
        ag.CC_Estado__c = 'Activo';
		ag.CC_Descripcion__c = 'Prueba TEST';
        ag.CC_CanalEntrada__c = 'Twitter';
        ag.CC_CanalProcedencia__c = 'ImaginBank';
        ag.CC_Fecha_Cierre__c =  Datetime.valueOf(system.now());
        insert ag;

        Case c = new Case(Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente', Origin = 'Chat', CC_Tipo_Contacto__c = 'Consulta', CC_Agrupador_Id__c =ag.Id,
        CC_Canal_Procedencia__c = 'App',
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta', CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución');
        insert c;

        Map<Id, Case> mapOldObj = new Map<Id, Case>();
        mapOldObj.put(c.Id, c);

        List<Case> listNewObj = new List<Case>{c};

        Test.startTest();
            HDT_Case_BU_TRHan.agrupadoresInactivos(mapOldObj, listNewObj);
        Test.stopTest();

        // Verificar el resultado
        List<Case> casos = [SELECT Id, CC_Agrupador_Id__c, Status FROM Case WHERE Id = :c.Id];
        System.assertEquals(ag.Id, casos[0].CC_Agrupador_Id__c);
        System.assertEquals('Activo', casos[0].Status);
        }
    }

   @isTest
    public static void generarURLLimeSurveyTest(){

        Account cuenta = [Select Id from Account where CC_Numero_Documento__c = '64850344G'];
        Contact contacto = [Select Id from Contact where CC_Matricula__c = 'U011152'];
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;

        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;

        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Empleado';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
       insert mccMotivo;

        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Empleado';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
       insert mccCausa;
        CC_MCC__c solucion = new CC_MCC__c();
        solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
        solucion.Name = 'Actualizar Sistema';
        solucion.CC_Tipo_Cliente__c = 'Empleado';
        solucion.CC_Causa__c = mccCausa.Id;
        solucion.CC_Codigo_Externo__c = 'CA-000002';
        insert solucion;
        
        
		CC_Lista_Valores__c lovAvisosSobreAgrupadores = new CC_Lista_Valores__c();
        lovAvisosSobreAgrupadores.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovAvisosSobreAgrupadores.CC_Activa__c = true;
        lovAvisosSobreAgrupadores.Name = 'Avisos sobre agrupadores';
        insert lovAvisosSobreAgrupadores;

        CC_Lista_Valores__c valorUmbralPrimerAviso = new CC_Lista_Valores__c();
        valorUmbralPrimerAviso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralPrimerAviso.CC_Activa__c = true;
        valorUmbralPrimerAviso.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralPrimerAviso.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral primer aviso';
        valorUmbralPrimerAviso.CC_Valor__c = '2';
        CC_Lista_Valores__c valorUmbralSiguientesAvisos = new CC_Lista_Valores__c();
        valorUmbralSiguientesAvisos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        valorUmbralSiguientesAvisos.CC_Activa__c = true;
        valorUmbralSiguientesAvisos.CC_Lista__c = lovAvisosSobreAgrupadores.Id;
        valorUmbralSiguientesAvisos.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('CC_Agrupador__c', 'CC_Incidencia') + ' - Umbral siguientes avisos';
        valorUmbralSiguientesAvisos.CC_Valor__c = '50';

        List<CC_Lista_Valores__c> valorUmbralInsert = new List<CC_Lista_Valores__c>();
        valorUmbralInsert.add(valorUmbralPrimerAviso);
        valorUmbralInsert.add(valorUmbralSiguientesAvisos);
    	insert valorUmbralInsert;
        

        CC_Envio_Encuesta__c encuesta3 = new CC_Envio_Encuesta__c();
		encuesta3.Name = 'CC_URL_Encuesta';
		encuesta3.CC_Id_Encuesta__c = '687532';
		encuesta3.CC_Link_LimeSurvey__c = 'https://opina.caixabank.com/index.php?r=survey/index&';
       insert encuesta3;

        Case caso = new Case();
        caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Canal_Operativo__c = 'App Imagin';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.CC_MCC_Solucion__c = solucion.Id;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Origin = 'Chat';
       insert caso;

        Case caso2 = new Case();
        caso2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso2.Status = 'Activo';
        caso2.CC_Idioma__c = 'es';
        caso2.Subject = 'Asunto';
        caso2.Description = 'Descripción';
        caso2.CC_Canal_Operativo__c = 'App Imagin';
        caso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.CC_MCC_Causa__c = mccCausa.Id;
        caso2.CC_MCC_Solucion__c = solucion.Id;
        caso2.AccountId = cuenta.Id;
        caso2.ContactId = contacto.Id;
        caso2.Origin = 'Phone';
       insert caso2;

        //Creación nueva tarea ABIERTA asociada al caso anterior
        Task tarea = new Task(WhatId=caso.Id, Status='Open', Type = 'Traslado Tercer Nivel');
        insert tarea;

        //Crear Agrupador incidencia

        Test.startTest();

 		 CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        agrupador.CC_Titulo__c = 'Prueba';
        agrupador.CC_Estado__c = 'Activo';
		agrupador.CC_Descripcion__c = 'Prueba TEST';
        agrupador.CC_CanalEntrada__c = 'Twitter';
        agrupador.CC_CanalProcedencia__c = 'ImaginBank';
        agrupador.CC_Fecha_Cierre__c =  Datetime.valueOf(system.now());
        insert agrupador;
        CC_PlantillaAsociada__c plantillaAgrupador = new CC_PlantillaAsociada__c();
        plantillaAgrupador.CC_Agrupador__c = agrupador.Id;
        plantillaAgrupador.CC_Idioma__c = 'es';
        plantillaAgrupador.CC_Tipo_Cliente__c = 'Empleado';
        plantillaAgrupador.CC_CuerpoNotificacion__c = 'Cuerpo email';
        plantillaAgrupador.CC_Revisada__c = true;
       insert plantillaAgrupador;

        caso.CC_Agrupador_Id__c = agrupador.Id;
        caso.Status= 'Pendiente Incidencia';
        update caso;

        tarea.Status = 'Completed';
        update tarea;


        List<Case> listCasos = new List<Case>();
        listCasos.add(caso);
        listCasos.add(caso2);

        Set<Id> setIdsCasos = new Set<Id>();
        setIdsCasos.add(caso.Id);

        List<ID> listaAgrupadores = new List<ID>();
        listaAgrupadores.add(agrupador.Id);

        
        User pruebas = [SELECT Id FROM User WHERE LastName = 'last211' LIMIT 1];
        //user usuario = [select id from user WHERE Name = 'HDT_Usuario_CaixaBank'];
        System.runAs(pruebas){

            caso.Status = 'Cerrado';
            update caso;
            HDT_Case_BU_TRHan.generarURLLimeSurvey(listCasos,setIdsCasos);

            //CC_Agrupador.cierreAgrupador(listaAgrupadores);
            Case c = [SELECT Id, CC_URL_Encuesta_3N__c, Status FROM Case WHERE Id =: caso.Id LIMIT 1];
            Case c2 = [SELECT Id, CC_URL_Encuesta_3N__c, Status FROM Case WHERE Id =: caso2.Id LIMIT 1];
        
        Test.stopTest();

           System.assertEquals(caso2.Status, c2.Status, 'No se ha cerrado el caso.');
            System.assertEquals(caso2.CC_URL_Encuesta_3N__c, c2.CC_URL_Encuesta_3N__c, 'No se ha informado el valor del campo de la encuesta 3N.');
        }
    }

    @isTest
    public static void enmascararPANBeforeInsert() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        // Alta de datos para la prueba
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto 1234567898765432';
        caso.Description = '1234 5678 9876 5432 Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
        caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        // Ejecución de la prueba
        Test.startTest();
        insert caso;
        Test.stopTest();

        // Evaluación del resultado de la prueba
        Case casoInsertado = [SELECT Subject, Description, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id];
        if (casoInsertado != null) {
            System.assertEquals('Asunto 1234XXXXXXXX5432', casoInsertado.Subject);
            System.assertEquals('1234XXXXXXXX5432 Descripción', casoInsertado.Description);
            System.assertEquals('Detalles 1234XXXXXXXX5432 Consulta', casoInsertado.CC_Detalles_Consulta__c);
            System.assertEquals('Detalles 1234XXXXXXXX5432 Solución', casoInsertado.CC_Detalles_Solucion__c);
        }
        }
    }

    @isTest
    public static void enmascararPANBeforeUpdate() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Alta de datos para la prueba
        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert caso;
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto 1234567898765432';
        caso.Description = '1234 5678 9876 5432 Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
        caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        // Ejecución de la prueba
        Test.startTest();
        update caso;
        Test.stopTest();

        // Evaluación del resultado de la prueba
        Case casoActualizado = [SELECT Subject, Description, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c FROM Case WHERE Id = :caso.Id];
        if (casoActualizado != null) {
            System.assertEquals('Asunto 1234XXXXXXXX5432', casoActualizado.Subject);
            System.assertEquals('1234XXXXXXXX5432 Descripción', casoActualizado.Description);
            System.assertEquals('Detalles 1234XXXXXXXX5432 Consulta', casoActualizado.CC_Detalles_Consulta__c);
            System.assertEquals('Detalles 1234XXXXXXXX5432 Solución', casoActualizado.CC_Detalles_Solucion__c);
        }
        }
    }

    @isTest
    public static void encryptPANsBU() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        // Alta de datos para la prueba
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert caso;


        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.RecordTypeId = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        agrupador.CC_Titulo__c = 'Agrupador Test';
        agrupador.CC_Estado__c = 'Rechazado';
        agrupador.CC_Numero_Casos__c = 0;
        insert agrupador;

        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto 1234567898765432';
        caso.Description = '1234 5678 9876 5432 Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
        caso.CC_PAN_Encriptado__c = false;
        caso.CC_PAN__c = '1111 2222 3333 4444';
        caso.CC_Digitos_Tarjeta__c = '1111 2222 3333 4444';
        caso.CC_Agrupador_Id__c = agrupador.Id;

        try {
            Test.startTest();
            update caso;
            Test.stopTest();
            // Evaluación del resultado de la prueba
            Case casoActualizado = [SELECT Subject, CC_PAN__c, CC_Digitos_Tarjeta__c FROM Case WHERE Id = :caso.Id];
            if (casoActualizado != null) {
                System.assertNotEquals('1111 2222 3333 4444', casoActualizado.CC_PAN__c);
                System.assertNotEquals('1111 2222 3333 4444', casoActualizado.CC_Digitos_Tarjeta__c);
            }
        } catch (Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('Solo se pueden asociar agrupadores activos.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        }

    }

    @isTest
    public static void decryptPANsBU() {

        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        // Alta de datos para la prueba
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        insert caso;

        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto 1234567898765432';
        caso.Description = '1234 5678 9876 5432 Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles 1234.5678.9876.5432 Solución';
        caso.CC_PAN_Encriptado__c = false;
        caso.CC_PAN__c = '1111222233334444';
        caso.CC_Digitos_Tarjeta__c = '1111 2222 3333 4444';


        update caso;
        Case casov2 = [SELECT Id, CC_PAN__c FROM Case WHERE Id =: caso.Id LIMIT 1];
        Test.startTest();
        String pan = HDT_Case_BU_TRHan.decryptPANs(casov2.CC_PAN__c);
        Test.stopTest();

        System.assertEquals(pan, '1111222233334444', 'El metodo de desencriptar el campo PAN ha fallado.');
        }

    }

    @isTest
    public static void obtenerBuzon() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        // Alta de datos para la prueba
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;

        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;

        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;

        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Case caso = new Case();
        caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.AccountId = cuenta.Id;
        caso.CC_Buzon_Salida__c = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        caso.ContactId = contacto.Id;
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        insert caso;

        //List<CC_Buzones_Por_Defecto__mdt> buzones = new List<CC_Buzones_Por_Defecto__mdt>();
        String buzones = '';

        // Ejecución de la prueba
        Test.startTest();

        caso.Status = 'Cerrado';
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        update caso;

        buzones = HDT_Case_BU_TRHan.obtenerBuzon(caso.CC_Canal_Procedencia__c, caso.CC_Idioma__c);

        Test.stopTest();

        // Evaluación del resultado de la prueba
        Case casoActualizado = [SELECT CC_Canal_Procedencia__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals('Servicios Centrales', casoActualizado.CC_Canal_Procedencia__c);
        }
    }

    @isTest
    public static void calcularSLA(){
       
        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;

        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;

        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;


        Case caso = new Case();
        caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso.Status = 'Activo';
        caso.CC_Idioma__c = 'es';
        caso.Subject = 'Asunto';
        caso.Description = 'Descripción';
        caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso.CC_MCC_Tematica__c = mccTematica.Id;
        caso.CC_MCC_ProdServ__c = mccProducto.Id;
        caso.CC_MCC_Motivo__c = mccMotivo.Id;
        caso.CC_MCC_Causa__c = mccCausa.Id;
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Origin = 'Phone';
        caso.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(1);
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(1);
        caso.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(4);    
        insert caso;
        Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day() -1, System.now().hour(), 0, 0));

        
        User pruebas = [SELECT Id FROM User WHERE LastName = 'last211' LIMIT 1];
        //user usuario = [select id from user WHERE Name = 'HDT_Usuario_CaixaBank'];
        System.runAs(pruebas){

            Test.startTest();
        
        List<Case> casos = new List<Case>();
        Case caso2 = new Case();
        caso2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso2.Status = 'Activo';
        caso2.CC_Idioma__c = 'es';
        caso2.Subject = 'Asunto';
        caso2.Description = 'Descripción';
        caso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso2.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso2.CC_MCC_Tematica__c = mccTematica.Id;
        caso2.CC_MCC_ProdServ__c = mccProducto.Id;
        caso2.CC_MCC_Motivo__c = mccMotivo.Id;
        caso2.CC_MCC_Causa__c = mccCausa.Id;
        caso2.AccountId = cuenta.Id;
        caso2.ContactId = contacto.Id;
        caso2.Origin = 'Phone';
        caso2.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(8);
        caso2.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso2.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(1);
        caso2.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(6);

        Case caso3 = new Case();
        caso3.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso3.Status = 'Activo';
        caso3.CC_Idioma__c = 'es';
        caso3.Subject = 'Asunto';
        caso3.Description = 'Descripción';
        caso3.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso3.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso3.CC_MCC_Tematica__c = mccTematica.Id;
        caso3.CC_MCC_ProdServ__c = mccProducto.Id;
        caso3.CC_MCC_Motivo__c = mccMotivo.Id;
        caso3.CC_MCC_Causa__c = mccCausa.Id;
        caso3.AccountId = cuenta.Id;
        caso3.ContactId = contacto.Id;
        caso3.Origin = 'Phone';
        caso3.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(8);
        caso3.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso3.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(1);
        caso3.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(6);

        insert caso3;
        casos.add(caso2);
        insert casos;

        List<CC_Lista_Valores__c> horariosInsertar = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c horario = new CC_Lista_Valores__c();
        horario.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        horario.Name = 'Calendario_servicios';
        horario.CC_Activa__c = true;
        insert horario;

        CC_Lista_Valores__c horarioAccionista = new CC_Lista_Valores__c();
        horarioAccionista.Name = 'Accionista';
        horarioAccionista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista.CC_Valor__c = '9';
        horarioAccionista.CC_Valor2__c = '23';
        horarioAccionista.CC_Valor_SFDC__c = 'L-J';
        horarioAccionista.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista);

        CC_Lista_Valores__c horarioAccionista2 = new CC_Lista_Valores__c();
        horarioAccionista2.Name = 'Accionista';
        horarioAccionista2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista2.CC_Valor__c = '9:30';
        horarioAccionista2.CC_Valor2__c = '19';
        horarioAccionista2.CC_Valor_SFDC__c = 'V';
        horarioAccionista2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista2);

        CC_Lista_Valores__c horarioImaginBank = new CC_Lista_Valores__c();
        horarioImaginBank.Name = 'ImaginBank';
        horarioImaginBank.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioImaginBank.CC_Valor__c = '9:30';
        horarioImaginBank.CC_Valor2__c = '19';
        horarioImaginBank.CC_Valor_SFDC__c = 'L-J';
        horarioImaginBank.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioImaginBank);

        CC_Lista_Valores__c horarioImaginBank2 = new CC_Lista_Valores__c();
        horarioImaginBank2.Name = 'ImaginBank';
        horarioImaginBank2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioImaginBank2.CC_Valor__c = '9:30';
        horarioImaginBank2.CC_Valor2__c = '19';
        horarioImaginBank2.CC_Valor_SFDC__c = 'V';
        horarioImaginBank2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioImaginBank2);
        insert horariosInsertar;

        List<CC_Lista_Valores__c> festivosInsertar = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
        festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        festivos.Name = 'Festivos nacionales';
        festivos.CC_Activa__c = true;
        insert festivos;

        CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
        festivo1.Name = 'Festivo';
        festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo1.CC_Valor__c = '11';
        festivo1.CC_Valor2__c = '11';
        festivo1.CC_Lista__c = festivos.Id;
        festivo1.CC_Activa__c = true;
        festivosInsertar.add(festivo1);

        CC_Lista_Valores__c festivo2 = new CC_Lista_Valores__c();
        festivo2.Name = 'Festivo2';
        festivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo2.CC_Valor__c = '10';
        festivo2.CC_Valor2__c = '10';
        festivo2.CC_Lista__c = festivos.Id;
        festivo2.CC_Activa__c = true;
        festivosInsertar.add(festivo2);
        insert festivosInsertar;

        //Map para tener el nombre de la lista de valores con sus valores
        Map<String, Map<String, List <Time>>> horariosPorCanalProcedencia = new Map<String, Map<String, List <Time>>> ();
        horariosPorCanalProcedencia = HDT_Case_BU_TRHan.horariosPorCanalProcedencia();
        Map <Id, Datetime> casosFecha = new Map <Id, Datetime>();

        //Map<Mes, List<dias>>
        Map<Integer, List<Integer>> festivosPorMesMap = new Map<Integer, List<Integer>> ();
        festivosPorMesMap = HDT_Case_BU_TRHan.sacarFestivosPorMes();
        caso.Status = 'Pendiente Colaborador';
        casosFecha.put(caso2.Id, caso2.CC_Fecha_Traslado_Colaborador__c);
        casosFecha.put(caso3.Id, caso3.CC_Fecha_Traslado_Colaborador__c);
        caso2.Status = 'Pendiente Interno';
        casos.clear();
        casos.add(caso);
        casos.add(caso2);
        update casos;

        //horasSLATraslado = calcularSLA(caso, horariosPorCanalProcedencia.get(caso.CC_Canal_Procedencia__c), casosFecha.get(caso.Id), festivosPorMesMap);
        Double horasSLATraslado = 0;
        Test.stopTest();

        // Horario de trabajo (Lunes a Viernes 9:00-18:00)
        Map<String, List<Time>> horario2 = new Map<String, List<Time>>{
            'L-J' => new List<Time>{Time.newInstance(9, 0, 0, 0), Time.newInstance(18, 0, 0, 0)},
            'V' => new List<Time>{Time.newInstance(9, 0, 0, 0), Time.newInstance(15, 0, 0, 0)}  // Viernes diferente horario
        };

        Case nuevoCaso = [Select id,CC_Inicio_Pendiente_Cliente__c,CC_Fin_Pendiente_Cliente__c, Origin,CreatedDate,CC_Canal_Procedencia__c from Case where id = :caso3.Id limit 1];
        system.debug('El primer cacular SLA es : ' + 'Canal ' + nuevoCaso.CC_Canal_Procedencia__c + 'Origin ' + nuevoCaso.Origin + 'Horario : '+ horario2);
        horasSLATraslado = HDT_Case_BU_TRHan.calcularSLA(nuevoCaso,horario2,casosFecha.get(nuevoCaso.Id),festivosPorMesMap);

        Case nuevoCaso2 = [Select id,CC_Inicio_Pendiente_Cliente__c,CC_Fin_Pendiente_Cliente__c, Origin,CreatedDate,CC_Canal_Procedencia__c from Case where id = :caso2.Id limit 1];
        horasSLATraslado = HDT_Case_BU_TRHan.calcularSLA(nuevoCaso2,horariosPorCanalProcedencia.get(nuevoCaso2.CC_Canal_Procedencia__c),casosFecha.get(nuevoCaso2.Id),festivosPorMesMap);


        System.assertEquals(caso.Status, 'Pendiente Colaborador', 'La asignación del nuevo estado no ha funcionado.');
        System.assertEquals(caso2.Status, 'Pendiente Interno', 'La asignación del nuevo estado no ha funcionado.');
        }
    }

    @Testvisible
    public static testMethod void testValidarCierreCaso() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
        // Creamos un perfil de usuario
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'HDT_Usuario_CaixaBank'].Id;

        // Creamos un usuario de prueba con el perfil creado
        User u = new User(Username='pruebasmois@test.com', LastName='Pruebaxxx', FirstName='Usuariox', Email='pruebaxx@test.com',
                          Alias='pruebaxx', CommunityNickname='pruebaxx', ProfileId=profileId, TimeZoneSidKey='GMT',
                          LocaleSidKey='en_US', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US');
        insert u;

        // Creamos un caso para cerrar
        Case c = new Case(Subject='Prueba', Status='Cerrado',recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId());
        insert c;

        Task tarea = new Task(WhatId=c.Id, Status='Pendiente',Subject='Prueba1');
        insert tarea;

        // Ejecutamos el método a probar
        Test.startTest();
        Map<Id, Case> mapOldObj = new Map<Id, Case>{c.Id => new Case(recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),Subject='Prueba', Status='Activo')};
        List<Case> listNewObj = new List<Case>{new Case(recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),Id=c.Id, Status='Cerrado')};

        HDT_Case_BU_TRHan.validarCierreCaso(mapOldObj, listNewObj);


        // Comprobamos que se ha creado una tarea de tipo 'Traslado Tercer Nivel'
        List<Task> tareas = [SELECT Id, Type FROM Task WHERE WhatId = :c.Id];
        System.assertEquals(1, tareas.size());
        //System.assertEquals('Automática', tareas[0].Type);

        // Intentamos cerrar el caso sin completar la tarea creada

        mapOldObj = new Map<Id, Case>{c.Id => new Case(Subject='Prueba', Status='Cerrado')};
        listNewObj = new List<Case>{new Case(recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),Id=c.Id, Status='Nuevo')};
        HDT_Case_BU_TRHan.validarCierreCaso(mapOldObj, listNewObj);
        Test.stopTest();

        // Comprobamos que el caso no se ha cerrado y se ha generado un error
        List<Case> casos = [SELECT Id, Status FROM Case WHERE Id = :c.Id];
        System.assertEquals('Cerrado', casos[0].Status);
        }
    }

    @isTest
    public static void calcularSLASegundaParte(){
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'ImaginBank';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mccTematica;

        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Migración';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        insert mccProducto;

        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        CC_MCC__c mccMotivo = new CC_MCC__c();
        mccMotivo.Name = 'Reversión';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.CC_Tematica__c = mccTematica.Id;
        mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
        mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
        insert mccMotivo;

        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        CC_MCC__c mccCausa = new CC_MCC__c();
        mccCausa.Name = 'Solicita reversión';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.CC_Motivo__c = mccMotivo.Id;
        mccCausa.CC_Codigo_Externo__c = 'CA-000001';
        insert mccCausa;

        Account cuenta = new Account();
        cuenta.Name = 'Smith';
        cuenta.CC_Numero_Documento__c = '64850344G';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.LastName = 'Smith';
        contacto.CC_Numero_Documento__c = '64850344G';
        contacto.AccountId = cuenta.Id;
        insert contacto;

        Case caso3 = new Case();
        caso3.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
        caso3.Status = 'Activo';
        caso3.CC_Idioma__c = 'es';
        caso3.Subject = 'Asunto';
        caso3.Description = 'Descripción';
        caso3.CC_Detalles_Consulta__c = 'Detalles Consulta';
        caso3.CC_Detalles_Solucion__c = 'Detalles Solución';
        caso3.CC_MCC_Tematica__c = mccTematica.Id;
        caso3.CC_MCC_ProdServ__c = mccProducto.Id;
        caso3.CC_MCC_Motivo__c = mccMotivo.Id;
        caso3.CC_MCC_Causa__c = mccCausa.Id;
        caso3.AccountId = cuenta.Id;
        caso3.ContactId = contacto.Id;
        caso3.Origin = 'Phone';
        caso3.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(2);
        caso3.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso3.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(22);
        caso3.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(23);
        insert caso3;

        List<CC_Lista_Valores__c> horariosInsertar = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c horario = new CC_Lista_Valores__c();
        horario.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        horario.Name = 'Calendario_servicios';
        horario.CC_Activa__c = true;
        insert horario;

        CC_Lista_Valores__c horarioAccionista = new CC_Lista_Valores__c();
        horarioAccionista.Name = 'Accionista';
        horarioAccionista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista.CC_Valor__c = '9';
        horarioAccionista.CC_Valor2__c = '23';
        horarioAccionista.CC_Valor_SFDC__c = 'L-J';
        horarioAccionista.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista);

        CC_Lista_Valores__c horarioAccionista2 = new CC_Lista_Valores__c();
        horarioAccionista2.Name = 'Accionista';
        horarioAccionista2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista2.CC_Valor__c = '9:30';
        horarioAccionista2.CC_Valor2__c = '19';
        horarioAccionista2.CC_Valor_SFDC__c = 'V';
        horarioAccionista2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista2);

        CC_Lista_Valores__c horarioImaginBank = new CC_Lista_Valores__c();
        horarioImaginBank.Name = 'ImaginBank';
        horarioImaginBank.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioImaginBank.CC_Valor__c = '9:30';
        horarioImaginBank.CC_Valor2__c = '19';
        horarioImaginBank.CC_Valor_SFDC__c = 'L-J';
        horarioImaginBank.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioImaginBank);

        CC_Lista_Valores__c horarioImaginBank2 = new CC_Lista_Valores__c();
        horarioImaginBank2.Name = 'ImaginBank';
        horarioImaginBank2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioImaginBank2.CC_Valor__c = '9:30';
        horarioImaginBank2.CC_Valor2__c = '19';
        horarioImaginBank2.CC_Valor_SFDC__c = 'V';
        horarioImaginBank2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioImaginBank2);
        insert horariosInsertar;


        List<CC_Lista_Valores__c> festivosInsertar = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
        festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        festivos.Name = 'Festivos nacionales';
        festivos.CC_Activa__c = true;
        insert festivos;

        CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
        festivo1.Name = 'Festivo';
        festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo1.CC_Valor__c = '11';
        festivo1.CC_Valor2__c = '11';
        festivo1.CC_Lista__c = festivos.Id;
        festivo1.CC_Activa__c = true;
        festivosInsertar.add(festivo1);

        CC_Lista_Valores__c festivo2 = new CC_Lista_Valores__c();
        festivo2.Name = 'Festivo2';
        festivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        festivo2.CC_Valor__c = '10';
        festivo2.CC_Valor2__c = '10';
        festivo2.CC_Lista__c = festivos.Id;
        festivo2.CC_Activa__c = true;
        festivosInsertar.add(festivo2);
        insert festivosInsertar;

        Test.startTest();
        caso3.Status = 'Pendiente Incidencia';
        update caso3;

        Test.stopTest();

        System.assertEquals(caso3.Status, 'Pendiente Incidencia', 'La asignación del nuevo estado no ha funcionado.');
        }
    }

    @isTest
    public static void asignacionTRZ(){
        
        // if (caso.OwnerId != mapOldObj.get(caso.Id).OwnerId && caso.CC_Fecha_Reapertura__c == null && caso.CC_Fecha_Limite_Resolucion__c != null) {

            // Alta de datos para la prueba
            Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'ImaginBank';
            mccTematica.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        	mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mccTematica;

            Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Migración';
            mccProducto.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000001';
            insert mccProducto;

            Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Reversión';
            mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Tematica__c = mccTematica.Id;
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
            insert mccMotivo;

            Id recordTypeIdTematicaAM = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            CC_MCC__c mccTematicaAM = new CC_MCC__c();
            mccTematicaAM.Name = 'ImaginBank';
            mccTematicaAM.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
            mccTematicaAM.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccTematicaAM.RecordTypeId = recordTypeIdTematicaAM;
            mccTematicaAM.CC_Codigo_Externo__c = 'TE-000002';
            insert mccTematicaAM;

            Id recordTypeIdProductoAM = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            CC_MCC__c mccProductoAM = new CC_MCC__c();
            mccProductoAM.Name = 'Migración';
            mccProductoAM.CC_Tipo_Cliente__c ='Cliente (CAM)/Empleado (CAM)';
            mccProductoAM.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccProductoAM.RecordTypeId = recordTypeIdProductoAM;
            mccProductoAM.CC_Tematica__c = mccTematicaAM.Id;
            mccProductoAM.CC_Codigo_Externo__c = 'PR-000002';
            insert mccProductoAM;

            Id recordTypeIdMotivoAM = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            CC_MCC__c mccMotivoAM = new CC_MCC__c();
            mccMotivoAM.Name = 'Reversión';
            mccMotivoAM.CC_Tipo_Cliente__c = 'Cliente (CAM)/Empleado (CAM)';
            mccMotivoAM.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivoAM.RecordTypeId = recordTypeIdMotivoAM;
            mccMotivoAM.CC_Tematica__c = mccTematicaAM.Id;
            mccMotivoAM.CC_Producto_Servicio__c = mccProductoAM.Id;
            mccMotivoAM.CC_Codigo_Externo__c = 'MO-000002';
            insert mccMotivoAM;

            Account cuenta = new Account();
            cuenta.recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            cuenta.Name = 'Smith';
            cuenta.CC_Numero_Documento__c = '64850344G';
            insert cuenta;

            Contact contacto = new Contact();
            contacto.recordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contacto.LastName = 'Smith';
            contacto.CC_Numero_Documento__c = '64850344G';
            contacto.AccountId = cuenta.Id;
            insert contacto;

            List<Case> casosAsignacionTRZ = new List<Case>();

            Case casoAsignacionTRZ = new Case();
            casoAsignacionTRZ.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            casoAsignacionTRZ.Status = 'Activo';
            casoAsignacionTRZ.CC_Idioma__c = 'es';
            casoAsignacionTRZ.Subject = 'Asunto';
            casoAsignacionTRZ.Description = 'Descripción';
            casoAsignacionTRZ.CC_Detalles_Consulta__c = 'Detalles Consulta';
            casoAsignacionTRZ.CC_Detalles_Solucion__c = 'Detalles Solución';
            casoAsignacionTRZ.AccountId = cuenta.Id;
            casoAsignacionTRZ.ContactId = contacto.Id;
            casoAsignacionTRZ.CC_MCC_Tematica__c = mccTematica.Id;
            casoAsignacionTRZ.CC_MCC_ProdServ__c = mccProducto.Id;
            casoAsignacionTRZ.CC_MCC_Motivo__c = mccMotivo.Id;
            casoAsignacionTRZ.Origin = 'Phone';
            casoAsignacionTRZ.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(2);
            casoAsignacionTRZ.CC_Canal_Procedencia__c = 'Servicios Centrales';
            casoAsignacionTRZ.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(22);
            casoAsignacionTRZ.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(23);
            casoAsignacionTRZ.CC_Fecha_Limite_Resolucion__c = System.now();
            casoAsignacionTRZ.OwnerId = [SELECT ID FROM User WHERE Email = 'tuser000@amamama.com' AND FirstName = 'first2' LIMIT 1].Id;
            casosAsignacionTRZ.add(casoAsignacionTRZ);


            Case casoAsignacionTRZ2 = new Case();
            casoAsignacionTRZ2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            casoAsignacionTRZ2.Status = 'Activo';
            casoAsignacionTRZ2.CC_Idioma__c = 'es';
            casoAsignacionTRZ2.Subject = 'Asunto';
            casoAsignacionTRZ2.Description = 'Descripción';
            casoAsignacionTRZ2.CC_Detalles_Consulta__c = 'Detalles Consulta';
            casoAsignacionTRZ2.CC_Detalles_Solucion__c = 'Detalles Solución';
            casoAsignacionTRZ2.AccountId = cuenta.Id;
            casoAsignacionTRZ2.ContactId = contacto.Id;
            casoAsignacionTRZ2.CC_MCC_Tematica__c = mccTematicaAM.Id;
            casoAsignacionTRZ2.CC_MCC_ProdServ__c = mccProductoAM.Id;
            casoAsignacionTRZ2.CC_MCC_Motivo__c = mccMotivoAM.Id;
            casoAsignacionTRZ2.Origin = 'Phone';
            casoAsignacionTRZ2.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(2);
            casoAsignacionTRZ2.CC_Canal_Procedencia__c = 'Servicios Centrales';
            casoAsignacionTRZ2.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(22);
            casoAsignacionTRZ2.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(23);
            casoAsignacionTRZ2.OwnerId = [SELECT ID FROM User WHERE Email = 'tuser000@amamama.com' AND FirstName = 'first2' LIMIT 1].Id;


            casosAsignacionTRZ.add(casoAsignacionTRZ2);

            test.startTest();

            Map<Id, Case> mapOldObjCC = New Map<Id, Case>();

            User pruebas = [SELECT Id FROM User WHERE LastName = 'last211' LIMIT 1];
            //user usuario = [select id from user WHERE Name = 'HDT_Usuario_CaixaBank'];
            System.runAs(pruebas){

            insert casosAsignacionTRZ;
            casosAsignacionTRZ.clear();
            casoAsignacionTRZ.OwnerId = [SELECT ID FROM User WHERE Email = 'tuser000@amamama.com' AND FirstName = 'first 11212' LIMIT 1].Id;
            casoAsignacionTRZ.CC_Fecha_Limite_Resolucion__c = System.now();
            casoAsignacionTRZ.Status = 'Cerrado';

            casoAsignacionTRZ2.OwnerId = [SELECT ID FROM User WHERE Email = 'tuser000@amamama.com' AND FirstName = 'first 11212' LIMIT 1].Id;
            casoAsignacionTRZ2.CC_Fecha_Limite_Resolucion__c = System.now();
            casoAsignacionTRZ2.Status = 'Cerrado';

            casosAsignacionTRZ.add(casoAsignacionTRZ);
            casosAsignacionTRZ.add(casoAsignacionTRZ2);

            update casosAsignacionTRZ;

            Case casoActualizado = [SELECT OwnerId,CC_Fecha_Limite_Resolucion__c,CC_Fecha_Reapertura__c,Id, Status FROM Case WHERE Id = :casoAsignacionTRZ.Id];
           Case casoActualizado2 = [SELECT OwnerId,CC_Fecha_Limite_Resolucion__c,CC_Fecha_Reapertura__c,Id, Status FROM Case WHERE Id = :casoAsignacionTRZ2.Id];

           mapOldObjCC.put(casoActualizado.Id, casoActualizado);
            mapOldObjCC.put(casoActualizado2.Id, casoActualizado2);



            HDT_Case_BU_TRHan.asignacionTRZ(mapOldObjCC, casosAsignacionTRZ);

            test.stopTest();

            System.assertEquals('Cerrada',[SELECT CC_Tramo_TRZ__c FROM Case WHERE Id = :casoAsignacionTRZ.Id LIMIT 1].CC_Tramo_TRZ__c);
         }
        }

    	@isTest
        public static void calcularSLAFormularioConsultasOperativasBI(){
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

            List<CC_Lista_Valores__c> festivosInsertar = new List<CC_Lista_Valores__c>();

            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;

            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = '06';
            festivo1.CC_Valor2__c = '01';
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            festivosInsertar.add(festivo1);

            CC_Lista_Valores__c festivo2 = new CC_Lista_Valores__c();
            festivo2.Name = 'Random';
            festivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo2.CC_Valor__c = String.valueOf(Datetime.now().addDays(1).day());
            festivo2.CC_Valor2__c = String.valueOf(Datetime.now().addDays(1).month());
            festivo2.CC_Lista__c = festivos.Id;
            festivo2.CC_Activa__c = true;
            festivosInsertar.add(festivo2);

            CC_Lista_Valores__c festivo3 = new CC_Lista_Valores__c();
            festivo3.Name = 'New year';
            festivo3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo3.CC_Valor__c = '1';
            festivo3.CC_Valor2__c = '1';
            festivo3.CC_Lista__c = festivos.Id;
            festivo3.CC_Activa__c = true;
            festivosInsertar.add(festivo3);


            insert festivosInsertar;



            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso);

            Case caso2 = new Case();
            caso2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso2.Status = 'Activo';
            caso2.CC_Idioma__c = 'es';
            caso2.Subject = 'Asunto';
            caso2.Description = 'Descripción';
            caso2.Origin = 'Phone';
            caso2.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso2.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso2);

            Case caso3 = new Case();
            caso3.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso3.Status = 'Activo';
            caso3.CC_Idioma__c = 'es';
            caso3.Subject = 'Asunto';
            caso3.Description = 'Descripción';
            caso3.Origin = 'Phone';
            caso3.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso3.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso3);

            Case caso4 = new Case();
            caso4.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso4.Status = 'Activo';
            caso4.CC_Idioma__c = 'es';
            caso4.Subject = 'Asunto';
            caso4.Description = 'Descripción';
            caso4.Origin = 'Phone';
            caso4.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso4.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso4);
            List<Case> preCasos = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c = 'Servicios Centrales'];
            Test.startTest();
            insert listadoCasos;
            Test.stopTest();
            List<Case> casosInsertados = [SELECT Id FROM Case WHERE CC_Canal_Procedencia__c = 'Servicios Centrales'];
            Test.setCreatedDate(casosInsertados[1].Id, DateTime.newInstance(2022, 1, 5, 20, 30, 00));

            System.assertNotEquals(preCasos.size(), casosInsertados.size(), 'La inserción de casos no ha tenido en cuenta el SLA de los dias festivos.');
            //Test.setCreatedDate(casosInsertados[0].Id, DateTime.newInstance(2022, 7, 2, 12, 00, 00));
            //Test.setCreatedDate(casosInsertados[2].Id, DateTime.newInstance(2022, 1, 1, 12, 00, 00));
            //Test.setCreatedDate(casosInsertados[3].Id, 2022, 07, 02, 12, 00, 00);
            }
        }



        @isTest
        public static void encryptPANs(){
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Email';
            caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            caso.CC_PAN__c = '35778451826574';
            caso.CC_PAN_Encriptado__c = false;


            Case caso2 = new Case();
            caso2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso2.Status = 'Activo';
            caso2.CC_Idioma__c = 'es';
            caso2.Subject = 'Asunto';
            caso2.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            caso2.CC_Digitos_Tarjeta__c = '35778451826574';
            caso2.CC_DigitosTarjeta_Encriptado__c = false;

            Test.startTest();
            insert caso;
            insert caso2;
            Test.stopTest();

            Case c = [SELECT Id, CC_DigitosTarjeta_Encriptado__c FROM Case WHERE Id =: caso2.Id];

            System.assertNotEquals(caso2.CC_DigitosTarjeta_Encriptado__c, c.CC_DigitosTarjeta_Encriptado__c, 'La encriptación de los dígitos de la cuenta ha fallado.');

            }
        }



        @isTest
        public static void horaSLAConsultasOperativasRenaudarPdteInterno(){
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;

            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = String.valueOf(Datetime.now().day());
            festivo1.CC_Valor2__c = String.valueOf(Datetime.now().month());
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            insert festivo1;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Pendiente Interno';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            //caso.Status = 'Pendiente Interno';
            //update caso;

            Test.startTest();



            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
            }
        }



        @isTest
        public static void horaSLAConsultasOperativasRenaudarPdteIncidencia(){

            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;

            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = '01';
            festivo1.CC_Valor2__c = '01';
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            insert festivo1;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            caso.Status = 'Pendiente Incidencia';
            update caso;

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
            }
        }

        @isTest
        public static void horaSLAConsultasOperativasRenaudarPInterno(){

            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;

            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = '01';
            festivo1.CC_Valor2__c = '01';
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            insert festivo1;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            caso.Status = 'Pendiente Interno';
            update caso;

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
            }
        }

        @isTest
        public static void horaSLAConsultasOperativasRenaudarPCliente(){

            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;

            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = '01';
            festivo1.CC_Valor2__c = '01';
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            insert festivo1;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            caso.Status = 'Pendiente Cliente';
            update caso;

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
            }
        }

        @isTest
        public static void horaSLAConsultasOperativasRenaudarPColab(){

            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;

            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Reyes';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = '01';
            festivo1.CC_Valor2__c = '01';
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            insert festivo1;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            caso.Status = 'Pendiente Colaborador';
            update caso;

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            System.assertEquals(null, [SELECT CC_EstadoSLA__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_EstadoSLA__c);
            }
        }

        @isTest
        public static void cambioPendienteIncidencia(){
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;
            caso.Status = 'Pendiente Incidencia';
            update caso;
            listadoCasos.add(caso);

            Map<Id, Case> mapOldObjCC = New Map<Id, Case>();

            Test.startTest();


            caso.Status = 'Activo';
            update caso;


            Case casoActualizado = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];
            mapOldObjCC.put(casoActualizado.Id, casoActualizado);
            HDT_Case_BU_TRHan.cambioPendienteIncidencia(mapOldObjCC, listadoCasos);


            Test.stopTest();

            System.assertNotEquals(null, [SELECT CC_Fin_Pendiente_Incidencia__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_Fin_Pendiente_Incidencia__c);
            }
        }

        @isTest
        public static void isWeekendTest()
        {
           User pruebas = [SELECT Id FROM User WHERE LastName = 'last211' LIMIT 1];

            System.runAs(pruebas){

            Boolean res;

            Test.startTest();
                DateTime dt = datetime.newInstance(2022, 12, 15);
                res = HDT_Case_BU_TRHan.isWeekend(dt);
            Test.stopTest();

            System.assertEquals(false, res, 'El metodo is weekend ha fallado.');
            }
        }


        @isTest
        public static void cambioPendienteInterno(){
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;
            caso.Status = 'Pendiente Interno';
            update caso;

            Map<Id, Case> mapOldObjCC = New Map<Id, Case>();
            mapOldObjCC.put(caso.Id, caso);

            listadoCasos.add(caso);

            Test.startTest();
            caso.Status = 'Activo';
            update caso;
            Test.stopTest();

            HDT_Case_BU_TRHan.cambioPendienteInterno(mapOldObjCC,listadoCasos);

            System.assertNotEquals(null, [SELECT CC_Fin_Pendiente_Interno__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_Fin_Pendiente_Interno__c);
            }

        }

        @isTest
        public static void cambioPendienteCliente(){
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Pendiente Cliente';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso);
            insert caso;


            Case caso2 = new Case();
            caso2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso2.Status = 'Pendiente Cliente';
            caso2.CC_Idioma__c = 'es';
            caso2.Subject = 'Asunto';
            caso2.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            listadoCasos.add(caso);
            insert caso2;


            //caso.Status = 'Pendiente Cliente';
            //update caso;
            Map<Id, Case> mapOldObjCC = New Map<Id, Case>();
            Test.startTest();


            caso.Status = 'Activo';
            update caso;


            Case casoActualizado = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];
            mapOldObjCC.put(casoActualizado.Id, casoActualizado);


            HDT_Case_BU_TRHan.cambioPendinteCliente(mapOldObjCC, listadoCasos);

            Test.stopTest();
            //HDT_Case_BU_TRHan.cambioPendienteColaborador(mapOldObjCC, listNewObjCC);
            System.assertEquals(null, [SELECT CC_Fin_Pendiente_Cliente__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_Fin_Pendiente_Cliente__c);
            }
        }

        @isTest
        public static void testcambioPendienteColaborador(){
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Pendiente Colaborador';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Canal_Resolucion__c = 'RRHH';
            insert caso;

            listadoCasos.add(caso);

            //caso.Status = 'Pendiente Cliente';
            //update caso;
            Map<Id, Case> mapOldObjCC = New Map<Id, Case>();
            Test.startTest();


            caso.Status = 'Activo';
            update caso;

            Test.stopTest();

            Case casoActualizado = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];

            mapOldObjCC.put(casoActualizado.Id, casoActualizado);


            HDT_Case_BU_TRHan.cambioPendienteColaborador(mapOldObjCC, listadoCasos);
            //HDT_Case_BU_TRHan.cambioPendienteColaborador(mapOldObjCC, listNewObjCC);
            System.assertEquals(null, [SELECT CC_Fin_Pendiente_Cliente__c FROM Case WHERE Id = :caso.Id LIMIT 1].CC_Fin_Pendiente_Cliente__c);
            }
        }

        @isTest
        public static void testPruebaRobot(){

            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'Contactos erróneos';
            mccTematica.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000120';
        	mccTematica.CC_Canal_Operativo__c = 'Sin canal';
            insert mccTematica;

            Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Pruebas Salesforce';
            mccProducto.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-001318';
            insert mccProducto;

            Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Contacto de prueba';
            mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Codigo_Externo__c = 'MO-012087';
            insert mccMotivo;

            Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
            CC_MCC__c mccCausa = new CC_MCC__c();
            mccCausa.Name = 'Pruebas/Validaciones';
            mccCausa.CC_Tipo_Cliente__c = 'Cliente';
            mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccCausa.RecordTypeId = recordTypeIdCausa;
            mccCausa.CC_Motivo__c = mccMotivo.Id;
            mccCausa.CC_Codigo_Externo__c = 'CA-015680';
            insert mccCausa;

            Id recordTypeIdSolucion = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
            CC_MCC__c mccSolucion = new CC_MCC__c();
            mccSolucion.Name = 'No aplica';
            mccSolucion.CC_Tipo_Cliente__c = 'Cliente';
            mccSolucion.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccSolucion.RecordTypeId = recordTypeIdSolucion;
            mccSolucion.CC_Causa__c = mccCausa.Id;
            mccSolucion.CC_Codigo_Externo__c = 'SO-033729';
            insert mccSolucion;

            List<Case> listadoCasos = new List<Case>();
            Case caso = new Case();
            caso.recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Prueba Robot';
            caso.Description = 'Descripción';
            caso.Origin = 'Phone';
            caso.CC_Canal_Procedencia__c = 'ImaginBank';

            Test.startTest();
            insert caso;
            Test.stopTest();

			Case casoRobot = [Select id, Status from Case where id = :caso.Id limit 1];
            System.assertEquals( 'Rechazado' , casoRobot.Status);
            }
        }

        @isTest
        public static void testHorarioDiaTurno() {
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            // Crea el mapa de horarios de prueba
            Map<String, List<Time>> horario = new Map<String, List<Time>>{
                'L-V' => new List<Time>{Time.newInstance(9, 0, 0, 0), Time.newInstance(18, 0, 0, 0)}
            };

            // Prueba para el caso de día de la semana 5 y entrada al trabajo
            Time horarioEntrada = HDT_Case_BU_TRHan.horarioDiaTurno(horario, '5', 'Entrada');
            System.assertEquals(Time.newInstance(9, 0, 0, 0), horarioEntrada);

            // Prueba para el caso de día de la semana 5 y salida del trabajo
            Time horarioSalida = HDT_Case_BU_TRHan.horarioDiaTurno(horario, '5', 'Salida');
            System.assertEquals(Time.newInstance(18, 0, 0, 0), horarioSalida);

            // Prueba para el caso de día de la semana 3 y entrada al trabajo
            horarioEntrada = HDT_Case_BU_TRHan.horarioDiaTurno(horario, '3', 'Entrada');
            System.assertEquals(Time.newInstance(9, 0, 0, 0), horarioEntrada);

            // Prueba para el caso de día de la semana 3 y salida del trabajo
            horarioSalida = HDT_Case_BU_TRHan.horarioDiaTurno(horario, '3', 'Salida');
            System.assertEquals(Time.newInstance(18, 0, 0, 0), horarioSalida);
        }
        }


        @isTest
        public static void testIsFestive() {
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            // Test case 1: empty map
            Datetime fecha1 = Datetime.newInstanceGmt(2023, 1, 1, 0, 0, 0);
            Map<Integer, List<Integer>> listaFestivos1 = new Map<Integer, List<Integer>>();
            Boolean expected1 = false;
            Boolean actual1 = HDT_Case_BU_TRHan.isFestive(fecha1, listaFestivos1);
            System.assertEquals(expected1, actual1);

            // Test case 2: non-empty map, date is a holiday
            Datetime fecha2 = Datetime.newInstanceGmt(2023, 5, 1, 0, 0, 0);
            Map<Integer, List<Integer>> listaFestivos2 = new Map<Integer, List<Integer>>{
                5 => new List<Integer>{1}
            };
            Boolean expected2 = true;
            Boolean actual2 = HDT_Case_BU_TRHan.isFestive(fecha2, listaFestivos2);
            System.assertEquals(expected2, actual2);

            // Test case 3: non-empty map, date is not a holiday
            Datetime fecha3 = Datetime.newInstanceGmt(2023, 5, 2, 0, 0, 0);
            Map<Integer, List<Integer>> listaFestivos3 = new Map<Integer, List<Integer>>{
                5 => new List<Integer>{1}
            };
            Boolean expected3 = false;
            Boolean actual3 = HDT_Case_BU_TRHan.isFestive(fecha3, listaFestivos3);
            System.assertEquals(expected3, actual3);
        }
        }

        @IsTest
        public static void testRestarHoras() {
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            Time t1 = Time.newInstance(10, 0, 0, 0);
            Time t2 = Time.newInstance(8, 30, 0, 0);

            Double resultadoEsperado = 1.5;
            Double resultadoReal = HDT_Case_BU_TRHan.restarHoras(t1, t2);

            System.assertEquals(resultadoEsperado, resultadoReal);
            }
        }

        @IsTest
        public static void testEncontrarMCCPorId() {
            System.runAs(HDT_TestDataFactory.usuarioAHdt()) {
            CC_MCC__c mcc1 = new CC_MCC__c();
            mcc1.Name = 'MCC1';
            mcc1.CC_Tipo_Cliente__c = 'Cliente';
            mcc1.CC_Codigo_Externo__c = 'TE-000001';
            mcc1.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mcc1;

            CC_MCC__c mcc2 = new CC_MCC__c();
            mcc2.Name = 'MCC2';
            mcc2.CC_Tipo_Cliente__c = 'Cliente';
            mcc2.CC_Codigo_Externo__c = 'TE-000002';
            mcc2.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mcc2;

            CC_MCC__c mcc3 = new CC_MCC__c();
            mcc3.Name = 'MCC3';
            mcc3.CC_Tipo_Cliente__c = 'Cliente';
            mcc3.CC_Codigo_Externo__c = 'TE-000003';
            mcc3.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mcc3;

        List<CC_MCC__c> listaMCC = new List<CC_MCC__c>();
        listaMCC.add(mcc1);
        listaMCC.add(mcc2);
        listaMCC.add(mcc3);
        Id idBuscado = mcc2.Id;
        CC_MCC__c mccEncontrado = HDT_Case_BU_TRHan.encontrarMCCPorId(listaMCC, idBuscado);
        System.assertEquals(mcc2, mccEncontrado);
            }
    }

    @isTest
    public static void newcalcularSLA(){
        User pruebas = [SELECT Id FROM User WHERE LastName = 'last211' LIMIT 1];

        System.runAs(pruebas){
            Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            CC_MCC__c mccTematica = new CC_MCC__c();
            mccTematica.Name = 'ImaginBank';
            mccTematica.CC_Tipo_Cliente__c = 'Cliente';
            mccTematica.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccTematica.RecordTypeId = recordTypeIdTematica;
            mccTematica.CC_Codigo_Externo__c = 'TE-000001';
            mccTematica.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mccTematica;

            Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            CC_MCC__c mccProducto = new CC_MCC__c();
            mccProducto.Name = 'Migración';
            mccProducto.CC_Tipo_Cliente__c = 'Cliente';
            mccProducto.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccProducto.RecordTypeId = recordTypeIdProducto;
            mccProducto.CC_Tematica__c = mccTematica.Id;
            mccProducto.CC_Codigo_Externo__c = 'PR-000001';
            insert mccProducto;

            Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            CC_MCC__c mccMotivo = new CC_MCC__c();
            mccMotivo.Name = 'Reversión';
            mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
            mccMotivo.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccMotivo.RecordTypeId = recordTypeIdMotivo;
            mccMotivo.CC_Tematica__c = mccTematica.Id;
            mccMotivo.CC_Producto_Servicio__c = mccProducto.Id;
            mccMotivo.CC_Codigo_Externo__c = 'MO-000001';
            insert mccMotivo;

            Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
            CC_MCC__c mccCausa = new CC_MCC__c();
            mccCausa.Name = 'Solicita reversión';
            mccCausa.CC_Tipo_Cliente__c = 'Cliente';
            mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccCausa.RecordTypeId = recordTypeIdCausa;
            mccCausa.CC_Motivo__c = mccMotivo.Id;
            mccCausa.CC_Codigo_Externo__c = 'CA-000001';
            insert mccCausa;

            Account cuenta = new Account();
            cuenta.Name = 'Smith';
            cuenta.CC_Numero_Documento__c = '64850344G';
            insert cuenta;

            Contact contacto = new Contact();
            contacto.LastName = 'Smith';
            contacto.CC_Numero_Documento__c = '64850344G';
            contacto.AccountId = cuenta.Id;
            insert contacto;

            Case caso = new Case();
            caso.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso.Status = 'Activo';
            caso.CC_Idioma__c = 'es';
            caso.Subject = 'Asunto';
            caso.Description = 'Descripción';
            caso.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso.CC_Detalles_Solucion__c = 'Detalles Solución';
            caso.CC_MCC_Tematica__c = mccTematica.Id;
            caso.CC_MCC_ProdServ__c = mccProducto.Id;
            caso.CC_MCC_Motivo__c = mccMotivo.Id;
            caso.CC_MCC_Causa__c = mccCausa.Id;
            caso.AccountId = cuenta.Id;
            caso.ContactId = contacto.Id;
            caso.Origin = 'Phone';
            caso.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(1);
            caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(1);
            caso.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(4);

            insert caso;
            Test.setCreatedDate(caso.Id, DateTime.newInstance(System.today().year(), System.today().month(), System.today().day() -1, System.now().hour(), 0, 0));

            List<Case> casos = new List<Case>();
            Case caso2 = new Case();
            caso2.recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId();
            caso2.Status = 'Activo';
            caso2.CC_Idioma__c = 'es';
            caso2.Subject = 'Asunto';
            caso2.Description = 'Descripción';
            caso2.CC_Detalles_Consulta__c = 'Detalles Consulta';
            caso2.CC_Detalles_Solucion__c = 'Detalles Solución';
            caso2.CC_MCC_Tematica__c = mccTematica.Id;
            caso2.CC_MCC_ProdServ__c = mccProducto.Id;
            caso2.CC_MCC_Motivo__c = mccMotivo.Id;
            caso2.CC_MCC_Causa__c = mccCausa.Id;
            caso2.AccountId = cuenta.Id;
            caso2.ContactId = contacto.Id;
            caso2.Origin = 'Phone';
            caso2.CC_Fecha_Traslado_Colaborador__c = Datetime.now().addDays(8);
            caso2.CC_Canal_Procedencia__c = 'Servicios Centrales';
            caso2.CC_Inicio_Pendiente_Cliente__c = Datetime.now().addHours(1);
            caso2.CC_Fin_Pendiente_Cliente__c = Datetime.now().addHours(6);
            casos.add(caso2);


            insert casos;


            List<CC_Lista_Valores__c> horariosInsertar = new List<CC_Lista_Valores__c>();

            CC_Lista_Valores__c horario = new CC_Lista_Valores__c();
            horario.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            horario.Name = 'Calendario_servicios';
            horario.CC_Activa__c = true;
            insert horario;

            CC_Lista_Valores__c horarioAccionista = new CC_Lista_Valores__c();
            horarioAccionista.Name = 'Accionista';
            horarioAccionista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            horarioAccionista.CC_Valor__c = '9';
            horarioAccionista.CC_Valor2__c = '23';
            horarioAccionista.CC_Valor_SFDC__c = 'L-J';
            horarioAccionista.CC_Lista__c = horario.Id;
            horariosInsertar.add(horarioAccionista);

            CC_Lista_Valores__c horarioAccionista2 = new CC_Lista_Valores__c();
            horarioAccionista2.Name = 'Accionista';
            horarioAccionista2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            horarioAccionista2.CC_Valor__c = '9:30';
            horarioAccionista2.CC_Valor2__c = '19';
            horarioAccionista2.CC_Valor_SFDC__c = 'V';
            horarioAccionista2.CC_Lista__c = horario.Id;
            horariosInsertar.add(horarioAccionista2);

            CC_Lista_Valores__c horarioImaginBank = new CC_Lista_Valores__c();
            horarioImaginBank.Name = 'ImaginBank';
            horarioImaginBank.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            horarioImaginBank.CC_Valor__c = '9:30';
            horarioImaginBank.CC_Valor2__c = '19';
            horarioImaginBank.CC_Valor_SFDC__c = 'L-J';
            horarioImaginBank.CC_Lista__c = horario.Id;
            horariosInsertar.add(horarioImaginBank);

            CC_Lista_Valores__c horarioImaginBank2 = new CC_Lista_Valores__c();
            horarioImaginBank2.Name = 'ImaginBank';
            horarioImaginBank2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            horarioImaginBank2.CC_Valor__c = '9:30';
            horarioImaginBank2.CC_Valor2__c = '19';
            horarioImaginBank2.CC_Valor_SFDC__c = 'V';
            horarioImaginBank2.CC_Lista__c = horario.Id;
            horariosInsertar.add(horarioImaginBank2);
            insert horariosInsertar;


            List<CC_Lista_Valores__c> festivosInsertar = new List<CC_Lista_Valores__c>();

            CC_Lista_Valores__c festivos = new CC_Lista_Valores__c();
            festivos.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            festivos.Name = 'Festivos nacionales';
            festivos.CC_Activa__c = true;
            insert festivos;

            CC_Lista_Valores__c festivo1 = new CC_Lista_Valores__c();
            festivo1.Name = 'Festivo';
            festivo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo1.CC_Valor__c = '11';
            festivo1.CC_Valor2__c = '11';
            festivo1.CC_Lista__c = festivos.Id;
            festivo1.CC_Activa__c = true;
            festivosInsertar.add(festivo1);

            CC_Lista_Valores__c festivo2 = new CC_Lista_Valores__c();
            festivo2.Name = 'Festivo2';
            festivo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            festivo2.CC_Valor__c = '10';
            festivo2.CC_Valor2__c = '10';
            festivo2.CC_Lista__c = festivos.Id;
            festivo2.CC_Activa__c = true;
            festivosInsertar.add(festivo2);
            insert festivosInsertar;

            Test.startTest();
            caso.Status = 'Pendiente Colaborador';
            caso2.Status = 'Pendiente Interno';

            casos.clear();
            casos.add(caso);
            casos.add(caso2);
            update casos;

            Test.stopTest();

            System.assertEquals(caso.Status, 'Pendiente Colaborador', 'La asignación del nuevo estado no ha funcionado.');
            System.assertEquals(caso2.Status, 'Pendiente Interno', 'La asignación del nuevo estado no ha funcionado.');
        }

    }

    @isTest
    static void testCalculateStateTimes() {
        
        User pruebas = [SELECT Id FROM User WHERE LastName = 'last211' LIMIT 1];

        System.runAs(pruebas){

        // Obtener el Business Hours "Empleados"
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'HDT_Empleados_TMR' LIMIT 1];

        // Crear un caso en el estado 'Activo'
        Case case1 = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),
            Status = 'Activo',
            CC_Tiempo_Nivel_1__c = 0,
            CC_Tiempo_Nivel_2__c = 0,
            CC_Tiempo_Nivel_3__c = 0,
            CC_Tiempo_Empleado__c = 0
        );
        insert case1;
        
        // Simular que el caso fue creado hace 1 día
        Test.setCreatedDate(case1.Id, DateTime.now().addDays(-1));

        // Simular un cambio de estado a 'Pendiente Cliente'
        Test.startTest();
        case1.Status = 'Pendiente Cliente';
        update case1;

       // Simulación de la actualización del caso
       Case caseOld = [SELECT Id, Status, LastModifiedDate FROM Case WHERE Id = :case1.Id];
       caseOld.Status = 'Pendiente Revision';
       update caseOld;
        

        // Llamar al método para calcular tiempos
        Map<Id, Case> mapOldCases = new Map<Id, Case>{case1.Id => case1};
        List<Case> listNewCases = [SELECT Id, Status, CC_Tiempo_Nivel_1__c, CC_Tiempo_Nivel_2__c, CC_Tiempo_Nivel_3__c, CC_Tiempo_Empleado__c FROM Case WHERE Id IN :mapOldCases.keySet()];
       
        HDT_Case_BU_TRHan.calculateStateTimes(mapOldCases, listNewCases);

        // Comprobar que el tiempo ha sido calculado correctamente en minutos
        Case updatedCase2 = [SELECT CC_Tiempo_Nivel_1__c, CC_Tiempo_Nivel_2__c, CC_Tiempo_Nivel_3__c, CC_Tiempo_Empleado__c FROM Case WHERE Id = :case1.Id];

        // Dependiendo de la hora actual y el horario laboral, verifica los cálculos
        //System.assertNotEquals(0, updatedCase2.CC_Tiempo_Nivel_1__c, 'El tiempo activo no debería ser cero.');
        System.assertEquals(0, updatedCase2.CC_Tiempo_Nivel_2__c, 'El tiempo pendiente cliente debería ser cero al iniciar el estado.');
        System.assertEquals(0, updatedCase2.CC_Tiempo_Nivel_3__c, 'El tiempo pendiente incidencia debería ser cero.');
        System.assertEquals(0, updatedCase2.CC_Tiempo_Empleado__c, 'El tiempo pendiente revisión debería ser cero.');

        Test.stopTest();
        }
    }

    @isTest
    static void testMultipleStateChanges() {
        User pruebas = [SELECT Id FROM User WHERE LastName = 'last211' LIMIT 1];

        System.runAs(pruebas){

        // Crear un caso en el estado 'Activo'
        Case case2 = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),
            Status = 'Activo',
            CC_Tiempo_Nivel_1__c = 10,
            CC_Tiempo_Nivel_2__c = 11,
            CC_Tiempo_Nivel_3__c = 12,
            CC_Tiempo_Empleado__c = 0
            
        );
        insert case2;

        // Simular que el caso fue creado hace 1 día
        Test.setCreatedDate(case2.Id, DateTime.now().addDays(-1));

        Case caseOld1 = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),
            Status = 'Pendiente Cliente',
            CC_Tiempo_Nivel_1__c = 10,
            CC_Tiempo_Nivel_2__c = 11,
            CC_Tiempo_Nivel_3__c = 12,
            CC_Tiempo_Empleado__c = 0
            
        );
        insert caseOld1;

        // Simular que el caso fue creado hace 1 día
        Test.setCreatedDate(caseOld1.Id, DateTime.now().addDays(-1));

        Case caseOld2 = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),
            Status = 'Pendiente Incidencia',
            CC_Tiempo_Nivel_1__c = 10,
            CC_Tiempo_Nivel_2__c = 11,
            CC_Tiempo_Nivel_3__c = 12,
            CC_Tiempo_Empleado__c = 0
            
        );
        insert caseOld2;
        
        // Simular que el caso fue creado hace 1 día
        Test.setCreatedDate(caseOld2.Id, DateTime.now().addDays(-1));

        
        Case caseOld3 = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),
            Status = 'Pendiente Revisión',
            CC_Tiempo_Nivel_1__c = 10,
            CC_Tiempo_Nivel_2__c = 11,
            CC_Tiempo_Nivel_3__c = 12,
            CC_Tiempo_Empleado__c = 0
            
        );
        insert caseOld3;
        
        // Simular que el caso fue creado hace 1 día
        Test.setCreatedDate(caseOld3.Id, DateTime.now().addDays(-1));

        // Llamar al método para calcular tiempos
        Map<Id, Case> mapOldCases = new Map<Id, Case>{case2.Id => case2,caseOld1.Id => caseOld1,caseOld2.Id => caseOld2,caseOld3.Id => caseOld3};
        List<Case> listNewCases = [SELECT Id, Status, CC_Tiempo_Nivel_1__c, CC_Tiempo_Nivel_2__c, CC_Tiempo_Nivel_3__c, CC_Tiempo_Empleado__c FROM Case WHERE Id IN :mapOldCases.keySet()];
        
        HDT_Case_BU_TRHan.calculateStateTimes(mapOldCases, listNewCases);

        // Comprobar que los tiempos han sido acumulados correctamente
        Case updatedCase2 = [SELECT CC_Tiempo_Nivel_1__c, CC_Tiempo_Nivel_2__c, CC_Tiempo_Nivel_3__c, CC_Tiempo_Empleado__c FROM Case WHERE Id = :case2.Id];

        // Verificación de cálculos acumulativos
        System.assertEquals(10, updatedCase2.CC_Tiempo_Nivel_1__c, 'El tiempo activo debería acumularse.');
        System.assertNotEquals(0, updatedCase2.CC_Tiempo_Nivel_2__c, 'El tiempo pendiente cliente debería acumularse.');
        System.assertNotEquals(0, updatedCase2.CC_Tiempo_Nivel_3__c, 'El tiempo pendiente incidencia debería acumularse.');
        }
    }

    @isTest
    static void testCalculateStateTimes1() {

        User pruebas = [SELECT Id FROM User WHERE LastName = 'last211' LIMIT 1];

        System.runAs(pruebas){

        // Crear un caso en el estado 'Activo'
        Case case4 = new Case(
            recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('HDT_Empleado').getRecordTypeId(),
            Status = 'Activo',
            CC_Tiempo_Nivel_1__c = 0,
            CC_Tiempo_Nivel_2__c = 0,
            CC_Tiempo_Nivel_3__c = 0,
            CC_Tiempo_Empleado__c = 0
        );
        insert case4;

       // Simular que el caso fue creado hace 60 minutos
       DateTime createdDate = DateTime.now().addMinutes(-60);
       Test.setCreatedDate(case4.Id, createdDate);

        // Simular un cambio de estado sin que haya registros en el historial (la lista historyList estará vacía)
        Test.startTest();

        Case caseToUpdate = [SELECT Id, Status FROM Case WHERE Id = :case4.Id];
        caseToUpdate.Status = 'Pendiente Cliente';
        update caseToUpdate;

        // Llamar al método para calcular tiempos
        Map<Id, Case> mapOldCases = new Map<Id, Case>{case4.Id => [SELECT Id, Status, CreatedDate, CC_Tiempo_Nivel_1__c, CC_Tiempo_Nivel_2__c, CC_Tiempo_Nivel_3__c, CC_Tiempo_Empleado__c 
            FROM Case WHERE Id = :case4.Id]};
        List<Case> listNewCases = [SELECT Id, Status, CC_Tiempo_Nivel_1__c, CC_Tiempo_Nivel_2__c, CC_Tiempo_Nivel_3__c, CC_Tiempo_Empleado__c 
        FROM Case WHERE Id IN :mapOldCases.keySet()];
        
        HDT_Case_BU_TRHan.calculateStateTimes(mapOldCases, listNewCases);

        // Comprobar que el tiempo ha sido calculado correctamente
        Case updatedCase = [SELECT CC_Tiempo_Nivel_1__c, CC_Tiempo_Nivel_2__c, CC_Tiempo_Nivel_3__c, CC_Tiempo_Empleado__c FROM Case WHERE Id = :case4.Id];

         // Verificar que el tiempo ha sido calculado y almacenado correctamente
         Long expectedTimeInMinutes = 60; // 60 minutos que deberían haberse calculado
         //System.assertEquals(expectedTimeInMinutes, updatedCase.CC_Tiempo_Nivel_1__c, 'El tiempo activo debería ser de 60 minutos.');
         System.assertEquals(0, updatedCase.CC_Tiempo_Nivel_2__c, 'El tiempo pendiente cliente debería ser cero al iniciar el estado.');
         System.assertEquals(0, updatedCase.CC_Tiempo_Nivel_3__c, 'El tiempo pendiente incidencia debería ser cero.');
         System.assertEquals(0, updatedCase.CC_Tiempo_Empleado__c, 'El tiempo pendiente revisión debería ser cero.');
 
         Test.stopTest();
        }
    }
    }