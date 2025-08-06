/**********************************************************************************************************************
 Name: EV_CMRecuentoTotalesTest
 Copyright © 2024  CaixaBank
----------------------------------------------------------------------------------------------------------------------
@description Clase de test para el recuento de totales en (EV_CMRecuentoTotales).
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION      USER_STORY	    AUTHOR				DATE			Description
 * 1.0		    FIX	            Carolina Lopez		17/06/2024   	Init Version
***********************************************************************************************************************/
@isTest
public with sharing class EV_CMRecuentoTotalesTest {
  
  @isTest(SeeAllData=true)
	private static void updateCMRecuentoTotalesFisicoAsisTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<EV_CMRecuentoTotales.OutputParameters> result  = new List<EV_CMRecuentoTotales.OutputParameters>();
        List<EV_CMRecuentoTotales.InputParameters> inputParams = new List<EV_CMRecuentoTotales.InputParameters>();
		EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
        System.runAs(newUser){
            campMember = EV_TestHelper.createCampaignMemberCustomContactFisicaSurvey('Asistió');
        }
		Test.startTest();
		System.runAs(newUser){
            EV_CMRecuentoTotales.InputParameters param = new EV_CMRecuentoTotales.InputParameters();
            param.recordId = campMember.EV_CampaignId__c;
            inputParams.add(param);
            result = EV_CMRecuentoTotales.updateCMRecuentoTotales(inputParams);
		}
		Test.stopTest();
        System.assertEquals('true', result[0].resultUpdate, 'OK');	
    }

    @isTest(SeeAllData=true)
	private static void updateCMRecuentoTotalesFisicoAsisAggListTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<EV_CMRecuentoTotales.OutputParameters> result  = new List<EV_CMRecuentoTotales.OutputParameters>();
        List<EV_CMRecuentoTotales.InputParameters> inputParams = new List<EV_CMRecuentoTotales.InputParameters>();
		EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
        System.runAs(newUser){
            campMember = EV_TestHelper.createCampaignMemberCustomContactFisicaSurvey('Asistió');
            EV_CMRecuentoTotales.aggTest = new Map<Id,Integer>();
            EV_CMRecuentoTotales.aggTest.put(campMember.EV_campaignId__c, 1);
        }
		Test.startTest();
		System.runAs(newUser){
            EV_CMRecuentoTotales.InputParameters param = new EV_CMRecuentoTotales.InputParameters();
            param.recordId = campMember.EV_CampaignId__c;
            inputParams.add(param);
            result = EV_CMRecuentoTotales.updateCMRecuentoTotales(inputParams);
		}
		Test.stopTest();
        System.assertEquals('true', result[0].resultUpdate, 'OK');	
    }

    @isTest(SeeAllData=true)
	private static void updateCMRecuentoTotalesVirtualAsistTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<EV_CMRecuentoTotales.OutputParameters> result  = new List<EV_CMRecuentoTotales.OutputParameters>();
        List<EV_CMRecuentoTotales.InputParameters> inputParams = new List<EV_CMRecuentoTotales.InputParameters>();
		EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
        Campaign camp = new Campaign();
        System.runAs(newUser){
            Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null LIMIT 1];
            camp = EV_TestHelper.createChildCampaignVirtualCMCustomTechSummit();
            camp.EV_Encuesta__c = surv.id;
            update camp;
            campMember = EV_TestHelper.createCampaignMemberCustomLeadTechSummitHibrido(camp.id);
            campMember.EV_Status__c = 'Asistió';
            update campMember;
        }
		Test.startTest();
		System.runAs(newUser){
            EV_CMRecuentoTotales.InputParameters param = new EV_CMRecuentoTotales.InputParameters();
            param.recordId = campMember.EV_CampaignId__c;
            inputParams.add(param);
            result = EV_CMRecuentoTotales.updateCMRecuentoTotales(inputParams);
		}
		Test.stopTest();
        System.assertEquals('true', result[0].resultUpdate, 'OK');	
    }

    @isTest(SeeAllData=true)
	private static void updateCMRecuentoTotalesVirtualAsistAggListTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<EV_CMRecuentoTotales.OutputParameters> result  = new List<EV_CMRecuentoTotales.OutputParameters>();
        List<EV_CMRecuentoTotales.InputParameters> inputParams = new List<EV_CMRecuentoTotales.InputParameters>();
		EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
        Campaign camp = new Campaign();
        System.runAs(newUser){
            Survey surv = [SELECT Id FROM Survey WHERE ActiveVersionId != null LIMIT 1];
            camp = EV_TestHelper.createChildCampaignVirtualCMCustomTechSummit();
            camp.EV_Encuesta__c = surv.id;
            update camp;
            campMember = EV_TestHelper.createCampaignMemberCustomLeadTechSummitHibrido(camp.id);
            campMember.EV_Status__c = 'Asistió';
            update campMember;
            EV_CMRecuentoTotales.aggTest = new Map<Id,Integer>();
            EV_CMRecuentoTotales.aggTest.put(campMember.EV_campaignId__c, 1);
        }
		Test.startTest();
		System.runAs(newUser){
            EV_CMRecuentoTotales.InputParameters param = new EV_CMRecuentoTotales.InputParameters();
            param.recordId = campMember.EV_CampaignId__c;
            inputParams.add(param);
            result = EV_CMRecuentoTotales.updateCMRecuentoTotales(inputParams);
		}
		Test.stopTest();
        System.assertEquals('true', result[0].resultUpdate, 'OK');	
    }

    @isTest
	private static void updateCMRecuentoTotalesRegConfirmadoFisicoTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<EV_CMRecuentoTotales.OutputParameters> result  = new List<EV_CMRecuentoTotales.OutputParameters>();
        List<EV_CMRecuentoTotales.InputParameters> inputParams = new List<EV_CMRecuentoTotales.InputParameters>();
		Lead interlocutor = new Lead();
		Campaign campTechSumm = new Campaign();
		EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
        System.runAs(newUser){
            interlocutor = EV_TestHelper.createLeadAuxTechSummit('Tech Summit Virtual');
            campTechSumm = EV_TestHelper.createCampaignTechSummit(false, true);
            campTechSumm.EV_InscritosFisicosC__c = 1;
            update campTechSumm;
			campMember = EV_TestHelper.createCampaignMemberLeadCampaignTechSummit(interlocutor.Id, campTechSumm.Id, 'Registro Confirmado');
        }
		Test.startTest();
		System.runAs(newUser){
            EV_CMRecuentoTotales.InputParameters param = new EV_CMRecuentoTotales.InputParameters();
            param.recordId = campMember.EV_CampaignId__c;
            inputParams.add(param);
            result = EV_CMRecuentoTotales.updateCMRecuentoTotales(inputParams);
		}
		Test.stopTest();
        System.assertEquals('true', result[0].resultUpdate, 'OK');	
    }

    @isTest
	private static void updateCMRecuentoTotalesRegConfirmadoFisicoAggListTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<EV_CMRecuentoTotales.OutputParameters> result  = new List<EV_CMRecuentoTotales.OutputParameters>();
        List<EV_CMRecuentoTotales.InputParameters> inputParams = new List<EV_CMRecuentoTotales.InputParameters>();
		Lead interlocutor = new Lead();
		Campaign campTechSumm = new Campaign();
		EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
        System.runAs(newUser){
            interlocutor = EV_TestHelper.createLeadAuxTechSummit('Tech Summit Virtual');
            campTechSumm = EV_TestHelper.createCampaignTechSummit(false, true);
            campTechSumm.EV_InscritosFisicosC__c = 1;
            update campTechSumm;
			campMember = EV_TestHelper.createCampaignMemberLeadCampaignTechSummit(interlocutor.Id, campTechSumm.Id, 'Registro Confirmado');
            EV_CMRecuentoTotales.aggTest = new Map<Id,Integer>();
            EV_CMRecuentoTotales.aggTest.put(campMember.EV_campaignId__c, 1);
        }
		Test.startTest();
		System.runAs(newUser){
            EV_CMRecuentoTotales.InputParameters param = new EV_CMRecuentoTotales.InputParameters();
            param.recordId = campMember.EV_CampaignId__c;
            inputParams.add(param);
            result = EV_CMRecuentoTotales.updateCMRecuentoTotales(inputParams);
		}
		Test.stopTest();
        System.assertEquals('true', result[0].resultUpdate, 'OK');	
    }

    @isTest
	private static void updateCMRecuentoTotalesRegConfirmadoVirtualTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<EV_CMRecuentoTotales.OutputParameters> result  = new List<EV_CMRecuentoTotales.OutputParameters>();
        List<EV_CMRecuentoTotales.InputParameters> inputParams = new List<EV_CMRecuentoTotales.InputParameters>();
		Lead interlocutor = new Lead();
		Campaign campTechSumm = new Campaign();
		EV_CampaignMemberC__c campMember  = new EV_CampaignMemberC__c();
        System.runAs(newUser){
            interlocutor = EV_TestHelper.createLeadAuxTechSummit('Tech Summit Virtual');
            campTechSumm = EV_TestHelper.createCampaignTechSummit(true, false);
            campTechSumm.EV_InscritosVirtualesC__c = 1;
            update campTechSumm;
			campMember = EV_TestHelper.createCampaignMemberLeadCampaignTechSummit(interlocutor.Id, campTechSumm.Id, 'Registro Confirmado');
        }
		Test.startTest();
		System.runAs(newUser){
            EV_CMRecuentoTotales.InputParameters param = new EV_CMRecuentoTotales.InputParameters();
            param.recordId = campMember.EV_CampaignId__c;
            inputParams.add(param);
            result = EV_CMRecuentoTotales.updateCMRecuentoTotales(inputParams);
		}
		Test.stopTest();
        System.assertEquals('true', result[0].resultUpdate, 'OK');	
    }

    @isTest
	private static void updateCMRecuentoTotalesErrorCampTest(){
		User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','EV Gestor Eventos Senior','Eventos');
        List<EV_CMRecuentoTotales.OutputParameters> result  = new List<EV_CMRecuentoTotales.OutputParameters>();
        List<EV_CMRecuentoTotales.InputParameters> inputParams = new List<EV_CMRecuentoTotales.InputParameters>();
		Test.startTest();
		System.runAs(newUser){
            EV_CMRecuentoTotales.InputParameters param = new EV_CMRecuentoTotales.InputParameters();
            param.recordId = null;
            inputParams.add(param);
            result = EV_CMRecuentoTotales.updateCMRecuentoTotales(inputParams);
		}
		Test.stopTest();
        System.assertEquals('false', result[0].resultUpdate, 'Error');	
    }
}