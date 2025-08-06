/*****************************************************************
 * Name: SAC_Genial_WS
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            genIAl           Alexandre Pérez   23/11/23     Creación
*****************************************************************/
@istest
public with sharing class SAC_Genial_WS_Test {
   
    @TestSetup
    static void makeData(){
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('SAC_GenialEstado__c', 'SAC_001');
 
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);  
        
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        Database.insert(usuarioGeneral);
 
        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSet permiSet = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      
        Database.insert(usuarioAdmin);
        system.runAs(usuarioAdmin){
            Database.insert(permiSetAssi);
        }

        system.runAs(usuarioGeneral){
            Database.insert(reclamacion);
        }
    }

    @isTest
    static void conexionTest(){
        case reclamacion = [SELECT ID FROM CASE LIMIT 1];
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf('{"reclamacion":{"Id":"'+reclamacion.id+'"}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161","direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410, Sueca, Valencia, España"}}');
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }   
        test.stopTest();
        system.assertEquals(200, RestContext.response.StatusCode);
    }
    @isTest
    static void badRequestTest(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf('{"reclamacion":{"Id":null}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161","direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410, Sueca, Valencia, España"}}');
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }
        test.stopTest();
        system.assertEquals(400, RestContext.response.StatusCode);
    }
    
    @isTest
    static void errorIdTest(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf('{"reclamacion":{"Id":""}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161","direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410, Sueca, Valencia, España"}}');
        RestContext.request = request;
        RestContext.response = response;     
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }
        test.stopTest();
        system.assertEquals(404, RestContext.response.StatusCode);
    }

    @isTest
    static void errorJSONTest(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf('{"reclamacion":"Id":""}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161","direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410, Sueca, Valencia, España"}}');
        RestContext.request = request;
        RestContext.response = response;     
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }
        test.stopTest();
        system.assertEquals(400, RestContext.response.StatusCode);
    }

    @isTest
    static void errorEstadoTest(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('SAC_GenialEstado__c', 'SAC_003');

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);  
        system.runAs(sacUser){
            Database.insert(reclamacion);
        }

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf('{"reclamacion":{"Id":"'+reclamacion.id+'"}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161","direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410, Sueca, Valencia, España"}}');
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }   
        test.stopTest();
        system.assertEquals(403, RestContext.response.StatusCode);
    }

    @isTest
    static void errorRechazadoTest(){
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        //amposRecl.put('SAC_GenialEstado__c', 'SAC_003');
        camposRecl.put('Status', 'Rechazado');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Rechazado');

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);  
        system.runAs(sacUser){
            Database.insert(reclamacion);
        }

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf('{"reclamacion":{"Id":"'+reclamacion.id+'"}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161","direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410, Sueca, Valencia, España"}}');
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }   
        test.stopTest();
        system.assertEquals(409, RestContext.response.StatusCode);
    }

    @isTest
    static void errorOficinaTest(){
        case reclamacion = [SELECT ID FROM CASE LIMIT 1];
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf('{"reclamacion":{"Id":"'+reclamacion.id+'", "CC_Oficina_Afectada_Lookup__c":"errorAerrorAerrorA"}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161","direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410, Sueca, Valencia, España"}}');
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }   
        test.stopTest();
        system.assertEquals(404, RestContext.response.StatusCode);
    }
}