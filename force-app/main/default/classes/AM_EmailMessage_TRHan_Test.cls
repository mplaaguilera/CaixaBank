@isTest
public class AM_EmailMessage_TRHan_Test {
    
    @isTest
    public static void enviarCorreo(){
             
        CC_Lista_Valores__c LV1 = new CC_Lista_Valores__c();
        LV1.Name='Plazo Genérico CAM';
        LV1.CC_Activa__c =true;
        LV1.CC_Valor__c = '24';
        insert LV1;

        CC_Lista_Valores__c LV2 = new CC_Lista_Valores__c();
        LV2.Name='Plazo Genérico Empleado CAM';
        LV2.CC_Activa__c =true;
        LV2.CC_Valor__c = '24';
        insert LV2;
          
    	Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;

        Account cuenta = new Account(
            Name = 'Cuenta Test',
            CC_Email__c = 'cuenta@test.com'
        );
        insert cuenta;
        
        Id colaboradorRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        Contact contacto = new Contact(
        RecordTypeId = colaboradorRecordTypeId,
        FirstName = 'Contacto',
        LastName = 'Test',
        AccountId = cuenta.Id,
        CC_Idioma__c = 'es',
        Email = 'prueba@ibm.com'
        );
        insert contacto;
		
        Case caso = new Case();
       	caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        caso.CC_Canal_Procedencia__c = 'Buzón Carteras';
        caso.Subject = 'Caso temporal';
        caso.CC_Ultima_Operativa_Correo__c = 'solicitar';
        insert caso;

        //Correo origen
        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Task').getRecordTypeId();
        actividadCorreoOrigen.Type = 'Traslado Colaborador';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreoOrigen;

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = 'Grupo';
        correoOrigen.CC_Procedencia__c = 'Traslado Colaborador';
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
        insert correoOrigen;

        Test.startTest();

        Task actividadCorreo = new Task();
        actividadCorreo.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Task').getRecordTypeId();
        insert actividadCorreo;

        EmailMessage correo = new EmailMessage();
        correo.Status = '1';
        correo.Subject = 'Prueba de envío de correo';
        correo.ActivityId = actividadCorreo.Id;
        correo.CC_Grupo_Colab__c = 'Grupo';
        correo.CC_Procedencia__c = 'Traslado Colaborador';
        correo.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
        correo.ToAddress = 'prueba@ibm.com';
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

        System.assert(correo.Id != null);
    
    }

    @isTest
    public static void responderClienteSaliente() {
        
        CC_Lista_Valores__c LV1 = new CC_Lista_Valores__c();
        LV1.Name='Plazo Genérico CAM';
        LV1.CC_Activa__c =true;
        LV1.CC_Valor__c = '24';
        insert LV1;

        CC_Lista_Valores__c LV2 = new CC_Lista_Valores__c();
        LV2.Name='Plazo Genérico Empleado CAM';
        LV2.CC_Activa__c =true;
        LV2.CC_Valor__c = '24';
        insert LV2;

        Account cuenta = new Account(
            Name = 'Cuenta Test',
            CC_Email__c = 'cuenta@test.com'
        );
        insert cuenta;
        
        Id colaboradorRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        Contact contacto = new Contact(
        RecordTypeId = colaboradorRecordTypeId,
        FirstName = 'Contacto',
        LastName = 'Test',
        AccountId = cuenta.Id,
        CC_Idioma__c = 'es',
        Email = 'prueba@ibm.com'
        );
        insert contacto;

        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();
        Case caso = new Case();
        caso.Subject = 'Caso temporal';
        caso.CC_Canal_Procedencia__c = 'Buzón Carteras';
        caso.Status = 'Cerrado';
        caso.RecordTypeId = recordTypeCaso;        
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
        actividadCorreoOrigen.Type = 'Responder a cliente';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreoOrigen;

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
    }
    
    @isTest
    public static void remitirColaboradorSaliente() {
        
        CC_Lista_Valores__c LV1 = new CC_Lista_Valores__c();
        LV1.Name='Plazo Genérico CAM';
        LV1.CC_Activa__c =true;
        LV1.CC_Valor__c = '24';
        insert LV1;

        CC_Lista_Valores__c LV2 = new CC_Lista_Valores__c();
        LV2.Name='Plazo Genérico Empleado CAM';
        LV2.CC_Activa__c =true;
        LV2.CC_Valor__c = '24';
        insert LV2;

        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab;
        
        Case caso = new Case();
        caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        caso.Subject = 'Caso temporal';
        insert caso;
        
        Task actividadCorreoOrigen = new Task();
		actividadCorreoOrigen.Type = 'Remitir Colaborador';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreoOrigen;

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Status = '1';
        correoOrigen.Subject = 'Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.CC_Procedencia__c = 'Remitir Colaborador';
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
        insert correoOrigen;
    }
    
    @isTest
    public static void solicitudInformacionSaliente() {
        
        CC_Lista_Valores__c LV1 = new CC_Lista_Valores__c();
        LV1.Name='Plazo Genérico CAM';
        LV1.CC_Activa__c =true;
        LV1.CC_Valor__c = '24';
        insert LV1;

        CC_Lista_Valores__c LV2 = new CC_Lista_Valores__c();
        LV2.Name='Plazo Genérico Empleado CAM';
        LV2.CC_Activa__c =true;
        LV2.CC_Valor__c = '24';
        insert LV2;

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
       	caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        caso.Subject = 'Caso temporal';
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
        insert correoOrigen;
    }

    @isTest
    public static void recibirCorreo(){

        Id recordTypeGrupoColaborador = Schema.getGlobalDescribe().get('CC_Grupo_Colaborador__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Grupo_Colaborador').getRecordTypeId();
        CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
        grupoColab.Name = 'Grupo Colaborador Temporal';
        grupoColab.RecordTypeId = recordTypeGrupoColaborador;
        grupoColab.CC_External__c = 'GC-00001';
        insert grupoColab; 

        Case caso = new Case();
       	caso.RecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        caso.Subject = 'Caso temporal';
        insert caso;

        Task actividadCorreoOrigen = new Task();
		actividadCorreoOrigen.Type = 'Solicitud Información';
        actividadCorreoOrigen.WhatId = caso.Id;
        actividadCorreoOrigen.CC_Referencia_Correo_Saliente__c = '1234567890';
        insert actividadCorreoOrigen;

        EmailServicesAddress headerValue = [SELECT LocalPart, EmailDomainName FROM EmailServicesAddress WHERE DeveloperName LIKE 'AM_%' LIMIT 1];
        String headerValueStr = headerValue.LocalPart +'@'+ headerValue.EmailDomainName;

        EmailMessage correoOrigen = new EmailMessage();
        correoOrigen.Status = '1';
        correoOrigen.Subject = ':::Prueba de envío de correo';
        correoOrigen.ActivityId = actividadCorreoOrigen.Id;
        correoOrigen.CC_Grupo_Colab__c = grupoColab.Name;
        correoOrigen.CC_Procedencia__c = 'Solicitud Información';
        correoOrigen.FromAddress = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt LIMIT 1].CC_Direccion_Correo__c;
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
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert correoOrigen;
        }

        System.assert(correoOrigen.Id != null);
    }
}