@isTest
public with sharing class CC_Contar_Casos_KPI_Batch_Test {
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
    public static void calcularRepetidos() {  
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
        List<Case> listCaseInsert = new List<Case>();
        Case caso = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente', Origin = 'Phone', CC_Tipo_Contacto__c = 'Consulta', recordTypeId = recordCaso,
        CC_Canal_Procedencia__c = 'Tarjetas',CC_MCC_Motivo__c = mcc2.Id,CC_MCC_ProdServ__c = mcc1.Id,CC_MCC_Tematica__c = mcc.Id,
        CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta', CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución');
        listCaseInsert.add(caso);
        Case caso2 = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente', Origin = 'Phone', CC_Tipo_Contacto__c = 'Consulta', recordTypeId = recordCaso,
        CC_Canal_Procedencia__c = 'Tarjetas',CC_MCC_Motivo__c = mcc2.Id,CC_MCC_ProdServ__c = mcc1.Id,CC_MCC_Tematica__c = mcc.Id,CC_MCC_Causa__c = mccCausa.Id, CC_MCC_Solucion__c = solucion.Id, CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta', CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución', CC_Status_Autorizacion__c = 'ERROR', CC_OTP_Nivel__c = 'Cliente Digital', CC_OTP_Valido__c = false);
        listCaseInsert.add(caso2);
        Case caso3 = new Case(AccountId=cuenta.Id, ContactId=contacto.Id, Status = 'Activo', CC_Idioma__c = 'es', Subject = 'Prueba',
        CC_Tipo_Cliente__c = 'Cliente', Origin = 'Phone', CC_Tipo_Contacto__c = 'Consulta', recordTypeId = recordCaso,
        CC_Canal_Procedencia__c = 'Tarjetas',CC_MCC_Motivo__c = mcc2.Id,CC_MCC_ProdServ__c = mcc1.Id,CC_MCC_Tematica__c = mcc.Id,CC_MCC_Causa__c = mccCausa.Id, CC_MCC_Solucion__c = solucion.Id, CC_Detalles_Consulta__c = 'Detalles 1234-5678-9876-5432 Consulta', CC_Detalles_Solucion__c = 'Detalles 1234-5678-9876-5432 Solución', CC_Status_Autorizacion__c = 'APPROVED', CC_OTP_Nivel__c = 'Cliente Digital', CC_OTP_Valido__c = true);
        listCaseInsert.add(caso3);
        insert listCaseInsert;

        User supervisorUser = [SELECT Id FROM User WHERE LastName LIKE 'last2' AND IsActive=true LIMIT 1];
        System.runAs(supervisorUser){
         Test.StartTest();
         List<Case> lstCasos = [SELECT CaseNumber, AccountId, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c, Origin, CC_MCC_Tematica__c,  CC_MCC_Tematica__r.Name,CC_MCC_Motivo__r.CC_Excluir_Registro__c, RecordTypeId, Status, CC_NumeroCasoOrigenRep__c, CC_OTP_Valido__c, CC_OTP_Nivel__c, CC_MCC_Solucion__r.Name, CC_Motivo_Derivacion__c, CC_Status_Autorizacion__c,CC_MCC_Tematica__r.CC_Excluir_Registro__c, CC_Repetitivo__c FROM Case WHERE RecordType.DeveloperName = 'CC_Cliente' AND Status != 'Rechazado' AND CreatedDate = TODAY order by AccountId asc];
        List<Case> repetitividad = CC_Marcar_Casos_KPI.calcularRepetitividad(lstCasos);
        if (!repetitividad.isEmpty()){
           update repetitividad;
        }
        List<Case> caso3Resultado = [SELECT CaseNumber, CC_Cantidad_Repeticiones__c, CC_NumeroCasoOrigenRep__c FROM Case WHERE CC_Cantidad_Repeticiones__c != NULL LIMIT 100];

        CC_Contar_Casos_KPI_Batch batch = new CC_Contar_Casos_KPI_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
        }
        List<Case> caso2Resultado = [SELECT CaseNumber, CC_Cantidad_Repeticiones__c, CC_NumeroCasoOrigenRep__c FROM Case WHERE CC_Cantidad_Repeticiones__c != NULL];
         assert.areEqual(2, caso2Resultado[0].CC_Cantidad_Repeticiones__c, 'El batch Fallo');
    }
}