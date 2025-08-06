@isTest
public with sharing class SAC_MCC_Knowledge_AD_TRHan_Test {

    @TestSetup
    static void makeData(){

        User usuarioAdmin;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC Admin
            usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
            usuarioAdmin.UserPermissionsKnowledgeUser = true;
            SAC_DatabaseDML.insertDML(usuarioAdmin, false);         
            //Database.insert(usuarioAdmin);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioAdmin.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);    
            //Database.insert(permiSetAssi);
        }

        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        //cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        SAC_DatabaseDML.insertDML(cuenta, false); 
        //Database.insert(cuenta);
        	
        Contact contacto = SAC_TestDataFactory.crearContacto(1, cuenta.Id)[0];
        contacto.Email = 'mp@test.com';
        //contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        SAC_DatabaseDML.insertDML(contacto, false); 
		//Database.insert(contacto);
        
        Datetime fecha = Datetime.now();
        Datetime fechaInicio = fecha.addHours(2);
        Datetime fechaCaducidad = fecha.addHours(10);

        Knowledge__kav articulo = new Knowledge__kav(); 
        articulo.URLName = 'Apex-Test' + System.now().getTime();
        articulo.Title = 'Articulo test';
        articulo.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
        articulo.CC_Fecha_Caducidad__c = fechaCaducidad;
        //articulo.CC_Responsable_Externo__c = contacto.Id;
        articulo.ValidationStatus = 'Validado';
        SAC_DatabaseDML.insertDML(articulo, false); 
        //Database.insert(articulo); 

        CC_MCC__c mccDetalle = new CC_MCC__c();
        Id recordTypeIdDetalle = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        mccDetalle.RecordTypeId = recordTypeIdDetalle;
        mccDetalle.Name = 'Detalle Test AD';
        //mccDetalle.CC_Tipo_Cliente__c = 'Cliente';
        mccDetalle.CC_Codigo_Externo__c = 'TE-000789';
        mccDetalle.CC_Fecha_Vigencia_Inicio__c = fecha;
        SAC_DatabaseDML.insertDML(mccDetalle, false);
        //Database.insert(mccDetalle);

    }

    @isTest
    public static void testAD(){
        Id recTypeSACProtocolo = Schema.SObjectType.CBK_MCC_Knowledge__c.getRecordTypeInfosByDeveloperName().get('SAC_Protocolo').getRecordTypeId();
        Knowledge__kav articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c 
                                   FROM Knowledge__kav WHERE Title = 'Articulo test'];
        Id idArticulo = articulo.Id;
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
                                            FROM KnowledgeArticleVersion WHERE Id =: idArticulo]);

        List<CBK_MCC_Knowledge__c> relaciones = new List<CBK_MCC_Knowledge__c>();
        CC_MCC__c mccDetalle = [SELECT Id FROM CC_MCC__c WHERE Name = 'Detalle Test AD'];
        User usuario = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        System.runAs(usuario){
            Test.startTest();
            SAC_MCC_Knowledge_AI_TRHan.publishArticle((String)obtenidoIdQuery.get(idArticulo).KnowledgeArticleId);
            CBK_MCC_Knowledge__c relacionDetalle = new CBK_MCC_Knowledge__c();
            relacionDetalle.CBK_MCC__c = mccDetalle.Id;
            relacionDetalle.CBK_Knowledge__c = articulo.Id;
            relacionDetalle.RecordTypeId = recTypeSACProtocolo;
            SAC_DatabaseDML.insertDML(relacionDetalle, false);
            //Database.insert(relacionDetalle);
            SAC_DatabaseDML.deleteDML(relacionDetalle, false);
            //Database.delete(relacionDetalle);
            Test.stopTest();
        }

        articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c, PublishStatus 
                    FROM Knowledge__kav WHERE Title = 'Articulo test'];

        //Comprobaciones para saber si se ha creado bien
        System.assertEquals(null, articulo.CBK_Codigo_Externo_Tematica__c, 'No se ha borrado bien');
        //System.assertEquals('Online', articulo.PublishStatus, 'El artículo no queda publicado por lo que no se podrá borrar el objeto');  
    }
}