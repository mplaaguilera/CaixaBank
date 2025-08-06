/**********************************************************************************************************************
Name:	  AV_ChannelsUsage_Controller_Test
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase Test de AV_ChannelsUsage_Controller
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY							   AUTHOR			  DATE				Description
1.0			Init version                           Sandra Gómez		  16/04/2021		Init version
1.1		    AV_Query IT	                           Daniel Rodríguez	  04/02/2022	    Change AV_Query to SOQL for User and Account
1.2         US477490                               Elisabeth R.       20/01/2023        Added custom setting record
***********************************************************************************************************************/
@isTest
public with sharing class AV_ChannelsUsage_Controller_Test {
    @TestSetup
    static void setup(){
        CBK_IntegrationSetting__c channelData = new CBK_IntegrationSetting__c();
        channelData.Name = 'AV_Channels';
        channelData.NamedCredential__c = 'callout:ChannelsIntegrationTest';
        Database.insert(channelData);
        AV_TestHelper.activateLogger();
        AV_TestHelper.createCustomerWithNumperson('54979978');
    }
    
    @isTest
    public static void testGetChannels() {
        Test.startTest();
        //List<Account> acc=new AV_Query('Account').selectFields('Id').setLimit(1).run();
        List<Account> acc = [Select Id From Account limit 1];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CHANNELS','OK')); 
        AV_ChannelsUsage_Controller.Response response = AV_ChannelsUsage_Controller.getChannels(acc[0].id);
        Test.stopTest();
        system.assertEquals('ok', response.severity);
    }
    
    @isTest
    public static void testGetChannelsKO() {
        Test.startTest();
        //List<Account> acc=new AV_Query('Account').selectFields('Id').setLimit(1).run();
        List<Account> acc = [Select Id From Account limit 1];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CHANNELS','KO')); 
        AV_ChannelsUsage_Controller.Response response = AV_ChannelsUsage_Controller.getChannels(acc[0].id);
        Test.stopTest();
        system.assertEquals('error', response.severity);
    }
    
    @isTest
    public static void testGetChannelsErrorId() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CHANNELS','OK')); 
        AV_ChannelsUsage_Controller.Response response = AV_ChannelsUsage_Controller.getChannels('12345');
        Test.stopTest();
        system.assertEquals('error', response.severity);
    }
    
    @isTest
    public static void testGetChannelsDoble() {
        Test.startTest();
        //List<Account> acc=new AV_Query('Account').selectFields('Id').setLimit(1).run();
        List<Account> acc = [Select Id From Account limit 1];
        Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CHANNELS','OK')); 
        AV_ChannelsUsage_Controller.Response response = AV_ChannelsUsage_Controller.getChannels(acc[0].id);
        AV_ChannelsUsage_Controller.Response response2 = AV_ChannelsUsage_Controller.getChannels(acc[0].id);
        Test.stopTest();
        system.assertEquals('ok', response2.severity);
    }
    
    @isTest
    public static void testGetChannelsDataNull() {
        Test.startTest();
        //List<Account> acc=new AV_Query('Account').selectFields('Id').setLimit(1).run(); 
        List<Account> acc = [Select Id From Account limit 1];
        AV_ChannelsUsage_Controller.Response response = AV_ChannelsUsage_Controller.getChannels(acc[0].id);
        Test.stopTest();
        system.assertEquals('error', response.severity);
    }
}