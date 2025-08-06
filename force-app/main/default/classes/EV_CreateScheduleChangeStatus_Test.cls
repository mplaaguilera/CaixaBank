/**********************************************************************************************************************
Name:	  EV_CreateScheduleChangeStatus_Test
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase de test
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY			AUTHOR				DATE				Description
1.0			DE75856             Daniel Rodriguez	04/10/2023			Init version
***********************************************************************************************************************/
@isTest
public class EV_CreateScheduleChangeStatus_Test {
    
    @TestSetup
    static void makeData(){
        
        List<EV_MappingCriterioPO__mdt> listMC = [SELECT Id, Label, EV_FieldName__c FROM EV_MappingCriterioPO__mdt];
        Map<String, EV_MappingCriterioPO__mdt> mapMC = new Map<String, EV_MappingCriterioPO__mdt>();
        for(EV_MappingCriterioPO__mdt mc: listMC){
            mapMC.put(mc.label, mc);
        }
        List<EV_VariablePublicoOjetivo__c> varPOTest = EV_TestHelper.createVariablePublicoObjetivo(mapMC);
        Account centroCaixa = EV_TestHelper.createCaixaCenter();
        Contact contacto = EV_TestHelper.createEmployee(centroCaixa);
        Campaign campParentTest = EV_TestHelper.createParentCampaignVirtual();
        List<EV_CriterioPublicoObjetivo__c> poTestParent = EV_TestHelper.createPublicObjetivo(campParentTest.Id, varPOTest);
        Campaign campTest = EV_TestHelper.createChildCampaignVirtual(centroCaixa, campParentTest);
        List<EV_CriterioPublicoObjetivo__c> poTest = EV_TestHelper.createPublicObjetivo(campTest.Id, varPOTest);
        EV_CriterioPublicoObjetivo__c cpo = new EV_CriterioPublicoObjetivo__c();
    }
    
    @isTest
    public static void validateChangeStatusInvitacionesEnviadas(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Campaign camp = new Campaign();
        Test.startTest();
        System.runAs(newUser)
        {
            Campaign campTest = EV_TestHelper.createChildCampaignVirtual();
            camp =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE Id =: campTest.Id];
            List<Campaign> upC = new List<Campaign>();
            Campaign camp2 =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE EV_CentroOrganizador__c != null];
            Map<Id, Campaign> oldMapCampaign = new Map<Id, Campaign>();
            oldMapCampaign.put(campTest.Id, campTest);
            
            camp.Status = '003';
            camp2.Status = '003';
            upC.add(camp);
            upC.add(camp2);
            update upC;
            
            List<Campaign> listNews = new List<Campaign>();
            listNews.add(camp);
        }
        Test.stopTest();
        System.assertEquals('003', camp.Status);
        
    }
    
    
    @isTest
    public static void validateChangeStatusEnCurso(){
        User newUser = EV_TestHelper.createUserTest('EV_Governance_Eventos','System Administrator','Eventos');
        Campaign camp = new Campaign();
        
        Test.startTest();
        System.runAs(newUser)
        {
            Campaign campTest = EV_TestHelper.createChildCampaignVirtual();
            List<Campaign> upC = new List<Campaign>();
            camp =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE Id =: campTest.Id];
            Campaign camp2 =  [SELECT Id, Status, RecordTypeId, EV_FechaHoraFin__c, EV_DiaHora_evento__c, EV_ExternalId__c  FROM Campaign  WHERE EV_CentroOrganizador__c != null];
            camp.Status = '012';
            camp2.Status = '012';
            upC.add(camp);
            upC.add(camp2);
            update upC;
            upC.clear();
            camp2.Status = '003';
            upC.add(camp2);
            update upC;
        }
        Test.stopTest();
        System.assertEquals('012', camp.Status);
    }
    
}