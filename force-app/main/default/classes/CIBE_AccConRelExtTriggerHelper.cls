/**********************************************************************************************************************
 Name:	CIBE_AccConRelExtTriggerHelper
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------------------------------
Proposito: helper para Trigger de AccountContactRelation
------------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				  DATE				Description
    1.0         US493757        Borja Lavesiera       16/01/2024        Init version
***********************************************************************************************************************/
public with sharing class CIBE_AccConRelExtTriggerHelper {
        public static void setExternalSourceId(list<AccountContactRelation> listNewObj, Map<Id, AccountContactRelation> mapOldObj){
            list<Id> idsToManage = new list<id>();
            try {
                for(AccountContactRelation relation : listNewObj){    
                    if(mapOldObj != null && relation.isDirect != mapOldObj.get(relation.Id).isDirect && relation.isDirect == false) {
                        idsToManage.add(relation.id);
                    }    
                }
                if(!idsToManage.isEmpty()) {
                    map<String,Object> params = New map<String,Object>();
                    params.put('relationIds',idsToManage);
                    CBK_BatchJob.executeBatch('CIBE_AccExtAccConRel_Batch', null, params,2);
                }     
            }catch(Exception e){
                CBK_Log.error(e);
            }
        }
}