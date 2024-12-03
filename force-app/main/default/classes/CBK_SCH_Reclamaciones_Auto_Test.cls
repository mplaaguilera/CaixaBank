@isTest
public with sharing class CBK_SCH_Reclamaciones_Auto_Test {
	@testSetup
    static void testSetup() {

        User adminSACH = new User();
        adminSACH.FirstName = 'Admin';
        adminSACH.LastName = '1';
        adminSACH.IsActive = true;
        adminSACH.Alias = 'Admin';
        adminSACH.Email = 'usuarioSACH_test@test.com';
        adminSACH.EmailEncodingKey = 'ISO-8859-1';
        adminSACH.LanguageLocaleKey = 'es';
        adminSACH.LocaleSidKey = 'es_ES';
        adminSACH.UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'SACH'].Id;
        adminSACH.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        adminSACH.TimeZoneSidKey = 'Europe/Madrid';
        adminSACH.UserName = 'usuariotest_' + UserInfo.getOrganizationId() + '_' + System.currentTimeMillis() + '@test.com';

        insert adminSACH;

        List<PermissionSetAssignment> nuevosPermisos = new List<PermissionSetAssignment>();
        List<PermissionSet> permissionSet = [SELECT Id, Name FROM PermissionSet WHERE  Name LIKE 'SACH%'];

        for (PermissionSet permissionSet1: permissionSet ) {
            PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
            if(permissionSet1.Name.startsWith('SACH')) {
                nuevoPermiso.PermissionSetId = permissionSet1.Id;
                nuevoPermiso.AssigneeId = adminSACH.Id;
            }
            nuevosPermisos.add(nuevoPermiso);
        }
        insert nuevosPermisos;

        System.runAs(adminSACH){
            List<BusinessHours> calendario = [SELECT Id FROM BusinessHours LIMIT 1];

            EmailTemplate template = new EmailTemplate();
            template.FolderId = UserInfo.getUserId();
            template.Name = 'Plantilla Traslado Colaborador Test';
            template.DeveloperName = 'Plantilla_Traslado_Colaborador_Test';
            template.TemplateType = 'Text';
            System.runAs(new User(Id = UserInfo.getUserId())) {
                insert template;
            }

            CC_Configuracion_Reclamacion__c configuracionTest = new CC_Configuracion_Reclamacion__c();
            configuracionTest.CC_1a_Reclamacion_Activa__c = true;
            configuracionTest.CC_Calendario__c = calendario[0].Id;
            configuracionTest.CC_Fecha_Activacion_1a_Rec__c = System.today();
            configuracionTest.CC_Horas_1a_Reclamacion__c = '0';
            configuracionTest.CC_Nombre_Plantilla_1_Rec_Colab_Cast__c = template.Name;
            configuracionTest.CC_Plantilla_1_Rec_Colab_Cast__c = template.DeveloperName;
            insert configuracionTest;

            CC_Grupo_Colaborador__c grupoTest = new CC_Grupo_Colaborador__c();
            grupoTest.Name = 'Grupo Pruebas SACH TEST';
            grupoTest.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Grupo_Colaborador__c', 'CC_CentroCaixaBank');
            grupoTest.OS_Negocio__c = 'CC';
            grupoTest.CC_Reclamacion_Automatica__c = configuracionTest.Id;
            insert grupoTest;
        }
        
    }

    @isTest
    static void correoNotIncomingTraslado() {
        Case caso = new Case();
        caso.Subject = 'Mail entrante';
        caso.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'SACH_Cliente' LIMIT 1].Id;
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.Status = 'Activo';
        insert caso;

        // Testar el trigger del objeto EmailMessage para SACH
        EmailMessage emailmes = new EmailMessage();
        emailmes.TextBody ='Email Body #@202204103132540#.';
        emailmes.Incoming = false;
        emailmes.RelatedToId = caso.Id;
        emailmes.CC_Procedencia__c = 'Traslado Colaborador';
        emailmes.CC_Grupo_Colab__c = [SELECT Id, Name FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Pruebas SACH TEST' LIMIT 1].Name;
        emailmes.toAddress = 'test@test.com';
        emailmes.CcAddress = 'test@test.com';
        insert emailmes;

        List<CBK_SCH_PendingProcess__c> pendingProcessInsertList = [SELECT Id, RecordId__c, Schedule_Time__c, ClassName__c FROM CBK_SCH_PendingProcess__c WHERE RecordId__c =: caso.Id];
        System.assert(!pendingProcessInsertList.isEmpty());

        test.startTest();
        
        User usuarioAdmin = [SELECT Id FROM User WHERE Email = 'usuarioSACH_test@test.com'];

        System.runAs(usuarioAdmin){
            CBK_SCH_Reclamaciones_Auto implClass = new CBK_SCH_Reclamaciones_Auto();
            implClass.lstInfoProcess = pendingProcessInsertList;
            System.enqueueJob(implClass);
        }
        
        test.stopTest();

        List<Task> tareas = [SELECT Id FROM Task WHERE WhatId = :caso.Id AND Type = 'Reclamación Traslado Colaborador'];

        System.assert(!tareas.isEmpty());
	}
}