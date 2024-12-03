@isTest
public with sharing class AV_SendInvitationCampaignFilteredTest {
    @TestSetup
    static void setup(){
        //Campaign campTest = AV_TestHelper.createCampaign();
        Centro_Objetivo__c centroObjTest = AV_TestHelper.createCentroObjetivo();

    }

    @isTest
    static void testgetFilteredCampaignCentros(){

        List<Campaign> listCampaign = [Select Id from Campaign ];
        System.debug('listCampaign ' + listCampaign);
        List<Centro_Objetivo__c> listCentroObjetivo = [Select Id, EV_Campaign__c from Centro_Objetivo__c];
        System.debug('listCentroObjetivo ' + listCentroObjetivo);
        List<AV_CampaignList> listcampList = new List<AV_CampaignList>();
        AV_CampaignList campList = new AV_CampaignList();
        campList.camps = listCampaign;
        campList.centrosObj = listCentroObjetivo;
        listcampList.add(campList);
        System.debug('campList ' + campList);
        Test.startTest();
        AV_SendInvitationCampaignFilter.getFilteredCampaignCentros(listcampList);

        Test.stopTest();
    }
}