@isTest
public with sharing class CC_Marcar_Casos_KPI_Batch_Test {
    @TestSetup
    static void makeData(){
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id profileIdAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];

        List<User> userList = new List<User>();
        User usuario1 = new User();
        usuario1.ProfileId = profileIdAdmin;
        usuario1.UserRoleId = rolId.Id;
        usuario1.FirstName = 'Usuario Admin Prueba';
        usuario1.LastName = 'last211053';
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
        User usuario2 = new User();
        usuario2.ProfileId = profileId;
        usuario2.UserRoleId = rolId.Id;
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
        insert userList;
        
        insert new PermissionSetAssignment(AssigneeId = usuario1.Id, PermissionSetId = ps.Id);
        insert new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = ps.Id);
        
    }
    
    @isTest
    public static void testMotivoDerivacion() {
        User supervisorUser = [SELECT Id FROM User WHERE LastName LIKE 'last2' AND IsActive=true LIMIT 1];
        System.runAs(supervisorUser){
            //Creación nueva cuenta
            Account cuenta = new Account(Name='Cuenta');
            insert cuenta;
            
            //Creación nuevo contacto asociado a la cuenta anterior
            Contact contacto = new Contact(LastName='Contacto', AccountId=cuenta.Id);
            insert contacto;
            
            Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            Id recordCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
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
            Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
            CC_MCC__c mccCausa = new CC_MCC__c();
            mccCausa.Name = 'Solicita reversión';
            mccCausa.CC_Tipo_Cliente__c = 'Cliente';
            mccCausa.CC_Fecha_Vigencia_Inicio__c = date.today();
            mccCausa.RecordTypeId = recordTypeIdCausa;
            mccCausa.CC_Motivo__c = mcc2.Id;
            mccCausa.CC_Codigo_Externo__c = 'CA-000001';
            insert mccCausa;
            CC_MCC__c solucion = new CC_MCC__c();
            solucion.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();
            solucion.Name = 'Derivar a oficina: Limitación protocolo';
            solucion.CC_Tipo_Cliente__c = 'Cliente';
            solucion.CC_Causa__c = mccCausa.Id;
            solucion.CC_Codigo_Externo__c = 'CA-000002';
            insert solucion;
            
            //Creación nuevo caso asociado al contacto anterior
            Case caso = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Prueba',
            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Phone', CC_Tipo_Contacto__c = 'Consulta', recordTypeId = recordCaso,
            CC_Canal_Procedencia__c = 'Tarjetas',CC_MCC_Motivo__c = mcc2.Id,CC_MCC_ProdServ__c = mcc1.Id,CC_MCC_Tematica__c = mcc.Id,
            CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta', CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución');
            insert caso;
            Case caso2 = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Prueba',
            CC_Tipo_Cliente__c = 'Cliente', Origin = 'Phone', CC_Tipo_Contacto__c = 'Consulta', recordTypeId = recordCaso,
            CC_Canal_Procedencia__c = 'Tarjetas',CC_MCC_Motivo__c = mcc2.Id,CC_MCC_ProdServ__c = mcc1.Id,CC_MCC_Tematica__c = mcc.Id,CC_MCC_Causa__c = mccCausa.Id, CC_MCC_Solucion__c = solucion.Id, CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta', CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución', CC_Status_Autorizacion__c = 'ERROR', CC_OTP_Nivel__c = 'Cliente Digital', CC_OTP_Valido__c = false);
            insert caso2;
            List<Task> listTaskInsert = new List<Task>();
            Task tarea = new Task(WhatId=caso.Id, Status='Pending', Type ='Tarea Cambio Gestor', Subject = 'Solicitud contacto gestor (Contact Center)');
            listTaskInsert.add(tarea);
            Task tarea2 = new Task(WhatId=caso2.Id, Status='Completed', Type = 'Consulta externa a empleado', CC_Tipo_Cierre__c = 'Consulta transferida');
            listTaskInsert.add(tarea2);
            insert listTaskInsert;
            Test.StartTest();
            CC_Marcar_Casos_KPI_Batch batch = new CC_Marcar_Casos_KPI_Batch();
            Database.executeBatch(batch);
            Test.stopTest();
            Case caso2Resultado = [SELECT CC_Motivo_Derivacion__c FROM Case WHERE Id = :caso2.Id];
            assert.areEqual(null, caso2Resultado.CC_Motivo_Derivacion__c, 'El batch fallo');
        }
    }
}