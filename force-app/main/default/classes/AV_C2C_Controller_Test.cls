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

***********************************************************************************************************************/
@isTest
public with sharing class AV_C2C_Controller_Test {

	@TestSetup
	static void setup(){
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
		prepareTest('1.1');
		Test.startTest();

		try {
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCall: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCall2() {
		prepareTest('1.2');
		Test.startTest();

		try {
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCall2: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCall3() {
		prepareTest('1.3');
		Test.startTest();

		try {
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCall3: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCall4() {
		prepareTest('1.4');
		Test.startTest();

		try {
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCall4: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCall5() {
		prepareTest('1.5');
		Test.startTest();

		try {
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCall5: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCall6() {
		prepareTest('1.6');
		Test.startTest();

		try {
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCall6: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCallErr1() {
		prepareTest('2');
		Test.startTest();

		try {
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCallErr1: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCallErr2() {
		prepareTest('3');
		Test.startTest();

		try {
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCallErr2: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCallErr3() {
		prepareTest('5');
		Test.startTest();

		try {
			String calledDevice = '760924833';
			String callingDevice = '773637562';
			AV_C2C_Controller.c2cMakeCall(calledDevice, callingDevice);
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCallErr3: ' + e.getMessage());
		}

		Test.stopTest();
	}

	@isTest
	public static void testC2cMakeCallMock() {
		Test.startTest();

		try {
			AV_C2C_Controller.getMockResponse();
		}catch(System.Exception e){
			System.debug(LoggingLevel.ERROR, 'testC2cMakeCallMock: ' + e.getMessage());
		}

		Test.stopTest();
	}
}