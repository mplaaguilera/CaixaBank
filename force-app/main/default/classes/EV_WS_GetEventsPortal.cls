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
    1.3         US306439            Carolina Lopez      17/11/2023          Modify custom CampaignMember service to add new field EV_URLVolverEvento__c, value 'Asistió en diferido' in EV_Status__c, modify RequestServicesPortalBody and Add service 'attended-deferred-basis'.
    1.4         US796398            Daniel Rodriguez    02/01/2024          Add field EV_URLLogoPie__c.
    1.5         US796398-adHoc      Carolina Lopez      16/01/2024          Add field EV_TextoLegal__c.
    1.6         US854993            Carolina Lopez      04/04/2024          Modified the portal visibility filter throughout the service.
    1.6         FIX             	Carolina Lopez      07/05/2024          Delete WITH SECURITY_ENFORCED.
    1.7         TechSummit          Carolina Lopez      05/06/2024          Add method generateICSFile, service 'events-summary' and modify RequestServicesPortalBody.
    1.8         TechSummit          Carolina Lopez      04/09/2024          Modify the query to limit the states.
    1.9         TechSummit          Carolina Lopez      06/09/2024          Modify query of service 'events-summary' for the 'Regitro confirmado' and 'QR enviado' statuses, sort by EV_DiaHoraInicio_c.
    ***********************************************************************************************************************/
@RestResource(urlMapping='/EV_GetEventsPortal/*')
global with sharing class EV_WS_GetEventsPortal extends CBK_HttpServiceIntegration_Abstract{
    private static final String LANG_CODE_CA  = '001';
	private static final String LANG_CODE_ES  = '002';

    @HttpPost
	global static void getResultsEvents() { 

		String servicio = '';
		String numperso = '';
		String idioma = '';
        String externalIdCM = '';
        String email = '';
        List<EV_CampaignMemberC__c> campaignMemberListCustom = new List<EV_CampaignMemberC__c>();
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
        Map<Id,Map<String,EV_TraduccionDeEvento__c>> eventoTraduccionesMap = new Map<Id,Map<String,EV_TraduccionDeEvento__c>>();
        
        Datetime start = Datetime.now();
        RestRequest req = RestContext.request;
        String bodyRequest = req.requestBody.toString();
        
        RequestServicesPortalBody request = (RequestServicesPortalBody) JSON.deserialize(bodyRequest, RequestServicesPortalBody.class);
        servicio = request.servicio;
		numperso = request.numperso;
		idioma = request.idioma;
        externalIdCM = request.externalIdCM;
        email = request.email;
        
        RestResponse res = RestContext.response; 

		switch on servicio{

            //Slider home
			when 'slider-home-events-by-client'{
				if(String.isNotBlank(numperso) && String.isNotBlank(idioma)){

                    portalList = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE EV_Posicionamiento__c='001'];
                    for (EV_PortalCaixaBankTalks__c portal : portalList){
                        campaignIds.add(portal.EV_Evento__c);
                    }
                    portalListLanding = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE ((EV_Posicionamiento__c='008')  OR
                    ((EV_Posicionamiento__c!='008' AND (EV_VisiblePortal__c = true OR EV_VisibleFormula__c = true)))) AND EV_URLeventoCompleto__c != null];
                    for (EV_PortalCaixaBankTalks__c portal : portalListLanding){
                        campaignIdsLanding.add(portal.EV_Evento__c);
                    }
                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_Provincia__c, EV_CP__c, Name, EndDate, EV_Description__c, 
                                    Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalInscritos__c, EV_Duracion__c, 
                                    EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c, EV_AforoCompleto__c, EV_HoraFin__c, 
                                    EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLImagenMedia__c, EV_URLImagenGrande__c, EV_URLImagenMovil__c,
                                    EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c, EV_URLLogoPie__c, EV_TextoLegal__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
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
                                    EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c, EV_URLLogoPie__c, EV_TextoLegal__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_URLeventoCompleto__c, EV_Espacio__c,EV_VisiblePortal__c FROM Portal_CaixaBank_Talks__r WHERE EV_Posicionamiento__c IN ('001','008')),
                                    (SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso) 
                                    FROM Campaign WHERE ID IN :campaignIds AND ID IN :campaignIdsLanding
                                    AND ID IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma)
                                    AND ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND EV_Status__c IN ('Pendiente', 'Invitación enviada', 'Registro confirmado', 'QR enviado', 'Asistió','Accedio a la oferta', 'Asistió en diferido'))
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
                    portalListLanding = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE ((EV_Posicionamiento__c='008')  OR
                    ((EV_Posicionamiento__c!='008' AND (EV_VisiblePortal__c = true OR EV_VisibleFormula__c = true)))) AND EV_URLeventoCompleto__c != null];
                    for (EV_PortalCaixaBankTalks__c portal : portalListLanding){
						campaignIdsLanding.add(portal.EV_Evento__c);
                    }


                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_LugarDeCelebracion__c, EV_DiaHora_evento__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_Provincia__c, EV_CP__c, Name, EndDate, EV_Description__c, 
                                    Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalInscritos__c, EV_Duracion__c, 
                                    EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c, EV_AforoCompleto__c, EV_HoraFin__c, 
                                    EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLImagenMedia__c, EV_URLImagenGrande__c, EV_URLImagenMovil__c, 
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c, EV_URLLogoPie__c, EV_TextoLegal__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
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
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c, EV_URLLogoPie__c, EV_TextoLegal__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_URLeventoCompleto__c, EV_Espacio__c,EV_VisiblePortal__c FROM Portal_CaixaBank_Talks__r WHERE EV_Posicionamiento__c IN ('002','008')),
                                    (SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso)
                                    FROM Campaign WHERE ID IN :campaignIds AND ID IN :campaignIdsLanding
                                    AND ID IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma)
                                    AND ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND EV_Status__c IN ('Pendiente', 'Invitación enviada', 'Registro confirmado', 'QR enviado', 'Asistió','Accedio a la oferta', 'Asistió en diferido'))
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
                    portalListLanding = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE ((EV_Posicionamiento__c='008')  OR
                    ((EV_Posicionamiento__c!='008' AND (EV_VisiblePortal__c = true OR EV_VisibleFormula__c = true)))) AND EV_URLeventoCompleto__c != null];
                    for (EV_PortalCaixaBankTalks__c portal : portalListLanding){
						campaignIdsLanding.add(portal.EV_Evento__c);
                    }
                    
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_DiaHora_evento__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_Provincia__c, EV_CP__c, Name, EndDate, EV_Description__c, 
                                    Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalInscritos__c, EV_Duracion__c, 
                                    EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c, EV_AforoCompleto__c, EV_HoraFin__c, 
                                    EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLImagenMedia__c, EV_URLImagenGrande__c, EV_URLImagenMovil__c, 
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c, EV_URLLogoPie__c, EV_TextoLegal__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
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
                                     EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c, EV_URLLogoPie__c, EV_TextoLegal__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_URLeventoCompleto__c, EV_Espacio__c,EV_VisiblePortal__c FROM Portal_CaixaBank_Talks__r WHERE EV_Posicionamiento__c IN ('004','008')),
                                    (SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso)
                                    FROM Campaign WHERE ID IN :campaignIds AND ID IN :campaignIdsLanding
                                    AND ID IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma)
                                    AND ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND (EV_Status__c = 'Asistió' OR EV_Status__c = 'Accedio a la oferta' OR EV_Status__c = 'Asistió en diferido'))
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
                    portalList = [SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE ((EV_Posicionamiento__c='008')  OR
                    ((EV_Posicionamiento__c!='008' AND (EV_VisiblePortal__c = true OR EV_VisibleFormula__c = true)))) AND EV_URLeventoCompleto__c != null];
                    for (EV_PortalCaixaBankTalks__c portal : portalList){
                        campaignIds.add(portal.EV_Evento__c);
                    }
                
                    campaignList = [SELECT StartDate, EV_NewArchitecture__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Provincia__c, Name, 
                                    EndDate, EV_Description__c, Id, EV_ProgramaDeEventos__c, EV_URLChatVirtual__c, EV_URLDelEventoVirtual__c, EV_Categoria__c, EV_TotalAsistentes__c, EV_TotalAsistentesC__c,
                                    EV_TotalInscritos__c ,EV_Duracion__c, EV_URLImagenVideo__c, EV_NombrePonente__c, EV_EventoPrivado__c, RecordType.DeveloperName, EV_AforoFisicoCompleto__c,
                                    EV_AforoCompleto__c, EV_HoraFin__c, EV_HoraInicio__c, Status, EV_ExternalID__c, EV_URLRegistro__c, 
                                    (SELECT Name, EV_Descripcion__c, EV_Claim__c, EV_URLDeImagen__c, EV_URLVideoTeaser__c, EV_URLImagenCarrusel__c, EV_URLImagenGrande__c,EV_URLImagenOriginal__c, 
                                     EV_URLImagenPequena__c, EV_URLImagenMovil__c, EV_URLImagenInvitacion__c, EV_URLImagenEsperaStreaming__c, EV_URLLogoPie__c, EV_TextoLegal__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
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
                                     EV_URLImagenPequena__c, EV_URLImagenMovil__c, EV_URLImagenInvitacion__c, EV_URLImagenEsperaStreaming__c, EV_URLLogoPie__c, EV_TextoLegal__c FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c = :idioma), 
                                    (SELECT EV_Posicionamiento__c, EV_Orden__c, EV_Palabras__c, EV_Espacio__c, EV_VisiblePortal__c, EV_Categoria__c, EV_Fechadespublicacion__c, EV_Podcast__c,
                                     EV_URLeventoCompleto__c, EV_URLresumenEvento__c FROM Portal_CaixaBank_Talks__r),
                                    (SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso)
                                    FROM Campaign WHERE (EV_TotalAsistentesC__c > 0 OR EV_TotalAsistentes__c > 0) AND Id IN (SELECT EV_Evento__c FROM EV_TraduccionDeEvento__c WHERE EV_Idioma__c = :idioma) 
                                    AND Id IN :campaignIds 
                                    AND ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND (EV_Status__c = 'Asistió' OR EV_Status__c = 'Accedio a la oferta' OR EV_Status__c = 'Asistió en diferido'))
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

            when 'attended-deferred-basis' {
				if (String.isNotBlank(externalIdCM)){

                    campaignMemberListCustom = [SELECT Id, EV_Status__c FROM EV_CampaignMemberC__c WHERE EV_ExternalID__c= :externalIdCM];
					
					if (!campaignMemberListCustom.isEmpty()){
						if(campaignMemberListCustom[0].EV_Status__c != 'Asistió'){
							EV_CampaignMemberC__c cmCustom = new EV_CampaignMemberC__c();
							cmCustom.Id = campaignMemberListCustom[0].Id;
							cmCustom.EV_Status__c = 'Asistió en diferido';

							Database.SaveResult resultAD = Database.update(cmCustom, false);
							if (resultAD.isSuccess()){
								listaResultados.add(resultAD);
								fillRestResponse(res, listaResultados, 200, req, start);
							}else {
								listaResultados.add(resultAD);
								fillRestResponse(res, listaResultados, 400, req, start);
							}
						}else{
							listaResultados.add(Label.EV_DeferredBasis);
							fillRestResponse(res, listaResultados, 400, req, start);
						}
					} 
                    if (campaignMemberListCustom.isEmpty()) {
                        listaResultados.add(Label.EV_CMNotFound);
                        fillRestResponse(res, listaResultados, 400, req, start);
                    }
				}else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

            when 'events-summary' {
				if (String.isNotBlank(email)){
                    campaignMemberListCustom = [SELECT Id, EV_FormatoDeAsistencias__c, EV_CampaignId__r.EV_DiaHoraInicio__c,  EV_CampaignId__r.EV_ExternalID__c, EV_Idioma__c, EV_CampaignId__c, EV_CampaignId__r.Name, EV_CampaignId__r.StartDate, EV_CampaignId__r.EV_Idioma__c, EV_LeadId__r.Email,  EV_LeadId__r.FirstName, EV_LeadId__r.LastName, EV_LeadId__r.Phone, EV_ExternalID__c, EV_Status__c, EV_CampaignId__r.RecordType.DeveloperName, EV_CampaignId__r.RecordTypeId, RecordTypeId, RecordType.DeveloperName, EV_CampaignId__r.EV_City__c, EV_CampaignId__r.EV_CP__c, EV_CampaignId__r.EV_Street__c, EV_CampaignId__r.EV_LugarDeCelebracion__c, EV_CampaignId__r.EV_Duracion__c, EV_CampaignId__r.EV_Description__c,EV_CampaignId__r.EV_HoraFin__c,  EV_CampaignId__r.EV_HoraInicio__c, EV_FirstName__c, EV_LastName__c,EV_CampaignId__r.EV_URLDelEventoVirtual__c, EV_CodigoQR__c, EV_URLStreamingEvento__c, EV_LeadId__c 
                    FROM EV_CampaignMemberC__c WHERE EV_LeadId__r.Email =: email AND (EV_Status__c = 'Registro confirmado' OR EV_Status__c = 'QR enviado') AND (EV_CampaignId__r.RecordType.DeveloperName =: Label.EV_CampTechSummitFisico OR EV_CampaignId__r.RecordType.DeveloperName =: Label.EV_CampTechSummitVirtual OR EV_CampaignId__r.RecordType.DeveloperName =: Label.EV_CampTechSummitHibrido) ORDER BY EV_CampaignId__r.EV_DiaHoraInicio__c asc];
                    
					if (!campaignMemberListCustom.isEmpty()){
				        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
                        Map<String, EmailTemplate> emailTemplatesMap = new Map<String, EmailTemplate>();

                        Map<Integer, String> monthNamesSpanish = new Map<Integer, String>{
                        1 => 'Enero', 2 => 'Febrero', 3 => 'Marzo', 4 => 'Abril', 
                        5 => 'Mayo', 6 => 'Junio', 7 => 'Julio', 8 => 'Agosto', 
                        9 => 'Septiembre', 10 => 'Octubre', 11 => 'Noviembre', 12 => 'Diciembre'
                        };
                        Map<Integer, String> monthNamesCatalan = new Map<Integer, String>{
                        1 => 'Gener', 2 => 'Febrer', 3 => 'Març', 4 => 'Abril', 
                        5 => 'Maig', 6 => 'Juny', 7 => 'Juliol', 8 => 'Agost', 
                        9 => 'Setembre', 10 => 'Octubre', 11 => 'Novembre', 12 => 'Desembre'
                        };
		
                        List<EmailTemplate> emailTemplateOficina = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body, Name FROM EmailTemplate WHERE Name in ('EmailTemplateTechSummitES','EmailTemplateTechSummitCA') limit 2];
                        for (EmailTemplate template : emailTemplateOficina) {
                            emailTemplatesMap.put(template.Name, template);
                        }

                        List<OrgWideEmailAddress> orgwideaddress = [SELECT Id, Address FROM OrgWideEmailAddress where Address = 'invitation@event.caixabank.com' LIMIT 1];

                        for (EV_CampaignMemberC__c cm : campaignMemberListCustom) {
                            campaignIds.add(cm.EV_CampaignId__c);
                        }
                        eventoTraduccionesMap = EV_Utilities.getEventoTraducciones(campaignIds);

                        String html;
                        String asunto;
                        String emailTemplateId;
                        String finalHtml = '';
                        string eventName;
                        string eventDescription;
                        Integer startIdx;
                        Integer endIdx;

                        //Nos quedamos con la plantilla inicial genérica en Castellano hasta un siguiente "MVP" en el que podamos obtener como parámetro el idioma del Portal.
                        html = emailTemplatesMap.get('EmailTemplateTechSummitES').HtmlValue;
                        html = html.replace('Hola', 'Hola ' + Label.EV_RecordatorioTemplateES);
                        asunto = Label.EV_SubjectTechES;
                        emailTemplateId = emailTemplatesMap.get('EmailTemplateTechSummitES').Id;
                                
                        for(EV_CampaignMemberC__c cmc: campaignMemberListCustom){
                            Datetime fecha = datetime.newInstance(cmc.EV_CampaignId__r.StartDate.year(), cmc.EV_CampaignId__r.StartDate.month(), cmc.EV_CampaignId__r.StartDate.day());
                            String hora = String.valueof(cmc.EV_CampaignId__r.EV_HoraInicio__c);
                            
                            String sectionToDuplicate = '';
                            startIdx = html.indexOf('[[BEGINMEMBER]]');
                            endIdx = html.indexOf('[[ENDMEMBER]]');
                            if (startIdx != -1 && endIdx != -1) {
                                sectionToDuplicate = html.substring(startIdx + 19, endIdx);
                            }

                            if(cmc.EV_Idioma__c == 'Castellano') {
                                eventName = eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_ES) == null ? cmc.EV_CampaignId__r.Name : eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_ES).Name;
                                eventDescription = eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_ES) == null ? cmc.EV_CampaignId__r.EV_Description__c : eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_ES).EV_Descripcion__c;
                            } else {
                                eventName = eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_CA) == null ? cmc.EV_CampaignId__r.Name : eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_CA).Name;
                                eventDescription = eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_CA) == null ? cmc.EV_CampaignId__r.EV_Description__c : eventoTraduccionesMap.get(cmc.EV_CampaignId__c).get(LANG_CODE_CA).EV_Descripcion__c;
                            }

                            String memberHtml = sectionToDuplicate;
                            memberHtml = memberHtml.replace('[DATESTART]', String.valueOf(cmc.EV_CampaignId__r.StartDate.day()));
                            memberHtml = memberHtml.replace('[MONTHSTART]', (cmc.EV_Idioma__c == 'Castellano' ? String.valueOf(monthNamesSpanish.get(fecha.month())) : String.valueOf(monthNamesCatalan.get(fecha.month()))));
                            memberHtml = memberHtml.replace('[ExternalIdEvento]', String.valueOf(cmc.EV_CampaignId__r.EV_ExternalID__c));
                            memberHtml = memberHtml.replace('[ExternalidInvitacion]', String.valueOf(cmc.EV_ExternalID__c));
                            memberHtml = memberHtml.replace('{{{Campaign.EV_HoraInicio__c}}}', hora.substring(0, 5));
                            memberHtml = memberHtml.replace('{{{CampTranslation.Name}}}', eventName);
                            
                            String auxLocation = '';
                            if(cmc.EV_FormatoDeAsistencias__c == '001'){
                                memberHtml = memberHtml.replace('{{{Campaign.EV_LugarDeCelebracion__c}}}', !String.isEmpty(cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c) ? cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c : '');
                                memberHtml = memberHtml.replace('{{{Campaign.EV_Street__c}}}', !String.isEmpty(cmc.EV_CampaignId__r.EV_Street__c) ? cmc.EV_CampaignId__r.EV_Street__c : '');
                                memberHtml = memberHtml.replace('{{{Campaign.EV_CP__c}}}', !String.isEmpty(cmc.EV_CampaignId__r.EV_CP__c) ? (cmc.EV_CampaignId__r.EV_CP__c + ', ') : '');
                                memberHtml = memberHtml.replace('{{{Campaign.EV_City__c}}}', !String.isEmpty(cmc.EV_CampaignId__r.EV_City__c) ? cmc.EV_CampaignId__r.EV_City__c : '');
                                auxLocation = (!String.isEmpty(cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c) ? cmc.EV_CampaignId__r.EV_LugarDeCelebracion__c : '') + ' ' + (!String.isEmpty(cmc.EV_CampaignId__r.EV_Street__c) ? cmc.EV_CampaignId__r.EV_Street__c : '') + ' ' +  (!String.isEmpty(cmc.EV_CampaignId__r.EV_CP__c) ? (cmc.EV_CampaignId__r.EV_CP__c + ' ') : '') + (!String.isEmpty(cmc.EV_CampaignId__r.EV_City__c) ? cmc.EV_CampaignId__r.EV_City__c : '');
                            }else{
                                memberHtml = memberHtml.replace('{{{Campaign.EV_LugarDeCelebracion__c}}}', 'Online');
                                memberHtml = memberHtml.replace('{{{Campaign.EV_Street__c}}}', '');
                                memberHtml = memberHtml.replace('{{{Campaign.EV_CP__c}}}', '');
                                memberHtml = memberHtml.replace('{{{Campaign.EV_City__c}}}', '');
                                auxLocation = 'Online';
                            }
                            finalHtml += memberHtml;
                            
                            Blob icsFile = Blob.valueOf(generateICSFile(cmc.EV_FormatoDeAsistencias__c, cmc.EV_CampaignId__r.StartDate, cmc.EV_CampaignId__r.EV_HoraInicio__c, cmc.EV_CampaignId__r.EV_HoraFin__c, eventDescription, eventName, auxLocation,cmc.EV_CampaignId__r.EV_URLDelEventoVirtual__c));
                        
                            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                            attachment.setFileName(cmc.EV_CampaignId__r.Name + '.ics');
                            attachment.setContentType('text/calendar');
                            attachment.setInline(false);
                            attachment.setBody(icsFile); 
                            attachments.add(attachment);
                        }

                        if (startIdx != -1 && endIdx != -1) {
                            String before = html.substring(0, startIdx + 19);
                            String after = html.substring(endIdx);
                            html = before + finalHtml + after;
				        }

                        html = html.replace('[[BEGINMEMBER]]', '');
                        html = html.replace('[[ENDMEMBER]]', '');
                        html = html.replace('[[FirstName]]', (campaignMemberListCustom.get(0).EV_FirstName__c != null? campaignMemberListCustom.get(0).EV_FirstName__c :  campaignMemberListCustom.get(0).EV_LastName__c));

                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.setToAddresses(new String[] { email });
                        message.setSubject(asunto); 
                        message.setTemplateId(emailTemplateId);
                        message.setHtmlBody(html);
                        message.setWhatId(campaignMemberListCustom.get(0).Id);
                        message.optOutPolicy = 'FILTER'; 
				        message.setSaveAsActivity(true);  
				        message.setUseSignature(true);
                        message.setOrgWideEmailAddressId(orgwideaddress.get(0).Id);
                        message.setFileAttachments(attachments);

                        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
                        for (Messaging.SendEmailResult result : results) {
                            if (result.isSuccess()){
                                Map<String, Object> responseMap = new Map<String, Object>{
                                    'errors' => new List<String>(),
                                    'success' => true,
                                    'email' => email
                                };
                                listaResultados.add(responseMap);
                                fillRestResponse(res, listaResultados, 200, req, start);
                            }else{
                                listaResultados.add(Label.EV_CMEmailTechSummit); 
                                fillRestResponse(res, listaResultados, 400, req, start);
                            }
                        }
					} 
                    if (campaignMemberListCustom.isEmpty()) {
                        listaResultados.add(Label.EV_CMNotFound);
                        fillRestResponse(res, listaResultados, 400, req, start);
                    }
				}else {
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
        public String externalIdCM;
        public String email;
	}

    public static String generateICSFile(String evtFormato, Date evStartDate, Time evHoraInicio, Time evHoraFin, String evDescription, String evName, String evLocation, String evCode) {
		String icsContent = 'BEGIN:VCALENDAR\n';
		icsContent += 'VERSION:2.0\n';
		icsContent += 'PRODID:-//Salesforce//Calendar//EN\n'; 
		icsContent += 'BEGIN:VEVENT\n'; 
		icsContent += 'UID:' + String.valueOf(System.currentTimeMillis()) + '\n';
		icsContent += 'DTSTAMP:' + Datetime.newInstance( evStartDate.year(),  evStartDate.month(),  evStartDate.day(),  evHoraInicio.hour(), evHoraInicio.minute(), evHoraInicio.second()).formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + '\n';
		icsContent += 'DTSTART:' + Datetime.newInstance( evStartDate.year(),  evStartDate.month(),  evStartDate.day(),  evHoraInicio.hour(), evHoraInicio.minute(), evHoraInicio.second()).formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'') + '\n';
		icsContent += 'DTEND:' + Datetime.newInstance( evStartDate.year(),  evStartDate.month(),  evStartDate.day(),  evHoraFin.hour(), evHoraFin.minute(), evHoraFin.second()).formatGmt('yyyyMMdd\'T\'HHmmss\'Z\'')+ '\n'; 
		icsContent += 'SUMMARY:' + evName + '\n';
		if(evtFormato == '001'){
			icsContent += 'DESCRIPTION:' +  evDescription + '\n';    
		}else{
			icsContent += 'DESCRIPTION:' +  evDescription + '\\n' + '\\n'+ (evCode != null ? evCode : '') + '\n';   
		}
		icsContent += 'LOCATION:' + evLocation + '\n';      
		icsContent += 'END:VEVENT\n';
		icsContent += 'END:VCALENDAR'; 
		return icsContent;
	} 
}