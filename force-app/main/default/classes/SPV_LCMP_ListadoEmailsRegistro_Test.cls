/*****************************************************************
 * Name: SPV_LCMP_ListadoEmailsRegistro_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_LCMP_ListadoEmailsRegistro
 * 
****************************************************************/ 
@isTest
public with sharing class SPV_LCMP_ListadoEmailsRegistro_Test {
    
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

        //Grupo
        List<CC_Grupo_Colaborador__c> listGrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
        grupo.RecordTypeId = Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SPV_GrupoDeTareas').getRecordTypeId();
        grupo.Name = 'grupotest';
        grupo.SAC_PermiteEscalado__c = true;
        grupo.SAC_PermiteConsultas__c = true;
        grupo.SAC_PermiteTareas__c = true;
        grupo.SAC_PeriodoConsulta__c = 12;
        grupo.OS_Negocio__c = 'SPV';
        listGrupos.add(grupo);

        Database.insert(listGrupos);

        //Reclamacion
        List<Case> listaReclamaciones = new List<Case>();
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRecCrearRec1');
        // camposReclamacion.put('SPV_Organismo__c', 'SPV_CNMV');
        camposReclamacion.put('Status', 'SAC_003');
        camposReclamacion.put('OwnerId', listUsuarios[0].Id);
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_003');

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(casoReclamacion);
        Database.insert(listaReclamaciones);

        //Consulta
        List<SAC_Interaccion__c> listConsultas = new List<SAC_Interaccion__c>();
        Map<String, Object> camposObj = new Map<String, Object>();
        camposObj.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposObj.put('SAC_Titulo__c', 'ConsultaTestSPV');
        camposObj.put('SAC_GrupoColaborador__c', grupo.Id);
        SAC_Interaccion__c consulta = SPV_TestDataFactory.crearInteraccion('Consulta', camposObj);
        listConsultas.add(consulta);

        Database.insert(listConsultas);

        EmailMessage em  = new EmailMessage();
        em.relatedtoId = consulta.Id;
        em.Subject = 'emTest Consulta externa';
        em.ToAddress = 'test@test.com';
        em.MessageDate = System.now();
        Database.insert(em);
    }

    @isTest
    static void getEmailsTest(){
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c consulta = [SELECT id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'ConsultaTestSPV' LIMIT 1];

        Test.startTest();
        List<EmailMessage> result = new List<EmailMessage>();

        System.runAs(usuario) {
            result = SPV_LCMP_ListadoEmailsRegistro.getEmails(consulta.Id);
        }
        Test.stopTest();

        Assert.areEqual(false, result.isEmpty(), 'Error al recuperar los mensajes de la consulta');
    }
}