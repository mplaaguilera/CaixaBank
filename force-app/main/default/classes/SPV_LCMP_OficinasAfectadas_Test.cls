/*****************************************************************
 * Name: SPV_LCMP_OficinasAfectadas_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de los métodos de la clase correspondiente
 * 
****************************************************************/ 

@isTest
public with sharing class SPV_LCMP_OficinasAfectadas_Test {

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

        //RecordTypes
        Id RECTYPEOFICINAS = Schema.SObjectType.SAC_ImagenDocumento__c.getRecordTypeInfosByDeveloperName().get('SPV_OficinaAfectada').getRecordTypeId();

        //Reclamaciones
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion1 = new Map<String, Object>();
        camposReclamacion1.put('Subject', 'TestRecCrearRec1');
        camposReclamacion1.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacion1.put('Status', 'SAC_002');
        camposReclamacion1.put('SEG_Subestado__c', 'Negociacion');
        camposReclamacion1.put('OwnerId', usuarioAdmin.Id);

        Case reclamacion1 = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion1);
        listaReclamaciones.add(reclamacion1);

        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        //Cuentas 
        List<Account> listaCuentas = SPV_TestDataFactory.crearCuentasNoClientePA(2);
        listaCuentas[0].PersonEmail = 'test@test.sactest';
        listaCuentas[0].BillingStreet = 'testStreet';
        listaCuentas[0].BillingPostalCode = '666';
        listaCuentas[0].BillingCity = 'testCity';
        listaCuentas[0].BillingState = 'tetState';
        listaCuentas[0].BillingCountry = 'testCountry';
        listaCuentas[0].Phone = '666666666';
        listaCuentas[0].PersonMobilePhone = '555555555';

        listaCuentas[1].PersonEmail = 'test@test.sactest';
        listaCuentas[1].BillingStreet = 'testStreet';
        listaCuentas[1].BillingPostalCode = '777';
        listaCuentas[1].BillingCity = 'testCity';
        listaCuentas[1].BillingState = 'tetState';
        listaCuentas[1].BillingCountry = 'testCountry';
        listaCuentas[1].PersonMobilePhone = '777777777';
        SPV_DatabaseDML.insertListDML(listaCuentas, true);

        //Objeto intermedio relacción reclamación-account (oficina afectada)

        List<SAC_ImagenDocumento__c> listaObjIntermedio = new List<SAC_ImagenDocumento__c>();
        SAC_ImagenDocumento__c objIntermedio = new SAC_ImagenDocumento__c();
        objIntermedio.SAC_Caso__c = reclamacion1.Id;
        objIntermedio.SPV_OficinaAfectada_Lookup__c = listaCuentas[0].Id;
        objIntermedio.RecordTypeId = RECTYPEOFICINAS;
        listaObjIntermedio.add(objIntermedio);
        
        SPV_DatabaseDML.insertListDML(listaObjIntermedio, true);
    }


    @isTest
    static void getOficinasAfectadas_Test(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];

        Test.startTest();
        
        SPV_LCMP_OficinasAfectadas.InfoOficinasWrapper respuesta = new SPV_LCMP_OficinasAfectadas.InfoOficinasWrapper(new List<SAC_ImagenDocumento__c>());
        SPV_LCMP_OficinasAfectadas.InfoOficinasWrapper respuesta2 = new SPV_LCMP_OficinasAfectadas.InfoOficinasWrapper(new List<SAC_ImagenDocumento__c>());
        System.runAs(usuario){
            respuesta = SPV_LCMP_OficinasAfectadas.getOficinasAfectadas(reclamacion.Id);
            respuesta2 = SPV_LCMP_OficinasAfectadas.getOficinasActualizadas(reclamacion.Id);
        }

        Assert.areNotEqual(null, respuesta, 'No se han obtenido las Oficinas Afectadas.');
        Assert.areNotEqual(null, respuesta2, 'No se han obtenido las Oficinas Afectadas 2.');
        Test.stopTest();

    }


    @isTest
    static void eliminarOficinaAfectada_Test(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        SAC_ImagenDocumento__c objIntermedio = [SELECT Id FROM SAC_ImagenDocumento__c WHERE SAC_Caso__c = :reclamacion.Id LIMIT 1];

        Test.startTest();
        System.runAs(usuario){
            SPV_LCMP_OficinasAfectadas.eliminarOficinaAfectada(objIntermedio.Id, reclamacion.Id, usuario.Id);
        }

        List<SAC_ImagenDocumento__c> listaResult = [SELECT Id FROM SAC_ImagenDocumento__c WHERE SAC_Caso__c = :reclamacion.Id LIMIT 1];
        Assert.areEqual(listaResult.isEmpty(), true, 'No se ha eliminado la oficina afectada.');

        Test.stopTest();

    }

    
    /*@isTest
    static void addOficinaAfectada_Test(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRecCrearRec1' LIMIT 1];
        Account oficina = [SELECT Id FROM Account WHERE PersonEmail = 'test@test.sactest' LIMIT 1];

        Test.startTest();
        System.runAs(usuario){
            reclamacion.CC_Oficina_Afectada_Lookup__c = oficina.Id;
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        List<SAC_ImagenDocumento__c> listaResult = [SELECT Id FROM SAC_ImagenDocumento__c WHERE SAC_Caso__c = :reclamacion.Id LIMIT 1];
        Assert.areNotEqual(listaResult.isEmpty(), true, 'No se ha eliminado la oficina afectada.'); //No tiene que estar vacía porque se acaba de crear un registro de SAC_ImagenDocumento__c con la nueva oficina afectada añadida

        Test.stopTest();
    }*/



}