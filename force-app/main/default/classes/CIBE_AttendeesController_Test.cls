/**********************************************************************************************************************
Name:	  CIBE_AttendeesController_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "CIBE_AttendeesController"
-----------------------------------------------------------------------------------------------------------------------
Historial
    VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0			Test Class		Alex Campos			11/08/2022		Init version
	2.0			Test Class		Alex Campos			10/11/2022		Contact Query change
-----------------------------------------------------------------------------------------------------------------------
**********************************************************************************************************************/
@isTest
public with sharing class CIBE_AttendeesController_Test {
    
    /***********************************************************************************************************/
    @TestSetup
    public static void setup(){
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account center = CIBE_TestHelper.createCaixaCenter();
        CIBE_TestHelper.createEmployee(center, usrTest);
        Account customer = CIBE_TestHelper.createCustomer();
    }
    /***********************************************************************************************************/
    @isTest
    public static void searchUserTest(){
        Test.startTest();
        List<Contact> employee = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'CC_Empleado'];
        
        Id[] fixedSearchResults = new Id[1];
        fixedSearchResults[0] = employee[0].Id;
        Test.setFixedSearchResults(fixedSearchResults);
        List<AV_LookupSearchResult> results = CIBE_AttendeesController.searchUser('Empleado', new List<String>());
        System.assert(!results.isEmpty());
        
        results = CIBE_AttendeesController.searchUser('Empleado', new List<String>{employee[0].Id});
        System.assert(results.isEmpty());
        Test.stopTest();
    }
    /***********************************************************************************************************/
    @isTest
	private static void getUserEmployeeTest(){
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        
        User record = CIBE_AttendeesController.getUserEmployee(usrTest.Id);
        System.assert(record != null);
    }
    
    /***********************************************************************************************************/
    
}