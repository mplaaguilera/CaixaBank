/*****************************************************************
 * Name: SAC_GenialQueueable_Test
 * Copyright © 2023  CaixaBank
 * 
 * Proposito: Clase test de SAC_GenialQueueable
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US749927         Alexandre Pérez   26/11/23     Creación
 * 1.1            US866221         David Ramos       03/04/24     Cambiar SAC_GenialSettings__c por el nuevo custom 
 *                                                                setting que separa configuraciones por canal 
 * 1.2            US-0009818       Iria AN-PC        20/02/25     Adaptar clase test a pretensionWrapper
*****************************************************************/
@isTest
public with sharing class SAC_GenialQueueable_Test {
   
    @TestSetup
    static void makeData(){
        list<user> userInsert = new list<user>();
        //Usuario SAC General
        User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];      
        //Database.insert(usuarioGeneral);
        userInsert.add(usuarioGeneral); 

        User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];      
        //Database.insert(usuarioAdmin);
        userInsert.add(usuarioAdmin);

        Database.insert(userInsert);

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSet permiSet = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;

        system.runAs(usuarioAdmin){
            Database.insert(permiSetAssi);     
        }

        SAC_GenialSettingsCanal__c settings = new SAC_GenialSettingsCanal__c();
        settings.Name = 'Email';
        settings.SAC_IAactiva__c = true;
        settings.SAC_Shadow__c = true;
        settings.SAC_Porcentaje__c = 100;
        settings.SAC_UmbralTematica__c = 0;
        settings.SAC_UmbralProductoServicio__c = 0;
        settings.SAC_UmbralMotivo__c = 0;
        settings.SAC_UmbralDetalle__c = 0;

        Database.insert(settings);
        Group grupoIntegracion = [SELECT Id FROM group WHERE developerName = 'SAC_Integration'];
        groupMember aso = new groupMember(
            groupId = grupoIntegracion.Id,
            userOrGroupId = usuarioGeneral.Id
        );
        //insert aso;
        system.runAs(usuarioAdmin){
            Database.insert(aso);     
        }

        Group colaIA =[SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = : 'SAC_GenialPdteIA' LIMIT 1];
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Subject de prueba');
        camposRecl.put('Description', 'Descripcion de prueba');
        camposRecl.put('ownerId', colaIA.Id);
        camposRecl.put('SAC_GenialEstado__c', 'SAC_001');
        camposRecl.put('Origin', 'Email');
        //para error en Class.SAC_Utils.comprobarEmailsBlackListAuto
        camposRecl.put('SuppliedEmail', 'test07032024931@test1.com.invalid');
 
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        
        
        Database.insert(reclamacion);
        
        caseShare reclamaShare = new caseShare(
            caseId = reclamacion.id,
            userOrGroupId = grupoIntegracion.id,
            caseAccessLevel = 'Edit'
        );
        insert reclamaShare;

        String clientePArt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        account acc = new account(
            CC_Numero_Documento__c='25071917P',
            firstName='Paco',
            lastName='Pelaes',
            recordTypeId = clientePArt
        );
        insert acc;
    }

    /*comprueba respuesta con account no existente como principal, confidencial y existente como no principales*/
    @isTest
    static void queueableAccount(){
        case reclamacion = [SELECT ID FROM CASE LIMIT 1];
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        String clientePArt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        //testeamos un confidencial
        account acc2 = new account(
            CC_Numero_Documento__c='37548393L',
            AV_NumPerso__c = '12345',
            AV_Confidencial__c = true,
            firstName='confidencial',
            lastName='Test',
            recordTypeId = clientePArt
        );
        insert acc2;
        string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'"}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161",'+
        '"direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410,'+
        ' Sueca, Valencia, España"},"reclamantes":[{"reclamantePrincipal":true,"reclamante":{"CC_Numero_Documento__c":"35825371L",'+
        '"PersonEmail":"bill.gates@hotmail.com.invalid","PersonMobilePhone":"731413628","BillingStreet":"Cádiz 64","BillingPostalCode":"7107","BillingCity":"Bérchules",'+
        '"BillingState":"Granada","BillingCountry":"España","firstName":"Bill","lastName":"Gates"},"umbrales":[{"nivel": "nombre","valor": 0.1},{"nivel": "nif","valor": 0.2},{"nivel": "email","valor": 0.3}]}]}},{"reclamantePrincipal":false,'+
        '"reclamante":{"CC_Numero_Documento__c":"25071917P","firstName":"Paco","lastName":"Pelaes"},"umbrales":[{"nivel": "nombre","valor": 0.1},{"nivel": "nif","valor": 0.2},{"nivel": "email","valor": 0.3}]}]}},'+
        '{"reclamantePrincipal":false,"reclamante":{"CC_Numero_Documento__c":"37548393L","firstName":"Confidencial","lastName":"Test"}}]}';
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf(textoRequest);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }
        test.stopTest();
        //list<account> listAccount = [SELECT ID FROM ACCOUNT];

        system.assertEquals(2, [SELECT count() FROM ACCOUNT], 'debería haber 2 accounts');//los accounts creados previamente, los accounts ahora no se crean
        
    }

    /*comprueba respuesta con account existente como principal*/
    @isTest
    static void queueableAccountExistente(){
        case reclamacion = [SELECT ID FROM CASE LIMIT 1];
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'"}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161",'+
        '"direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410,'+
        ' Sueca, Valencia, España"},"reclamantes":[{"reclamantePrincipal":true,'+
        '"reclamante":{"CC_Numero_Documento__c":"25071917P","firstName":"Paco","lastName":"Pelaes"}}]}';
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf(textoRequest);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }
        test.stopTest();

        //list<account> listAccount = [SELECT ID FROM ACCOUNT];

        system.assertEquals(1, [SELECT count() FROM ACCOUNT], 'solo debería haber 1 account');
        
    }

    /*comprueba cuando IA está desactivada y recibimos contestación*/
    @isTest
    static void queueableIADesconectada(){
        SAC_GenialSettingsCanal__c settings = [SELECT Id FROM SAC_GenialSettingsCanal__c LIMIT 1];
        settings.SAC_IAactiva__c = false;
        settings.SAC_Shadow__c = false;
        update settings;
        case reclamacion = [SELECT ID, ownerId, Origin FROM CASE LIMIT 1];
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        //es necesario saber el canal para acceder a SAC_GenialSettingsCanal__c
        case reclamaOriginal = new case();
        reclamaOriginal.Origin = 'Email';

        string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'", "Origin":"'+reclamaOriginal.Origin+'"}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161",'+
        '"direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410,'+
        ' Sueca, Valencia, España"},"reclamantes":[{"reclamantePrincipal":true,'+
        '"reclamante":{"CC_Numero_Documento__c":"25071917P","firstName":"Paco","lastName":"Pelaes"}}]}';
        request.requestUri ='/services/apexrest/ActualizacionCasoPretensiones';
        request.httpMethod = 'POST';
        request.requestBody = blob.valueOf(textoRequest);
        RestContext.request = request;
        RestContext.response = response;
        test.startTest();
        system.runAs(sacUser){
            SAC_Genial_WS.genialComunicacion();
        }
        test.stopTest();
        case reclamacion2 = [SELECT ID, ownerID FROM CASE LIMIT 1];
        system.assert(reclamacion != reclamacion2, 'Se esperaba un cambio de owner en la reclamación');
        
    }

    /*creacion de pretensiones*/
    @isTest
    static void pretensiones(){
        Id recTypeTematica = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recTypeProdServ = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recTypeMotivo = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        Id recTypeDetalle = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        List<CC_MCC__c> listaMCCs = new List<CC_MCC__c>();
        DateTime inicioVigencia = now();
        CC_MCC__c mccTematica1 = new CC_MCC__c(
            RecordTypeId = recTypeTematica,
            Name = 'Tematica',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-0101');
        insert mccTematica1;
        listaMCCs.add(mccTematica1);
        
        CC_MCC__c mccProdServ1 = new CC_MCC__c(
            RecordTypeId = recTypeProdServ,
            Name = 'ProdServ',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-010101',
            CC_Tematica__c = mccTematica1.id);
        insert mccProdServ1;
        listaMCCs.add(mccProdServ1);
    
        CC_MCC__c mccMotivo1 = new CC_MCC__c(
            RecordTypeId = recTypeMotivo,
            Name = 'Motivo',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Producto_Servicio__c = mccProdServ1.id,
            CC_Codigo_Externo__c = 'TEST-0102');
        insert mccMotivo1;
        listaMCCs.add(mccMotivo1);

        CC_MCC__c mccDetalle1 = new CC_MCC__c(
            RecordTypeId = recTypeDetalle,
            Name = 'Detalle',
            CC_Tipo_Cliente__c = 'SAC',
            CC_Fecha_Vigencia_Inicio__c = inicioVigencia,
            CC_Codigo_Externo__c = 'TEST-01010101',
            CC_Motivo__c = mccMotivo1.id);
        insert mccDetalle1;
        listaMCCs.add(mccDetalle1);

        SAC_Genial_WS.genialRequest genialRequest = new SAC_Genial_WS.genialRequest();
        
        case reclamacion = [SELECT ID, ownerId FROM CASE LIMIT 1];
        
        string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'","ownerId":"'+reclamacion.ownerId+'"},"pretensiones":[{"pretension":{"CC_MCC_Tematica__c":"'+listaMCCs[0].Id+'",'+
        '"CC_MCC_ProdServ__c":"'+listaMCCs[1].Id+'","CC_MCC_Motivo__c":"'+listaMCCs[2].Id+'","SEG_Detalle__c":"'+listaMCCs[3].Id+'","SAC_EsPrincipal__c":true,'+
            '"SAC_Reclamacion__c":"'+reclamacion.id+'","SAC_Resumen__c":"pretension de prueba genial"}, "umbrales": [{"nivel":"Tematica", "valor":1}, {"nivel":"ProductoServicio", "valor":1}, {"nivel":"Motivo", "valor":1}, {"nivel":"Detalle", "valor":1}]}],"pdteIA":true, "datosRecPrincipal":{"firstName":null, "lastName":null, "numPerso":null}},' +
            '"jsonRequest":"{\"pretensiones\":[{\"pretension\":{\"CC_MCC_Tematica__c\":\"a0VKN000000Lx6b2AC\",\"CC_MCC_ProdServ__c\":\"a0VKN000000Lx6c2AC\",\"CC_MCC_Motivo__c\":\"a0VKN000000Lx6d2AC\",\"SEG_Detalle__c\":\"a0VKN000000Lx6q2AC\",\"SAC_EsPrincipal__c\":false,\"SAC_Reclamacion__c\":\"500KN000001uvUeYAI\",\"SAC_Resumen__c\":\"pretension de prueba genial secundaria 1\"},\"umbrales\":[{\"nivel\":\"Tematica\",\"valor\":0},{\"nivel\":\"ProductoServicio\",\"valor\":0},{\"nivel\":\"Motivo\",\"valor\":0},{\"nivel\":\"Detalle\",\"valor\":0}]},{\"pretension\":{\"CC_MCC_Tematica__c\":\"a0VKN000000Lx6T2AS\",\"CC_MCC_ProdServ__c\":\"a0VKN000000Lx6U2AS\",\"CC_MCC_Motivo__c\":\"a0VKN000000Lx6Z2AS\",\"SEG_Detalle__c\":\"a0VKN000000Lx6a2AC\",\"SAC_EsPrincipal__c\":true,\"SAC_Reclamacion__c\":\"500KN000001uvUeYAI\",\"SAC_Resumen__c\":\"pretension de prueba genial principal\"},\"umbrales\":[{\"nivel\":\"Tematica\",\"valor\":0.1},{\"nivel\":\"ProductoServicio\",\"valor\":0.3},{\"nivel\":\"Motivo\",\"valor\":0.5},{\"nivel\":\"Detalle\",\"valor\":0.7}]}]}"';
        genialRequest = (SAC_Genial_WS.genialRequest)JSON.deserialize(textoRequest, SAC_Genial_WS.genialRequest.class);
        //es necesario saber el canal para acceder a SAC_GenialSettingsCanal__c
        case reclamaOriginal = new case();
        reclamaOriginal.Origin = 'Email';
        genialRequest.reclamaOriginal = reclamaOriginal;
        
        test.startTest();
        system.runAs(sacUser){
            System.enqueueJob(new SAC_GenialQueueable(genialRequest, 1));
        }
        test.stopTest();
        //list<SAC_Genial_Resultado__c> pretResultado = [SELECT Id FROM SAC_Genial_Resultado__c];
        system.assertEquals(2, [SELECT count() FROM SAC_Genial_Resultado__c], 'no se ha creado el numero de resultados asociados a las pretensiones esperados');
    }

    /*updateo del caso*/
    @isTest
    static void queueableUpdateCaso(){
        case reclamacion = [SELECT ID FROM CASE LIMIT 1];
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        //RestRequest request = new RestRequest();
        //estResponse response = new RestResponse();

        SAC_Genial_WS.genialRequest genialRequest = new SAC_Genial_WS.genialRequest();

        string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'"}, "pdteIA":true}';

        genialRequest = (SAC_Genial_WS.genialRequest)JSON.deserialize(textoRequest, SAC_Genial_WS.genialRequest.class);

        //es necesario saber el canal para acceder a SAC_GenialSettingsCanal__c
        case reclamaOriginal = new case();
        reclamaOriginal.Origin = 'Email';
        genialRequest.reclamaOriginal = reclamaOriginal;

        test.startTest();
        system.runAs(sacUser){
            System.enqueueJob(new SAC_GenialQueueable(genialRequest, 2));
        }
        test.stopTest();
        case reclamacion2 = [SELECT ID, SAC_GenialEstado__c FROM CASE LIMIT 1];
        system.assertEquals('SAC_003', reclamacion2.SAC_GenialEstado__c, 'SAC_GenialEstado no está en "respondido" como se esperaba');
        
    }

     /*updateo del caso account formulario*/
     @isTest
     static void queueableUpdateCasoFormulario(){
         case reclamacion = [SELECT ID FROM CASE LIMIT 1];
         case reclamaOriginal = new case();
         user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

         SAC_GenialSettingsCanal__c settings2 = new SAC_GenialSettingsCanal__c();
         settings2.Name = 'SAC_Formulario';
         settings2.SAC_IAactiva__c = true;
         settings2.SAC_Shadow__c = true;
         settings2.SAC_Porcentaje__c = 100;
         Database.insert(settings2);

         //account acc = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '25071917P' LIMIT 1];
 
         SAC_Genial_WS.genialRequest genialRequest = new SAC_Genial_WS.genialRequest();
 
         string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'"}, "pdteIA":true}';
 
         genialRequest = (SAC_Genial_WS.genialRequest)JSON.deserialize(textoRequest, SAC_Genial_WS.genialRequest.class);
         //genialRequest.reclamacion.AccountId = acc.Id;
        /* reclamaOriginal.AccountId = acc.Id;
         genialRequest.reclamaOriginal = reclamaOriginal;*/
         reclamaOriginal.Origin = 'SAC_Formulario';
         genialRequest.reclamaOriginal = reclamaOriginal;
         //genialRequest.reclamacion.AccountId = acc.Id;
         test.startTest();
         system.runAs(sacUser){
             System.enqueueJob(new SAC_GenialQueueable(genialRequest, 2));
         }
         test.stopTest();
         case reclamacion2 = [SELECT ID, SAC_GenialEstado__c FROM CASE LIMIT 1];
         system.assertEquals('SAC_003', reclamacion2.SAC_GenialEstado__c, 'SAC_GenialEstado no está en "respondido" como se esperaba');
         
     }

    /*updateo del caso en modo shadow*/
    @isTest
    static void queueableUpdateCasoShadow(){

        SAC_GenialSettingsCanal__c settings = [SELECT Id FROM SAC_GenialSettingsCanal__c LIMIT 1];
        settings.SAC_IAactiva__c = false;
        update settings;
        case reclamacion = [SELECT ID FROM CASE LIMIT 1];
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        //RestRequest request = new RestRequest();
        //RestResponse response = new RestResponse();

        SAC_Genial_WS.genialRequest genialRequest = new SAC_Genial_WS.genialRequest();

        string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'"}, "pdteIA":true}';

        genialRequest = (SAC_Genial_WS.genialRequest)JSON.deserialize(textoRequest, SAC_Genial_WS.genialRequest.class);

        //es necesario saber el canal para acceder a SAC_GenialSettingsCanal__c
        case reclamaOriginal = new case();
        reclamaOriginal.Origin = 'Email';
        genialRequest.reclamaOriginal = reclamaOriginal;

        test.startTest();
        system.runAs(sacUser){
            System.enqueueJob(new SAC_GenialQueueable(genialRequest, 2));
        }
        test.stopTest();
        case reclamacion2 = [SELECT ID, SAC_GenialEstado__c FROM CASE LIMIT 1];
        system.assertEquals('SAC_002', reclamacion2.SAC_GenialEstado__c, 'SAC_GenialEstado no está en "respondido(shadow)" como se esperaba');
        
    }

    /*inserción de la relación de reclamantes no principales*/
    @isTest
    static void queueableCaseReclamante(){
        case reclamacion = [SELECT ID FROM CASE LIMIT 1];
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        account acc = [SELECT ID FROM Account WHERE CC_Numero_Documento__c = '25071917P'];
        String clientePArt = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        account acc2 = new account(
            CC_Numero_Documento__c='33003125B',
            firstName='Baptiste',
            lastName='Ceba',
            recordTypeId = clientePArt
        );
        insert acc2;

        //simulamos que ya ha sido introducido un reclamante principal
        reclamacion.accountId = acc2.Id;
        update reclamacion;
        //RestRequest request = new RestRequest();
        //RestResponse response = new RestResponse();
        SAC_Genial_WS.genialRequest genialRequest = new SAC_Genial_WS.genialRequest();

        string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'"}, "contactoReclamacion":{"email":"contacto@mail.com.invalid","telefono":"661616161",'+
        '"direccion":"Camino Blanca, 1, 73º D","codPostal":"95543","poblacion":"El Longoria","provincia":"Málaga","pais":"España","direccionNoti":"calle falsa 123, 46410,'+
        ' Sueca, Valencia, España"},"reclamantes":[{"reclamantePrincipal":false,'+
        '"reclamante":{"Id":"'+acc.id+'","CC_Numero_Documento__c":"25071917P","firstName":"Paco","lastName":"Pelaes"},"umbrales":[{"nivel": "nombre","valor": 0.1},{"nivel": "nif","valor": 0.2},{"nivel": "email","valor": 0.3}]}]}';
        genialRequest = (SAC_Genial_WS.genialRequest)JSON.deserialize(textoRequest, SAC_Genial_WS.genialRequest.class);

        //es necesario saber el canal para acceder a SAC_GenialSettingsCanal__c
        case reclamaOriginal = new case();
        reclamaOriginal.Origin = 'Email';
        genialRequest.reclamaOriginal = reclamaOriginal;

        test.startTest();
        system.runAs(sacUser){
            System.enqueueJob(new SAC_GenialQueueable(genialRequest, 3));
        }
        test.stopTest();
        //list<SAC_caseReclamante__c> casosRec = [SELECT count() FROM SAC_caseReclamante__c];
        system.assertEquals(1,[SELECT count() FROM SAC_caseReclamante__c],'El número tiene que ser el original, ya que no se deben crear caseReclamantes');
        system.assertEquals(1,[SELECT count() FROM SAC_Genial_Resultado__c WHERE recordType.developerName = 'SAC_Reclamante_IA'], 'No se ha generado el registro resultado de reclamante');      
        
    }

    @isTest
    static void queueableUpdateCasoError(){
        case reclamacion = [SELECT ID FROM CASE LIMIT 1];
        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        //RestRequest request = new RestRequest();
        //RestResponse response = new RestResponse();

        SAC_Genial_WS.genialRequest genialRequest = new SAC_Genial_WS.genialRequest();

        string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'", "SAC_Tipo_integracion_IA__c":"fallo"}, "pdteIA":true}';

        genialRequest = (SAC_Genial_WS.genialRequest)JSON.deserialize(textoRequest, SAC_Genial_WS.genialRequest.class);

        //es necesario saber el canal para acceder a SAC_GenialSettingsCanal__c
        case reclamaOriginal = new case();
        reclamaOriginal.Origin = 'Email';
        genialRequest.reclamaOriginal = reclamaOriginal;
        
        test.startTest();
        system.runAs(sacUser){
    
            System.enqueueJob(new SAC_GenialQueueable(genialRequest, 2));
        
                
        }
        test.stopTest();
        case reclamacion2 = [SELECT ID, SAC_GenialEstado__c FROM CASE LIMIT 1];
        system.assertEquals('SAC_006', reclamacion2.SAC_GenialEstado__c, 'SAC_GenialEstado no está en "error" como se esperaba');
        
    }

    /*caza de error al crear pretensiones*/
    @isTest
    static void pretensionesKO(){

        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];

        SAC_Genial_WS.genialRequest genialRequest = new SAC_Genial_WS.genialRequest();
        
        case reclamacion = [SELECT ID, ownerId FROM CASE LIMIT 1];
        
        string textoRequest = '{"reclamacion":{"Id":"'+reclamacion.id+'","ownerId":"'+reclamacion.ownerId+'"},"pretensiones":[{"CC_MCC_Tematica__c":"12345",'+
        '"CC_MCC_ProdServ__c":"12345","CC_MCC_Motivo__c":"12345","SEG_Detalle__c":"12345","SAC_EsPrincipal__c":true,'+
        '"SAC_Reclamacion__c":"'+reclamacion.id+'","SAC_Resumen__c":"pretension de prueba genial"}],"pdteIA":true}';
        genialRequest = (SAC_Genial_WS.genialRequest)JSON.deserialize(textoRequest, SAC_Genial_WS.genialRequest.class);

        //es necesario saber el canal para acceder a SAC_GenialSettingsCanal__c
        case reclamaOriginal = new case();
        reclamaOriginal.Origin = 'Email';
        genialRequest.reclamaOriginal = reclamaOriginal;

        test.startTest();
        system.runAs(sacUser){
            System.enqueueJob(new SAC_GenialQueueable(genialRequest, 1));
        }
        test.stopTest();
        list<aggregateResult> pretResultado = [SELECT count(Id) conteo FROM CBK_Log__c WHERE Log_Level__c = 'ERROR'];
        
        system.assertEquals(2, integer.valueof(pretResultado.get(0).get('conteo')), 'no se ha creado el numero de errores esperados');
    }

    @isTest
    static void asignarPretensionPrincipal(){

        user sacUser = [SELECT ID FROM USER WHERE Username = 'usertest0@test.com.testSetup'];
        case reclamacion = [SELECT Id FROM case WHERE subject = 'Subject de prueba'];
        account cuenta = [SELECT Id FROM Account WHERE CC_Numero_Documento__c = '25071917P'];

        Case casoPretension = new Case(); 
        casoPretension.Status = 'SAC_001';
        casoPretension.SAC_StatusAuxiliar__c = 'SAC_001';
        casoPretension.AccountId = cuenta.Id;
        casoPretension.SAC_Reclamacion__c = reclamacion.Id;
        casoPretension.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        insert casoPretension;

        SAC_Genial_WS.genialRequest genialRequest = new SAC_Genial_WS.genialRequest();
        genialRequest.pdteIA = true;
        genialRequest.reclamacion = new case(sac_pretensionPrincipal__c = casoPretension.id);
        genialRequest.reclamaOriginal = new case(Origin = 'Email');

        test.startTest();
        system.runAs(sacUser){
            System.enqueueJob(new SAC_GenialQueueable(genialRequest, 4));
        }
        test.stopTest();

        system.assertEquals(casoPretension.id, [SELECT SAC_PretensionPrincipal__c FROM Case WHERE Id = : reclamacion.id].SAC_PretensionPrincipal__c, 'la pretensión no se ha asociado a la reclamación como principal');
    }
    public static DateTime now() {
        return System.now();
    }
}