@isTest
public class CC_CaseStatusKnowledgeController_Test {
    
    @TestSetup
    static void setupTestData() {
        // Crear usuarios de prueba
        Map<String, User> usuarios = CC_TestDataFactory.insertUserAdminOperador('TEST001');
        User admin = usuarios.get('admin');
        User operador = usuarios.get('operador');
        
        // Dar permisos de Knowledge al operador
        operador.UserPermissionsKnowledgeUser = true;
        update operador;
        
        // Asignar Permission Set de Knowledge
        PermissionSet permiso = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Knowledge_Publish' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = permiso.Id);        
     
        // Agregar operador al grupo de supervisores de Knowledge
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
                CC_Configuracion_11__c = 'Renovar artículo'
            );
            insert knowledgeSettings;
            
   
        } 
    }
    
    @isTest
    static void testChangeStatusWithoutArticle() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        Boolean error = false;
        
        System.runAs(operador) {
            // Crear caso sin artículo relacionado
            Case caso = new Case(
                Subject = 'Caso de Prueba',
                Status = 'Activo',
                RecordTypeId = CC_KnowledgeCaseHandler.CASE_KNOWDLEGE_RT
            );
            insert caso;

            Test.startTest();
            try {
                // Cambiar estado sin artículo - debería fallar
                CC_CaseStatusKnowledgeController.changeStatusKnowledgeCase(caso.Id, 'Cerrado', 'Archivar');
            } catch (AuraHandledException e) {
                error = true;
            }
            Test.stopTest();
            
            // Verificar que el caso NO se actualizó
            Case casoActualizado = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];
            System.assertEquals('Activo', casoActualizado.Status, 'No debería haberse actualizado el caso');
            System.assertEquals(true, error, 'Debería haber lanzado una excepción');        
        }
    }
    
    @isTest
    static void testChangeStatusWithArticleArchivar() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        System.runAs(operador) {
            // Crear artículo de Knowledge
            Knowledge__kav articulo = new Knowledge__kav(
                Title = 'Artículo de Prueba',
                UrlName = 'articulo-prueba',
                Language = 'es'              
            );
            insert articulo;

            Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :articulo.Id LIMIT 1].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);

            // Crear extensión de caso
            CBK_Case_Extension__c extension = new CBK_Case_Extension__c(
                CC_Articulo_Relacionado__c = articulo.Id
            );
            insert extension;
            
            // Crear caso con artículo relacionado
            Case caso = new Case(
                Subject = 'Caso con Artículo',
                Status = 'Activo',
                CBK_Case_Extension_Id__c = extension.Id,
                RecordTypeId = CC_KnowledgeCaseHandler.CASE_KNOWDLEGE_RT
            );
            insert caso;
            
            Test.startTest();
            // Cambiar estado con acción Archivar
            CC_CaseStatusKnowledgeController.changeStatusKnowledgeCase(caso.Id, 'Cerrado', 'Archivar');
            Test.stopTest();
            
            // Verificar que el caso se actualizó
            Case casoActualizado = [SELECT Id, Status, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c 
                                   FROM Case WHERE Id = :caso.Id];
            String detallesConsulta =  casoActualizado.CC_Detalles_Consulta__c;
            String detallesSolucion =  casoActualizado.CC_Detalles_Solucion__c;
            System.assertEquals('Cerrado', casoActualizado.Status, 'El estado debería haberse actualizado a Cerrado');
            System.assertEquals(true, detallesConsulta.contains('Archivar'), 'Debería tener los detalles de consulta correctos');
            System.assertEquals(true, detallesSolucion.contains('Archivar'), 'Debería tener los detalles de solución correctos');

            //Chequear articulo
            Knowledge__kav articuloActualizado = [SELECT Id, PublishStatus FROM Knowledge__kav WHERE Id = :articulo.Id LIMIT 1];
            System.assertEquals('Archived', articuloActualizado.PublishStatus, 'El artículo debería estar archivado');
        }
    }
    
    @isTest
    static void testChangeStatusWithArticleRenovar() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        System.runAs(operador) {
            // Crear artículo de Knowledge
            Knowledge__kav articulo = new Knowledge__kav(
                Title = 'Artículo de Prueba',
                UrlName = 'articulo-prueba-renovar',
                Language = 'es'
            );
            insert articulo;

            Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :articulo.Id LIMIT 1].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
            
            // Crear extensión de caso
            CBK_Case_Extension__c extension = new CBK_Case_Extension__c(
                CC_Articulo_Relacionado__c = articulo.Id
            );
            insert extension;
            
            // Crear caso con artículo relacionado
            Case caso = new Case(
                Subject = 'Caso con Artículo',
                Status = 'Activo',
                CBK_Case_Extension_Id__c = extension.Id,
                RecordTypeId = CC_KnowledgeCaseHandler.CASE_KNOWDLEGE_RT
            );
            insert caso;
            
            Test.startTest();
            // Cambiar estado con acción Renovar
            CC_CaseStatusKnowledgeController.changeStatusKnowledgeCase(caso.Id, 'Cerrado', 'Renovar');
            Test.stopTest();
            
            // Verificar que el caso se actualizó
            Case casoActualizado = [SELECT Id, Status, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c 
                                   FROM Case WHERE Id = :caso.Id];
            String detallesConsulta =  casoActualizado.CC_Detalles_Consulta__c;
            String detallesSolucion =  casoActualizado.CC_Detalles_Solucion__c;
            System.assertEquals('Cerrado', casoActualizado.Status, 'El estado debería haberse actualizado a Cerrado');
            System.assertEquals(true, detallesConsulta.contains('Renovar'), 'Debería tener los detalles de consulta correctos');
            System.assertEquals(true, detallesSolucion.contains('Renovar'), 'Debería tener los detalles de solución correctos');

            //Chequear articulo
            CBK_UtilsDate.nowDatetime = DateTime.newInstance(2025, 1, 1, 0, 0, 0);

            Knowledge__kav articuloActualizado = [
                SELECT Id, PublishStatus, CC_Fecha_Caducidad__c 
                FROM Knowledge__kav 
                WHERE KnowledgeArticleId = :knowledgeArticleId LIMIT 1
            ];
            System.assertEquals(true, articuloActualizado.CC_Fecha_Caducidad__c.year() == 2026, 'La fecha de caducidad debería ser el año siguiente');
            System.assertEquals('Online', articuloActualizado.PublishStatus, 'El artículo debería estar en estado Online');
        }
    }
    
    @isTest
    static void testChangeStatusWithArticleActualizarSuccess() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();       
        
        System.runAs(operador) {
            //Chequear articulo
            CBK_UtilsDate.nowDatetime = DateTime.newInstance(2025, 1, 1, 0, 0, 0);
            // Crear artículo de Knowledge con fecha de caducidad en el año siguiente
            Knowledge__kav articulo = new Knowledge__kav(
                Title = 'Artículo de Prueba',
                UrlName = 'articulo-prueba-actualizar',
                Language = 'es',
                CC_Fecha_Caducidad__c = CBK_UtilsDate.nowDT().addYears(1)
            );
            insert articulo;

            Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :articulo.Id LIMIT 1].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);

            // Crear extensión de caso
            CBK_Case_Extension__c extension = new CBK_Case_Extension__c(
                CC_Articulo_Relacionado__c = articulo.Id
            );
            insert extension;
            
            // Crear caso con artículo relacionado
            Case caso = new Case(
                Subject = 'Caso con Artículo',
                Status = 'Activo',
                CBK_Case_Extension_Id__c = extension.Id,
                RecordTypeId = CC_KnowledgeCaseHandler.CASE_KNOWDLEGE_RT
            );
            insert caso;

            Test.startTest();
            // Cambiar estado con acción Actualizar
            CC_CaseStatusKnowledgeController.changeStatusKnowledgeCase(caso.Id, 'Cerrado', 'Actualizar');
            Test.stopTest();

            // Verificar que el caso se actualizó
            Case casoActualizado = [SELECT Id, Status, CC_Detalles_Consulta__c, CC_Detalles_Solucion__c 
                                   FROM Case WHERE Id = :caso.Id];
            String detallesConsulta =  casoActualizado.CC_Detalles_Consulta__c;
            String detallesSolucion =  casoActualizado.CC_Detalles_Solucion__c;
            System.assertEquals('Cerrado', casoActualizado.Status, 'El estado debería haberse actualizado a Cerrado');
            System.assertEquals(true, detallesConsulta.contains('Actualizar'), 'Debería tener los detalles de consulta correctos');
            System.assertEquals(true, detallesSolucion.contains('Actualizar'), 'Debería tener los detalles de solución correctos');

            //Chequear articulo
            Knowledge__kav articuloActualizado = [SELECT Id, PublishStatus, CC_Fecha_Caducidad__c FROM Knowledge__kav WHERE KnowledgeArticleId = :knowledgeArticleId LIMIT 1];
            System.assertEquals(true, articuloActualizado.CC_Fecha_Caducidad__c.year() == 2026, 'La fecha de caducidad debería ser el año siguiente');
            System.assertEquals('Online', articuloActualizado.PublishStatus, 'El artículo debería estar en estado Online');
        }
    }
    
    @isTest
    static void testChangeStatusWithArticleActualizarError() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        Boolean error = false;
        
        System.runAs(operador) {
            CBK_UtilsDate.nowDatetime = DateTime.newInstance(2024, 1, 1, 0, 0, 0);
            // Crear artículo de Knowledge con fecha de caducidad en el año actual (no válido)
            Knowledge__kav articulo = new Knowledge__kav(
                Title = 'Artículo de Prueba',
                UrlName = 'articulo-prueba-actualizar-error',
                Language = 'es',
                CC_Fecha_Caducidad__c = CBK_UtilsDate.nowDT().addMonths(6)
            );
            insert articulo;

            Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :articulo.Id LIMIT 1].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
            
            // Crear extensión de caso
            CBK_Case_Extension__c extension = new CBK_Case_Extension__c(
                CC_Articulo_Relacionado__c = articulo.Id
            );
            insert extension;
            
            // Crear caso con artículo relacionado
            Case caso = new Case(
                Subject = 'Caso con Artículo',
                Status = 'Activo',
                CBK_Case_Extension_Id__c = extension.Id,
                RecordTypeId = CC_KnowledgeCaseHandler.CASE_KNOWDLEGE_RT
            );
            insert caso;
            
            Test.startTest();
            // Intentar cambiar estado con acción Actualizar - debería fallar
            try {
                CC_CaseStatusKnowledgeController.changeStatusKnowledgeCase(caso.Id, 'Cerrado', 'Actualizar');
            } catch (AuraHandledException e) {
                error = true;
            }
            Test.stopTest();
            
            // Verificar que el caso NO se actualizó
            Case casoActualizado = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];
            System.assertEquals('Activo', casoActualizado.Status, 'El estado no debería haberse actualizado');
            System.assertEquals(true, error, 'Debería haber lanzado una excepción');
        }
    }
    
    @isTest
    static void testChangeStatusPendienteColaborador() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        System.runAs(operador) {
            // Crear caso
            Knowledge__kav articulo = new Knowledge__kav(
                Title = 'Artículo de Prueba',
                UrlName = 'articulo-prueba-actualizar-error',
                Language = 'es',
                CC_Fecha_Caducidad__c = CBK_UtilsDate.todayDT().addMonths(30)
            );
            insert articulo;

            Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :articulo.Id LIMIT 1].KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
            
            // Crear extensión de caso
            CBK_Case_Extension__c extension = new CBK_Case_Extension__c(
                CC_Articulo_Relacionado__c = articulo.Id
            );
            insert extension;
            
            // Crear caso con artículo relacionado
            Case caso = new Case(
                Subject = 'Caso con Artículo',
                Status = 'Activo',
                CBK_Case_Extension_Id__c = extension.Id,
                RecordTypeId = CC_KnowledgeCaseHandler.CASE_KNOWDLEGE_RT
            );
            insert caso;
            
            Test.startTest();
            // Cambiar a un estado que no sea Cerrado
            CC_CaseStatusKnowledgeController.changeStatusKnowledgeCase(caso.Id, 'Pendiente Colaborador', '');
            Test.stopTest();
            
            // Verificar que el caso se actualizó
            Case casoActualizado = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];
            System.assertEquals('Pendiente Colaborador', casoActualizado.Status, 'El estado debería haberse actualizado a Pendiente Colaborador');
            
            // Verificar que se creó la tarea
            List<Task> tareas = [SELECT Id, Subject, Type, Status, WhatId 
                                FROM Task WHERE WhatId = :caso.Id AND Type = :CC_KnowledgeCaseHandler.TASK_TYPE_CAMBIO_ESTADO_CASO_KNOWLEDGE];
            System.assertEquals(false, tareas.isEmpty(), 'Debería haberse creado una tarea');
        }
    }
    
    @isTest
    static void testGetConfiguraciones() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        System.runAs(operador) {
            Test.startTest();
            Map<String, Object> configuraciones = CC_CaseStatusKnowledgeController.getConfiguraciones();
            Test.stopTest();
            
            System.assertNotEquals(null, configuraciones, 'Las configuraciones no deberían ser null');
            System.assertEquals('Archivar artículo', configuraciones.get('avisoArchivar'), 'Debería tener el aviso de archivar correcto');
            System.assertEquals('Renovar artículo', configuraciones.get('avisoRenovar'), 'Debería tener el aviso de renovar correcto');
            System.assertEquals('Actualizar artículo', configuraciones.get('avisoActualizar'), 'Debería tener el aviso de actualizar correcto');
        }
    }
    
    @isTest
    static void testGetConfiguracionesError() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        Boolean error = false;
        System.runAs(operador) {
            // Eliminar la configuración para probar el error
            delete [SELECT Id FROM CC_Settings__c WHERE Name = 'CC_Knowledge_Settings'];
            
            Test.startTest();
            try {
                CC_CaseStatusKnowledgeController.getConfiguraciones();
            } catch (AuraHandledException e) {
                error = true;
            }
            Test.stopTest();
        }
        System.assertEquals(true, error, 'Debería haber lanzado una excepción');
    }
    
    @isTest
    static void testChangeStatusWithoutArticleExtension() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        Boolean error = false;
        
        System.runAs(operador) {
            // Crear caso sin extensión de caso
            Case caso = new Case(
                Subject = 'Caso sin Extensión',
                Status = 'Activo',
                RecordTypeId = CC_KnowledgeCaseHandler.CASE_KNOWDLEGE_RT
            );
            insert caso;
            
            Test.startTest();
            try {
                CC_CaseStatusKnowledgeController.changeStatusKnowledgeCase(caso.Id, 'Cerrado', 'Archivar');
            } catch (AuraHandledException e) {
                error = true;
            }
            Test.stopTest();
            
            // Verificar que el caso NO se actualizó
            Case casoActualizado = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];
            System.assertEquals('Activo', casoActualizado.Status, 'El estado no debería haberse actualizado');
            System.assertEquals(true, error, 'Debería haber lanzado una excepción');
        }
    }
    
    @isTest
    static void testChangeStatusWithArticleExtensionNoArticle() {
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        Boolean error = false;
        System.runAs(operador) {
            // Crear extensión de caso sin artículo relacionado
            CBK_Case_Extension__c extension = new CBK_Case_Extension__c();
            insert extension;
            
            // Crear caso con extensión pero sin artículo
            Case caso = new Case(
                Subject = 'Caso con Extensión sin Artículo',
                Status = 'Activo',
                CBK_Case_Extension_Id__c = extension.Id,
                RecordTypeId = CC_KnowledgeCaseHandler.CASE_KNOWDLEGE_RT
            );
            insert caso;
            
            Test.startTest();
            try {
                CC_CaseStatusKnowledgeController.changeStatusKnowledgeCase(caso.Id, 'Cerrado', 'Archivar');
            } catch (AuraHandledException e) {
                error = true;
            }
            Test.stopTest();
            
            // Verificar que el caso NO se actualizó
            Case casoActualizado = [SELECT Id, Status FROM Case WHERE Id = :caso.Id];
            System.assertEquals('Activo', casoActualizado.Status, 'El estado no debería haberse actualizado');
            System.assertEquals(true, error, 'Debería haber lanzado una excepción');
        }
    }
}