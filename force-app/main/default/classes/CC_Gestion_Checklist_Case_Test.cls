@isTest
public with sharing class CC_Gestion_Checklist_Case_Test {
    @TestSetup
    static void makeData(){
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileSupervisor = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        
        User administrador = new User();
        administrador.ProfileId = profileAdmin;
        administrador.FirstName = 'Usuario Admin Prueba';
        administrador.LastName = 'last211';
        administrador.Email = 'aalsdna@kfsb.com';
        administrador.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        administrador.CompanyName = 'MST';
        administrador.Title = 'title';
        administrador.Alias = 'alias';
        administrador.TimeZoneSidKey = 'Europe/Paris';
        administrador.EmailEncodingKey = 'UTF-8';
        administrador.LanguageLocaleKey = 'es';
        administrador.LocaleSidKey = 'es_ES';
		insert administrador;

        System.runAs(administrador)
        {
            User supervisor = new User();
            supervisor.ProfileId = profileSupervisor;
            supervisor.FirstName = 'Supervisor';
            supervisor.LastName = 'last11';
            supervisor.Email = 'tuser000@amamama.com';
            supervisor.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
            supervisor.CompanyName = 'MST';
            supervisor.Title = 'title';
            supervisor.Alias = 'alias';
            supervisor.TimeZoneSidKey = 'Europe/Paris';
            supervisor.EmailEncodingKey = 'UTF-8';
            supervisor.LanguageLocaleKey = 'es';
            supervisor.LocaleSidKey = 'es_ES';
            supervisor.UserRoleId = rolCC.Id;
            insert supervisor;

            insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id);
			PermissionSet psOperador = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
			insert new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psOperador.Id);
        }

        Account accountTest = new Account();
        accountTest.Name = 'Account Test';
        insert accountTest;

        Id recordTypeEmpleado = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();

        Contact testContact = new Contact();
        testContact.FirstName = 'Contacto';
        testContact.LastName = 'Test';
        testContact.CC_Matricula__c = 'U0000001';
        testContact.Email = 'test@test.com';
        testContact.AccountId = accountTest.Id;
        testContact.RecordTypeId = recordTypeEmpleado;
        testContact.CC_Idioma__c = 'ES';
        insert testContact;

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

        CC_MCC__c producto = new CC_MCC__c(
        Name = 'Producto Test',
        RecordTypeId = productoId,
        CC_Tematica__c = tematica.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'PR-000001'
        );        
        insert producto;
        
        CC_MCC__c motivo = new CC_MCC__c(
        Name = 'Motivo Test',
        RecordTypeId = motivoId,
        CC_Producto_Servicio__c = producto.Id,
        CC_Tipo_Cliente__c = 'Cliente',
        CC_Codigo_Externo__c = 'MO-000001'
        );
        insert motivo;
        
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

        Id recordTypeIdCSIBankia = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        Case oCaso = new Case();
        oCaso.Subject = 'Test Incidencia';
        oCaso.Origin = 'Email';
        oCaso.Status = 'Activo';
        oCaso.ContactId = testContact.Id;
        oCaso.CC_NotIncidencia__c = '1';
        oCaso.CC_MailTelfNotif__c = 'test@test.es';
        oCaso.CC_CanalNotifCli__c = 'Email';
        oCaso.CC_Idioma__c = 'es';
        oCaso.CC_Detalles_Consulta__c = 'Detalles Consulta';
        oCaso.CC_Detalles_Solucion__c = 'Detalles Solución';
        oCaso.RecordTypeId = recordTypeIdCSIBankia;
        oCaso.CC_Canal_Procedencia__c = 'Accionista';
        oCaso.CC_Canal_Respuesta__c = 'Email';
        oCaso.CC_MCC_Tematica__c = tematica.Id;
        oCaso.CC_MCC_ProdServ__c = producto.Id;
        oCaso.CC_MCC_Motivo__c = motivo.Id;
        oCaso.CC_MCC_Causa__c = causa.Id;
		oCaso.CC_Motivo__c = motivo.Name;
		oCaso.OwnerID = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE LIMIT 1].Id;
        insert oCaso;

        SAC_MaestroTemas__c plantilla = new SAC_MaestroTemas__c();
        plantilla.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('CC_Checklist').getRecordTypeId();
        plantilla.Name = 'testPlantilla';
        insert plantilla;

        CC_TareaMotivo__c tareaMotivo = new CC_TareaMotivo__c();
        tareaMotivo.CC_Tarea_Motivo_Activa__c = true;
        tareaMotivo.CC_MCC_Motivo__c = motivo.Id;
        tareaMotivo.CC_Checklist__c = plantilla.Id;
        insert tareaMotivo;

        SAC_MaestroTemas__c maestroTemas = new SAC_MaestroTemas__c();
        maestroTemas.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('CC_ChecklistTareasProtocolarias').getRecordTypeId();
        maestroTemas.CC_Maestro_Temas__c = plantilla.Id;
        maestroTemas.SAC_Seccion__c = 'testSeccion';
        maestroTemas.Name = 'testName';
        maestroTemas.SAC_Activo__c = true;
        insert maestroTemas;

		List<SAC_Marca_Case__c> tareas = new List<SAC_Marca_Case__c>();
        List<SAC_MaestroTemas__c> listControles = [SELECT Id, Name FROM SAC_MaestroTemas__c WHERE RecordTypeId = :CC_TareasProtocolarias.RECTYPETAREAS];
        for (SAC_MaestroTemas__c control : listControles) {
            SAC_Marca_Case__c tarea = new SAC_Marca_Case__c();
            tarea.SAC_Marca__c = control.Id;
            tarea.SAC_Case__c = oCaso.Id;
            tarea.CC_TareaCompletada__c = true;
			tarea.CC_Motivo_del_Caso__c = oCaso.CC_Motivo__c;
            tareas.add(tarea);
        }
        insert tareas;
    }

    @isTest
    static void testTareasCompletadas() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Supervisor' AND IsActive = TRUE LIMIT 1];
        Case caso = [SELECT Id, CC_MCC_Motivo__c, CC_Motivo__c FROM Case WHERE Subject = 'Test Incidencia'];
        // Asegurarse de que todas las tareas estén completadas
        List<SAC_Marca_Case__c> tareas = [SELECT Id, CC_TareaCompletada__c FROM SAC_Marca_Case__c WHERE SAC_Case__c = :caso.Id];
        for (SAC_Marca_Case__c tarea : tareas) {
            tarea.CC_TareaCompletada__c = true;
			tarea.CC_Motivo_del_Caso__c = caso.CC_Motivo__c;
        }
        update tareas;
        System.runAs(supervisor) {
            Test.startTest();
                CC_Gestion_Checklist_Case.chequearChecklistAlGuardar(caso);
                System.assert(true, 'No se ha lanzado ninguna excepción');
            Test.stopTest();
        }
    }

    @isTest
    static void testTareasNoCompletadas() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE LIMIT 1];
        Case caso = [SELECT Id, CC_MCC_Motivo__c, CC_Motivo__c FROM Case WHERE Subject = 'Test Incidencia'];
        
        // Asegurarse de que todas las tareas estén NO completadas
        List<SAC_Marca_Case__c> tareas = [SELECT Id, CC_TareaCompletada__c, SAC_Marca__r.RecordTypeId FROM SAC_Marca_Case__c WHERE SAC_Case__c = :caso.Id];
		for (SAC_Marca_Case__c tarea : tareas) {
            tarea.CC_TareaCompletada__c = false;
			tarea.CC_Motivo_del_Caso__c = caso.CC_Motivo__c;
        }
        update tareas;
        System.runAs(supervisor) {
            Test.startTest();
            try {
                CC_Gestion_Checklist_Case.chequearChecklistAlGuardar(caso);
                System.assert(false, 'Se esperaba una excepción');
            } catch (AuraHandledException e) {
                System.assert(true, 'Se ha lanzado la excepción esperada');
            }
        	Test.stopTest();
		}
    }
}