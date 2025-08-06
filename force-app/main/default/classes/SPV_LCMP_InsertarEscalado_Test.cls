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
        SPV_DatabaseDML.insertDML(usuarioAdmin, true); 
        //Database.insert(usuarioAdmin);

        User usuario = new User();
        System.RunAs(usuarioAdmin) {
            usuario = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];   
            //Database.insert(usuario);
            SPV_DatabaseDML.insertDML(usuario, true);
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
        listagrupos[1].SAC_DeveloperName__c = 'SPV_AJ';
        
        //Database.insert(listagrupos);
        SPV_DatabaseDML.insertListDML(listagrupos, true);
        grupo = listagrupos[0];


        System.RunAs(usuarioAdmin) {
            // Colaborador contact
            List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = SPV_TestDataFactory.crearColaboradorContact(usuario.Id, grupo.Id); 
            grupoColaboradorContact.SAC_Administrador__c = true;
            listaColaboradores.add(grupoColaboradorContact);

            CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupo.Id); 
            grupoColaboradorContact2.SAC_Administrador__c = true;
            listaColaboradores.add(grupoColaboradorContact2);

            SPV_DatabaseDML.insertListDML(listaColaboradores, true);
        }

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

        //Pretensiones
        List<Case> listPretensiones = new List<Case>();
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SuppliedCompany', 'pruebaPretension');
        camposPret.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret.put('OwnerId', usuario.Id);
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);

        Case pretension = SPV_TestDataFactory.crearCaso('Pretension',camposPret);
        listPretensiones.add(pretension);

        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SuppliedCompany', 'pruebaPretension2');
        camposPret2.put('SPV_Organismo__c', 'SPV_Consumo');
        camposPret2.put('OwnerId', usuario.Id);
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret2.put('SAC_EsPrincipal__c', true);
        camposPret2.put('SAC_Motivoresultadonegociacion__c', 'Solicita verificar primero documentación no disponible');
        camposPret2.put('SAC_ResultadoNegociacion__c', 'Con acuerdo');
        camposPret2.put('SAC_Observaciones__c', 'Test');

        Case pretension2 = SPV_TestDataFactory.crearCaso('Pretension',camposPret2);
        listPretensiones.add(pretension2);

        SPV_DatabaseDML.insertListDML(listPretensiones, true);

        //Interaccion
        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_Titulo__c', 'propuesta test');
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_MotivoEscalado__c', 'SAC_SolicitudAJ');
        camposEsc.put('SAC_CasoEscalado__c', casoReclamacion2.Id);
        camposEsc.put('OwnerId', usuario.Id);
        camposEsc.put('SAC_GrupoColaborador__c', grupo.Id);
        camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');
        
        SAC_Interaccion__c escalado = SPV_TestDataFactory.crearInteraccion('Escalado',camposEsc);
        SPV_DatabaseDML.insertDML(escalado, true);
        //Database.insert(escalado); 
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

    @isTest
    static void comprobarCamposEscalarTest(){
        Test.startTest();
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case reclamacion = [SELECT Id FROM Case Where Subject = 'TestRec'];
        Case pretension = [SELECT id, Status, SAC_EsPrincipal__c, CBK_Case_Extension_Id__c FROM Case WHERE SuppliedCompany = 'pruebaPretension' LIMIT 1];
        Case pretension2 = [SELECT id, Status, SAC_EsPrincipal__c, CBK_Case_Extension_Id__c FROM Case WHERE SuppliedCompany = 'pruebaPretension2' LIMIT 1];

        CBK_Case_Extension__c caseExtension1 = new CBK_Case_Extension__c();
        caseExtension1.Id = pretension.CBK_Case_Extension_Id__c;
        caseExtension1.SPV_DecisionPretensionLetrado__c = 'Allanamiento';

        CBK_Case_Extension__c caseExtension2 = new CBK_Case_Extension__c();
        caseExtension2.Id = pretension2.CBK_Case_Extension_Id__c;
        caseExtension2.SPV_DecisionPretensionLetrado__c = 'Desistimiento';

        List<CBK_Case_Extension__c> listaCaseExtension = new List<CBK_Case_Extension__c>();
        listaCaseExtension.add(caseExtension1);
        listaCaseExtension.add(caseExtension2);

        String resultado = '';

        System.runAs(usuario){
            SPV_DatabaseDML.updateListDML(listaCaseExtension, true);

            resultado = SPV_LCMP_InsertarEscalado.comprobarCamposEscalar(reclamacion.Id);
        }

        Assert.areEqual(false, String.isBlank(resultado), 'No se han realizado las comprobaciones correctamente.');
        Test.stopTest();
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
        User usuario = [SELECT id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND isActive = true Limit 1];
        Case caso = [SELECT Id, Subject, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c = 'COPS' LIMIT 1];
        Test.startTest();
        System.runAs(usuario) {
            escaladoId = SPV_LCMP_InsertarEscalado.insertarEscalado(caso.Id, 'SPV_Otros', 'ObservacionesTest', 'PropuestaTest', grupo.Id, 'SAC_OtrosMotivosEsc', 'ObservacionesTest');
        }
        Test.stopTest();

        SAC_Interaccion__c escalado2 = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Propuesta__c = 'PropuestaTest'];
        System.assertNotEquals(escalado2, null, 'No se ha podido crear el escalado');
    }
}