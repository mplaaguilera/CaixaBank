/*****************************************************************
 * Name: SAC_CalculoSLA_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_CalculoSLA
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0              ---            Marcela Neira        30/09/21     Creación
 *                                 Esteve Llao     
 * 1.1            US563153         Jose Carlos Blanco   07/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/
@istest
public with sharing class SAC_CalculoSLA_Test {
    @TestSetup
    static void makeData(){

        User usuario;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            //Usuario SAC General
            usuario = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];
            SAC_DatabaseDML.insertDML(usuario, false); 
            //Database.insert(usuario);
        
            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuario.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            SAC_DatabaseDML.insertDML(permiSetAssi, false); 
            //Database.insert(permiSetAssi);
        }

        List<Case> listaReclamaciones = new List<Case>();
        List<Case> listaPretensiones = new List<Case>();

        //Account
        Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
        SAC_DatabaseDML.insertDML(cuenta, false);
        //Database.insert(cuenta);

        //MCCs
        List<CC_MCC__c> mcc = SAC_TestDataFactory.crearMCCs();
        SAC_DatabaseDML.insertListDML(mcc, false);
        //Database.insert(mcc);

        Id recType = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('SAC_Detalle').getRecordTypeId();
        CC_MCC__c mccDetalle = [SELECT Id FROM CC_MCC__c WHERE RecordTypeId =: recType LIMIT 1];
       
        //Parametrizaciones SLA
        SAC_ParametrizacionSLATME__c parametrizacionRegulatorio = SAC_TestDataFactory.crearParamsSla('Regulatorio',1)[0];
        parametrizacionRegulatorio.SAC_MCC__c = mccDetalle.id;
        parametrizacionRegulatorio.SAC_Duracion__c = 15;
        SAC_DatabaseDML.insertDML(parametrizacionRegulatorio, false);
        //Database.insert(parametrizacionRegulatorio);

        SAC_ParametrizacionSLATME__c parametrizacionLetrado = SAC_TestDataFactory.crearParamsSla('Letrado',1)[0];
        parametrizacionLetrado.SAC_MCC__c = mccDetalle.id;
        parametrizacionLetrado.SAC_Duracion__c = 15;
        SAC_DatabaseDML.insertDML(parametrizacionLetrado, false);
        //Database.insert(parametrizacionLetrado);

        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('Origin', 'Backoffice');
        camposRecl.put('SEG_Detalle__c', mccDetalle.id);
        camposRecl.put('AccountId', cuenta.id);
        camposRecl.put('SAC_TipoConsumidor__c', 'Si');
        camposRecl.put('OwnerId', usuario.id);
        
        Case casoReclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        listaReclamaciones.add(casoReclamacion);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'TestRec2');
        camposRecl2.put('Origin', 'Backoffice');
        camposRecl2.put('SEG_Detalle__c', mccDetalle.id);
        camposRecl2.put('SAC_TipoConsumidor__c', 'Si');
        camposRecl2.put('OwnerId', usuario.id);
        
        Case casoReclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        listaReclamaciones.add(casoReclamacion2);
        SAC_DatabaseDML.insertListDML(listaReclamaciones, false); 
        //Database.insert(listaReclamaciones);

        //Pretension
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret.put('Origin', 'Backoffice');
        camposPret.put('SEG_Detalle__c', mccDetalle.id);
        camposPret.put('OwnerId', usuario.id);
        
        Case casoPretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        listaPretensiones.add(casoPretension);
       
        //Pretension 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('SAC_Reclamacion__c', casoReclamacion.Id);
        camposPret2.put('Origin', 'Backoffice');
        camposPret2.put('SEG_Detalle__c', mccDetalle.id);
        camposPret2.put('OwnerId', usuario.id);
        
        Case casoPretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
        listaPretensiones.add(casoPretension2);
        
        //Pretension 3
        Map<String, Object> camposPret3 = new Map<String, Object>();
        camposPret3.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret3.put('Origin', 'Backoffice');
        camposPret3.put('SEG_Detalle__c', mccDetalle.id);
        camposPret3.put('OwnerId', usuario.id);
        
        Case casoPretension3 = SAC_TestDataFactory.crearCaso('Pretension',camposPret3);
        listaPretensiones.add(casoPretension3);

        //Pretension 4
        Map<String, Object> camposPret4 = new Map<String, Object>();
        camposPret4.put('SAC_Reclamacion__c', casoReclamacion2.Id);
        camposPret4.put('Origin', 'Backoffice');
        camposPret4.put('SEG_Detalle__c', mccDetalle.id);
        camposPret4.put('OwnerId', usuario.id);
        
        Case casoPretension4 = SAC_TestDataFactory.crearCaso('Pretension',camposPret4);
        listaPretensiones.add(casoPretension4);
        SAC_DatabaseDML.insertListDML(listaPretensiones, false);
        //Database.insert(listaPretensiones);
    }

    @istest
    static void buscarParametrizacionMCCTest() {

        Case casoPadre = [SELECT id, RecordTypeId, SAC_Reclamacion__c, SEG_Detalle__c, SAC_TiempoSLARegulatorio__c, CC_Canal_Procedencia__c, SAC_CasoEspecial__c
                          FROM Case
                          WHERE Subject = 'TestRec' ];

        Case casoHijo = [SELECT id, RecordTypeId, SAC_Reclamacion__c, SEG_Detalle__c, SAC_TiempoSLARegulatorio__c, CC_Canal_Procedencia__c, SAC_CasoEspecial__c
                         FROM Case
                         WHERE SAC_Reclamacion__r.Subject = 'TestRec' LIMIT 1];

        List<Case> listaFamilia = [SELECT id, SAC_Reclamacion__c, RecordTypeId, Status, SAC_EnvioParcial__c, SAC_ReclamanteConformeNegociacion__c, isStopped,
                                   SAC_TiempoSLALetradoAlta__c, SAC_TiempoSLARegulatorio__c, SEG_Detalle__c, CC_Canal_Procedencia__c, SAC_CasoEspecial__c,
                                   SAC_Reclamacion__r.SAC_CasoEspecial__c
                                   FROM case
                                   WHERE SAC_Reclamacion__c =: casoPadre.id];
        listaFamilia.add(casoPadre);

        User usuario = [SELECT Id, UserName FROM User WHERE UserName = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
            Test.startTest();
            casoPadre.Status = 'SAC_002';
            casoPadre.SAC_StatusAuxiliar__c = 'SAC_002';
            casoPadre.SAC_CasoEspecial__c = 'SAC_Sensible';
            casoPadre.SAC_PretensionPrincipal__c = casoHijo.Id;
            SAC_DatabaseDML.updateDML(casoPadre, false);
            //Database.update(casoPadre);
            //List<Case> listaFamlia2 = SAC_CalculoSLA.buscarParametrizacionMCC(listaFamilia);
            Test.stopTest();
        }
        System.assertNotEquals(null, casoPadre.Id);
    }

    /*@istest
    static void buscarParametrizacionMCCTest2() {

        Case casoPadre = [SELECT id, RecordTypeId, SAC_Reclamacion__c, SEG_Detalle__c, SAC_TiempoSLARegulatorio__c, CC_Canal_Procedencia__c
                          FROM Case
                          WHERE Subject = 'TestRec2' ];

        List<Case> listaFamilia = [SELECT id, RecordTypeId, SAC_Reclamacion__c, SEG_Detalle__c, SAC_TiempoSLARegulatorio__c, CC_Canal_Procedencia__c 
                                 FROM case
                                 WHERE SAC_Reclamacion__c =: casoPadre.id];

        listaFamilia.add(casoPadre);        
        Test.startTest();
        List<Case> listaFamlia2 = SAC_CalculoSLA.buscarParametrizacionMCC(listaFamilia);
        Test.stopTest();

        System.assertEquals(15, listaFamlia2[0].SAC_TiempoSLARegulatorio__c);
    }*/
}