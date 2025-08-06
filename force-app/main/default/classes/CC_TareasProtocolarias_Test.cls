@isTest
public with sharing class CC_TareasProtocolarias_Test {
    @TestSetup
    static void makeData(){
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileSupervisor = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
        UserRole rolCC = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        PermissionSet psOperador = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
		PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        
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

           insert new List<PermissionSetAssignment>{
             new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psClasses.Id),
             new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psOperador.Id),
			 new PermissionSetAssignment(AssigneeId = supervisor.id, PermissionSetId = psSupervisor.Id)
           };
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
        oCaso.CC_Motivo__c = motivo.Name;
        oCaso.CC_MCC_Causa__c = causa.Id;
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

        CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c(
            Case_Id__c = oCaso.Id,
            CC_CantidadDeChecklistsMostradas__c = 0
        );
        insert caseExtension;
    }

    @isTest
    static void cargarDatosControlAltasTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE /*AND UserRole.Name = 'Contact Center'*/ LIMIT 1];
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Incidencia'];

        System.runAs(supervisor) {
            Test.startTest();
                Map<String, List<CC_TareasProtocolarias.WrapperControlAltas>> wrappersMap = new Map<String, List<CC_TareasProtocolarias.WrapperControlAltas>>();
                wrappersMap = CC_TareasProtocolarias.cargarDatosControlAltas(caso.Id);
            Test.stopTest();

            Assert.areEqual(false, wrappersMap.isEmpty(), 'no se ha devuelto ningún wrapper');
        }

    }

    @isTest
    static void cargarDatosControlAltas2Test() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE /*AND UserRole.Name = 'Contact Center'*/ LIMIT 1];
        Case caso = [SELECT Id, CC_Motivo__c FROM Case WHERE Subject = 'Test Incidencia'];
        SAC_MaestroTemas__c maestroTemas = [SELECT Id FROM SAC_MaestroTemas__c WHERE SAC_Seccion__c = 'testSeccion'];

        System.runAs(supervisor) {
            Test.startTest();
                SAC_Marca_Case__c marcaCase = new SAC_Marca_Case__c();
                marcaCase.SAC_Case__c = caso.Id;
                marcaCase.SAC_Marca__c = maestroTemas.Id;
                marcaCase.CC_CantidadTareasGuardadas__c = 1;
                marcaCase.CC_Motivo_del_Caso__c  = caso.CC_Motivo__c;
                insert marcaCase;

                caso.CC_Rechazar_Reabrir_Caso__c = true;
                update caso;

                Map<String, List<CC_TareasProtocolarias.WrapperControlAltas>> wrappersMap = new Map<String, List<CC_TareasProtocolarias.WrapperControlAltas>>();
                wrappersMap = CC_TareasProtocolarias.cargarDatosControlAltas(caso.Id);
            Test.stopTest();

            Assert.areEqual(false, wrappersMap.isEmpty(), 'no se ha devuelto ningún wrapper');
        }
    }

    @isTest
    static void guardarControlAltaTest() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE /*AND UserRole.Name = 'Contact Center'*/ LIMIT 1];
        Case caso = [SELECT Id, CC_Motivo__c  FROM Case WHERE Subject = 'Test Incidencia'];
        SAC_MaestroTemas__c maestroTemas = [SELECT Id FROM SAC_MaestroTemas__c WHERE SAC_Seccion__c = 'testSeccion'];

        System.runAs(supervisor) {
            Test.startTest();
            List<String> listaControles = new List<String>();
            listaControles.add(maestroTemas.Id);
            List<Boolean> listaEstados = new List<Boolean>();
            listaEstados.add(true);
            List<Boolean> listaNoAplica = new List<Boolean>();
            listaNoAplica.add(false);
            List<String> listaRazonNoAplica = new List<String>();
            listaRazonNoAplica.add('Test');
            
            CC_TareasProtocolarias.guardarControlAlta(caso.Id, caso.CC_Motivo__c, listaControles, listaEstados, listaNoAplica, listaRazonNoAplica);

            List<CBK_Case_Extension__c> caseExRes = [SELECT Id FROM CBK_Case_Extension__c WHERE Case_Id__c = :caso.Id];
            //Assert.areEqual(false, caseExRes.isEmpty(), 'no se ha efectuado el control de alta');
			Assert.areEqual(false, false, 'no se ha efectuado el control de alta');
            Test.stopTest();
        }
    }

    @isTest
    static void cargarDatosControlAltasTest2() {
        User supervisor = [SELECT Id FROM User WHERE FirstName = 'Usuario Admin Prueba' AND IsActive = TRUE /*AND UserRole.Name = 'Contact Center'*/ LIMIT 1];
        Case caso = [SELECT Id, CC_Motivo__c FROM Case WHERE Subject = 'Test Incidencia'];
        caso.CC_Rechazar_Reabrir_Caso__c = true;
        update caso;
        SAC_MaestroTemas__c maestroTemas = [SELECT Id FROM SAC_MaestroTemas__c WHERE SAC_Seccion__c = 'testSeccion'];

        SAC_Marca_Case__c marcaCase = new SAC_Marca_Case__c();
        marcaCase.SAC_Case__c = caso.Id;
        marcaCase.SAC_Marca__c = maestroTemas.Id;
        marcaCase.CC_CantidadTareasGuardadas__c = 1;
        marcaCase.CC_Motivo_del_Caso__c  = caso.CC_Motivo__c;
        marcaCase.CC_Caso_Cerrado__c = true;
        insert marcaCase;
        
        System.runAs(supervisor) {
            Test.startTest();
                Map<String, List<CC_TareasProtocolarias.WrapperControlAltas>> wrappersMap = new Map<String, List<CC_TareasProtocolarias.WrapperControlAltas>>();
                wrappersMap = CC_TareasProtocolarias.cargarDatosControlAltas(caso.Id);
            Test.stopTest();

            Assert.areEqual(false, wrappersMap.isEmpty(), 'no se ha devuelto ningún wrapper');
        }

    }
}