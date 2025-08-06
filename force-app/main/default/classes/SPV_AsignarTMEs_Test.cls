/*****************************************************************
 * Name: SPV_AsignarTME_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de SPV_AsignarTMEs
 * 
****************************************************************/
/**
*   @description SPV_AsignarTMEs_Test
*/
@isTest
public with sharing class SPV_AsignarTMEs_Test {

    @TestSetup
    static void makeData(){
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        SPV_DatabaseDML.insertDML(usuarioAdmin, true);

        List<User> listUsuarios ;

        System.runAs(usuarioAdmin){
            listUsuarios  = SPV_TestDataFactory.crearUsuarioSPVGeneral(2);
            SPV_DatabaseDML.insertListDML(listUsuarios, true);
        }

        //RecordTypes
        Id tipoRegistroParametrizaciones = Schema.SObjectType.SAC_ParametrizacionSLATME__c.getRecordTypeInfosByDeveloperName().get('SPV_TMO').getRecordTypeId();

        //Reclamaciones
        List<Case> listaReclamaciones = new List<Case>();

        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRec');
        camposReclamacion.put('SPV_Organismo__c', 'SPV_BDE');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);

        SPV_DatabaseDML.insertListDML(listaReclamaciones, true);

        //Pretensiones
        List<Case> listaPretensiones = new List<Case>();

        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pruebaPretension1');
        camposPret.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret.put('OwnerId', listUsuarios[0].Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_EsPrincipal__c', true);
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('SAC_ResumenManual__c', 'Test');
        camposPret.put('SPV_ObservacionesReclamacion__c', 'Observacion Test');

        Case casoPretension1 = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension1);

        SPV_DatabaseDML.insertListDML(listaPretensiones, true);

        //Parametrizaciones SLA/TMO
        List<SAC_ParametrizacionSLATME__c> listaParametrizaciones = new List<SAC_ParametrizacionSLATME__c>();
        SAC_ParametrizacionSLATME__c parametrizacion1 = new SAC_ParametrizacionSLATME__c();
        parametrizacion1.Name = 'TMO Envío Análisis y Decisión';
        parametrizacion1.SAC_Estados__c = 'SPV_Envio';
        parametrizacion1.RecordTypeId = tipoRegistroParametrizaciones;

        listaParametrizaciones.add(parametrizacion1);

        SPV_DatabaseDML.insertListDML(listaParametrizaciones, true);
    }


    @isTest
    public static void insertarTMOconTPETest(){

        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        System.runAs(usuario){
            reclamacion.Status = 'SPV_Envio';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        List<SAC_TMECaso__c> listaResult = [SELECT Id FROM SAC_TMECaso__c WHERE SAC_Caso__c = :reclamacion.Id];
        Assert.areNotEqual(listaResult.isEmpty(), true, 'No se ha creado el TMO.');
        Test.stopTest();
    }

    @isTest
    public static void finalizarTMOTest(){
            Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        System.runAs(usuario){
            reclamacion.Status = 'SPV_Envio';
            SPV_DatabaseDML.updateDML(reclamacion, true);

            reclamacion.Status = 'SPV_PendienteRespuestaOrganismo';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        SAC_TMECaso__c tmeResult = [SELECT Id FROM SAC_TMECaso__c WHERE SAC_Caso__c = :reclamacion.Id AND Name = 'TMO Envío Análisis y Decisión'];
        SAC_TiempoEstados__c tpeResult = [SELECT Id, SAC_Fin__c FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__c = :tmeResult.Id ORDER BY CreatedDate desc LIMIT 1];
        Assert.areNotEqual(tpeResult.SAC_Fin__c, null, 'No se ha cerrado el TMO.');
        Test.stopTest();
    }

    @isTest
    public static void coberturaMetodoComprobarDuplicadoTest(){
        Test.startTest();
        User usuario = [SELECT Id, Name FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];

        System.runAs(usuario){
            reclamacion.Status = 'SPV_Envio';
            SPV_DatabaseDML.updateDML(reclamacion, true);

            reclamacion.Status = 'SPV_PendienteRespuestaOrganismo';
            SPV_DatabaseDML.updateDML(reclamacion, true);

            reclamacion.Status = 'SPV_Envio';
            SPV_DatabaseDML.updateDML(reclamacion, true);
        }

        SAC_TMECaso__c tmeResult = [SELECT Id FROM SAC_TMECaso__c WHERE SAC_Caso__c = :reclamacion.Id AND Name = 'TMO Envío Análisis y Decisión'];
        SAC_TiempoEstados__c tpeResult = [SELECT Id, SAC_Fin__c FROM SAC_TiempoEstados__c WHERE SAC_TMECaso__c = :tmeResult.Id ORDER BY CreatedDate desc LIMIT 1];
        Assert.areEqual(tpeResult.SAC_Fin__c, null, 'No se ha cerrado el TMO.');
        Test.stopTest();
    }

}