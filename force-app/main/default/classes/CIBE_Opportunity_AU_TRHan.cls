/**********************************************************************************************************************
Name:	  CIBE_Opportunity_BD_TRHan
Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase para Trigger de Opportunity AfterUpdate funcionalidad para CIBE 
=======================================================================================================================
Historial 
---------------------
VERSION		USER_STORY			AUTHOR				DATE				Description
1.0								Mikel Lezama		13/09/2022			Init version

***********************************************************************************************************************/
public with sharing class CIBE_Opportunity_AU_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Opportunity>)tp.newList, (Map<Id, Opportunity>)tp.newMap, (List<Opportunity>) tp.oldList, (Map<Id, Opportunity>) tp.oldMap);
    }
    
    private void process(List<Opportunity> listNewObj, Map<Id, Opportunity> mapNewObj, List<Opportunity> listOldObj, Map<Id, Opportunity> mapOldObj) {
        //General check the Record type's for intouch project
        List<Opportunity> listData = CIBE_OpportunityTriggerHelper.checkGeneralRT(listNewObj);
        
        // Lógica de negocio a ejecutar
        if (listData!=null && !listData.isEmpty()){
            CIBE_OpportunityTriggerHelper.setFieldsFromOppTask(listData, mapOldObj);
            CIBE_OpportunityTriggerHelper.setOpportunityUsers(listData, mapOldObj);
            CIBE_OpportunityTriggerHelper.updateTaskWithOpp(listData, mapOldObj);
        }
    }
}