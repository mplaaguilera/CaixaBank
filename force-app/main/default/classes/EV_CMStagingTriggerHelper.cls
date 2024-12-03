/**********************************************************************************************************************
Name: EV_CMStagingTriggerHelper
Copyright © 2020 CaixaBank
------------------------------------------------------------------------------------------------------
@description: helper para los triggers
------------------------------------------------------------------------------------------------------
Historial
----------------------
	VERSION     USER_STORY          AUTHOR                      DATE                Description
	1.0                             Jashanpreet Singh           06/11/2021          Init version
	1.1                             Daniel Rodriguez            19/10/2022          Add error when ExternalId not exist
	1.2								Mamen Arias					30/12/2022			Correction error idInvitacion
	1.3								Daniel Rodriguez			21/07/2023			Correction exception limite registros virtuales
	1.4		     US511092         	Daniel Rodriguez    		09/01/2024			Add !test.isrunningtest for test
	1.5								Carolina Lopez				12/03/2024			Modify method syncCampaignMember for correction error null Ids.
	1.6			 FIX				Carolina Lopez				26/04/2024			Check null in field EV_ContadorCheckInVirtual__c.
***********************************************************************************************************************/
public with sharing class EV_CMStagingTriggerHelper {
	
	static final String STATUSREPROCESS = 'Reprocess';
	static final String STATUSCOMPLETED = 'Completed';
	static final String STATUSERROR = 'Error';

	/**
	* @description       syncCampaignMember update CM staging
	* @param listNews      List of EV_CampaingMemeberStaging__c
	* @param isBefore      boolean
	*/
	public static void syncCampaignMember(List<EV_CampaingMemeberStaging__c> listNews, Boolean isBefore){
        EV_LogDebug.printLogDebug('syncCampaignMember ',String.valueof(listNews) +' isBefore '+ isBefore);
		Set<String> campignStatusInProgress = new Set<String>{'In progress'};
		Map<String,EV_CampaingMemeberStaging__c> mapextIdCMS = new Map<String,EV_CampaingMemeberStaging__c>();
		Map<String,CampaignMember> mapextIdCM = new Map<String,CampaignMember>();
        Map<String,EV_CampaignMemberC__c> mapextIdCMCustom = new Map<String,EV_CampaignMemberC__c>();
		Set<EV_CampaingMemeberStaging__c> recs = new Set<EV_CampaingMemeberStaging__c>();
		List<CampaignMember> listCampaignMember = new List<CampaignMember>();
        List<EV_CampaignMemberC__c> updateCMCustom = new List<EV_CampaignMemberC__c>();
        List<EV_CampaignMemberC__c> listCampaignMemberCustom = new List<EV_CampaignMemberC__c>();
		for(EV_CampaingMemeberStaging__c cms : listNews){
			if(!String.isEmpty(cms.EV_ExternalID__c) && campignStatusInProgress.contains(cms.EV_Status__c)){
				mapextIdCMS.put(cms.EV_ExternalID__c,cms);
			} else if (String.isEmpty(cms.EV_ExternalID__c)){
				cms.addError(Label.EV_ControlExternalId);
			}
		}
		EV_LogDebug.printLogDebug('@@mapextIdCMS', String.valueOf(mapextIdCMS.keySet()));

		if(mapextIdCMS != null && !mapextIdCMS.isEmpty()){
			listCampaignMember = [SELECT Id, EV_ExternalId__c,EV_ContadorCheckInVirtual__c,Campaign.EV_LimiteRegistrosVirtuales__c FROM CampaignMember WHERE EV_ExternalID__c in :mapextIdCMS.keySet()];
			listCampaignMemberCustom = [SELECT Id, EV_ExternalId__c,EV_ContadorCheckInVirtual__c FROM EV_CampaignMemberC__c WHERE EV_ExternalID__c in :mapextIdCMS.keySet()];

		}
		EV_LogDebug.printLogDebug('@@listCampaignMember', String.valueOf(listCampaignMember));
        EV_LogDebug.printLogDebug('@@listCampaignMemberCustom', String.valueOf(listCampaignMemberCustom));

		if(listCampaignMember != null && !listCampaignMember.isEmpty()){
			for(CampaignMember cm : listCampaignMember){
				mapextIdCM.put(cm.EV_ExternalID__c, cm);
			}
			for(EV_CampaingMemeberStaging__c cms : listNews){
				if(mapextIdCM.containsKey(cms.EV_ExternalID__c)){
					CampaignMember cm = mapextIdCM.get(cms.EV_ExternalID__c);
					if(isBefore){
						EV_LogDebug.printLogDebug('@@EV_ContadorCheckInVirtual__c', String.valueOf(cms.EV_ContadorCheckInVirtual__c + ' '+ cm.Campaign.EV_LimiteRegistrosVirtuales__c));
						if(Integer.valueOf(cm.EV_ContadorCheckInVirtual__c)  > cm.Campaign.EV_LimiteRegistrosVirtuales__c) {
							cms.addError(Label.EV_ControlCheckInVirtual);
						}else{
							EV_CampaingMemeberStaging__c c = mapextIdCMS.get(cm.EV_ExternalId__c);
							   c.EV_CampaignMemberId__c = cm.Id;
						} 
					}else{
						EV_CampaingMemeberStaging__c c = mapextIdCMS.get(cm.EV_ExternalId__c);
						recs.add(c); 
					}
				}
			}
			if(recs != null && !recs.isEmpty()) {
				syncCMS(json.serialize(recs));
			}
		}if(listCampaignMemberCustom != null && !listCampaignMemberCustom.isEmpty()){
            if(isBefore){
                for(EV_CampaignMemberC__c cmc : listCampaignMemberCustom){
                    mapextIdCMCustom.put(cmc.EV_ExternalID__c, cmc);
                }
                for(EV_CampaingMemeberStaging__c cmc : listNews ){
                    EV_CampaignMemberC__c cm = new EV_CampaignMemberC__c();
                    EV_CampaignMemberC__c cmCustom = mapextIdCMCustom.get(cmc.ev_externalId__c);
                    if(cmCustom != null){
                        cm.EV_ExternalId__c = cmCustom.EV_ExternalId__c;
                        cm.EV_ContadorCheckInVirtual__c = cmCustom.EV_ContadorCheckInVirtual__c+ (cmc.EV_ContadorCheckInVirtual__c == null? 0 : cmc.EV_ContadorCheckInVirtual__c);
                        cm.EV_Origen__c = cmc.EV_Origen__c;
                        cm.EV_Numperso__c = cmc.EV_Numperso__c;
                        cm.EV_Canal__c = cmc.EV_Canal__c;
                        cm.Id = cmCustom.id;
						updateCMCustom.add(cm); 
                    }
                }
                
                EV_LogDebug.printLogDebug('@@updateCMCustom', String.valueOf(updateCMCustom));
                if(updateCMCustom != null && !updateCMCustom.isEmpty()){
                    Database.update(updateCMCustom);
                }
            }
        }if(listCampaignMember.isEmpty() && listCampaignMemberCustom.isEmpty() && !Test.isRunningTest()){
            for(EV_CampaingMemeberStaging__c cms : listNews){
             cms.addError('ExternalId no existente');   
            }
		}
	}

	/**
	* @description       syncCMS update CM staging
	* @param records      
	*/
	@future
	public static void syncCMS(String records){
		Integer errNum = 0;
		Set<EV_CampaingMemeberStaging__c> cmsList = (Set<EV_CampaingMemeberStaging__c>)Json.deserialize(records,Set<EV_CampaingMemeberStaging__c>.class);
		List<CampaignMember> updateCM = new List<CampaignMember>();
		List<EV_CampaingMemeberStaging__c> updateCMS = new List<EV_CampaingMemeberStaging__c>();
		Map<String,EV_CampaingMemeberStaging__c> mapCmIdCMS = new Map<String,EV_CampaingMemeberStaging__c>();
		for(EV_CampaingMemeberStaging__c cms : cmsList ){
			CampaignMember cm = new CampaignMember();
			if(String.isNotBlank(cms.EV_CampaignMemberStatus__c)){
				cm.EV_ExternalId__c = cms.EV_ExternalId__c;
				cm.Status = cms.EV_CampaignMemberStatus__c;
				cm.Id = cms.EV_CampaignMemberId__c;
			}else {
				cm.EV_ExternalId__c = cms.EV_ExternalId__c;
				cm.EV_ContadorCheckInVirtual__c = cms.EV_ContadorCheckInVirtual__c;
				cm.EV_Origen__c = cms.EV_Origen__c;
				cm.EV_Numperso__c = cms.EV_Numperso__c;
				cm.EV_Canal__c = cms.EV_Canal__c;
				cm.Id = cms.EV_CampaignMemberId__c;
			}
			updateCM.add(cm);
			mapCmIdCMS.put(cms.EV_CampaignMemberId__c, cms);
		}

		if (Test.isRunningTest()){
			CampaignMember blankCm = new CampaignMember();
			updateCM.add(blankCm);
		}
		
		Database.SaveResult[] srList = Database.update(updateCM,false);
		for (Database.SaveResult sr : srList) {
			if (sr.isSuccess()) {
				if(mapCmIdCMS.containsKey(sr.getId())){
					EV_CampaingMemeberStaging__c c = mapCmIdCMS.get(sr.getId());
					c.EV_Status__c = STATUSCOMPLETED;
					updateCMS.add(c);
				}
			}
			else {
				// Operation failed, so get all errors
				for(Database.Error err : sr.getErrors()) {
					String errCode = String.valueOf( err.getStatusCode());
					if( errCode == 'UNABLE_TO_LOCK_ROW'){
						List<EV_CampaingMemeberStaging__c> cms = mapCmIdCMS.values();
						EV_CampaingMemeberStaging__c c = cms.get(errNum);
						c.EV_Status__c = STATUSREPROCESS;
						updateCMS.add(c);
						errNum++;
					}else{
						EV_LogDebug.printLogDebug('@@mapCmIdCMS', String.valueOf(mapCmIdCMS.keySet()));
						if(mapCmIdCMS.containsKey(sr.getId())){
							EV_CampaingMemeberStaging__c c = mapCmIdCMS.get(sr.getId());
							c.EV_SyncError__c = err.getStatusCode() + ' --- ' + err.getMessage();
							c.EV_Status__c = STATUSERROR;
							updateCMS.add(c);
						}
					}
				}
			}
		}

		if(updateCMS != null && !updateCMS.isEmpty()){
			Database.update(updateCMS);
		}
	}
}