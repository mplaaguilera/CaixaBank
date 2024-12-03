/**********************************************************************************************************************
Name:     AV_SendInvitationFlowActionTest
-----------------------------------------------------------------------------------------------------------------------
@description Test class for AV_SendInvitationFlowAction
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY          AUTHOR              DATE            Description
1.0         GEO MC              Carolina Lopez      30/09/2024      Include method testgetFilteredCampaignsCus.
***********************************************************************************************************************/
@isTest
public with sharing class AV_SendInvitationFlowActionTest {
    @TestSetup
    static void setup(){
        User userGestor = AV_TestHelper.createUserSinInsert('AV_Usuario_CaixaBank','U01545400', 'AV_SistematicaComercial');
		userGestor.Alias = 'gest';
		userGestor.Email = 'gestor-test@test.com';
		userGestor.IsActive = true;
        insert userGestor;

        User userGcf = [SELECT Id FROM User WHERE Profile.Name = 'API Only' AND Alias = 'AV-TF9' AND IsActive = true];
        System.runAs(userGcf){
            AV_TestHelper.createCampaignMemberContact();
            EV_TestHelper.createCampaignMemberCustomContact(true, false);
        }
    }
    @isTest
    static void testgetFilteredCampaigns(){
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
        List<Campaign> listCampaign = [Select Id from Campaign];
        List<CampaignMember> listCampaignMember = [Select Id, CampaignId from CampaignMember];
        List<AV_CampaignList> listcampList = new List<AV_CampaignList>();
        AV_CampaignList campList = new AV_CampaignList();
        campList.camps = listCampaign;
        campList.campMembers = listCampaignMember;
        listcampList.add(campList);
        Test.startTest();
            System.runAs(userGestor){
                AV_SendInvitationFlowAction.getFilteredCampaigns(listcampList);
            }
        Test.stopTest();
        System.assertNotEquals(listcampList.size(), 0, 'La lista de campañas filtradas no debería estar vacía.');
    }
    @isTest
    static void testgetFilteredCampaignsCus(){
        User userGestor = [SELECT Id FROM User WHERE Profile.Name = 'AV_Usuario_CaixaBank' AND IsActive = true AND Email = 'gestor-test@test.com'];
        List<Campaign> listCampaign = [Select Id from Campaign];
        List<EV_CampaignMemberC__c> listCampaignMemberCus = [Select Id, EV_CampaignId__c from EV_CampaignMemberC__c];
        List<AV_CampaignList> listcampList = new List<AV_CampaignList>();
        AV_CampaignList campList = new AV_CampaignList();
        campList.camps = listCampaign;
        campList.campMembersCus = listCampaignMemberCus;
        listcampList.add(campList);
        Test.startTest();
            System.runAs(userGestor){
                AV_SendInvitationFlowAction.getFilteredCampaigns(listcampList);
            }
        Test.stopTest();
        System.assertNotEquals(listcampList.size(), 0, 'La lista de campañas filtradas no debería estar vacía.');
    }
}