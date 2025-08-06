/**********************************************************************************************************************
Name:	  AV_AsesorVentas_Integration_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración para información de carteras (GCF)
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Esperanza Conde	   	30/07/2020		Init version
1.1			Test Class	   Esperanza Conde	   	19/08/2020		Init version
1.2			Test Class	   Esperanza Conde	   	02/10/2020		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_AsesorVentas_Integration_Test {
    
    @TestSetup
    static void setup(){
        AV_TestHelper.activateLogger();
    }

    
    @isTest
    public static void testlistGestores() {
        String branchId = '59';
        Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_GESTORES','OK'));
		AV_AsesorVentas_Integration.ListaGestoresResponse prodResponse = AV_AsesorVentas_Integration.liEmplCentro(branchId);		
		Test.stopTest();
		System.assertEquals('200', prodResponse.statusCode);
    }
    
    @isTest
    public static void testlistGestoresFail() {
        String branchId = '59';
        Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_GESTORES','KO'));
		AV_AsesorVentas_Integration.ListaGestoresResponse prodResponse = AV_AsesorVentas_Integration.liEmplCentro(branchId);		
		Test.stopTest();
		System.assertEquals('500', prodResponse.statusCode);
    }
    
    @isTest
    public static void testreasignarCartera() {
        String portfolioId = '100360313';
        String branchId = '59';
        AV_AsesorVentas_Integration.ReasignarCarteraRequest ctcBody = new AV_AsesorVentas_Integration.ReasignarCarteraRequest();
        ctcBody.newManager = 19363;
        ctcBody.newBranch = 59;
        ctcBody.inheritCategories = true;
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_REASIGNARCARTERA','OK'));
		AV_AsesorVentas_Integration.ReasignarCarteraResponse prodResponse = AV_AsesorVentas_Integration.reasignarCartera(ctcBody, portfolioId, branchId);		
		Test.stopTest();
		System.assertEquals('200', prodResponse.statusCode);
    }
    
    @isTest
    public static void testreasignarCarteraFail() {
        String portfolioId = '100360313';
        String branchId = '59';
        AV_AsesorVentas_Integration.ReasignarCarteraRequest ctcBody = new AV_AsesorVentas_Integration.ReasignarCarteraRequest();
        ctcBody.newManager = 19363;
        ctcBody.newBranch = 59;
        ctcBody.inheritCategories = true;
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_REASIGNARCARTERA','KO'));
		AV_AsesorVentas_Integration.ReasignarCarteraResponse prodResponse = AV_AsesorVentas_Integration.reasignarCartera(ctcBody, portfolioId, branchId);		
		Test.stopTest();
		System.assertEquals('500', prodResponse.statusCode);
    }
    
    @isTest
    public static void testcambiarGestorCli() {
        String customerId = '100360313';
        String branchId = '59';
        String employeeId = 'U0185227';
        AV_AsesorVentas_Integration.CambiarGestorRequest ctcBody = new AV_AsesorVentas_Integration.CambiarGestorRequest();
        List<String> catList = new List<String>();
        catList.add('1936300014');
        catList.add('1936300015');
        
        ctcBody.Categories = catList;
        ctcBody.customerPortfolioId = 100019067;
        ctcBody.isNextYear = false;
        ctcBody.otherReason = 'Cambio de domicilio';
        ctcBody.typeOperation = 'C';
        ctcBody.typeReason = '9';
        
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_CAMBIARGESTOR','OK'));
		AV_AsesorVentas_Integration.CambiarGestorResponse prodResponse = AV_AsesorVentas_Integration.cambiarGestorCli(ctcBody, customerId, branchId,employeeId);		
		Test.stopTest();
    }
    
    @isTest
    public static void testcambiarGestorCliFail() {
        String customerId = '100360313';
        String branchId = '59';
        String employeeId = 'U0185227';
        AV_AsesorVentas_Integration.CambiarGestorRequest ctcBody = new AV_AsesorVentas_Integration.CambiarGestorRequest();
        List<String> catList = new List<String>();
        catList.add('1936300014');
        catList.add('1936300015');
        
        ctcBody.Categories = catList;
        ctcBody.customerPortfolioId = 100019067;
        ctcBody.isNextYear = false;
        ctcBody.otherReason = 'Cambio de domicilio';
        ctcBody.typeOperation = 'C';
        ctcBody.typeReason = '9';
        
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_CAMBIARGESTOR','KO'));
		AV_AsesorVentas_Integration.CambiarGestorResponse prodResponse = AV_AsesorVentas_Integration.cambiarGestorCli(ctcBody, customerId, branchId, employeeId);		
		Test.stopTest();
		System.assertEquals('500', prodResponse.statusCode);
    }
}