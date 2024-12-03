/**********************************************************************************************************************
 Name:	  AV_CustomersSurveys_Integration_Test
 Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Test para AV_CustomersSurveys_Integration.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE			Description
    1.0         US363437        Pablo Martinez      01/06/2022      Init version
***********************************************************************************************************************/

@isTest
public with sharing class AV_CustomersSurveys_Integration_Test{

    @isTest
    public static void validateGetSurveyId(){

        String triggerId = '30309438';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CUSTOMERSURVEY', 'OK') );
        AV_CustomersSurveys_Integration.SurveyResponse result = AV_CustomersSurveys_Integration.getSurveyId(triggerId);
        Test.stopTest();
        
        System.assertEquals('200', result.statusCode, 'statusCode distinto 200');

    }
    @isTest
    public static void validateGetSurveyIdKO(){

        String triggerId = '30309438';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CUSTOMERSURVEY', 'KO') );
        AV_CustomersSurveys_Integration.SurveyResponse result = AV_CustomersSurveys_Integration.getSurveyId(triggerId);
        Test.stopTest();
        
        System.assertEquals('500', result.statusCode, 'statusCode distinto 500');

    }

}