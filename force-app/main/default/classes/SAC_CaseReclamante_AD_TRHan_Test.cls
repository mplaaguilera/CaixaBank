/*****************************************************************
 * Name: SAC_CaseReclamante_AD_TRHan_Test
 * Copyright © 2019  CaixaBank 
 * 
 * Proposito: Testear la clase SAC_CaseReclamante_AD_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         		DATE         Description
 * 1.0            US200213         Jose Gonzalez  		04/06/21     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	17/01/23	 Modificación (agregada assertion)
 * 1.2			  US563153		   Jose Carlos Blanco	10/02/23	 Modificación (test modificada usando el SAC_TestDataFactory)
  *****************************************************************/

@isTest
public with sharing class SAC_CaseReclamante_AD_TRHan_Test {
	@TestSetup
    static void makeData(){

		//Usuario SAC General
		User usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1)[0];  
		SAC_DatabaseDML.insertDML(usuarioGeneral, false);     
        //Database.insert(usuarioGeneral);

		PermissionSet permiSet = [SELECT Id FROM PermissionSet WHERE Name = 'SAC_General'];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet.Id;
		SAC_DatabaseDML.insertDML(permiSetAssi, false);  
        //Database.insert(permiSetAssi);

		System.runAs(usuarioGeneral){
			//Reclamacion
			Map<String, Object> camposRecl = new Map<String, Object>();
			camposRecl.put('Subject', 'TestRec');

			Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
			SAC_DatabaseDML.insertDML(reclamacion, false);  
			//Database.insert(reclamacion);

			//Reclamante
			SAC_CaseReclamante__c caseRecl = SAC_TestDataFactory.crearReclamante(false,reclamacion,null);
			SAC_DatabaseDML.insertDML(caseRecl, false); 
			//Database.insert(caseRecl);
		}
	}
	@isTest
	static void borrarReclamante() {
		List<SAC_CaseReclamante__c> caseRecl = [Select SAC_Case__c, SAC_Account__c, SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c LIMIT 1];
		User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true LIMIT 1];
		System.runAs(usuario){
			Test.startTest();
			SAC_DatabaseDML.deleteListDML(caseRecl, false); 
			//Database.delete(caseRecl); 
			Test.stopTest();
		}
		List<SAC_CaseReclamante__c> caseReclBorrado = [Select SAC_ReclamantePrincipal__c, SAC_Case__c, SAC_Account__c FROM SAC_CaseReclamante__c LIMIT 1];
		System.assertNotEquals(caseRecl, caseReclBorrado, 'No se ha borrado el reclamante.');
	}
}