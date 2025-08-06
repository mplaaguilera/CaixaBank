@isTest
public with sharing class CC_Gestion_Checklist_Case_Test_2 {
    @isTest
    static void testTareasProtocolariasNoCompletadas() {
        // Crear un usuario administrador
        User administrador = new User();
        administrador.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
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

        // Crear un usuario supervisor
        System.runAs(administrador) {
            User supervisor = new User();
            supervisor.ProfileId = [SELECT Id FROM Profile WHERE Name = 'CC_Supervisor'].Id;
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
            supervisor.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
            insert supervisor;

            // Crear un caso
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
            Case OGR2 = new Case();
            OGR2.Subject = 'Test Incidencia 2';
            OGR2.Origin = 'Email';
            OGR2.Status = 'Activo';
            OGR2.ContactId = testContact.Id;
            OGR2.CC_NotIncidencia__c = '1';
            OGR2.CC_MailTelfNotif__c = 'test@test.es';
            OGR2.CC_CanalNotifCli__c = 'Email';
            OGR2.CC_Idioma__c = 'es';
            OGR2.CC_Detalles_Consulta__c = 'Detalles Consulta';
            OGR2.CC_Detalles_Solucion__c = 'Detalles Solución';
            OGR2.RecordTypeId = recordTypeIdCSIBankia;
            OGR2.CC_Canal_Procedencia__c = 'Accionista';
            OGR2.CC_Canal_Respuesta__c = 'Email';
            OGR2.CC_MCC_Tematica__c = tematica.Id;
            OGR2.CC_MCC_ProdServ__c = producto.Id;
            OGR2.CC_MCC_Motivo__c = motivo.Id;
            OGR2.CC_MCC_Causa__c = causa.Id;
            OGR2.CC_Motivo__c = motivo.Name;
            insert OGR2;

            // Agregar tareas protocolarias no completadas
            List<SAC_MaestroTemas__c> listControles2 = [SELECT Id, Name FROM SAC_MaestroTemas__c WHERE RecordTypeId = :CC_TareasProtocolarias.RECTYPETAREAS];
            for (SAC_MaestroTemas__c control : listControles2) {
                SAC_Marca_Case__c tarea2 = new SAC_Marca_Case__c();
                tarea2.SAC_Marca__c = control.Id;
                tarea2.SAC_Case__c = OGR2.Id;
                tarea2.CC_TareaCompletada__c = false;
                //tarea2.SAC_Marca__r.RecordTypeId = CC_TareasProtocolarias.RECTYPETAREAS;
                insert tarea2;
            }

            // Ejecutar el test
            System.runAs(supervisor) {
                Test.startTest();
                    try {
                        CC_Gestion_Checklist_Case.chequearChecklistAlGuardar(OGR2);
                        System.assert(false, 'Se esperaba una excepción');
                    } catch (AuraHandledException e) {
                        System.assert(true, 'Se ha lanzado la excepción esperada');
                    }
                Test.stopTest();
            }
        }
    }
}