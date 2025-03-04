/*****************************************************************
 * Name: SAC_CaseReclamante_BU_TRHan_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_CaseReclamante_BU_TRHan
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         		DATE         Description
 * 1.0            US200213         Jose Gonzalez  		04/06/21     Creación
 * 1.1			  US507573		   Jose Carlos Blanco	17/01/23	 Modificación (agregada assertion)
 * 1.2            US563153         Jose Carlos Blanco   28/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/

@isTest
public with sharing class SAC_CaseReclamante_BU_TRHan_Test  {

	@TestSetup
    static void makeData() {
		//Cuenta
		Account cuenta = SAC_TestDataFactory.crearCuentas(1)[0];
		SAC_DatabaseDML.insertDML(cuenta, false);
		//Database.insert(cuenta);

		//Reclamacion
		Map<String, Object> camposRecl = new Map<String, Object>();
        camposRecl.put('Subject', 'TestRec');
        camposRecl.put('AccountId', cuenta.Id);

        Case reclamacion = SAC_TestDataFactory.crearCaso('Reclamacion',camposRecl);
		SAC_DatabaseDML.insertDML(reclamacion, false);
        //Database.insert(reclamacion);

		//Reclamante
		SAC_CaseReclamante__c re = SAC_TestDataFactory.crearReclamante(false,reclamacion,cuenta.id);
		SAC_DatabaseDML.insertDML(re, false);
		//Database.insert(re);

		//Usuario SAC General
		List<User> usuarioGeneral = SAC_TestDataFactory.crearUsuarioSACGeneral(1);  
		SAC_DatabaseDML.insertListDML(usuarioGeneral, false);    
        //Database.insert(usuarioGeneral);
	}

	@isTest
    static void actualizarReclamante() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c LIMIT 1];
		caseRecl.SAC_ReclamantePrincipal__c = true;

		User usuario = [SELECT id FROM User WHERE Username = 'usertest0@test.com.testSetup' AND isActive = true];
		System.runAs(usuario){
			Test.startTest();
			SAC_DatabaseDML.updateDML(caseRecl, false); 
			//Database.SaveResult dr = Database.update(caseRecl,false);
			Test.stopTest();
		}
		System.assertEquals(true, caseRecl.SAC_ReclamantePrincipal__c, 'No se ha actualizado el reclamante.');
    }
}