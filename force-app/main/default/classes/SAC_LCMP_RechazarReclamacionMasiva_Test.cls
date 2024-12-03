/*****************************************************************
 * Name: SAC_LCMP_RechazarReclamacionMasiva_Test
 * Copyright © 2021  CaixaBank 
 * 
 * Proposito: Testear la clase SAC_LCMP_RechazarReclamacionMasiva
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            DE71399          Sergio Martín        23/02/2023   Creación
 * 1.1            US643756         Jose Carlos Blanco  	04/07/23     Modificación (test modificada usando el SAC_TestDataFactory) 
*****************************************************************/
@isTest
public with sharing class SAC_LCMP_RechazarReclamacionMasiva_Test {
    @testSetup
    static void setup(){

        User user;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            user = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
            user.LastName = 'Administrator';
            user.Username = 'test@test.com' + System.currentTimeMillis();    
            Database.insert(user);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = user.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        User user2;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            user2 = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];
            user2.LastName = 'COPSAJ';
            user2.Username = 'test@test.com' + System.currentTimeMillis();
            user2.SAC_PerteneceCOPSAJ__c = true;  
            Database.insert(user2);

            PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = user2.Id;
            permiSetAssi.PermissionSetId = permiSet.Id;
            Database.insert(permiSetAssi);
        }

        CC_Grupo_Colaborador__c grupoColaborador = SAC_TestDataFactory.crearGrupoColaborador('GrupoProveedor', 1)[0];
        grupoColaborador.SAC_PorcentajeAsignacion__c = 100;
        grupoColaborador.SAC_MaximoCasosDiarios__c = 15;
        Database.insert(grupoColaborador);

        CC_Grupo_Colaborador_Contact__c grupoColaboradorContact = SAC_TestDataFactory.crearColaboradorContact(user.id, grupoColaborador.id);
        grupoColaboradorContact.SAC_Administrador__c = true;
        Database.insert(grupoColaboradorContact);
        
        List<Case> casesToInsert = new List<Case>();
        //Reclamacion
        Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'testRec1');
        camposRecl.put('Status', 'SAC_001');
        camposRecl.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposRecl.put('SEG_Grupo__c', grupoColaborador.Id);
        
        Case casoRechazo = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl);
        casesToInsert.add(casoRechazo);

        //Reclamacion 2
        Map<String, Object> camposRecl2 = new Map<String, Object>();
        camposRecl2.put('Subject', 'testfallo');
        camposRecl2.put('Status', 'SAC_003');
        camposRecl2.put('SAC_StatusAuxiliar__c', 'SAC_003');
        camposRecl2.put('SEG_Grupo__c', grupoColaborador.Id);
        camposRecl2.put('CC_Rechazar_Reabrir_Caso__c', true);
        
        Case casoFalloRechazo = SAC_TestDataFactory.crearCaso('Reclamacion', camposRecl2);
        casesToInsert.add(casoFalloRechazo);
        
        // Consulta COPS
        Map<String, Object> camposConsulta = new Map<String, Object>();
        camposConsulta.put('Subject', 'testConsulta');
        camposConsulta.put('Status', 'SAC_003');
        camposConsulta.put('SAC_StatusAuxiliar__c', 'SAC_001');
        camposConsulta.put('SEG_Grupo__c', grupoColaborador.Id);
        
        Case consulta = SAC_TestDataFactory.crearCaso('Consulta', camposConsulta);
        casesToInsert.add(consulta);
		
        insert casesToInsert;
    }

	@isTest
	private static void rechazarCasosTest(){
		User usr = [SELECT id FROM User WHERE LastName = 'Administrator' AND IsActive = true LIMIT 1];
        List<Case> lstCases =  [SELECT id FROM Case WHERE Subject LIKE 'testRec%' LIMIT 2];
		
        List<string> lstId = new List<string>();

		for(Case caso : lstCases){
			lstId.add(caso.id);
		}

        String result;
        System.runAs(usr) {
		    result = SAC_LCMP_RechazarReclamacionMasiva.rechazarCasos('Otros', string.join(lstId, ','), 'Test');
        }
		System.assertEquals(result, 'OK', 'Reclamaciones rechazadas correctamente');
	}

    @isTest
	private static void rechazarCasosCOPSAJTest(){
		User usr = [SELECT id FROM User WHERE LastName = 'COPSAJ' AND IsActive = true LIMIT 1];
        List<Case> lstCases =  [SELECT id FROM Case WHERE Subject LIKE 'testRec%' LIMIT 2];
		
        List<string> lstId = new List<string>();

		for(Case caso : lstCases){
			lstId.add(caso.id);
		}
		
        String result;
        System.runAs(usr) {
		    result = SAC_LCMP_RechazarReclamacionMasiva.rechazarCasos('Otros', string.join(lstId, ','), 'Test');
        }
		System.assertEquals(result, 'OK', 'Reclamaciones rechazadas correctamente');
	}


    @isTest
	private static void rechazarCasosFalloTest(){
		User usr = [SELECT id FROM User WHERE LastName = 'Administrator' AND IsActive = true LIMIT 1];
        List<Case> lstCases =  [SELECT id FROM Case WHERE Subject LIKE 'testfallo%' LIMIT 2];
		
        List<string> lstId = new List<string>();

		for(Case caso : lstCases){
			lstId.add(caso.id);
		}

        String result;
        System.runAs(usr) {
		    result = SAC_LCMP_RechazarReclamacionMasiva.rechazarCasos('Otros', string.join(lstId, ','), 'Test');
        }
		System.assertNotEquals(result, 'OK', 'No ha saltado la validacion correctamente');
	}
    
    @isTest
    private static void descartarConsultasKOOrigenTest(){
        
		User usr = [SELECT id FROM User WHERE LastName = 'Administrator' AND IsActive = true LIMIT 1];
        List<Case> lstCases =  [SELECT id, recordtype.name FROM Case WHERE Subject LIKE 'testConsulta%' LIMIT 2];
        List<string> lstId = new List<string>();
		for(Case caso : lstCases){
			lstId.add(caso.id);
		}
        String result;
        System.runAs(usr) {
		    result = SAC_LCMP_RechazarReclamacionMasiva.descartarCasos('SAC_Otros', string.join(lstId, ','), 'Test');
        }
		System.assertEquals(result, 'KO ORIGEN', 'Es necesario informar el Origen');
	}

    @isTest
    private static void descartarConsultasCOPSAJTest(){
        
		User usr = [SELECT id FROM User WHERE LastName = 'COPSAJ' AND IsActive = true LIMIT 1];
        List<Case> lstCases =  [SELECT id, recordtype.name FROM Case WHERE Subject LIKE 'testConsulta%' LIMIT 2];
        List<string> lstId = new List<string>();
		for(Case caso : lstCases){
			lstId.add(caso.id);
		}
        String result;
        System.runAs(usr) {

		    result = SAC_LCMP_RechazarReclamacionMasiva.descartarCasos('SAC_Otros', string.join(lstId, ','), 'Test');

        }
		System.assertEquals(result, 'OK', 'Consultas descartadas correctamente');

	}
}