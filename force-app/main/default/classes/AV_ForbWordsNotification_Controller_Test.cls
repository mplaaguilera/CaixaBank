/**********************************************************************************************************************
Name:		AV_ForbWordsNotification_Controller_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Test class to cover AV_ForbWordsNotification_Controller
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY								AUTHOR				DATE			Description
1.0			Palabras prohibidas						Álvaro López		18/11/2020		Init version
1.1			FIX										Sandra Gómez		26/08/2021		Fix product opportunity
1.2		    AV_Query IT	                            Daniel Rodríguez	04/02/2022	    Change AV_Query to SOQL for User and Account
***********************************************************************************************************************/
@isTest
public with sharing class AV_ForbWordsNotification_Controller_Test {
    @TestSetup
    static void setup(){
        Account dummyAcc = AV_TestHelper.createCustomer();
        dummyAcc.CBK_ForbiddenWords__c = 'CATOLICA';
        Database.update(dummyAcc, false);

		Pricebook2 pb = new Pricebook2();
		pb.Name = 'Standard Price Book';
		Database.insert(pb, false);
        Opportunity dummyOpp = AV_TestHelper.createOpportunity(dummyAcc);
    }

    @isTest
    private static void retrieveMessageTest(){
        Account acc = [Select Id, CBK_ForbiddenWords__c From Account Where CBK_ForbiddenWords__c = 'CATOLICA' limit 1];
        //Account acc = (Account) new AV_Query('Account').selectFields('Id, CBK_ForbiddenWords__c').addConditionEq('CBK_ForbiddenWords__c', 'CATOLICA').fetch();
        
        Test.startTest();
        String message = AV_ForbWordsNotification_Controller.retrieveMessage(String.valueOf(acc.Id), 'Account');
        Test.stopTest();

        System.assertEquals(true, message.contains('CATOLICA'), 'Error al construir mensaje de advertencia.');
    }

    @isTest
    private static void retrieveMessageKOTest(){
        Opportunity opp = [Select Id, CBK_ForbiddenWords__c From Opportunity limit 1];
        //Opportunity opp = (Opportunity) new AV_Query('Opportunity').selectFields('Id, CBK_ForbiddenWords__c').fetch();
        
        Test.startTest();
        String message = AV_ForbWordsNotification_Controller.retrieveMessage(String.valueOf(opp.Id), 'Opportunity');
        Test.stopTest();

        System.assertEquals('KO', message, 'Error al forzar el KO.');
    }
}