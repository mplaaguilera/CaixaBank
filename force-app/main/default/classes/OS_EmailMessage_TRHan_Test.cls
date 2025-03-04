@isTest
public class OS_EmailMessage_TRHan_Test {

    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = usuarioOperador.Id;
        template1.Name = 'CC Respuesta Automatica Cliente es';
        template1.DeveloperName = 'CC_Respuesta_Automatica_Cliente_es';
        template1.TemplateType = 'Text';
        System.runAs (usuarioOperador) {
            insert template1;
        }

        EmailTemplate template2 = new EmailTemplate();
        template2.FolderId = usuarioOperador.Id;
        template2.Name = 'CC Respuesta Automatica Cliente en';
        template2.DeveloperName = 'CC_Respuesta_Automatica_Cliente_en';
        template2.TemplateType = 'Text';
        System.runAs (usuarioOperador) {
            insert template2;
        }

        EmailTemplate template3 = new EmailTemplate();
        template3.FolderId = usuarioOperador.Id;
        template3.Name = 'CC Respuesta Automatica Cliente ca';
        template3.DeveloperName = 'CC_Respuesta_Automatica_Cliente_ca';
        template3.TemplateType = 'Text';
        System.runAs (usuarioOperador) {
            insert template3;
        }
    }
   
    @isTest
    static void generarDatosPrueba() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        //CREACIÓN DE CASOS PARA LOS CORREOS
        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.OS_Negocio__c = 'COPS';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        grupoColab.OwnerId = usuarioOperador.Id;
        insert grupoColab;        
         
        List<Case> casos = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso.CC_Referencia_Correo_Saliente__c = '#@1234567890#';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.OwnerId = usuarioOperador.Id;
        casos.add(caso);
        
        Case caso2 = new Case();
        caso2.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso2.Subject = 'Caso temporal';
        caso2.CC_Cola_Procedencia__c='OS_Buzon_International_Support';
        caso2.Status = 'Pendiente Colaborador';
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso2.OwnerId = usuarioOperador.Id;
        casos.add(caso2);
        
        Case caso3 = new Case();
        caso3.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso3.Subject = 'Caso temporal';
        caso3.Origin = 'Email';
        caso3.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso3.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso3.OwnerId = usuarioOperador.Id;
        casos.add(caso3);
        insert casos;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '02';
        contacto.Email = 'contacto@prueba.com';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto;

        List<Task> tareas = new List<Task>();
        Task actividadCorreo = new Task();
        actividadCorreo.Type = 'Traslado Colaborador';
        actividadCorreo.WhatId = caso.Id;
        actividadCorreo.CC_Referencia_Correo_Saliente__c = '4444567890';
        actividadCorreo.OwnerId = usuarioOperador.Id;
        tareas.add(actividadCorreo);

        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Traslado Colaborador';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.OwnerId = usuarioOperador.Id;
        tareas.add(actividadCorreoOrigen);
        
		Task actividadCorreo2 = new Task();
 		actividadCorreo2.Type = 'Traslado Colaborador';
        actividadCorreo2.WhatId = caso.Id;
        actividadCorreo2.CC_Referencia_Correo_Saliente__c = '3334567890';
        actividadCorreo2.OwnerId = usuarioOperador.Id;
        tareas.add(actividadCorreo2);
        
        Task actividadCorreoOrigen2 = new Task();
		actividadCorreoOrigen2.Type = 'Remitir Colaborador';
        actividadCorreoOrigen2.WhatId = caso3.Id;
        actividadCorreoOrigen2.CC_Referencia_Correo_Saliente__c = '1111567890';
        actividadCorreoOrigen2.OwnerId = usuarioOperador.Id;
        tareas.add(actividadCorreoOrigen2);

        insert tareas;

        String direccion = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        
        List<EmailMessage> emails = new List<EmailMessage>();
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'OS%' LIMIT 1];
            String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

            List<EmailMessage> correos = new List<EmailMessage>();
            EmailMessage correo = new EmailMessage();
            correo.Status = '0';
            correo.Subject = 'Envío traslado colaborador';
            correo.ActivityId = actividadCorreo.Id;
            correo.CC_Grupo_Colab__c = grupoColab.Name;
            correo.CC_Procedencia__c = 'Traslado Colaborador';
            correo.FromAddress = direccion;
            correo.ToAddress = 'prueba@ibm.com';
            correo.Incoming = false;
            correo.ParentId = caso.Id;
            correo.RelatedToId = caso.Id;

            List<String> cuerpo = new List<String>();
            cuerpo.add('<html>');
            cuerpo.add('Cuerpo del correo');
            cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@4444567890#.</font>');
            cuerpo.add('</html>');
            correo.HtmlBody = String.join(cuerpo, '<br/>');
            emails.add(correo);
    
            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Status = '1';
            correoOrigen.Subject = 'Entrante traslado a colaborador';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;
            correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
            correoOrigen.CC_Procedencia__c = 'Traslado Colaborador';
            correoOrigen.FromAddress = direccion;
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
            emails.add(correoOrigen);

            EmailMessage correo2 = new EmailMessage();
            correo2.Status = '1';
            correo2.Subject = 'Prueba de envío de correo';
            correo2.ActivityId = actividadCorreo2.Id;
            correo2.CC_Grupo_Colab__c = grupoColab.Name;
            correo2.CC_Procedencia__c = 'Traslado Colaborador';
            correo2.FromAddress = direccion;
            correo2.ToAddress = 'prueba@ibm.com';
            correo2.Incoming = false;
            correo2.ParentId = caso2.Id;
            correo2.RelatedToId = caso2.Id;

            cuerpo = new List<String>();
            cuerpo.add('<html>');
            cuerpo.add('Cuerpo del correo');
            cuerpo.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@3334567890#.</font>');
            cuerpo.add('</html>');
            correo2.HtmlBody = String.join(cuerpo, '<br/>');
            emails.add(correo2);
            
            EmailMessage correoOrigen2 = new EmailMessage();
            correoOrigen2.Status = '1';
            correoOrigen2.Subject = 'Prueba de envío de correo';
            correoOrigen2.ActivityId = actividadCorreoOrigen2.Id;
            correoOrigen2.CC_Grupo_Colab__c = grupoColab.Name;
            correoOrigen2.CC_Procedencia__c = 'Remitir Colaborador';
            correoOrigen2.FromAddress = direccion;
            correoOrigen2.ToAddress = 'prueba@ibm.com';
            correoOrigen2.Incoming = false;
            correoOrigen2.ParentId = caso3.Id;
            correoOrigen2.RelatedToId = caso3.Id;

            cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1111567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen2.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            emails.add(correoOrigen2);
            insert emails;
            Test.stopTest();

            System.assert(emails.size() > 0, 'Comprobamos la lista de emails está creada.');
        }
    }

    @isTest
    public static void solicitudInformacionSaliente() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.Name = 'Plazo Genérico';
        lista.CC_Valor__c = '1';
        insert lista;
        
        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;  
        
        Case caso = new Case();
       	caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        caso.Subject = 'Caso temporal';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
		actividadCorreoOrigen.Type = 'Solicitud Información';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreoOrigen;

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Status = '1';
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.CC_Procedencia__c = 'Solicitud Información';
        correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
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

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '02';
        contacto.Email = 'contacto@prueba.com';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            insert correoOrigen;
            Test.stopTest();
            
            EmailMessage emailRecuperado = [Select CC_Procedencia__c from EmailMessage where id = :correoOrigen.Id limit 1];
            
            System.assertEquals('Solicitud Información', emailRecuperado.CC_Procedencia__c, 'Comprobamos la procedencia del email.');
        }
    }
    
    @isTest
    public static void responderClienteSaliente() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.Status = 'Cerrado';
        caso.RecordTypeId = recordTypeCaso;   
        caso.OS_Cerrado_Operativa__c = true;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso.OwnerId = usuarioOperador.Id;
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Responder a cliente';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreoOrigen;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '02';
        contacto.Email = 'contacto@prueba.com';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Status = '1';
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;        
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.ToAddress = 'prueba@ibm.com';
            correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
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
            
            System.assertEquals('Cerrado', [SELECT Status FROM Case WHERE Id=: caso.Id].Status, 'Comprobamos el estado del caso es cerrado.');
        }
    }

    @isTest
    public static void respuestaCliente() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
		
        List<Case> casos = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.Status = 'Cerrado';
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';  
        caso.OwnerId = usuarioOperador.Id;      
        casos.add(caso);
        
        Case caso2 = new Case();
        caso2.Subject = 'Cas temporal';
        caso2.Status = 'Cerrado';
        caso2.RecordTypeId = recordTypeCaso;
        caso2.CC_Idioma__c = 'ca';
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso2.OwnerId = usuarioOperador.Id;
        casos.add(caso2);

        Case caso3 = new Case();
        caso3.Subject = 'Caso temporal';
        caso3.Status = 'Cerrado';
        caso3.RecordTypeId = recordTypeCaso;        
        caso3.CC_Idioma__c = 'en';
        caso3.Origin = 'Email';
        caso3.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso3.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso3.OwnerId = usuarioOperador.Id;
        casos.add(caso3);        
        insert casos;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '02';
        contacto.Email = 'contacto@prueba.com';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto;

        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Responder a cliente';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen.OwnerId = usuarioOperador.Id;
        insert actividadCorreoOrigen;

        Task actividadCorreoOrigen2 = new Task();
        actividadCorreoOrigen2.Type = 'Responder a cliente';
        actividadCorreoOrigen2.WhatId = casos[1].Id;
        actividadCorreoOrigen2.CC_Referencia_Correo_Saliente__c = '1234567890';
        actividadCorreoOrigen2.OwnerId = usuarioOperador.Id;
        insert actividadCorreoOrigen2;

        System.runAs (usuarioOperador) {
            Test.startTest();
            EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'OS%' LIMIT 1];
            String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Status = '1';
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;        
            correoOrigen.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen.FromAddress = 'prueba@ibm.com';
            correoOrigen.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = casos[0].Id;
            correoOrigen.RelatedToId = casos[0].Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            
            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen;
            
            EmailMessage correoOrigen2 = new EmailMessage();
            correoOrigen2.Status = '1';
            correoOrigen2.Subject = 'Prueba de envío de correo';
            correoOrigen2.ActivityId = actividadCorreoOrigen2.Id;        
            correoOrigen2.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen2.FromAddress = 'prueba@ibm.com';
            correoOrigen2.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correoOrigen2.Incoming = true;
            correoOrigen2.ParentId = casos[1].Id;
            correoOrigen2.RelatedToId = casos[1].Id;
            correoOrigen2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            
            List<String> cuerpoOrigen2 = new List<String>();
            cuerpoOrigen2.add('<html>');
            cuerpoOrigen2.add('Cuerpo del correo');
            cuerpoOrigen2.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen2.add('</html>');
            correoOrigen2.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen2; 
            
            Task actividadCorreoOrigen3 = new Task();
            actividadCorreoOrigen3.Type = 'Responder a cliente';
            actividadCorreoOrigen3.WhatId = casos[2].Id;
            actividadCorreoOrigen3.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreoOrigen3;

            EmailMessage correoOrigen3 = new EmailMessage();
            correoOrigen3.Status = '1';
            correoOrigen3.Subject = 'Prueba de envío de correo';
            correoOrigen3.ActivityId = actividadCorreoOrigen3.Id;        
            correoOrigen3.CC_Procedencia__c = 'Responder Cliente';
            correoOrigen3.FromAddress = 'prueba@ibm.com';
            correoOrigen3.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correoOrigen3.Incoming = true;
            correoOrigen3.ParentId = casos[2].Id;
            correoOrigen3.RelatedToId = casos[2].Id;
            correoOrigen3.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            
            List<String> cuerpoOrigen3 = new List<String>();
            cuerpoOrigen3.add('<html>');
            cuerpoOrigen3.add('Cuerpo del correo');
            cuerpoOrigen3.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen3.add('</html>');
            correoOrigen3.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen3;
            Test.stopTest();
            
            EmailMessage emailRecuperado = [Select CC_Procedencia__c from EmailMessage where id = :correoOrigen3.Id limit 1];
            
            System.assertEquals('Responder Cliente', emailRecuperado.CC_Procedencia__c, 'Comprobamos la procedencia del email.');
        }
    }
    
    @isTest
    public static void validarDestinatariosCorreoTest() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeListaValores = Schema.getGlobalDescribe().get('CC_Lista_Valores__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id recordTypeValor = Schema.getGlobalDescribe().get('CC_Lista_Valores__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'OS%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        List<CC_Lista_Valores__c> listasInsertar = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c listaDepartamentosValidar = new CC_Lista_Valores__c();
        listaDepartamentosValidar.Name = 'COPS: Departamentos validar destinatarios correo saliente';
        listaDepartamentosValidar.RecordTypeId = recordTypeListaValores;
        listaDepartamentosValidar.CC_Activa__c = true;
        listasInsertar.add(listaDepartamentosValidar);
        Insert listasInsertar;

        List<CC_Lista_Valores__c> valoresInsertar = new List<CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c valorDepartamento = new CC_Lista_Valores__c();
        valorDepartamento.Name = 'BOS';
        valorDepartamento.CC_Lista__c = listaDepartamentosValidar.Id;
        valorDepartamento.RecordTypeId = recordTypeValor;
        valorDepartamento.CC_Activa__c = true;
        valoresInsertar.add(valorDepartamento);
        Insert valoresInsertar;

        CC_Administracion_Lista_Blanca__c dominioPermitido1 = new CC_Administracion_Lista_Blanca__c();
        dominioPermitido1.CC_Activo__c = true;
        dominioPermitido1.CC_Canal_Contacto__c = 'Email';
        dominioPermitido1.CBK_Negocio__c = 'COPS';
        dominioPermitido1.Name = '@toibm.com';
        dominioPermitido1.CC_Prioridad__c = 'Medium';
        insert dominioPermitido1;

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta02';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        insert cuenta;        
                        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '02';
        contacto.Email = 'contacto@prueba.com';
        contacto.AccountId = cuenta.Id;
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto;
        		
        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Empleado').getRecordTypeId();
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';        
        caso.OS_Departamento__c = 'BOS';
        caso.OwnerId = usuarioOperador.Id;
        Insert caso;

        List<String> cuerpoOrigen = new List<String>();
        cuerpoOrigen.add('<html>');
        cuerpoOrigen.add('Cuerpo del correo inicial');
        cuerpoOrigen.add('</html>');

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Status = '1';
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.FromAddress = 'prueba@ibm.com';
        correoOrigen.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoOrigen.CcAddress = 'copiaprueba@prueba.com';
        correoOrigen.BccAddress = 'copiaocultaprueba@prueba.com';
        correoOrigen.Incoming = true;
        correoOrigen.ParentId = caso.Id;
        correoOrigen.RelatedToId = caso.Id;
        correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
        correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
        insert correoOrigen;

        List<EmailMessage> correosEnviar = new List<EmailMessage>();
        List<EmailMessage> correosEnviar2 = new List<EmailMessage>();
        
        List<String> cuerpoSaliente = new List<String>();
        cuerpoSaliente.add('<html>');
        cuerpoSaliente.add('Cuerpo del correo saliente');
        cuerpoSaliente.add('</html>');

        EmailMessage correoSaliente = new EmailMessage();
        correoSaliente.Status = '1';
        correoSaliente.Incoming = false;
        correoSaliente.Subject = 'Prueba de envío de correo no válido';
        correoSaliente.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoSaliente.ToAddress = 'prueba@toibm.com';
        correoSaliente.CcAddress = 'correonovalido@prueba.com';
        correoSaliente.Incoming = false;
        correoSaliente.ParentId = caso.Id;
        correoSaliente.RelatedToId = caso.Id;
        correoSaliente.HtmlBody = String.join(cuerpoSaliente, '<br/>');
        correosEnviar2.add(correoSaliente);

        EmailMessage correoSaliente2 = new EmailMessage();
        correoSaliente2.Status = '1';
        correoSaliente2.Incoming = false;
        correoSaliente2.Subject = 'Prueba de envío de correo válido';
        correoSaliente2.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correoSaliente2.ToAddress = 'prueba@ibm.com';
        correoSaliente2.BccAddress = 'copiaocultaprueba@prueba.com';
        correoSaliente2.Incoming = false;
        correoSaliente2.ParentId = caso.Id;
        correoSaliente2.RelatedToId = caso.Id;
        correoSaliente2.HtmlBody = String.join(cuerpoSaliente, '<br/>');
        correosEnviar.add(correoSaliente2);
        
        System.runAs (usuarioOperador) {
            Test.startTest();
            insert correosEnviar;
            
            try {
                List<EmailMessage> correosCreados = new List<EmailMessage>([SELECT Id FROM EmailMessage WHERE Subject = 'Prueba de envío de correo válido']);
                System.assert(!correosCreados.isEmpty(),'Se ha producido un error');
            }
            catch(Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains('No está entre los contactos de tipo buzón COPS y colaborador dados de alta. No está entre los dominios admitidos. No está entre los contactos relacionados con la cuenta del caso.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true,'Se ha producido un error');
            }
            Test.stopTest();
        }
    }

    @isTest
    public static void  respuestaSolInfo() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
		
        List<Case> casos = new List<Case>();
        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.Status = 'Pendiente Cliente';
        caso.RecordTypeId = recordTypeCaso;
		caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';     
        caso.OwnerId = usuarioOperador.Id;   
        casos.add(caso);
        
        Case caso2 = new Case();
        caso2.Subject = 'Cas temporal';
        caso2.Status = 'Pendiente Cliente';
        caso2.RecordTypeId = recordTypeCaso;
        caso2.CC_Idioma__c = 'ca';
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso2.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso2.OwnerId = usuarioOperador.Id;
        casos.add(caso2);

        Case caso3 = new Case();
        caso3.Subject = 'Caso temporal';
        caso3.Status = 'Pendiente Cliente';
        caso3.RecordTypeId = recordTypeCaso;        
        caso3.CC_Idioma__c = 'en';
        caso3.Origin = 'Email';
        caso3.CC_Canal_Procedencia__c = 'Buzón Service Desk';
        caso3.CC_Tipo_Contacto__c = 'Asesoramiento';
        caso3.OwnerId = usuarioOperador.Id;
        casos.add(caso3);        
        insert casos;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '02';
        contacto.Email = 'contacto@prueba.com';
        contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Empleado').getRecordTypeId();
        insert contacto;

        System.runAs (usuarioOperador) {
            Test.startTest();
            Task actividadCorreoOrigen = new Task();
            actividadCorreoOrigen.Type = 'Solicitud Información';
            actividadCorreoOrigen.WhatId = caso.Id;
            actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreoOrigen;

            EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'OS%' LIMIT 1];
            String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

            EmailMessage correoOrigen = new EmailMessage();
            correoOrigen.Status = '1';
            correoOrigen.Subject = 'Prueba de envío de correo';
            correoOrigen.ActivityId = actividadCorreoOrigen.Id;        
            correoOrigen.CC_Procedencia__c = 'Solicitud Información';
            correoOrigen.FromAddress = 'prueba@ibm.com';
            correoOrigen.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correoOrigen.Incoming = true;
            correoOrigen.ParentId = casos[0].Id;
            correoOrigen.RelatedToId = casos[0].Id;
            correoOrigen.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            
            List<String> cuerpoOrigen = new List<String>();
            cuerpoOrigen.add('<html>');
            cuerpoOrigen.add('Cuerpo del correo');
            cuerpoOrigen.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen.add('</html>');
            correoOrigen.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen;
            
            Task actividadCorreoOrigen2 = new Task();
            actividadCorreoOrigen2.Type = 'Solicitud Información';
            actividadCorreoOrigen2.WhatId = casos[1].Id;
            actividadCorreoOrigen2.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreoOrigen2;

            EmailMessage correoOrigen2 = new EmailMessage();
            correoOrigen2.Status = '1';
            correoOrigen2.Subject = 'Prueba de envío de correo';
            correoOrigen2.ActivityId = actividadCorreoOrigen2.Id;        
            correoOrigen2.CC_Procedencia__c = 'Solicitud Información';
            correoOrigen2.FromAddress = 'prueba@ibm.com';
            correoOrigen2.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correoOrigen2.Incoming = true;
            correoOrigen2.ParentId = casos[1].Id;
            correoOrigen2.RelatedToId = casos[1].Id;
            correoOrigen2.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            
            List<String> cuerpoOrigen2 = new List<String>();
            cuerpoOrigen2.add('<html>');
            cuerpoOrigen2.add('Cuerpo del correo');
            cuerpoOrigen2.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen2.add('</html>');
            correoOrigen2.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen2; 
            
            Task actividadCorreoOrigen3 = new Task();
            actividadCorreoOrigen3.Type = 'Solicitud Información';
            actividadCorreoOrigen3.WhatId = casos[2].Id;
            actividadCorreoOrigen3.CC_Referencia_Correo_Saliente__c = '1234567890';
            insert actividadCorreoOrigen3;

            EmailMessage correoOrigen3 = new EmailMessage();
            correoOrigen3.Status = '1';
            correoOrigen3.Subject = 'Prueba de envío de correo';
            correoOrigen3.ActivityId = actividadCorreoOrigen3.Id;        
            correoOrigen3.CC_Procedencia__c = 'Solicitud Información';
            correoOrigen3.FromAddress = 'prueba@ibm.com';
            correoOrigen3.ToAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
            correoOrigen3.Incoming = true;
            correoOrigen3.ParentId = casos[2].Id;
            correoOrigen3.RelatedToId = casos[2].Id;
            correoOrigen3.Headers = '[{"value": "' + headerValueStr + '","name": "X-SFDC-Original-RCPT"}]';
            
            List<String> cuerpoOrigen3 = new List<String>();
            cuerpoOrigen3.add('<html>');
            cuerpoOrigen3.add('Cuerpo del correo');
            cuerpoOrigen3.add('<font color="gray">Por favor mantenga la siguiente referencia al responder a este correo: #@1234567890#.</font>');
            cuerpoOrigen3.add('</html>');
            correoOrigen3.HtmlBody = String.join(cuerpoOrigen, '<br/>');
            insert correoOrigen3;
            Test.stopTest();
            
            EmailMessage emailRecuperado = [Select CC_Procedencia__c from EmailMessage where id = :correoOrigen3.Id limit 1];
            
            System.assertEquals('Solicitud Información', emailRecuperado.CC_Procedencia__c, 'Comprobamos la procedencia del email.');
        }
    }
}