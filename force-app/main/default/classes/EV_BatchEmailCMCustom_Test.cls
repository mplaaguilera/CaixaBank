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
* 1.3            FIX                Carolina Lopez        05/02/2024     Modify executeProcessSendMassEmailBatch with seeAllData > ConnectApi Error. 
* 1.4            TechSummit         Carolina Lopez        11/06/2024     Modify executeProcessSendMassEmailBatch with method createCampaignMemberCustomLeadTechSummit.
* 1.5            TechSummit         Carolina Lopez        04/09/2024     Modify executeProcessSendMassEmailBatch with the status record confirmed.
******************************************************************************************/
@isTest
public with sharing class EV_BatchEmailCMCustom_Test {    
  
    @isTest(SeeAllData=true)
    static void executeProcessSendMassEmailBatch() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        System.runAs(newUser){  
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new EV_AdobeCampaignInscripcion_Mock());
            Date currentDate = System.today();
            Date afterOneDayDate = currentDate.addDays(1);
            EV_CampaignMemberC__c cmCus = EV_TestHelper.createCampaignMemberCustomLeadTechSummit(true, false);
            cmCus.EV_Status__c = 'Registro confirmado';
            update cmCus;
            Campaign eventoVirtual = [SELECT Id, EV_ExternalId__c, EV_TechSummit__c FROM Campaign WHERE Id =:cmCus.EV_CampaignId__c LIMIT 1];
            eventoVirtual.EV_ExternalId__c = '789132456'; 
            eventoVirtual.StartDate = afterOneDayDate;
            eventoVirtual.EV_TechSummit__c = true;
            eventoVirtual.Status = '009';
            update eventoVirtual;
            EV_BatchEmailCMCustom batch = new EV_BatchEmailCMCustom();
            Id idJob = Database.executeBatch(batch);
            System.assertNotEquals(null, idJob);
            Test.stopTest();
        }
    }
}