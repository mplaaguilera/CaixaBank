@isTest
public with sharing class CC_EmailMessage_AI_TRHan_Test {

    // Variable estática para almacenar el correo por defecto
    public static String defaultFromAddressAttCliente = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Atencion_Cliente_ESP'].CC_Direccion_Correo__c;
    public static String defaultFromAddressBuzonEmpleados;
    

    @TestSetup
    static void makeData(){
        
        //defaultFromAddressAttCliente = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Atencion_Cliente_ESP'].CC_Direccion_Correo__c;
        defaultFromAddressBuzonEmpleados = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Buzon_Defecto_Empleados'].CC_Direccion_Correo__c;
     
        system.debug('El email es : ' + defaultFromAddressAttCliente + ' - ' + defaultFromAddressBuzonEmpleados );

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
        }

        //crear usuarios CC
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profile2Id = [SELECT Id FROM Profile WHERE Name = 'CC_Analísta y 2º nivel MVP2'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_CCO'];
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
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
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
            insert userList2;
        }  
        List<CC_Lista_Valores__c> horariosInsertar = new List<CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c horario = new CC_Lista_Valores__c();
        horario.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        horario.Name = 'Calendario_servicios';
        horario.CC_Activa__c = true;
        insert horario;
        
                CC_Lista_Valores__c horarioAccionista = new CC_Lista_Valores__c();
        horarioAccionista.Name = 'Atención al Cliente';
        horarioAccionista.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista.CC_Valor__c = '9';
        horarioAccionista.CC_Valor2__c = '23';
        horarioAccionista.CC_Valor_SFDC__c = 'L-J';
        horarioAccionista.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista);
        
        CC_Lista_Valores__c horarioAccionista2 = new CC_Lista_Valores__c();
        horarioAccionista2.Name = 'Atención al Cliente';
        horarioAccionista2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioAccionista2.CC_Valor__c = '9:30';
        horarioAccionista2.CC_Valor2__c = '19';
        horarioAccionista2.CC_Valor_SFDC__c = 'V';
        horarioAccionista2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioAccionista2);
        
        CC_Lista_Valores__c horarioServiciosCentrales = new CC_Lista_Valores__c();
        horarioServiciosCentrales.Name = 'Servicios Centrales';
        horarioServiciosCentrales.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioServiciosCentrales.CC_Valor__c = '9:30';
        horarioServiciosCentrales.CC_Valor2__c = '19';
        horarioServiciosCentrales.CC_Valor_SFDC__c = 'L-J';
        horarioServiciosCentrales.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioServiciosCentrales);
        
        CC_Lista_Valores__c horarioServiciosCentrales2 = new CC_Lista_Valores__c();
        horarioServiciosCentrales2.Name = 'Servicios Centrales';
        horarioServiciosCentrales2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        horarioServiciosCentrales2.CC_Valor__c = '9:30';
        horarioServiciosCentrales2.CC_Valor2__c = '19';
        horarioServiciosCentrales2.CC_Valor_SFDC__c = 'V';
        horarioServiciosCentrales2.CC_Lista__c = horario.Id;
        horariosInsertar.add(horarioServiciosCentrales2);
        insert horariosInsertar;
    }    
    
    @isTest
    public static void trasladoColaboradorSaliente() {

       /*CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = '';
        insert grupoColab;*/
        
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

        Test.startTest();
        
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
        caso.CC_Canal_Procedencia__c = 'Servicios Centrales';
        caso.CC_Canal_Resolucion__c = 'Servicios Centrales';
        caso.CC_En_Tercer_Nivel__c = true;
        caso.CC_Grupo_3N__c = '3N de CaixaBank Now';
        insert caso;
        
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
        insert tareas;

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
        
        caso.CC_Fecha_Traslado_Colaborador__c = Date.today().addDays(-7);
        update caso;

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
        correo.CC_Segunda_Oficina__c = 'Segunda oficina';

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
        Test.startTest();
        insert correoOrigen;
        Test.stopTest();

        System.assertEquals(3, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());

    }
    
    @isTest
    public static void responderClienteSalienteTest() {       
        
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
        Test.startTest();
        insert correoOrigen;
        Test.stopTest();


        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());

    }

    @isTest
    public static void remitirColaboradorEntrante() {

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
        Test.startTest();
        insert correoOrigen;
        Test.stopTest();

        System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());

    }

    @isTest
    public static void solicitudInformacionSaliente() {

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

        Test.startTest();
        insert correoOrigen;
        Test.stopTest();
        
        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
    }

    @isTest
    public static void solicitudInformacionEntrante() {

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
        Test.startTest();        
        insert correoOrigen;     
        Test.stopTest();

        System.assertEquals(3, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());
    }

    
    @isTest
    public static void  respuestaCliente() {

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
        Test.startTest();
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
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
          
            insert correoOrigen;
        }
        Test.stopTest();
        List<EmailMessage> emailList = [SELECT Id, Status FROM EmailMessage WHERE RelatedToId = :caso.Id];
        System.AssertEquals(2, emailList.size());
    }

    @isTest
    public static void  rechazarCasosSpam() {

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

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
          
            insert correoOrigen;

        }
        Test.stopTest();
        List<Case> casoList = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];
        System.AssertEquals('Rechazado', casoList[0].Status);

    }
    
    @isTest
    public static void  respuestaEmpleadoForm() {

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
        Database.update(caso);

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
        

        Test.startTest();
        insert correoOrigen;
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());   
     }
     
     @isTest
    public static void  respuestaEmpleadoChat() {

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
        Database.update(caso);

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

        Test.startTest();
        insert correoOrigen;
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());   
     }

        @isTest
        public static void  respuestaClienteWivai() {
    
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
            Test.startTest();
            insert correoOrigen;
            Test.stopTest();
            
            System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());    }
            @isTest
            public static void  respuestaAccionista() {
        
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
                Test.startTest();
                insert correoOrigen;
                Test.stopTest();
                
                System.assertEquals(1, [SELECT Id FROM Task WHERE WhatId = :caso.Id].size());    }
    @isTest
    public static void  respuestaClienteCSIBankia() {

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

        Test.startTest();
            insert correoOrigen;
        Test.stopTest();

        List<EmailMessage> emailList = [SELECT Id, Status FROM EmailMessage WHERE RelatedToId = :caso.Id];
        //  System.AssertEquals(2, emailList.size());
        emailList = [SELECT Id, Status FROM EmailMessage WHERE RelatedToId = :caso.Id AND FromAddress =: fromEmail.Address];
        
        System.AssertEquals(1, emailList.size());
    }

    @isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoEsCli() {
      
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
        
        Test.startTest();
            insert correo;
        Test.stopTest();
        
        Case casoId = [SELECT Id FROM Case LIMIT 1];
        Integer cantidadDeEmails = [SELECT Count() FROM EmailMessage WHERE ParentId = :casoId.Id];
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

        Test.startTest();
                insert correo;
        Test.stopTest();
        
        Case casoId = [SELECT Id FROM Case LIMIT 1];
        List <EmailMessage> cantidadDeEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :casoId.Id];
       System.AssertEquals(2, cantidadDeEmails.size());
    }

    @isTest
    public static void trasladoColaboradorWivaiCorreoAutomaticoCaCli() {
      
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
        
        Test.startTest();
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
        
        Test.startTest();
            insert correo;
        Test.stopTest();
        
        Case casoId = [SELECT Id FROM Case LIMIT 1];
        List <EmailMessage> cantidadDeEmails = [SELECT Id FROM EmailMessage WHERE ParentId = :casoId.Id];
        System.AssertEquals(2, cantidadDeEmails.size());
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

        Test.startTest();
            insert correo;
        Test.stopTest();
        

       System.assertEquals(2, [SELECT Id FROM EmailMessage WHERE ParentId = :caso.Id].size());

    }
     
}