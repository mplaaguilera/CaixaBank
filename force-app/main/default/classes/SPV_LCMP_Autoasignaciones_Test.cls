/*****************************************************************
 * Name: SPV_LCMP_Autoasignaciones_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Test de la clase SPV_LCMP_Autoasignaciones
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US912956      Raúl Santos    13/05/24        Creación
****************************************************************/ 

@isTest
public with sharing class SPV_LCMP_Autoasignaciones_Test {

    private static Set<String> objetos = new Set<String>{'Case', 'CC_Grupo_Colaborador__c', 'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEGESTORES = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoGestor').getRecordTypeId();
    private static final Id RECTYPELETRADOS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoLetrado').getRecordTypeId();
    private static final Id RECTYPETAREAS = mapRTsObjects.get('CC_Grupo_Colaborador__c').get('SPV_GrupoDeTareas').getRecordTypeId();
    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();
   
    @TestSetup
    static void makeData(){
        Test.startTest();
        User usuarioAdmin = SPV_TestDataFactory.crearUsuarioAdministrador(1)[0];
        Database.insert(usuarioAdmin);

        User usuarioGeneral;
        System.runAs(usuarioAdmin){
            usuarioGeneral = SPV_TestDataFactory.crearUsuarioSPVGeneral(1)[0];
            Database.insert(usuarioGeneral);

            PermissionSet permiSetAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'SPV_Administrador'];
            PermissionSetAssignment permiSetAssiAdmin = new PermissionSetAssignment();
            permiSetAssiAdmin.AssigneeId = usuarioAdmin.Id;
            permiSetAssiAdmin.PermissionSetId = permiSetAdmin.Id;
            Database.insert(permiSetAssiAdmin);
        }
        Test.stopTest();
        
        Group colaPteAsignar = [SELECT id FROM Group WHERE DeveloperName = 'SPV_PendienteAsignar'];

        //Grupos colaboradores
        List<CC_Grupo_Colaborador__c> gruposColaboradores = new List <CC_Grupo_Colaborador__c>();
        CC_Grupo_Colaborador__c grupoGestor = SPV_TestDataFactory.crearGrupoColaborador('GrupoGestor',1)[0];
        grupoGestor.SAC_MaximoCasosDiarios__c = 5;
        grupoGestor.SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposColaboradores.add(grupoGestor);

        CC_Grupo_Colaborador__c grupoResponsable = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',1)[0];
        grupoResponsable.SAC_Email__c = 'testSPV2tareas@testemail.com.invalid';
        grupoResponsable.SAC_PermiteEscalado__c = true;
        grupoResponsable.SAC_PermiteTareas__c = true;
        grupoResponsable.SAC_DeveloperName__c = 'SPV_AJ';
        gruposColaboradores.add(grupoResponsable);
        Database.insert(gruposColaboradores);

        //Colaboradores
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = new List<CC_Grupo_Colaborador_Contact__c>();
        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact1 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupoGestor.Id);
        grupoColaboradorContact1.SAC_Administrador__c = true;
        listaColaboradores.add(grupoColaboradorContact1);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact2 = SPV_TestDataFactory.crearColaboradorContact(usuarioAdmin.Id, grupoResponsable.Id);
        grupoColaboradorContact2.SAC_Administrador__c = false;
        listaColaboradores.add(grupoColaboradorContact2);

        System.runAs(usuarioAdmin){
            Database.insert(listaColaboradores);
        }

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec PteAsignar');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('SEG_Grupo__c', grupoGestor.Id);
        camposRecl.put('OwnerId', colaPteAsignar.Id);

        Case reclamacion = SPV_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        Database.insert(reclamacion);

        //Escalado
        Map<String, Object> camposEsc = new Map<String, Object>();
        camposEsc.put('SAC_CasoEscalado__c', reclamacion.Id);
        camposEsc.put('SAC_GrupoColaborador__c', grupoResponsable.Id);
        camposEsc.put('OwnerId', colaPteAsignar.Id);
        camposEsc.put('SAC_Titulo__c', 'propuesta test escalado');
        camposEsc.put('SAC_Propuesta__c', 'propuesta test');
        camposEsc.put('SAC_Estado__c', 'SAC_PendienteRespuesta');

        SAC_Interaccion__c escalado = SPV_TestDataFactory.crearInteraccion('Escalado', camposEsc);
        Database.insert(escalado);

        //Tareas
        List<SAC_Accion__c> tareas = new List<SAC_Accion__c>();
        List<SAC_Accion__c> listaDeTareasOtras = SPV_TestDataFactory.crearTareas(1,reclamacion,null);
        
        //Tarea 1
        listaDeTareasOtras[0].SAC_Observaciones__c = 'tarea1';
        listaDeTareasOtras[0].SAC_Estado__c = 'SAC_PendienteAsignar';
        listaDeTareasOtras[0].SAC_PlazoMaximo__c = 0;
        listaDeTareasOtras[0].SAC_Prorroga__c = 5;
        listaDeTareasOtras[0].OwnerId = colaPteAsignar.id;
        listaDeTareasOtras[0].SAC_EquipoResponsable__c = grupoResponsable.Id;
        listaDeTareasOtras[0].SAC_Reclamacion__c = reclamacion.Id;

        tareas.addAll(listaDeTareasOtras);
        Database.insert(tareas);

        SAC_MaestroTemas__c maestro = new SAC_MaestroTemas__c();
        maestro.RecordTypeId = RECTYPETIPOADJUNTOS;
        maestro.SAC_DeveloperName__c = 'SPV_DocumentacionOrganismo';
        Database.insert(maestro);
    }

    @isTest
    static void autoasignarPropiedadCasoTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        Case caso = [SELECT id, OwnerId, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec PteAsignar' LIMIT 1];
        
        Test.startTest();

        System.runAs(usuario) {
            SPV_LCMP_Autoasignaciones.autoasignarPropiedad('Case', caso.Id, usuario.Id);
        }
        
        Case casoActualizado = [SELECT id, OwnerId, SEG_Grupo__c FROM Case WHERE Subject = 'TestRec PteAsignar' LIMIT 1];

        Test.stopTest();
        Assert.areEqual(usuario.Id, casoActualizado.ownerId, 'No se ha podido autoasignar la propiedad del caso');
    }

    @isTest
    static void autoasignarInteraccionTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Interaccion__c escalado = [SELECT Id FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test escalado' LIMIT 1];
        
        Test.startTest();

        System.runAs(usuario) {
            SPV_LCMP_Autoasignaciones.autoasignarPropiedad('SAC_Interaccion__c', escalado.Id, usuario.Id);
        }
        
        SAC_Interaccion__c escaladoAct = [SELECT Id, OwnerId FROM SAC_Interaccion__c WHERE SAC_Titulo__c = 'propuesta test escalado' LIMIT 1];

        Test.stopTest();
        Assert.areEqual(usuario.Id, escaladoAct.ownerId, 'No se ha podido autoasignar la propiedad del escalado');
    }

    @isTest
    static void autoasignarAccionTest() {
       
        User usuario = [SELECT Id FROM User WHERE Username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];
        SAC_Accion__c accion = [SELECT Id FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tarea1' LIMIT 1];
        
        Test.startTest();

        System.runAs(usuario) {
            SPV_LCMP_Autoasignaciones.autoasignarPropiedad('SAC_Accion__c', accion.Id, usuario.Id);
        }
        
        SAC_Accion__c accionAct = [SELECT Id, OwnerId FROM SAC_Accion__c WHERE SAC_Observaciones__c = 'tarea1' LIMIT 1];

        Test.stopTest();
        Assert.areEqual(usuario.Id, accionAct.ownerId, 'No se ha podido autoasignar la propiedad de la tarea');
    }
}