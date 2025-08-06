@isTest
public with sharing class SEG_Casos_Por_Grupo_Queueable_Test{
	@testSetup
	static void datosIniciales(){
        ID rtSegCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        List<Case> listCase = new List<Case>();
        
        SEG_ClasificacionRapida__c cr = new SEG_ClasificacionRapida__c();
        cr.Name = 'No procede';
        insert cr;
        
        Case c1 = new Case();
        c1.Subject = 'Test c1';
        c1.Origin = 'Oficina';
        c1.SEG_Organizacion__c = 'Banca Corporativa';
        c1.SEG_Zona__c = 'Corporativa';
        c1.CC_Idioma__c = 'es';
        c1.Status = 'Activo';
    	c1.RecordTypeId = rtSegCliente;
        listCase.add(c1);
        
        Case c2 = new Case();
        c2.Subject = 'Test c2';
        c2.Origin = 'Oficina';
        c2.SEG_Organizacion__c = 'Banca Corporativa';
        c2.SEG_Zona__c = 'Corporativa';
        c2.CC_Idioma__c = 'es';
        c2.Status = 'Activo';
    	c2.RecordTypeId = rtSegCliente;
        listCase.add(c2);
        
        insert listCase;
	}

	@isTest
	private static void testRechazarCasos() {
        System.runAs (new User(Id = UserInfo.getUserId())){
            
            Set<Id> setCasos = new Set<Id>();
            List<Case> caseListPre = [SELECT Id, Status FROM Case WHERE Subject LIKE 'TEST %' ORDER BY Subject];
    
            for(Case c : caseListPre){
                setCasos.add(c.Id);
            }

			Test.startTest();
			SEG_Casos_Por_Grupo_Queueable cPGQ = new SEG_Casos_Por_Grupo_Queueable(setCasos);
			System.enqueueJob(cPGQ);
			Test.stopTest();

			List<Case> lstCasePost = [SELECT Id, Status FROM Case WHERE Subject LIKE 'TEST %' ORDER BY Subject];
			System.assertEquals('Descartado', lstCasePost[0].Status, 'Se debería rechazar el caso c1 con el estado a Descartado');
			System.assertEquals('Descartado', lstCasePost[1].Status, 'Se debería rechazar el caso c2 con el estado a Descartado');
		}

	}

}