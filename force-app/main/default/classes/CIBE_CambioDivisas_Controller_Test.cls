/**********************************************************************************************************************
Name:	  CIBE_CambioDivisas_Controller_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR             
    1.0         SF - Integración con API's de Divisas      Jose Maria Fernandez       
***********************************************************************************************************************/

@isTest
public with sharing class CIBE_CambioDivisas_Controller_Test {


    public static final String RESPONSE_DIVISAS	= '[{"ccyData":{"ccyCode":1,"ccyDigits":13,"swiftCode":"ESP","ccyCodeBE":0,"ccyShortName":"PESETA","ccyLongName":""},"exchangeData":{"fixingPurchaseExchange":0,"fixingSaleExchange":166.386,"standardPurchaseExchange":166.386,"standardSaleExchange":166.386,"exchangeOperator":"D","agreementIndicator":""},"rangeData":{"standardPurchaseRange":0,"standardSaleRange":0,"fixingPurchaseRange":0},"decimalNumbers":0,"decimalRoundNumbers":3,"ccyGender":0,"correspondentBank":0,"ccyCountry":0,"isoCcyCode":0,"riskLetterCode":"","validityTime":0,"umeCcyIndicator":"","signalsData":{"quotableSignal":"S","purchaseAllowedSignal":"S","saleAllowedSignal":"S","forcedExchangeSignal":"N","fx4cashCcySignal":"N"}},{"ccyData":{"ccyCode":100,"ccyDigits":7,"swiftCode":"ESP","ccyCodeBE":0,"ccyShortName":"PESETA","ccyLongName":""},"exchangeData":{"fixingPurchaseExchange":0,"fixingSaleExchange":166.386,"standardPurchaseExchange":166.386,"standardSaleExchange":166.386,"exchangeOperator":"D","agreementIndicator":""},"rangeData":{"standardPurchaseRange":0,"standardSaleRange":0,"fixingPurchaseRange":0},"decimalNumbers":0,"decimalRoundNumbers":3,"ccyGender":0,"correspondentBank":0,"ccyCountry":0,"isoCcyCode":0,"riskLetterCode":"","validityTime":0,"umeCcyIndicator":"","signalsData":{"quotableSignal":"S","purchaseAllowedSignal":"S","saleAllowedSignal":"S","forcedExchangeSignal":"N","fx4cashCcySignal":"N"}},{"ccyData":{"ccyCode":102,"ccyDigits":33,"swiftCode":"GBP","ccyCodeBE":0,"ccyShortName":"LIBRA ES","ccyLongName":""},"exchangeData":{"fixingPurchaseExchange":0,"fixingSaleExchange":0.85885,"standardPurchaseExchange":0.88015,"standardSaleExchange":0.84019,"exchangeOperator":"D","agreementIndicator":""},"rangeData":{"standardPurchaseRange":0,"standardSaleRange":0,"fixingPurchaseRange":0},"decimalNumbers":2,"decimalRoundNumbers":5,"ccyGender":0,"correspondentBank":0,"ccyCountry":0,"isoCcyCode":0,"riskLetterCode":"","validityTime":0,"umeCcyIndicator":"","signalsData":{"quotableSignal":"S","purchaseAllowedSignal":"S","saleAllowedSignal":"S","forcedExchangeSignal":"N","fx4cashCcySignal":"N"}},{"ccyData":{"ccyCode":103,"ccyDigits":46,"swiftCode":"USD","ccyCodeBE":0,"ccyShortName":"DOL.USA.","ccyLongName":""},"exchangeData":{"fixingPurchaseExchange":0,"fixingSaleExchange":1.0375,"standardPurchaseExchange":1.059,"standardSaleExchange":1.0109,"exchangeOperator":"D","agreementIndicator":""},"rangeData":{"standardPurchaseRange":0,"standardSaleRange":0,"fixingPurchaseRange":0},"decimalNumbers":2,"decimalRoundNumbers":4,"ccyGender":1,"correspondentBank":0,"ccyCountry":0,"isoCcyCode":0,"riskLetterCode":"","validityTime":0,"umeCcyIndicator":"","signalsData":{"quotableSignal":"S","purchaseAllowedSignal":"S","saleAllowedSignal":"S","forcedExchangeSignal":"N","fx4cashCcySignal":"N"}}]';

   
 

     @isTest
    private static void testSendRequestCheckReponse() {
        CIBE_CambioDivisas_Controller.Response eventResponse = new CIBE_CambioDivisas_Controller.Response();
        CIBE_CambioDivisas_Controller.Response eventResponseFakeJson = new CIBE_CambioDivisas_Controller.Response();

        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('DIVISAS','OK'));
        eventResponseFakeJson.data = (List<CIBE_CambioDivisas_Controller.ResponseData>)JSON.deserialize(RESPONSE_DIVISAS, List<CIBE_CambioDivisas_Controller.ResponseData>.class);  

        Test.StartTest();
        eventResponse= CIBE_CambioDivisas_Controller.sendRequest('{"option":4,"requestType":"D"}');
        Test.StopTest();

        System.debug('eventResponseFakeJson.data: ' + eventResponseFakeJson.data);
        System.debug('eventResponse.data: ' + eventResponse.data);  

        System.assertEquals(200, eventResponse.statusCode);


    }
    

    @isTest
    private static void testSendRequestCompareDivisas() {
        CIBE_CambioDivisas_Controller.Response eventResponse = new CIBE_CambioDivisas_Controller.Response();
        CIBE_CambioDivisas_Controller.Response eventResponseFakeJson = new CIBE_CambioDivisas_Controller.Response();

        List<CIBE_Divisas__c> divisas = new List<CIBE_Divisas__c>();
        List<CIBE_Divisas__c> divisasFake = new List<CIBE_Divisas__c>();

        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('DIVISAS','OK'));
        eventResponseFakeJson.data = (List<CIBE_CambioDivisas_Controller.ResponseData>)JSON.deserialize(RESPONSE_DIVISAS, List<CIBE_CambioDivisas_Controller.ResponseData>.class);  

        Test.StartTest();
       
        divisas = CIBE_CambioDivisas_Controller.getDivisas();
        divisasFake = CIBE_CambioDivisas_Controller.jsonToDatabase( eventResponseFakeJson.data);
        Test.StopTest();

        System.debug('eventResponseFakeJson.data: ' + eventResponseFakeJson.data);
        System.debug('eventResponse.data: ' + eventResponse.data);  

        System.assertEquals(divisasFake, divisas);


    }


   
}