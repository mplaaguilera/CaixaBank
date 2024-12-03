/*****************************************************************
 * Name: SPV_LCMP_InsertarEscalado_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SPV_LCMP_InsertarEscalado
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 *  1.0           US929958     Sergio Martín          04/06/24     Creación Clase
*****************************************************************/
@isTest
public with sharing class SPV_LCMP_InsertarEscalado_Test {
    @TestSetup
    static void makeData(){
        Test.startTest();
        //Usuario Admin
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuario = new User();
        System.RunAs(usuarioAdmin) {
            usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];   
            Database.insert(usuario);
        }
        Test.stopTest();

        List<CC_Grupo_Colaborador__c> listagrupos = new List<CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();

        
        listagrupos = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',3);
        listagrupos[0].Name = 'grupoTest';
        listagrupos[0].SAC_PermiteEscalado__c = true;
        listagrupos[0].SAC_Email__c = 'testing@test.test';
        listagrupos[0].SAC_DeveloperName__c = 'COPS';

        listagrupos[1].Name = 'grupoTest';
        listagrupos[1].SAC_PermiteEscalado__c = true;
        listagrupos[1].SAC_Email__c = 'testing@test.test';
        listagrupos[1].SAC_DeveloperName__c = 'AJ';
        
        Database.insert(listagrupos);
        grupo = listagrupos[0];

        // Colaborador contact
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = SPV_TestDataFactory.crearColaboradorContact(usuario.Id, grupo.Id); 
        grupoColaboradorContact.SAC_Administrador__c = true;
        Database.insert(grupoColaboradorContact);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupo.Id); 
        grupoColaboradorContact2.SAC_Administrador__c = true;
        Database.insert(grupoColaboradorContact2);

        // Reclamaciones
        List<Case> listaReclamaciones = new List<Case>();
        
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_002');
        camposRecl.put('SEG_Subestado__c', 'Allanamiento');
        camposRecl.put('OwnerId', usuario.id);
        camposRecl.put('SEG_Grupo__c', grupo.Id);

        Case casoReclamacion = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(casoReclamacion);

        //RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRecConEscalado');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'SAC_002');
        camposRecl2.put('SEG_Subestado__c', 'Alegaciones');
        camposRecl2.put('OwnerId', usuario.id);
        camposRecl2.put('SEG_Grupo__c', grupo.Id);

        Case casoReclamacion2 = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        listaReclamaciones.add(casoReclamacion2);

        //RECLAMACION 3 
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'TestRec3');
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'SAC_002');
        camposRecl2.put('SEG_Subestado__c', 'Alegaciones');
        camposRecl3.put('OwnerId', usuarioAdmin.Id);
    
        Case casoReclamacion3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);
        listaReclamaciones.add(casoReclamacion3);

        Database.insert(listaReclamaciones);             

        //Interaccion
        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_Titulo__c', 'propuesta test');
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_MotivoEscalado__c', 'SPV_Alegación');
        camposEsc.put('SAC_CasoEscalado__c', casoReclamacion2.Id);
        camposEsc.put('OwnerId', usuario.Id);
        camposEsc.put('SAC_GrupoColaborador__c', grupo.Id);
        camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c escalado = SPV_TestDataFactory.crearInteraccion('Escalado',camposEsc);
        Database.insert(escalado); 
    }


    @isTest
    static void esPropietarioTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject, OwnerId FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        Boolean propietario = false;

        Test.startTest();
        System.runAs(usuario) {
            propietario = SPV_LCMP_InsertarEscalado.esPropietario(caso.Id);
        }
        Test.stopTest();

        System.assertEquals(false, propietario, 'No se ha podido comprobar si el usuario puede ser propietario del escalado');
    }


    @IsTest
    static void recogerGruposParaEscaladosTest(){
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<CC_Grupo_Colaborador__c> resultado;

        Test.startTest();
        System.runAs(usuario){
            resultado = SPV_LCMP_InsertarEscalado.recogerGruposParaEscalados(caso.Id);
        }
        Test.stopTest();
        
        System.assertNotEquals(null, resultado, 'No se han podido recoger los grupos disponibles para escalar');   
    }

    @isTest
    static void hayEscaladosAbiertosTest() {
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject FROM Case WHERE Subject = 'TestRecConEscalado' LIMIT 1];
        Boolean hayEscaladosAbiertos = false;

        Test.startTest();
        System.runAs(usuario) {
            hayEscaladosAbiertos = SPV_LCMP_InsertarEscalado.hayEscaladosAbiertos(caso.Id);
        }
        Test.stopTest();

        System.assertNotEquals(false, hayEscaladosAbiertos, 'No se ha podido comporbar si hay escalados abiertos en la reclamación');
    }


    @isTest
    static void insertarEscaladoTest() {
        String escaladoId;
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@testSPV.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = 'COPS' LIMIT 1];
        Test.startTest();
        System.runAs(usuario) {
            escaladoId = SPV_LCMP_InsertarEscalado.insertarEscalado(caso.Id, 'propuesta de prueba', 'titulo1', 'SPV_Allanamiento', 'observaciones', grupo.Id);
        }
        Test.stopTest();

        System.assertNotEquals(escaladoId, null, 'No se ha podido crear el escalado');
    }
}