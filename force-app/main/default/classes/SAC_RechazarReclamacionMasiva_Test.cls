/*****************************************************************
 * Name: SAC_RechazarReclamacionMasiva_Test
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Testear la clase SAC_RechazarReclamacionMasiva_Controller
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0             DE71399       Sergio Martín    23/02/2023       Creación 
*****************************************************************/
@isTest
public with sharing class SAC_RechazarReclamacionMasiva_Test {
    @testSetup 
    static void setup() {
		User user = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Administrador del sistema'].Id,
            LastName = 'Administrator',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US');
        SAC_DatabaseDML.insertDML(user, false);

        Case casoRechazo;
        list<Case> lstCases = new List<Case>(); 
        for(Integer  i = 0; i <= 5; i++){
            casoRechazo = new Case();
            casoRechazo.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
            casoRechazo.Status = 'SAC_001';
            casoRechazo.Subject = 'testrec' + i;
            casoRechazo.SAC_StatusAuxiliar__c = casoRechazo.Status;
			
			lstCases.add(casoRechazo);
	 	}

        SAC_DatabaseDML.insertListDML(lstCases, false);
    }

	@isTest 
	private static void testRechazarReclamacionMasivaController() {
		User usuario = [SELECT id FROM User WHERE LastName = 'Administrator' AND IsActive = true LIMIT 1];
		list<Case> lstCases = [SELECT id,Status,SAC_StatusAuxiliar__c,Subject, RecordTypeId FROM Case WHERE Subject LIKE 'testrec%'];
	
		System.runAs(usuario){
			PageReference testPage = Page.SAC_RechazarReclamacionMasiva;
			Test.setCurrentPage(testPage);

			ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(lstCases);
			stdSetController.setSelected(lstCases);
			SAC_RechazarReclamacionMasiva_Controller lstIdVF = new SAC_RechazarReclamacionMasiva_Controller(stdSetController);
			System.assertNotEquals(0, lstIdVF.getIDs.size(), 'Registros VF Page. Ids a cambiar');
		}
	}
}