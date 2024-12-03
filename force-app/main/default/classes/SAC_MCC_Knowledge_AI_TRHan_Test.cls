@isTest
public with sharing class SAC_MCC_Knowledge_AI_TRHan_Test {
    @TestSetup
    static void makeData(){

        User usuarioAdmin;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC Admin
            usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
            usuarioAdmin.UserPermissionsKnowledgeUser = true;     
            Database.insert(usuarioAdmin);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioAdmin.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        //cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        Database.insert(cuenta);
        	
        Contact contacto = SAC_TestDataFactory.crearContacto(1, cuenta.Id)[0];
        contacto.Email = 'mp@test.com';
        //contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
		Database.insert(contacto);
        
        Datetime fecha = Datetime.now();
        Datetime fechaInicio = fecha.addHours(2);
        Datetime fechaCaducidad = fecha.addHours(10);

        Knowledge__kav articulo = new Knowledge__kav(); 
        articulo.URLName = 'Apex-Test' + System.now().getTime();
        articulo.Title = 'Articulo test';
        articulo.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
        articulo.CC_Fecha_Caducidad__c = fechaCaducidad;
        //articulo.CC_Responsable_Externo__c = contacto.Id;
        Database.insert(articulo); 

        CC_MCC__c mccTematica = new CC_MCC__c();
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.Name = 'Tematica Test AI';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Codigo_Externo__c = 'TE-000789';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = fecha;
        mccTematica.CC_Canal_Operativo__c = 'RRSS';
        Database.insert(mccTematica);
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.Name = 'Producto Test AI';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Codigo_Externo__c = 'PR-000789';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = fecha;
        Database.insert(mccProducto);

        CC_MCC__c mccMotivo = new CC_MCC__c();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.Name = 'Motivo Test AI';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Codigo_Externo__c = 'MO-000789';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = fecha;
        Database.insert(mccMotivo);

        CC_MCC__c mccDetalle = new CC_MCC__c();
        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        mccDetalle.RecordTypeId = recordTypeIdDetalle;
        mccDetalle.Name = 'Detalle Test AI';
        mccDetalle.CC_Codigo_Externo__c = 'CA-000789';
        mccDetalle.CC_Fecha_Vigencia_Inicio__c = fecha;
        Database.insert(mccDetalle);
    }

    @isTest
    public static void testAIDetalle(){
        Knowledge__kav articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c 
                    FROM Knowledge__kav WHERE Title = 'Articulo test'];

        Id idArticulo = articulo.Id;
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
                                            FROM KnowledgeArticleVersion WHERE Id =: idArticulo]);
        
        CC_MCC__c mccDetalle = [SELECT Id FROM CC_MCC__c WHERE Name = 'Detalle Test AI'];
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        System.runAs(usuario){
            Test.startTest();
            CBK_MCC_Knowledge__c relacionDetalle = new CBK_MCC_Knowledge__c();
            SAC_MCC_Knowledge_AI_TRHan.publishArticle((String)obtenidoIdQuery.get(idArticulo).KnowledgeArticleId);
            relacionDetalle.CBK_MCC__c = mccDetalle.Id;
            relacionDetalle.CBK_Knowledge__c = articulo.Id;
            relacionDetalle.RecordTypeId = Schema.SObjectType.CBK_MCC_Knowledge__c.getRecordTypeInfosByDeveloperName().get('SAC_Protocolo').getRecordTypeId();
            Database.insert(relacionDetalle);
            Test.stopTest();
        }

        articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c, PublishStatus 
                    FROM Knowledge__kav WHERE Title = 'Articulo test'];

        //Comprobaciones para saber si se ha creado bien
        System.assertEquals('CA-000789 -', articulo.CBK_Codigo_Externo_Causa__c, 'El código externo de causa (detalle) no se ha guardado correctamente');
        System.assertEquals('Online', articulo.PublishStatus, 'El artículo no se publica');
    }

   /* @isTest
    public static void testAIMotivo(){
        Knowledge__kav articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c 
                    FROM Knowledge__kav WHERE Title = 'Articulo test'];

        Id idArticulo = articulo.Id;
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
                                            FROM KnowledgeArticleVersion WHERE Id =: idArticulo]);
        
        CC_MCC__c mccMotivo = [SELECT Id FROM CC_MCC__c WHERE Name = 'Motivo Test AI'];

        Test.startTest();
        CBK_MCC_Knowledge__c relacionMotivo = new CBK_MCC_Knowledge__c();
        SAC_MCC_Knowledge_AI_TRHan.publishArticle((String)obtenidoIdQuery.get(idArticulo).KnowledgeArticleId);
        relacionMotivo.CBK_MCC__c = mccMotivo.Id;
        relacionMotivo.CBK_Knowledge__c = articulo.Id;
        insert relacionMotivo;
        Test.stopTest();

        articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c, PublishStatus 
                    FROM Knowledge__kav WHERE Title = 'Articulo test'];

        //Comprobaciones para saber si se ha creado bien
        System.assertEquals('MO-000789 -', articulo.CBK_Codigo_Externo_Motivo__c, 'El código externo de motivo no se ha guardado correctamente');
        System.assertEquals('Online', articulo.PublishStatus, 'El artículo no se publica');
    }

    @isTest
    public static void testAIProducto(){
        Knowledge__kav articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c 
                    FROM Knowledge__kav WHERE Title = 'Articulo test'];

        Id idArticulo = articulo.Id;
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
                                            FROM KnowledgeArticleVersion WHERE Id =: idArticulo]);
        
        CC_MCC__c mccProducto = [SELECT Id FROM CC_MCC__c WHERE Name = 'Producto Test AI'];

        Test.startTest();
        CBK_MCC_Knowledge__c relacionProducto = new CBK_MCC_Knowledge__c();
        SAC_MCC_Knowledge_AI_TRHan.publishArticle((String)obtenidoIdQuery.get(idArticulo).KnowledgeArticleId);
        relacionProducto.CBK_MCC__c = mccProducto.Id;
        relacionProducto.CBK_Knowledge__c = articulo.Id;
        insert relacionProducto;
        Test.stopTest();

        articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c, PublishStatus 
                    FROM Knowledge__kav WHERE Title = 'Articulo test'];

        //Comprobaciones para saber si se ha creado bien
        System.assertEquals('PR-000789 -', articulo.CBK_Codigo_Externo_Producto__c, 'El código externo de producto no se ha guardado correctamente');
        System.assertEquals('Online', articulo.PublishStatus, 'El artículo no se publica');
    }

    @isTest
    public static void testAITematica(){
        Knowledge__kav articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c 
                    FROM Knowledge__kav WHERE Title = 'Articulo test'];

        Id idArticulo = articulo.Id;
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
                                            FROM KnowledgeArticleVersion WHERE Id =: idArticulo]);
        
        CC_MCC__c mccTematica = [SELECT Id FROM CC_MCC__c WHERE Name = 'Tematica Test AI'];

        Test.startTest();
        CBK_MCC_Knowledge__c relacionTematica = new CBK_MCC_Knowledge__c();
        SAC_MCC_Knowledge_AI_TRHan.publishArticle((String)obtenidoIdQuery.get(idArticulo).KnowledgeArticleId);
        relacionTematica.CBK_MCC__c = mccTematica.Id;
        relacionTematica.CBK_Knowledge__c = articulo.Id;
        insert relacionTematica;
        Test.stopTest();

        articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c, PublishStatus 
                    FROM Knowledge__kav WHERE Title = 'Articulo test'];

        //Comprobaciones para saber si se ha creado bien
        System.assertEquals('TE-000789 -', articulo.CBK_Codigo_Externo_Tematica__c, 'El código externo de temática no se ha guardado correctamente');
        System.assertEquals('Online', articulo.PublishStatus, 'El artículo no se publica');
    }*/

    @isTest
    public static void testAIDetalleUsado(){
        Contact contacto = [SELECT Id FROM Contact WHERE FirstName = 'Test0' LIMIT 1];

        Datetime fecha = Datetime.now();
        Datetime fechaInicio = fecha.addHours(2);
        Datetime fechaCaducidad = fecha.addHours(10);

        Knowledge__kav articulo = new Knowledge__kav(); 
        articulo.URLName = 'Apex-Test' + System.now().getTime();
        articulo.Title = 'ArticuloUsado test';
        articulo.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
        articulo.CC_Fecha_Caducidad__c = fechaCaducidad;
        //articulo.CC_Responsable_Externo__c = contacto.Id;
        articulo.CBK_Codigo_Externo_Causa__c = 'DA256 -';
        Database.insert(articulo); 
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
                                            FROM KnowledgeArticleVersion WHERE Id =: articulo.Id]);
        
        CC_MCC__c mccDetalle = [SELECT Id FROM CC_MCC__c WHERE Name = 'Detalle Test AI'];
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        System.runAs(usuario){
            Test.startTest();
            CBK_MCC_Knowledge__c relacionDetalle = new CBK_MCC_Knowledge__c();
            SAC_MCC_Knowledge_AI_TRHan.publishArticle((String)obtenidoIdQuery.get(articulo.Id).KnowledgeArticleId);
            relacionDetalle.CBK_MCC__c = mccDetalle.Id;
            relacionDetalle.CBK_Knowledge__c = articulo.Id;
            relacionDetalle.RecordTypeId = Schema.SObjectType.CBK_MCC_Knowledge__c.getRecordTypeInfosByDeveloperName().get('SAC_Protocolo').getRecordTypeId();
            Database.insert(relacionDetalle);
            Test.stopTest();
        }

        articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c, PublishStatus 
                    FROM Knowledge__kav WHERE Title = 'ArticuloUsado test'];

        //Comprobaciones para saber si se ha creado bien
        System.assertEquals('DA256 -CA-000789 -', articulo.CBK_Codigo_Externo_Causa__c, 'El código externo de causa (detalle) no se ha guardado correctamente');
        System.assertEquals('Online', articulo.PublishStatus, 'El artículo no se publica');
    }
}