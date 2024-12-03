/**********************************************************************************************************************
 Name: EV_TestPublic_Test
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test para la creación de Lead y CampaignMember custom con información de contactos (EV_TestPublic).
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION      USER_STORY	    AUTHOR				DATE			Description
 * 1.0		    US567184	    Carolina Lopez		10/10/2023   	Init Version
***********************************************************************************************************************/
@IsTest
public class EV_TestPublic_Test {
    @isTest
    static void createCMLeadCampFisico_Test() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest();
        System.runAs(newUser){
            Campaign camp = EV_TestHelper.createChildCampaignFisica();
            List<Contact> lstContact = EV_TestHelper.createEmployeeTestPublic();

            EV_TestPublic.InputParameters params = new EV_TestPublic.InputParameters();
            params.recordTypeCamp = camp.RecordTypeId;
            params.recordId = camp.Id;
            params.lstContact = lstContact;

            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));

            EV_TestPublic.createCampaignMemberLead(new List<EV_TestPublic.InputParameters>{params});

            List<Lead> leadCount = [Select id, FirstName from Lead where  FirstName in('Empleado', 'Adolfo')];
            List<EV_CampaignMemberC__c> campaignMemberCount = [Select id from EV_CampaignMemberC__c];
            System.assertEquals(lstContact.size(), leadCount.size(), 'No se crearon todos los registros de Lead esperados.');
            System.assertEquals(lstContact.size(), campaignMemberCount.size(), 'No se crearon todos los registros de CampaignMember esperados.');
        }
        Test.stopTest();
    }
    @isTest
    static void createCMLeadCampAcc_Test() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Test.startTest();
        System.runAs(newUser){  
            List<Contact> lstContact = EV_TestHelper.createEmployeeTestPublic();
            Campaign camp = EV_TestHelper.createCampaignAccionista();

            EV_TestPublic.InputParameters params = new EV_TestPublic.InputParameters();
            params.recordTypeCamp = camp.RecordTypeId;
            params.recordId = camp.Id;
            params.lstContact = lstContact;

            Test.setMock(HttpCalloutMock.class, new EV_ConexionQR_Mock(200));

            EV_TestPublic.createCampaignMemberLead(new List<EV_TestPublic.InputParameters>{params});

            List<Lead> leadCount = [Select id, FirstName from Lead where  FirstName in('Empleado', 'Adolfo')];
            List<EV_CampaignMemberC__c> campaignMemberCount = [Select id from EV_CampaignMemberC__c];
            System.assertEquals(lstContact.size(), leadCount.size(), 'No se crearon todos los registros de Lead esperados.');
            System.assertEquals(lstContact.size(), campaignMemberCount.size(), 'No se crearon todos los registros de CampaignMember esperados.');
        }
        Test.stopTest();
    }
}