/**********************************************************************************************************************
 Name:	  EV_WS_InscripcionMultipleHibrido
 Copyright © 2024  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Web service EV_WS_InscripcionMultipleHibrido de Portal
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION        USER_STORY         AUTHOR              DATE         Description
 * 1.0            TechSummit         Carolina Lopez      06/06/2024   Init Version
***********************************************************************************************************************/
@RestResource(urlMapping='/EV_InscripcionMultipleHibrido/*') 
global with sharing class EV_WS_InscripcionMultipleHibrido extends CBK_HttpServiceIntegration_Abstract  {
    private static Id rtCMC = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_EventosTechSummit').getRecordTypeId();
    private static Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_LeadTechSummit').getRecordTypeId();
    @HttpPost
    global static void inscripcionPortal() {
        RestResponse res = RestContext.response;
        res.headers.put('Content-Type', 'application/json');
        RestRequest req = RestContext.request;
        String bodyRequest = req.requestBody.toString();        
        String cleanedRequestBody = bodyRequest.replaceAll('\\s', '');
        if(cleanedRequestBody.trim() == '{}'){
            res.responsebody = Blob.valueOf(Label.EV_NotBodyInscription); 
            res.statusCode = 400;
        	returnResponse(res);
        }else{        
            EV_NoClienteWrapperHibrido.RequestInscripcionBodyMultipleHibrido campBodyMul = (EV_NoClienteWrapperHibrido.RequestInscripcionBodyMultipleHibrido)JSON.deserialize(bodyRequest, EV_NoClienteWrapperHibrido.RequestInscripcionBodyMultipleHibrido.class);
            List<EV_NoClienteWrapperHibrido.LstEventFormat> lstIdEvt = campBodyMul.lstIdEvento;
            Map<String,String> mapEventFormat = new Map<String,String>();
            for (EV_NoClienteWrapperHibrido.LstEventFormat event : lstIdEvt) {
            	mapEventFormat.put(event.idEvento, event.formatoDeAsistencia);
            }            
            List<EV_NoClienteWrapperHibrido.LstEventFormat> lstIdEvtNotFound = lstIdEvt.clone();
            Map<String,String> mapNotFoundEventFormat = new Map<String,String>();
            for (EV_NoClienteWrapperHibrido.LstEventFormat event : lstIdEvtNotFound) {
            	mapNotFoundEventFormat.put(event.idEvento, event.formatoDeAsistencia);
            }            
            List<Campaign> lstCamp = new List<Campaign>();
            if(Schema.SObjectType.Campaign.isAccessible()) {
                lstCamp = [SELECT Id, Name, EV_NewArchitecture__c, EV_ExternalId__c 
                           FROM Campaign 
                           WHERE EV_ExternalId__c IN:mapEventFormat.keySet() AND EV_NewArchitecture__c = true AND EV_TechSummit__c = true AND RecordType.DeveloperName =:Label.EV_CampTechSummitHibrido];
            }
            List<EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido> lstNCW = new List<EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido>();
            Map<String,Campaign> mapcm = new Map<String,Campaign>();
            if(!lstCamp.isEmpty()) {
                for(Campaign cp : lstCamp) {
                    mapcm.put(cp.EV_ExternalId__c, cp);
                }
                for(String eventId  : mapNotFoundEventFormat.keySet()) {
                    if (mapcm.containsKey(eventId)) {
                        mapNotFoundEventFormat.remove(eventId);
                    }
               }
               if(!mapNotFoundEventFormat.isEmpty()){
                   handleCampaignError(lstNCW, new List<String>(mapNotFoundEventFormat.keySet()), '404');    
               }            
               if(campBodyMul.datosFormulario != null) {
                   if(String.isNotBlank(campBodyMul.datosFormulario.Email)) {//No clientes
                        registroNoClientes(lstNCW,campBodyMul.datosFormulario, mapcm, mapEventFormat);
                   }
               } else {
                   fillRestResponse(lstNCW, mapcm,'400');
               }
            }else{
                handleCampaignError(lstNCW, new List<String>(mapEventFormat.KeySet()), '404');
            }        
            res.responsebody = Blob.valueOf(JSON.serialize(new EV_NoClienteWrapperHibrido.ExternalMultiple(lstNCW))); 
            returnResponse(res);
        }
    }
    
    private static RestResponse returnResponse(RestResponse response) {       
        return response;        
    }
    
    private static void handleCampaignError(List<EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido> lstNCW, List<String> lstIdEvt, String fstatusCode) {
        for(String externalEv : lstIdEvt) {
            EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido responseToShow = new EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido();
            responseToShow.externalId = externalEv ;
            responseToShow.statusCode = fstatusCode;
            responseToShow.description = Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , '');
            lstNCW.add(responseToShow);
        }
    }
    
    private static void fillRestResponse(List<EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido> lstNCW, Map<String, Campaign> fmapcmName, String fstatusCode) {
        for(Campaign camp : fmapcmName.values()) {
            EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido responseToShow = new EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido();
            responseToShow.externalId = camp.EV_ExternalId__c ;
            responseToShow.statusCode = fstatusCode;
            responseToShow.description = Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , camp.Name);
            lstNCW.add(responseToShow);
        }
    }
    
    private static void handleCMDuplicate(List<EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido> lstNCW, Map<String, Campaign> fmapcmName, String fstatusCode) {
        for(Campaign camp : fmapcmName.values()) {
            EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido responseToShow = new EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido();
            responseToShow.externalId = camp.EV_ExternalId__c ;
            responseToShow.statusCode = fstatusCode;
            responseToShow.description = Label.EV_DuplicateCMEmail.replace('[Replace1]' , camp.Name);
            lstNCW.add(responseToShow);
        }
    }
    
    private static void registroNoClientes(List<EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido> lstNCW, EV_NoClienteWrapperHibrido datosFormulario, Map<String,Campaign> fmapcmName, Map<String,String> mapFormat){
        Map<String, Campaign>cmCusExternal = new Map<String, Campaign>();
        List<EV_CampaignMemberC__c> listCampMemberCustom = new List<EV_CampaignMemberC__c>();
        //Validar si un usuario ya se ha inscrito al evento a partir del email. (campo 'email' no puede ser filtrado)
        if(Schema.SObjectType.EV_CampaignMemberC__c.isAccessible()) {
            listCampMemberCustom = [SELECT Id, EV_Status__c, EV_CampaignId__r.EV_ExternalId__c, EV_CampaignId__c, EV_CampaignId__r.Name, EV_NumeroDocumento__c, EV_ExternalId__c, EV_Email__c
                                    FROM EV_CampaignMemberC__c 
                                    WHERE EV_CampaignId__r.EV_ExternalId__c IN:fmapcmName.keySet() 
                                    AND EV_LeadId__c != null 
                                    AND EV_LeadId__r.RecordType.DeveloperName ='EV_LeadTechSummit'
                                    AND EV_LeadId__r.Email =:datosFormulario.Email
                                    AND RecordtypeId =:rtCMC
                                    AND EV_Status__c != 'Baja del evento'
                                    LIMIT 50000]; 
        }
        if(!listCampMemberCustom.isEmpty()) {
            for(EV_CampaignMemberC__c arch : listCampMemberCustom) {
                cmCusExternal.put(arch.EV_CampaignId__r.EV_ExternalId__c, arch.EV_CampaignId__r);
                fmapcmName.remove(arch.EV_CampaignId__r.EV_ExternalId__c);
            }
            handleCMDuplicate(lstNCW, cmCusExternal, '202');
        }
        List<EV_CampaignMemberC__c> lstMiembroInterlocutorCustom = new List<EV_CampaignMemberC__c>();
        if(!fmapcmName.isEmpty()) {
            List<Lead> lstInterlocutores = new List<Lead>();
            for(Campaign externalCamp : fmapcmName.values()){
                lstInterlocutores.add(new Lead(
                    FirstName = datosFormulario.Nombre,
                    LastName = datosFormulario.Apellidos,
                    Phone = datosFormulario.Phone,
                    EV_Idiomas__c = datosFormulario.Idioma,
					EV_CampaignId__c = externalCamp.Id,
                    EV_Cargo__c = datosFormulario.Cargo,
                    EV_ConsentimientoGeneral__c = datosFormulario.ConsentimientoGeneral,
                    RecordtypeId = rtLeadEvento,
                    Email = datosFormulario.Email,
                    EV_ConsentimientoTerceros__c = (datosFormulario.ConsentimientoTerceros!=null ? datosFormulario.ConsentimientoTerceros : false),
                    EV_Marketing__c = (datosFormulario.Marketing!=null ? datosFormulario.Marketing : false)
                ));
            }
            Database.SaveResult[] resultLead = Database.insert(lstInterlocutores);
            Map<String, String> msjs = new Map<String, String>();
            List<Campaign> lstCm = new List<Campaign>();
            for(Integer i = 0; i < fmapcmName.values().size(); i++){
                if(resultLead[i].isSuccess()){
                    String xFormatAux;
                    if(mapFormat.containsKey(fmapcmName.values().get(i).EV_ExternalId__c)){
                        xFormatAux = mapFormat.get(fmapcmName.values().get(i).EV_ExternalId__c);
                    }                    
                    lstMiembroInterlocutorCustom.add(new EV_CampaignMemberC__c(
                        EV_CampaignId__c = fmapcmName.values().get(i).Id,
                        EV_Status__c = Label.EV_RecordConformed,
                        EV_CanalOrigen__c = (String.isNotEmpty(datosFormulario.NIFEmpresa) ? '002' : '003'),
                        EV_FormatoDeAsistencias__c = xFormatAux,
                        RecordtypeId = rtCMC,
                        EV_LeadId__c = resultLead[i].getId()));
                    
                    lstCm.add(fmapcmName.values().get(i));
                }
                if(!resultLead[i].isSuccess()) {
                    EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido recordResponse = new EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido();
                    recordResponse.externalId = fmapcmName.values().get(i).EV_ExternalId__c;
                    recordResponse.statusCode = '500';
                    recordResponse.description = Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , fmapcmName.values().get(i).Name);                    
                    lstNCW.add(recordResponse);
                    
                    msjs.put(recordResponse.statusCode, resultLead[i].getErrors()[0].getMessage());
                }
            }
            if(!msjs.isEmpty()){
                CBK_Log.error(msjs);
            }
            Database.SaveResult[] result = Database.insert(lstMiembroInterlocutorCustom, false);
            Map<String, String> msjsCM = new Map<String, String>();
            for(Integer i = 0; i < lstCm.size(); i++){
                if(result[i].isSuccess()){
                    EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido recordResponse = new EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido();
                    recordResponse.externalId = lstCm.get(i).EV_ExternalId__c;
                    recordResponse.statusCode = '200';
                    recordResponse.description = Label.EV_EventInscriptionCompleted.replace('[Replace1]', lstCm.get(i).Name);
                    lstNCW.add(recordResponse);
                }	
                if(!result[i].isSuccess()) {
                    EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido recordResponse = new EV_NoClienteWrapperHibrido.CampaignMemberResponseMultiHibrido();
                    recordResponse.externalId = lstCm.get(i).EV_ExternalId__c;
                    recordResponse.statusCode = '500';
                    recordResponse.description = Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , lstCm.get(i).Name);
                    lstNCW.add(recordResponse);                    
                    msjsCM.put(recordResponse.statusCode, result[i].getErrors()[0].getMessage());
                }
            }
            if(!msjsCM.isEmpty()){                
                CBK_Log.error(msjsCM);                
            }
        } else {
            List<String> externalEvList = new List<String>();
            externalEvList.addAll(fmapcmName.keySet());
            handleCampaignError(lstNCW, externalEvList, '404'); 
        }
    }  
}