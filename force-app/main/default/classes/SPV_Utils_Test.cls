/*********************************************************************************************************
 * Name: SPV_Utils_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Test de SAC_Utils
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0               ---             Raúl Santos          29/04/24             Creación
**********************************************************************************************************/
@isTest
public with sharing class SPV_Utils_Test {
    
    @TestSetup
    static void makeData(){
        
        Test.startTest();
            User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
            SPV_DatabaseDML.insertDML(usuarioAdmin, true);

            List<User> listUsuarios ;

            System.runAs(usuarioAdmin){
                listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
                SPV_DatabaseDML.insertListDML(listUsuarios, true);
            }
        Test.stopTest();

        //Reclamacion
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRecCrearRec1');
        // camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);
        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        //Email Backlist
        SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
        maestroTema.Name ='emailtestinvalido@prueba.com';
        maestroTema.SAC_Activo__c = true;
        maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SPV_BlackListEmails').getRecordTypeId();
        SPV_DatabaseDML.insertDML(maestroTema, true);
    }

    @isTest
    static void getRecordTypeDevTest() {
        
        Set<String> setObjetos = new Set<String>{'Case','CC_MCC__c','CC_Grupo_Colaborador__c','CC_Grupo_Colaborador_Contact__c','SAC_Accion__c','SAC_Interaccion__c','SPV_Formulario__c'};
        Map<String,Map<String,Schema.RecordTypeInfo>> mapaRT = new Map<String,Map<String,Schema.RecordTypeInfo>>();
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            mapaRT = SPV_Utils.getRecordTypesObjects(setObjetos);
            Test.stopTest();
        }

        Assert.areEqual(true, mapaRT.containskey('Case'), 'El mapa contiene el objeto buscado.');
        Assert.areEqual(true, mapaRT.containskey('CC_MCC__c'), 'El mapa contiene el objeto buscado.');
        Assert.areEqual(true, mapaRT.containskey('CC_Grupo_Colaborador__c'), 'El mapa contiene el objeto buscado.');
        Assert.areEqual(true, mapaRT.containskey('CC_Grupo_Colaborador_Contact__c'), 'El mapa contiene el objeto buscado.'); 
        Assert.areEqual(true, mapaRT.containskey('SAC_Accion__c'), 'El mapa contiene el objeto buscado.');             
        Assert.areEqual(true, mapaRT.containskey('SAC_Interaccion__c'), 'El mapa contiene el objeto buscado.');      
        Assert.areEqual(true, mapaRT.containskey('SPV_Formulario__c'), 'El mapa contiene el objeto buscado.');      
    }

    @isTest
    static void creacionThreadIDTest(){
        Case caso = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
		System.runAs(usuario){
            test.startTest();
            String threadId = SPV_Utils.creacionThreadID(caso.Id);
            Assert.areNotEqual(null, threadId, 'No se ha calculado bien el threadId.');
            test.stopTest();
        }   
    }

    @isTest
    static void comprobarEmailsBlackListTest() {
        
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        List<SAC_MaestroTemas__c> emailsBlacklist = [SELECT Id, Name FROM SAC_MaestroTemas__c WHERE RecordType.DeveloperName = 'SPV_BlackListEmails' AND Name = 'emailtestinvalido@prueba.com' AND SAC_Activo__c = true LIMIT 1];

        String emailsNoValidosEncontrados = '';

        System.runAs(usuario) {
            Test.startTest();
            emailsNoValidosEncontrados = SPV_Utils.comprobarEmailsBlackList(emailsBlacklist, 'emailtestinvalido@prueba.com','', '');
            Test.stopTest();
        }
        
        Assert.areNotEqual('', emailsNoValidosEncontrados, 'Error al comprobar los emails de la blackList en envios manuales');
    }

    @isTest
    static void comprobarEmailsBlackListAutoTest() {
        
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        List<SAC_MaestroTemas__c> emailsBlacklist = [SELECT Id, Name FROM SAC_MaestroTemas__c WHERE RecordType.DeveloperName = 'SPV_BlackListEmails' AND Name = 'emailtestinvalido@prueba.com' AND SAC_Activo__c = true LIMIT 1];

        List<String> emailsValidos = new List<String>();

        System.runAs(usuario) {
            Test.startTest();
            List<String> listaEmails = new List<String>{ 'testemailSAC@test.com' };
            emailsValidos = SPV_Utils.comprobarEmailsBlackListAuto(emailsBlacklist, listaEmails);
            Test.stopTest();
        }
        
        Assert.areNotEqual(0, emailsValidos.size(), 'Error al comprobar los emails de la blackList en envios automáticos');
    }

    @isTest
    static void obtenerRecordTypesTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND IsActive = true LIMIT 1];
        
        Test.startTest();

        List<RecordType> listaResult = new List<RecordType>();
        System.runAs(usuario){
            
            listaResult = SPV_Utils.obtenerRecordTypes();
            
        }

        Assert.areNotEqual(true, listaResult.isEmpty(), 'No se han recuperado los record types.');
        Test.stopTest();
    }

    @isTest
    static void gestionarImagenesInlineRedactarMailTest() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario) {

            ContentVersion docsV = new contentVersion();
            docsV.title='/test.jpeg';
            docsV.PathOnClient ='/test.jpeg';
            docsV.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            SPV_DatabaseDML.insertDML(docsV, true);

            ContentVersion docsV2 = new ContentVersion();
            docsV2.title='/testDos.jpeg';
            docsV2.PathOnClient ='/testDos.jpeg';
            docsV2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body Dos');
            SPV_DatabaseDML.insertDML(docsV2, true);
    
            String randomUuid = UUID.randomUUID().toString().remove('-').left(18);
            String developerNameFinal = 'SPV_' + docsV2.id + randomUuid;
            
            ContentAsset assetId = new ContentAsset();
            assetId.DeveloperName = developerNameFinal;
            assetId.IsVisibleByExternalUsers = true;
            assetId.MasterLabel = developerNameFinal;
            SPV_DatabaseDML.insertDML(assetId, true);

            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = : docsV2.Id];
    
            ContentDocument cntDocument2 = new ContentDocument();
            cntDocument2.Id = documents[0].Id;
            SPV_DatabaseDML.updateDML(cntDocument2, true);

            String emailBody = '</p><p><img src="https://caixabankcc.lightning.force.com/sfc/servlet.shepherd/version/download/'+ docsV2.Id + '" alt="test1"></p><p>';
        
            Test.startTest();
                String htmlResult = SPV_Utils.gestionarImagenesInlineRedactarMail(emailBody);
            Test.stopTest();

            Assert.areNotEqual(emailBody, htmlResult, 'Error al parsear la imagen del email body');
        }
    }

    @isTest
    static void gestionarImagenesInlineRedactarMailTest2() {
        
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true LIMIT 1];

        System.runAs(usuario) {

            ContentVersion docsV = new contentVersion();
            docsV.title='/test.jpeg';
            docsV.PathOnClient ='/test.jpeg';
            docsV.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
            SPV_DatabaseDML.insertDML(docsV, true);

            ContentVersion docsV2 = new ContentVersion();
            docsV2.title='/testDos.jpeg';
            docsV2.PathOnClient ='/testDos.jpeg';
            docsV2.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body Dos');
            SPV_DatabaseDML.insertDML(docsV2, true);
    
            String randomUuid = UUID.randomUUID().toString().remove('-').left(18);
            String developerNameFinal = 'SPV_' + docsV2.id + randomUuid;
            
            ContentAsset assetId = new ContentAsset();
            assetId.DeveloperName = developerNameFinal;
            assetId.IsVisibleByExternalUsers = true;
            assetId.MasterLabel = developerNameFinal;
            SPV_DatabaseDML.insertDML(assetId, true);

            List<ContentDocument> documents = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = : docsV2.Id];
    
            ContentDocument cntDocument2 = new ContentDocument();
            cntDocument2.Id = documents[0].Id;
            cntDocument2.ContentAssetId = assetId.Id;
            SPV_DatabaseDML.updateDML(cntDocument2, true);

            String emailBody = '</p><p><img src="https://caixabankcc.lightning.force.com/sfc/servlet.shepherd/version/download/'+ docsV2.Id + '" alt="test2"></p><p>';
        
            Test.startTest();
                String htmlResult = SPV_Utils.gestionarImagenesInlineRedactarMail(emailBody);
            Test.stopTest();

            Assert.areNotEqual(emailBody, htmlResult, 'Error al parsear la imagen del email body');
            Assert.areEqual(true, htmlResult.contains(developerNameFinal), 'Error al convertir la imagen del email body');
        }
    }

    @isTest
    static void comprobarTieneByPassTest(){

        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Boolean resultado;

        System.runAs(usuario){
            resultado = SPV_Utils.comprobarTieneByPass();
        }

        Assert.areEqual(resultado, false, 'No se ha comprobado correctamente');
        Test.stopTest();
    }

    @isTest
    static void procesarPermisionSetTest(){

        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Boolean esAdmin = false;


        System.runAs(usuario){
            SPV_Utils.procesarPermisionSet(true, usuario.Id, 'SPV_SystemAdmin');

            List<PermissionSetAssignment> psas = [SELECT ID FROM PermissionSetAssignment WHERE PermissionSet.Name = 'SPV_SystemAdmin' AND AssigneeId =: usuario.Id LIMIT 1];
            if(!psas.isEmpty()){
                esAdmin = true;
            }
        }

        Assert.areNotEqual(false, esAdmin, 'No ha podido insertar el PS al usuario');
        Test.stopTest();
    }


    @isTest
    static void minutosHastaMedianocheTest(){
        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Integer minutosDiaCompleto = 0;

        System.runAs(usuario){
            minutosDiaCompleto = SPV_Utils.minutosHastaMedianoche(CBK_UtilsDate.nowSYS());
        }

        Assert.areNotEqual(0, minutosDiaCompleto, 'No ha calcular la diferencia de tiempo');
        Test.stopTest();
    }
}