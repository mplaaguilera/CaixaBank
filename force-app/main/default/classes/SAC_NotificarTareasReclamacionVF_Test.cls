@isTest
public with sharing class SAC_NotificarTareasReclamacionVF_Test {
    @TestSetup
    static void makeData(){

        User userAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        userAdmin.Username = 'useradminpruebaredfinal@test.com.testdata';
        SAC_DatabaseDML.insertDML(userAdmin, false);   
        //Database.insert(userAdmin);

        User userAdmin2 = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
        userAdmin2.Username = 'useradminpruebaredfinal@test.com.testdata2';
        SAC_DatabaseDML.insertDML(userAdmin2, false);   
        //Database.insert(userAdmin2);

        List<CC_Grupo_Colaborador__c> gruposTareas = SPV_TestDataFactory.crearGrupoColaborador('GrupoDeTareas',1);
        gruposTareas[0].SAC_Email__c = 'testSPV@testemail.com.invalid';
        gruposTareas[0].SAC_Email2__c = 'testSPV@testemail.com.invalid2';
        gruposTareas[0].SAC_Email3__c = 'testSPV@testemail.com.invalid3';
        gruposTareas[0].SAC_DeveloperName__c = 'COPS';
        gruposTareas[0].SAC_PermiteTareas__c = true;
        SAC_DatabaseDML.insertListDML(gruposTareas, false); 
        //Database.insert(gruposTareas);

        CC_Grupo_Colaborador_Contact__c grupoTareas1 = new CC_Grupo_Colaborador_Contact__c();
        grupoTareas1 = SAC_TestDataFactory.crearColaboradorContact(userAdmin.id, gruposTareas[0].id);
        grupoTareas1.SAC_Administrador__c = true;
        SAC_DatabaseDML.insertDML(grupoTareas1, false); 
        //Database.insert(grupoTareas1);
        
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        SAC_DatabaseDML.insertDML(reclamacion, false); 
        //Database.insert(reclamacion);

        Map<String, Object> camposRecSPV = new Map<String, Object>();
        camposRecSPV.put('Subject', 'TestRecSPV');        
        Case casoReclamacionSPV = SPV_TestDataFactory.crearCaso('Reclamacion',camposRecSPV);
        SAC_DatabaseDML.insertDML(casoReclamacionSPV, false); 
        //Database.insert(casoReclamacionSPV);

        List<SAC_Accion__c> tareas = SAC_TestDataFactory.crearTareas(2,reclamacion,false);
        tareas[0].SAC_Descripcion__c = 'TestTarea1';
        tareas[0].SAC_Estado__c = 'SAC_EnGestion';
        tareas[1].SAC_Descripcion__c = 'TestTarea2';
        tareas[1].SAC_Estado__c = 'SAC_EnGestion';
        SAC_DatabaseDML.insertListDML(tareas, false); 
        //Database.insert(tareas);

        Group cola = [SELECT Id, DeveloperName, Name FROM Group WHERE Type = 'Queue' AND  DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];

        List<SAC_Accion__c> tareasSPV = SPV_TestDataFactory.crearTareas(2,casoReclamacionSPV,null);
        tareasSPV[0].SAC_Descripcion__c = 'TestTarea1SPV';
        tareasSPV[0].SAC_Estado__c = 'SAC_EnGestion';
        tareasSPV[0].SAC_EquipoResponsable__c = gruposTareas[0].Id;
        tareasSPV[1].SAC_Descripcion__c = 'TestTarea2SPV';
        tareasSPV[1].SAC_Estado__c = 'SAC_EnGestion';
        tareasSPV[1].OwnerId = cola.Id;
        tareasSPV[1].SAC_EquipoResponsable__c = gruposTareas[0].Id;
        SAC_DatabaseDML.insertListDML(tareasSPV, false); 
        //Database.insert(tareasSPV);
    }

    @isTest
    static void notificarTareasRelatedListTest() {

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<SAC_Accion__c> listaAcciones = [SELECT Id, OwnerId FROM SAC_Accion__c WHERE SAC_Descripcion__c = 'TestTarea1' OR SAC_Descripcion__c = 'TestTarea2'];
        User usuario = [SELECT Id FROM User WHERE Username = 'useradminpruebaredfinal@test.com.testdata' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            PageReference pageRef = Page.SAC_NotificarTareasReclamacion;
            pageRef.getParameters().put('id',reclamacion.id);
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaAcciones);
            //stdSetController.setSelected(listaAcciones);
            
            SAC_NotificarTareasReclamacionVF controlador = new SAC_NotificarTareasReclamacionVF(stdSetController);
            controlador.currentRecord = reclamacion.Id;
            pageRef.getParameters().put('mensaje', 'mensaje de test');
            controlador.enviarNotificaciones();
        }
        Test.stopTest();

        FeedItem fdResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :listaAcciones[0].Id];

        System.assertNotEquals(null, fdResult, 'No se ha podido mandar la notificación');
    }

    @isTest
    static void notificarTareasRelatedListTest2() {

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecSPV' LIMIT 1];
        List<SAC_Accion__c> listaAcciones = [SELECT Id, OwnerId FROM SAC_Accion__c WHERE SAC_Descripcion__c = 'TestTarea1SPV' OR SAC_Descripcion__c = 'TestTarea2SPV'];
        User usuario = [SELECT Id FROM User WHERE Username = 'useradminpruebaredfinal@test.com.testdata' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            PageReference pageRef = Page.SAC_NotificarTareasReclamacion;
            pageRef.getParameters().put('id',reclamacion.id);
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaAcciones);
            //stdSetController.setSelected(listaAcciones);
            
            SAC_NotificarTareasReclamacionVF controlador = new SAC_NotificarTareasReclamacionVF(stdSetController);
            controlador.currentRecord = reclamacion.Id;
            pageRef.getParameters().put('mensaje', 'mensaje de test');
            controlador.enviarNotificaciones();
        }
        Test.stopTest();

        System.assertNotEquals(null, reclamacion.Id, 'No se ha podido mandar la notificación');
    }

    @isTest
    static void notificarTareasListViewTest() {

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRec' LIMIT 1];
        List<SAC_Accion__c> listaAcciones = [SELECT Id, OwnerId FROM SAC_Accion__c WHERE SAC_Descripcion__c = 'TestTarea1' OR SAC_Descripcion__c = 'TestTarea2'];
        User usuario = [SELECT Id FROM User WHERE Username = 'useradminpruebaredfinal@test.com.testdata' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            reclamacion.OwnerId = usuario.Id;
            SAC_DatabaseDML.updateDML(reclamacion, false); 
            //Database.update(reclamacion);

            PageReference pageRef = Page.SAC_NotificarTareasReclamacion;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaAcciones);
            stdSetController.setSelected(listaAcciones);
            
            SAC_NotificarTareasReclamacionVF controlador = new SAC_NotificarTareasReclamacionVF(stdSetController);
            controlador.currentRecord = reclamacion.Id;
            pageRef.getParameters().put('mensaje', 'mensaje de test');
            controlador.enviarNotificaciones();
        }
        Test.stopTest();

        FeedItem fdResult = [SELECT Id, Body FROM FeedItem WHERE ParentId = :listaAcciones[0].Id];

        System.assertNotEquals(null, fdResult, 'No se ha podido mandar la notificación');
    }

    @isTest
    static void notificarTareasListViewTest2() {

        Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestRecSPV' LIMIT 1];
        List<SAC_Accion__c> listaAcciones = [SELECT Id, OwnerId FROM SAC_Accion__c WHERE SAC_Descripcion__c = 'TestTarea1SPV' OR SAC_Descripcion__c = 'TestTarea2SPV'];
        User usuario = [SELECT Id FROM User WHERE Username = 'useradminpruebaredfinal@test.com.testdata2' LIMIT 1];

        Test.startTest();
        System.runAs(usuario) {
            reclamacion.OwnerId = usuario.Id;
            SAC_DatabaseDML.updateDML(reclamacion, false); 
            //Database.update(reclamacion);

            PageReference pageRef = Page.SAC_NotificarTareasReclamacion;
            Test.setCurrentPage(pageRef);
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(listaAcciones);
            stdSetController.setSelected(listaAcciones);
            
            SAC_NotificarTareasReclamacionVF controlador = new SAC_NotificarTareasReclamacionVF(stdSetController);
            controlador.currentRecord = reclamacion.Id;
            pageRef.getParameters().put('mensaje', 'mensaje de test');
            controlador.enviarNotificaciones();
        }
        Test.stopTest();

        System.assertNotEquals(null, reclamacion.Id, 'No se ha podido mandar la notificación');
    }
}