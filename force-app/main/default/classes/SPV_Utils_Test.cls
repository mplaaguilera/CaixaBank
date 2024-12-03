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
        Database.insert(usuarioAdmin);

        List<User> listUsuarios ;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            Database.insert(listUsuarios );
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
        Database.insert(listaReclamaciones);
        //Email Backlist
        SAC_MaestroTemas__c maestroTema = new SAC_MaestroTemas__c();
        maestroTema.Name ='emailtestinvalido@prueba.com';
        maestroTema.SAC_Activo__c = true;
        maestroTema.RecordTypeId = Schema.SObjectType.SAC_MaestroTemas__c.getRecordTypeInfosByDeveloperName().get('SPV_BlackListEmails').getRecordTypeId();
        Database.insert(maestroTema);
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
}