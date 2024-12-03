@isTest
public class OS_EmailService_Queueable_Test {
    @TestSetup
    static void cargaDeDatos(){
        User operador = OS_Usuarios.usuarioOperador();

        Id businessHoursId;
        BusinessHours[] stdBusinessHours = [SELECT Id FROM BusinessHours WHERE Name = 'Default' AND IsActive = true];
        businessHoursId = stdBusinessHours[0].Id;
        if(stdBusinessHours.isEmpty()){
            businessHoursId = [SELECT Id FROM BusinessHours WHERE IsActive = true LIMIT 1].Id;
        }

        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_Cliente');
        insert cuenta;

        AccountShare acshare = new AccountShare();
        acshare.AccountId = cuenta.Id;
        acshare.UserOrGroupId = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1].Id;
        acshare.AccountAccessLevel = 'Edit';
        acshare.OpportunityAccessLevel = 'Edit';
        acshare.CaseAccessLevel = 'Edit';
        insert acshare;

        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto01';
        contacto.LastName = 'Contacto01';
        contacto.CC_NumPerso__c = '25345561';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.Email = 'correo@prueba.com';
        insert contacto;

        CC_MCC__c tematica = new CC_MCC__c();
		tematica.Name = 'tematica cops test';
        tematica.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        tematica.CC_Fecha_Vigencia_Inicio__c = System.now();
        tematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.CC_Codigo_Externo__c = 'TEC-000001';
        tematica.OS_Departamento__c = 'UAC';
        tematica.OS_Horario__C= businessHoursId;
        insert tematica;

        CC_MCC__c producto = new CC_MCC__c();
        producto.Name = 'producto cops test';
        producto.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        producto.CC_Fecha_Vigencia_Inicio__c = System.now();
        producto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        producto.CC_Tematica__c = tematica.Id;
        producto.CC_Codigo_Externo__c = 'PRC-000001'; 
        insert producto;

        CC_MCC__c motivo = new CC_MCC__c();
        motivo.Name = 'motivo cops test';
        motivo.CC_Tipo_Cliente__c = 'Cliente (COPS)/Empleado (COPS)';
        motivo.CC_Fecha_Vigencia_Inicio__c = System.now();
        motivo.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        motivo.CC_Tematica__c = tematica.Id;
        motivo.CC_Producto_Servicio__c = producto.Id;
        motivo.CC_Codigo_Externo__c = 'MOC-000001';
        insert motivo;

        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'OS_Cliente');
        caso.Subject = 'Caso OS_EmailService_Test';
        caso.Origin = 'Email';
        caso.Status = 'Activo';
        caso.AccountId = cuenta.Id;
        caso.ContactId = contacto.Id;
        caso.CC_Idioma__c = 'es';
        caso.CC_Detalles_Consulta__c = 'Detalles consulta';
        caso.CC_Detalles_Solucion__c = 'Detalles solución';
        caso.CC_MCC_Tematica__c = tematica.Id;
        caso.CC_MCC_ProdServ__c = producto.Id;
        caso.CC_MCC_Motivo__c = motivo.Id;
        caso.CC_Canal_Procedencia__c = 'Buzón CCI Holabank';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;
    }

    @isTest static void testEmailServiceQueueable() {
        User usuarioAdmin = OS_Usuarios.usuarioAdmin();
        
        // Preparar los datos para el envío del correo electrónico
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso OS_EmailService_Test'];
        caso.OwnerId = usuarioAdmin.Id;
        caso.Status = 'Pendiente Cliente';
        update caso;

        //Actividad de solicitud de información
        Task tareaSolicitudInfo = new Task();
        tareaSolicitudInfo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        tareaSolicitudInfo.WhatId = caso.Id;
        tareaSolicitudInfo.Type = 'Solicitud Información';
        tareaSolicitudInfo.Subject = 'Solicitud Información';
        tareaSolicitudInfo.Status = 'Completed';
        tareaSolicitudInfo.CC_Referencia_Correo_Saliente__c = 'refSolicitudInfo';
        tareaSolicitudInfo.OwnerId = usuarioAdmin.Id;
        insert tareaSolicitudInfo;

        //Crear un InboundEnvelope e InboundEmail de entrada
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        Messaging.InboundEmail correo = new Messaging.InboundEmail() ;
        Messaging.InboundEmail.Header header = new Messaging.InboundEmail.Header();
        header.value = 'hello';
        header.name = 'HEADER DE PRUEBA';
        envelope.fromAddress = 'correo@prueba.com';
        envelope.toAddress = [SELECT OS_Email__c FROM OS_Correo__mdt WHERE DeveloperName LIKE '%Holabank%' LIMIT 1].OS_Email__c;
        correo.subject = 'asunto';
        correo.fromAddress = 'correo@prueba.com';
        correo.plainTextBody = 'hola\n#@refSolicitudInfo#\nadios';
        correo.htmlBody = 'email test prueba';
        
        
        Map<String, Integer> reintentos = new Map<String, Integer>();
        //Id idMapa = '111';
        reintentos.put(String.valueof(correo.messageId), 0);

        // Crear el WrapperValoresEmail
        OS_EmailService.WrapperValoresEmail parametrosJob = new OS_EmailService.WrapperValoresEmail();
        parametrosJob.emailQueue = correo;
        parametrosJob.envelopeQueue = envelope;
        parametrosJob.reintentosMap = reintentos;
        
        //Integer numEmailsAnterior = [SELECT COUNT() FROM EmailMessage];

        // Crear una instancia del Queueable
        OS_EmailService_Queueable queueableEmail = new OS_EmailService_Queueable(parametrosJob);

        // Enviar el correo electrónico mediante el Queueable
        Test.startTest();
        System.runAs(usuarioAdmin){
            System.enqueueJob(queueableEmail);
        }
        
        Test.stopTest();

        System.assertEquals(1, [SELECT Count() FROM EmailMessage WHERE ParentId = :caso.Id]);
    }
}