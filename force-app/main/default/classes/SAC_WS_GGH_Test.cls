/*****************************************************************
 * Name: SAC_WS_GGH_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase test de la clase apex SAC_WS_GGH
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0              ---            Luis Mesa            02/06/22     Creación
 * 1.1              ---            Jose Carlos Blanco   06/09/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@IsTest
public with sharing class SAC_WS_GGH_Test {
    
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            SAC_DatabaseDML.insertDML(usuarioGeneral, false);        
            //Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false);  
            //Database.insert(permiSetAssi);
        }

        //Reclamacion
        Map<String, Object> camposRecl1 = new Map<String, Object>();
        camposRecl1.put('Subject', 'testRec');
        camposRecl1.put('Origin', 'SAC_Manual');
        camposRecl1.put('Status', 'SAC_001');
        camposRecl1.put('SAC_StatusAuxiliar__c', 'SAC_001');

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl1);
        SAC_DatabaseDML.insertDML(reclamacion, false);  
        //Database.insert(reclamacion);

        //Pretension
        Map<String, Object> camposPret1 = new Map<String, Object>();
        camposPret1.put('SuppliedCompany', 'testPret');
        camposPret1.put('Status', reclamacion.Status);
        camposPret1.put('SAC_StatusAuxiliar__c', reclamacion.Status);
        camposPret1.put('SAC_Reclamacion__c', reclamacion.id);

        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret1);
        SAC_DatabaseDML.insertDML(pretension, false);  
        //Database.insert(pretension);

        //Tarea
        SAC_Accion__c tarea = SAC_TestDataFactory.crearTareas(1,pretension,true)[0];
        SAC_DatabaseDML.insertDML(tarea, false);  
        //Database.insert(tarea);
        tarea.SAC_Estado__c = 'SAC_PendienteAsignar';
        SAC_DatabaseDML.updateDML(tarea, false);  
        //Database.update(tarea);
    }

    @isTest
    public static void comprobarImportes(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '0';
        input.estadoNotaria = '0';
        input.estadoGestoria = '0';
        input.estadoTasacion = '0';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, true, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes2(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];
        tarea.SAC_Estado__c = 'SAC_EnGestion';
        SAC_DatabaseDML.updateDML(tarea, false);  
        //Database.update(tarea);

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = 'pretension.Id';
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '0';
        input.estadoNotaria = '0';
        input.estadoGestoria = '0';
        input.estadoTasacion = '0';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, false, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes4(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];
        tarea.SAC_Estado__c = 'SAC_EnGestion';
        SAC_DatabaseDML.updateDML(tarea, false);  
        //Database.update(tarea);

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = 'tarea.Id';
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '0';
        input.estadoNotaria = '0';
        input.estadoGestoria = '0';
        input.estadoTasacion = '0';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, false, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes3(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '2';
        input.estadoNotaria = '2';
        input.estadoGestoria = '2';
        input.estadoTasacion = '2';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, true, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes5(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '24';
        input.estadoNotaria = '24';
        input.estadoGestoria = '24';
        input.estadoTasacion = '24';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, true, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes6(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '52';
        input.estadoNotaria = '52';
        input.estadoGestoria = '52';
        input.estadoTasacion = '52';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, true, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes7(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '53';
        input.estadoNotaria = '53';
        input.estadoGestoria = '53';
        input.estadoTasacion = '53';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, true, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes8(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '54';
        input.estadoNotaria = '54';
        input.estadoGestoria = '54';
        input.estadoTasacion = '54';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, true, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes9(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '57';
        input.estadoNotaria = '57';
        input.estadoGestoria = '57';
        input.estadoTasacion = '57';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, true, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes10(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '80';
        input.estadoNotaria = '80';
        input.estadoGestoria = '80';
        input.estadoTasacion = '80';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, true, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes11(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idPretension = pretension.Id;
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '81';
        input.estadoNotaria = '81';
        input.estadoGestoria = '81';
        input.estadoTasacion = '81';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, true, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }

    @isTest
    public static void comprobarImportes12(){
        Case pretension = [SELECT Id FROM Case WHERE SuppliedCompany = 'testPret' LIMIT 1];
        SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Pretension__c =: pretension.id LIMIT 1];
        tarea.SAC_Estado__c = 'SAC_EnGestion';
        SAC_DatabaseDML.updateDML(tarea, false);  
        //Database.update(tarea);

        SAC_WS_GGH.SAC_WS_GGH_Input input = new SAC_WS_GGH.SAC_WS_GGH_Input();
        input.idTarea = tarea.Id;
        input.numContrato = '';
        input.cuentaAbono = '';
        input.impAbonGestoria = 0;
        input.impAbonNotaria = 0;
        input.impAbonRegistro = 0;
        input.impAbonTasacion = 0;
        input.estadoRegistro = '81';
        input.estadoNotaria = '81';
        input.estadoGestoria = '81';
        input.estadoTasacion = '81';
        input.fechaAbono = '';
        input.observaciones = '';

        User usuario = [SELECT Id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
            Test.startTest();
            SAC_WS_GGH.SAC_WS_GGH_Output result = SAC_WS_GGH.comprobarImportes(input);
            System.assertEquals(result.bResultadoOk, false, 'El servicio de GGH ha fallado.');
            Test.stopTest();
        }
    }
}