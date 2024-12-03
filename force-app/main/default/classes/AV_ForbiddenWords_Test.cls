/**********************************************************************************************************************
Name:	  AV_ForbiddenWords_Test
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Testing class "AV_ForbiddenWords"
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Álvaro López	   	   07/10/2020		Init version
1.1		    AV_Query IT	   Daniel Rodríguez	   04/02/2022	    Change AV_Query to SOQL for User and Account
***********************************************************************************************************************/
@isTest
public with sharing class AV_ForbiddenWords_Test {
    @TestSetup
    static void setup(){
        AV_TestHelper.createCustomerWithComment();
        CBK_ForbiddenWord__c word = new CBK_ForbiddenWord__c(CBK_EXPRES__c = 'ABELLOTS', CBK_TIPAVI__c = 'E', CBK_IsActive__c = true);
        AV_Bypass__c bypass = new AV_Bypass__c(AV_ForbiddenWords__c = true);
        Database.insert(word, false);
        Database.insert(bypass, false);
    }
    
    @isTest
    private static void forbiddenWordsTest() {
        Test.startTest();
        Map<String, CBK_ForbiddenWord__c> mapForbiddenWords = AV_ForbiddenWords.fetchForbiddenWords();
        String word = mapForbiddenWords.get( new List<String>(mapForbiddenWords.keySet())[0] ).CBK_EXPRES__c;
        String transformedString = AV_ForbiddenWords.transformWords('Forbidden words test: ' + word);
        List<CBK_ForbiddenWord__c> listFW = AV_ForbiddenWords.validateExpr(transformedString, mapForbiddenWords);
        System.assertEquals(word, listFW[0].CBK_EXPRES__c);
        Test.stopTest();
    }
    
    @isTest
    private static void validateMessagesTest() {
        List<List<String>> listWords = new List<List<String>>();
        listWords.add(new List<String>{'ABELLOTS', 'CATOLICA'});
        Test.startTest();
        List<String> listResult = AV_ForbiddenWords.validateMessages(listWords);
        System.assertNotEquals('OK', listResult[0]);
        Test.stopTest();
    }
    
    @isTest
    private static void validateRecordsTest() {
        Set<String> setFields = new Set<String>{'Description'};
        List<Account> listClients = [Select Description From Account limit 1];
        Test.startTest();
        String errorMessage = '';
        if(!listClients.isEmpty()) {
            listClients[0].Description += ' ABELLOTS and CAUCASIC';
            AV_ForbiddenWords.validateRecords(listClients,setFields);

        Test.stopTest();
    	}
    }
}