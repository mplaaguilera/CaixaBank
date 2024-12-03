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
        List<Account> cuentas = SAC_TestDataFactory.crearCuentas(2);
        Database.insert(cuentas);

		List<Contact> contactos = SAC_TestDataFactory.crearContacto(2,cuentas[0].Id);
		Database.insert(contactos);

		List<Case> reclamaciones = SAC_TestDataFactory.crearReclamacion(2);
		reclamaciones[0].AccountId = cuentas[0].Id;
		reclamaciones[0].ContactId = contactos[0].Id;
        reclamaciones[0].SAC_FechaRecepcion__c = system.today();
        reclamaciones[1].SAC_FechaRecepcion__c = system.today();
        Database.insert(reclamaciones);

		Case casoPretension = SAC_TestDataFactory.crearPretension(1,null)[0];
        casoPretension.AccountId = cuentas[1].Id;
		casoPretension.ContactId = contactos[1].Id;
        casoPretension.SAC_FechaRecepcion__c = system.today();
		Database.insert(casoPretension);

		SAC_CaseReclamante__c reclamantePret = SAC_TestDataFactory.crearReclamante(true,casoPretension,cuentas[1].Id);
		Database.insert(reclamantePret); 
    }

	@isTest
    static void actualizarReclamentePrincipal() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		caseRecl.SAC_ReclamantePrincipal__c = false;

		User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
		Database.SaveResult dr;

        System.RunAs(usr){   
			Test.startTest();
			dr = Database.update(caseRecl,false);
			Test.stopTest();
        }

		System.assertEquals(1,dr.getErrors().size());
		System.assertEquals('Un caso con reclamantes tiene que tener al menos un reclamante como principal',dr.getErrors()[0].getMessage());
    }

	@isTest
    static void deleteReclamentePrincipal() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		
		Account cuenta = new Account();
        cuenta.name = 'cuentaTest1';
        Database.insert(cuenta);

		Contact contacto = new Contact();
		contacto.AccountId = cuenta.Id;
		contacto.FirstName = 'Test1';
		contacto.LastName = 'Apellido1';
		Database.insert(contacto);

		SAC_CaseReclamante__c caseRecl1 = new SAC_CaseReclamante__c();
		caseRecl1.SAC_Case__c = caseRecl.SAC_Case__c;
		caseRecl1.SAC_Account__c = cuenta.Id;
		caseRecl1.SAC_Contact__c = contacto.Id;
		caseRecl1.SAC_ReclamantePrincipal__c = false;
		Database.insert(caseRecl1);
		
		User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];

        System.RunAs(usr){   
			Test.startTest();
			Database.delete(caseRecl);
			Test.stopTest();
        }

		List<SAC_CaseReclamante__c> listcaseRecl = [Select Id, SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c != null];
		System.assertEquals(1,listcaseRecl.size());
		System.assertEquals(caseRecl1.Id, listcaseRecl.get(0).Id);
		System.assert(listcaseRecl.get(0).SAC_ReclamantePrincipal__c);
    }

	@isTest
    static void deleteUltimoReclamentePrincipal() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		
		User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];

        System.RunAs(usr){   
			Test.startTest();
			Database.delete(caseRecl);
			Test.stopTest();
        }

		List<SAC_CaseReclamante__c> listcaseRecl = [Select Id, SAC_Case__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c != null];
		string rT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
		List<Case> lstCs = [Select Id, AccountId,ContactId FROM Case WHERE RecordTypeId =: rT];
		System.assertEquals(0,listcaseRecl.size());
		System.assertEquals(2, lstCs.size());
		System.assertEquals(null, lstCs.get(0).AccountId);
		System.assertEquals(null, lstCs.get(0).ContactId);
    }

	@isTest
    static void actualizarReclamentePrincipalPretension() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Pretension__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		caseRecl.SAC_ReclamantePrincipal__c = false;

		User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];
		Database.SaveResult dr;

        System.RunAs(usr){   
			Test.startTest();
			dr = Database.update(caseRecl,false);
			Test.stopTest();
        }
		
		System.assertEquals(1,dr.getErrors().size());
		System.assertEquals('Un caso con reclamantes tiene que tener al menos un reclamante como principal',dr.getErrors()[0].getMessage());
    }

	@isTest
    static void deleteReclamentePrincipalPretension() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Pretension__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		
		Account cuenta = new Account();
        cuenta.name = 'cuentaTest1';
        Database.insert(cuenta);

		Contact contacto = new Contact();
		contacto.AccountId = cuenta.Id;
		contacto.FirstName = 'Test1';
		contacto.LastName = 'Apellido1';
		Database.insert(contacto);

		SAC_CaseReclamante__c caseRecl1 = new SAC_CaseReclamante__c();
		caseRecl1.SAC_Pretension__c = caseRecl.SAC_Pretension__c;
		caseRecl1.SAC_Account__c = cuenta.Id;
		caseRecl1.SAC_Contact__c = contacto.Id;
		caseRecl1.SAC_ReclamantePrincipal__c = false;
		Database.insert(caseRecl1);
		
		User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];

        System.RunAs(usr){   
			Test.startTest();
			Database.delete(caseRecl);
			Test.stopTest();
        }

		List<SAC_CaseReclamante__c> listcaseRecl = [Select Id, SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Pretension__c != null];
		System.assertEquals(1,listcaseRecl.size());
		System.assertEquals(caseRecl1.Id, listcaseRecl.get(0).Id);
		System.assert(listcaseRecl.get(0).SAC_ReclamantePrincipal__c);
    }

	@isTest
    static void deleteUltimoReclamentePrincipalPretension() {
        SAC_CaseReclamante__c caseRecl = [Select SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Pretension__c != null LIMIT 1];
		System.assert(caseRecl != null, 'No se ha creado el reclamante con el trigger');
		
		User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];

        System.RunAs(usr){   
			Test.startTest();
			Database.delete(caseRecl);
			Test.stopTest();
        }
		
		List<SAC_CaseReclamante__c> listcaseRecl = [Select Id, SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Pretension__c != null];
		string rT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
		List<Case> lstCs = [Select Id, AccountId,ContactId FROM Case WHERE RecordTypeId =: rT];
		System.assertEquals(0,listcaseRecl.size());
		System.assertEquals(1, lstCs.size());
		System.assertEquals(null, lstCs.get(0).AccountId);
		System.assertEquals(null, lstCs.get(0).ContactId);
    }

	@isTest
	static void compruebaPrincipalTest(){

		Case reclamacion = [SELECT Id FROM Case WHERE Subject = 'TestReclamacion1' LIMIT 1];
		Account cuenta = [SELECT Id FROM Account WHERE Name = 'cuentaTest1' LIMIT 1];

		List<SAC_CaseReclamante__c> reclamantes = [SELECT SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: reclamacion.Id];

		SAC_CaseReclamante__c caseRecl1 = new SAC_CaseReclamante__c();
		caseRecl1.SAC_Case__c = reclamacion.Id;
		caseRecl1.SAC_Account__c = cuenta.Id;

		User usr = [Select id from User where Id = :UserInfo.getUserId() AND isActive = true];

        System.RunAs(usr){   
			Test.startTest();
			Database.insert(caseRecl1);
			Test.stopTest();
        }

		List<SAC_CaseReclamante__c> reclamantesv2 = [SELECT SAC_Case__c,SAC_Pretension__c, SAC_Account__c,SAC_ReclamantePrincipal__c FROM SAC_CaseReclamante__c WHERE SAC_Case__c =: reclamacion.Id];

		System.assertNotEquals(reclamantes, reclamantesv2, 'No se ha insertado correctamente el reclamante.');  

	}
}