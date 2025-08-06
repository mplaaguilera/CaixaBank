/********************************************************************************************************
* Name: SAC_GenialOpenServicesIntegracion_Test
*
* @description : Clase test de SAC_GenialOpenServicesIntegracion
*
* Historial
*------------------------------------------------------------------
* VERSION        USER_STORY       AUTHOR            DATE         Description
* 1.0            US967489         Alex Pérez        05/08/24     Creación
* 1.1            US1027990        Alexandre Pérez   30/09/24     Adaptación nueva estructura de respuesta
********************************************************************************************************/
@istest
public with sharing class SAC_GenialOpenServicesIntegracion_Test {
    @TestSetup
    static void makeData(){
        CBK_IntegrationSetting__c openServicesConf = new CBK_IntegrationSetting__c();
        openServicesConf.Name = 'SAC_GenialOSEnviarDoc';
        openServicesConf.NamedCredential__c = 'callout:API_GWT_SAC/testmock';
        //csGenialAzureAI.CBK_Method__c = 'POST';
        openServicesConf.CBK_TimeOut__c = 120000;
        //Database.insert(openServicesConf);
        CBK_IntegrationSetting__c openServicesConf2 = new CBK_IntegrationSetting__c();
        openServicesConf2.Name = 'SAC_GenialOSEnviarRec';
        openServicesConf2.NamedCredential__c = 'callout:API_GWT_SAC/testmock';
        openServicesConf2.CBK_Method__c = 'POST';
        openServicesConf2.CBK_TimeOut__c = 120000;
        openServicesConf2.CBK_ContentType__c = 'application/json';
        Database.insert(new list<CBK_IntegrationSetting__c>{openServicesConf2, openServicesConf});
        //csGenialAzureAI.CBK_ContentType__c = 'application/json';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test data')
        );
        //insert contentVersion;

        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //usuario general de testing sac
        user usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSet permiSet = permiSets[0];
     
        //se necesita para evitar mixed operations al insertar los PS
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      
        Database.insert(usuarioAdmin);

        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        system.runAs(usuarioAdmin) {
            Database.insert(permiSetAssi);
        }
        system.runAs(usuarioGeneral) {
            insert contentVersion;
            insert reclamacion;
        }
        
    }

    @isTest
    static void testDocExito() {
        // Configura datos de prueba
        /*ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test data')
        );
        insert contentVersion;*/
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        /*ContentDocumentLink doculink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            LinkedEntityId = UserInf*o.getUserId()
        );
        insert doculink;*/
       //Id ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
       //contentDocumentLink doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE contentDocumentId = : ContentDocumentId];
       contentDocumentLink doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE LinkedEntityId = : sacUser.Id];
       /* SAC_GenialOpenServicesIntegracion.ResponseOK mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOK();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document';
         */
        SAC_GenialOpenServicesIntegracion.DocumentsInfo documentsInfo = new SAC_GenialOpenServicesIntegracion.DocumentsInfo();
        documentsInfo.documentId = '001';
        documentsInfo.mimeTypeDesc = 'application/pdf';
        documentsInfo.name = 'Test Document';
        SAC_GenialOpenServicesIntegracion.ResponseOk mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOk();
        mockResponse.documentsInfo = new list<SAC_GenialOpenServicesIntegracion.DocumentsInfo>{documentsInfo};

        String mockResponseBody = JSON.serialize(mockResponse);

        // Simula la respuesta del callout HTTP
        Test.startTest();
        
        
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', mockResponseBody, new Map<String, String>()));
        SAC_GenialOpenServicesIntegracion.DocumentsInfo response;
        system.runAs(sacUser) {
            response = SAC_GenialOpenServicesIntegracion.envioDocumento(doculink);
        }
        
        
        Test.stopTest();
        
        // Asserts
        System.assertNotEquals(null, response, 'La respuesta no debería ser nula');
        System.assertEquals('001', response.documentId, 'El ID del documento debería ser 001');
        System.assertEquals('application/pdf', response.mimeTypeDesc, 'El tipo mime debería ser application/pdf');
        System.assertEquals('Test Document', response.name, 'El nombre del documento debería ser Test Document');
    }

    @isTest
    static void testDocError() {
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        // Configura datos de prueba
        /*ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test data')
        );
        insert contentVersion;*/

        //Id ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
       //contentDocumentLink doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE contentDocumentId = : ContentDocumentId];

        // Simula la respuesta del callout HTTP con error
        contentDocumentLink doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE LinkedEntityId = : sacUser.Id];
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(500, 'OK', '', new Map<String, String>()));
        SAC_GenialOpenServicesIntegracion.DocumentsInfo response;
        system.runAs(sacUser) {
            response = SAC_GenialOpenServicesIntegracion.envioDocumento(doculink);
        }
        
        Test.stopTest();
        
        // Asserts
        System.assertEquals(null, response, 'La respuesta debería ser nula en caso de error');
    }

    @istest
    static void testRecOk(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        case reclamacion = [SELECT Id FROM Case WHERE Subject = 'Subject de prueba'];

        /* SAC_GenialOpenServicesIntegracion.ResponseOK mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOK();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document'; */

        SAC_GenialOpenServicesIntegracion.DocumentsInfo mockResponse = new SAC_GenialOpenServicesIntegracion.DocumentsInfo();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document';
        //SAC_GenialOpenServicesIntegracion.ResponseOk mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOk();
        //mockResponse.documentsInfo = new list<SAC_GenialOpenServicesIntegracion.DocumentsInfo>{documentsInfo};
        
        //String mockResponseBody = JSON.serialize(new List<SAC_GenialOpenServicesIntegracion.ResponseOK>{ mockResponse });
        
        test.startTest();
        system.runAS(sacUser) {
            Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(204, 'OK', '', new Map<String, String>()));
            SAC_GenialOpenServicesIntegracion.envioReclamacion(new list<SAC_GenialOpenServicesIntegracion.documentsInfo>{mockResponse}, reclamacion.Id);
        }
        test.stopTest();

        case recResultado = [SELECT Id, SAC_GenialEstado__c, SAC_Tipo_integracion_IA__c FROM Case WHERE Subject = 'Subject de prueba'];

        system.assertEquals('SAC_001', recResultado.SAC_GenialEstado__c, 'El campo estado de GenIAl debería haber cambiado a "Enviado"');
        system.assertEquals('OpenServices', recResultado.SAC_Tipo_integracion_IA__c, 'El campo que muestra la integración elegida ' +
                                'debería haber cambiado a "OpenServices"');
    }

    @istest
    static void testRecKO(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        case reclamacion = [SELECT Id FROM Case WHERE Subject = 'Subject de prueba'];

        SAC_GenialOpenServicesIntegracion.DocumentsInfo mockResponse = new SAC_GenialOpenServicesIntegracion.DocumentsInfo();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document';
        
        //String mockResponseBody = JSON.serialize(new List<SAC_GenialOpenServicesIntegracion.ResponseOK>{ mockResponse });
        
        test.startTest();
        system.runAS(sacUser) {
            Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(500, 'KO', '', new Map<String, String>()));
            SAC_GenialOpenServicesIntegracion.envioReclamacion(new list<SAC_GenialOpenServicesIntegracion.DocumentsInfo>{mockResponse}, reclamacion.Id);
        }
        test.stopTest();

        case recResultado = [SELECT Id, SAC_GenialEstado__c, SAC_Tipo_integracion_IA__c FROM Case WHERE Subject = 'Subject de prueba'];

        system.assertEquals('SAC_004', recResultado.SAC_GenialEstado__c, 'El campo estado de GenIAl debería haber cambiado a "Error Envío"');
        system.assertEquals('OpenServices', recResultado.SAC_Tipo_integracion_IA__c, 'El campo que muestra la integración elegida ' +
                                'debería haber cambiado a "OpenServices"');
    }

    @istest
    static void testBodyOk(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        case reclamacion = [SELECT Id, Subject, Description FROM Case WHERE Subject = 'Subject de prueba'];

        reclamacion.Subject = 'Subject test';
        reclamacion.Description = 'Description test';

       /*  SAC_GenialOpenServicesIntegracion.ResponseOK mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOK();
        mockResponse.documentId = '000';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Body'; */

        SAC_GenialOpenServicesIntegracion.DocumentsInfo documentsInfo = new SAC_GenialOpenServicesIntegracion.DocumentsInfo();
        documentsInfo.documentId = '001';
        documentsInfo.mimeTypeDesc = 'plain/text';
        documentsInfo.name = 'Test Body';
        SAC_GenialOpenServicesIntegracion.ResponseOk mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOk();
        mockResponse.documentsInfo = new list<SAC_GenialOpenServicesIntegracion.DocumentsInfo>{documentsInfo};
        
        String mockResponseBody = JSON.serialize(mockResponse);

        // Simula la respuesta del callout HTTP
        Test.startTest();
        
        
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', mockResponseBody, new Map<String, String>()));
        SAC_GenialOpenServicesIntegracion.documentsInfo response;
        system.runAs(sacUser) {
            response = SAC_GenialOpenServicesIntegracion.envioBody(reclamacion.id);
        }
        
        
        Test.stopTest();
        
        // Asserts
        System.assertNotEquals(null, response, 'La respuesta no debería ser nula');
        System.assertEquals('001', response.documentId, 'El ID del documento debería ser 001');
        System.assertEquals('plain/text', response.mimeTypeDesc, 'El tipo mime debería ser plain/text');
        System.assertEquals('Test Body', response.name, 'El nombre del documento debería ser Test Body');
    }

    @istest
    static void testBodyKO(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        case reclamacion = [SELECT Id, Subject, Description FROM Case WHERE Subject = 'Subject de prueba'];

        reclamacion.Subject = 'Subject test';
        reclamacion.Description = 'Description test';

        /* SAC_GenialOpenServicesIntegracion.ResponseOK mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOK();
        mockResponse.documentId = '000';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Body'; */
        
        //String mockResponseBody = JSON.serialize(new List<SAC_GenialOpenServicesIntegracion.ResponseOK>{ mockResponse });
        
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(500, 'KO', '', new Map<String, String>()));
        SAC_GenialOpenServicesIntegracion.DocumentsInfo response;
        system.runAs(sacUser) {
            response = SAC_GenialOpenServicesIntegracion.envioBody(reclamacion.id);
        }
        
        Test.stopTest();
        
        // Asserts
        System.assertEquals(null, response, 'La respuesta debería ser nula en caso de error');
    }
}