/*****************************************************************
* Name: SAC_GenialOSEnvioDocIntegracion_test
* Copyright © 2024  CaixaBank
* 
* @description : clase test de SAC_GenialOSEnvioDocIntegracion_test
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US977960         Alexandre Perez        31/07/24     Creación     
*****************************************************************/
@istest
public with sharing class SAC_GenialOSEnviaDocIntegracion_Test {

    @TestSetup
    static void makeData(){
        CBK_IntegrationSetting__c openServicesConf = new CBK_IntegrationSetting__c();
        openServicesConf.Name = 'SAC_GenialOSEnviarDoc';
        openServicesConf.NamedCredential__c = 'callout:API_GWT_SAC/testmock';
        //csGenialAzureAI.CBK_Method__c = 'POST';
        openServicesConf.CBK_TimeOut__c = 120000;
        Database.insert(openServicesConf);
        //csGenialAzureAI.CBK_ContentType__c = 'application/json';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test data')
        );
        //insert contentVersion;

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
        }
        
    }

    @isTest
    static void testCalloutSuccess() {
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
       SAC_GenialOSEnvioDocIntegracion.ResponseOK mockResponse = new SAC_GenialOSEnvioDocIntegracion.ResponseOK();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document';
        
        String mockResponseBody = JSON.serialize(new List<SAC_GenialOSEnvioDocIntegracion.ResponseOK>{ mockResponse });

        // Simula la respuesta del callout HTTP
        Test.startTest();
        
        
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', mockResponseBody, new Map<String, String>()));
        SAC_GenialOSEnvioDocIntegracion.ResponseOK response;
        system.runAs(sacUser) {
            response = SAC_GenialOSEnvioDocIntegracion.callout(doculink);
        }
        
        
        Test.stopTest();
        
        // Asserts
        System.assertNotEquals(null, response, 'La respuesta no debería ser nula');
        System.assertEquals('001', response.documentId, 'El ID del documento debería ser 001');
        System.assertEquals('application/pdf', response.mimeTypeDesc, 'El tipo mime debería ser application/pdf');
        System.assertEquals('Test Document', response.name, 'El nombre del documento debería ser Test Document');
    }

    @isTest
    static void testCalloutError() {
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
        SAC_GenialOSEnvioDocIntegracion.ResponseOK response;
        system.runAs(sacUser) {
            response = SAC_GenialOSEnvioDocIntegracion.callout(doculink);
        }
        
        Test.stopTest();
        
        // Asserts
        System.assertEquals(null, response, 'La respuesta debería ser nula en caso de error');
    }
}