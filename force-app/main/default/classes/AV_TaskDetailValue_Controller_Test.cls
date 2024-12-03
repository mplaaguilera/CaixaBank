/**********************************************************************************************************************
Name:	  AV_TaskDetailValue_Controller_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Testing class "AV_TaskDetailValue_Controller"
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Esperanza Conde 	    23/12/2020		Init version
***********************************************************************************************************************/
@isTest
public with sharing class AV_TaskDetailValue_Controller_Test {
    
    @isTest
    private static void getValueLabelTest() {
        
        Test.startTest();

        String result = AV_TaskDetailValue_Controller.getValueLabel('A');
        System.assertEquals('Alta', result);
        Test.stopTest();
    }


}