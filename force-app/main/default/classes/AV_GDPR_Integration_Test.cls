/**********************************************************************************************************************
Name:	  AV_GDPR_Integration_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Test para la integración de GDPR
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Esperanza Conde	   	19/08/2020		Init version
1.1         US568949       Ángel Medina.         19/04/2023      Added custom setting record
***********************************************************************************************************************/
@isTest
public with sharing class AV_GDPR_Integration_Test {
    
    @TestSetup
    static void setup(){
        CBK_IntegrationSetting__c gdpr = new CBK_IntegrationSetting__c();
        gdpr.Name = 'AV_GDPR';
        gdpr.NamedCredential__c = 'callout:GDPRIntegrationTest';
        Database.insert(gdpr);
        AV_TestHelper.activateLogger();
    }
    
    @isTest
    public static void testcheckTreatments() {

        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('GDPR','OK')); 
        AV_GDPR_Integration.GDPRResponse response = AV_GDPR_Integration.checkTreatmentsFw('0001-A', 'GCC', '12542', 'U0185227');
        Test.stopTest();
        system.assertEquals('200', response.statusCode);
    }
    
    @isTest
    public static void testCompareTo() {
        AV_GDPR_Integration.ConsentsList compareToEmp = new AV_GDPR_Integration.ConsentsList();
        compareToEmp.consentId = 1232;
        compareToEmp.isConsent = 'True';
        
        Test.startTest();
        AV_GDPR_Integration.ConsentsList constructor = new AV_GDPR_Integration.ConsentsList();
        constructor.consentId = 1232;
        constructor.isConsent = 'True';
        Integer num = constructor.compareTo(compareToEmp);
        Test.stopTest();
        
        system.assertEquals(0, num);
    }
    
    @isTest
    public static void testCompareTo2() {
        AV_GDPR_Integration.ConsentsList compareToEmp = new AV_GDPR_Integration.ConsentsList();
        compareToEmp.consentId = 2;
        compareToEmp.isConsent = 'True';
        
        Test.startTest();
        AV_GDPR_Integration.ConsentsList constructor = new AV_GDPR_Integration.ConsentsList();
        constructor.consentId = 1;
        constructor.isConsent = 'True';
        Integer num = constructor.compareTo(compareToEmp);
        Test.stopTest();
        
        system.assertEquals(1, num);
    }
     
}