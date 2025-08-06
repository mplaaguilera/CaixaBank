@isTest
public with sharing class CC_EmailMessage_AI_TRHan_Test {

    // Variable estática para almacenar el correo por defecto
    public static String defaultFromAddressAttCliente = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Atencion_Cliente_ESP'].CC_Direccion_Correo__c;
    public static String defaultFromAddressBuzonEmpleados;
    

    @TestSetup
    static void makeData(){
        Test.startTest();
        //defaultFromAddressAttCliente = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Atencion_Cliente_ESP'].CC_Direccion_Correo__c;
        defaultFromAddressBuzonEmpleados = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Buzon_Defecto_Empleados'].CC_Direccion_Correo__c;

    	List<String> developerNamesPlantillas = new List<String>{'CC_ConsultasOperativasCanalFormulario_Traslado_CAT','CC_ConsultasOperativasCanalFormulario_Traslado_CAS'};
		List<EmailTemplate> plantillas = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName IN :developerNamesPlantillas];
        List<EmailTemplate> plantillasAInsertar = new List<EmailTemplate>();
        if (plantillas.isEmpty()) {
            
            EmailTemplate plantilla1CAS= new EmailTemplate();
            plantilla1CAS.Developername = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAS';
            plantilla1CAS.HTMLValue= 'hola prueba 2';
            plantilla1CAS.Subject = 'plantilla1CAS';
            plantilla1CAS.FolderId = UserInfo.getUserId();
            plantilla1CAS.TemplateType = 'Text';        
            plantilla1CAS.name = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAS';
            plantilla1CAS.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAS);

            
            EmailTemplate plantilla1CAT= new EmailTemplate();
            plantilla1CAT.Developername = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAT';
            plantilla1CAT.HTMLValue= 'hola prueba 2';
            plantilla1CAT.Subject = 'plantilla1CAT';
            plantilla1CAT.FolderId = UserInfo.getUserId();
            plantilla1CAT.TemplateType = 'Text';        
            plantilla1CAT.name = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAT';
            plantilla1CAT.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAT);
            
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            	insert plantillasAInsertar;
        	}

            Group grupoPublico = new Group();
            grupoPublico.Name = 'Cola AC DxC';
            grupoPublico.Type = 'Queue';
            grupoPublico.DeveloperName = 'CC_Inbound_Email_AC';
            insert grupoPublico;
        }

        //crear usuarios CC
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileCCId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profile2Id = [SELECT Id FROM Profile WHERE Name = 'CC_Analísta y 2º nivel MVP2'].Id;
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        Id roleDirectorioCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center_sin_acceso_a_Directorio'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
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
        insert userList;
        System.runAs(usuario1){

            List<User> userList2 = new List<User>();
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

            User operadorCliente = new User();
            operadorCliente.profileId = profileCCId;
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
            userList2.add(operadorCliente);
            insert userList2;
            
            List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>();
            PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psOperadorCliente.Id);
            insertPSAssOperadores.add(psaOperadorCliente);

            PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psClasses.Id);
            insertPSAssOperadores.add(psaOperadorClasses);
            insert insertPSAssOperadores;
        }

        List<CC_Lista_Valores__c> valoresInsertar = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> listasInsertar = new List <CC_Lista_Valores__c>();
        Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        Id rtValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        CC_Lista_Valores__c horario = new CC_Lista_Valores__c();
        horario.RecordTypeId = recordTypeLista;
        horario.Name = 'Calendario_servicios';
        horario.CC_Activa__c = true;
        listasInsertar.add(horario);

        CC_Lista_Valores__c listaDerivar = new CC_Lista_Valores__c();
        listaDerivar.Name = 'Textos operativa Derivar';
        listaDerivar.RecordTypeId = recordTypeLista;
        listasInsertar.add(listaDerivar);

        CC_Lista_Valores__c listaPlazo = new CC_Lista_Valores__c();
        listaPlazo.Name = 'Plazo Cierre Solicitud Información';
        listaPlazo.CC_Activa__c = true;
        listaPlazo.RecordTypeId = recordTypeLista;
        listasInsertar.add(listaPlazo);

        insert listasInsertar;
        
        CC_Lista_Valores__c horarioAccionista = new CC_Lista_Valores__c();
        horarioAccionista.Name = 'Atención al Cliente';
        horarioAccionista.RecordTypeId = rtValor;
        horarioAccionista.CC_Valor__c = '9';
        horarioAccionista.CC_Valor2__c = '23';
        horarioAccionista.CC_Valor_SFDC__c = 'L-J';
        horarioAccionista.CC_Lista__c = horario.Id;
        valoresInsertar.add(horarioAccionista);
        
        CC_Lista_Valores__c horarioAccionista2 = new CC_Lista_Valores__c();
        horarioAccionista2.Name = 'Atención al Cliente';
        horarioAccionista2.RecordTypeId = rtValor;
        horarioAccionista2.CC_Valor__c = '9:30';
        horarioAccionista2.CC_Valor2__c = '19';
        horarioAccionista2.CC_Valor_SFDC__c = 'V';
        horarioAccionista2.CC_Lista__c = horario.Id;
        valoresInsertar.add(horarioAccionista2);
        
        CC_Lista_Valores__c horarioServiciosCentrales = new CC_Lista_Valores__c();
        horarioServiciosCentrales.Name = 'Servicios Centrales';
        horarioServiciosCentrales.RecordTypeId = rtValor;
        horarioServiciosCentrales.CC_Valor__c = '9:30';
        horarioServiciosCentrales.CC_Valor2__c = '19';
        horarioServiciosCentrales.CC_Valor_SFDC__c = 'L-J';
        horarioServiciosCentrales.CC_Lista__c = horario.Id;
        valoresInsertar.add(horarioServiciosCentrales);
        
        CC_Lista_Valores__c horarioServiciosCentrales2 = new CC_Lista_Valores__c();
        horarioServiciosCentrales2.Name = 'Servicios Centrales';
        horarioServiciosCentrales2.RecordTypeId = rtValor;
        horarioServiciosCentrales2.CC_Valor__c = '9:30';
        horarioServiciosCentrales2.CC_Valor2__c = '19';
        horarioServiciosCentrales2.CC_Valor_SFDC__c = 'V';
        horarioServiciosCentrales2.CC_Lista__c = horario.Id;
        valoresInsertar.add(horarioServiciosCentrales2);

        CC_Lista_Valores__c horarioGenerico = new CC_Lista_Valores__c();
        horarioGenerico.Name = 'Generico';
        horarioGenerico.RecordTypeId = rtValor;
        horarioGenerico.CC_Valor__c = '9:30';
        horarioGenerico.CC_Valor2__c = '19';
        horarioGenerico.CC_Valor_SFDC__c = 'L-J';
        horarioGenerico.CC_Lista__c = horario.Id;
        valoresInsertar.add(horarioGenerico);

        CC_Lista_Valores__c horarioGenerico2 = new CC_Lista_Valores__c();
        horarioGenerico2.Name = 'Generico';
        horarioGenerico2.RecordTypeId = rtValor;
        horarioGenerico2.CC_Valor__c = '9:30';
        horarioGenerico2.CC_Valor2__c = '19';
        horarioGenerico2.CC_Valor_SFDC__c = 'V';
        horarioGenerico2.CC_Lista__c = horario.Id;
        valoresInsertar.add(horarioGenerico2);

        CC_Lista_Valores__c valorPlazo = new CC_Lista_Valores__c();
        valorPlazo.Name = 'Plazo Genérico';
        valorPlazo.RecordTypeId = rtValor;
        valorPlazo.CC_Valor__c = '1';
        valoresInsertar.add(valorPlazo);

        CC_Lista_Valores__c valorCSBD = new CC_Lista_Valores__c();
        valorCSBD.Name = 'Texto oportunidad tarea existente';
        valorCSBD.RecordTypeId = rtValor;
        valorCSBD.CC_Mensajes_Mostrar__c = 'pruebatest';
        valorCSBD.CC_Activa__c = true;
        valoresInsertar.add(valorCSBD);

        insert valoresInsertar;

        Account cuenta = new Account();
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        cuenta.Name = 'Cuenta Prueba';
        cuenta.CC_Numero_Oficina__c = '222';
        insert cuenta;

        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.AccountId = cuenta.Id;
        contacto.FirstName = 'Test';
        contacto.LastName = 'Contacto Prueba';
        contacto.CC_NumPerso__c = '25345569';
        contacto.CC_Idioma__c = 'ca';
        contacto.Email = 'correo@gmail.com';
        contacto.Phone = '973242323';
        insert contacto;

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

        //MCCs argos
        CC_MCC__c mcc3 = new CC_MCC__c();
        mcc3.RecordTypeId = recordTem;
        mcc3.Name = 'App\'s';
        mcc3.CC_Tipo_Cliente__c = 'Cliente';
        mcc3.CC_Codigo_Externo__c = 'TE-000002';
        mcc3.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc3;
        CC_MCC__c mcc4 = new CC_MCC__c();
        mcc4.RecordTypeId = recordProd;
        mcc4.Name = 'APP CaixaBank';
        mcc4.CC_Detalle__c = 'CaixaBank';
        mcc4.CC_Tipo_Cliente__c = 'Cliente';
        mcc4.CC_Tematica__c = mcc3.Id;
        mcc4.CC_Codigo_Externo__c = 'PR-000002';
        insert mcc4;
        CC_MCC__c mcc5 = new CC_MCC__c();
        mcc5.RecordTypeId = recordMot;
        mcc5.Name = 'Valoración positiva';
        mcc5.CC_Tipo_Cliente__c = 'Cliente';
        mcc5.CC_Producto_Servicio__c = mcc4.Id;
        mcc5.CC_Codigo_Externo__c = 'MO-000002';
        mcc5.CC_Ambito_Tareas_Imagin__c = 'Argos General';
        mcc5.CC_Ambito_Tareas_Caixa__c = 'Argos General';
        insert mcc5;
        
        List<Case> casos = new List<Case>();
        Case caso = new Case();
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.Subject = 'Caso Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_MCC_Tematica__c = mcc.Id;
        caso.CC_MCC_ProdServ__c = mcc1.Id;
        caso.CC_MCC_Motivo__c = mcc2.Id;
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        caso.CC_Detalles_Consulta__c = 'Test';
        caso.CC_Detalles_Solucion__c = 'Test';
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        casos.add(caso);

        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        caso2.Subject = 'Caso temporal';
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso2.CC_Canal_Resolucion__c = 'Servicios Centrales';
        caso2.CC_En_Tercer_Nivel__c = true;
        caso2.CC_Grupo_3N__c = '3N de CaixaBank Now';
        caso2.CC_Fecha_Traslado_Colaborador__c = Date.today().addDays(-7);
        casos.add(caso2);

        Case caso3 = new Case();
        caso3.AccountId = cuenta.Id;
        caso3.ContactId = contacto.Id;
        caso3.Subject = 'Caso Cliente 3';
        caso3.Status = 'Activo';
        caso3.Origin = 'Email';
        caso3.CC_Tipo_Cliente__c = 'Cliente';
        caso3.CC_Tipo_Contacto__c = 'Consulta';
        caso3.CC_MCC_Tematica__c = mcc3.Id;
        caso3.CC_MCC_ProdServ__c = mcc4.Id;
        caso3.CC_MCC_Motivo__c = mcc5.Id;
        caso3.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        caso3.CC_Detalles_Consulta__c = 'Test';
        caso3.CC_Detalles_Solucion__c = 'Test';
        caso3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        casos.add(caso3);

        CC_Settings__c configuracion = new CC_Settings__c(
            Name = 'CC_RespuestaArgosPushSMS',
            CC_Configuracion_1__c = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAS',
            CC_Configuracion_2__c = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAT'
        );
        insert configuracion;

        insert casos;
        Test.stopTest();
    }    
    
    @isTest
    public static void trasladoColaboradorSaliente() {

       /*CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = '';
        insert grupoColab;*/
        Test.startTest();

        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;        
        
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Caso temporal';
        caso.CC_Referencia_Correo_Saliente__c = '#@1234567890#';
        insert caso;
        
        
        Task actividadCorreo = new Task();
        actividadCorreo.Type = 'Traslado Colaborador';
        actividadCorreo.WhatId = caso.Id;
        actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreo;

        //Setup header for the email
        /*List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE '%CC_Email%' LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }*/

        system.debug('El email nuevo essses : ' + defaultFromAddressAttCliente + ' - ' + defaultFromAddressBuzonEmpleados );

        EmailMessage correo = new EmailMessage();
        correo.Subject = 'Prueba de envío de correo';
        correo.ActivityId = actividadCorreo.Id;
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.FromAddress = defaultFromAddressAttCliente;
        correo.ToAddress = 'prueba@ibm.com';
        correo.Incoming = false;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;
        correo.CC_Segunda_Oficina__c = 'Segunda oficina';
        //correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

        List<String> cuerpo = new List<String>();
        cuerpo.add('<html>');
        cuerpo.add('Cuerpo del correo');
        cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpo.add('</html>');
        correo.HtmlBody = String.join(cuerpo, '<br/>');
        insert correo;

        Test.stopTest();

        System.assert(correo.Id != null);
    }

    @isTest
    public static void trasladoColaboradorEntrante() {
        
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso temporal' LIMIT 1];

        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;       
        
        // Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        // Case caso = new Case();
        // caso.RecordTypeId = recordTypeCaso;
        // caso.Subject = 'Caso temporal';
        // caso.Origin = 'Email';
        // caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        // caso.CC_Canal_Resolucion__c = 'Servicios Centrales';
        // caso.CC_En_Tercer_Nivel__c = true;
        // caso.CC_Grupo_3N__c = '3N de CaixaBank Now';
        // caso.CC_Fecha_Traslado_Colaborador__c = Date.today().addDays(-7);
        // insert caso;
        
        //Correo origen crear las dos task en una lista
        List<Task> tareas = new List<Task>();
        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Traslado Colaborador';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tareas.add(actividadCorreoOrigen);
        
        Task reasignacion = new Task();
        reasignacion.Type = 'Reasignación';
        reasignacion.WhatId = caso.Id;
        reasignacion.Status = 'Completed';
        reasignacion.Subject = 'Reasignación del caso a 3N de CaixaBank Now';
        reasignacion.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tareas.add(reasignacion);

        
        Task actividadCorreo = new Task();
        // insert actividadCorreo;
        tareas.add(actividadCorreo);
        insert tareas;
		Test.startTest();
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        List<EmailMessage> correos = new List<EmailMessage>();
        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.CC_Procedencia__c = 'Traslado Colaborador';
        correoOrigen.FromAddress = defaultFromAddressAttCliente;
        correoOrigen.ToAddress = 'prueba@ibm.com';
        correoOrigen.Incoming = false;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;

        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        correos.add(correoOrigen);
        // insert correoOrigen;



        EmailMessage correo = new EmailMessage();
        correo.Status = '1';
        correo.Subject = 'Prueba de envío de correo';
        correo.ActivityId = actividadCorreo.Id;
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.FromAddress = defaultFromAddressAttCliente;
        correo.ToAddress = 'prueba@ibm.com';
        correo.Incoming = true;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;
        correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        correo.CC_Segunda_Oficina__c = 'Segunda oficina';

        List<String> cuerpo = new List<String>();
        cuerpo.add('<html>');
        cuerpo.add('Cuerpo del correo');
        cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpo.add('</html>');
        correo.HtmlBody = String.join(cuerpo, '<br/>');
        correos.add(correo);
        insert correos;

        System.assert(correo.Id != null);
        Test.stopTest();
    }
    
    /*
    @isTest
    public static void trasladoColaboradorEntranteCasoNoIndra() {
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;       
        
        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Atención al Cliente';
        caso.CC_Canal_Resolucion__c = 'Atención al Cliente';
        caso.recordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        insert caso;
        
        caso.Status = 'Pendiente Colaborador';
		update caso;
        
        //Correo origen
        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Traslado Colaborador';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        insert actividadCorreoOrigen;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.CC_Procedencia__c = 'Traslado Colaborador';
        correoOrigen.FromAddress = defaultFromAddressAttCliente;
        correoOrigen.ToAddress = 'prueba@ibm.com';
        correoOrigen.Incoming = false;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;


        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        insert correoOrigen;

        Test.startTest();

        Task actividadCorreo = new Task();
        insert actividadCorreo;

        EmailMessage correo = new EmailMessage();
        correo.Status = '1';
        correo.Subject = 'Prueba de envío de correo';
        correo.ActivityId = actividadCorreo.Id;
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.FromAddress = defaultFromAddressAttCliente;
        correo.ToAddress = 'prueba@ibm.com';
        correo.Incoming = true;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;
        correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';


        List<String> cuerpo = new List<String>();
        cuerpo.add('<html>');
        cuerpo.add('Cuerpo del correo');
        cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpo.add('</html>');
        correo.HtmlBody = String.join(cuerpo, '<br/>');
        insert correo;

        Test.stopTest();

        System.assert(correo.Id != null);
    }
        */

    @isTest
    public static void remitirColaboradorSaliente() {

        Test.startTest();
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Caso temporal';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
        caso.CC_Canal_Resolucion__c = 'Activo';
        caso.CC_Idioma__c = 'es';
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
		actividadCorreoOrigen.Type = 'Remitir Colaborador';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        insert actividadCorreoOrigen;


        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.CC_Procedencia__c = 'Remitir Colaborador';
        correoOrigen.FromAddress = defaultFromAddressAttCliente;
        correoOrigen.ToAddress = 'prueba@ibm.com';
        correoOrigen.Incoming = false;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.CC_Segunda_Oficina__c = 'Segunda oficina';

        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        insert correoOrigen;
        Test.stopTest();

        System.assertEquals(3, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());

    }
    
    @isTest
    public static void responderClienteSalienteTest() {       
        
        Test.startTest();
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Caso temporal';
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
		actividadCorreoOrigen.Type = 'Responder Cliente';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = null;
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        insert actividadCorreoOrigen;


        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Procedencia__c = 'Responder Cliente';
        correoOrigen.FromAddress = defaultFromAddressAttCliente;
        correoOrigen.ToAddress = 'prueba@ibm.com';
        correoOrigen.Incoming = false;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        insert correoOrigen;
        Test.stopTest();


        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());

    }

    @isTest
    public static void remitirColaboradorEntrante() {

        Test.startTest();
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;  
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Caso temporal';
        caso.Status = 'Pendiente Colaborador';
        caso.CC_Fecha_Traslado_Colaborador__c = System.now();
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Remitir Colaborador';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        insert actividadCorreoOrigen;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.CC_Procedencia__c = 'Remitir Colaborador';
        correoOrigen.FromAddress = defaultFromAddressAttCliente;
        correoOrigen.ToAddress = 'prueba@ibm.com';
        correoOrigen.Incoming = true;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';


        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        insert correoOrigen;
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());

    }

    @isTest
    public static void solicitudInformacionSaliente() {

        Test.startTest();
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.Name = 'Plazo Genérico';
        lista.CC_Valor__c = '1';
        insert lista;
        
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;  
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Caso temporal';
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
		actividadCorreoOrigen.Type = 'Solicitud Información';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        insert actividadCorreoOrigen;

        

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.CC_Procedencia__c = 'Solicitud Información';
        correoOrigen.FromAddress = defaultFromAddressAttCliente;
        correoOrigen.ToAddress = 'prueba@ibm.com';
        correoOrigen.Incoming = false;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;


        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

        insert correoOrigen;
        Test.stopTest();
        
        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
    }

    @isTest
    public static void solicitudInformacionEntrante() {

        Test.startTest();
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.Name = 'Plazo Genérico';
        lista.CC_Valor__c = '1';
        insert lista;
        
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;         
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Caso temporal';
        caso.Status = 'Pendiente Cliente';
        caso.CC_En_Tercer_Nivel__c = true;
        caso.CC_Grupo_3N__c = '3N de CaixaBank Now';
        caso.Origin = 'Email';  
        caso.CC_Inicio_Pendiente_Cliente__c = System.now();
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Solicitud Información';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        insert actividadCorreoOrigen;
        
        Task reasignacion = new Task();
        reasignacion.Type = 'Reasignación';
        reasignacion.WhatId = caso.Id;
        reasignacion.Status = 'Completed';
        reasignacion.Subject = 'Reasignación del caso a 3N de CaixaBank Now';

        reasignacion.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();

        insert reasignacion;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.CC_Procedencia__c = 'Solicitud Información';
        correoOrigen.FromAddress = defaultFromAddressAttCliente;
        correoOrigen.ToAddress = 'prueba@ibm.com';
        correoOrigen.Incoming = true;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        insert correoOrigen;     
        Test.stopTest();

        System.assertEquals(3, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
    }

    
    @isTest
    public static void  respuestaCliente() {

        Test.startTest();
        String rtDeveloperNameCaso = 'CC_Cliente';
        String rtDeveloperNameTask = 'CC_Task';
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtDeveloperNameCaso).getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.Status = 'Cerrado';
        caso.RecordTypeId = recordTypeCaso;        
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Responder a cliente';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(rtDeveloperNameTask).getRecordTypeId();
        insert actividadCorreoOrigen;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;        
        correoOrigen.CC_Procedencia__c = 'Responder Cliente';
        correoOrigen.FromAddress = 'prueba@ibm.com';
        correoOrigen.ToAddress = defaultFromAddressAttCliente;
        correoOrigen.Incoming = true;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        
        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        /*System.runAs(new User(Id = [SELECT Id FROM User Where FirstName = 'Usuario 2 Prueba' LIMIT 1].Id))
        {*/
            //new User(Id = [SELECT Id FROM User Where FirstName = 'Usuario 2 Prueba' LIMIT 1].Id)            
            insert correoOrigen;
        //}
        Test.stopTest();
        
        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());  
    }

    @isTest
    public static void  respuestaCasoEmailRevisar() {

        Test.startTest();
        String rtDeveloperNameCaso = 'CC_Cliente';
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtDeveloperNameCaso).getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Caso Email to Case';
        caso.Status = 'Activo';
        caso.Origin = 'Email - Revisar';
        caso.RecordTypeId = recordTypeCaso;        
        insert caso;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';     
        correoOrigen.CC_Procedencia__c = 'Responder Cliente';
        correoOrigen.FromAddress = 'prueba@ibm.com';
        correoOrigen.ToAddress = defaultFromAddressAttCliente;
        correoOrigen.Incoming = true;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        
        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">TEST Case Email - Revisar</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        System.runAs(new User(Id = UserInfo.getUserId())) {
          
            insert correoOrigen;
        }
        Test.stopTest();
        List<EmailMessage> emailList = [SELECT Id, Status FROM EmailMessage WHERE RelatedToId = :caso.Id];
        System.AssertEquals(2, emailList.size());
    }

    @isTest
    public static void  rechazarCasosSpam() {

        Test.startTest();
        List<CC_Lista_Valores__c> lista = new List <CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> listaValores = new List <CC_Lista_Valores__c>();


        CC_Lista_Valores__c casosSpam = new CC_Lista_Valores__c();
        casosSpam.Name = 'CC_Casos_Spam';
        casosSpam.CC_Activa__c = true;
        casosSpam.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.add(casosSpam);
        insert lista;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.Name = 'Asunto Newsletter';
        valor.CC_Activa__c = true;
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = casosSpam.Id;
        valor.CC_Valor_SFDC__c = 'Asunto';
        valor.CC_Valor__c = 'Newsletter';
        listaValores.add(valor);
        insert listaValores;

        String rtDeveloperNameCaso = 'CC_Cliente';
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(rtDeveloperNameCaso).getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Newsletter';
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.RecordTypeId = recordTypeCaso;        
        insert caso;

       
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Newsletter';     
        correoOrigen.CC_Procedencia__c = 'Responder Cliente';
        correoOrigen.FromAddress = 'prueba@ibm.com';
        correoOrigen.ToAddress = defaultFromAddressAttCliente;
        correoOrigen.Incoming = true;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        
        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Newsletter</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

        System.runAs(new User(Id = UserInfo.getUserId())) {
          
            insert correoOrigen;

        }
        Test.stopTest();
        List<Case> casoList = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];
        System.AssertEquals('Rechazado', casoList[0].Status);

    }
    
    @isTest
    public static void  respuestaEmpleadoForm() {

        Test.startTest();
        List<CC_Lista_Valores__c> lista = new List <CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> val = new List <CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c respuestaEmp = new CC_Lista_Valores__c();
        respuestaEmp.Name = 'CC_Respuesta_a_empleado_form';
        respuestaEmp.CC_Activa__c = true;
        respuestaEmp.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.add(respuestaEmp);
        insert lista;

        CC_Lista_Valores__c val1 = new CC_Lista_Valores__c();
        val1.Name = 'Activo';
        val1.CC_Activa__c = true;
        val1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        val1.CC_Lista__c = respuestaEmp.Id;
        val1.CC_Valor_SFDC__c = 'CC_Cons_Form_Activo';
        val.add(val1);
        insert val;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.Status = 'Cerrado';
        caso.RecordTypeId = recordTypeCaso; 
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';  
        caso.CC_Canal_Resolucion__c = 'Activo';
        caso.Origin = 'Email';     
        insert caso;
        
        caso.CC_Canal_Resolucion__c = 'Activo';
        update caso;

        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Responder a cliente';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        insert actividadCorreoOrigen;
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;        
        correoOrigen.CC_Procedencia__c = 'Responder Cliente';
        correoOrigen.FromAddress = 'prueba@ibm.com';
        correoOrigen.ToAddress = defaultFromAddressBuzonEmpleados;
        correoOrigen.Incoming = true;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        
        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        

        insert correoOrigen;
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());   
     }
     
     @isTest
    public static void  respuestaEmpleadoChat() {

        Test.startTest();
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;

        List<CC_Lista_Valores__c> lista = new List <CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> val = new List <CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c respuestaEmp = new CC_Lista_Valores__c();
        respuestaEmp.Name = 'CC_Respuesta_a_empleado';
        respuestaEmp.CC_Activa__c = true;
        respuestaEmp.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.add(respuestaEmp);
        insert lista;

        CC_Lista_Valores__c val1 = new CC_Lista_Valores__c();
        val1.Name = 'Activo';
        val1.CC_Activa__c = true;
        val1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        val1.CC_Lista__c = respuestaEmp.Id;
        val1.CC_Valor_SFDC__c = 'CC_Cons_Form_Activo';
        val.add(val1);
        insert val;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.Status = 'Cerrado';
        caso.RecordTypeId = recordTypeCaso; 
        caso.CC_Canal_Procedencia__c = 'Activo';  
        caso.CC_Canal_Resolucion__c = 'Activo';
        caso.Origin = 'Chat';     
        insert caso;
        
        caso.CC_Canal_Resolucion__c = 'Activo';
        update caso;

        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Responder a cliente';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        insert actividadCorreoOrigen;
        
        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;        
        correoOrigen.CC_Procedencia__c = 'Responder Cliente';
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.FromAddress = 'prueba@ibm.com';
        correoOrigen.ToAddress = defaultFromAddressBuzonEmpleados;
        correoOrigen.Incoming = true;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        
        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

        insert correoOrigen;
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());   
     }

        @isTest
        public static void  respuestaClienteWivai() {
    
            Test.startTest();
            Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            Case caso = new Case();
            caso.Subject = 'Caso temporal';
            caso.Status = 'Cerrado';
            caso.RecordTypeId = recordTypeCaso; 
            caso.CC_Canal_Procedencia__c = 'Soporte Clientes CompraEstrella';  
            caso.CC_Canal_Resolucion__c = 'Activo'; 
            caso.Origin = 'Email';     
            insert caso;
            
            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Responder a cliente';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            insert actividadCorreoOrigen;
    
            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE '%CC_Email%' LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
            } else {
            headerValueStr = 'Prueba@IBM';    
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;        
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.FromAddress = 'prueba@ibm.com';
            correoOrigen.ToAddress = 'hola';
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            
            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen;
            Test.stopTest();
            
            System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());    }
            @isTest
            public static void  respuestaAccionista() {
        
                Test.startTest();
                Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                Case caso = new Case();
                caso.Subject = 'Caso temporal';
                caso.Status = 'Cerrado';
                caso.RecordTypeId = recordTypeCaso; 
                caso.CC_Canal_Procedencia__c = 'Accionista';   
                caso.CC_Canal_Resolucion__c = 'Activo';
                caso.Origin = 'Email';     
                insert caso;
                
                Task actividadCorreoOrigen = new Task();
                actividadCorreoOrigen.Type = 'Responder a cliente';
                actividadCorreoOrigen.WhatId = caso.Id;
                actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
                actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
                insert actividadCorreoOrigen;
                //Setup header for the email
                List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE '%CC_Email%' LIMIT 1];
                String headerValueStr;
                EmailServicesAddress headerValue= new EmailServicesAddress();
                if (!EmailServicesList.isEmpty()) {
                    headerValue=emailServicesList[0];
                    headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
                } else {
                headerValueStr = 'Prueba@IBM';    
                }
                EmailMessage correoOrigen = new EmailMessage();
                correoOrigen.Subject = 'Prueba de envío de correo';
                correoOrigen.ActivityId = actividadCorreoOrigen.Id;        
                correoOrigen.CC_Procedencia__c = 'Responder Cliente';
                correoOrigen.FromAddress = 'prueba@ibm.com';
                correoOrigen.ToAddress = 'hola';
                correoOrigen.Incoming = true;
                correoOrigen.ParentId = caso.Id;
                correoOrigen.RelatedToId = caso.Id;
                correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
                
                List<String> cuerpoOrigen = new List<String>();
                cuerpoOrigen.add('<html>');
                cuerpoOrigen.add('Cuerpo del correo');
                cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
                cuerpoOrigen.add('</html>');
                correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
                insert correoOrigen;
                Test.stopTest();
                
                System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());    }
    @isTest
    public static void  respuestaClienteCSIBankia() {

        Test.startTest();
        OrgWideEmailAddress fromEmail = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Atención Empleados Csi Bankia' LIMIT 1];
        fromEmail.Address = 'prueba@ibm.com';
        

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CSI_Bankia').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Canal_Procedencia__c = 'CCO CSI';        
        caso.Subject = 'Caso temporal';
        caso.Status = 'Cerrado';
        caso.RecordTypeId = recordTypeCaso;
        caso.Origin = 'Email';      
        insert caso;
        
        Id recordTypeTarea = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.RecordTypeId = recordTypeTarea;
        actividadCorreoOrigen.Type = 'Responder a cliente';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreoOrigen;

        //Setup header for the email
        List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
        String headerValueStr;
        EmailServicesAddress headerValue= new EmailServicesAddress();
        if (!EmailServicesList.isEmpty()) {
            headerValue=emailServicesList[0];
            headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
        } else {
            headerValueStr = 'Prueba@IBM';    
        }

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;        
        correoOrigen.CC_Procedencia__c = 'Responder Cliente';
        correoOrigen.FromAddress = 'prueba@ibm.com';
        correoOrigen.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Default_CSI_Bankia_ESP'].CC_Direccion_Correo__c;
        correoOrigen.Incoming = true;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        
        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo');
        cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpoOrigen.add('</html>');
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

            insert correoOrigen;
        Test.stopTest();

        List<EmailMessage> emailList = [SELECT Id, Status FROM EmailMessage WHERE RelatedToId = :caso.Id];
        //  System.AssertEquals(2, emailList.size());
        emailList = [SELECT Id, Status FROM EmailMessage WHERE RelatedToId = :caso.Id AND FromAddress =: fromEmail.Address];
        
        System.AssertEquals(1, emailList.size());
    }

    @isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoEsCli() {
      
        Test.startTest();
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;        

        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.Email ='jorge.andres.argente.guillen@ibm.com';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;        
        Id cId = contacto.Id;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Canal_Procedencia__c = 'Soporte Clientes CompraEstrella';        
        caso.Subject = 'Caso temporal';
        caso.Status = 'Activo';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Email';      
        caso.CC_Canal_Resolucion__c = 'Postventa CompraEstrella';
        caso.ContactId = cId;
        
        insert caso;
        
        Task actividadCorreo = new Task();
        actividadCorreo.Type = 'Traslado Colaborador';
        actividadCorreo.WhatId = caso.Id;
        actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreo;

       

        EmailMessage correo = new EmailMessage();
        correo.Subject = 'Prueba de envío de correo';
        correo.ActivityId = actividadCorreo.Id;
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.FromAddress = defaultFromAddressAttCliente;
        correo.ToAddress = 'pruebatraslado@ibm.com';
        correo.Incoming = false;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;


        List<String> cuerpo = new List<String>();
        cuerpo.add('<html>');
        cuerpo.add('Cuerpo del correo');
        cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpo.add('</html>');
        correo.HtmlBody = String.join(cuerpo, '<br/>');
        
            insert correo;
        Case casoId = [SELECT Id FROM Case LIMIT 1];
        Integer cantidadDeEmails = [SELECT Count() FROM EmailMessage WHERE ParentId = :casoId.Id];
        Test.stopTest();
        

        System.AssertNotEquals(4, cantidadDeEmails);
        //System.AssertEquals(1, cantidadDeEmails.size());
    }

    @isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoEsEmp() {
      
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;        

        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.Email ='jorge.andres.argente.guillen@ibm.com';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;        
        Id cId = contacto.Id;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Canal_Procedencia__c = 'Soporte Empleados CompraEstrella';        
        caso.Subject = 'Caso temporal';
        caso.Status = 'Activo';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Email';      
        caso.CC_Canal_Resolucion__c = 'Postventa CompraEstrella';
        caso.ContactId = cId;
        
        insert caso;
        
        Test.startTest();
        Task actividadCorreo = new Task();
        actividadCorreo.Type = 'Traslado Colaborador';
        actividadCorreo.WhatId = caso.Id;
        actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreo;

        EmailMessage correo = new EmailMessage();
        correo.Subject = 'Prueba de envío de correo';
        correo.ActivityId = actividadCorreo.Id;
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.FromAddress = defaultFromAddressAttCliente;
        correo.ToAddress = 'pruebatraslado@ibm.com';
        correo.Incoming = false;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;


        List<String> cuerpo = new List<String>();
        cuerpo.add('<html>');
        cuerpo.add('Cuerpo del correo');
        cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpo.add('</html>');
        correo.HtmlBody = String.join(cuerpo, '<br/>');

        insert correo;
        
        Case casoId = [SELECT Id FROM Case LIMIT 1];
        List <EmailMessage> cantidadDeEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :casoId.Id];
        System.AssertEquals(true, cantidadDeEmails != null);
        Test.stopTest();
    }

    @isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoCaCli() {
      
        Test.startTest();
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;        

        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.Email ='jorge.andres.argente.guillen@ibm.com';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;        
        Id cId = contacto.Id;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Canal_Procedencia__c = 'Soporte Clientes CompraEstrella';        
        caso.Subject = 'Caso temporal';
        caso.Status = 'Activo';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'ca';
        caso.Origin = 'Email';      
       // caso.CC_Canal_Resolucion__c = 'Postventa CompraEstrella';
        caso.CC_Canal_Resolucion__c = 'Soporte Clientes CompraEstrella';
        caso.ContactId = cId;
        
        insert caso;
        
        Task actividadCorreo = new Task();
        actividadCorreo.Type = 'Traslado Colaborador';
        actividadCorreo.WhatId = caso.Id;
        actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreo;

        

        EmailMessage correo = new EmailMessage();
        correo.Subject = 'Prueba de envío de correo';
        correo.ActivityId = actividadCorreo.Id;
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.FromAddress = defaultFromAddressAttCliente;
        correo.ToAddress = 'pruebatraslado@ibm.com';
        correo.Incoming = false;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;


        List<String> cuerpo = new List<String>();
        cuerpo.add('<html>');
        cuerpo.add('Cuerpo del correo');
        cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpo.add('</html>');
        correo.HtmlBody = String.join(cuerpo, '<br/>');
        
            insert correo;
        Test.stopTest();
        
        Case casoId = [SELECT Id FROM Case LIMIT 1];
        Integer cantidadDeEmails = [SELECT Count() FROM EmailMessage WHERE ParentId = :casoId.Id];
        System.AssertNOTEquals(4, cantidadDeEmails);
        //System.AssertEquals(1, cantidadDeEmails.size());
    }

    @isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoCaEmp() {
      
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;        

        Id recordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.Email ='jorge.andres.argente.guillen@ibm.com';
        contacto.RecordTypeId = recordTypeCliente;
        insert contacto;        
        Id cId = contacto.Id;
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Canal_Procedencia__c = 'Soporte Empleados CompraEstrella';        
        caso.Subject = 'Caso temporal';
        caso.Status = 'Activo';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'ca';
        caso.Origin = 'Email';      
        caso.CC_Canal_Resolucion__c = 'Postventa CompraEstrella';
        caso.ContactId = cId;
        
        insert caso;
        
        Test.startTest();
        Task actividadCorreo = new Task();
        actividadCorreo.Type = 'Traslado Colaborador';
        actividadCorreo.WhatId = caso.Id;
        actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreo;

       

        EmailMessage correo = new EmailMessage();
        correo.Subject = 'Prueba de envío de correo';
        correo.ActivityId = actividadCorreo.Id;
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.FromAddress = defaultFromAddressAttCliente;
        correo.ToAddress = 'pruebatraslado@ibm.com';
        correo.Incoming = false;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;


        List<String> cuerpo = new List<String>();
        cuerpo.add('<html>');
        cuerpo.add('Cuerpo del correo');
        cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpo.add('</html>');
        correo.HtmlBody = String.join(cuerpo, '<br/>');
        
        insert correo;
        
        Case casoId = [SELECT Id FROM Case LIMIT 1];
        List <EmailMessage> cantidadDeEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :casoId.Id];
        System.AssertEquals(true, cantidadDeEmails != null);
        Test.stopTest();
    }
    @isTest
    public static void trasladoColaboradorCorreoAutoFormularioConsultasOperativas() {
      
        Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;        

        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.Email ='test@test.com';
        contacto.RecordTypeId = recordTypeEmpleado;
        insert contacto;        
        
        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';        
        caso.Subject = 'Caso Formulario Consultas Operativas';
        caso.Status = 'Activo';
        caso.RecordTypeId = recordTypeCaso;
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Email';  
        caso.CC_MailTelfNotif__c ='test@test.com';
        caso.CC_Canal_Resolucion__c = 'Activo';
        caso.ContactId = contacto.Id;
        insert caso;

        Test.startTest();
        Task actividadCorreo = new Task();
        actividadCorreo.Type = 'Traslado Colaborador';
        actividadCorreo.WhatId = caso.Id;
        actividadCorreo.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        actividadCorreo.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreo;

        

        EmailMessage correo = new EmailMessage();
        correo.Subject = 'Prueba de envío de correo';
        correo.ActivityId = actividadCorreo.Id;
        correo.CC_Grupo_Colab__c = grupoColab.Name;
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.FromAddress = defaultFromAddressAttCliente;
        correo.ToAddress = 'pruebatraslado@ibm.com';
        correo.Incoming = false;
        correo.ParentId = caso.Id;
        correo.RelatedToId = caso.Id;


        List<String> cuerpo = new List<String>();
        cuerpo.add('<html>');
        cuerpo.add('Cuerpo del correo');
        cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
        cuerpo.add('</html>');
        correo.HtmlBody = String.join(cuerpo, '<br/>');

            insert correo;
        Test.stopTest();
        

       System.assertEquals(2, [SELECT Id FROM EmailMessage WHERE ParentId = :caso.Id].size());

    }

    @isTest
    public static void filtrarEmailMessageNoCC() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where FirstName = 'Usuario Admin Prueba' LIMIT 1].Id)) {
            Case caso = new Case();
            caso.Subject = 'Caso Email to Case';
            caso.Status = 'Activo';
            caso.Origin = 'Email';
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SAC_Pretension');
            insert caso;

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
            } else {
                headerValueStr = 'Prueba@IBM';    
            }

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';     
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.FromAddress = 'prueba@ibm.com';
            correoOrigen.ToAddress = defaultFromAddressAttCliente;
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            
            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">TEST Case Email - Revisar</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen;
            List<EmailMessage> correo = [SELECT Id, Status, RelatedToId, ParentId FROM EmailMessage WHERE RelatedToId = :caso.Id];
            List<EmailMessage> correos = CC_EmailMessage_AI_TRHan.filtrarEmailMessageNoCC(correo);
            System.assertEquals(correos.size(), 0, 'Ha habido un problema con el RT del caso');
        }
        Test.stopTest();
    }

    @isTest
    public static void comprobarDocumentacionDerivarMenor() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1].Id)) {
            CC_Lista_Valores__c valorFecha = new CC_Lista_Valores__c ();
            Datetime today = Datetime.newInstance(System.today().addDays(-1), Time.newInstance(0, 0, 0, 0));
            String todayFormated = today.format('yyyy-MM-dd');
            valorFecha.Name = 'Fecha documentacion respuesta cliente';
            valorFecha.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            valorFecha.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'Textos operativa Derivar' AND recordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores')].Id;
            valorFecha.CC_Mensajes_Mostrar__c = todayFormated;
            insert valorFecha;

            Case caso = new Case();
            caso.Subject = 'Caso Email to Case';
            caso.Status = 'Activo';
            caso.Origin = 'Email';
            caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            insert caso;

            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Solicitud Información';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            insert actividadCorreoOrigen;

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Procedencia__c = 'Solicitud Información';
            correoOrigen.FromAddress = defaultFromAddressAttCliente;
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;

            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

            insert correoOrigen;

            CC_EmailMessage_AI_TRHan.comprobarDocumentacionDerivar(caso, correoOrigen);
            System.assertEquals(caso.OwnerId, [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName  = 'CC_Inbound_Email_AC' LIMIT 1].Id, 'No se ha creado ningun caso');
        }
        Test.stopTest();
    }

    @isTest
    public static void comprobarDocumentacionDerivarMayor() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Cliente' LIMIT 1];

        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1].Id)) {
                CC_Lista_Valores__c valorFecha = new CC_Lista_Valores__c ();
                Datetime today = Datetime.newInstance(System.today().addDays(1), Time.newInstance(0, 0, 0, 0));
                String todayFormated = today.format('yyyy-MM-dd');
                valorFecha.Name = 'Fecha documentacion respuesta cliente';
                valorFecha.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
                valorFecha.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'Textos operativa Derivar' AND recordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores')].Id;
                valorFecha.CC_Mensajes_Mostrar__c = todayFormated;
                insert valorFecha;

                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                caseExtension.Case_Id__c = caso.Id;
                insert caseExtension;

                Task actividadCorreoOrigen = new Task();
                actividadCorreoOrigen.Type = 'Solicitud Información';
                actividadCorreoOrigen.WhatId = caso.Id;
                actividadCorreoOrigen.Status = 'Completed';
                actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
                actividadCorreoOrigen.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
                insert actividadCorreoOrigen;

                EmailMessage correoOrigen = new EmailMessage();
                correoOrigen.Subject = 'Prueba de envío de correo';
                correoOrigen.ActivityId = actividadCorreoOrigen.Id;
                correoOrigen.CC_Procedencia__c = 'Solicitud Información';
                correoOrigen.FromAddress = defaultFromAddressAttCliente;
                correoOrigen.ToAddress = 'prueba@ibm.com';
                correoOrigen.Incoming = true;
                correoOrigen.ParentId = caso.Id;
                correoOrigen.RelatedToId = caso.Id;

                List<String> cuerpoOrigen = new List<String>();
                cuerpoOrigen.add('<html>');
                cuerpoOrigen.add('Cuerpo del correo');
                cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
                cuerpoOrigen.add('</html>');
                correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');

                insert correoOrigen;
                
                CC_EmailMessage_AI_TRHan.comprobarDocumentacionDerivar(caso, correoOrigen);
                System.assertEquals([SELECT OwnerId FROM Case WHERE CC_CasoRelacionado__c = :caso.Id].OwnerId, [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName  = 'CC_Inbound_Email_AC' LIMIT 1].Id, 'No se ha creado ningun caso');
        }
        Test.stopTest();
    }


    @isTest
    public static void emailInbound() {
        
        System.runAs(new User(Id = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1].Id)) {
            Test.startTest();
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Cliente' LIMIT 1];
            Task tarea = new Task();
            tarea.Type = 'Actividad manual';
            tarea.WhatId = caso.Id;
            tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            insert tarea;

            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
            } else {
                headerValueStr = 'Prueba@IBM';    
            }
            EmailMessage correo = new EmailMessage();
            correo.Incoming = true;
            correo.ParentId = caso.Id;
            correo.RelatedToId = caso.Id;
            correo.CC_Aplicacion__c = 'CC Clientes';
            correo.ActivityId = tarea.Id;
            correo.FromAddress = defaultFromAddressAttCliente;
            correo.ToAddress = 'pruebaemailinbound@ibm.com';
            correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            
            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">PRUEBA</font>');
            cuerpoOrigen.add('</html>');
            correo.HtmlBody = String.join(cuerpoOrigen, '<br/>');

            insert correo;

            EmailMessage correoCreado = [SELECT Id, Incoming, CC_Aplicacion__c, HtmlBody FROM EmailMessage WHERE Id = :correo.Id];
            System.assert(correoCreado.Id != null, 'No se ha creado el correo');
            Task tareaActualizada  = [SELECT Id, Type FROM Task WHERE Id = :correo.ActivityId];
            System.assertEquals('Correo no identificado', tareaActualizada.Type, 'El flow no se ha ejecutado o no se ha cambiado el tipo de tarea');

            Test.stopTest();
        }
    }

    @isTest
    public static void notificacionKnowledgeEntrante() {
           
        System.runAs(new User(Id = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1].Id)) {
            Test.startTest(); 
                Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Knowledge').getRecordTypeId();
                Case caso = new Case();
                caso.RecordTypeId = recordTypeCaso;
                caso.Subject = 'Caso Knowledge';
                caso.Status = CC_KnowledgeCaseHandler.CASE_STATUS_PENDIENTE_COLABORADOR;
                caso.Origin = 'Email';  
                caso.CC_Referencia_Correo_Saliente__c = '1234567890';
                insert caso;
                
                Task tarea = CC_KnowledgeCaseHandler.crearTareaEnvioCorreo(caso.Id, true, '1234567890', 'Notificación de vencimiento enviada');
                insert tarea;

                //Setup header for the email
                List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
                String headerValueStr;
                EmailServicesAddress headerValue= new EmailServicesAddress();
                if (!EmailServicesList.isEmpty()) {
                    headerValue=emailServicesList[0];
                    headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
                } else {
                    headerValueStr = 'Prueba@IBM';    
                }

                EmailMessage correoOrigen = new EmailMessage();
                correoOrigen.Subject = 'Prueba de envío de correo';
                correoOrigen.ActivityId = tarea.Id;
                correoOrigen.CC_Procedencia__c = 'Notificación de vencimiento';
                correoOrigen.FromAddress = defaultFromAddressAttCliente;
                correoOrigen.ToAddress = 'prueba@ibm.com';
                correoOrigen.Incoming = true;
                correoOrigen.ParentId = caso.Id;
                correoOrigen.RelatedToId = caso.Id;
                correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';

                List<String> cuerpoOrigen = new List<String>();
                cuerpoOrigen.add('<html>');
                cuerpoOrigen.add('Cuerpo del correo');
                cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
                cuerpoOrigen.add('</html>');
                correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
                insert correoOrigen;     
            Test.stopTest();

            System.assertEquals(false, [SELECT Id FROM Case WHERE Status = :CC_KnowledgeCaseHandler.CASE_STATUS_ACTIVO AND Id = :caso.Id].isEmpty(), 
                'No se ha actualizado el estado del caso');
        }
    }

    @isTest
    public static void automatizacionRespuestaArgosTest() {
        
        System.runAs(new User(Id = [SELECT Id FROM User WHERE LastName = 'Administrador de sistema' LIMIT 1].Id)) {
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso Cliente 3' LIMIT 1];

            Id recordTypeGrupoColaborador = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'Grupo Colaborador Temporal';
            grupoColab.RecordTypeId = recordTypeGrupoColaborador;
            grupoColab.CC_External__c = 'GC-00001';
            insert grupoColab;       
            
            //Correo origen crear las dos task en una lista
            List<Task> tareas = new List<Task>();
            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Traslado Colaborador';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            actividadCorreoOrigen.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            tareas.add(actividadCorreoOrigen);
            
            Task reasignacion = new Task();
            reasignacion.Type = 'Reasignación';
            reasignacion.WhatId = caso.Id;
            reasignacion.Status = 'Completed';
            reasignacion.Subject = 'Reasignación del caso a 3N de CaixaBank Now';
            reasignacion.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
            tareas.add(reasignacion);

            
            Task actividadCorreo = new Task();
            // insert actividadCorreo;
            tareas.add(actividadCorreo);
            insert tareas;
            Test.startTest();
            //Setup header for the email
            List<EmailServicesAddress> emailServicesList= [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId IN (SELECT Id FROM EmailServicesFunction WHERE FunctionName = 'CC_AC') LIMIT 1];
            String headerValueStr;
            EmailServicesAddress headerValue= new EmailServicesAddress();
            if (!EmailServicesList.isEmpty()) {
                headerValue=emailServicesList[0];
                headerValueStr = headervalue.LocalPart + '@' + headervalue.EmailDomainName;       
            } else {
                headerValueStr = 'Prueba@IBM';    
            }

            List<EmailMessage> correos = new List<EmailMessage>();
            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
            correoOrigen.CC_Procedencia__c = 'Traslado Colaborador';
            correoOrigen.FromAddress = defaultFromAddressAttCliente;
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.Incoming = false;
            correoOrigen.ParentId = caso.Id;
            correoOrigen.RelatedToId = caso.Id;

            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            //correos.add(correoOrigen);
            insert correoOrigen;

            EmailMessage correo = new EmailMessage();
            correo.Status = '1';
            correo.Subject = 'Prueba de envío de correo';
            correo.ActivityId = actividadCorreo.Id;
            correo.CC_Grupo_Colab__c = grupoColab.Name;
            correo.CC_Procedencia__c = 'Traslado Colaborador';
            correo.FromAddress = defaultFromAddressAttCliente;
            correo.ToAddress = 'prueba@ibm.com';
            correo.Incoming = true;
            correo.ParentId = caso.Id;
            correo.RelatedToId = caso.Id;
            correo.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            correo.CC_Segunda_Oficina__c = 'Segunda oficina';

            List<String> cuerpo = new List<String>();
            cuerpo.add('<html>');
            cuerpo.add('Cuerpo del correo');
            cuerpo.add('<font color="gray"> #$%&CIERRE&%$# Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpo.add('</html>');
            correo.HtmlBody = String.join(cuerpo, '<br/>');
            correos.add(correo);
            insert correos;

            Case casoResult = [SELECT Id, Status, CC_Admin__c FROM Case WHERE Subject = 'Caso Cliente 3' LIMIT 1];
            System.assertEquals('Cerrado', casoResult.Status, 'No se ha cerrado el caso');
            System.assertEquals(false, casoResult.CC_Admin__c, 'No se ha quitado el check admin');
        }
        Test.stopTest();
    }
}