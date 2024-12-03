/**********************************************************************************************************************
 Name:	CIBE_AccConRelTriggerHelper
 Copyright © 2023  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: helper para Trigger de AccountContactRelation
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
	1.0			US493757	    Alex Pérez	   	      27/03/2023	    Init version
***********************************************************************************************************************/
public without sharing class CIBE_AccConRelTriggerHelper {

    public static void teamMemberManager(list<AccountContactRelation> listNewObj, Map<Id, AccountContactRelation> mapOldObj){

        list<Id> idsToManage = new list<id>();
        try {
            for(AccountContactRelation relation : listNewObj){
                if( !string.isBlank(relation.FinServ__SourceSystemId__c) && relation.FinServ__SourceSystemId__c.startsWith('CIBE') && (mapOldObj == null || relation.isActive != mapOldObj.get(relation.Id).isActive) ) {
                    idsToManage.add(relation.id);
                }    
            }
            if(!idsToManage.isEmpty()) {
                map<String,Object> params = New map<String,Object>();
                params.put('relationIds',idsToManage);
                CBK_BatchJob.executeBatch('CIBE_AccTMAccConRel_Batch', null, params,1);
            }     
        }catch(Exception e){
            CBK_Log.error(e);
        }
    }
}