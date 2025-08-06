/**********************************************************************************************************************
Name:	  AV_Canales_Integration_Test
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Test para la integración de Canales
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY	   AUTHOR		   		DATE			Description
1.0			Test Class	   Sandra Gómez	    	08/04/2021		Init version
1.1         US477490       Elisabeth R.         20/01/2023      Added custom setting record

***********************************************************************************************************************/
@isTest
public with sharing class AV_Canales_Integration_Test {
    @TestSetup
    static void setup(){
 		CBK_IntegrationSetting__c channelData = new CBK_IntegrationSetting__c();
        channelData.Name = 'AV_Channels';
        channelData.NamedCredential__c = 'callout:ChannelsIntegrationTest';
        Database.insert(channelData);
        AV_TestHelper.activateLogger();
    }
    
    @isTest
    public static void testcGetChannelsOK() {
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CHANNELS','OK')); 
        AV_Canales_Integration.ChannelResponse response = AV_Canales_Integration.getChannels('54979978');
        Test.stopTest();
        system.assertEquals('200', response.statusCode);
    }
    
    @isTest
    public static void testcGetChannelsKO() {
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CHANNELS','KO')); 
        AV_Canales_Integration.ChannelResponse response = AV_Canales_Integration.getChannels('2679868');
        Test.stopTest();
        system.assertEquals('500', response.statusCode);
    }
}