/*********************************************************************************************************
 * Name: SPV_GrupoColaboradorContactHelper_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Test de los triggers de SPV del objeto CC_Grupo_Colaborador_Contact__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0             US828257           Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

@isTest
public with sharing class SPV_GrupoColaboradorContactHelper_Test {

    @TestSetup
    static void makeData(){

        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);
        }
        Test.stopTest();


        //Grupos colaboradores
        List<CC_Grupo_Colaborador__c> gruposColaboradores = new List <CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoGestor = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
        grupoGestor.SAC_MaximoCasosDiarios__c = 5;
        grupoGestor.SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposColaboradores.add(grupoGestor);

        CC_Grupo_Colaborador__c grupoLetrado = SPV_TestDataFactory.crearGrupoColaborador('GrupoLetrado',1)[0];
        grupoLetrado.SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposColaboradores.add(grupoLetrado);

        List<CC_Grupo_Colaborador__c> gruposTareas = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',2);
        gruposTareas[0].SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposTareas[0].SAC_DeveloperName__c = 'SPV_COPS';
        gruposTareas[1].SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposTareas[1].SAC_DeveloperName__c = 'SPV_AJ';
        gruposColaboradores.addAll(gruposTareas);

        Database.insert(gruposColaboradores);

        //Reclamación
        Group colaPteAsignar = [SELECT id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar'];
        List<Case> listaReclamaciones = new List<Case>();
        Case reclamacion = new Case();
        Map<String, Object> camposReclamacion = new Map<String, Object>();
        camposReclamacion.put('Subject', 'TestRec PteAsignar');
        camposReclamacion.put('Origin', 'Backoffice');
        camposReclamacion.put('Status', 'SAC_001');
        camposReclamacion.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposReclamacion.put('SEG_Grupo__c', grupoGestor.Id);
        camposReclamacion.put('OwnerId', colaPteAsignar.Id);

        reclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposReclamacion);
        listaReclamaciones.add(reclamacion);
        Database.insert(listaReclamaciones);
        
        
        //Colaboradores     
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact1 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupoGestor.Id);
        grupoColaboradorContact1.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact1);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupoLetrado.Id);
        grupoColaboradorContact2.SAC_Administrador__c = false;
        listaColaboradores.add(grupoColaboradorContact2);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact3 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, gruposTareas[0].Id);
        listaColaboradores.add(grupoColaboradorContact3);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact4 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, gruposTareas[1].Id);
        listaColaboradores.add(grupoColaboradorContact4);

        System.runAs(usuarioAdmin){
            Database.insert(listaColaboradores);
        }
    } 

    @IsTest
    public static void insertarColaboradorTest(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        List<CC_Grupo_Colaborador__c> gruposColab = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Gestor 0' OR Name = 'Grupo Letrado 0' OR Name = 'Grupo De Tareas 0' OR Name = 'Grupo De Tareas 1'];

        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();

        for(CC_Grupo_Colaborador__c grupo : gruposColab){
            CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();
            colaboradorNuevo.SAC_Administrador__c = true;
            colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
            colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;
            listaColaboradores.add(colaboradorNuevo);
        }
          
        Test.startTest();

        System.runAs(usuarioGeneral){
            Database.insert(listaColaboradores);

            Test.stopTest();
            PermissionSet ps = [SELECT id FROM PermissionSet WHERE PermissionSet.Name = 'SPV_Gestor'];
            List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: listaColaboradores[0].CC_Usuario__c];   

            Assert.areNotEqual(null, psa, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
        }
    } 

    @IsTest
    public static void insertarColaboradorTest2(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        CC_Grupo_Colaborador__c grupo = [SELECT Id FROM CC_Grupo_Colaborador__c WHERE Name = 'Grupo Gestor 0' LIMIT 1];

        List<CC_Grupo_Colaborador_Contact__c> listaUsers = new List<CC_Grupo_Colaborador_Contact__c>();

        CC_Grupo_Colaborador_Contact__c colaboradorNuevo = new CC_Grupo_Colaborador_Contact__c();
        colaboradorNuevo.CC_Usuario__c = usuarioGeneral.Id;
        colaboradorNuevo.CC_Grupo_Colaborador__c = grupo.Id;
        listaUsers.add(colaboradorNuevo);
          
        Test.startTest();

        System.runAs(usuarioGeneral){
            Database.insert(colaboradorNuevo);

            Test.stopTest();

            PermissionSet ps = [SELECT id FROM PermissionSet WHERE PermissionSet.Name = 'SPV_Gestor'];
            List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradorNuevo.CC_Usuario__c];   

            Assert.areNotEqual(null, psa, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
        }
    } 

    @IsTest
    public static void modificarColaboradorTest(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        CC_Grupo_Colaborador_Contact__c colaborador = [SELECT Id, SAC_Administrador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: usuarioGeneral.Id AND SAC_Administrador__c = true LIMIT 1];
        CC_Grupo_Colaborador_Contact__c colaborador2 = [SELECT Id, SAC_Administrador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: usuarioGeneral.Id AND SAC_Administrador__c = false LIMIT 1];

        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        colaborador.SAC_Administrador__c = false;
        colaborador2.SAC_Administrador__c = true;
        listaColaboradores.add(colaborador);
        listaColaboradores.add(colaborador2);

        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_General'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuarioGeneral.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        Database.insert(permiSetAssiAdmin);
        
        Test.startTest();
        
        System.runAs(usuarioGeneral){
            Database.update(listaColaboradores);
        }

        Test.stopTest();

        PermissionSet ps = [SELECT id FROM PermissionSet WHERE PermissionSet.Name = 'SPV_AdministradorGrupos'];
        List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND (AssigneeId =: colaborador.CC_Usuario__c OR AssigneeId =: colaborador2.CC_Usuario__c)];   

        Assert.areNotEqual(null, psa, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
    }

    @IsTest
    public static void eliminarColaboradorTest(){
        User usuarioGeneral = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        
        List<CC_Grupo_Colaborador_Contact__c> colaboradores = [SELECT Id, SAC_Administrador__c, CC_Usuario__c FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: usuarioGeneral.Id ];

        PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_General'];
        PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
        permiSetAssiAdmin.AssigneeId = usuarioGeneral.Id;
        permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
        Database.insert(permiSetAssiAdmin);
          
        Test.startTest();

        System.runAs(usuarioGeneral){
            Database.delete(colaboradores);

            Test.stopTest();
            PermissionSet ps = [SELECT id FROM PermissionSet WHERE PermissionSet.Name = 'SPV_Gestor'];
            List<PermissionSetAssignment> psa = [SELECT Id, AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSetId =: ps.id AND AssigneeId =: colaboradores[0].CC_Usuario__c];

            Assert.areNotEqual(null, psa, 'El procesamiento a la hora de insertar el usuario en el grupo colaborador no ha funcionado.');
        }
    } 
}