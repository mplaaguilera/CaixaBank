/**********************************************************************************************************************
 Name:	  CIBE_CustomActivityOppTriggerHelper
 Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Clase Helper para Trigger de AV_CustomActivityOpportunity__c 
-----------------------------------------------------------------------------------------------------------------------
Historial
--------------------------------------------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0     	App FSC		    Luis Martínez	  	13/06/2024			Init version 

***********************************************************************************************************************/
public with sharing class CIBE_CustomActivityOppTriggerHelper {

    public static void updateCommentsHistoryVinculated(List<AV_CustomActivityOpportunity__c> listNew, Map<Id, AV_CustomActivityOpportunity__c> mapOld){
        //AI
        Set<Id> setIds =  new Set<Id>();
        Set<String> setIdsAvTask =  new Set<String>();
        for(AV_CustomActivityOpportunity__c cuAcOp: listNew){
            setIds.add(cuAcOp.Id);
        }

        List<AV_CustomActivityOpportunity__c> lstACOEmp =   [SELECT Id, AV_Opportunity__c, AV_Task__c,AV_Opportunity__r.OwnerId, AV_Opportunity__r.AV_Comentarios__c, 
                                                            AV_Opportunity__r.AV_Gestor__c, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedById
                                                            FROM AV_CustomActivityOpportunity__c 
                                                            WHERE Id IN :setIds AND AV_Opportunity__r.RecordType.DeveloperName LIKE '%EMP%'];
    
        List<AV_CommentsHistory__c> lstCommHist = new List<AV_CommentsHistory__c>();	
            if(!lstACOEmp.isEmpty()){
                for(AV_CustomActivityOpportunity__c cao : lstACOEmp){
                    setIdsAvTask.add(cao.AV_Task__c);
                }


                List<Event> evnt = [SELECT Id FROM Event WHERE AV_Task__c IN :setIdsAvTask];
                List<Task> tsk = [SELECT Id FROM Task WHERE AV_Task__c IN :setIdsAvTask];

                if(!evnt.isEmpty()){
                    for(AV_CustomActivityOpportunity__c cao : lstACOEmp){
                    AV_CommentsHistory__c commHist = new AV_CommentsHistory__c();
                        commHist.OwnerId = cao.AV_Opportunity__r.OwnerId;
                        commHist.AV_ModificationDate__c = System.now();
                        commHist.AV_NewComment__c = cao.AV_Opportunity__r.AV_Comentarios__c;
                        commHist.AV_OpportunityStatus__c = cao.AV_Opportunity__r.StageName;
                        commHist.AV_AssignedEmployee__c = cao.AV_Opportunity__r.AV_Gestor__c;
                        commHist.AV_Opportunity__c = cao.AV_Opportunity__c;
                        commHist.AV_Event__c = cao.AV_Task__c;
                    lstCommHist.add(commHist);
                    }
                }else if(!tsk.isEmpty()){
                    for(AV_CustomActivityOpportunity__c cao : lstACOEmp){
                    AV_CommentsHistory__c commHist2 = new AV_CommentsHistory__c();
                        commHist2.OwnerId = cao.AV_Opportunity__r.OwnerId;
                        commHist2.AV_ModificationDate__c = System.now();
                        commHist2.AV_NewComment__c = cao.AV_Opportunity__r.AV_Comentarios__c;
                        commHist2.AV_OpportunityStatus__c = cao.AV_Opportunity__r.StageName;
                        commHist2.AV_AssignedEmployee__c = cao.AV_Opportunity__r.AV_Gestor__c;
                        commHist2.AV_Opportunity__c = cao.AV_Opportunity__c;
                        commHist2.AV_Task__c = cao.AV_Task__c;
                    lstCommHist.add(commHist2);
                    }
                }



            }

        if(Schema.sObjectType.AV_CommentsHistory__c.isCreateable()){
            try{
                Database.insert(lstCommHist);
            }catch(Exception e) {
                CBK_Log.error(e);
            }
        }
    }

    public static void deleteCommentsHistoryVinculated(List<AV_CustomActivityOpportunity__c> listNew){
        String methodName = 'deleteCommentsHistoryVinculated';
        Boolean cambioOwner = false;
        Set<Id> setIds =  new Set<Id>();
        Integer i = 0;
        Integer h = 0;
        Set<String> setIdsAvTask =  new Set<String>();
        Set<String> setIdsOpp = new Set<String>();
        List<AV_CommentsHistory__c> commentRelation = new List<AV_CommentsHistory__c>();
        for(AV_CustomActivityOpportunity__c cuAcOp: listNew){
            setIds.add(cuAcOp.Id);
        }

        List<AV_CustomActivityOpportunity__c> lstACOEmp =   [SELECT Id, AV_Opportunity__c, AV_Task__c,AV_Opportunity__r.OwnerId, AV_Opportunity__r.AV_Comentarios__c, 
                                                            AV_Opportunity__r.AV_Gestor__c, AV_Opportunity__r.StageName, AV_Opportunity__r.LastModifiedById
                                                            FROM AV_CustomActivityOpportunity__c 
                                                            WHERE Id IN :setIds AND AV_Opportunity__r.RecordType.DeveloperName LIKE '%EMP'];
    
        List<AV_CommentsHistory__c> lstCommHist = new List<AV_CommentsHistory__c>();	
            if(!lstACOEmp.isEmpty()){
                for(AV_CustomActivityOpportunity__c cao : lstACOEmp){
                    setIdsAvTask.add(cao.AV_Task__c);
                    setIdsOpp.add(cao.AV_Opportunity__c);
                }

            commentRelation = [SELECT Id, OwnerId FROM AV_CommentsHistory__c WHERE (AV_Event__c IN :setIdsAvTask OR AV_Task__c IN :setIdsAvTask) AND AV_Opportunity__c IN :setIdsOpp];
        }

        if(!commentRelation.isEmpty()){
            for (AV_CommentsHistory__c comment : commentRelation) {
                if(comment.OwnerId != UserInfo.getUserId()){
                    comment.OwnerId = UserInfo.getUserId();
                    cambioOwner = true;
                }
            }

            if(cambioOwner){
                List<Database.SaveResult> updRes = Database.update(commentRelation,false);

                for (Database.SaveResult sr : updRes) {
					if (sr.getErrors()!=null) {
						for(Database.Error err : sr.getErrors()) {
							CBK_Log.debug(methodName, 'Error: ' + err.getMessage() + ' -> Id: ' + commentRelation.get(i).Id);
							i++; 
                }
            }
        }
    }

            List<Database.DeleteResult> delRes = Database.delete(commentRelation,false);

            for (Database.DeleteResult srDelete : delRes) {
                if (srDelete.getErrors()!=null) {
                    for(Database.Error errDelete : srDelete.getErrors()) {
                        CBK_Log.debug(methodName, 'Error: ' + errDelete.getMessage() + ' -> Id: ' + commentRelation.get(i).Id);
                        h++; 
                    }
                }
            }
            
            
        }
    }
}