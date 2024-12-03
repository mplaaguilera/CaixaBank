/**********************************************************************************************************************
 Name:	  AV_C2C_Controller_Test
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Integración con Rainbow para la funcionalidad de Click-to-Call (C2C)
=======================================================================================================================
Historial
---------------------
   VERSION		USER_STORY	   AUTHOR		   		DATE			Description
   1.0			Test Class	   Carolina Alonso	   	10/03/2020		Init version
   1.1 			US649249	   Gonzalo Ávila		27/11/2023		Include system.asserts in all methods

***********************************************************************************************************************/
@isTest
public with sharing class AV_C2C_Controller_Test {

	@TestSetup
	static void setup(){
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		AV_TestHelper.activateLogger();
	}

	/**
     * @description 	prepare data for test
	 * @param option	option for testing:
	 * 					1.1 - Mock Success
	 * 					1.2 - Mock Error 1
	 * 					1.3 - Mock Error 2
	 * 					1.4 - Mock Error 3
	 * 					2 - Mock Fail
	 * 					3 - Mock Fail Exception
     * @return 			mock with token success
	 */
	static void prepareTest(String option){
		Test.setMock(HttpCalloutMock.class, new AV_C2C_MockCallout_Test(option));
	}

	@isTest
	public static void testC2cMakeCall() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];

		System.runAs(userGcf){
			prepareTest('1.1');
			Test.startTest();
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			List<String> listResult = AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
			System.assert(listResult.contains('success'), 'ResultMethod does not contain the expected result 1.1');
			System.assert(listResult.contains(Label.AV_CMP_C2C_OK), 'ResultMethod does not contain the expected result 1.1');
			Test.stopTest();
		}
	}

	@isTest
	public static void testC2cMakeCall2() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		prepareTest('1.2');
		Test.startTest();
		System.runAs(userGcf){
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			List<String> listResult = AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
			System.assert(listResult.contains('warning'), 'ResultMethod does not contain the expected result 1.2');
			System.assert(listResult.contains(Label.AV_CMP_C2C_ERR_PERMISSIONS) , 'ResultMethod does not contain the expected result 1.2');
		}
		Test.stopTest();
		
	}

	@isTest
	public static void testC2cMakeCall3() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		prepareTest('1.3');
		
		Test.startTest();
		System.runAs(userGcf){
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			List<String> listResult = AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
			System.assert(listResult.contains('error'), 'ResultMethod does not contain the expected result 1.3');
			System.assert(listResult.contains(Label.AV_CMP_C2C_ERR_MOBILE), 'ResultMethod does not contain the expected result 1.3');
		}
		Test.stopTest();
	}	

	@isTest
	public static void testC2cMakeCall4() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		prepareTest('1.4');
		
		Test.startTest();
		System.runAs(userGcf){
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			List<String> listResult = AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
			System.assert(listResult.contains('error'), 'ResultMethod does not contain the expected result 1.4');
			System.assert(listResult.contains(Label.AV_CMP_C2C_ERR_CON_CUSTOMER), 'ResultMethod does not contain the expected result 1.4');
		}
		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCall5() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		prepareTest('1.5');
		
		Test.startTest();
		System.runAs(userGcf){
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			List<String> listResult = AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
			System.assert(listResult.contains('error') , 'ResultMethod does not contain the expected result 1.5');
			System.assert(listResult.contains(Label.AV_UnknownError) , 'ResultMethod does not contain the expected result 1.5');
		}
		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCall6() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		prepareTest('1.6');
		
		Test.startTest();
		System.runAs(userGcf){
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			List<String> listResult = AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
			System.assert(listResult.contains('error'), 'ResultMethod does not contain the expected result 1.6.');
		}
		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCallErr1() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		prepareTest('2');
		
		Test.startTest();
		System.runAs(userGcf){
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			List<String> listResult = AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
			System.assert(listResult.contains('error'), 'ResultMethod does not contain the expected result 1.7.');
		}
		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCallErr2() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		prepareTest('3');
		
		Test.startTest();
		System.runAs(userGcf){
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			List<String> listResult = AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
			System.assert(listResult.contains(AV_AppConstants.ERROR), 'ResultMethod does not contain the expected result Error 3');
	    }
		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCallErr3() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		prepareTest('5');
		
		Test.startTest();
		System.runAs(userGcf){
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			List<String> listResult = AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
			System.assert(listResult.contains(AV_AppConstants.ERROR), 'ResultMethod does not contain the expected result Error 5');
		}
		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCallMock() {
		User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
		
		Test.startTest();
		System.runAs(userGcf){
			AV_C2C_Controller.ClickToCallResponse response = AV_C2C_Controller.getMockResponse();
			System.assert(!String.isEmpty(response.Result) || !String.isEmpty(response.StatusCode),'Mock Response is empty');
		}
		Test.stopTest();
	}
}