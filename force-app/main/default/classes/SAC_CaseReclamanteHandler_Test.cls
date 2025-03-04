/*****************************************************************
 * Name: SAC_CaseReclamanteHandler_Test
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Testear la clase SAC_CaseReclamanteHandler
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         		DATE         Description
 * 1.0            US200213         Jose Gonzalez  		04/06/21     Creación
 * 1.1            US563153         Jose Carlos Blanco  	08/03/23     Modificación (test modificada usando el SAC_TestDataFactory)   
*****************************************************************/

@isTest
public with sharing class SAC_CaseReclamanteHandler_Test  {

	@TestSetup
    static void makeData() {

		User usuarioAdmin = SAC_TestDataFactory.crearUsuarioAdministrador(1)[0];     
        SAC_DatabaseDML.insertDML(usuarioAdmin, false);

        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(2);
		SAC_DatabaseDML.insertListDML(cuentas, false);

		List<Contact> contactos = SAC_TestDataFactory.crearContacto(2,cuentas[0].Id);
		SAC_DatabaseDML.insertListDML(contactos, false);

		List<Case> reclamaciones = SAC_TestDataFactory.crearReclamacion(2);
		reclamaciones[0].AccountId = cuentas[0].Id;
		reclamaciones[0].ContactId = contactos[0].Id;
        reclamaciones[0].SAC_FechaRecepcion__c = system.today();
        reclamaciones[1].SAC_FechaRecepcion__c = system.today();
		SAC_DatabaseDML.insertListDML(reclamaciones, false);

		Case casoPretension = SAC_TestDataFactory.crearPretension(1,null)[0];
        casoPretension.AccountId = cuentas[1].Id;
		casoPretension.ContactId = contactos[1].Id;
        casoPretension.SAC_FechaRecepcion__c = system.today();
		SAC_DatabaseDML.insertDML(casoPretension, false);

		SAC_CaseReclamante__c reclamantePret = SAC_TestDataFactory.crearReclamante(true,casoPretension,cuentas[1].Id);
		SAC_DatabaseDML.insertDML(reclamantePret, false);
    }

	@isTest
    static void actualizarReclamentePrincipal() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		caseRecl.SAC_ReclamantePrincipal__c = false;

		User usr = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.RunAs(usr){   
			Test.startTest();
			SAC_DatabaseDML.updateDML(caseRecl,false);
			Test.stopTest();
        }

		System.assertNotEquals(null,caseRecl, 'Error al actualizar el reclamante principal');
    }

	@isTest
    static void deleteReclamentePrincipal() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		
		Account cuenta = new Account();
        cuenta.name = 'cuentaTest1';
		SAC_DatabaseDML.insertDML(cuenta, false);

		Contact contacto = new Contact();
		contacto.AccountId = cuenta.Id;
		contacto.FirstName = 'Test1';
		contacto.LastName = 'Apellido1';
		SAC_DatabaseDML.insertDML(contacto, false);

		SAC_CaseReclamante__c caseRecl1 = new SAC_CaseReclamante__c();
		caseRecl1.SAC_Case__c = caseRecl.SAC_Case__c;
		caseRecl1.SAC_Account__c = cuenta.Id;
		caseRecl1.SAC_Contact__c = contacto.Id;
		caseRecl1.SAC_ReclamantePrincipal__c = false;
		SAC_DatabaseDML.insertDML(caseRecl1, false);
		
		User usr = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.RunAs(usr){   
			Test.startTest();
			SAC_DatabaseDML.deleteDML(caseRecl, false);
			Test.stopTest();
        }

		List<SAC_CaseReclamante__c> listcaseRecl = [Select Id, SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c != null];
		System.assertEquals(caseRecl1.Id, listcaseRecl.get(0).Id, 'Error al eliminar el reclamante principal');
		System.assert(listcaseRecl.get(0).SAC_ReclamantePrincipal__c, 'Error al eliminar el reclamante principal');
    }

	@isTest
    static void deleteUltimoReclamentePrincipal() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		
		User usr = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.RunAs(usr){   
			Test.startTest();
			SAC_DatabaseDML.deleteDML(caseRecl, false);
			Test.stopTest();
        }

		string rT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		List<Case> lstCs = [Select Id, AccountId,ContactId FROM Case WHERE RecordTypeId =: rT];

		System.assertEquals(null, lstCs.get(0).AccountId, 'Error al eliminar el ultimo reclamante principal');
		System.assertEquals(null, lstCs.get(0).ContactId, 'Error al eliminar el ultimo reclamante principal');
    }

	@isTest
    static void actualizarReclamentePrincipalPretension() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Pretension__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		caseRecl.SAC_ReclamantePrincipal__c = false;

		User usr = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.RunAs(usr){   
			Test.startTest();
			SAC_DatabaseDML.updateDML(caseRecl,false);
			Test.stopTest();
        }
		
		System.assertNotEquals(null,caseRecl, 'Error al actualizar el reclamante ppal de la pretension');
    }

	@isTest
    static void deleteReclamentePrincipalPretension() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Pretension__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		
		Account cuenta = new Account();
        cuenta.name = 'cuentaTest1';
		SAC_DatabaseDML.insertDML(cuenta, false);

		Contact contacto = new Contact();
		contacto.AccountId = cuenta.Id;
		contacto.FirstName = 'Test1';
		contacto.LastName = 'Apellido1';
		SAC_DatabaseDML.insertDML(contacto, false);

		SAC_CaseReclamante__c caseRecl1 = new SAC_CaseReclamante__c();
		caseRecl1.SAC_Pretension__c = caseRecl.SAC_Pretension__c;
		caseRecl1.SAC_Account__c = cuenta.Id;
		caseRecl1.SAC_Contact__c = contacto.Id;
		caseRecl1.SAC_ReclamantePrincipal__c = false;
		SAC_DatabaseDML.insertDML(caseRecl1, false);
		
		User usr = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.RunAs(usr){   
			Test.startTest();
			SAC_DatabaseDML.deleteDML(caseRecl, false);
			Test.stopTest();
        }

		List<SAC_CaseReclamante__c> listcaseRecl = [Select Id, SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Pretension__c != null];
		System.assertEquals(caseRecl1.Id, listcaseRecl.get(0).Id, 'Error al eliminar el reclamante principal');
		System.assert(listcaseRecl.get(0).SAC_ReclamantePrincipal__c, 'Error al eliminar el reclamante principal');
    }

	@isTest
    static void deleteUltimoReclamentePrincipalPretension() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Pretension__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		
		User usr = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.RunAs(usr){   
			Test.startTest();
			SAC_DatabaseDML.deleteDML(caseRecl, false);
			Test.stopTest();
        }
		
		string rT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
		List<Case> lstCs = [Select Id, AccountId,ContactId FROM Case WHERE RecordTypeId =: rT];

		System.assertEquals(null, lstCs.get(0).AccountId, 'Error al eliminar el ultimo reclamante principal');
		System.assertEquals(null, lstCs.get(0).ContactId, 'Error al eliminar el ultimo reclamante principal');
    }

	@isTest
	static void compruebaPrincipalTest(){

		Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestReclamacion1' LIMIT 1];
		Account cuenta = [SELECT Id FROM Account WHERE Name = 'cuentaTest1' LIMIT 1];

		List<SAC_CaseReclamante__c> reclamantes = [SELECT SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: reclamacion.Id];

		SAC_CaseReclamante__c caseRecl1 = new SAC_CaseReclamante__c();
		caseRecl1.SAC_Case__c = reclamacion.Id;
		caseRecl1.SAC_Account__c = cuenta.Id;

		User usr = [SELECT id FROM User WHERE username = 'useradmintest0@test.com.testSetup' AND IsActive = true LIMIT 1];

        System.RunAs(usr){   
			Test.startTest();
			SAC_DatabaseDML.insertDML(caseRecl1, false);
			Test.stopTest();
        }

		List<SAC_CaseReclamante__c> reclamantesv2 = [SELECT SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: reclamacion.Id];

		System.assertNotEquals(reclamantes, reclamantesv2, 'No se ha insertado correctamente el reclamante.');  

	}
}