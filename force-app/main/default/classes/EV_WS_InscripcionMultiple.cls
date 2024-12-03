/**********************************************************************************************************************
 Name:	  EV_WS_InscripcionMultiple
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Web service EV_WS_InscripcionMultiple de Portal
---------------------------------------------------------------------------------------------------------------------- 
 * VERSION        USER_STORY         AUTHOR              DATE         Description
 * 1.0            US622078           Carolina Lopez      01/06/2023   Init Version
 * 1.1            US661500           Carolina Lopez      25/07/2023   Modify Campaign member / lead creation logic with old RT.
 * 1.2			  US680535			 Daniel Rodriguez	 31/07/2023	  Modify creation lead, addition campaignId related with lead and remove search Account related with record
 * 1.3            US680535           Mamen Arias         10/08/2023   Add method handleCMDuplicate() for controle response duplicated emails in CMs
 * 1.4			  US680535			 Daniel Rodriguez 	 17/08/2023   Add check body null
 * 1.5			  US680535			 Carolina Lopez 	 18/08/2023   Modify error code of duplicate elements 204 by 202
 * 1.6								 Mamen Arias		 21/02/2024	  Add extends CBK_HttpServiceIntegration_Abstract
 * 1.7            TechSummit         Carolina Lopez      14/05/2024   Modify the logic include the new Recordtypes TechSummit.
***********************************************************************************************************************/
@RestResource(urlMapping='/EV_InscripcionMultiple/*') 
global with sharing class EV_WS_InscripcionMultiple extends CBK_HttpServiceIntegration_Abstract {
    private static Id rtCMC = Schema.SObjectType.EV_CampaignMemberC__c.getRecordTypeInfosByDeveloperName().get('EV_EventosTechSummit').getRecordTypeId();
    private static Id rtLeadEvento = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('EV_LeadTechSummit').getRecordTypeId();
    private static Id rtAccEmpresa = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

    
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
        EV_NoClienteWrapper.RequestInscripcionBodyMultiple campBodyMul = (EV_NoClienteWrapper.RequestInscripcionBodyMultiple) JSON.deserialize(bodyRequest, EV_NoClienteWrapper.RequestInscripcionBodyMultiple.class);
        List<String> lstIdEvt = campBodyMul.lstIdEvento;
        List<String> lstIdEvtNotFound = lstIdEvt.clone();
        
        List<Campaign> lstCamp = new List<Campaign>();
        if(Campaign.SObjectType.getDescribe().isAccessible()) {
            lstCamp = [SELECT Id, Name, EV_NewArchitecture__c, EV_ExternalId__c FROM Campaign WHERE EV_ExternalId__c IN:lstIdEvt AND EV_NewArchitecture__c = true AND EV_TechSummit__c = true];
        }
        
        List<EV_NoClienteWrapper.CampaignMemberResponseMulti> lstNCW = new List<EV_NoClienteWrapper.CampaignMemberResponseMulti>();
        Map<String,Campaign> mapcm = new Map<String,Campaign>();
        
        if(!lstCamp.isEmpty()) {
            for(Campaign cp : lstCamp) {
                mapcm.put(cp.EV_ExternalId__c,cp);
                if(lstIdEvtNotFound.contains(cp.EV_ExternalId__c)){
                    lstIdEvtNotFound.remove(lstIdEvtNotFound.indexOf(cp.EV_ExternalId__c));
                }
            }
            
            if(!lstIdEvtNotFound.isEmpty()){
                handleCampaignError(lstNCW, lstIdEvtNotFound, '404');    
            }            
            
            if(campBodyMul.datosFormulario != null) {
                if(String.isNotBlank(campBodyMul.IdInvitacion)) {
                    List<EV_CampaignMemberC__c> lstCampMemberCt = new List<EV_CampaignMemberC__c>();
                    if(EV_CampaignMemberC__c.SObjectType.getDescribe().isAccessible()) {
                        lstCampMemberCt = [SELECT Id, EV_ExternalId__c, EV_AccountId__c, EV_Empresa__c, EV_NumeroDocumento__c FROM EV_CampaignMemberC__c WHERE EV_ExternalId__c = :campBodyMul.IdInvitacion LIMIT 1];
                    }
                    
                    if(!lstCampMemberCt.isEmpty()) { //Registrar cliente dado que tiene invitacion en nueva arquitectura
                        if(lstCampMemberCt.get(0).EV_Empresa__c && String.isNotBlank(lstCampMemberCt.get(0).EV_NumeroDocumento__c)) {
                            campBodyMul.datosFormulario.NIFEmpresa = lstCampMemberCt.get(0).EV_NumeroDocumento__c;
                            registroNoClientes(lstNCW, campBodyMul.datosFormulario, lstCampMemberCt.get(0).EV_AccountId__c,mapcm);
                        }else {
                            registroClientes(lstNCW, String.valueOf(lstCampMemberCt.get(0).Id), campBodyMul.datosFormulario.FormatoDeAsistencia, mapcm);
                        }						  
                    } else {
                        handleCampaignError(lstNCW, lstIdEvt, '404');    
                    }
                } else { //No clientes
                    if(String.isNotBlank(campBodyMul.datosFormulario.Email)) {
                        registroNoClientes(lstNCW,campBodyMul.datosFormulario, null, mapcm);
                    }
                }
            } else {
                fillRestResponse(lstNCW, mapcm,'400');
            }
        }else{
            handleCampaignError(lstNCW, lstIdEvt, '404');
        }        
        res.responsebody = Blob.valueOf(JSON.serialize(new EV_NoClienteWrapper.ExternalMultiple(lstNCW))); 
        returnResponse(res);
    }
    }
    
    private static RestResponse returnResponse(RestResponse response) {       
        return response;        
    }
    
    private static void handleCampaignError(List<EV_NoClienteWrapper.CampaignMemberResponseMulti> lstNCW, List<String> lstIdEvt, String fstatusCode) {
        for(String externalEv : lstIdEvt) {
            EV_NoClienteWrapper.CampaignMemberResponseMulti responseToShow = new EV_NoClienteWrapper.CampaignMemberResponseMulti();
            responseToShow.externalId = externalEv ;
            responseToShow.statusCode = fstatusCode;
            responseToShow.description = Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , '');
            lstNCW.add(responseToShow);
        }
    }
    
    private static void fillRestResponse(List<EV_NoClienteWrapper.CampaignMemberResponseMulti> lstNCW, Map<String, Campaign> fmapcmName, String fstatusCode) {
        for(Campaign camp : fmapcmName.values()) {
            EV_NoClienteWrapper.CampaignMemberResponseMulti responseToShow = new EV_NoClienteWrapper.CampaignMemberResponseMulti();
            responseToShow.externalId = camp.EV_ExternalId__c ;
            responseToShow.statusCode = fstatusCode;
            responseToShow.description = Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , camp.Name);
            lstNCW.add(responseToShow);
        }
    }
    
    private static void handleCMDuplicate(List<EV_NoClienteWrapper.CampaignMemberResponseMulti> lstNCW, Map<String, Campaign> fmapcmName, String fstatusCode) {
        for(Campaign camp : fmapcmName.values()) {
            EV_NoClienteWrapper.CampaignMemberResponseMulti responseToShow = new EV_NoClienteWrapper.CampaignMemberResponseMulti();
            responseToShow.externalId = camp.EV_ExternalId__c ;
            responseToShow.statusCode = fstatusCode;
            responseToShow.description = Label.EV_DuplicateCMEmail.replace('[Replace1]' , camp.Name);
            lstNCW.add(responseToShow);
        }
    }
    
    
    private static void registroClientes(List<EV_NoClienteWrapper.CampaignMemberResponseMulti> lstNCW, String idInvitacion, String formatoDeAsistencia, Map<String,Campaign> fmapcm){
        list<EV_CampaignMemberC__c> lstCampActualizarC = new list<EV_CampaignMemberC__c>();
        if(EV_CampaignMemberC__c.SObjectType.getDescribe().isAccessible()) {
            lstCampActualizarC = [SELECT Id, EV_Status__c, EV_ExternalId__c, EV_CampaignId__r.Name, EV_CampaignId__r.EV_ExternalId__c, EV_CampaignId__c,  EV_FormatoDeAsistencias__c FROM EV_CampaignMemberC__c WHERE Id = :IdInvitacion];
        }
        Map<String,Campaign> mapStatus = new Map<String,Campaign>();
        Map<String,Campaign> mapRemov = fmapcm.clone();
        List<EV_CampaignMemberC__c> lstCCusUpdate = new List<EV_CampaignMemberC__c>();
        
        if(!lstCampActualizarC.isEmpty()){
            for(EV_CampaignMemberC__c cCus :lstCampActualizarC){
                if(fmapcm.keySet().contains(cCus.EV_CampaignId__r.EV_ExternalId__c)){
                    mapRemov.remove(cCus.EV_CampaignId__r.EV_ExternalId__c);
                }
                if(cCus.EV_Status__c == Label.EV_RecordConformed || cCus.EV_Status__c == Label.EV_QRSend){
                    mapStatus.put(cCus.EV_CampaignId__r.EV_ExternalId__c, cCus.EV_CampaignId__r);
                }else{
                    cCus.EV_Status__c = Label.EV_RecordConformed;
                    cCus.EV_FormatoDeAsistencias__c = formatoDeAsistencia;
                    lstCCusUpdate.add(cCus);
                }
            }
            
            if(!mapRemov.isEmpty()){
                fillRestResponse(lstNCW, mapRemov, '404');
            }
            if(!mapStatus.isEmpty()){
                fillRestResponse(lstNCW, mapStatus, '412');
            }
            if(!lstCCusUpdate.isEmpty()){
                Database.SaveResult[] resultCampMem = Database.update(lstCCusUpdate, false);
                Map<String, String> msjsCM = new Map<String, String>();
                for(Integer i = 0; i < lstCCusUpdate.size(); i++){
                    if(resultCampMem[i].isSuccess()){
                        EV_NoClienteWrapper.CampaignMemberResponseMulti recordResponse = new EV_NoClienteWrapper.CampaignMemberResponseMulti();
                        recordResponse.externalId = lstCCusUpdate.get(i).EV_CampaignId__r.EV_ExternalId__c;
                        recordResponse.statusCode = '200';
                        recordResponse.description = Label.EV_EventInscriptionCompleted.replace('[Replace1]', lstCCusUpdate.get(i).EV_CampaignId__r.Name);
                        lstNCW.add(recordResponse);
                    }	
                    if(!resultCampMem[i].isSuccess()) {
                        EV_NoClienteWrapper.CampaignMemberResponseMulti recordResponse = new EV_NoClienteWrapper.CampaignMemberResponseMulti();
                        recordResponse.externalId = lstCCusUpdate.get(i).EV_CampaignId__r.EV_ExternalId__c;
                        recordResponse.statusCode = '500';
                        recordResponse.description = Label.EV_EventInscriptionNotCompleted.replace('[Replace1]' , lstCCusUpdate.get(i).EV_CampaignId__r.Name);
                        lstNCW.add(recordResponse);
                        msjsCM.put(recordResponse.statusCode, resultCampMem[i].getErrors()[0].getMessage());
                    }
                }
                if(!msjsCM.isEmpty()){                    
                    CBK_Log.error(msjsCM);                    
                }
            }
        }else{
            List<String> externalEvList = new List<String>();
            externalEvList.addAll(fmapcm.keySet());
            handleCampaignError(lstNCW, externalEvList, '404');
        }
        
    }
    
    private static void registroNoClientes(List<EV_NoClienteWrapper.CampaignMemberResponseMulti> lstNCW, EV_NoClienteWrapper datosFormulario, String accId, Map<String,Campaign> fmapcmName){
        Map<String, Campaign>cmCusExternal = new Map<String, Campaign>();
        List<EV_CampaignMemberC__c> listCampMemberCustom = new List<EV_CampaignMemberC__c>();
        //Validar si un usuario ya se ha inscrito al evento a partir del email. (campo 'email' no puede ser filtrado)
        if(EV_CampaignMemberC__c.SObjectType.getDescribe().isAccessible()) {
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
                    lstMiembroInterlocutorCustom.add(new EV_CampaignMemberC__c(
                        EV_CampaignId__c = fmapcmName.values().get(i).Id,
                        EV_Status__c = Label.EV_RecordConformed,
                        EV_CanalOrigen__c = (String.isNotEmpty(datosFormulario.NIFEmpresa) ? '002' : '003'),
                        EV_FormatoDeAsistencias__c = datosFormulario.FormatoDeAsistencia,
                        RecordtypeId = rtCMC,
                        EV_LeadId__c = resultLead[i].getId()));
                    
                    lstCm.add(fmapcmName.values().get(i));
                }
                if(!resultLead[i].isSuccess()) {
                    EV_NoClienteWrapper.CampaignMemberResponseMulti recordResponse = new EV_NoClienteWrapper.CampaignMemberResponseMulti();
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
                    EV_NoClienteWrapper.CampaignMemberResponseMulti recordResponse = new EV_NoClienteWrapper.CampaignMemberResponseMulti();
                    recordResponse.externalId = lstCm.get(i).EV_ExternalId__c;
                    recordResponse.statusCode = '200';
                    recordResponse.description = Label.EV_EventInscriptionCompleted.replace('[Replace1]', lstCm.get(i).Name);
                    lstNCW.add(recordResponse);
                }	
                if(!result[i].isSuccess()) {
                    EV_NoClienteWrapper.CampaignMemberResponseMulti recordResponse = new EV_NoClienteWrapper.CampaignMemberResponseMulti();
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