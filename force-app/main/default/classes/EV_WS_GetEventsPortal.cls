/**********************************************************************************************************************
 Name:	  EV_WS_GetEventsPortal
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Web service de Portal
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0         US602112			Mamen Arias         30/06/2023          Init Version
    1.1         US714516            Mamen Arias         27/09/2023          Fix status in queries. Badly written
    1.2			US624265			Daniel Rodriguez	26/09/2023			Modify all service to add new field EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c  
***********************************************************************************************************************/
@RestResource(urlMapping='/EV_GetEventsPortal/*')
global with sharing class EV_WS_GetEventsPortal extends CBK_HttpServiceIntegration_Abstract{
    
    @HttpPost
	global static void getResultsEvents() {

		String servicio = '';
		String numperso = '';
		String idioma = '';
		List<Campaign> campaignList = new List<Campaign>();
        List<EV_CampaignWrapperDate> orderCampaignDate = new List<EV_CampaignWrapperDate>(); 
        List<EV_CampaignWrapperDateDesc> orderCampaignDateDesc = new List<EV_CampaignWrapperDateDesc>();
        List<EV_CampaignWrapperTotalAsis> orderCampaignTotalAsis = new List<EV_CampaignWrapperTotalAsis>(); 
		List<Object> listaResultados = new List<Object>();
		List<String> error = new List<String>();
        Date datePastCampaign = null;
        datePastCampaign = Date.Today().addYears(-2);
        Set<Id> campaignIds = new Set<Id>();
        Set<Id> campaignIdsLanding = new Set<Id>();
        List<EV_PortalCaixaBankTalks__c> portalList = new List<EV_PortalCaixaBankTalks__c>();
        List<EV_PortalCaixaBankTalks__c> portalListLanding = new List<EV_PortalCaixaBankTalks__c>();
        
        Datetime start = Datetime.now();
        RestRequest req = RestContext.request;
        String bodyRequest = req.requestBody.toString();
        
        RequestServicesPortalBody request = (RequestServicesPortalBody) JSON.deserialize(bodyRequest, RequestServicesPortalBody.class);
        servicio = request.servicio;
		numperso = request.numperso;
		idioma = request.idioma;
        
        RestResponse res = RestContext.response; 

		switch on servicio{

            //Slider home
			when 'slider-home-events-by-client'{
				if(String.isNotBlank(numperso) && String.isNotBlank(idioma)){
                    
                    portalList = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c='001'];
                    for (EV_PortalCaixaBankTalks__c portal : portalList){
                        campaignIds.add(portal.EV_Evento__c);
                    }
                    
                    portalListLanding = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c='008' AND EV_VisiblePortal__c = true AND EV_URLeventoCompleto__c != null];
                    for (EV_PortalCaixaBankTalks__c portal : portalListLanding){
						campaignIdsLanding.add(portal.EV_Evento__c);
                    }
                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_Provincia__c, EV_CP__c, Name, EndDate, EV_Description__c, 
                                    Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalInscritos__c, EV_Duracion__c, 
                                    EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c, EV_AforoCompleto__c, EV_HoraFin__c, 
                                    EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLImagenMedia__c, EV_URLImagenGrande__c, EV_URLImagenMovil__c,
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_URLeventoCompleto__c, EV_Espacio__c,EV_VisiblePortal__c FROM Portal_CaixaBank_Talks__r WHERE EV_Posicionamiento__c IN ('001','008')),
                                    (SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso) 
                                    FROM Campaign WHERE ID IN :campaignIds AND ID IN :campaignIdsLanding
                                    AND ID IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma)
                                    AND ID IN (SELECT CampaignId FROM CampaignMember WHERE Contact.CC_NumPerso__c = :numperso AND Status IN ('Pendiente', 'Invitacion enviada', 'Registro confirmado', 'QR enviado', 'Asistió'))
                                    AND RecordType.DeveloperName != :Label.EV_EventosAccionistas];
                    listaResultados.addAll(campaignList);
                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_Provincia__c, EV_CP__c, Name, EndDate, EV_Description__c, 
                                    Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalInscritos__c, EV_Duracion__c, 
                                    EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c, EV_AforoCompleto__c, EV_HoraFin__c, 
                                    EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLImagenMedia__c, EV_URLImagenGrande__c, EV_URLImagenMovil__c, 
                                    EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c,
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_URLeventoCompleto__c, EV_Espacio__c,EV_VisiblePortal__c FROM Portal_CaixaBank_Talks__r WHERE EV_Posicionamiento__c IN ('001','008')),
                                    (SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso) 
                                    FROM Campaign WHERE ID IN :campaignIds AND ID IN :campaignIdsLanding
                                    AND ID IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma)
                                    AND ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND EV_Status__c IN ('Pendiente', 'Invitación enviada', 'Registro confirmado', 'QR enviado', 'Asistió','Accedio a la oferta'))
                                    AND RecordType.DeveloperName != :Label.EV_EventosAccionistas];
                    listaResultados.addAll(campaignList);
                    
                	fillRestResponse(res, listaResultados, 200, req, start);

				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

            //Próximos eventos
            when 'future-events-by-client'{
				if(String.isNotBlank(numperso) && String.isNotBlank(idioma)){
                    
                    portalList = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c='002'];
                    for (EV_PortalCaixaBankTalks__c portal : portalList){
                        campaignIds.add(portal.EV_Evento__c);
                    }
                    
                    portalListLanding = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c='008' AND EV_VisiblePortal__c = true AND EV_URLeventoCompleto__c != null];
                    for (EV_PortalCaixaBankTalks__c portal : portalListLanding){
						campaignIdsLanding.add(portal.EV_Evento__c);
                    }
                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_LugarDeCelebracion__c, EV_DiaHora_evento__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_Provincia__c, EV_CP__c, Name, EndDate, EV_Description__c, 
                                    Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalInscritos__c, EV_Duracion__c, 
                                    EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c, EV_AforoCompleto__c, EV_HoraFin__c, 
                                    EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLImagenMedia__c, EV_URLImagenGrande__c, EV_URLImagenMovil__c, 
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_URLeventoCompleto__c, EV_Espacio__c,EV_VisiblePortal__c FROM Portal_CaixaBank_Talks__r WHERE EV_Posicionamiento__c IN ('002','008')),
                                    (SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso)
                                    FROM Campaign WHERE ID IN :campaignIds AND ID IN :campaignIdsLanding
                                    AND ID IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma)
                                    AND ID IN (SELECT CampaignId FROM CampaignMember WHERE Contact.CC_NumPerso__c = :numperso AND Status IN ('Pendiente', 'Invitacion enviada', 'Registro confirmado', 'QR enviado', 'Asistió'))
                                    AND RecordType.DeveloperName != :Label.EV_EventosAccionistas AND Status IN ('003', '004', '008', '009', '012')];
                    for (Campaign c : campaignList){
                        orderCampaignDate.add(new EV_CampaignWrapperDate(c));
                    }
                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_LugarDeCelebracion__c, EV_DiaHora_evento__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_Provincia__c, EV_CP__c, Name, EndDate, EV_Description__c, 
                                    Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalInscritos__c, EV_Duracion__c, 
                                    EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c, EV_AforoCompleto__c, EV_HoraFin__c, 
                                    EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLImagenMedia__c, EV_URLImagenGrande__c, EV_URLImagenMovil__c,
                                    EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c, 
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_URLeventoCompleto__c, EV_Espacio__c,EV_VisiblePortal__c FROM Portal_CaixaBank_Talks__r WHERE EV_Posicionamiento__c IN ('002','008')),
                                    (SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso)
                                    FROM Campaign WHERE ID IN :campaignIds AND ID IN :campaignIdsLanding
                                    AND ID IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma)
                                    AND ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND EV_Status__c IN ('Pendiente', 'Invitación enviada', 'Registro confirmado', 'QR enviado', 'Asistió','Accedio a la oferta'))
                                    AND RecordType.DeveloperName != :Label.EV_EventosAccionistas AND Status IN ('003', '004', '008', '009', '012')];
                    for (Campaign c : campaignList){
                        orderCampaignDate.add(new EV_CampaignWrapperDate(c));
                    }

                    orderCampaignDate.sort();
                    listaResultados.addAll(orderCampaignDate);
                    
                	fillRestResponse(res, listaResultados, 200, req, start);
                } else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

            //Últimos eventos añadidos
			when 'past-events-by-client'{
				if(String.isNotBlank(numperso) && String.isNotBlank(idioma)){
                    
                    portalList = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c='004'];
                    for (EV_PortalCaixaBankTalks__c portal : portalList){
                        campaignIds.add(portal.EV_Evento__c);
                    }
                    
                    portalListLanding = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c='008' AND EV_VisiblePortal__c = true AND EV_URLeventoCompleto__c != null];
                    for (EV_PortalCaixaBankTalks__c portal : portalListLanding){
						campaignIdsLanding.add(portal.EV_Evento__c);
                    }
                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_DiaHora_evento__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_Provincia__c, EV_CP__c, Name, EndDate, EV_Description__c, 
                                    Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalInscritos__c, EV_Duracion__c, 
                                    EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c, EV_AforoCompleto__c, EV_HoraFin__c, 
                                    EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLImagenMedia__c, EV_URLImagenGrande__c, EV_URLImagenMovil__c, 
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_URLeventoCompleto__c, EV_Espacio__c,EV_VisiblePortal__c FROM Portal_CaixaBank_Talks__r WHERE EV_Posicionamiento__c IN ('004','008')),
                                    (SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso)
                                    FROM Campaign WHERE ID IN :campaignIds AND ID IN :campaignIdsLanding
                                    AND ID IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma)
                                    AND ID IN (SELECT CampaignId FROM CampaignMember WHERE Contact.CC_NumPerso__c = :numperso AND Status = 'Asistió')
                                    AND RecordType.DeveloperName != :Label.EV_EventosAccionistas AND StartDate > :datePastCampaign];
                    for (Campaign c : campaignList){
                        orderCampaignDateDesc.add(new EV_CampaignWrapperDateDesc(c));
                    }
                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_DiaHora_evento__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_Provincia__c, EV_CP__c, Name, EndDate, EV_Description__c, 
                                    Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalInscritos__c, EV_Duracion__c, 
                                    EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c, EV_AforoCompleto__c, EV_HoraFin__c, 
                                    EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLImagenMedia__c, EV_URLImagenGrande__c, EV_URLImagenMovil__c,
                                    EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c, 
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_URLeventoCompleto__c, EV_Espacio__c,EV_VisiblePortal__c FROM Portal_CaixaBank_Talks__r WHERE EV_Posicionamiento__c IN ('004','008')),
                                    (SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso)
                                    FROM Campaign WHERE ID IN :campaignIds AND ID IN :campaignIdsLanding
                                    AND ID IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma)
                                    AND ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND (EV_Status__c = 'Asistió' OR EV_Status__c = 'Accedio a la oferta'))
                                    AND RecordType.DeveloperName != :Label.EV_EventosAccionistas AND StartDate > :datePastCampaign];
                    for (Campaign c : campaignList){
                        orderCampaignDateDesc.add(new EV_CampaignWrapperDateDesc(c));
                    }
                    
                    orderCampaignDateDesc.sort();
                    listaResultados.addAll(orderCampaignDateDesc);

					fillRestResponse(res, listaResultados, 200, req, start);

				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

            //Los más vistos
			when 'most-viewed-events-by-client'{
				if(String.isNotBlank(numperso) && String.isNotBlank(idioma)){
                    
                    portalList = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c='008' AND EV_VisiblePortal__c = true AND EV_URLeventoCompleto__c != null];
                    for (EV_PortalCaixaBankTalks__c portal : portalList){
                        campaignIds.add(portal.EV_Evento__c);
                    }
                
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Provincia__c, Name, 
                                    EndDate, EV_Description__c, Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalAsistentesC__c,
                                    EV_TotalInscritos__c ,EV_Duracion__c, EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c,
                                    EV_AforoCompleto__c, EV_HoraFin__c, EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c, EV_URLImagenGrande__c,EV_URLImagenOriginal__c, 
                                     EV_URLImagenPequena__c, EV_URLImagenMovil__c, EV_URLImagenInvitacion__c, EV_URLImagenEsperaStreaming__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_Espacio__c, EV_VisiblePortal__c, EV_Categoria__c, EV_Fechadespublicacion__c, EV_Podcast__c,
                                     EV_URLeventoCompleto__c, EV_URLresumenEvento__c FROM Portal_CaixaBank_Talks__r),
                                    (SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso)
                                    FROM Campaign WHERE (EV_TotalAsistentes__c > 0 OR EV_TotalAsistentesC__c > 0) AND Id IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma) 
                                    AND Id IN :campaignIds 
                                    AND ID IN (SELECT CampaignId FROM CampaignMember WHERE Contact.CC_NumPerso__c = :numperso AND Status = 'Asistió')
                                    AND RecordType.DeveloperName != :Label.EV_EventosAccionistas LIMIT 10];	
                    for (Campaign c : campaignList){
                        orderCampaignTotalAsis.add(new EV_CampaignWrapperTotalAsis(c));
                    }
                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Provincia__c, Name, 
                                    EndDate, EV_Description__c, Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalAsistentesC__c,
                                    EV_TotalInscritosC__c ,EV_Duracion__c, EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_aforoFisicoCompletoC__c,
                                    EV_AforoCompleto__c, EV_HoraFin__c, EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c, EV_URLImagenGrande__c,EV_URLImagenOriginal__c,
                                    EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c, 
                                     EV_URLImagenPequena__c, EV_URLImagenMovil__c, EV_URLImagenInvitacion__c, EV_URLImagenEsperaStreaming__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_Espacio__c, EV_VisiblePortal__c, EV_Categoria__c, EV_Fechadespublicacion__c, EV_Podcast__c,
                                     EV_URLeventoCompleto__c, EV_URLresumenEvento__c FROM Portal_CaixaBank_Talks__r),
                                    (SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso)
                                    FROM Campaign WHERE (EV_TotalAsistentesC__c > 0 OR EV_TotalAsistentes__c > 0) AND Id IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma) 
                                    AND Id IN :campaignIds 
                                    AND ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND (EV_Status__c = 'Asistió' OR EV_Status__c = 'Accedio a la oferta'))
                                    AND RecordType.DeveloperName != :Label.EV_EventosAccionistas LIMIT 10];	
                    for (Campaign c : campaignList){
                        orderCampaignTotalAsis.add(new EV_CampaignWrapperTotalAsis(c));
                    }
                    
                    orderCampaignTotalAsis.sort();
                    listaResultados.addAll(orderCampaignTotalAsis);

					fillRestResponse(res, listaResultados, 200, req, start);

				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}	
			}

			when else {
				error.add(Label.EV_ServiceError);
				fillRestResponse(res, error, 400, req, start);
			}
		}
    }
    
    public static void fillRestResponse(RestResponse res, List<Object> responseToShow, Integer statusCode, RestRequest req, Datetime start){
		res.addHeader('Content-Type', 'application/json');
		res.responsebody = Blob.valueOf(JSON.serialize(responseToShow));
		res.statusCode = statusCode;
        Datetime stop = Datetime.now();
        register(req, res, start, stop, '', 'EV_GetEventsPortal');
	}
	
	public class RequestServicesPortalBody{
        public String servicio;
		public String numperso;
		public String idioma;
	}
}