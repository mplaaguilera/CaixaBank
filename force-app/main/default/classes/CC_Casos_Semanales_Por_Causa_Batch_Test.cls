@isTest
public with sharing class CC_Casos_Semanales_Por_Causa_Batch_Test {
    @TestSetup
    static void makeData() {
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        Id roleDirectorioCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center_sin_acceso_a_Directorio'].Id;
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>();
        List<CC_MCC__c> mccCreado = new List<CC_MCC__c>();
        List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();

        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;        
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        userList.add(usuarioAdmin);

        User operadorCliente = new User();
        operadorCliente.profileId = profileId;
        operadorCliente.UserRoleId = roleDirectorioCC;
        operadorCliente.AV_ExternalID__c = 'U0124112';
        operadorCliente.FirstName = 'Operador';
        operadorCliente.LastName = 'Operador Cliente';
        operadorCliente.Email = 'tuser000@amamama.com';
        operadorCliente.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        operadorCliente.CompanyName = 'MST';
        operadorCliente.Title = 'title';
        operadorCliente.Alias = 'alias';
        operadorCliente.TimeZoneSidKey = 'Europe/Paris';
        operadorCliente.EmailEncodingKey = 'UTF-8';
        operadorCliente.LanguageLocaleKey = 'es';
        operadorCliente.LocaleSidKey = 'es_ES';
        userList.add(operadorCliente);
        insert userList;

        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psOperadorCliente.Id);
        insertPSAssOperadores.add(psaOperadorCliente);

        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psClasses.Id);
        insertPSAssOperadores.add(psaOperadorClasses);

        Database.insert(insertPSAssOperadores);

        System.runAs(usuarioAdmin) {
            Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            Id tematicaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
            Id productoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c','CC_Producto_Servicio');
            Id motivoId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
            Id causaId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Causa');

            CC_MCC__c tematica = new CC_MCC__c(
            Name = 'Tematica Test',
            RecordTypeId = tematicaId,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Canal_Operativo__c = 'Cajero',
            CC_Codigo_Externo__c = 'TE-000001'
            );
            insert tematica;
            mccCreado.add(tematica);

            CC_MCC__c producto = new CC_MCC__c(
            Name = 'Producto Test',
            RecordTypeId = productoId,
            CC_Tematica__c = tematica.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'PR-000001'
            );        
            insert producto;
            mccCreado.add(producto);
            
            CC_MCC__c motivo = new CC_MCC__c(
            Name = 'Motivo Test',
            RecordTypeId = motivoId,
            CC_Producto_Servicio__c = producto.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'MO-000001'
            );
            insert motivo;
            mccCreado.add(motivo);
            
            CC_MCC__c causa = new CC_MCC__c(
            Name = 'Causa Test',
            RecordTypeId = causaId,
            CC_Producto_Servicio__c = motivo.Id,
            CC_Tipo_Cliente__c = 'Cliente',
            CC_Codigo_Externo__c = 'CA-000001',
            CC_Desviacion_Media_LV__c = 0,
            CC_Desviacion_Media_SD__c = 0
            );
            insert causa;
            mccCreado.add(causa);

            for(CC_MCC__c record : mccCreado) {
                CC_MCC__Share mccShare = new CC_MCC__Share();
                mccShare.ParentId = record.Id;
                mccShare.UserOrGroupId = operadorCliente.Id;
                mccShare.AccessLevel = 'Edit';
                totalPermisosMCC.add(mccShare);
            }
            insert totalPermisosMCC;

            Case caso = new Case();
            caso.Subject = 'Caso batch';
            caso.Origin = 'Email';
            caso.Status = 'Cerrado';
            caso.CC_Idioma__c = 'es';
            caso.CC_MCC_Tematica__c = tematica.Id; 
            caso.CC_MCC_ProdServ__c = producto.Id;
            caso.CC_MCC_Motivo__c = motivo.Id;
            caso.CC_MCC_Causa__c = causa.Id;
            caso.RecordTypeId = recordTypeCaso;
            insert caso;

            CaseShare caseShare = new CaseShare();
            caseShare.CaseId = caso.Id;
            caseShare.UserOrGroupId = operadorCliente.Id;
            caseShare.CaseAccessLevel = 'Edit';
            insert caseShare;

            CC_Prevision__c prevision = new CC_Prevision__c();
            insert prevision;
        }
    }

    @isTest
    public static void executeBatchTest() {
        Test.startTest();
        System.runAs(new User(Id = [SELECT Id FROM User Where LastName = 'Operador Cliente' LIMIT 1].Id)) {
            CC_Casos_Semanales_Por_Causa_Batch batch = new CC_Casos_Semanales_Por_Causa_Batch();
            List<CC_MCC__c> causas = [SELECT Id FROM CC_MCC__c WHERE RecordType.DeveloperName = 'CC_Causa'];
            batch.execute(null, causas);
            Integer numPrevisiones = [SELECT Count() FROM CC_Prevision__c];
            System.assertEquals(numPrevisiones > 0, true, 'Error en el batch');
        }
        Test.stopTest();
    }
}