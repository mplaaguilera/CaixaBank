/***********************************************************************
 * Name: SAC_LCMP_ResponderConsulta_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para operaciones de LWC sAC_ResponderConsulta
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US361683         Marcela Neira        28/04/22     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	29/12/22	 Modificación (agregada assertion)
*************************************************************************/
@isTest
public with sharing class SAC_LCMP_ResponderConsulta_Test {
    @TestSetup
    static void makeData(){
        
        List<User> usuarios = SAC_TestDataFactory.crearUsuarioSACGeneral(1);
        //usuario
        usuarios[0].Username = 'ustestesteo@test.com';
        usuarios[0].Alias = 'alias'; 
        SAC_DatabaseDML.insertListDML(usuarios, false);     
        //Database.insert(usuarios);

        //grupo colaborador
        List<CC_Grupo_Colaborador__c> listagrupos = SAC_TestDataFactory.crearGrupoColaborador('ResponsableAccion',1);
        listagrupos[0].Name = 'grupoTestOficinas';
        listagrupos[0].SAC_PermiteConsultas__c = true;
        listagrupos[0].SAC_NivelGrupo__c = 'SAC_Nivel2';
        listagrupos[0].SAC_Email__c = 'etestingsac1409@test.test';
        listagrupos[0].SAC_DeveloperName__c = 'OFICINA';
        listagrupos[0].SAC_PeriodoConsulta__c = 12;
        listagrupos[0].SAC_TieneUsuariosActivos__c = true;
        SAC_DatabaseDML.insertDML(listagrupos[0], false); 
        //Database.insert(listagrupos[0]);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testCaso');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'Alta');
        camposRecl.put('SAC_StatusAuxiliar__c', 'Alta');
        camposRecl.put('OwnerId', usuarios[0].Id);

        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(casoReclamacion, false); 
        //Database.insert(casoReclamacion);
        
        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();
        //Interaccion consulta
        Map<String, Object> camposCons = new Map<String, Object>();
        camposCons.put('SAC_Titulo__c', 'consulta');
        camposCons.put('SAC_Propuesta__c', 'consulta');
        camposCons.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposCons.put('OwnerId', usuarios[0].Id);
        SAC_Interaccion__c consulta = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons);
        listaConsultas.add(consulta);

        //Interaccion consulta 2
        Map<String, Object> camposCons2 = new Map<String, Object>();
        camposCons2.put('SAC_Titulo__c', 'consulta2');
        camposCons2.put('SAC_Propuesta__c', 'consulta');
        camposCons2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposCons2.put('SAC_Respuesta__c', 'Respuesta consulta test');
        camposCons2.put('OwnerId', usuarios[0].Id);
        SAC_Interaccion__c consulta2 = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons2);
        listaConsultas.add(consulta2);

        //Interaccion consulta 3
        Map<String, Object> camposCons3 = new Map<String, Object>();
        camposCons3.put('SAC_Titulo__c', 'consulta3');
        camposCons3.put('SAC_Propuesta__c', 'consulta');
        camposCons3.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposCons3.put('OwnerId', usuarios[0].Id);
        camposCons3.put('SAC_GrupoColaborador__c', listaGrupos[0].Id);
        SAC_Interaccion__c consulta3 = SAC_TestDataFactory.crearInteraccion('Consulta',camposCons3);
        listaConsultas.add(consulta3);
        
        SAC_DatabaseDML.insertListDML(listaConsultas, false); 
        //Database.insert(listaConsultas);
    }


    @istest 
    static void responderConsultaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        String comprobacion;
        test.startTest();
        System.runAs(usuario) {
            comprobacion = SAC_LCMP_ResponderConsulta.responderConsulta(consulta.id, 'Esta es la respuesta', 'SAC_FaltaInformacion');
        }
        test.stopTest();
        System.assertEquals('Esta es la respuesta', comprobacion, 'No se ha respondido la consulta correctamente');
    }

    @istest 
    static void responderConsultaTest2() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c consultaOficina = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta3' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        String comprobacion2;
        test.startTest();
        System.runAs(usuario) {
            comprobacion2 = SAC_LCMP_ResponderConsulta.responderConsulta(consultaOficina.id, 'Esta es la respuesta', 'SAC_FaltaInformacion');
        }
        test.stopTest();
        System.assertEquals('Esta es la respuesta', comprobacion2, 'No se ha respondido la consulta correctamente');
    }

    @istest 
    static void guardarConsultaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        String comprobacion;
        test.startTest();
        System.runAs(usuario) {
            comprobacion = SAC_LCMP_ResponderConsulta.guardarConsulta(consulta.id, 'Esta es la respuesta', 'SAC_FaltaInformacion');
        }
        test.stopTest();
        System.assertEquals('Esta es la respuesta', comprobacion, 'No se ha guardado la respuesta correctamente');
    }

    @istest 
    static void guardarConsultaTest2() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c consultaOficina = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta3' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        String comprobacion;
        test.startTest();
        System.runAs(usuario) {
            comprobacion = SAC_LCMP_ResponderConsulta.guardarConsulta(consultaOficina.id, 'Esta es la respuesta', 'SAC_FaltaInformacion');
        }
        test.stopTest();
        System.assertEquals('Esta es la respuesta', comprobacion, 'No se ha guardado la respuesta correctamente');
    }
    
    @istest 
    static void getRespuestaConsultaTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta2' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        String comprobacion;
        test.startTest();
        System.runAs(usuario) {
            comprobacion = SAC_LCMP_ResponderConsulta.getRespuestaConsulta(consulta.id);
        }
        test.stopTest();
        System.assertEquals('Respuesta consulta test', comprobacion, 'No se ha obtenido la respuesta correctamente');
        
    }

    @isTest
    static void insertarAdjuntoCasoTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'ustestesteo@test.com' AND isActive = true Limit 1];
        SAC_Interaccion__c consulta = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'consulta2' LIMIT 1];

        PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuario.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
        SAC_DatabaseDML.insertDML(permiSetAssi, false); 
        //Database.insert(permiSetAssi);

        Test.startTest();
        System.runAs(usuario) {
            //Archivo adjunto
            ContentVersion newcont = new ContentVersion();
            newcont.Title = 'prueba';
            newcont.PathOnClient = 'caixa.jpeg';
            Blob b=Blob.valueOf('This is version data');
            newcont.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
            newcont.FirstPublishLocationId  = consulta.id;
            SAC_DatabaseDML.insertDML(newcont, false); 
            //Database.insert(newcont); 

            SAC_LCMP_ResponderConsulta.insertarAdjuntoCaso(consulta.Id, 1);
        }
        Test.stopTest();
		
        System.assertNotEquals(null, 'adjuntado', 'no se ha podido insertar adjunto');
    }
}