/**********************************************************************************************************************
Name:	  AV_InterlocutionGroup_Controller
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Controller del lwc av_InterlocutionGroupDetail
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	  AUTHOR		   	DATE				Description
	1.0			US352009	  Elisabeth R.  	26/01/2023		  	Init version
               
***********************************************************************************************************************/

public with sharing class AV_InterlocutionGroupDetails_Controller {



   @AuraEnabled(cacheable=true)
	public static List<AV_GrupoInterlocucion__c> getInterlocutionGroup(String recordId){

        AV_GrupoInterlocucion__c interlocutionGroup = [SELECT Name, AV_Numper__c, AV_Numper__r.Name, AV_IsInterlocutor__c  FROM AV_GrupoInterlocucion__c WHERE Id =: recordId AND RecordType.DeveloperName =: AV_AppConstants.INTERLOC_GROUP_RT];
        List<AV_GrupoInterlocucion__c> interlocutionGroupMembers = [SELECT Name, AV_Numper__c, AV_Numper__r.Name, AV_IsInterlocutor__c FROM AV_GrupoInterlocucion__c WHERE Name =:interlocutionGroup.Name AND RecordType.DeveloperName =: AV_AppConstants.INTERLOC_GROUP_RT];

        if(interlocutionGroupMembers != null && !interlocutionGroupMembers.isEmpty()){
            if(interlocutionGroupMembers.size()>1){

                Integer indexInterlocutionMember = interlocutionGroupMembers.indexOf(interlocutionGroup);

                if(indexInterlocutionMember != -1 && indexInterlocutionMember != 0){
                    AV_GrupoInterlocucion__c reorderMember = interlocutionGroupMembers.get(0);
                    Integer indexOfMember = interlocutionGroupMembers.indexOf(interlocutionGroup);
                    interlocutionGroupMembers.remove(indexOfMember);
                    interlocutionGroupMembers.set(0, interlocutionGroup);
                    interlocutionGroupMembers.add(reorderMember);
                }
            }
        }

        return interlocutionGroupMembers;
    }
}