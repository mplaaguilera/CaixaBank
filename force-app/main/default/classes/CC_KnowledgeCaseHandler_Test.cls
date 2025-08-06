@isTest
public class CC_KnowledgeCaseHandler_Test {
    
    @TestSetup
    static void setupTestData() {
        Map<String, User> usuarios = CC_TestDataFactory.insertUserAdminOperador('TEST001');
        User admin = usuarios.get('admin');
        User operador = usuarios.get('operador');

        //Dar acceso a Knodlege
        operador.UserPermissionsKnowledgeUser = true;
        update operador;

        PermissionSet permiso = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Knowledge_Publish'];
        insert new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = permiso.Id);     
        
        // Crear cola
        Group queue = new Group(
            Name = 'QueueTestKnowledge',
            DeveloperName = 'QueueTestKnowledge',
            Type = 'Queue'
        );
        insert queue;
        
        QueueSObject queueSObject = new QueueSObject(
            QueueId = queue.Id,
            SobjectType = 'Case'
        );
        insert queueSObject;

        GroupMember gm = new GroupMember(
            GroupId = queue.Id,
            UserOrGroupId = operador.Id
        );
        insert gm;

        //Ponerlo en el Public Group de Knowedege Supervisores
        Group groupKnowledgeSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Knowledge_Supervisores' LIMIT 1];
        GroupMember gmKnowledgeSupervisores = new GroupMember(
            GroupId = groupKnowledgeSupervisores.Id,
            UserOrGroupId = operador.Id
        );
        insert gmKnowledgeSupervisores;

        System.runAs(admin) {
            //Usar OWA buzon de empleados
            String defaultFromAddressEmpleados = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Buzon_Defecto_Empleados'].CC_Direccion_Correo__c;
           
            // Crear configuración de settings
            CC_Settings__c knowledgeSettings = new CC_Settings__c(
                Name = 'CC_Knowledge_Settings',
                CC_Activa__c = true,
                CC_Configuracion_1__c = '30;15;7',
                CC_Configuracion_2__c = '7',
                CC_Configuracion_3__c = 'true',
                CC_Configuracion_4__c = defaultFromAddressEmpleados,
                CC_Configuracion_6__c = 'PlantillaPorVencerTest',
                CC_Configuracion_7__c = 'PlantillaVencidoTest',
                CC_Configuracion_8__c = 'QueueTestKnowledge',
                CC_Configuracion_9__c = 'Archivar artículo',
                CC_Configuracion_10__c = 'Actualizar artículo',
                CC_Configuracion_11__c = 'Renovar artículo',    
                CC_Configuracion_12__c = 'Cliente'
            );
            insert knowledgeSettings;
            
            // Crear plantilla de email
            EmailTemplate template = new EmailTemplate(
                Name = 'PlantillaPorVencerTest',
                DeveloperName = 'PlantillaPorVencerTest',
                TemplateType = 'custom',
                Subject = 'Artículo próximo a vencer: [Knowledge.Title]',
                HtmlValue = '<p>El artículo [Knowledge.Title] vence el [Knowledge.CC_Fecha_Caducidad__c]</p>[Knowledge_Cuerpo_Articulo]',
                FolderId = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1].Id
            );
            insert template;

            EmailTemplate template2 = new EmailTemplate(
                Name = 'PlantillaVencidoTest',
                DeveloperName = 'PlantillaVencidoTest',
                TemplateType = 'custom',
                Subject = 'Artículo vencido: [Knowledge.Title]',
                HtmlValue = '<p>El artículo [Knowledge.Title] ha vencido</p>[Knowledge_Cuerpo_Articulo]',
                FolderId = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1].Id
            );
            insert template2;
    
        } 
    }
    
    @isTest
    static void testGetCustomSetting() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        String defaultFromAddressEmpleados = [
            SELECT CC_Direccion_Correo__c 
            FROM CC_Buzones_Por_Defecto__mdt 
            WHERE DeveloperName = 'CC_Buzon_Defecto_Empleados'
        ].CC_Direccion_Correo__c;

        Test.startTest();
        System.runAs(operador) {
            CC_KnowledgeCaseHandler.KnowledgeSettings settings = CC_KnowledgeCaseHandler.getCustomSetting();
            
            System.assertNotEquals(null, settings, 'La configuración no debería ser null');
            System.assertEquals(false, settings.diasAvisoAntes.isEmpty(), 'Debería tener 3 días de aviso');
            System.assertEquals(7, settings.diasAvisoDespues, 'Debería tener 7 días de aviso después');
            System.assertEquals(true, settings.activarEnvioCorreos, 'Debería estar activado el envío de correos');
            System.assertEquals(defaultFromAddressEmpleados, settings.buzonSalida, 'Debería tener el buzón correcto');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetCustomSettingNull() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        // Eliminar la configuración para probar el caso null
        delete [SELECT Id FROM CC_Settings__c WHERE Name = 'CC_Knowledge_Settings'];
        
        Test.startTest();
        System.runAs(operador) {
            CC_KnowledgeCaseHandler.KnowledgeSettings settings = CC_KnowledgeCaseHandler.getCustomSetting();
            System.assertEquals(null, settings, 'La configuración debería ser null cuando no existe');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcesarStringDias() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        Test.startTest();
        System.runAs(operador) {
            // Este método es privado, pero podemos probarlo indirectamente a través de getCustomSetting
            CC_KnowledgeCaseHandler.KnowledgeSettings settings = CC_KnowledgeCaseHandler.getCustomSetting();
            System.assertEquals(false, settings.diasAvisoAntes.isEmpty(), 'Debería procesar correctamente los días');
            System.assertEquals(30, settings.diasAvisoAntes[0], 'Primer día debería ser 30');
            System.assertEquals(15, settings.diasAvisoAntes[1], 'Segundo día debería ser 15');
            System.assertEquals(7, settings.diasAvisoAntes[2], 'Tercer día debería ser 7');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testReemplazarCamposKnowledge() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        User admin = CC_TestDataFactory.getUserAdmin();
        
        Test.startTest();
        System.runAs(operador) {
            // Crear un artículo de Knowledge de prueba usando KnowledgeArticleVersion
            CBK_UtilsDate.todayDate = Date.newInstance(2025, 1, 1);  //01/01/2025 dd/mm/yyyy        
            Knowledge__kav kav = new Knowledge__kav(
                Title = 'Artículo de Prueba',
                URLName = 'articulo-de-prueba',
                CC_Fecha_Caducidad__c = CBK_UtilsDate.todayDT().addDays(1), //02/01/2025 dd/mm/yyyy
                Answer__c = 'Contenido del artículo',
                CC_Tipo__c = 'Cliente'
            );
            //insert kav;

            String textoOriginal = 'El artículo [Knowledge.Title] vence el [Knowledge.CC_Fecha_Caducidad__c]';
            String resultado = CC_KnowledgeCaseHandler.reemplazarCamposKnowledge(textoOriginal, kav);
            
            System.assertNotEquals(textoOriginal, resultado, 'El texto debería ser reemplazado');
            System.assert(resultado.contains('Artículo de Prueba'), 'Debería contener el título del artículo');

            System.assert(resultado.contains('02/01/2025'), 'Debería contener la fecha formateada');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testReemplazarCamposKnowledgeNull() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        Test.startTest();
        System.runAs(operador) {
            String resultado1 = CC_KnowledgeCaseHandler.reemplazarCamposKnowledge(null, null);
            System.assertEquals(null, resultado1, 'Debería retornar null cuando ambos parámetros son null');
            
            String resultado2 = CC_KnowledgeCaseHandler.reemplazarCamposKnowledge('Texto', null);
            System.assertEquals('Texto', resultado2, 'Debería retornar el texto original cuando el artículo es null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testObtenerAdjuntos() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        Test.startTest();
        System.runAs(operador) {
            // Crear un artículo de Knowledge usando KnowledgeArticleVersion
            Knowledge__kav kav = new Knowledge__kav(
                Title = 'Artículo con Adjuntos',
                URLName = 'articulo-con-adjuntos',
                CC_Tipo__c = 'Cliente'
            );
            insert kav;  

                    
            // Crear un ContentVersion
            ContentVersion cv = new ContentVersion(
                Title = 'Documento de Prueba',
                PathOnClient = 'test.pdf',
                VersionData = Blob.valueOf('Contenido de prueba'),
                IsMajorVersion = true
            );
            insert cv;
            
            // Crear ContentDocumentLink
            ContentDocumentLink cdl = new ContentDocumentLink(
                LinkedEntityId = kav.Id,
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId,
                ShareType = 'V'
            );
            insert cdl;
                     
            Set<Id> articleIds = new Set<Id>{kav.Id};
            List<Knowledge__kav> scope = new List<Knowledge__kav>{kav};
                        
            Map<Id, List<ContentVersion>> resultado = CC_KnowledgeCaseHandler.obtenerAdjuntos(articleIds, scope);
            
            System.assertNotEquals(null, resultado, 'El resultado no debería ser null');
            System.assert(resultado.containsKey(kav.Id), 'Debería contener el artículo');
            System.assertEquals(false, resultado.get(kav.Id).isEmpty(), 'Debería tener un adjunto');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCrearTareaEnvioCorreo() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        Test.startTest();
        System.runAs(operador) {
            // Crear un caso de prueba
            Case caso = new Case(
                Subject = 'Caso de Prueba',
                Status = 'Activo'
            );
            insert caso;
            
            Task tarea = CC_KnowledgeCaseHandler.crearTareaEnvioCorreo(caso.Id, true, 'REF001', 'Descripción de prueba');
            
            System.assertEquals(caso.Id, tarea.WhatId, 'Debería tener el ID del caso correcto');
            System.assertEquals(CC_KnowledgeCaseHandler.TASK_TYPE_NOTIFICAR_VENCIMIENTO_KNOWLEDGE, tarea.Type, 'Debería tener el tipo correcto');
            System.assertEquals('Completed', tarea.Status, 'Debería estar completada');
            System.assertEquals('Notificación de vencimiento enviada', tarea.Subject, 'Debería tener el asunto correcto');
            System.assertEquals('REF001', tarea.CC_Referencia_Correo_Saliente__c, 'Debería tener la referencia correcta');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCrearTareaCambioStatus() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        Test.startTest();
        System.runAs(operador) {
            // Crear un caso de prueba
            Case caso = new Case(
                Subject = 'Caso de Prueba',
                Status = 'Activo'
            );
            insert caso;
            
            Task tarea = CC_KnowledgeCaseHandler.crearTareaCambioStatus(caso.Id, 'Cerrado', 'Archivar');
            
            System.assertEquals(caso.Id, tarea.WhatId, 'Debería tener el ID del caso correcto');
            System.assertEquals(CC_KnowledgeCaseHandler.TASK_TYPE_CAMBIO_ESTADO_CASO_KNOWLEDGE, tarea.Type, 'Debería tener el tipo correcto');
            System.assertEquals('Completed', tarea.Status, 'Debería estar completada');
            System.assertEquals('Caso actualizado a: Cerrado', tarea.Subject, 'Debería tener el asunto correcto');
            System.assertEquals('Archivar', tarea.CC_Tipo_Cierre__c, 'Debería tener el tipo de cierre correcto');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testRenderFromTemplate() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        Test.startTest();
        System.runAs(operador) {
            // Crear un caso de prueba
            Case caso = new Case(
                Subject = 'Caso de Prueba',
                Status = 'Activo'
            );
            insert caso;
            
            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = 'PlantillaPorVencerTest' LIMIT 1];
            
            Map<String, String> resultado = CC_KnowledgeCaseHandler.renderFromTemplate(template.Id, caso.Id);
            
            System.assertNotEquals(null, resultado, 'El resultado no debería ser null');
            System.assert(resultado.containsKey('subject'), 'Debería contener el subject');
            System.assert(resultado.containsKey('body'), 'Debería contener el body');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGestionarArticulosNotificaciones() {
        User operador = CC_TestDataFactory.getUserOperadorCliente(); 
        User admin = CC_TestDataFactory.getUserAdmin();
        Account account;      
        System.runAs(admin) {
            // Crear Account para el área responsable
            Id rtCentroCaixaBancario = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            account = new Account(
                Name = 'Área Responsable Test',
                RecordTypeId = rtCentroCaixaBancario
            );
            insert account;

            // Crear Contact colaborador
            Contact contacto = new Contact(
                FirstName = 'Colaborador',
                LastName = 'Test',
                Email = 'colaborador@test.com',
                AccountId = account.Id,
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(),
                CC_ResponsableKnowledge__c = 'Primer contacto'
            );
            insert contacto;

            AccountShare accShare = new AccountShare(
                AccountId = account.Id,
                UserOrGroupId = operador.Id,
                AccountAccessLevel = 'Edit',
                OpportunityAccessLevel = 'Edit',
                CaseAccessLevel = 'Edit'
            );

            ContactShare contactShare = new ContactShare(
                ContactId = contacto.Id,
                UserOrGroupId = operador.Id,
                ContactAccessLevel = 'Edit'
            );

            insert contactShare;
            insert accShare;
        }
        
       
        System.runAs(operador) {           
            // Crear artículo de Knowledge con fecha de vencimiento próxima usando KnowledgeArticleVersion
            Knowledge__kav kav = new Knowledge__kav(
                Title = 'Artículo Próximo a Vencer',
                URLName = 'articulo-proximo-a-vencer',
                CC_Area_Responsable__c = account.Id,
                CC_Fecha_Caducidad__c = CBK_UtilsDate.todayDT().addDays(30),
                Answer__c = 'Contenido del artículo de prueba',
                CC_Tipo__c = 'Cliente'
            );
            insert kav;

            Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :kav.Id].KnowledgeArticleId;
            
            // Publicar el artículo usando el servicio de publicación dentro del contexto del admin
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
            
                     
            List<Knowledge__kav> scope = [SELECT Id, KnowledgeArticleId, CC_Area_Responsable__c, CC_Fecha_Caducidad__c, Title,  Answer__c 
                                         FROM Knowledge__kav WHERE KnowledgeArticleId = :knowledgeArticleId AND PublishStatus = 'Online'];
            Test.startTest();
                CC_KnowledgeCaseHandler.gestionarArticulosNotificaciones(scope);
            Test.stopTest();
            // Verificar que se creó un caso
            List<Case> casosCreados = [SELECT Id FROM Case WHERE Subject = 'Artículo Próximo a Vencer'];
            System.assertEquals(false, casosCreados.isEmpty(), 'Debería haberse creado un caso');
            
            // Verificar que se creó un Case Extension
            List<CBK_Case_Extension__c> caseExtensions = [SELECT Id FROM CBK_Case_Extension__c WHERE CC_Articulo_Relacionado__c = :kav.Id];
            System.assertEquals(false, caseExtensions.isEmpty(), 'Debería haberse creado un Case Extension');
        }
 
    }
    
    @isTest
    static void testGestionarArticulosNotificacionesSinContactos() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        Test.startTest();
        System.runAs(operador) {
            // Crear artículo de Knowledge sin contactos asociados usando KnowledgeArticleVersion
            Knowledge__kav kav = new Knowledge__kav(
                Title = 'Artículo Sin Contactos',
                URLName = 'articulo-sin-contactos',
                CC_Fecha_Caducidad__c = CBK_UtilsDate.todayDT().addDays(30),
                Answer__c = 'Contenido del artículo de prueba',
                CC_Tipo__c = 'Cliente'
            );
            insert kav;

            Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :kav.Id].KnowledgeArticleId;
            
            // Publicar el artículo usando el servicio de publicación dentro del contexto del admin
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
            
            // Obtener el Knowledge__kav publicado
            Knowledge__kav articulo = [SELECT Id, KnowledgeArticleId, CC_Area_Responsable__c, CC_Fecha_Caducidad__c, Title,  Answer__c 
                                      FROM Knowledge__kav WHERE KnowledgeArticleId = :knowledgeArticleId];
            
            List<Knowledge__kav> scope = new List<Knowledge__kav>{articulo};
            
            // No debería lanzar excepción
            CC_KnowledgeCaseHandler.gestionarArticulosNotificaciones(scope);
            
            // No debería crear casos
            List<Case> casosCreados = [SELECT Id FROM Case WHERE Subject = 'Artículo Sin Contactos'];
            System.assertEquals(true, casosCreados.isEmpty(), 'No debería haberse creado ningún caso');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcesarNotificacionArticulosVencidos() {
        User operador = CC_TestDataFactory.getUserOperadorCliente(); 
        User admin = CC_TestDataFactory.getUserAdmin();
        Account account;      
        System.runAs(admin) {
            // Crear Account para el área responsable
            Id rtCentroCaixaBancario = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            account = new Account(
                Name = 'Área Responsable Test',
                RecordTypeId = rtCentroCaixaBancario
            );
            insert account;

            // Crear Contact colaborador
            Contact contacto = new Contact(
                FirstName = 'Colaborador',
                LastName = 'Test',
                Email = 'colaborador@test.com',
                AccountId = account.Id,
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(),
                CC_ResponsableKnowledge__c = 'Primer contacto'
            );
            insert contacto;

            AccountShare accShare = new AccountShare(
                AccountId = account.Id,
                UserOrGroupId = operador.Id,
                AccountAccessLevel = 'Edit',
                OpportunityAccessLevel = 'Edit',
                CaseAccessLevel = 'Edit'
            );

            ContactShare contactShare = new ContactShare(
                ContactId = contacto.Id,
                UserOrGroupId = operador.Id,
                ContactAccessLevel = 'Edit'
            );

            insert contactShare;
            insert accShare;
        }
        
       
        System.runAs(operador) {           
            // Crear artículo de Knowledge con fecha de vencimiento próxima usando KnowledgeArticleVersion
            Knowledge__kav kav = new Knowledge__kav(
                Title = 'Artículo Vencido',
                URLName = 'articulo-proximo-a-vencer',
                CC_Area_Responsable__c = account.Id,
                CC_Fecha_Caducidad__c = CBK_UtilsDate.todayDT().addDays(30),
                Answer__c = 'Contenido del artículo de prueba',
                CC_Tipo__c = 'Cliente'
            );
            insert kav;

            Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :kav.Id].KnowledgeArticleId;
            
            // Publicar el artículo usando el servicio de publicación dentro del contexto del admin
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
            // Archivarlo
            KbManagement.PublishingService.archiveOnlineArticle(knowledgeArticleId, null);
            
                     
            List<Knowledge__kav> scope = [SELECT Id FROM Knowledge__kav WHERE KnowledgeArticleId = :knowledgeArticleId LIMIT 1];
            List<Id> scopeId = new List<Id>{scope[0].Id};
            Test.startTest();
               CC_KnowledgeCaseHandler.procesarNotificacionArticulosVencidos(scopeId);
            Test.stopTest();
            // Verificar que se creó un caso
            List<Case> casosCreados = [SELECT Id FROM Case WHERE Subject = 'Artículo Vencido'];
            System.assertEquals(false, casosCreados.isEmpty(), 'Debería haberse creado un caso');
            
            // Verificar que se creó un Case Extension
            List<CBK_Case_Extension__c> caseExtensions = [SELECT Id FROM CBK_Case_Extension__c WHERE CC_Articulo_Relacionado__c = : scope[0].Id];
            System.assertEquals(false, caseExtensions.isEmpty(), 'Debería haberse creado un Case Extension');
        }
    }
}