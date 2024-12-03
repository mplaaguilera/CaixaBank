/**********************************************************************************************************************
 Name:	  EV_Utilities_Test
 Copyright © 2022  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para test de EV_Utilities
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  Daniel Rodriguez    27/09/2022			Init version
    1.1         US760328          Carolina Lopez      05/12/2023            Include runAs in all methods and add the method testGetRecordTypeIdsInSet. 
  	1.2			US511092       	  Daniel Rodriguez 	  09/01/2024			Remove system.debug
***********************************************************************************************************************/

@isTest
public with sharing class EV_Utilities_Test {

    @isTest
	public static void testGenerateSecureId() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        String key = '';
        System.runAs(newUser){
            key = EV_Utilities.generateSecureId('dsafdsafdsaewrew');
        }
        system.assertEquals(String.isNotBlank(key), key != '', 'KO');
    }
    
    @isTest
	public static void testSetId() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        set<String> setIds = new set<String>{'000033033303', '24324325345'};
        String listIds = '';
        System.runAs(newUser){
            listIds = EV_Utilities.setToStringIn(setIds);
        }
        system.assertEquals(String.isNotBlank(listIds), listIds != '', 'KO');
    }

    @isTest
	public static void testGenerateRandomString() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        String codigo = '';
        System.runAs(newUser){
            codigo = EV_Utilities.generateRandomString(4);
        }
        system.assertEquals(String.isNotBlank(codigo), codigo != '', 'KO'); 
    }

    @isTest
    public static void testGetRecordTypeIdsInSet() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Set<Id> recordTypeIds;
        System.runAs(newUser){
            EV_Utilities.SearchRT rtOpportunity = new EV_Utilities.SearchRT('Opportunity', 'AV_Iniciativa');
            EV_Utilities.SearchRT rtTask = new EV_Utilities.SearchRT('Task', 'AV_AlertaComercial');
            EV_Utilities.SearchRT rtEvent = new EV_Utilities.SearchRT('Event', 'AV_EventosConCliente');
            EV_Utilities.SearchRT rtAccount = new EV_Utilities.SearchRT('Account', 'CC_Cliente');
            EV_Utilities.SearchRT rtContact = new EV_Utilities.SearchRT('Contact', 'CC_Cliente');
            EV_Utilities.SearchRT rtCampaign = new EV_Utilities.SearchRT('Campaign', 'EV_EventoFisico');
            EV_Utilities.SearchRT rtCampaignMember = new EV_Utilities.SearchRT('CampaignMember', 'EV_Eventos');
            EV_Utilities.SearchRT rtCustomObject = new EV_Utilities.SearchRT('EV_CampaignMemberC__c', 'EV_Eventos');

            Set<EV_Utilities.SearchRT> setRTs = new Set<EV_Utilities.SearchRT>{
                rtOpportunity, rtTask, rtEvent, rtAccount, rtContact, rtCampaign, rtCampaignMember, rtCustomObject
            };

            recordTypeIds = EV_Utilities.getRecordTypeIdsInSet(setRTs);
        }
        System.assertNotEquals(0, recordTypeIds.size(), 'Record Type Ids should not be empty');
    }

    public static void getEventoTraduccionesTest() {
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Lead interlocutor = new Lead();
        Campaign campTechSumm = new Campaign();
        EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
        List<EV_TraduccionDeEvento__c> listTraducciones = new List<EV_TraduccionDeEvento__c>();
        Set<Id> campaignIds = New Set<Id>();

        System.runAs(newUser){  
            interlocutor = EV_TestHelper.createLeadAuxTechSummit('Tech Summit Virtual');
            campTechSumm = EV_TestHelper.createCampaignTechSummit(true, false);
            campMember = EV_TestHelper.createCampaignMemberLeadCampaignTechSummit(interlocutor.Id, campTechSumm.Id, 'Registro Confirmado');
            listTraducciones = EV_TestHelper.createTraslationEvt(campTechSumm);
            campaignIds.add(campTechSumm.Id);
        }
        
        System.runAs(newUser){  
            Test.startTest();
            Map<Id,Map<String,EV_TraduccionDeEvento__c>> traducciones = EV_Utilities.getEventoTraducciones(campaignIds);            
            Test.stopTest();
            System.assertNotEquals(traducciones.get(campTechSumm.Id).get('001'), null);
            System.assertNotEquals(traducciones.get(campTechSumm.Id).get('002'), null);
        }
    }
}