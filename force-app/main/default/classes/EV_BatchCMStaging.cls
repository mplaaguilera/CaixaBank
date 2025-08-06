/**********************************************************************************************************************
 Name:	  EV_BatchCMStaging
 Copyright © 2022  CaixaBank
=======================================================================================================================
Proposito: Clase para batch de CampaignMemberStaiging
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		                	  Daniel Rodriguez    30/09/2022			Modify error duplicates and AVQuery
	1.1		     US511092         Daniel Rodriguez    09/01/2024			Remove system.debug
***********************************************************************************************************************/
public with sharing class EV_BatchCMStaging implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    public Integer recordsProcessed = 0;
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String avQuery = '';
        avQuery = 'Select Id, EV_ExternalId__c, EV_ContadorCheckInVirtual__c, EV_Origen__c, EV_Numperso__c, EV_Canal__c, EV_CampaignMemberId__c from EV_CampaingMemeberStaging__c where EV_Status__c = \'Reprocess\'';

        EV_LogDebug.printLogDebug('avQuery: ',String.valueof(avQuery));
        return Database.getQueryLocator(avQuery);
    }

    public void execute(Database.BatchableContext bc, List<EV_CampaingMemeberStaging__c> scope){
        EV_LogDebug.printLogDebug('Scope: ',String.valueof(scope));
        List<CampaignMember> updateCM = new List<CampaignMember>();
        Set<Id> cmId = new Set<Id>();
        Map<String,CampaignMember> mapUpdateCM = new Map<String,CampaignMember>();
        Map<String,EV_CampaingMemeberStaging__c> mapUpdateCMS = new Map<String,EV_CampaingMemeberStaging__c>();
        Map<String,double> cmLimite = new Map<String,double>();
        //Map<String, EV_CampaingMemeberStaging__c> mapCmIdCMS = new Map<String, EV_CampaingMemeberStaging__c>();

        for(EV_CampaingMemeberStaging__c sc : scope){
            cmId.add(sc.EV_CampaignMemberId__c);
        }
        For(List<CampaignMember> listCampaignMember : [SELECT Id, EV_ExternalId__c,EV_ContadorCheckInVirtual__c,Campaign.EV_LimiteRegistrosVirtuales__c FROM CampaignMember WHERE id in :cmId]){
            for(CampaignMember cam : listCampaignMember){
            	cmLimite.put(cam.Id,cam.Campaign.EV_LimiteRegistrosVirtuales__c );
                EV_LogDebug.printLogDebug('cmLimite: ',String.valueof(cmLimite.values()));
            }
        }
        
        
        
        Map<String, List<EV_CampaingMemeberStaging__c>> mapCmIdListCMS = new Map<String, List<EV_CampaingMemeberStaging__c>>();
        for(EV_CampaingMemeberStaging__c cms : scope ){
            if(mapUpdateCM.containskey(cms.EV_CampaignMemberId__c) && mapCmIdListCMS.containskey(cms.EV_CampaignMemberId__c) && cmLimite.containskey(cms.EV_CampaignMemberId__c)){
                CampaignMember cm = mapUpdateCM.get(cms.EV_CampaignMemberId__c);
                Double limite = cmLimite.get(cms.EV_CampaignMemberId__c);
                EV_LogDebug.printLogDebug('limite: ',String.valueof(limite));
                cm.EV_ExternalId__c = cms.EV_ExternalId__c;
                if(cm.EV_ContadorCheckInVirtual__c < limite ){
                    cm.EV_ContadorCheckInVirtual__c = cm.EV_ContadorCheckInVirtual__c + cms.EV_ContadorCheckInVirtual__c;
                }
                cm.EV_Origen__c = cms.EV_Origen__c;
                cm.EV_Numperso__c = cms.EV_Numperso__c;
                cm.EV_Canal__c = cms.EV_Canal__c;
                cm.Id = cms.EV_CampaignMemberId__c;
                mapUpdateCM.put(cm.Id, cm);
                mapCmIdListCMS.get(cms.EV_CampaignMemberId__c).add(cms);
                EV_LogDebug.printLogDebug('mapCmIdListCMS: ',String.valueof(mapCmIdListCMS.values()));
                EV_LogDebug.printLogDebug('mapUpdateCM: ',String.valueof(mapUpdateCM.values()));
                //updateCM.add(cm);
            }else{
                
                CampaignMember cm = new CampaignMember();
                cm.EV_ExternalId__c = cms.EV_ExternalId__c;
                cm.EV_ContadorCheckInVirtual__c = cms.EV_ContadorCheckInVirtual__c;
                cm.EV_Origen__c = cms.EV_Origen__c;
                cm.EV_Numperso__c = cms.EV_Numperso__c;
                cm.EV_Canal__c = cms.EV_Canal__c;
                cm.Id = cms.EV_CampaignMemberId__c;
                mapUpdateCM.put(cm.Id, cm);
                //updateCM.add(cm);
                mapCmIdListCMS.put(cms.EV_CampaignMemberId__c, new List<EV_CampaingMemeberStaging__c> {cms});
                EV_LogDebug.printLogDebug('mapCmIdListCMS: ',String.valueof(mapCmIdListCMS.values()));
            }
            
        }
        for(List<EV_CampaingMemeberStaging__c> cms2 : mapCmIdListCMS.values()){
            for (EV_CampaingMemeberStaging__c cm : cms2){
            }
            
        }
      Database.SaveResult[] srList = Database.update(mapUpdateCM.values(),false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                if(mapCmIdListCMS.containsKey(sr.getId())){
                    List<EV_CampaingMemeberStaging__c> listC = mapCmIdListCMS.get(sr.getId());
                    for(EV_CampaingMemeberStaging__c cs : listC){
                        cs.EV_Status__c = 'Completed';
                    	mapUpdateCMS.put(cs.Id, cs);
                    }
                }
            }
            else {
                // Operation failed, so get all errors      
                EV_LogDebug.printLogDebug('error : ',String.valueof(sr));
                for(Database.Error err : sr.getErrors()) {                   
                    String errCode = String.valueOf( err.getStatusCode());
                    if( errCode == 'UNABLE_TO_LOCK_ROW'){
                        if(mapCmIdListCMS.containsKey(sr.getId())){
                            List<EV_CampaingMemeberStaging__c> listC = mapCmIdListCMS.get(sr.getId());
                            for(EV_CampaingMemeberStaging__c cs : listC){
                                cs.EV_Status__c = 'Reprocess';
                                mapUpdateCMS.put(cs.Id, cs);
                            }
                        }
                    }else{
                        if(mapCmIdListCMS.containsKey(sr.getId())){
                            List<EV_CampaingMemeberStaging__c> listC = mapCmIdListCMS.get(sr.getId());
                            for(EV_CampaingMemeberStaging__c cs : listC){
                                cs.EV_SyncError__c = err.getStatusCode() + ' --- ' + err.getMessage();
                                cs.EV_Status__c = 'Error';
                                mapUpdateCMS.put(cs.Id, cs);
                            }
                        }
                    }                 
                }
            }
        }
        if(mapUpdateCMS != null && !mapUpdateCMS.isEmpty()){
            Database.update(mapUpdateCMS.values());
        } 
    }

    public void execute(SchedulableContext sc) {
        
		Database.executeBatch(new EV_BatchCMStaging());
        
	}
    public void finish(Database.BatchableContext bc){
        
		String methodName='finish';
        
		EV_LogDebug.printLogDebug(methodName +'recordsProcessed: ',String.valueof(recordsProcessed));
	}
}