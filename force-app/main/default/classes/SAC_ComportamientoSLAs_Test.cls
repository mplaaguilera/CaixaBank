/*****************************************************************
 * Name: SAC_ComportamientoSLAs_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_ComportamientoSLAs
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US219261         Carlos Solis         19/05/21     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	29/12/22	 Modificación (agregada assertion)
 * 1.2            US563153         Jose Carlos Blanco   29/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@isTest
public with sharing class SAC_ComportamientoSLAs_Test {
    @TestSetup
    static void makeData(){

        User usuarioGeneral;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];     
            Database.insert(usuarioGeneral);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGeneral.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        Database.insert(cuenta);

        Entitlement entitle = SAC_TestDataFactory.crearEntitlement(cuenta.id);
        Database.insert(entitle);

        //Reclamacion 1
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Test1Rec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('OwnerId', usuarioGeneral.id);
        camposRecl.put('SAC_ReclamanteConformeNegociacion__c', false);
        camposRecl.put('IsStopped', false);
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');

        Case caso1 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'Test2Rec');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('Status', 'SAC_003');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_003');
        camposRecl2.put('OwnerId', usuarioGeneral.id);
        camposRecl2.put('SAC_ReclamanteConformeNegociacion__c', false);
        camposRecl2.put('IsStopped', false);

        Case caso2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);

        //Reclamacion 3
        Map<String, Object> camposRecl3 = new Map<String, Object>();
        camposRecl3.put('Subject', 'Test3Rec');
        camposRecl3.put('Origin', 'Backoffice');
        camposRecl3.put('Status', 'SAC_001');
        camposRecl3.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl3.put('OwnerId', usuarioGeneral.id);
        camposRecl3.put('SAC_ReclamanteConformeNegociacion__c', false);
        camposRecl3.put('IsStopped', false);

        Case caso3 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl3);

        //Insertamos reclamaciones
        List<Case> listaReclamaciones = new List<Case>();
        listaReclamaciones.add(caso1);
        listaReclamaciones.add(caso2);
        listaReclamaciones.add(caso3);

        Test.startTest();
        Database.insert(listaReclamaciones);
		Test.stopTest();

        //Pretension 1
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'Pretension');
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('SuppliedCompany', 'prueba para el filtro');
        camposPret.put('Status', 'SAC_001');
        camposPret.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret.put('OwnerId', usuarioGeneral.id);
        camposPret.put('SAC_ReclamanteConformeNegociacion__c', false);
        camposPret.put('IsStopped', false);
        camposPret.put('SAC_TipoConsumidor__c', 'Si');
        camposPret.put('SAC_Reclamacion__c', caso1.id);

        Case pretensionHija1 = SAC_TestDataFactory.crearCaso('Pretension',camposPret);

        //Pretension 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('Subject', 'Pretension2');
        camposPret2.put('Origin', 'Backoffice');
        camposPret2.put('SuppliedCompany', 'prueba para el filtro 2');
        camposPret2.put('Status', 'SAC_001');
        camposPret2.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret2.put('OwnerId', usuarioGeneral.id);
        camposPret2.put('SAC_ReclamanteConformeNegociacion__c', false);
        camposPret2.put('IsStopped', false);
        camposPret2.put('SAC_TipoConsumidor__c', 'Si');
        camposPret2.put('SAC_Reclamacion__c', caso1.id);

        Case pretensionHija2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);

        //Pretension 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('Subject', 'Pretension3');
        camposPret3.put('Origin', 'Backoffice');
        camposPret3.put('SuppliedCompany', 'prueba para el filtro 3');
        camposPret3.put('Status', 'SAC_001');
        camposPret3.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposPret3.put('OwnerId', usuarioGeneral.id);
        camposPret3.put('SAC_ReclamanteConformeNegociacion__c', false);
        camposPret3.put('IsStopped', false);
        camposPret3.put('SAC_TipoConsumidor__c', 'Si');
        camposPret3.put('SAC_Reclamacion__c', caso3.id);

        Case pretensionHija3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret3);

        ////Insertamos pretensiones       
        List<Case> listaCasos = new List<Case>();
        listaCasos.add(pretensionHija1);
        listaCasos.add(pretensionHija2);
        listaCasos.add(pretensionHija3);
        Database.insert(listaCasos);
    }
    
    // @isTest
    // static void pausarSLAsTest() {
    //     User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
    //     Case caso = [select id, subject, status, SAC_ReclamanteConformeNegociacion__c, IsStopped from case where SuppliedCompany = 'prueba para el filtro' limit 1];
    //     caso.Status = 'SAC_006';
    //     caso.SAC_StatusAuxiliar__c = caso.Status;
        
    //     System.runAs(usuario) {
    //         Test.startTest();
    //         Database.update(caso);
    //         Test.stopTest();
    //     }
        
    //     Case casoActualizado = [select id, subject, status, SAC_ReclamanteConformeNegociacion__c, IsStopped from case where  SuppliedCompany = 'prueba para el filtro'  limit 1];
        
    //     System.assertEquals(true, casoActualizado.isStopped, 'No se ha podido pausar la SLA');
    // }

    @isTest
    static void completarSLATest(){
        List <Entitlement> entls = [select id, SlaProcess.name from Entitlement where SlaProcess.name = 'SAC_Process' limit 1];
        Case caso = [SELECT id, subject, status, SAC_ReclamanteConformeNegociacion__c, IsStopped FROM Case WHERE Subject = 'Test2Rec' LIMIT 1];
        caso.Status = 'SAC_007';
        caso.SAC_StatusAuxiliar__c = caso.Status;
        
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            Database.update(caso);
            Test.stopTest();
        }
        CaseMilestone caseMilestoneActualizada = [select id, CompletionDate, caseId from caseMilestone WHERE caseId =: caso.Id limit 1];
        System.debug('caseMilestoneActualizada '  + caseMilestoneActualizada);
        System.assertNotEquals(null, caseMilestoneActualizada.CompletionDate, 'No se ha podido completar la SLA');
    }

    @istest
    static void actualizarFechaTest(){
        Case caso = [SELECT id, subject, status, SAC_ReclamanteConformeNegociacion__c, IsStopped, SAC_FechaRecepcion__c FROM Case WHERE Subject = 'Test1Rec' LIMIT 1];

        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            caso.SAC_FechaRecepcion__c = System.now().AddDays(-1);
            Database.update(caso);
            Test.stopTest();
        }
        Case casoResult = [select Id, SAC_FechaRecepcion__c from case where  SuppliedCompany = 'prueba para el filtro 2'];
        System.assertEquals(casoResult.SAC_FechaRecepcion__c, caso.SAC_FechaRecepcion__c, 'No se ha modificado la fecha de la pretension');
    }

    @istest
    static void updateVacioPretRecTest(){
        List<Case> listNewCasos = [SELECT Id, RecordTypeId, SAC_Reclamacion__c FROM Case WHERE SuppliedCompany = 'prueba para el filtro'];
        Map<Id, Case> newMap = new Map<Id, Case>();
        newMap.put(listNewCasos[0].Id, listNewCasos[0]);

        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            SAC_ComportamientoSLAs.updateVacioPretRec(listNewCasos, newMap);
            Test.stopTest();
        }
        System.assertNotEquals(listNewCasos.size(), 0, 'No se ha recuperado nada');
    }

   /* @istest
    static void actualizarFechaRecTest(){
        Case caso = [SELECT id, subject, status, SAC_ReclamanteConformeNegociacion__c, IsStopped FROM Case WHERE Subject = 'Test3Rec' LIMIT 1];
        Datetime fechaReclamacion = [select SAC_FechaRecepcion__c from case where  Subject = 'Test3Rec'].SAC_FechaRecepcion__c;
        
        caso.SAC_FechaRecepcion__c = System.now().AddDays(-1);
        
        Test.startTest();
        update caso;
        Datetime fechaReclamacionActualizada = [select SAC_FechaRecepcion__c from case where  SuppliedCompany = 'prueba para el filtro'].SAC_FechaRecepcion__c;

        
        Test.stopTest();

       
        system.assertNotEquals(fechaReclamacionActualizada, fechaReclamacion, 'No se ha modificado la fecha de la pretension');
    }*/

    @istest
    static void cerrarMilestoneLetradoAltaBajaTest(){
        Case caso = [SELECT id, subject, status, SAC_ReclamanteConformeNegociacion__c, IsStopped FROM Case WHERE SuppliedCompany = 'prueba para el filtro 3' LIMIT 1];
        Case casoComp = [SELECT id, subject, status, SAC_ReclamanteConformeNegociacion__c, IsStopped FROM Case WHERE SuppliedCompany = 'prueba para el filtro 3' LIMIT 1];
        caso.Status = 'SAC_009';
        caso.SAC_StatusAuxiliar__c = 'SAC_009';
        
        User usuario = [SELECT id FROM User WHERE username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        System.runAs(usuario){
            Test.startTest();
            Database.update(caso);
            Test.stopTest();
        }
        System.assertNotEquals(casoComp, caso);
    }  
}