/**********************************************************************************************************************
 Name:   EV_CampaignMemberCTriggerHelper
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Trigger Helper para el objeto EV_CampaignMemberC__c
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
  VERSION    USER_STORY      AUTHOR        DATE        Description
  1.0      US584499      Mamen Arias       20/04/2023      Init Version
  1.1      US587001      Mamen Arias       26/05/2023      Use new methods for EV_AdobeInscription and EV_ConexionQR
  1.2      US586998      Daniel Rodriguez  07/06/2023      Modify method actualizarContadorCheckInVirtual
  1.3      US622078      Humberto Vilchez  09/06/2023      Modify method rtCampaignMember to include Tech Summit RecordTtype
  1.4      US586998      Daniel Rodriguez  07/06/2023      Create method updateRollUp 
  1.5      US635293      Carolina Lopez    21/06/2023      Create method SendSingleEmail and executeSendEmailSingle and generateICSFile
  1.6      US661500      Carolina Lopez    25/07/2023      Modify filter logic method SendSingleEmail to include new field EV_TechSummit__c
  1.7	   US680535      Daniel Rodriguez  31/07/2023	   Modify method sendSingleEmail and remove framework and other method
  1.8	   US680535      Daniel Rodriguez  31/07/2023	   Modify methods eventSurvey, linkUniqueSurveyGeneration, processCampaignMemberForQR, inscripcionNRT, inscripcionCliente and add condition EV_CampaignTechSummit__c for campaign Tech Summit
  1.9	   US680535      Humberto Vilchez  10/08/2023	   Modify method generateICSFile to include url QR code in ICS
  2.0      US680535      Carolina Lopez    16/08/2023      Modify method generateICSFile and sendSingleEmail to send url QR code in event virtual and add event name and campaignmember name in subject 
  2.1	   US680535      Daniel Rodriguez  18/08/2023      Manage error in send email
  2.2      US680535      Mamen Arias       29/08/2023      Add EV_Street__c, EV_CP__c and EV_City__c to sendSingleEmail
  2.3	   US657362		 Mamen Arias	   31/08/2023	   Add Status 'Pendiente' and 'Invitación enviada' for chage Status to 'Asistió' in linkUniqueSurveyGeneration 
  2.4	   US704865		 Daniel Rodriguez  06/09/2023	   Change parameter QR to EV_URLdelEventoVirtual__c	in ICS file		
  2.5      US674053      Mamen Arias       02/10/2023      Modify method linkUniqueSurveyGeneration > check if EV_ContadorCheckInVirtual__c >= 1, instead == 1
  2.6			 US624265		   Daniel Rodriguez	 29/09/2023      Modify all method to add new RT EV_FestivalesYExperiencias and remove get rt from the methods and put into head
***********************************************************************************************************************/
public with sharing class EV_CampaignMemberCTriggerHelper {
  private static Id rtEventoAccionistas     = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_EventosAccionistas).getRecordTypeId();
  //private static Id rtEventoTechSummit      = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_EventosTechSummit).getRecordTypeId();
  private static Id rtCMevento              = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get(Label.EV_CMcEventos).getRecordTypeId();
  private static Id rtCMeventoACC           = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get(Label.EV_CMcEventosAcc).getRecordTypeId();
  //private static Id rtCMeventoTechSumm      = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get(Label.EV_CMcEventoTechSummit).getRecordTypeId();
  private static Id rtFestivales            = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_FestivalesYexperiencias).getRecordTypeId();
  private static Id rtCMFestivales          = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get(Label.EV_FestivalesYexperiencias).getRecordTypeId();
  private static Id rtEventoVirtual         = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_EventoVirtual).getRecordTypeId();
  private static Id rtEventoFisico          = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(Label.EV_EventoFisico).getRecordTypeId();

  public static void fillNameFromCampaignMember(List<EV_CampaignMemberC__c> listNews){
    EV_LogDebug.printLogDebug('fillNameFromCampaignMemberC ',String.valueof(listNews));
    for(EV_CampaignMemberC__c cm : listNews){
      if(cm.EV_FirstName__c != null && cm.EV_LastName__c != null){
        cm.EV_NameCampaignMember__c = cm.EV_FirstName__c + ' ' + cm.EV_LastName__c; 
      }else{
        cm.EV_NameCampaignMember__c = cm.EV_FirstName__c;
      }
    }
  }

  public static void rtCampaignMember(List<EV_CampaignMemberC__c> listNews){
    EV_LogDebug.printLogDebug('rtCampaignMember ',String.valueof(listNews));
    
    for(EV_CampaignMemberC__c cm : listNews){
      if( cm.EV_RTCampaign__c == rtEventoAccionistas){
        cm.RecordTypeId = rtCMeventoACC;
      }else if (cm.EV_RTCampaign__c == rtFestivales) {
        cm.RecordTypeId = rtCMFestivales;
      }else{
        cm.RecordTypeId = rtCMevento;
      }
    }
  }

  public static void fillFormatoAsistenciaByRT(List<EV_CampaignMemberC__c> listNews){
    EV_LogDebug.printLogDebug('fillFormatoAsistenciaByRTC ',String.valueof(listNews));
    for(EV_CampaignMemberC__c cm : listNews){
      if(cm.EV_RTCampaign__c == rtEventoVirtual){
        cm.EV_FormatoDeAsistencias__c = '002';
      }else if(cm.EV_RTCampaign__c == rtEventoFisico){
        cm.EV_FormatoDeAsistencias__c = '001';
      }
    } 
  }

  public static void memberCampaignWithoutAccount(List<EV_CampaignMemberC__c> listNews){
    EV_LogDebug.printLogDebug('memberCampaignWithoutAccountC ',String.valueof(listNews));
    for(EV_CampaignMemberC__c cm : listNews){
      if(cm.EV_AccountId__c!=null){
        cm.EV_Empresa__c = true;
      }
    }
  }

  public static void eventSurvey(List<EV_CampaignMemberC__c> listNews,  Map<Id, EV_CampaignMemberC__c> mapOldObj, Boolean isInsert) {
    EV_LogDebug.printLogDebug('eventSurveyC ',String.valueof(listNews));

    List<Lead> listLead = new List<Lead>();
    List<EV_CampaignMemberC__c> lstCampaignMembers = new List<EV_CampaignMemberC__c>();
    List<EV_CampaignMemberC__c> lstCampaignMembersTemp = new List<EV_CampaignMemberC__c>();
    List<Id> listAccountId = new List<Id>();
    Map<Id,Id> mapLeadCampaign = new Map<Id,Id>();
    Map<Id,Set<Id>> mapCampaignAccount = new Map<Id,Set<Id>>();
    Set<String> campignStatusConfirmed = new Set<String>{'Asistió','Accedio a la oferta'};
    for(EV_CampaignMemberC__c campMember : listNews){
      if(((campignStatusConfirmed.contains(campMember.EV_Status__c) && mapOldObj != null && mapOldObj.get(campMember.Id).EV_Status__c != campMember.EV_Status__c) || (campignStatusConfirmed.contains(campMember.EV_Status__c) && isInsert)) 
      && campMember.EV_LeadId__c != null && (campMember.RecordtypeId == rtCMevento || campMember.RecordtypeId == rtCMeventoACC || campMember.RecordTypeId == rtCMFestivales) && campMember.EV_CampaignTechSummit__c == false){
        mapLeadCampaign.put(campMember.EV_LeadId__c,campMember.EV_CampaignId__c);
      }
    }

    EV_LogDebug.printLogDebug('mapLeadCampaign eventSurveyC',String.valueof(mapLeadCampaign));
    if(mapLeadCampaign != null && !mapLeadCampaign.isEmpty()){
      listLead = [SELECT Id, Name, EV_Account__c FROM Lead WHERE Id IN : mapLeadCampaign.keySet() and EV_Account__c != null];
      if(listLead!=null){
        for(Lead l : listLead){
            Set<Id> ids= new Set<Id>();
            ids.add(l.EV_Account__c);
          if(!mapCampaignAccount.containsKey(mapLeadCampaign.get(l.Id))){
            mapCampaignAccount.put(mapLeadCampaign.get(l.Id),ids);
          }else{
            ids.addAll(mapCampaignAccount.get(mapLeadCampaign.get(l.Id)));
            mapCampaignAccount.put(mapLeadCampaign.get(l.Id),ids);
          }
        }
      }

      for(set<id> i : mapCampaignAccount.values()){
        listAccountId.addall(i);
      }  
      
      lstCampaignMembersTemp = [SELECT Id, EV_Status__c, EV_AccountId__c, EV_CampaignId__c, RecordtypeId FROM EV_CampaignMemberC__c WHERE EV_CampaignId__c IN :mapCampaignAccount.keySet() and EV_AccountId__c IN :listAccountId];

      for(EV_CampaignMemberC__c cmp :lstCampaignMembersTemp){
        if(mapCampaignAccount.get(cmp.EV_CampaignId__c).contains(cmp.EV_AccountId__c)){
          lstCampaignMembers.add(cmp);
        }
      }

      if(lstCampaignMembers!=null){
        for(EV_CampaignMemberC__c cmember : lstCampaignMembers){
          if(cmember.RecordtypeId == rtCMevento || cmember.RecordtypeId == rtCMeventoACC ){
          cmember.EV_Status__c = 'Asistió';
          }else{
            cmember.EV_Status__c = 'Accedio a la oferta';
          }
        }
        database.update(lstCampaignMembers);
      }
    }
  }

public static void linkUniqueSurveyGeneration(List<EV_CampaignMemberC__c> listNews, Map<Id, EV_CampaignMemberC__c> mapOld) {
    EV_LogDebug.printLogDebug('linkUniqueSurveyGenerationC ',String.valueof(listNews) + ' ' + String.valueof(mapOld));
    Set<Id> setCampaignIds = new Set<Id>();
    Set<String> campMemberStatus = new Set<String>{'QR enviado', 'Registro confirmado', 'Pendiente', 'Invitación enviada'};
    Set<String> campMemberStatusConfirmed = new Set<String>{'Asistió','Accedio a la oferta'};
    
    List<Campaign> listCampaign = new List<Campaign>();
    Map<String, Campaign> mapCampaign = new Map<String, Campaign>();
    //Id rtEvento = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
    //Id rtAccionista = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_EventosAccionistas').getRecordTypeId();
    Network network = [SELECT Id FROM Network WHERE Name = 'Eventos - Encuestas CaixaBank' LIMIT 1];
    for(EV_CampaignMemberC__c campMember : listNews){
      if(((campMemberStatus.contains(campMember.EV_Status__c) && campMember.EV_ContadorCheckInVirtual__c >= 1) || 
          (mapOld != null && (mapOld.get(campMember.Id).EV_ContadorCheckInVirtual__c != campMember.EV_ContadorCheckInVirtual__c) && mapOld.get(campMember.Id).EV_Status__c != 'Asistió' && campMember.EV_CampaignTechSummit__c == true) ||
      (mapOld != null && mapOld.get(campMember.Id).EV_Status__c != campMember.EV_Status__c && campMemberStatusConfirmed.contains(campMember.EV_Status__c)) ||
      (mapOld == null && campMemberStatusConfirmed.contains(campMember.EV_Status__c))) && (campMember.RecordtypeId == rtCMevento || campMember.RecordtypeId == rtCMeventoAcc || campMember.RecordTypeId == rtCMFestivales)){
        setCampaignIds.add(campMember.EV_CampaignId__c);
      }
    }
    EV_LogDebug.printLogDebug('setCampaignIds linkUniqueSurveyGeneration',String.valueof(setCampaignIds));
    if(setCampaignIds != null && !setCampaignIds.isEmpty()){
      listCampaign = [SELECT Id, EV_Encuesta__c FROM Campaign WHERE Id IN:setCampaignIds];
      if(listCampaign!=null){
        for(Campaign camp: listCampaign){
          mapCampaign.put(camp.Id, camp);
        }
      }
      for(EV_CampaignMemberC__c campMember : listNews){
        SurveyInvitation survey = new SurveyInvitation();
        if(mapOld != null && mapOld.get(campMember.Id).EV_Status__c != 'Asistió' && campMember.EV_Status__c != 'Asistió' && campMember.RecordtypeId == rtCMevento && campMember.EV_CampaignTechSummit__c == true){
            campMember.EV_Status__c = 'Asistió';      
        }
        else if(campMemberStatus.contains(campMember.EV_Status__c) && campMember.EV_ContadorCheckInVirtual__c >= 1 && (campMember.RecordtypeId == rtCMevento || campMember.RecordtypeId == rtCMeventoAcc || campMember.RecordTypeId == rtCMFestivales)){
          if(campMember.RecordTypeId == rtCMFestivales){
            campMember.EV_Status__c = 'Accedio a la oferta';
          }else{
          campMember.EV_Status__c = 'Asistió';
          }
          
          survey.CommunityId = network.Id;
          survey.EV_Campaign__c = campMember.EV_CampaignId__c;
          if(campMember.EV_LastName__c != null || campMember.EV_FirstName__c != null){
            survey.Name = campMember.EV_LastName__c+'_'+campMember.EV_FirstName__c+'_Survey_Invitation_'+Datetime.now();
          }else{
            survey.Name = '_Survey_Invitation_'+Datetime.now();
          }
          if(campMember.EV_LeadId__c!=null && campMember.EV_ContactId__c==null && campMember.EV_AccountId__c == null){
            survey.ParticipantId = campMember.EV_LeadId__c;
            survey.OptionsAllowGuestUserResponse = true;
          }else if(campMember.EV_LeadId__c==null && campMember.EV_ContactId__c!=null && campMember.EV_AccountId__c == null){
            survey.ParticipantId = campMember.EV_ContactId__c;
            survey.OptionsAllowGuestUserResponse = true;
          }else if (campMember.EV_LeadId__c==null && campMember.EV_ContactId__c==null && campMember.EV_AccountId__c != null){
            survey.ParticipantId = campMember.LastModifiedById;
            survey.OptionsAllowGuestUserResponse = false;
          }
          survey.SurveyId = mapCampaign.get(campMember.EV_CampaignId__c).EV_Encuesta__c;

          if(survey!=null){
            Database.insert(survey);
            campMember.EV_InvitacionEncuesta__c = survey.Id;
          }
        }else if(mapOld != null && mapOld.get(campMember.Id).EV_Status__c != campMember.EV_Status__c && campMemberStatusConfirmed.contains(campMember.EV_Status__c) && (campMember.RecordtypeId == rtCMevento || campMember.RecordtypeId == rtCMeventoAcc)){
          survey.CommunityId = network.Id;
          survey.EV_Campaign__c = campMember.EV_CampaignId__c;
          if(campMember.EV_LastName__c != null || campMember.EV_FirstName__c != null){
            survey.Name = campMember.EV_LastName__c+'_'+campMember.EV_FirstName__c+'_Survey_Invitation_'+Datetime.now();
          }else{
            survey.Name = '_Survey_Invitation_'+Datetime.now();
          }
          if(campMember.EV_LeadId__c!=null && campMember.EV_ContactId__c==null && campMember.EV_AccountId__c == null){
            survey.ParticipantId = campMember.EV_LeadId__c;
            survey.OptionsAllowGuestUserResponse = true;
          }else if(campMember.EV_LeadId__c==null && campMember.EV_ContactId__c!=null && campMember.EV_AccountId__c == null){
            survey.ParticipantId = campMember.EV_ContactId__c;
            survey.OptionsAllowGuestUserResponse = true;
          }else if (campMember.EV_LeadId__c==null && campMember.EV_ContactId__c==null && campMember.EV_AccountId__c != null){
            survey.ParticipantId = campMember.LastModifiedById;
            survey.OptionsAllowGuestUserResponse = false;
          }
          survey.SurveyId = mapCampaign.get(campMember.EV_CampaignId__c).EV_Encuesta__c;

          if(survey!=null){
            Database.insert(survey);
            campMember.EV_InvitacionEncuesta__c = survey.Id;
          }
        }else if (mapOld == null && campMemberStatusConfirmed.contains(campMember.EV_Status__c) && (campMember.RecordtypeId == rtCMevento || campMember.RecordtypeId == rtCMeventoAcc)){             
          survey.CommunityId = network.Id;
          survey.EV_Campaign__c = campMember.EV_CampaignId__c;
          if(campMember.EV_LastName__c != null || campMember.EV_FirstName__c != null){
            survey.Name = campMember.EV_LastName__c+'_'+campMember.EV_FirstName__c+'_Survey_Invitation_'+Datetime.now();
          }else{
            survey.Name = '_Survey_Invitation_'+Datetime.now();
          }
          if(campMember.EV_LeadId__c!=null && campMember.EV_ContactId__c==null && campMember.EV_AccountId__c == null){
            survey.ParticipantId = campMember.EV_LeadId__c;
            survey.OptionsAllowGuestUserResponse = true;
          }else if(campMember.EV_LeadId__c==null && campMember.EV_ContactId__c!=null && campMember.EV_AccountId__c == null){
            survey.ParticipantId = campMember.EV_ContactId__c;
            survey.OptionsAllowGuestUserResponse = true;
          }else if (campMember.EV_LeadId__c==null && campMember.EV_ContactId__c==null && campMember.EV_AccountId__c != null){
            survey.ParticipantId = campMember.LastModifiedById;
            survey.OptionsAllowGuestUserResponse = false;
          }
          survey.SurveyId = mapCampaign.get(campMember.EV_CampaignId__c).EV_Encuesta__c;

          if(survey!=null){
            Database.insert(survey);
            campMember.EV_InvitacionEncuesta__c = survey.Id;
          }
        }
      }
    }
  }

  public static void generarIdSeguro(List<EV_CampaignMemberC__c> listNewObj) {
    EV_LogDebug.printLogDebug('generarIdSeguroC ',String.valueof(listNewObj));
    List<EV_CampaignMemberC__c> lstAux = new List<EV_CampaignMemberC__c>();
    
    for(EV_CampaignMemberC__c campMember : listNewObj){
          Blob b = Crypto.GenerateAESKey(128);
          String h = EncodingUtil.ConvertTohex(b);
          String guid = h.SubString(0,18);
          campMember.EV_ExternalID__c = EV_Utilities.generateSecureId(guid +campMember.EV_NumeroDocumento__c+campMember.EV_CampaignId__c+campMember.EV_Email__c + campMember.EV_ExternalID__c+ String.valueOf(Datetime.now()) + campMember.EV_ContactId__c).replace('%','').replace('&','');
          lstAux.add(campMember);
    }
  }

  public static void actualizarContadorCheckInVirtual(List<EV_CampaignMemberC__c> listNewObj, Map<Id, EV_CampaignMemberC__c> mapOldObj, boolean isInsert) {
    EV_LogDebug.printLogDebug('actualizarContadorCheckInVirtualC ',String.valueof(listNewObj)+ ' ' +String.valueof(mapOldObj));

    Map<String,Object> mapextIdCMS = new Map<String,Object>();
        Map<String,Object> mapextIdCMCustom = new Map<String,Object>();
    for(EV_CampaignMemberC__c cms : listNewObj){
        EV_CampaignMemberC__c cmcOld = mapOldObj.get(cms.id);
      if(cms.EV_ContadorCheckInVirtual__c == 1 && !system.isBatch() && cms.EV_ContadorCheckInVirtual__c != cmcOld.EV_ContadorCheckInVirtual__c){
        if(!String.isEmpty(cms.EV_ExternalID__c)){
          mapextIdCMS.put(cms.EV_ExternalID__c,cms);
        } else if (String.isEmpty(cms.EV_ExternalID__c)){
          cms.addError(Label.EV_ControlExternalId);
        }
      }
    }
    EV_LogDebug.printLogDebug('@@mapextIdCMS actualizarContadorCheckInVirtualC', String.valueOf(mapextIdCMS.keySet()));

    if(mapextIdCMS != null && !mapextIdCMS.isEmpty()){
      List<EV_CampaignMemberC__c> listCampaignMemberCustom = [SELECT Id, EV_ExternalId__c,EV_ContadorCheckInVirtual__c,EV_CampaignId__r.EV_LimiteRegistrosVirtuales__c, EV_CampaignId__r.EV_NewArchitecture__c FROM EV_CampaignMemberC__c WHERE EV_ExternalID__c in :mapextIdCMS.keySet() and (RecordtypeId = :rtCMevento or RecordtypeId = :rtCMeventoAcc or RecordtypeId = :rtCMFestivales)];
      List<EV_CampaingMemeberStaging__c> cmsList = new List<EV_CampaingMemeberStaging__c>();
      List<EV_CampaignMemberC__c> cmcList = new List<EV_CampaignMemberC__c>();
      EV_LogDebug.printLogDebug('@@listCampaignMemberCustom', String.valueOf(listCampaignMemberCustom));

      if(!listCampaignMemberCustom.isEmpty()){       
       
          for(EV_CampaignMemberC__c cms : listNewObj){
              EV_LogDebug.printLogDebug('@@NO Insert actualizarContadorCheckInVirtualC', String.valueof(IsInsert));
              Integer contador = 0;
              EV_CampaignMemberC__c mapCMC= (EV_CampaignMemberC__c)mapextIdCMS.get(cms.EV_ExternalId__c);
              contador = (Integer)cms.EV_ContadorCheckInVirtual__c ;
              cms.Id = mapCMC.id;
              cms.EV_ExternalId__c = mapCMC.EV_ExternalID__c;
              cms.EV_ContadorCheckInVirtual__c = mapOldObj.get(cms.Id).EV_ContadorCheckInVirtual__c + cms.EV_ContadorCheckInVirtual__c;
              cms.EV_Origen__c = mapCMC.EV_Origen__c;
              cms.EV_Numperso__c = mapCMC.EV_Numperso__c;
              cms.EV_Canal__c = mapCMC.EV_Canal__c;
          }    
      }
    }
  }

  public static void processCampaignMemberForQR(List<EV_CampaignMemberC__c> listNewObj, Map<Id, EV_CampaignMemberC__c> mapOldObj) {
    EV_LogDebug.printLogDebug('processCampaignMemberForQRC ',String.valueof(listNewObj));
    Set<Id> setCampMembers = new Set<Id>();        
    for(EV_CampaignMemberC__c campMember : listNewObj ){
      if(campMember.EV_Status__c != mapOldObj.get(campMember.Id).EV_Status__c && campMember.EV_Status__c == 'Registro Confirmado' && campMember.EV_CampaignTechSummit__c == false){
        setCampMembers.add(campMember.Id);
      }
    }
    EV_LogDebug.printLogDebug('setCampMembers processCampaignMemberForQRC',String.valueof(setCampMembers));
    if(setCampMembers != null && setCampMembers.size() >0){
      generarQR(setCampMembers);
    }
  }

  @future (callout=true)
  public static void generarQR(Set<Id> setCampMembers) {
    EV_LogDebug.printLogDebug('generarQRC ',String.valueof(setCampMembers));

    List<EV_CampaignMemberC__c> lstCampaignMembers = [SELECT Id, Name, EV_Status__c, EV_ContactId__r.CC_Sexo__c, EV_LeadId__c, EV_ContactId__c, EV_CampaignId__r.EV_HoraFinAC__c, EV_CampaignId__r.EV_HoraInicioAC__c, EV_CampaignId__r.StartDate, EV_ContactId__r.EV_Idiomas__c, EV_LeadId__r.EV_Idiomas__c,
    EV_CampaignId__c, EV_CampaignId__r.Name, EV_CampaignId__r.EV_Description__c, EV_CampaignId__r.EV_LugarDeCelebracion__c FROM EV_CampaignMemberC__c WHERE Id IN: setCampMembers AND (RecordtypeId =:rtCMevento or RecordtypeId =:rtCMEventoAcc  or RecordtypeId = :rtCMFestivales)];
    for(EV_CampaignMemberC__c campMember : lstCampaignMembers ){
      Map<String, String> mapRequestResponse = (Map<String, String>) JSON.deserialize(EV_ConexionQR.conexQRCMCustom(campMember), Map<String, String>.class);
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
        campMember.EV_QRLog__c = Label.EV_QRMal;
      }
    }

    if(lstCampaignMembers!=null){
      Database.update(lstCampaignMembers);
    }
  }

  public static void inscripcionNRT(Map<Id,EV_CampaignMemberC__c> mapNewObj){
    EV_LogDebug.printLogDebug('inscripcionNRTC ',String.valueof(mapNewObj));

    Set<Id> leadIds = new Set<Id>();
    for(EV_CampaignMemberC__c campMember : mapNewObj.values()){
      if(campMember.EV_LeadId__c != null && (campMember.RecordtypeId == rtCMevento || campMember.RecordtypeId == rtCMeventoAcc || campMember.RecordtypeId == rtCMFestivales) && campMember.EV_CampaignTechSummit__c == false){
        leadIds.add(campMember.EV_LeadId__c); 
      }
    }
    if(leadIds != null && !leadIds.isEmpty()){
      inscripcionNRT(leadIds, mapNewObj.keySet());
    }
  }

  @future (callout=true)
  public static void inscripcionNRT(Set<Id> leadIds, Set<Id> campMembIds) {
    EV_LogDebug.printLogDebug('inscripcionNRTC ',String.valueof(leadIds) + ' ' + String.valueof(campMembIds));

    Map<Id, EV_CampaignMemberC__c> mapCampMembers = new Map<Id, EV_CampaignMemberC__c>([SELECT Id, EV_CampaignId__c, EV_FormatodeAsistencias__c, EV_RTCampaign__c, LastModifiedById, RecordTypeId, LastModifiedDate, CreatedById, EV_LeadId__c, CreatedDate, EV_MobilePhone__c, EV_Phone__c, EV_Email__c, EV_Status__c, EV_CanalOrigen__c, 
    EV_TelefonoDeCampana__c, EV_Nickname__c, EV_QR__c, EV_NumeroDocumento__c, EV_URLEncuesta__c, EV_ExternalID__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM EV_CampaignMemberC__c WHERE Id IN: campMembIds]);
    Map<Id,Lead> mapLeads;
    
    if(leadIds != null && !leadIds.isEmpty()){
      mapLeads = new Map<Id,Lead>([SELECT Id, FirstName, LastName, CreatedDate, LastmodifiedDate, Phone, Email, Status, RecordTypeId, EV_Idiomas__c, EV_NumeroDocumento__c, EV_Marketing__c, EV_ConsentimientoGeneral__c, EV_ConsentimientoTerceros__c FROM Lead WHERE Id IN :leadIds]);
    }
    
    for(EV_CampaignMemberC__c campMember : mapCampMembers.values()){
      
      if( campMember.EV_LeadId__c != null && mapLeads != null && mapLeads.containsKey(campMember.EV_LeadId__c) && (campMember.RecordtypeId == rtCMevento || campMember.RecordtypeId == rtCMeventoAcc || campMember.RecordtypeId == rtCMFestivales)){
        EV_AdobeCampaignInscripcion.inscriptionEventCMCustom(null,campMember.EV_CampaignId__c,null,mapLeads.get(campMember.EV_LeadId__c), campMember);
      }
    }
  }

/**
  * @description       Count number of Campaign Member C physical in Campaign
  * @param Map<Id, Campaign> mapNewObj    Map to New Campaign
  * @param Map<Id, Campaign> mapOldObj    Map to Old Campaign
  */
  public static void updateRollup(Map<Id, EV_CampaignMemberC__c> mapNewObj, Map<Id, EV_CampaignMemberC__c> mapOldObj){
    EV_LogDebug.printLogDebug('updateRollup ',String.valueof(mapNewObj) + ' ' + String.valueof(mapOldObj));

        Map<Id,Integer> aggAsis = new Map<Id,Integer>();
        Map<Id,Integer> aggInscri = new Map<Id,Integer>();
        Map<Id,Integer> aggTotal = new Map<Id,Integer>();
        Map<Id,Campaign> campaignUpdate = new Map<Id,Campaign>();
        Set<Id> idCamp = new Set<Id>();
        
        for(EV_CampaignMemberC__c c: mapNewObj.values()){
            if((mapOldObj != null && ((mapOldObj.get(c.id).EV_FormatoDeAsistencias__c != c.EV_FormatoDeAsistencias__c) || (mapOldObj.get(c.id).EV_Status__c != c.EV_Status__c))) || (mapOldObj == null && (c.EV_Status__c == 'Registro confirmado' || c.EV_Status__c == 'Asistió' || c.EV_Status__c == 'QR Enviado' || c.EV_Status__c == 'Accedio a la oferta'))){
              idCamp.add(c.EV_CampaignId__c);
            }
        }
    EV_LogDebug.printLogDebug('ids Campaign rollup ',String.valueof(idCamp));
        if(!idCamp.isEmpty()){
      List<AggregateResult> agrr = [SELECT count(id) t, EV_Status__c,  EV_CampaignId__c,EV_FormatoDeAsistencias__c FROM EV_CampaignMemberC__c where (EV_Status__c= 'Registro confirmado' or EV_Status__c = 'Asistió' or EV_Status__c= 'QR Enviado' or EV_Status__c = 'Accedio a la oferta') and EV_CampaignId__c in : idCamp GROUP BY EV_CampaignId__c, EV_Status__c,EV_FormatoDeAsistencias__c];
            EV_LogDebug.printLogDebug('ids Campaign rollup ',String.valueof(agrr));
            for(AggregateResult arr : agrr){
                String idC = (String)arr.get('EV_CampaignId__c');
                if(aggAsis.containsKey(idC)){
                    if((String)arr.get('EV_FormatoDeAsistencias__c') == '001' && ((String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                        Integer asis = aggAsis.get(idC);
                        Integer totalAsis = (Integer)arr.get('t') + asis;
                        aggAsis.put(idC, totalAsis);
                    }
                }else{
                        if((String)arr.get('EV_FormatoDeAsistencias__c') == '001' && (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta'){
                            Integer totalAsis = (Integer)arr.get('t');
                            aggAsis.put(idC, totalAsis); 
                        }  
                }
                if(aggInscri.containsKey(idC)){
                    if((String)arr.get('EV_FormatoDeAsistencias__c') == '001' && ((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Registro confirmado' ||  (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                        Integer inscri = aggInscri.get(idC);
                        Integer totalInscri = (Integer)arr.get('t') + inscri;
                        aggInscri.put(idC, totalInscri);
                    }
                }else{
                    if((String)arr.get('EV_FormatoDeAsistencias__c') == '001' && ((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Registro confirmado' || (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta')){
                        Integer totalInscri = (Integer)arr.get('t');
                        aggInscri.put(idC, totalInscri);
                    }
                }
                if(aggTotal.containsKey(idC)){  
                    if((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Registro confirmado' ||  (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta'){
                        Integer count = aggTotal.get(idC);
                        Integer total = (Integer)arr.get('t') + count;
                        aggTotal.put(idC, total);
                    }
                }else{
                    if((String)arr.get('EV_Status__c') == 'QR Enviado' || (String)arr.get('EV_Status__c') == 'Registro confirmado' || (String)arr.get('EV_Status__c') == 'Asistió' || (String)arr.get('EV_Status__c') == 'Accedio a la oferta'){
                        Integer total = (Integer)arr.get('t');
                        aggTotal.put(idC, total);
                    }
                    
                }
                EV_LogDebug.printLogDebug('agrr rollup ',String.valueof(arr));
            }
            EV_LogDebug.printLogDebug('aggAsis ',String.valueof(aggAsis) + ' ' +aggAsis.values() );
            EV_LogDebug.printLogDebug('aggInscri ',String.valueof(aggInscri) + ' ' +aggInscri.values() );
            EV_LogDebug.printLogDebug('aggTotal ',String.valueof(aggTotal) +' ' + aggTotal.values() );
    
            for(EV_CampaignMemberC__c c: mapNewObj.values()){
                Campaign camp = new Campaign();
                Integer asisFisi = aggAsis.get(c.EV_CampaignId__c);
                Integer inscFisi = aggInscri.get(c.EV_CampaignId__c);
                Integer total = aggTotal.get(c.EV_CampaignId__c);
                camp.Id = c.EV_campaignId__c;
                if(asisFisi != null){
                    camp.EV_AsistentesFisicosC__c = asisFisi;
                }else{
                    camp.EV_AsistentesFisicosC__c = 0;
                }if(inscFisi != null){
                    camp.EV_InscritosFisicosC__c = inscFisi;
                }else{
                    camp.EV_InscritosFisicosC__c = 0;
                }if(total != null){
                    camp.EV_TotalInscritosC__c = total;
                }else{
                    camp.EV_TotalInscritosC__c = 0;  
                }
                if(!campaignUpdate.containsKey(camp.id)){
                    campaignUpdate.put(camp.id, camp);
                }else{
                    campaignUpdate.put(camp.id, camp);
                }
    
            }
    
                
            EV_LogDebug.printLogDebug('campaignUpdate ',String.valueof(campaignUpdate));
            Database.update(campaignUpdate.values(), false);
        }

  }
  
  public static void inscripcionCliente(Map<Id, EV_CampaignMemberC__c> mapNewObj, Map<Id, EV_CampaignMemberC__c> mapOldObj) {
    EV_LogDebug.printLogDebug('inscripcionClienteC ',String.valueof(mapNewObj) + ' ' + String.valueof(mapOldObj));


    String statusRegistrado = 'Registro confirmado'; 
    Set<Id> recordIds = new Set<Id>();
    Id rtEvento = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_Eventos').getRecordTypeId();
    Id rtAccionista = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_EventosAccionistas').getRecordTypeId();
    
    for(EV_CampaignMemberC__c campMember : mapNewObj.values()){
          if(campMember.EV_Status__c == statusRegistrado && mapOldObj.get(campMember.Id).EV_Status__c != campMember.EV_Status__c && (campMember.RecordtypeId == rtEvento || campMember.RecordtypeId == rtAccionista) && campMember.EV_CampaignTechSummit__c == false){
            recordIds.add(campMember.Id);
          }
    }

    if(recordIds.size() > 0 && recordIds != null){
      inscripcionNRT(recordIds);
    }
  }

  @future (callout=true)
  public static void inscripcionNRT(Set<Id> recordIds) {
    EV_LogDebug.printLogDebug('inscripcionNRTC ',String.valueof(recordIds));
    Map<Id, EV_CampaignMemberC__c> mapCampMembers = new Map<Id, EV_CampaignMemberC__c>([SELECT Id, LastModifiedById, LastModifiedDate, CreatedById, CreatedDate, EV_MobilePhone__c, EV_Phone__c, EV_Email__c, EV_Status__c, EV_CanalOrigen__c, 
    EV_TelefonoDeCampana__c, EV_Nickname__c, EV_QR__c, EV_NumeroDocumento__c, EV_URLEncuesta__c, EV_ExternalID__c, EV_EmailDeCampana__c, EV_CampaignId__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM EV_CampaignMemberC__c WHERE Id IN: recordIds]);
    
    for(EV_CampaignMemberC__c campMember : mapCampMembers.values()){
      if(campMember.EV_EmailDeCampana__c != null){
        EV_AdobeCampaignInscripcion.inscriptionEventCMCustom(campMember.Id,campMember.EV_CampaignId__c,campMember.EV_EmailDeCampana__c,null,null); 
      }else{
        EV_AdobeCampaignInscripcion.inscriptionEventCMCustom(campMember.Id,campMember.EV_CampaignId__c,null,null,null); 
      }
    }
  }

  public static void crearHistoricoDelete(List<EV_CampaignMemberC__c> listOldObj, Map<Id, String> mapNameForLeads) {
    EV_LogDebug.printLogDebug('crearHistoricoDeleteC ',String.valueof(listOldObj) + ' ' + String.valueof(mapNameForLeads));
    
    List<EV_CampaignMemberHistory__c> ch = new List<EV_CampaignMemberHistory__c>(); 
    
    for(EV_CampaignMemberC__c cmOld : listOldObj)
    {           
      EV_CampaignMemberHistory__c cmHistorial = new EV_CampaignMemberHistory__c();               
      cmHistorial.EV_Campaign_Id__c = cmOld.EV_CampaignId__c;            
      cmHistorial.EV_CampaignMember_Id__c = cmOld.Id;    
      cmHistorial.EV_Nombre_Miembro__c = mapNameForLeads.get(cmOld.EV_LeadId__c);
      cmHistorial.EV_Lead__c = cmOld.EV_LeadId__c;     
      cmHistorial.EV_Usuario__c = userinfo.getUserId();
      cmHistorial.EV_Accion_Trigger__c = 'Delete';
      cmHistorial.EV_Detalles_del_historial__c = DateTime.now() + ' - Se ha eliminado al Campaign Member Id: ' 
        + cmOld.id + ' perteneciente a la Campaign Id: '+ cmOld.EV_CampaignId__c + ' por el usuario: '+ userinfo.getUserName();
      
      ch.add(cmHistorial);
    }
    
    if(!ch.isEmpty())
    {
      insert ch;
    }
  }
    
    public static void sendSingleEmail(List<EV_CampaignMemberC__c> lstCM){ 
      	EV_LogDebug.printLogDebug('sendSingleEmail ',String.valueof(lstCM));
        EmailTemplate emailTemplateOficina = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'EV_SingleEmailTech' limit 1]; 
        List<OrgWideEmailAddress> orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress where Address = 'invitation@event.caixabank.com' LIMIT 1];
        List<EV_CampaignMemberC__c> campaginMembList = new List<EV_CampaignMemberC__c> ();             
        List<Id> campaginMembIds = new List<Id>();
        Map<String, String> msjsError = new Map<String, String>();
        for(EV_CampaignMemberC__c cm : lstCM){
            campaginMembIds.add(cm.Id);
        }
        
        if(EV_CampaignMemberC__c.SObjectType.getDescribe().isAccessible()) {
            campaginMembList = [SELECT id,EV_CampaignId__r.Name, EV_CampaignId__r.RecordType.DeveloperName, EV_LeadId__c, EV_URLStreamingEvento__c, EV_CodigoQR__c, EV_CampaignId__r.EV_URLDelEventoVirtual__c,EV_FirstName__c, EV_CampaignId__r.StartDate, EV_CampaignId__r.EV_HoraInicio__c, EV_CampaignId__r.EV_HoraFin__c, EV_CampaignId__r.EV_Description__c,EV_CampaignId__r.EV_Duracion__c, EV_CampaignId__r.EV_LugarDeCelebracion__c, EV_CampaignId__r.EV_Street__c, EV_CampaignId__r.EV_CP__c, EV_CampaignId__r.EV_City__c, EV_LeadId__r.Email, RecordTypeId, EV_Status__c, EV_CampaignId__c, EV_CampaignId__r.EV_TechSummit__c
                                FROM EV_CampaignMemberC__c 
                                WHERE Id IN: campaginMembIds AND EV_CampaignId__r.EV_TechSummit__c = true AND EV_CampaignId__r.EV_NewArchitecture__c = true]; 
        }
        EV_LogDebug.printLogDebug('campaginMembList ',String.valueof(campaginMembList));
        if(!campaginMembList.isEmpty()){
          Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>{};
          
          for(EV_CampaignMemberC__c cmc :campaginMembList){
              String html = emailTemplateOficina.HtmlValue;
              String asunto = emailTemplateOficina.Subject;
              Blob icsFile = Blob.valueOf(generateICSFile(cmc.EV_CampaignId__r.RecordType.DeveloperName, cmc.EV_CampaignId__r.StartDate, cmc.EV_CampaignId__r.EV_HoraInicio__c, 
                                                          cmc.EV_CampaignId__r.EV_HoraFin__c, cmc.EV_CampaignId__r.EV_Description__c, cmc.EV_CampaignId__r.Name, cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c, cmc.EV_CampaignId__r.EV_URLDelEventoVirtual__c, cmc.EV_CodigoQR__c));
              Datetime fecha = datetime.newInstance(cmc.EV_CampaignId__r.StartDate.year(), cmc.EV_CampaignId__r.StartDate.month(), cmc.EV_CampaignId__r.StartDate.day());
              String hora = String.valueof(cmc.EV_CampaignId__r.EV_HoraInicio__c);
              asunto = asunto.replace('{!Campaign.Name}', cmc.EV_CampaignId__r.Name);
              asunto = asunto.replace('{!EV_CampaignMemberC__c.EV_FirstName__c}', cmc.EV_FirstName__c);
              html = html.replace('[DATESTART]',String.valueOf(cmc.EV_CampaignId__r.StartDate.day()));
              html = html.replace('[MONTHSTART]',String.valueOf(fecha.format('MMMM')));
              html = html.replace('{!Campaign.Name}', cmc.EV_CampaignId__r.Name);
              html = html.replace('{!Campaign.EV_HoraInicio__c}', hora.substring(0, 5));
              html = html.replace('{!Campaign.EV_Duracion__c}', string.valueOf(cmc.EV_CampaignId__r.EV_Duracion__c));
              html = html.replace('{!Campaign.EV_LugarDeCelebracion__c}', !String.isEmpty(cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c) ? cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c : '');
              html = html.replace('{!Campaign.EV_Street__c}', !String.isEmpty(cmc.EV_CampaignId__r.EV_Street__c) ? cmc.EV_CampaignId__r.EV_Street__c : '');
              html = html.replace('{!Campaign.EV_CP__c}', !String.isEmpty(cmc.EV_CampaignId__r.EV_CP__c) ? (cmc.EV_CampaignId__r.EV_CP__c + ', ') : '');
              html = html.replace('{!Campaign.EV_City__c}', !String.isEmpty(cmc.EV_CampaignId__r.EV_City__c) ? cmc.EV_CampaignId__r.EV_City__c : '');
              html = html.replace('{!EV_CampaignMemberC__c.EV_FirstName__c}', cmc.EV_FirstName__c);
              html = html.replace('{!EV_CampaignMemberC__c.EV_CodigoQR__c}', cmc.EV_CodigoQR__c);
              Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
              attachment.setFileName(cmc.EV_CampaignId__r.Name + '.ics');
              attachment.setContentType('text/calendar');
              attachment.setInline(false);
              attachment.setBody(icsFile); 
              EV_LogDebug.printLogDebug('icsFile ',String.valueof(icsFile));
              Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
              message.setToAddresses(new String[]{cmc.EV_LeadId__r.Email});
              message.setTargetObjectId(cmc.EV_LeadId__c);
              message.setTemplateId(emailTemplateOficina.Id);
              message.Subject = asunto;
              message.setHtmlBody(html);
              message.optOutPolicy = 'FILTER'; 
              message.setSaveAsActivity(false); 
              message.setUseSignature(true);
              message.setOrgWideEmailAddressId(orgwideaddress.get(0).Id);
              message.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
              messages.add(message);
          }
            EV_LogDebug.printLogDebug('messages ',String.valueof(messages));
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            for (Messaging.SendEmailResult result : results) {
                if (result.isSuccess()) {
                    EV_LogDebug.printLogDebug('result.isSuccess()',String.valueof(result));
                } else {
                    String errorMessage = 'Error al enviar el correo electrónico: ';
                    if (result.getErrors() != null && !result.getErrors().isEmpty()) {
                        for (Messaging.SendEmailError error : result.getErrors()) {
                            errorMessage += error.getMessage() + '\n';
                            msjsError.put(error.getMessage(), String.valueof(error));
                        }
                    }
                    CBK_Log.error(msjsError);
                }
            }
        }
  }


    
    public static String generateICSFile(String evtRT, Date evStartDate, Time evHoraInicio, Time evHoraFin, String evDescription, String evName, String evLocation, String cmQRcode, String cmQRstreaming) {
        String urlQR = cmQRcode;
        String urlQRFisico = '';
        system.debug('@@cmQRstreaming '+ cmQRstreaming);
        if(evtRT == 'EV_EventoFisico'){
        	cmQRstreaming = cmQRstreaming.replace('<img src="https://chart.googleapis.com/chart?chs=200x200&amp;cht=qr&amp;chl=', '');
        	cmQRstreaming = cmQRstreaming.replace('" alt=" " border="0"/>', '');
            system.debug('@@cmQRstreaming 2'+ cmQRstreaming);
        	urlQRFisico = 'https://chart.googleapis.com/chart?chs=200x200&cht=qr&chl=' + cmQRstreaming;
            system.debug('@@urlQRFisico '+ urlQRFisico);
        }

        String icsContent = 'BEGIN:VCALENDAR\n';
        icsContent += 'VERSION:2.0\n';
        icsContent += 'PRODID:-//Salesforce//Calendar//EN\n'; 
        icsContent += 'BEGIN:VEVENT\n'; 
        icsContent += 'UID:' + String.valueOf(System.currentTimeMillis()) + '\n';
        icsContent += 'DTSTAMP:' + Datetime.newInstance( evStartDate.year(),  evStartDate.month(),  evStartDate.day(),  evHoraInicio.hour(), evHoraInicio.minute(), evHoraInicio.second()).formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + '\n';
        icsContent += 'DTSTART:' + Datetime.newInstance( evStartDate.year(),  evStartDate.month(),  evStartDate.day(),  evHoraInicio.hour(), evHoraInicio.minute(), evHoraInicio.second()).formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + '\n';
        icsContent += 'DTEND:' + Datetime.newInstance( evStartDate.year(),  evStartDate.month(),  evStartDate.day(),  evHoraFin.hour(), evHoraFin.minute(), evHoraFin.second()).formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'')+ '\n'; 
        icsContent += 'SUMMARY:' + evName + '\n';
        if(evtRT == 'EV_EventoVirtual'){
          icsContent += 'DESCRIPTION:' +  evDescription + '\\n'+ '\\n' + urlQR + '\n';    
        }else{
          icsContent += 'DESCRIPTION:' +  evDescription + '\\n' + '\\n'+ urlQRFisico + '\n';   
        }
        icsContent += 'LOCATION:' + evLocation + '\n';      
        icsContent += 'END:VEVENT\n';
        icsContent += 'END:VCALENDAR'; 
        return icsContent;
        
    } 
}