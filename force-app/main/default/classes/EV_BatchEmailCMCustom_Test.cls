/*****************************************************************************************
* Name: EV_BatchEmailCMCustom_Test
* Copyright © 2023  CaixaBank
* 
* Proposito: test de la clase EV_BatchEmailCMCustom.
* 
* -------
* VERSION        USER_STORY         AUTHOR              	DATE         Description
* 1.0            US635293           Humberto Vilchez      27/06/2023   	 Init Version
* 1.1            US661500           Carolina Lopez        31/07/2023     Modify executeProcessSendMassEmailBatch use class EV_TestHelper and add mock call
* 1.2            US680535           Mamen Arias           11/08/2023     Change test from 2 days to 1 day.
******************************************************************************************/
@isTest
public with sharing class EV_BatchEmailCMCustom_Test {    
  
    @isTest 
    static void executeProcessSendMassEmailBatch() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        System.runAs(newUser){  
            Date currentDate = System.today();
            Date afterOneDayDate = currentDate.addDays(1);
            
            EV_TestHelper.createCampaignMemberCustomLead(true, false);
            List<Campaign> lstEventoVirtual = [Select id, EV_ExternalId__c, EV_NewArchitecture__c,EV_TechSummit__c  from Campaign Limit 1];
            for(Campaign cm : lstEventoVirtual){
                cm.EV_ExternalId__c = '789132456';
                cm.StartDate = afterOneDayDate;
                cm.EV_TechSummit__c = true;
                cm.Status = '009';
            }
            update lstEventoVirtual;
        }

        Test.startTest();
        System.runAs(newUser){ 
            Map<String, HttpCalloutMock> header2TestResp = new Map<String,HttpCalloutMock>();
			header2TestResp.put('https://qrpass-qrpass.tst.icp-1.internet.cloud.lacaixa.es/qrpass/NEMzNzU4MTg1QjM2MzcxQTAxMzYwQ0MzQTYxMjU5QzM3N0Y2OTMzMjZFREExQUYwQ0IyQzE0Q0M3ODMwNUVBOQ==',new EV_ConexionQR_Mock(200));

            if (DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName() == null) {
                header2TestResp.put('callout:API_GWT_PRO/servicing/registers',new EV_ConexionQR_Mock(200));
                header2TestResp.put('callout:EV_PROAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            } else {
                header2TestResp.put('callout:API_GWT_PRE/servicing/registers',new EV_ConexionQR_Mock(200));
                header2TestResp.put('callout:EV_PREAdobeCampaign',new EV_AdobeCampaignInscripcion_Mock());
            }
            
			HttpCalloutMock multiCalloutMock = new EV_multipleRequestConexionMock_Test(header2TestResp);
			Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            EV_BatchEmailCMCustom batch = new EV_BatchEmailCMCustom();
            Id idJob = Database.executeBatch(batch);
            System.assertNotEquals(null, idJob);
        }
        Test.stopTest();
    }
}