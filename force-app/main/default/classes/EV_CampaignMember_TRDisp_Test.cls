@isTest
public with sharing class EV_CampaignMember_TRDisp_Test {
    private static testMethod void testUpdateCaseMethod() {
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        CampaignMember testCampaignMember = EV_TestHelper.createCampaignMemberContactEmpresa(false, true);
        campaignMemberList.add(testCampaignMember);
        
         for(CampaignMember mem : campaignMemberList){
        	mem.EV_Empresa__c = true;
        } 
        testCampaignMember.EV_Empresa__c=true;
        Test.startTest();
        update campaignMemberList;
        
        System.assertEquals(true, testCampaignMember.EV_Empresa__c);
        Test.stopTest();
    }
    
}