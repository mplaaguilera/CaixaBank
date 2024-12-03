/**********************************************************************************************************************
 Name:   EV_CampaignMemberTriggerHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Before Insert sobre el objeto Campaign Member
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION     USER_STORY          AUTHOR              DATE                Description
	1.0                             Eric Vázquez        19/03/2021          Init version
	2.0                             Eric Vázquez        08/06/2021          Add methods for survey
	2.1								Mamen Arias			05/01/2023			Add method linkUniqueSurveyGeneration replace process builder and flow
	2.2								Daniel Rodriguez	03/02/2023			Add method generarIdseguro to EV_CampaignMember_BI_TRHan, Add method inscripcionNRT to EV_CampaignMember_AI_TRHan. Add method inscripcionCliente,inscripcionNRT to EV_CampaignMember_AU_TRHan. Add method crearHistoricoDelete to EV_CampaignMember_BD_TRHan
																			Modify method fillFormatoAsistenciaByRT, linkUniqueSurveyGeneration, eventSurvey
	2.3			US657362			Mamen Arias			31/08/2023			Add Status 'Pendiente' and 'Invitacion enviada' for chage Status to 'Asistió' in linkUniqueSurveyGeneration
	2.4			US674053			Mamen Arias			02/10/2023			Modify method linkUniqueSurveyGeneration > check if EV_ContadorCheckInVirtual__c >= 1, instead == 1
***********************************************************************************************************************/
public with sharing class EV_CampaignMemberTriggerHelper {

	public static void fillNameFromCampaignMember(List<CampaignMember> listNews){
	EV_LogDebug.printLogDebug('fillNameFromCampaignMember ',String.valueof(listNews));
		for(CampaignMember cm : listNews){
			if(cm.ContactId!=null || cm.LeadId!=null){
				cm.EV_NameCampaignMember__c = cm.FirstName + ' ' + cm.LastName;
			}
		}
	}

	public static void fillFormatoAsistenciaByRT(List<CampaignMember> listNews){
		EV_LogDebug.printLogDebug('fillFormatoAsistenciaByRT ',String.valueof(listNews));
		Set<Id> campaignIds = new Set<Id>();
		Id rtEventoVirtual = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoVirtual').getRecordTypeId();
		Id rtEventoFisico = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('EV_EventoFisico').getRecordTypeId();
		for(CampaignMember cm : listNews){
				if(cm.EV_RTCampaign__c == rtEventoVirtual){
					cm.EV_FormatoDeAsistencias__c = '002';
				}else if(cm.EV_RTCampaign__c == rtEventoFisico){
					cm.EV_FormatoDeAsistencias__c = '001';
				}
		} 
	}

	public static void memberCampaignWithoutAccount(List<CampaignMember> listNews){
		EV_LogDebug.printLogDebug('memberCampaignWithoutAccount ',String.valueof(listNews));
		for(CampaignMember cm : listNews){
			if(cm.AccountId!=null){
				cm.EV_Empresa__c = true;
			}
		}
	}

	public static void eventSurvey(List<CampaignMember> listNews,  Map<Id, CampaignMember> mapOldObj, Boolean isInsert) {
		EV_LogDebug.printLogDebug('eventSurvey ',String.valueof(listNews));
		List<Lead> listLead = new List<Lead>();
		List<CampaignMember> lstCampaignMembers = new List<CampaignMember>();
        List<CampaignMember> lstCampaignMembersTemp = new List<CampaignMember>();
        List<Id> listAccountId = new List<Id>();
        
		Map<Id,Id> mapLeadCampaign = new Map<Id,Id>();
		Map<Id,Set<Id>> mapCampaignAccount = new Map<Id,Set<Id>>();
		Set<String> campignStatusConfirmed = new Set<String>{'Asistió'};
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		for(CampaignMember campMember : listNews){
			if(((campignStatusConfirmed.contains(campMember.Status) && mapOldObj != null && mapOldObj.get(campMember.Id).Status != campMember.Status) || (campignStatusConfirmed.contains(campMember.Status) && isInsert)) && campMember.LeadId != null && campMember.RecordtypeId == rtEvento){
				mapLeadCampaign.put(campMember.LeadId,campMember.CampaignId);
			}
		}
		EV_LogDebug.printLogDebug('mapLeadCampaign ',String.valueof(mapLeadCampaign));
		if(mapLeadCampaign != null && !mapLeadCampaign.isEmpty()){
			listLead = [SELECT Id, Name, EV_Account__c FROM Lead WHERE Id in : mapLeadCampaign.keySet() and EV_Account__c != null];
			if(listLead!=null){
				for(Lead l : listLead){
						if(!mapCampaignAccount.containsKey(mapLeadCampaign.get(l.Id))){
							Set<Id> ids= new Set<Id>();
							ids.add(l.EV_Account__c);
							mapCampaignAccount.put(mapLeadCampaign.get(l.Id),ids);
						}else{
							Set<Id> ids= new Set<Id>();
							ids.add(l.EV_Account__c);
							ids.addAll(mapCampaignAccount.get(mapLeadCampaign.get(l.Id)));
							mapCampaignAccount.put(mapLeadCampaign.get(l.Id),ids);
						}
				}
			}
			for(set<id> i : mapCampaignAccount.values()){
				listAccountId.addall(i);
				
			}  
			
			lstCampaignMembersTemp = [SELECT Id, Status, AccountId, CampaignId FROM CampaignMember WHERE CampaignId in :mapCampaignAccount.keySet() and AccountId in :listAccountId];

			for(CampaignMember cmp :lstCampaignMembersTemp){
				if(mapCampaignAccount.get(cmp.CampaignId).contains(cmp.accountid)){
					lstCampaignMembers.add(cmp);
				}
				
			}
			
			if(lstCampaignMembers!=null){
				for(CampaignMember cmember : lstCampaignMembers){
					cmember.Status = 'Asistió';
				}
				
				database.update(lstCampaignMembers);
			}
		}
	}

	public static void linkUniqueSurveyGeneration(List<CampaignMember> listNews, Map<Id, CampaignMember> mapOld) {
		EV_LogDebug.printLogDebug('linkUniqueSurveyGeneration ',String.valueof(listNews) + ' ' + String.valueof(mapOld));
		Set<Id> setCampaignIds = new Set<Id>();
		Set<String> campMemberStatus = new Set<String>{'QR enviado', 'Registro confirmado', 'Pendiente', 'Invitacion enviada'};
		Set<String> campMemberStatusConfirmed = new Set<String>{'Asistió'};
		
		List<Campaign> listCampaign = new List<Campaign>();
		Map<String, Campaign> mapCampaign = new Map<String, Campaign>();
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		Network network = [SELECT Id FROM Network WHERE Name = 'Eventos - Encuestas CaixaBank' LIMIT 1];
		for(CampaignMember campMember : listNews){
			if(((campMemberStatus.contains(campMember.Status) && campMember.EV_ContadorCheckInVirtual__c >= 1) || 
			(mapOld != null && mapOld.get(campMember.Id).Status != campMember.Status && campMemberStatusConfirmed.contains(campMember.Status)) ||
			(mapOld == null && campMemberStatusConfirmed.contains(campMember.Status))) && campMember.RecordtypeId == rtEvento ){
				setCampaignIds.add(campMember.CampaignId);
			}
		}
		EV_LogDebug.printLogDebug('setCampaignIds linkUniqueSurveyGeneration',String.valueof(setCampaignIds));
		if(setCampaignIds != null){
			listCampaign = [SELECT Id, EV_Encuesta__c FROM Campaign WHERE Id in:setCampaignIds];
			if(listCampaign!=null){
				for(Campaign camp: listCampaign){
					mapCampaign.put(camp.Id, camp);
				}
			}
			
			for(CampaignMember campMember : listNews){
				SurveyInvitation survey = new SurveyInvitation();
				if(campMemberStatus.contains(campMember.Status) && campMember.EV_ContadorCheckInVirtual__c >= 1 && campMember.RecordtypeId == rtEvento){
					campMember.Status = 'Asistió';
					survey.CommunityId = network.Id;
					survey.EV_Campaign__c = campMember.CampaignId;
					if(campMember.LastName != null || campMember.FirstName != null){
						survey.Name = campMember.LastName+'_'+campMember.FirstName+'_Survey_Invitation_'+Datetime.now();
					}else{
						survey.Name = '_Survey_Invitation_'+Datetime.now();
					}
					if(campMember.LeadId!=null && campMember.ContactId==null && campMember.AccountId == null){
						survey.ParticipantId = campMember.LeadId;
						survey.OptionsAllowGuestUserResponse = true;
					}else if(campMember.LeadId==null && campMember.ContactId!=null && campMember.AccountId == null){
						survey.ParticipantId = campMember.ContactId;
						survey.OptionsAllowGuestUserResponse = true;
					}else if (campMember.LeadId==null && campMember.ContactId==null && campMember.AccountId != null){
						survey.ParticipantId = campMember.LastModifiedById;
						survey.OptionsAllowGuestUserResponse = false;
					}
					survey.SurveyId = mapCampaign.get(campMember.CampaignId).EV_Encuesta__c;

					if(survey!=null){
						Database.insert(survey);
						campMember.EV_InvitacionEncuesta__c = survey.Id;
					}

				// Comparamos que haya cambiado sólo el campo Status, para que no entre en este if cada vez que se modifique un cambio en el CM
				}else if(mapOld != null && mapOld.get(campMember.Id).Status != campMember.Status && campMemberStatusConfirmed.contains(campMember.Status) && campMember.RecordtypeId == rtEvento){
					survey.CommunityId = network.Id;
					survey.EV_Campaign__c = campMember.CampaignId;
					if(campMember.LastName != null || campMember.FirstName != null){
						survey.Name = campMember.LastName+'_'+campMember.FirstName+'_Survey_Invitation_'+Datetime.now();
					}else{
						survey.Name = '_Survey_Invitation_'+Datetime.now();
					}
					if(campMember.LeadId!=null && campMember.ContactId==null && campMember.AccountId == null){
						survey.ParticipantId = campMember.LeadId;
						survey.OptionsAllowGuestUserResponse = true;
					}else if(campMember.LeadId==null && campMember.ContactId!=null && campMember.AccountId == null){
						survey.ParticipantId = campMember.ContactId;
						survey.OptionsAllowGuestUserResponse = true;
					}else if (campMember.LeadId==null && campMember.ContactId==null && campMember.AccountId != null){
						survey.ParticipantId = campMember.LastModifiedById;
						survey.OptionsAllowGuestUserResponse = false;
					}
					survey.SurveyId = mapCampaign.get(campMember.CampaignId).EV_Encuesta__c;

					if(survey!=null){
						Database.insert(survey);
						campMember.EV_InvitacionEncuesta__c = survey.Id;
					}
				
				// Esta casuística es sólo por si se inserta un CM directamente con el estado Asistió.
				}else if (mapOld == null && campMemberStatusConfirmed.contains(campMember.Status) && campMember.RecordtypeId == rtEvento){             
					survey.CommunityId = network.Id;
					survey.EV_Campaign__c = campMember.CampaignId;
					if(campMember.LastName != null || campMember.FirstName != null){
						survey.Name = campMember.LastName+'_'+campMember.FirstName+'_Survey_Invitation_'+Datetime.now();
					}else{
						survey.Name = '_Survey_Invitation_'+Datetime.now();
					}
					if(campMember.LeadId!=null && campMember.ContactId==null && campMember.AccountId == null){
						survey.ParticipantId = campMember.LeadId;
						survey.OptionsAllowGuestUserResponse = true;
					}else if(campMember.LeadId==null && campMember.ContactId!=null && campMember.AccountId == null){
						survey.ParticipantId = campMember.ContactId;
						survey.OptionsAllowGuestUserResponse = true;
					}else if (campMember.LeadId==null && campMember.ContactId==null && campMember.AccountId != null){
						survey.ParticipantId = campMember.LastModifiedById;
						survey.OptionsAllowGuestUserResponse = false;
					}
					survey.SurveyId = mapCampaign.get(campMember.CampaignId).EV_Encuesta__c;

					if(survey!=null){
						Database.insert(survey);
						campMember.EV_InvitacionEncuesta__c = survey.Id;
					}
				}
			}
		}
	}

	public static void generarIdSeguro(List<CampaignMember> listNewObj) {
		EV_LogDebug.printLogDebug('generarIdSeguro ',String.valueof(listNewObj));
		List<CampaignMember> lstAux = new List<CampaignMember>();
		for(CampaignMember campMember : listNewObj){
			Blob b = Crypto.GenerateAESKey(128);
			String h = EncodingUtil.ConvertTohex(b);
			String guid = h.SubString(0,18);
			campMember.EV_ExternalID__c = EV_Utilities.generateSecureId(guid +campMember.EV_NumeroDocumento__c+campMember.CampaignId+campMember.EV_Email__c + campMember.EV_ExternalID__c+ String.valueOf(Datetime.now()) + campMember.ContactId).replace('%','').replace('&','');
			lstAux.add(campMember);
		}
	}

	public static void actualizarContadorCheckInVirtual(List<CampaignMember> listNewObj, Map<Id, CampaignMember> mapOldObj) {
		EV_LogDebug.printLogDebug('actualizarContadorCheckInVirtual ',String.valueof(listNewObj) + ' ' + String.valueof(mapOldObj));
        Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();

        for(CampaignMember camp : listNewObj){
            if(camp.EV_ContadorCheckInVirtual__c == 1 && !system.isBatch() && camp.RecordtypeId == rtEvento ){
                camp.EV_ContadorCheckInVirtual__c = mapOldObj.get(camp.Id).EV_ContadorCheckInVirtual__c + camp.EV_ContadorCheckInVirtual__c;
            }
        }
    }

    
    //Pasar solo los registros adecuados al método futuro para generar el QR
    public static void processCampaignMemberForQR(List<CampaignMember> listNewObj, Map<Id, CampaignMember> mapOldObj) {
		EV_LogDebug.printLogDebug('processCampaignMemberForQR ',String.valueof(listNewObj));
        Set<Id> setCampMembers = new Set<Id>();        
        for(CampaignMember campMember : listNewObj ){
            if(campMember.status != mapOldObj.get(campMember.Id).status && campMember.status == 'Registro Confirmado'){
                setCampMembers.add(campMember.Id);
            }
        }
		EV_LogDebug.printLogDebug('setCampMembers ',String.valueof(setCampMembers));
        if(setCampMembers != null && setCampMembers.size() >0){
            generarQR(setCampMembers);
        }
        
    }

    @future (callout=true)
    public static void generarQR(Set<Id> setCampMembers) {
		EV_LogDebug.printLogDebug('generarQR ',String.valueof(setCampMembers));
        Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
        List<CampaignMember> lstCampaignMembers = [Select id, Name, Status, Contact.CC_Sexo__c, LeadId, ContactId, Campaign.EV_HoraFinAC__c, Campaign.EV_HoraInicioAC__c, Campaign.StartDate, Contact.EV_Idiomas__c,Lead.EV_Idiomas__c,
        CampaignId, Campaign.Name, Campaign.EV_Description__c, Campaign.EV_LugarDeCelebracion__c from CampaignMember where Id in: setCampMembers and RecordtypeId =:rtEvento];
        for(CampaignMember campMember : lstCampaignMembers ){
            Map<String, String> mapRequestResponse = (Map<String, String>) JSON.deserialize(EV_ConexionQR.conexQR(campMember), Map<String, String>.class);
            if(mapRequestResponse.get('errorCode') != null){
                campMember.EV_QRLog__c =  String.valueOf(datetime.now()) +'-'+ mapRequestResponse.get('errorCode') + ': '+ mapRequestResponse.get('errorMessage');
            }else if(mapRequestResponse.get('pdfLink') != null && mapRequestResponse.get('pkpassLink') != null && mapRequestResponse.get('qr_bcLink') != null){
                campMember.EV_URLQRPKPASS__c = mapRequestResponse.get('pkpassLink');
                campMember.EV_URLPDFQR__c = mapRequestResponse.get('pdfLink');
                Map<String, Object> mapQR = EV_ConexionQR.getQRBinary(mapRequestResponse.get('qr_bcLink'));
                if(mapQR.get('StatusCode') == '200'){
                    if(mapQR.get('Body')!= ''){
                        campMember.EV_QR__c = String.valueOf(mapQR.get('Body'));
                    }else{
                        campMember.EV_QRLog__c = 'ERROR';
                    }
                }else{
                    campMember.EV_QRLog__c = String.valueOf(mapQR.get('StatusCode'));
                }
            }else{
                campMember.EV_QRLog__c =  Label.EV_QRMal;
            }
        }

        if(lstCampaignMembers!=null){
            Database.update(lstCampaignMembers);
        }
    }

	public static void inscripcionNRT(Map<Id,CampaignMember> mapNewObj){
		EV_LogDebug.printLogDebug('inscripcionNRT ',String.valueof(mapNewObj));
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		Set<Id> leadIds = new Set<Id>();
		for(CampaignMember campMember : mapNewObj.values()){
			if(campMember.LeadId != null && campMember.RecordtypeId == rtEvento){
				leadIds.add(campMember.LeadId); 
			}
		}
		if(leadIds != null && !leadIds.isEmpty()){
			
			inscripcionNRT(leadIds, mapNewObj.keySet());
		}
	}

	
	@future (callout=true)
	public static void inscripcionNRT(Set<Id> leadIds, Set<Id> campMembIds) {
		EV_LogDebug.printLogDebug('inscripcionNRT ',String.valueof(leadIds) + ' ' + String.valueof(campMembIds));
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		Map<Id, CampaignMember> mapCampMembers = new Map<Id, CampaignMember>([Select id,CampaignId,EV_FormatodeAsistencias__c, EV_RTCampaign__c, lastModifiedById,RecordTypeId, lastModifiedDate, createdById,LeadId, createdDate, mobilePhone, phone, email, status, EV_CanalOrigen__c, 
		EV_TelefonoDeCampana__c, EV_Nickname__c, EV_QR__c, EV_NumeroDocumento__c, EV_URLEncuesta__c, EV_ExternalID__c, EV_URLRegistro__c, EV_URLStreamingEvento__c from CampaignMember where Id in: campMembIds]);
		Map<Id,Lead> mapLeads;
		
		if(leadIds != null && !leadIds.isEmpty()){
			mapLeads = new Map<Id,Lead>([Select id, firstname, lastname,CreatedDate, LastmodifiedDate, phone, email, status, recordtypeId,EV_Idiomas__c, EV_NumeroDocumento__c,EV_Marketing__c,EV_ConsentimientoGeneral__c,EV_ConsentimientoTerceros__c from Lead where id in :leadIds]);
		}
		
		for(CampaignMember campMember : mapCampMembers.values()){
			
			if( campMember.LeadId != null && mapLeads != null && mapLeads.containsKey(campMember.LeadId) && campMember.RecordtypeId == rtEvento){
				EV_AdobeCampaignInscripcion.inscriptionEvent(null,campMember.CampaignId,null,mapLeads.get(campMember.LeadId), campMember);
			}
		}
	}
	//Metodo AU
	public static void inscripcionCliente(Map<Id, CampaignMember> mapNewObj, Map<Id, CampaignMember> mapOldObj) {
		EV_LogDebug.printLogDebug('inscripcionCliente ',String.valueof(mapNewObj) + ' ' + String.valueof(mapOldObj));
		String statusRegistrado = 'Registro confirmado'; 
		Set<Id> recordIds = new Set<Id>();
		Id rtEvento = Schema.SObjectType.CampaignMember.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
		
		for(CampaignMember campMember : mapNewObj.values()){
            if(campMember.Status == statusRegistrado && mapOldObj.get(campMember.Id).Status != campMember.Status && campMember.RecordtypeId == rtEvento){
				recordIds.add(campMember.Id);
			}
		}

		if(recordIds.size() > 0 && recordIds != null){
			inscripcionNRT(recordIds);
		}
	}
	//Metodo AU
	@future (callout=true)
	public static void inscripcionNRT(Set<Id> recordIds) {
		EV_LogDebug.printLogDebug('inscripcionNRT ',String.valueof(recordIds));
		Map<Id, CampaignMember> mapCampMembers = new Map<Id, CampaignMember>([Select id, lastModifiedById, lastModifiedDate, createdById, createdDate, mobilePhone, phone, email, Status, EV_CanalOrigen__c, 
		EV_TelefonoDeCampana__c, EV_Nickname__c, EV_QR__c, EV_NumeroDocumento__c, EV_URLEncuesta__c, EV_ExternalID__c, EV_EmailDeCampana__c, CampaignId, EV_URLRegistro__c, EV_URLStreamingEvento__c from CampaignMember where Id in: recordIds]);
		
		for(CampaignMember campMember : mapCampMembers.values()){
			if(campMember.EV_EmailDeCampana__c != null){
				EV_AdobeCampaignInscripcion.inscriptionEvent(campMember.Id,campMember.CampaignId,campMember.EV_EmailDeCampana__c,null,null); 
			}else{
				EV_AdobeCampaignInscripcion.inscriptionEvent(campMember.Id,campMember.CampaignId,null,null,null); 
			}
		}
	}

	//Metodo BD
	/*public static void crearHistoricoDelete(List<CampaignMember> listOldObj, Map<Id, String> mapNameForLeads) {
		EV_LogDebug.printLogDebug('crearHistoricoDelete ',String.valueof(listOldObj) + ' ' + String.valueof(mapNameForLeads));
        
        List<EV_CampaignMemberHistory__c> ch = new List<EV_CampaignMemberHistory__c>(); 
        
        for(CampaignMember cmOld : listOldObj)
        {           
            EV_CampaignMemberHistory__c cmHistorial = new EV_CampaignMemberHistory__c();               
            cmHistorial.EV_Campaign_Id__c = cmOld.CampaignId;            
            cmHistorial.EV_CampaignMember_Id__c = cmOld.Id;    
            cmHistorial.EV_Nombre_Miembro__c = mapNameForLeads.get(cmOld.LeadId);
            cmHistorial.EV_Lead__c = cmOld.LeadId;     
            cmHistorial.EV_Usuario__c = userinfo.getUserId();
            cmHistorial.EV_Accion_Trigger__c = 'Delete';
            cmHistorial.EV_Detalles_del_historial__c = DateTime.now() + ' - Se ha eliminado al Campaign Member Id: ' 
                + cmOld.id + ' perteneciente a la Campaign Id: '+ cmOld.campaignId + ' por el usuario: '+ userinfo.getUserName();
            
            ch.add(cmHistorial);
        }
        
        if(!ch.isEmpty())
        {
            insert ch;
        }*
    }*/

}