/*****************************************************************
* Name: SAC_GenialOpenServicesQueueable_Test
* Copyright © 2024  CaixaBank
* 
* @description : clase test de SAC_GenialOpenServicesQueueable
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US977960         Alexandre Pérez        02/07/24     Creación     
* 1.1            US1027990        Alexandre Pérez        30/09/24     Adaptación nueva estructura de respuesta
*****************************************************************/
@istest
public with sharing class SAC_GenialOpenServicesQueueable_Test {
    @TestSetup
    static void makeData(){
        
        //csGenialAzureAI.CBK_ContentType__c = 'application/json';
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test data')
        );
        //insert contentVersion;
        
            //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        camposRecl.put('Subject', 'Subject de prueba2');
        camposRecl.put('Description', 'Descripcion de prueba2');

        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        list<case> listreclama = new list<case>{reclamacion, reclamacion2};

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
            Database.insert(listreclama);
            insert contentVersion;
            ContentDocumentLink doculink = new ContentDocumentLink(
                ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
                LinkedEntityId = listreclama.get(0).Id
            );
            Database.insert(doculink);
        }


    }

    @isTest
    static void testPrimeraLlamadaKO() {
        //forzamos error evitando cargar la configuración de la integración para que salga por el try catch
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
        case reclamacion = [SELECT Id FROM Case WHERE Subject = 'Subject de prueba'];
       //contentDocumentLink doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE LinkedEntityId = : reclamacion.Id];
       /*SAC_GenialOpenServicesIntegracion.ResponseOK mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOK();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document'; */

        SAC_GenialOpenServicesIntegracion.DocumentsInfo documentsInfo = new SAC_GenialOpenServicesIntegracion.DocumentsInfo();
        documentsInfo.documentId = '001';
        documentsInfo.mimeTypeDesc = 'application/pdf';
        documentsInfo.name = 'Test Document';
        SAC_GenialOpenServicesIntegracion.ResponseOk mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOk();
        mockResponse.documentsInfo = new list<SAC_GenialOpenServicesIntegracion.DocumentsInfo>{documentsInfo};
        
        String mockResponseBody = JSON.serialize(mockResponse);

        // Simula la respuesta del callout HTTP
        Test.startTest();

        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(reclamacion.Id)
                                        .addString('TESTOS')
                                        .build();
        
        
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', mockResponseBody, new Map<String, String>()));
        //SAC_GenialOSEnvioDocIntegracion.ResponseOK response;
        system.runAs(sacUser) {
            System.enqueueJob(new SAC_GenialOpenServices_Queueable(new list<id>{reclamacion.Id}), options);
        }
        
        
        Test.stopTest();
        
        case recResultado = [SELECT Id, SAC_GenialEstado__c, SAC_Tipo_integracion_IA__c FROM Case WHERE Subject = 'Subject de prueba'];

        system.assertEquals('SAC_004', recResultado.SAC_GenialEstado__c, 'El campo estado de GenIAl debería haber cambiado a "Error Envío"');
        system.assertEquals('OpenServices', recResultado.SAC_Tipo_integracion_IA__c, 'El campo que muestra la integración elegida ' +
                                'debería haber cambiado a "OpenServices"');
        // Asserts
        /*System.assertNotEquals(null, response, 'La respuesta no debería ser nula');
        System.assertEquals('001', response.documentId, 'El ID del documento debería ser 001');
        System.assertEquals('application/pdf', response.mimeTypeDesc, 'El tipo mime debería ser application/pdf');
        System.assertEquals('Test Document', response.name, 'El nombre del documento debería ser Test Document');*/
    }

    @isTest
    static void testPrimeraLlamadaOK() {
        // Configura datos de prueba
        /*ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test data')
        );
        insert contentVersion;*/
        CBK_IntegrationSetting__c openServicesConf = new CBK_IntegrationSetting__c();
        openServicesConf.Name = 'SAC_GenialOSEnviarDoc';
        openServicesConf.NamedCredential__c = 'callout:API_GWT_SAC/testmock';
        openServicesConf.CBK_Method__c = 'POST';
        openServicesConf.CBK_TimeOut__c = 120000;
        openServicesConf.CBK_ContentType__c = 'application/json';
        Database.insert(openServicesConf);
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        /*ContentDocumentLink doculink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            LinkedEntityId = UserInf*o.getUserId()
        );
        insert doculink;*/
       //Id ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
       //contentDocumentLink doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE contentDocumentId = : ContentDocumentId];
       case reclamacion = [SELECT Id FROM Case WHERE Subject = 'Subject de prueba'];
       list<contentDocumentLink> doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE LinkedEntityId = : reclamacion.Id];
      /*  SAC_GenialOpenServicesIntegracion.ResponseOK mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOK();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document'; */

        SAC_GenialOpenServicesIntegracion.DocumentsInfo documentsInfo = new SAC_GenialOpenServicesIntegracion.DocumentsInfo();
       documentsInfo.documentId = '001';
       documentsInfo.mimeTypeDesc = 'application/pdf';
       documentsInfo.name = 'Test Document';
       SAC_GenialOpenServicesIntegracion.ResponseOk mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOk();
       mockResponse.documentsInfo = new list<SAC_GenialOpenServicesIntegracion.DocumentsInfo>{documentsInfo};
        
        String mockResponseBody = JSON.serialize( mockResponse );

        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(reclamacion.Id)
                                        .addString('TESTOS')
                                        .build();

        // Simula la respuesta del callout HTTP
        Test.startTest();
        
        
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', mockResponseBody, new Map<String, String>()));
        //SAC_GenialOSEnvioDocIntegracion.ResponseOK response;
        system.runAs(sacUser) {
            System.enqueueJob(new SAC_GenialOpenServices_Queueable(doculink, 
            mockResponse.documentsInfo, new list<id>{reclamacion.Id}), options);
        }    
        Test.stopTest();

        system.assert(![select iD from AsyncApexJob].isEmpty(), 'No hay job asíncrono');
        /*case recResultado = [SELECT Id, SAC_GenialEstado__c, SAC_Tipo_integracion_IA__c FROM Case WHERE Subject = 'Subject de prueba'];

        system.assertEquals('SAC_003', recResultado.SAC_GenialEstado__c, 'El campo estado de GenIAl debería haber cambiado a "Error Envío"');
        system.assertEquals('OpenServices', recResultado.SAC_Tipo_integracion_IA__c, 'El campo que muestra la integración elegida ' +
                                'debería haber cambiado a "OpenServices"');*/
        
        // Asserts
        /*System.assertNotEquals(null, response, 'La respuesta no debería ser nula');
        System.assertEquals('001', response.documentId, 'El ID del documento debería ser 001');
        System.assertEquals('application/pdf', response.mimeTypeDesc, 'El tipo mime debería ser application/pdf');
        System.assertEquals('Test Document', response.name, 'El nombre del documento debería ser Test Document');*/
    }
    @isTest
    static void testMultiLlamadaOK() {
        // Configura datos de prueba
        /*ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test data')
        );
        insert contentVersion;*/
        CBK_IntegrationSetting__c openServicesConf = new CBK_IntegrationSetting__c();
        openServicesConf.Name = 'SAC_GenialOSEnviarDoc';
        openServicesConf.NamedCredential__c = 'callout:API_GWT_SAC/testmock';
        openServicesConf.CBK_Method__c = 'POST';
        openServicesConf.CBK_TimeOut__c = 120000;
        openServicesConf.CBK_ContentType__c = 'application/json';
        Database.insert(openServicesConf);
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        /*ContentDocumentLink doculink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            LinkedEntityId = UserInf*o.getUserId()
        );
        insert doculink;*/
       //Id ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
       //contentDocumentLink doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE contentDocumentId = : ContentDocumentId];
       case reclamacion = [SELECT Id, Subject, Description  FROM Case WHERE Subject = 'Subject de prueba'];
       //list<contentDocumentLink> doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE LinkedEntityId = : reclamacion.Id];
       SAC_GenialOpenServicesIntegracion.DocumentsInfo documentsInfo = new SAC_GenialOpenServicesIntegracion.DocumentsInfo();
       documentsInfo.documentId = '001';
       documentsInfo.mimeTypeDesc = 'application/pdf';
       documentsInfo.name = 'Test Document';
       SAC_GenialOpenServicesIntegracion.ResponseOk mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOk();
       mockResponse.documentsInfo = new list<SAC_GenialOpenServicesIntegracion.DocumentsInfo>{documentsInfo};
       
        
        String mockResponseBody = JSON.serialize(mockResponse);

        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(reclamacion.Id)
                                        .addString('TESTOS')
                                        .build();

        // Simula la respuesta del callout HTTP
        Test.startTest();
        
        
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(200, 'OK', mockResponseBody, new Map<String, String>()));
        //SAC_GenialOSEnvioDocIntegracion.ResponseOK response;
        system.runAs(sacUser) {
            System.enqueueJob(new SAC_GenialOpenServices_Queueable(new list<id>{reclamacion.Id}), options);
        }    
        Test.stopTest();

        system.assert(![select iD from AsyncApexJob].isEmpty(), 'No hay job asíncrono');
        /*case recResultado = [SELECT Id, SAC_GenialEstado__c, SAC_Tipo_integracion_IA__c FROM Case WHERE Subject = 'Subject de prueba'];

        system.assertEquals('SAC_003', recResultado.SAC_GenialEstado__c, 'El campo estado de GenIAl debería haber cambiado a "Error Envío"');
        system.assertEquals('OpenServices', recResultado.SAC_Tipo_integracion_IA__c, 'El campo que muestra la integración elegida ' +
                                'debería haber cambiado a "OpenServices"');*/
        
        // Asserts
        /*System.assertNotEquals(null, response, 'La respuesta no debería ser nula');
        System.assertEquals('001', response.documentId, 'El ID del documento debería ser 001');
        System.assertEquals('application/pdf', response.mimeTypeDesc, 'El tipo mime debería ser application/pdf');
        System.assertEquals('Test Document', response.name, 'El nombre del documento debería ser Test Document');*/
    }

    @isTest
    static void testUltimaLlamadaOK() {
        // Configura datos de prueba
        /*ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test data')
        );
        insert contentVersion;*/
        CBK_IntegrationSetting__c openServicesConf = new CBK_IntegrationSetting__c();
        openServicesConf.Name = 'SAC_GenialOSEnviarRec';
        openServicesConf.NamedCredential__c = 'callout:API_GWT_SAC/testmock';
        openServicesConf.CBK_Method__c = 'POST';
        openServicesConf.CBK_TimeOut__c = 120000;
        openServicesConf.CBK_ContentType__c = 'application/json';
        Database.insert(openServicesConf);
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        /*ContentDocumentLink doculink = new ContentDocumentLink(
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId,
            LinkedEntityId = UserInf*o.getUserId()
        );
        insert doculink;*/
       //Id ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
       //contentDocumentLink doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE contentDocumentId = : ContentDocumentId];
       list<case> reclamacion = [SELECT Id FROM Case WHERE Subject = 'Subject de prueba' OR Subject = 'Subject de prueba2'];

       //list<contentDocumentLink> doculink = [SELECT Id, ContentDocumentId FROM contentDocumentLink WHERE LinkedEntityId = : reclamacion.Id];
        list<contentDocumentLink> doculink = new list<contentDocumentLink>();
       /*SAC_GenialOpenServicesIntegracion.ResponseOK mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOK();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document'; */
        SAC_GenialOpenServicesIntegracion.DocumentsInfo documentsInfo = new SAC_GenialOpenServicesIntegracion.DocumentsInfo();
        documentsInfo.documentId = '001';
        documentsInfo.mimeTypeDesc = 'application/pdf';
        documentsInfo.name = 'Test Document';
       /*  SAC_GenialOpenServicesIntegracion.ResponseOk mockResponse = new SAC_GenialOpenServicesIntegracion.ResponseOk();
        mockResponse.documentsInfo = new list<SAC_GenialOpenServicesIntegracion.DocumentsInfo>{documentsInfo}; */

        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(reclamacion.get(0).Id)
                                        .addString('TESTOS')
                                        .build();


        Test.startTest();
        
        
        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(204, 'OK', '', new Map<String, String>()));
        system.runAs(sacUser) {
            System.enqueueJob(new SAC_GenialOpenServices_Queueable(doculink, 
                                                                   new List<SAC_GenialOpenServicesIntegracion.DocumentsInfo>{ documentsInfo }, 
                                                                   new list<id>{reclamacion.get(0).id, reclamacion.get(1).id}), options);
        }    
        Test.stopTest();

        system.assert(![select iD from AsyncApexJob].isEmpty(), 'No hay job asíncrono');
        case recResultado = [SELECT Id, SAC_GenialEstado__c, SAC_Tipo_integracion_IA__c FROM Case WHERE Id = : reclamacion.get(0).id];

        system.assertEquals('SAC_001', recResultado.SAC_GenialEstado__c, 'El campo estado de GenIAl debería haber cambiado a "Error Envío"');
        system.assertEquals('OpenServices', recResultado.SAC_Tipo_integracion_IA__c, 'El campo que muestra la integración elegida ' +
                                'debería haber cambiado a "OpenServices"');
    }

    public static AsyncOptions options(id firmaId){
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                        .addId(firmaId)
                                        .addString('TESTOS')
                                        .build();
        return options;
    }
    

}