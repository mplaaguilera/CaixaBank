/**********************************************************************************************************************
Name:	  AV_AsesorVentasOpp_Integration_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Unit test of the AV_AsesorVentasOpp_Integration class
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Esperanza Conde	   	01/10/2020		Init version
1.1          QC            Oscar Moreno        12/06/2024       Delete UserInfo.geetUserId()

***********************************************************************************************************************/
@isTest
public with sharing class AV_AsesorVentasOpp_Integration_Test {
    
    @TestSetup
    static void setup(){
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true]; 
        AV_TestHelper.activateLogger();
    }
    
    @isTest
    public static void testGetOpp() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  
        
        String userId = '13550';
        String employeeId = [Select AV_ExternalID__c From User Where Id = : usuarioGcf.Id][0].AV_ExternalID__c;
        Account customer = AV_TestHelper.createCustomer();
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        insert pb;
        Opportunity opp = AV_TestHelper.createOpportunity(customer);
        
        Test.startTest();		
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_OPP','OK'));
        AV_AsesorVentasOpp_Integration.ConOppResponse oppResponse;
        System.runAs(usuarioGcf){
            oppResponse = AV_AsesorVentasOpp_Integration.conOportunidad(userId,opp.Id,employeeId);		
        }
        Test.stopTest();
        System.assertEquals('200', oppResponse.statusCode);
    }
    
    @isTest
    public static void testAltaOpp() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  
        
        String userId = '13550';
        String employeeId = [Select AV_ExternalID__c From User Where Id = : usuarioGcf.Id][0].AV_ExternalID__c;
        Account customer = AV_TestHelper.createCustomer();
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        insert pb;
        Opportunity opp = AV_TestHelper.createOpportunity(customer);
        
        AV_AsesorVentasOpp_Integration.Opportunity request = new AV_AsesorVentasOpp_Integration.Opportunity();
        
        request.entityName = 'Santander';
        request.amountOtherEntities = 3000;
        request.dueDate = Date.valueof('2022-10-28');
        request.commentary = 'Préstamo personal para coche';
        request.noOfferUntil = '2022-10-29';
        request.monthlyFee = 50;
        request.interestRate = 10.65;
        
        Test.startTest();		
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_ALTAOPP','OK'));
        AV_AsesorVentasOpp_Integration.AltaOppResponse oppAltaResponse ;
        System.runAs(usuarioGcf){
             oppAltaResponse = AV_AsesorVentasOpp_Integration.altaOportunidad(request, userId,employeeId);		
        }
        Test.stopTest();
        System.assertEquals('200', oppAltaResponse.statusCode);
    }
    
    @isTest
    public static void testModOpp() {
        User usuarioGcf =[SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];  
        
        String userId = '13550';
        String employeeId = [Select AV_ExternalID__c From User Where Id = : usuarioGcf.Id][0].AV_ExternalID__c;
        Account customer = AV_TestHelper.createCustomer();
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Standard Price Book';
        insert pb;
        Opportunity opp = AV_TestHelper.createOpportunity(customer);
        
        AV_AsesorVentasOpp_Integration.Opportunity request = new AV_AsesorVentasOpp_Integration.Opportunity();
        request.opportunityId = 34568;
        request.employeeId = 81223;
        request.offerUntil = Date.valueof('2021-03-31');
        request.potential = 'S';
        request.holdingOtherEntities = 'S';
        request.entityName = 'BBVA';
        request.amountOtherEntities = 113243.50;
        request.userId = 13550;
        request.interestRate = 0.00;
        request.warningIndicator = 'N';
        
        Test.startTest();		
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GCF_MODOPP','OK'));
        AV_AsesorVentasOpp_Integration.ModOppResponse oppModResponse;
        System.runAs(usuarioGcf){
            oppModResponse = AV_AsesorVentasOpp_Integration.modOportunidad(request, userId,employeeId, opp.Id);		
        }
        Test.stopTest();
        System.assertEquals('200', oppModResponse.statusCode);
    }    
}