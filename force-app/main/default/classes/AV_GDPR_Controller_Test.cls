/**********************************************************************************************************************
Name:	  AV_GDPR_Controller_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Test para el controlador de GDPR
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Esperanza Conde	   	17/09/2020		Init version
1.1			Test Class	   Carolina Alonso	   	01/10/2020		Add test to cover new logic
1.2			Test Class	   Eric Vazquez         14/10/2020      Add test to cover update logic
1.3		    AV_Query IT	   Daniel Rodríguez	    07/02/2022	    Change AV_Query to SOQL for User and Account
1.4         US568949       Ángel Medina.         19/04/2023      Added custom setting record
***********************************************************************************************************************/
@isTest
public with sharing class AV_GDPR_Controller_Test {
	
    private static final String AV_USUARIO_CAIXABANK = 'AV_Usuario_CaixaBank';
    
	@TestSetup
	static void setup(){
		CBK_IntegrationSetting__c gdpr = new CBK_IntegrationSetting__c();
        gdpr.Name = 'AV_GDPR';
        gdpr.NamedCredential__c = 'callout:GDPRControllerTest';
        Database.insert(gdpr);
        AV_TestHelper.activateLogger();
	}
	
	@isTest
	public static void testcheckTreatments() {
        Account cliente = AV_TestHelper.createCustomer();
		// Set mock callout class 
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','OK'));
		
        Test.startTest();
		AV_GDPR_Controller.response response = AV_GDPR_Controller.getTreatments(cliente.Id);
		Test.stopTest();
		
		System.assertEquals('ok', response.severity);
	}

	@isTest
	public static void testcheckTreatmentsUpdateClient() {
		Account cliente = AV_TestHelper.createCustomer();
		cliente.AV_JSONGDPR__c = 'update';
		update cliente;
        
        // Set mock callout class 
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','OK')); 
        
		Test.startTest();
		AV_GDPR_Controller.response response = AV_GDPR_Controller.getTreatments(cliente.Id);
		Test.stopTest();
		
		System.assertEquals('error', response.severity);
	}

	@isTest
	public static void testcheckTreatmentsGDPR_OTHER() {
		Account cliente = AV_TestHelper.createCustomer();
        // Set mock callout class 
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR_OTHER','OK')); 
        
		Test.startTest();
		AV_GDPR_Controller.response response = AV_GDPR_Controller.getTreatments(cliente.Id);
		Test.stopTest();
		
		System.assertEquals('ok', response.severity);
	}

	@isTest
	public static void testcheckTreatmentsGDPR_OTHER_NEW() {
		Account cliente = AV_TestHelper.createCustomer();
        // Set mock callout class 
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR_OTHER_NEW','OK')); 
        
		Test.startTest();
		AV_GDPR_Controller.response response = AV_GDPR_Controller.getTreatments(cliente.Id);
		Test.stopTest();
		
		System.assertEquals('ok', response.severity);
	}
	
	@isTest
	public static void testcheckTreatmentsFail() {
		Account cliente = AV_TestHelper.createCustomer();
		// Set mock callout class 
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','KO')); 
        
        Test.startTest();
		AV_GDPR_Controller.response response = AV_GDPR_Controller.getTreatments(cliente.Id);
		Test.stopTest();
		
		System.assertEquals('error', response.severity);
	}
	
	@isTest
	public static void testcheckTreatmentsFailCustomerNotFound() {
		Test.startTest();

		try{
			// Set mock callout class 
			Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','KO'));
			// This causes a fake response to be sent
			// from the class that implements HttpCalloutMock. 
			AV_GDPR_Controller.response response = AV_GDPR_Controller.getTreatments(null);
		}catch(Exception e){
			Boolean expectedExceptionThrown =  e.getMessage().contains('not retreived') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		} 
		
		Test.stopTest();
	}


	/*@isTest
	public static void testcheckTreatmentsFailUserWithoutExternalId() {
		User usuario = AV_TestHelper.createUser(AV_USUARIO_CAIXABANK);
		usuario.AV_ExternalId__c = null;
		update usuario;
        
		System.runAs(usuario){
			Account cliente = AV_TestHelper.createCustomer();
			Test.startTest();

			try{
				// Set mock callout class 
				Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','KO')); 
				// This causes a fake response to be sent
				// from the class that implements HttpCalloutMock. 
				AV_GDPR_Controller.response response = AV_GDPR_Controller.getTreatments(cliente.Id);
			}catch(Exception e){
				Boolean expectedExceptionThrown =  e.getMessage().contains('Error') ? true : false;
				Boolean expectedExceptionUser =  e.getMessage().contains('usuario') ? true : false;
				System.AssertEquals(expectedExceptionThrown, true);
				System.AssertEquals(expectedExceptionUser, true);
			} 
			
			Test.stopTest();
		}		
	}*/

	@isTest
	public static void testcheckgetGDPRForCampaigns() {
		 Account cliente = AV_TestHelper.createCustomer();
		// Set mock callout class 
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','OK'));
		List<List<String>> fields = new List<List<String>>();
		List<String> field = new List<String>();
		field.add(cliente.Id);
        fields.add(field);
        Test.startTest();
		List<Boolean> res = AV_GDPR_Controller.getGDPRForCampaigns(fields);
		Test.stopTest();
		
		//System.assertEquals(true, res[0]);
	}
    
    @isTest
	public static void testcheckgetGDPRForCampaigns2() {
		 Account cliente = AV_TestHelper.createCustomer();
		cliente.AV_NumPerso__c = '';
        update cliente;
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','OK'));
		List<List<String>> fields = new List<List<String>>();
		List<String> field = new List<String>();
		field.add(cliente.Id);
        fields.add(field);
        Test.startTest();
		List<Boolean> res = AV_GDPR_Controller.getGDPRForCampaigns(fields);
		Test.stopTest();

	}


	
}