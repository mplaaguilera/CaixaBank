@isTest
public with sharing class AV_SendInvitationFlowActionTest {
    @TestSetup
    static void setup(){
        //Campaign campTest = AV_TestHelper.createCampaign();
        CampaignMember campMemberTest = AV_TestHelper.createCampaignMemberContact();

    }

    @isTest
    static void testgetFilteredCampaigns(){

        List<Campaign> listCampaign = [Select Id from Campaign ];
        System.debug('listCampaign ' + listCampaign);
        List<CampaignMember> listCampaignMember = [Select Id, CampaignId from CampaignMember];
        List<AV_CampaignList> listcampList = new List<AV_CampaignList>();
        AV_CampaignList campList = new AV_CampaignList();
        campList.camps = listCampaign;
        campList.campMembers = listCampaignMember;
        listcampList.add(campList);
        System.debug('campList ' + campList);
        Test.startTest();
        AV_SendInvitationFlowAction.getFilteredCampaigns(listcampList);

        Test.stopTest();
    }
}