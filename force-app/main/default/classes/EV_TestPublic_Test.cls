/**********************************************************************************************************************
 Name: EV_TestPublic_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test para la creación de Lead y CampaignMember custom con información de contactos (EV_TestPublic).
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION      USER_STORY	    AUTHOR				DATE			Description
 * 1.0		    US567184	    Carolina Lopez		10/10/2023   	Init Version
 * 1.1          FIX             Carolina Lopez      01/02/2024      Add methods seeAllData > ConnectApi Error.
 * 1.2          TechSummit      Carolina Lopez      17/05/2024      Add methods createCMLeadCampFisicoTechSummit_Test.
***********************************************************************************************************************/
@IsTest
public class EV_TestPublic_Test {
    @isTest(SeeAllData=true)
    static void createCMLeadCampFisicoTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));

            Campaign camp = EV_TestHelper.createChildCampaignFisica();
            List<Contact> lstContact = EV_TestHelper.createEmployeeTestPublic();

            EV_TestPublic.InputParameters params = new EV_TestPublic.InputParameters();
            params.recordTypeCamp = camp.RecordTypeId;
            params.recordId = camp.Id;
            params.lstContact = lstContact;
            EV_TestPublic.createCampaignMemberLead(new List<EV_TestPublic.InputParameters>{params});

            Integer leadCount = [Select count() from Lead where FirstName in('Empleado', 'Adolfo') AND Phone IN('607047900','607047934')];
            Integer campaignMemberCount = [Select count() from EV_CampaignMemberC__c where EV_CampaignId__c =: camp.Id];
            System.assertEquals(lstContact.size(), leadCount, 'No se crearon todos los registros de Lead esperados.');
            System.assertEquals(lstContact.size(), campaignMemberCount, 'No se crearon todos los registros de CampaignMember esperados.');
        }
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void createCMLeadCampAccTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest();
        System.runAs(newUser){  
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));

            List<Contact> lstContact = EV_TestHelper.createEmployeeTestPublic();
            Campaign camp = EV_TestHelper.createCampaignAccionista();

            EV_TestPublic.InputParameters params = new EV_TestPublic.InputParameters();
            params.recordTypeCamp = camp.RecordTypeId;
            params.recordId = camp.Id;
            params.lstContact = lstContact;
            EV_TestPublic.createCampaignMemberLead(new List<EV_TestPublic.InputParameters>{params});

            Integer leadCount = [Select count() from Lead where FirstName in('Empleado', 'Adolfo') AND Phone IN('607047900','607047934')];
            Integer campaignMemberCount = [Select count() from EV_CampaignMemberC__c where EV_CampaignId__c =: camp.Id];
            System.assertEquals(lstContact.size(), leadCount, 'No se crearon todos los registros de Lead esperados.');
            System.assertEquals(lstContact.size(), campaignMemberCount, 'No se crearon todos los registros de CampaignMember esperados.');
        }
        Test.stopTest();
    }
    @isTest(SeeAllData=true)
    static void createCMLeadCampFisicoTechSummitTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));

            Campaign camp = EV_TestHelper.createChildCampaignFisicaCMCustomTechSummit();
            List<Contact> lstContact = EV_TestHelper.createEmployeeTestPublic();

            EV_TestPublic.InputParameters params = new EV_TestPublic.InputParameters();
            params.recordTypeCamp = camp.RecordTypeId;
            params.recordId = camp.Id;
            params.lstContact = lstContact;
            EV_TestPublic.createCampaignMemberLead(new List<EV_TestPublic.InputParameters>{params});

            Integer leadCount = [Select count() from Lead where FirstName in('Empleado', 'Adolfo') AND Phone IN('607047900','607047934')];
            Integer campaignMemberCount = [Select count() from EV_CampaignMemberC__c where EV_CampaignId__c =: camp.Id];
            System.assertEquals(lstContact.size(), leadCount, 'No se crearon todos los registros de Lead esperados.');
            System.assertEquals(lstContact.size(), campaignMemberCount, 'No se crearon todos los registros de CampaignMember esperados.');
        }
        Test.stopTest();
    }
}