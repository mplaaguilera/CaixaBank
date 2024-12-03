/**********************************************************************************************************************
Name:	  CIBE_Path_Opportunity_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Test class for the controller for the LWC cibe_TaskTabs
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
	1.0			US420186    	Jose Maria	  	    20/10/2021		Init version copy retail methods 
	
***********************************************************************************************************************/
@isTest
public with sharing class CIBE_Path_Opportunity_Controller_Test {
    @isTest
    private static void testGetRecordTypeVerificationAccionComercial() {
        //Create a new account
        Account testingAccount = CIBE_TestHelper.createCustomer();
        //Insert the account

        //Create a new opportunity
        Opportunity testingOpportunity = CIBE_TestHelper.createOpportunity(testingAccount);
        Id idOfRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Acción Comercial CIB').getRecordTypeId();
        testingOpportunity.RecordTypeId = idOfRecordType;
        //Insert the opportunity
        update testingOpportunity;
        
        //Call the method getRecordTypeVerification with the opportunity id
        Test.startTest();
        Boolean result = CIBE_Path_Opportunity_Controller.getRecordTypeVerification(testingOpportunity.Id);
        Test.stopTest();        //Verify if the result is true
        System.assertEquals(true, result);
    }

    @isTest
    private static void testGetRecordTypeVerificationIniciativaEmpleadoCIB() {
        //Create a new account
        Account testingAccount = CIBE_TestHelper.createCustomer();
        //Insert the account

        //Create a new opportunity
        Opportunity testingOpportunity = CIBE_TestHelper.createOpportunity(testingAccount);
        //Insert the opportunity
        Id idOfRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Iniciativa Empleado CIB').getRecordTypeId();
        testingOpportunity.RecordTypeId = idOfRecordType;
        update testingOpportunity;


        //Call the method getRecordTypeVerification with the opportunity id
        Test.startTest();
        Boolean result = CIBE_Path_Opportunity_Controller.getRecordTypeVerification(testingOpportunity.Id);
        Test.stopTest();        //Verify if the result is true
        System.assertEquals(true, result);
    }

    @isTest
    private static void testGetRecordTypeVerificationSugerencia() {
      
        //Create a new account
        Account testingAccount = CIBE_TestHelper.createCustomer();
        //Insert the account

        //Create a new opportunity
        Opportunity testingOpportunity = CIBE_TestHelper.createOpportunity(testingAccount);
        Id idOfRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Sugerencia CIB').getRecordTypeId();
        testingOpportunity.RecordTypeId = idOfRecordType;
        //Insert the opportunity
        update testingOpportunity;
        

        //Call the method getRecordTypeVerification with the opportunity id
        Test.startTest();
        Boolean result = CIBE_Path_Opportunity_Controller.getRecordTypeVerification(testingOpportunity.Id);
        Test.stopTest();        //Verify if the result is true
        System.assertEquals(true, result);
    }

    @isTest
    private static void testGetRecordTypeVerificationAlerta() {
        //Create a new account
        Account testingAccount = CIBE_TestHelper.createCustomer();
        //Insert the account

        //Create a new opportunity
        Opportunity testingOpportunity = CIBE_TestHelper.createOpportunity(testingAccount);
        Id idOfRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alerta Comercial CIB').getRecordTypeId();
        testingOpportunity.RecordTypeId = idOfRecordType;

        //Insert the opportunity
        update testingOpportunity;
        


        //Call the method getRecordTypeVerification with the opportunity id
        Test.startTest();
        Boolean result = CIBE_Path_Opportunity_Controller.getRecordTypeVerification(testingOpportunity.Id);
        Test.stopTest();        //Verify if the result is true
        System.assertEquals(true, result);
    }

    
    @isTest
    private static void testGetRecordTypeVerificationWrongType() {
        //Create a new account
        Account testingAccount = CIBE_TestHelper.createCustomer();
        //Insert the account

        //Create a new opportunity
        Opportunity testingOpportunity = CIBE_TestHelper.createOpportunity(testingAccount);
        Id idOfRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alerta Comercial EMP').getRecordTypeId();
        testingOpportunity.RecordTypeId = idOfRecordType;

        //Insert the opportunity
        update testingOpportunity;
        


        //Call the method getRecordTypeVerification with the opportunity id
        Test.startTest();
            Boolean result = CIBE_Path_Opportunity_Controller.getRecordTypeVerification(testingOpportunity.Id);
        Test.stopTest();
        //Verify if the result is true
        System.assertEquals(false, result);
    }
    
    @isTest
    private static void testGetRecordTypeVerificationWrongTypeAndNoOpportunity() {
        //Create a new account
        Account testingAccount = CIBE_TestHelper.createCustomer();
        //Insert the account

 
        


        //Call the method getRecordTypeVerification with the opportunity id
        Test.startTest();
            Boolean result = CIBE_Path_Opportunity_Controller.getRecordTypeVerification('00000000P');
        Test.stopTest();
        //Verify if the result is true
        System.assertEquals(null, result);
    }

}