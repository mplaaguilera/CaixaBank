/**********************************************************************************************************************
 Name:	  EV_CampaignMember_AI_TRHan
 Copyright © 2020  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Trigger de Event AfterInsert
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  Eventos - 73889	  Jorge Centella	   	06/05/2020			Init version
	1.1         App Eventos		  Daniel Rodriguez      23/12/2022			Add field EV_FormatosAsitencia__c, EV_RTCampaign__c, CampaignId in query
	1.2         App Eventos		  Daniel Rodriguez      03/02/2023			Remove method inscripcionNRT to EV_CampaignMemberTriggerHelper
	1.3							  Daniel Rodriguez 		17/10/2023			Call to AC if you have custom permission EV_CallTooAC
***********************************************************************************************************************/

public with sharing class EV_CampaignMember_AI_TRHan extends CC_TriggerHandlerBase {
	
	public override void mainEntry(CC_TriggerParameters tp) {
		process((List<CampaignMember>)tp.newList, (Map<Id, CampaignMember>)tp.newMap, (List<CampaignMember>)tp.oldList, (Map<Id, CampaignMember>)tp.oldMap);
	}
	
	private void process(List<CampaignMember> listNewObj, Map<Id, CampaignMember> mapNewObj, List<CampaignMember> listOldObj, Map<Id, CampaignMember> mapOldObj) {
		EV_LogDebug.printLogDebug('EV_CampaignMember_AI_TRHan ',String.valueof(listNewObj));
		//generarIdSeguro(mapNewObj.keySet());
		Boolean hasCustomPermission = FeatureManagement.checkPermission('EV_NotCallToAC');
        if(!hasCustomPermission || Test.isRunningTest()){
			EV_CampaignMemberTriggerHelper.inscripcionNRT(mapNewObj);
        }

	}

   /* //@future
	private static void generarIdSeguro(Set<Id> recordIds) {
		List<CampaignMember> lstAux = new List<CampaignMember>();
		for(CampaignMember campMember : [Select Id, CreatedDate, Name from CampaignMember where Id in : recordIds]){
			campMember.EV_ExternalID__c = EV_Utilities.generateSecureId(campMember.Id + String.valueOf(campMember.CreatedDate) + campMember.Name).replace('%','').replace('&','');
			lstAux.add(campMember);

		}
		update lstAux;
	}*/
	
	/*private static void encuestaPersonJuridica(List<CampaignMember> listNewObj){
		Set<Id> leadIds = new Set<Id>();
		List<CampaignMember> listCampM = new List<CampaignMember>();
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		for(CampaignMember campMember : listNewObj){
			if(campMember.LeadId != null && campMember.RecordtypeId == rtEvento && campMember.Status == 'Asistencia confirmada'){
				leadIds.add(campMember.LeadId);
				listCampM.add(campMember);
			}
		}
		
		 Map<Id,Lead> map_leads;
		
		if(leadIds.size() > 0 && leadIds != null){
			map_leads = new Map<Id,Lead>([Select id, EV_Account__c, firstname, lastname,CreatedDate, LastmodifiedDate, phone, email, status, recordtypeId,EV_Idiomas__c, EV_NumeroDocumento__c,EV_Marketing__c,EV_ConsentimientoGeneral__c,EV_ConsentimientoTerceros__c from Lead where id in :leadIds]);
		}
		
	  
		
		//Select de campaigns members where Campaign Id se el mismo que el de miembro actual miembro y que tenga el account id igual al de Lead
		//
		//Update Persona juridica a Assistencia confirmada
		
	   
		
		
	}*/

	
}