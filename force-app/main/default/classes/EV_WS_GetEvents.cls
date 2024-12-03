/**********************************************************************************************************************
 Name:	  EV_WS_GetEvents
 Copyright © 2023  CaixaBank
----------------------------------------------------------------------------------------------------------------------
Proposito: Clase para Web service de GCF
----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		    AUTHOR				DATE				Description
	1.0		  	US587006			Mamen Arias         31/05/2023          Init Version
	1.1			US606503			Mamen Arias			13/07/2023			Modify services future-registered-list-by-client, future-list-by-client and pass-and-future-list-by-client. Adapt to COE FWK.
	1.2			US714516			Mamen Arias			27/09/2023			Fix status in queries. Badly written
	1.3			US624265			Daniel Rodriguez	26/09/2023			Modify all service to add new field EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c 
	1.4         US306439            Carolina Lopez      17/11/2023          Modify custom CampaignMember service to add new field EV_URLVolverEvento__c, value 'Asistió en diferido' in EV_Status__c and Add service 'attended-deferred-basis'.
	1.5			US854993			Carolina Lopez		04/04/2024			Modified the portal visibility filter in 'past-list-by-client'.
	1.6         FIX             	Carolina Lopez      07/05/2024          Delete WITH SECURITY_ENFORCED.
***********************************************************************************************************************/
@RestResource(urlMapping='/EV_GetEvents/*')
global with sharing class EV_WS_GetEvents extends CBK_HttpServiceIntegration_Abstract {
	
	@HttpPost
	global static void getResults() {

		String servicio = ''; 
		String numperso = '';
		List<String> idioma = new List<String>();
		String numOficina = '';
		String externalIdCampaign = '';
		String externalIdCM = '';
		Date fecha = null;
		List<Campaign> campaignList = new List<Campaign>();
		List<CampaignMember> campaignMemberList = new List<CampaignMember>();
		List<EV_CampaignMemberC__c> campaignMemberListCustom = new List<EV_CampaignMemberC__c>();
		List<Object> listaResultados = new List<Object>();
		List<EV_TraduccionDeEvento__c> traduccionList= new List<EV_TraduccionDeEvento__c>();
		List<String> error = new List<String>();

        Datetime start = Datetime.now();
		RestRequest req = RestContext.request;
		String bodyRequest = req.requestBody.toString();
        
		RequestServicesGCFBody request = (RequestServicesGCFBody) JSON.deserialize(bodyRequest, RequestServicesGCFBody.class);
		servicio = request.servicio;
		numperso = request.numperso;
		idioma = request.idioma;
		numOficina = request.numOficina;
		externalIdCampaign = request.externalIdCampaign;
		externalIdCM = request.externalIdCM;
		fecha = request.fecha;

        RestResponse res = RestContext.response; 

		switch on servicio{
			when 'list-by-client'{
				if (String.isNotBlank(numperso) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, 
								EV_Categoria__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_AforoCompleto__c, EV_AforoFisicoCompleto__c,  
								(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
								EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
								EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c  
								FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
								(SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c 
								FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso) 
								FROM Campaign WHERE ID IN (SELECT CampaignId FROM CampaignMember WHERE Contact.CC_NumPerso__c = :numperso) 
								AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true AND Status != '009' AND Status != '002'];
					listaResultados.addAll(campaignList);

					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, 
								EV_Categoria__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_aforoCompletoC__c, EV_aforoFisicoCompletoC__c,  
								(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
								EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
								EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c    
								FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
								(SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c 
								FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso) 
								FROM Campaign WHERE ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso) 
								AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true AND Status != '009' AND Status != '002'];
					listaResultados.addAll(campaignList);
					
					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
 
			}
			when 'past-list-by-client'{
				if (String.isNotBlank(numperso) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_AforoCompleto__c, EV_AforoFisicoCompleto__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLPDFQR__c, EV_URLQRPKPASS__c
									FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso)  
									FROM Campaign WHERE ID IN (SELECT CampaignId FROM CampaignMember WHERE Contact.CC_NumPerso__c = :numperso) 
									AND Status = '005' AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true 
									AND Id IN (SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE ((EV_Posicionamiento__c='008')  OR
                    				((EV_Posicionamiento__c!='008' AND (EV_VisiblePortal__c = true OR EV_VisibleFormula__c = true)))) AND EV_URLeventoCompleto__c != null)
									ORDER BY EV_FechaHoraFin__c DESC];
					listaResultados.addAll(campaignList);

					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_aforoCompletoC__c, EV_aforoFisicoCompletoC__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c, EV_URLPDFQR__c, EV_URLQRPKPASS__c
									FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso)  
									FROM Campaign WHERE ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso) 
									AND Status = '005' AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true 
									AND Id IN (SELECT EV_Evento__c FROM EV_PortalCaixaBankTalks__c WHERE ((EV_Posicionamiento__c='008')  OR
                    				((EV_Posicionamiento__c!='008' AND (EV_VisiblePortal__c = true OR EV_VisibleFormula__c = true)))) AND EV_URLeventoCompleto__c != null)
									ORDER BY EV_FechaHoraFin__c DESC];
					listaResultados.addAll(campaignList);

					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'future-registered-list-by-client'{
				if (String.isNotBlank(numperso) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_AforoCompleto__c, EV_AforoFisicoCompleto__c, 
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c  
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLPDFQR__c,EV_URLQRPKPASS__c  
									FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso AND (Status IN ('Registro confirmado', 'QR enviado', 'Asistió'))) 
									FROM Campaign WHERE ID IN (SELECT CampaignId FROM CampaignMember WHERE Contact.CC_NumPerso__c = :numperso AND (Status IN ('Registro confirmado', 'QR enviado', 'Asistió'))) 
									AND (Status = '008' OR Status = '003' OR Status = '004' OR  Status = '012') AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true 
									ORDER BY EV_FechaHoraFin__c];
					listaResultados.addAll(campaignList);

					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_aforoCompletoC__c, EV_aforoFisicoCompletoC__c, 
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c, EV_URLPDFQR__c, EV_URLQRPKPASS__c  
									FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND (EV_Status__c IN ('Registro confirmado', 'QR enviado', 'Asistió', 'Asistió en diferido'))) 
									FROM Campaign WHERE ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND (EV_Status__c IN ('Registro confirmado', 'QR enviado', 'Asistió','Accedio a la oferta', 'Asistió en diferido'))) 
									AND (Status = '008' OR Status = '003' OR Status = '004' OR  Status = '012') AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true 
									ORDER BY EV_FechaHoraFin__c];
					listaResultados.addAll(campaignList);

					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'future-interested-list-by-client'{
				if (String.isNotBlank(numperso) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, 
									EV_Categoria__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_AforoCompleto__c, EV_AforoFisicoCompleto__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c    
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLPDFQR__c, EV_URLQRPKPASS__c  
									FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso AND (Status = 'Pendiente' OR Status = 'Invitacion enviada')) 
									FROM Campaign WHERE ID IN (SELECT CampaignId FROM CampaignMember where Contact.CC_NumPerso__c = :numperso AND(Status = 'Pendiente'  OR Status = 'Invitacion enviada')) 
									AND (Status = '008' OR Status = '003' OR Status = '004' OR  Status = '012') AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true
									ORDER BY EV_FechaHoraFin__c];
					listaResultados.addAll(campaignList);

					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, 
									EV_Categoria__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_aforoCompletoC__c, EV_aforoFisicoCompletoC__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c    
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c, EV_URLPDFQR__c, EV_URLQRPKPASS__c  
									FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND (EV_Status__c = 'Pendiente' OR EV_Status__c = 'Invitación enviada')) 
									FROM Campaign WHERE ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c where EV_ContactId__r.CC_NumPerso__c = :numperso AND(EV_Status__c = 'Pendiente'  OR EV_Status__c = 'Invitación enviada')) 
									AND (Status = '008' OR Status = '003' OR Status = '004' OR  Status = '012') AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true
									ORDER BY EV_FechaHoraFin__c];
					listaResultados.addAll(campaignList);

					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'future-list-by-client'{
				if (String.isNotBlank(numperso) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_AforoCompleto__c, EV_AforoFisicoCompleto__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c    
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c 
									FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso AND Status IN ('Pendiente', 'Invitacion enviada', 'Registro confirmado', 'QR enviado', 'Asistió')) 
									FROM Campaign WHERE ID IN (SELECT CampaignId FROM CampaignMember WHERE Contact.CC_NumPerso__c = :numperso AND Status IN ('Pendiente', 'Invitacion enviada', 'Registro confirmado', 'QR enviado', 'Asistió')) 
									AND (Status = '008' OR Status = '003' OR Status = '004' OR  Status = '012') AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true 
									ORDER BY EV_FechaHoraFin__c];
					listaResultados.addAll(campaignList);

					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_aforoCompletoC__c, EV_aforoFisicoCompletoC__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c  
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c
									FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND EV_Status__c IN ('Pendiente', 'Invitación enviada', 'Registro confirmado', 'QR enviado', 'Asistió', 'Asistió en diferido')) 
									FROM Campaign WHERE ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND EV_Status__c IN ('Pendiente', 'Invitación enviada', 'Registro confirmado', 'QR enviado', 'Asistió','Accedio a la oferta', 'Asistió en diferido')) 
									AND (Status = '008' OR Status = '003' OR Status = '004' OR  Status = '012') AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true 
									ORDER BY EV_FechaHoraFin__c];
					listaResultados.addAll(campaignList);

					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'pass-and-future-list-by-client'{
				if (String.isNotBlank(numperso) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_AforoCompleto__c, EV_AforoFisicoCompleto__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c,  EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c ,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c  
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLPDFQR__c, EV_URLQRPKPASS__c 
									FROM CampaignMembers WHERE Contact.CC_NumPerso__c = :numperso AND Status IN ('Pendiente', 'Invitacion enviada', 'Registro confirmado', 'QR enviado', 'Asistió')) 
									FROM Campaign WHERE ID IN (SELECT CampaignId FROM CampaignMember WHERE Contact.CC_NumPerso__c = :numperso AND Status IN ('Pendiente', 'Invitacion enviada', 'Registro confirmado', 'QR enviado', 'Asistió')) 
									AND (Status = '008' OR Status = '003' OR Status = '004' OR  Status = '005' OR  Status = '012') AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true];
					listaResultados.addAll(campaignList);

					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_aforoCompletoC__c, EV_aforoFisicoCompletoC__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c,  EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLPDFQR__c, EV_URLQRPKPASS__c, EV_URLVolverEvento__c
									FROM CampaignMembers__r WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND EV_Status__c IN ('Pendiente', 'Invitación enviada', 'Registro confirmado', 'QR enviado', 'Asistió', 'Asistió en diferido')) 
									FROM Campaign WHERE ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ContactId__r.CC_NumPerso__c = :numperso AND EV_Status__c IN ('Pendiente', 'Invitación enviada', 'Registro confirmado', 'QR enviado', 'Asistió','Accedio a la oferta', 'Asistió en diferido')) 
									AND (Status = '008' OR Status = '003' OR Status = '004' OR  Status = '005' OR  Status = '012') AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true];
					listaResultados.addAll(campaignList);

					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'list-by-office'{
				if (String.isNotBlank(numOficina) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_AforoCompleto__c, EV_aforoCompletoC__c, EV_AforoFisicoCompleto__c, EV_aforoFisicoCompletoC__c, 
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma), 
									(SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers),
									(SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c FROM CampaignMembers__r) 
									FROM Campaign WHERE (Campaign.EV_CentroOrganizador__r.CC_Numero_Oficina__c = :numOficina 
									OR Campaign.EV_CentroPromotor__r.CC_Numero_Oficina__c = :numOficina 
									OR Campaign.EV_CentroAdminstrador__r.CC_Numero_Oficina__c = :numOficina) 
									AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true AND Status != '009' AND Status != '002'];
					fillRestResponse(res, campaignList, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'client-and-event-list-by-date'{
				if (fecha != null){
						campaignMemberList = [SELECT Id, Contact.CC_NumPerso__c, CampaignId,  Campaign.EV_NewArchitecture__c, Campaign.EV_ExternalID__c, Campaign.Name, Campaign.EV_NombrePonente__c, Campaign.StartDate, Campaign.EV_HoraInicio__c, 
											Campaign.Status, Campaign.RecordType.DeveloperName, EV_ExternalID__c, Status, EV_FormatoDeAsistencias__c, Campaign.EV_Categoria__c, Campaign.EV_URLDelEventoVirtual__c, 
											Campaign.EV_URLRegistro__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, Campaign.EV_Duracion__c, Campaign.EV_Idioma__c, Campaign.EV_AforoCompleto__c, Campaign.EV_AforoFisicoCompleto__c 
											FROM CampaignMember WHERE Campaign.StartDate = :fecha AND Campaign.Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND Campaign.EV_EventoVisibleNOW__c = true 
											AND Campaign.Status != '009' AND Campaign.Status != '002'];

						listaResultados.addAll(campaignMemberList);

						campaignMemberListCustom = [SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_CampaignId__c, EV_CampaignId__r.EV_NewArchitecture__c, EV_CampaignId__r.EV_ExternalID__c, EV_CampaignId__r.Name, EV_CampaignId__r.EV_NombrePonente__c, 
											EV_CampaignId__r.StartDate, EV_CampaignId__r.EV_HoraInicio__c, EV_CampaignId__r.Status, EV_CampaignId__r.RecordType.DeveloperName, EV_ExternalID__c, EV_Status__c, 
											EV_FormatoDeAsistencias__c, EV_CampaignId__r.EV_Categoria__c , EV_CampaignId__r.EV_URLDelEventoVirtual__c, EV_CampaignId__r.EV_URLRegistro__c, EV_URLRegistro__c, 
											EV_URLStreamingEvento__c, EV_URLVolverEvento__c, EV_CampaignId__r.EV_Duracion__c, EV_CampaignId__r.EV_Idioma__c, EV_CampaignId__r.EV_aforoCompletoC__c, EV_CampaignId__r.EV_aforoFisicoCompletoC__c 
											FROM EV_CampaignMemberC__c WHERE EV_CampaignId__r.StartDate = :fecha AND EV_CampaignId__r.Recordtype.DeveloperName != :Label.EV_EventosAccionistas 
											AND EV_CampaignId__r.EV_EventoVisibleNOW__c = true AND EV_CampaignId__r.Status != '009' AND EV_CampaignId__r.Status != '002'];
					
						listaResultados.addAll(campaignMemberListCustom);

						fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'detail-list-by-externalid-and-language'{
				if (String.isNotBlank(externalIdCampaign) && (idioma != null && !idioma.isEmpty())){
					traduccionList = [SELECT Id, EV_Claim__c, EV_Idioma__c, EV_Evento__r.Name, EV_Evento__r.EV_NewArchitecture__c, EV_Evento__r.EV_Description__c, EV_Evento__r.EV_NombrePonente__c, EV_Evento__r.StartDate, EV_Evento__r.Status, 
									EV_Evento__r.EV_HoraInicio__c, EV_Evento__r.EV_LugarDeCelebracion__c, EV_Evento__r.EV_AddressNumber__c, EV_Evento__r.EV_Street__c, EV_Evento__r.EV_City__c, EV_Evento__r.EV_CP__c, 
									EV_Evento__r.EV_CentroOrganizador__r.CC_Numero_Oficina__c, EV_Evento__r.EV_Aforo_espacio_fisico__c, EV_Evento__r.EV_NumeroDePlazas__c, EV_Evento__r.EV_inscritosFisicos__c, EV_Evento__r.EV_InscritosFisicosC__c,
									EV_Evento__r.EV_inscritosVirtuales__c, EV_Evento__r.EV_InscritosVirtualesC__c, EV_Evento__r.EV_asistentesFisicos__c, EV_Evento__r.EV_AsistentesFisicosC__c, EV_Evento__r.EV_asistentesVirtuales__c, EV_Evento__r.EV_AsistentesVirtualesC__c, EV_Evento__r.RecordType.DeveloperName, 
									EV_Evento__r.EV_URLDelEventoVirtual__c, EV_Evento__r.EV_URLRegistro__c, EV_Evento__r.EV_Categoria__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, 
									EV_URLImagenGrande__c, EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c, 
									EV_Evento__r.EV_Duracion__c, EV_Evento__r.EV_Idioma__c, EV_Evento__r.EV_AforoCompleto__c, EV_Evento__r.EV_aforoCompletoC__c, EV_Evento__r.EV_AforoFisicoCompleto__c, EV_Evento__r.EV_aforoFisicoCompletoC__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c  
									FROM EV_TraduccionDeEvento__c WHERE EV_Evento__r.EV_ExternalId__c = :externalIdCampaign AND EV_Idioma__c IN :idioma AND EV_Evento__r.Recordtype.DeveloperName != :Label.EV_EventosAccionistas 
									AND EV_Evento__r.EV_EventoVisibleNOW__c = true AND EV_Evento__r.Status != '009' AND EV_Evento__r.Status != '002'];
					fillRestResponse(res, traduccionList, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'detail-by-externalid'{
				if (String.isNotBlank(externalIdCM) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, Name, EV_NewArchitecture__c, EV_ExternalID__c,EV_Description__c, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, 
									EV_CentroOrganizador__c, EV_CentroOrganizador__r.CC_Numero_Oficina__c, EV_Aforo_espacio_fisico__c, EV_NumeroDePlazas__c, EV_inscritosFisicos__c, EV_inscritosVirtuales__c, EV_asistentesFisicos__c, 
									EV_asistentesVirtuales__c, EV_Duracion__c, EV_Idioma__c, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, Status, EV_AforoCompleto__c, EV_AforoFisicoCompleto__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c , EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c in :idioma),  
									(SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c,EV_URLPDFQR__c,EV_URLQRPKPASS__c  
									FROM CampaignMembers WHERE EV_ExternalID__c = :externalIdCM) 
									FROM Campaign WHERE ID IN (SELECT CampaignId FROM CampaignMember WHERE EV_ExternalID__c = :externalIdCM) AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true 
									AND Status != '009' and Status != '002'];
					listaResultados.addAll(campaignList);

					campaignList = [SELECT Id, Name, EV_NewArchitecture__c, EV_ExternalID__c,EV_Description__c, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, 
									EV_CentroOrganizador__c, EV_CentroOrganizador__r.CC_Numero_Oficina__c, EV_Aforo_espacio_fisico__c, EV_NumeroDePlazas__c, EV_InscritosFisicosC__c, EV_InscritosVirtualesC__c, EV_AsistentesFisicosC__c, 
									EV_AsistentesVirtualesC__c, EV_Duracion__c, EV_Idioma__c, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, Status, EV_aforoCompletoC__c, EV_aforoFisicoCompletoC__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c , EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c in :idioma),  
									(SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c, EV_URLPDFQR__c, EV_URLQRPKPASS__c  
									FROM CampaignMembers__r WHERE EV_ExternalID__c = :externalIdCM) 
									FROM Campaign WHERE ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_ExternalID__c = :externalIdCM) AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true 
									AND Status != '009' and Status != '002'];
					listaResultados.addAll(campaignList);
					
					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'detail-by-externalid-and-client'{
				if (String.isNotBlank(externalIdCampaign) && String.isNotBlank(numperso) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, Name, EV_NewArchitecture__c, EV_ExternalID__c,EV_Description__c, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, 
									EV_CentroOrganizador__c, EV_CentroOrganizador__r.CC_Numero_Oficina__c, EV_Aforo_espacio_fisico__c, EV_NumeroDePlazas__c, EV_inscritosFisicos__c, EV_inscritosVirtuales__c, EV_asistentesFisicos__c, 
									EV_asistentesVirtuales__c, EV_Duracion__c, EV_Idioma__c, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, Status, EV_AforoCompleto__c, EV_AforoFisicoCompleto__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma),  
									(SELECT Id, Contact.CC_NumPerso__c, Status, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLPDFQR__c, EV_URLQRPKPASS__c 
									FROM CampaignMembers WHERE Campaign.EV_ExternalID__c = :externalIdCampaign AND Contact.CC_NumPerso__c = :numperso) 
									FROM Campaign WHERE ID IN (SELECT CampaignId FROM CampaignMember WHERE Campaign.EV_ExternalID__c = :externalIdCampaign AND Contact.CC_NumPerso__c = :numperso) 
									AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true AND Status != '009' AND Status != '002'];
					listaResultados.addAll(campaignList);

					campaignList = [SELECT Id, Name, EV_NewArchitecture__c, EV_ExternalID__c,EV_Description__c, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, 
									EV_CentroOrganizador__c, EV_CentroOrganizador__r.CC_Numero_Oficina__c, EV_Aforo_espacio_fisico__c, EV_NumeroDePlazas__c, EV_InscritosFisicosC__c, EV_InscritosVirtualesC__c, EV_AsistentesFisicosC__c, 
									EV_AsistentesVirtualesC__c, EV_Duracion__c, EV_Idioma__c, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, Status, EV_aforoCompletoC__c, EV_aforoFisicoCompletoC__c,
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma),  
									(SELECT Id, EV_ContactId__r.CC_NumPerso__c, EV_Status__c, EV_ExternalID__c, EV_FormatoDeAsistencias__c, EV_URLRegistro__c, EV_URLStreamingEvento__c, EV_URLVolverEvento__c,EV_URLPDFQR__c, EV_URLQRPKPASS__c 
									FROM CampaignMembers__r WHERE EV_CampaignId__r.EV_ExternalID__c = :externalIdCampaign AND EV_ContactId__r.CC_NumPerso__c = :numperso) 
									FROM Campaign WHERE ID IN (SELECT EV_CampaignId__c FROM EV_CampaignMemberC__c WHERE EV_CampaignId__r.EV_ExternalID__c = :externalIdCampaign AND EV_ContactId__r.CC_NumPerso__c = :numperso) 
									AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true AND Status != '009' AND Status != '002'];
					listaResultados.addAll(campaignList);

					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'inprogress-list-by-office'{
				if (String.isNotBlank(numOficina) && (idioma != null && !idioma.isEmpty())){
					campaignList = [SELECT Id, EV_NewArchitecture__c, EV_ExternalID__c, Name, EV_NombrePonente__c, StartDate, EV_HoraInicio__c, Status, RecordType.DeveloperName, EV_URLDelEventoVirtual__c, EV_URLRegistro__c, EV_Categoria__c, 
									EV_LugarDeCelebracion__c, EV_AddressNumber__c, EV_Street__c, EV_City__c, EV_CP__c, EV_Duracion__c, EV_Idioma__c, EV_AforoCompleto__c, EV_aforoCompletoC__c, EV_AforoFisicoCompleto__c, EV_aforoFisicoCompletoC__c, 
									(SELECT EV_Claim__c, EV_Descripcion__c, Name, EV_Idioma__c, EV_ImagenCabecera__c, EV_URLDeImagen__c, EV_URLImagenCarrusel__c, EV_URLImagenEsperaStreaming__c, EV_URLImagenGrande__c, 
									EV_URLImagenInvitacion__c, EV_URLImagenMedia__c, EV_URLImagenMovil__c, EV_URLImagenOriginal__c, EV_URLImagenPequena__c, EV_URLVideoTeaser__c, EV_URLEventVideo__c,
									EV_BeAgroBankMIC__c, EV_BancaNegocios__c,EV_BancaPremier__c,EV_BancaPrivada__c,EV_BancaRetail__c,EV_CodigoBeAgroBankMIC__c,EV_CodigoBancaNegocios__c,EV_CodigoBancaPremier__c,EV_CodigoBancaPrivada__c,EV_CodigoBancaRetail__c,EV_TextoCTANL__c, EV_URLCTALanding__c,EV_TextoCTALanding__c   
									FROM Idiomas_de_Eventos__r WHERE EV_Idioma__c IN :idioma) 
									FROM Campaign WHERE ID IN (SELECT EV_Campaign__c FROM Centro_Objetivo__c WHERE EV_Centro__r.CC_Numero_Oficina__c = :numOficina) 
									AND Status = '004' AND Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_EventoVisibleNOW__c = true];
					fillRestResponse(res, campaignList, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}

			when 'registered-client-list-by-externalid'{
				if (String.isNotBlank(externalIdCampaign)){
					campaignMemberList = [SELECT Id, Campaign.EV_NewArchitecture__c, Campaign.EV_Aforo_espacio_fisico__c, Campaign.EV_TotalInscritos__c, Campaign.EV_Description__c, Campaign.EV_ExternalID__c, Campaign.EV_Categoria__c, 
										Campaign.RecordType.DeveloperName, Type, EV_Numperso__c, Name, EV_ExternalID__c, Status, EV_FormatoDeAsistencias__c, Campaign.EV_Duracion__c, Campaign.EV_Idioma__c, Campaign.EV_AforoFisicoCompleto__c 
										FROM CampaignMember WHERE Campaign.EV_ExternalId__c = :externalIdCampaign AND Status IN ('Registro confirmado', 'QR enviado', 'Asistió') 
										AND Campaign.Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND Campaign.EV_EventoVisibleNOW__c = true AND Campaign.Status != '009' AND Campaign.Status != '002'];
					listaResultados.addAll(campaignMemberList);

					campaignMemberListCustom = [SELECT Id, EV_CampaignId__r.EV_NewArchitecture__c, EV_CampaignId__r.EV_Aforo_espacio_fisico__c, EV_CampaignId__r.EV_TotalInscritosC__c, EV_CampaignId__r.EV_Description__c, EV_CampaignId__r.EV_ExternalID__c, 
											EV_CampaignId__r.EV_Categoria__c, EV_CampaignId__r.RecordType.DeveloperName, EV_Numperso__c, Name, EV_ExternalID__c, EV_Status__c, EV_FormatoDeAsistencias__c, 
											EV_CampaignId__r.EV_Duracion__c, EV_CampaignId__r.EV_Idioma__c, EV_CampaignId__r.EV_aforoFisicoCompletoC__c 
											FROM EV_CampaignMemberC__c WHERE EV_CampaignId__r.EV_ExternalId__c = :externalIdCampaign AND EV_Status__c IN ('Registro confirmado', 'QR enviado', 'Asistió','Accedio a la oferta', 'Asistió en diferido') 
											AND EV_CampaignId__r.Recordtype.DeveloperName != :Label.EV_EventosAccionistas AND EV_CampaignId__r.EV_EventoVisibleNOW__c = true AND EV_CampaignId__r.Status != '009' AND EV_CampaignId__r.Status != '002'];
					listaResultados.addAll(campaignMemberListCustom);

					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
			}
            
            when 'client-by-externalid'{
                if (String.isNotBlank(externalIdCM)){
					campaignMemberList = [SELECT Id, FirstName, EV_NumeroDocumento__c, LastName, Status, Phone, EV_ContadorCheckInVirtual__c, Contact.AccountId, EV_Empresa__c, Email, Account.Name, 
                                          Account.CC_Numero_Documento__c, Account.CC_Cargo__pc, EV_URLStreamingEvento__c, EV_FormatoDeAsistencias__c, Campaign.EV_Aforo_espacio_fisico__c, Campaign.EV_inscritosFisicos__c, Campaign.EV_NewArchitecture__c 
                                          FROM CampaignMember WHERE EV_ExternalID__c= :externalIdCM];
					listaResultados.addAll(campaignMemberList);

					campaignMemberListCustom = [SELECT Id, EV_FirstName__c, EV_NumeroDocumento__c, EV_LastName__c, EV_Status__c, EV_Phone__c, EV_ContadorCheckInVirtual__c, EV_ContactId__r.AccountId, EV_Empresa__c, EV_Email__c, EV_AccountId__r.Name, 
                                                EV_AccountId__r.CC_Numero_Documento__c, EV_AccountId__r.CC_Cargo__pc, EV_URLStreamingEvento__c, EV_FormatoDeAsistencias__c, EV_CampaignId__r.EV_Aforo_espacio_fisico__c, EV_CampaignId__r.EV_InscritosFisicosC__c, EV_CampaignId__r.EV_NewArchitecture__c 
                                                FROM EV_CampaignMemberC__c WHERE EV_ExternalID__c= :externalIdCM ];
					listaResultados.addAll(campaignMemberListCustom);

					fillRestResponse(res, listaResultados, 200, req, start);
				} else {
					error.add(Label.EV_ParameterError);
					fillRestResponse(res, error, 400, req, start);
				}
            }
            
            when 'client-unsubscribed-event'{
                if (String.isNotBlank(externalIdCM)){
                    
					campaignMemberList = [SELECT Id FROM CampaignMember WHERE EV_ExternalID__c= :externalIdCM];
                    if (!campaignMemberList.isEmpty()){
                        CampaignMember cm = new CampaignMember();
                        cm.Id = campaignMemberList[0].Id;
                        cm.Status = 'Baja del evento';
                        Database.SaveResult result = Database.update(cm, false);
                        
                        if (result.isSuccess()){
                            listaResultados.add(result);
                            fillRestResponse(res, listaResultados, 200, req, start);
                        } else {
                            listaResultados.add(result);
                            fillRestResponse(res, listaResultados, 400, req, start);
                        }
                    }
                    
                    campaignMemberListCustom = [SELECT Id FROM EV_CampaignMemberC__c WHERE EV_ExternalID__c= :externalIdCM];
                        if (!campaignMemberListCustom.isEmpty()){
                            EV_CampaignMemberC__c cmCustom = new EV_CampaignMemberC__c();
                            cmCustom.Id = campaignMemberListCustom[0].Id;
                            cmCustom.EV_Status__c = 'Baja del evento';
                            Database.SaveResult result = Database.update(cmCustom, false);
                        
                            if (result.isSuccess()){
                                listaResultados.add(result);
                                fillRestResponse(res, listaResultados, 200, req, start);
                            } else {
                                listaResultados.add(result);
                                fillRestResponse(res, listaResultados, 400, req, start);
                            }
                    } 
                                        
                    if (campaignMemberList.isEmpty() && campaignMemberListCustom.isEmpty()) {
                        listaResultados.add(Label.EV_CMNotFound);
                        fillRestResponse(res, listaResultados, 400, req, start);
                    }
                    
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

			when else {
				error.add(Label.EV_ServiceError);
				fillRestResponse(res, error, 400, req, start);
			}
		}
		
	}

	public static void fillRestResponse(RestResponse res, List<Object> responseToShow, Integer statusCode, RestRequest req, Datetime start){
		res.headers.put('Content-Type', 'application/json');
		res.responsebody = Blob.valueOf(JSON.serialize(responseToShow));
		res.statusCode = statusCode;
        Datetime stop = Datetime.now();
        register(req, res, start, stop, '', 'EV_GetEvents');
	}
	
	public class RequestServicesGCFBody{
		public String servicio;
		public String numperso;
		public List<String> idioma;
		public String numOficina;
		public String externalIdCampaign;
		public String externalIdCM;
		public Date fecha;
	}
}