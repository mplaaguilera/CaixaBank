/*****************************************************************
* Name: SAC_GenialSendAzure_Test
* Copyright © 2023  CaixaBank
* 
* Proposito: Testear el componente SAC_GenialSendAzure
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US727970         David Ramos            15/11/23       Creación     
*****************************************************************/
@isTest
public with sharing class SAC_GenialSendAzure_Test {
    @TestSetup
    static void makeData(){
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSet permiSet = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        Database.insert(permiSetAssi);

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      
        Database.insert(usuarioAdmin);

        System.runAs(usuarioGeneral){
            //Reclamacion
            Map<String, Object> camposRecl = new Map<String, Object>();
            camposRecl.put('Subject', 'Subject de prueba');
            camposRecl.put('Description', 'Descripcion de prueba');

            Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
            Database.insert(reclamacion);
        }
    }
    @isTest
    public static void testSendDataOK() {
        // User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        User usuarioAdmin = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(201, 'OK', '', new Map<String, String>()));
        
        CBK_IntegrationSetting__c csGenialAzureAI = new CBK_IntegrationSetting__c();
        csGenialAzureAI.Name = 'SAC_GenialAzureAI';
        csGenialAzureAI.NamedCredential__c = 'callout:API_GWT_SAC/tech/geni06/notify-case';
        csGenialAzureAI.CBK_Method__c = 'POST';
        csGenialAzureAI.CBK_TimeOut__c = 120000;
        csGenialAzureAI.CBK_ContentType__c = 'application/json';
        
        Database.insert(csGenialAzureAI);

        Case reclamacion = [SELECT Id, Subject, Description FROM Case 
                            WHERE Subject = 'Subject de prueba' Limit 1];

        ContentVersion testAttachment = SAC_TestDataFactory.crearContentVersion(reclamacion);
        Database.insert(testAttachment);
        
        System.runAs(usuarioAdmin){
            Test.startTest();
            SAC_GenialSendAzure.sendToIA(reclamacion.Id, reclamacion.Description);
            Test.stopTest();
        }

        Case resultCase = [SELECT id, SAC_GenialEstado__c FROM Case WHERE Id = :reclamacion.id];
        
        System.assertEquals('SAC_001', resultCase.SAC_GenialEstado__c,'El caso no se ha modificado correctamente despues de enviarlo a IA');
    }

    @isTest
    public static void testSendDataError() {
        // User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];

        User usuarioAdmin = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' and IsActive = true limit 1];

        // Simular la respuesta del servicio HTTP utilizando un mockup de datos
        Test.setMock(HttpCalloutMock.class, new SAC_MockHttpResponseGenerator(400, 'KO', '', new Map<String, String>()));
        
        CBK_IntegrationSetting__c csGenialAzureAI = new CBK_IntegrationSetting__c();
        csGenialAzureAI.Name = 'SAC_GenialAzureAI';
        csGenialAzureAI.NamedCredential__c = 'callout:API_GWT_SAC/tech/geni06/notify-case';
        csGenialAzureAI.CBK_Method__c = 'POST';
        csGenialAzureAI.CBK_TimeOut__c = 120000;
        csGenialAzureAI.CBK_ContentType__c = 'application/json';
        
        Database.insert(csGenialAzureAI);

        Case reclamacion = [SELECT Id, Subject, Description FROM Case 
                            WHERE Subject = 'Subject de prueba' Limit 1];
        
        System.runAs(usuarioAdmin){
            Test.startTest();
            SAC_GenialSendAzure.sendToIA(reclamacion.Id, reclamacion.Description);
            Test.stopTest();
        }

        Case resultCase = [SELECT id, SAC_GenialEstado__c, OwnerId FROM Case WHERE Id = :reclamacion.id];
        
        system.debug('id cola: ' + resultCase.OwnerId);
        System.assertEquals('SAC_004', resultCase.SAC_GenialEstado__c,'El caso no se ha modificado correctamente despues de enviarlo a IA');
    }
}