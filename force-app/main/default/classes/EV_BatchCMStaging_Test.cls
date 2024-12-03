/**********************************************************************************************************************
 Name:	  EV_BatchCMStaging_Test
 Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase para batch de EV_BatchCMStaging_Test
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  Daniel Rodriguez    30/09/2022			Add class test

***********************************************************************************************************************/

@isTest
public with sharing class EV_BatchCMStaging_Test {
   /* @TestSetup
    static void makeData(){
        List<EV_CampaingMemeberStaging__c> listcms = new List<EV_CampaingMemeberStaging__c>();
        CampaignMember cm = EV_TestHelper.createCampaignMemberContact(true, false);
        //CampaignMember cm1 = EV_TestHelper.createCampaignMemberContact(false, true);
       
        listcms.add(EV_TestHelper.createCMStaging(cm));
        //listcms.add(EV_TestHelper.createCMStaging(cm));
        //listcms.add(EV_TestHelper.createCMStaging(cm1));
    }*/

    @isTest (SeeAllData=false)
    public static void executeBatchTest() {
        List<EV_CampaingMemeberStaging__c> listcms = new List<EV_CampaingMemeberStaging__c>();
        CampaignMember cm = EV_TestHelper.createCampaignMemberContact(true, false);
       
        listcms.add(EV_TestHelper.createCMStaging(cm));
        listcms.add(EV_TestHelper.createCMStaging(cm));
        Test.startTest();
        EV_BatchCMStaging bcms = new EV_BatchCMStaging();
        Id batchId = Database.executeBatch(bcms);
        Test.stopTest();
        system.assertEquals(batchId != null, true);

    }
    
    @isTest (SeeAllData=false)
    public static void executeBatchTest2() {
        List<EV_CampaingMemeberStaging__c> listcms = new List<EV_CampaingMemeberStaging__c>();
        CampaignMember cm = EV_TestHelper.createCampaignMemberContact(true, false);
       	//Survey sur = [Select id from Survey limit 1];
        //SurveyInvitation  invitation = new SurveyInvitation (EV_Campaign__c = cm.CampaignId);
        Campaign campm = [Select id from Campaign where id = :cm.CampaignId];
        listcms.add(EV_TestHelper.createCMStaging(cm));
        Test.startTest();
        EV_BatchCMStaging bcms = new EV_BatchCMStaging();
        Id batchId = Database.executeBatch(bcms);
        Test.stopTest();
        system.assertEquals(batchId != null, true);

    }
}