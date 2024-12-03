/*****************************************************************
* Name: SAC_GenialOSEnvioRecIntegracion_Test
* Copyright © 2024  CaixaBank
* 
* @description : clase test de SAC_GenialOSEnvioRecIntegracion
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US977960         Alexandre Perez        01/07/24     Creación     
*****************************************************************/
@isTest
public with sharing class SAC_GenialOSEnvioRecIntegracion_Test {
    @TestSetup
    static void makeData(){
        CBK_IntegrationSetting__c openServicesConf = new CBK_IntegrationSetting__c();
        openServicesConf.Name = 'SAC_GenialOSEnviarRec';
        openServicesConf.NamedCredential__c = 'callout:API_GWT_SAC/testmock';
        openServicesConf.CBK_Method__c = 'POST';
        openServicesConf.CBK_TimeOut__c = 120000;
        openServicesConf.CBK_ContentType__c = 'application/json';
        Database.insert(openServicesConf);
        //csGenialAzureAI.CBK_ContentType__c = 'application/json';
        /*ContentVersion contentVersion = new ContentVersion(
            Title = 'Test Document',
            PathOnClient = 'TestDocument.txt',
            VersionData = Blob.valueOf('Test data')
        );*/
        //insert contentVersion;
        
            //Reclamacion
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
            Database.insert(reclamacion);
        }


    }

    @istest
    static void calloutOk(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        case reclamacion = [SELECT Id FROM Case WHERE Subject = 'Subject de prueba'];

        SAC_GenialOSEnvioDocIntegracion.ResponseOK mockResponse = new SAC_GenialOSEnvioDocIntegracion.ResponseOK();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document';
        
        //String mockResponseBody = JSON.serialize(new List<SAC_GenialOSEnvioDocIntegracion.ResponseOK>{ mockResponse });
        
        test.startTest();
        system.runAS(sacUser) {
            Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(204, 'OK', '', new Map<String, String>()));
            SAC_GenialOSEnvioRecIntegracion.callout(new list<SAC_GenialOSEnvioDocIntegracion.ResponseOK>{mockResponse}, reclamacion.Id);
        }
        test.stopTest();

        case recResultado = [SELECT Id, SAC_GenialEstado__c, SAC_Tipo_integracion_IA__c FROM Case WHERE Subject = 'Subject de prueba'];

        system.assertEquals('SAC_001', recResultado.SAC_GenialEstado__c, 'El campo estado de GenIAl debería haber cambiado a "Enviado"');
        system.assertEquals('OpenServices', recResultado.SAC_Tipo_integracion_IA__c, 'El campo que muestra la integración elegida ' +
                                'debería haber cambiado a "OpenServices"');
    }

    @istest
    static void calloutKO(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        case reclamacion = [SELECT Id FROM Case WHERE Subject = 'Subject de prueba'];

        SAC_GenialOSEnvioDocIntegracion.ResponseOK mockResponse = new SAC_GenialOSEnvioDocIntegracion.ResponseOK();
        mockResponse.documentId = '001';
        mockResponse.mimeTypeDesc = 'application/pdf';
        mockResponse.name = 'Test Document';
        
        //String mockResponseBody = JSON.serialize(new List<SAC_GenialOSEnvioDocIntegracion.ResponseOK>{ mockResponse });
        
        test.startTest();
        system.runAS(sacUser) {
            Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(500, 'KO', '', new Map<String, String>()));
            SAC_GenialOSEnvioRecIntegracion.callout(new list<SAC_GenialOSEnvioDocIntegracion.ResponseOK>{mockResponse}, reclamacion.Id);
        }
        test.stopTest();

        case recResultado = [SELECT Id, SAC_GenialEstado__c, SAC_Tipo_integracion_IA__c FROM Case WHERE Subject = 'Subject de prueba'];

        system.assertEquals('SAC_004', recResultado.SAC_GenialEstado__c, 'El campo estado de GenIAl debería haber cambiado a "Error Envío"');
        system.assertEquals('OpenServices', recResultado.SAC_Tipo_integracion_IA__c, 'El campo que muestra la integración elegida ' +
                                'debería haber cambiado a "OpenServices"');
    }
}