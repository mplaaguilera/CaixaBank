/*****************************************************************
 * Name: SAC_LCMP_infoSla_Test
 * Copyright © 2021  CaixaBank
 *  
 * Proposito: Testear la clase SAC_LCMP_infoSla
 *  
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0                     		   Daniel Benito        03/11/21     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	23/12/22	 Modificación (agregada assertion)
 * 1.2            US593664         Jose Carlos Blanco  	10/05/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/

@isTest
public with sharing class  SAC_LCMP_infoSla_Test {
    
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


        List<Case> reclamaciones = new List<Case>();
        List<Case> pretensiones = new List<Case>();
        
	    //RECLAMACION
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'Reclamacion test');
        camposRecl.put('Status', 'SAC_006');
        camposRecl.put('IsStopped', true);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
        reclamaciones.add(reclamacion);
        
        //RECLAMACION 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'Reclamacion2 test');
        camposRecl2.put('Status', 'SAC_007');
        camposRecl2.put('IsStopped', true);
        camposRecl2.put('SAC_ReclamanteConformeNegociacion__c', true);

        Case reclamacion2 = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl2);
        reclamaciones.add(reclamacion2);
        Database.insert(reclamaciones);
        
        //PRETENSION
        Map<String, Object> camposPret = new Map<String, Object>();
        camposPret.put('Subject', 'Pretension test');
        camposPret.put('SAC_Reclamacion__c', reclamacion.id);
        camposPret.put('Status', 'SAC_001');

        Case pretension = SAC_TestDataFactory.crearCaso('Pretension',camposPret);
        pretensiones.add(pretension);

        //PRETENSION 2
        Map<String, Object> camposPret2 = new Map<String, Object>();
        camposPret2.put('Subject', 'Pretension2 test');
        camposPret2.put('SAC_Reclamacion__c', reclamacion2.id);
        camposPret2.put('Status', 'SAC_001');

        Case pretension2 = SAC_TestDataFactory.crearCaso('Pretension',camposPret2);
        pretensiones.add(pretension2);
        Database.insert(pretensiones);
        
    }
    
    @istest
    static void cambiarEstado(){
		Case reclamacion = [SELECT Id, Status,IsStopped FROM CASE WHERE Subject = 'Reclamacion test' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario) {
            Test.startTest();
            SAC_LCMP_infoSla.comprobarEstadoPausaPadre(reclamacion.id);
            System.assertEquals('Subsanación en la Reclamación', SAC_LCMP_infoSla.comprobarEstadoPausaPadre(reclamacion.id));
            Test.stopTest();
        }
        
    }
    
    @istest
    static void cambiarEstado2(){
        Case reclamacion = [SELECT Id, Status,IsStopped FROM CASE WHERE Subject = 'Reclamacion2 test' LIMIT 1];
        User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true Limit 1];
        
        System.runAs(usuario) {
            Test.startTest();
            SAC_LCMP_infoSla.comprobarEstadoPausaPadre(reclamacion.id);
            System.assertEquals('Negociación en la Reclamación', SAC_LCMP_infoSla.comprobarEstadoPausaPadre(reclamacion.id));
            Test.stopTest();
        }    
    }
}