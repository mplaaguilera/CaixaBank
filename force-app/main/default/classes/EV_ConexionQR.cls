/**********************************************************************************************************************
 Name:	  EV_ConexionQR
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración de inscripción NRT
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			App Eventos		xxx                	xxx			        Init version
	1.1         Eventos         Daniel Rodriguez    16/11/2022          Replace Campaign.Description to Campaign.EV_Description__c
	1.2			US587001		Mamen Arias			24/05/2023			Add methods conexQRCMCustom, buildCallRequestBodyQRCMCustom.
***********************************************************************************************************************/


public class EV_ConexionQR {
	
	public class Response {
		public String statusCode;
		public String errorMessage;
		public String errorCode;
	}
	
	public static String conexQR(CampaignMember campMember){
		
		String mockString = '{"eventId": "7015E000099muGZQAY","registerId": "00v5E00099DdAd0QAF","type": "E0101","eventName": "Nombre del evento","eventSubtitle": "Subtitulo del evento","eventDescription": "Descripcion del evento","companyId": 0,"place": "string","address": "Detalle del callejero","name": "Juan López Martínez","language": 0,"documentType": 0,"destination": "descripcion identificadora del destinatario","startHour": "09:30:00","endHour": "14:00:00","date": "2020-10-12","templateId": "T4258"}';
		CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('EV_QRPKPASS');
		Response resultMethod = new Response();
		String body = buildCallRequestBodyQR(campMember);
		
		Map<String, String> mapHeader = new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json;charset=UTF-8');
		EV_LogDebug.printLogDebug('###Header: ', String.valueOf(mapHeader));
		EV_LogDebug.printLogDebug('@@@Body: ', body);
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(dataInterface.CC_EndPoint__c)
			.setCertificate(dataInterface.CC_Certificado__c)
			.setHeaders(mapHeader)
			.setBody(body)
			.addContentTypeJsonHeader()
			.debugMode()
			//.setDataMockup(mockString)
			.runCallout();
		EV_LogDebug.printLogDebug('@@endpoint: ', String.valueOf(dataInterface.CC_EndPoint__c));
		
		//Check errors:
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();

		EV_LogDebug.printLogDebug('@@reqStatusOK: ', String.valueof(reqStatusOK));
		
		if(reqStatusOK){
			EV_LogDebug.printLogDebug('@@apiCallout.getBodyResponse(): ', String.valueof(apiCallout.getBodyResponse()));
		}
		
		return apiCallout.getBodyResponse();
	}
	
	//Generación del body de la llamada
	public static String buildCallRequestBodyQR(CampaignMember campMember) {	
		//String JSONBody = '{"eventId": '+campMember.campaignId + ',"registerId": '+campMember.Id + ',"type": "E0102","eventName": '+campMember.Campaign.Name+',"eventSubtitle": "","eventDescription": '+campMember.Campaign.EV_Description__c+',"companyId": 0,"place": '+campMember.Campaign.EV_LugarDeCelebracion__c+',"address": "","name": '+campMember.Name+',"language": '+campMember.Lead != null ? campMember.Lead.EV_Idiomas__c : campMember.Contact.EV_Idiomas__c+',"documentType": 0,"destination": "Sr.","startHour": '+campMember.Campaign.EV_HoraInicioAC__c+',"endHour": '+campMember.Campaign.EV_HoraFinAC__c+',"date": '+campMember.Campaign.StartDate+',"templateId": "T4258"}'; 
		Map<String, Object> mapJson = new Map<String, Object>();
		mapJson.put('eventId',campMember.campaignId);
		mapJson.put('registerId',campMember.Id);
		mapJson.put('type','E0102');
		mapJson.put('eventName',campMember.Campaign.Name);
		mapJson.put('eventSubtitle','');
		mapJson.put('eventDescription',campMember.Campaign.EV_Description__c);
		mapJson.put('companyId',0);
		mapJson.put('place',campMember.Campaign.EV_LugarDeCelebracion__c != null ? campMember.Campaign.EV_LugarDeCelebracion__c : 'Online');
		mapJson.put('address',campMember.Campaign.EV_LugarDeCelebracion__c != null ? campMember.Campaign.EV_LugarDeCelebracion__c : '');
		mapJson.put('name',campMember.Name);
		mapJson.put('language',campMember.Lead != null ? campMember.Lead.EV_Idiomas__c : campMember.Contact.EV_Idiomas__c);
		mapJson.put('documentType',0);
		mapJson.put('destination',campMember.Id);
		//mapJson.put('destination',campMember.EV_CodigoQR__c.substring(campMember.EV_CodigoQR__c.indexOf('https://www.caixa'), campMember.EV_CodigoQR__c.lastIndexOf('" alt')));
		mapJson.put('startHour',campMember.Campaign.EV_HoraInicioAC__c);
		mapJson.put('endHour',campMember.Campaign.EV_HoraFinAC__c);
		mapJson.put('date',campMember.Campaign.StartDate);
		mapJson.put('templateId','');

		String JSONBody = JSON.serialize(mapJson);

		EV_LogDebug.printLogDebug('@@JSONBody: ', JSONBody);

		return JSONBody;
	}

	public static String conexQRCMCustom(EV_CampaignMemberC__c campMember){
		
		String mockString = '{"eventId": "7015E000099muGZQAY","registerId": "00v5E00099DdAd0QAF","type": "E0101","eventName": "Nombre del evento","eventSubtitle": "Subtitulo del evento","eventDescription": "Descripcion del evento","companyId": 0,"place": "string","address": "Detalle del callejero","name": "Juan López Martínez","language": 0,"documentType": 0,"destination": "descripcion identificadora del destinatario","startHour": "09:30:00","endHour": "14:00:00","date": "2020-10-12","templateId": "T4258"}';
		CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('EV_QRPKPASS');
		Response resultMethod = new Response();
		String body = buildCallRequestBodyQRCMCustom(campMember);
		
		Map<String, String> mapHeader = new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json;charset=UTF-8');
		EV_LogDebug.printLogDebug('###Header: ', String.valueof(mapHeader));
		EV_LogDebug.printLogDebug('@@@Body: ', body);
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(dataInterface.CC_EndPoint__c)
			.setCertificate(dataInterface.CC_Certificado__c)
			.setHeaders(mapHeader)
			.setBody(body)
			.addContentTypeJsonHeader()
			.debugMode()
			//.setDataMockup(mockString)
			.runCallout();
		EV_LogDebug.printLogDebug('@@endpoint: ', String.valueof(dataInterface.CC_EndPoint__c));
		
		//Check errors:
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();

		EV_LogDebug.printLogDebug('@@reqStatusOK: ', String.valueof(reqStatusOK));
		
		if(reqStatusOK){
			EV_LogDebug.printLogDebug('@@apiCallout.getBodyResponse(): ', String.valueof(apiCallout.getBodyResponse()));
		}
		
		return apiCallout.getBodyResponse();
	}
	
	//Generación del body de la llamada
	public static String buildCallRequestBodyQRCMCustom(EV_CampaignMemberC__c campMember) {
		//String JSONBody = '{"eventId": '+campMember.campaignId + ',"registerId": '+campMember.Id + ',"type": "E0102","eventName": '+campMember.Campaign.Name+',"eventSubtitle": "","eventDescription": '+campMember.Campaign.EV_Description__c+',"companyId": 0,"place": '+campMember.Campaign.EV_LugarDeCelebracion__c+',"address": "","name": '+campMember.Name+',"language": '+campMember.Lead != null ? campMember.Lead.EV_Idiomas__c : campMember.Contact.EV_Idiomas__c+',"documentType": 0,"destination": "Sr.","startHour": '+campMember.Campaign.EV_HoraInicioAC__c+',"endHour": '+campMember.Campaign.EV_HoraFinAC__c+',"date": '+campMember.Campaign.StartDate+',"templateId": "T4258"}'; 
		
		Map<String, Object> mapJson = new Map<String, Object>();
		mapJson.put('eventId',campMember.EV_CampaignId__c);
		mapJson.put('registerId',campMember.Id);
		mapJson.put('type','E0102');
		mapJson.put('eventName',campMember.EV_CampaignId__r.Name);
		mapJson.put('eventSubtitle','');
		mapJson.put('eventDescription',campMember.EV_CampaignId__r.EV_Description__c);
		mapJson.put('companyId',0);
		mapJson.put('place',campMember.EV_CampaignId__r.EV_LugarDeCelebracion__c != null ? campMember.EV_CampaignId__r.EV_LugarDeCelebracion__c : 'Online');
		mapJson.put('address',campMember.EV_CampaignId__r.EV_LugarDeCelebracion__c != null ? campMember.EV_CampaignId__r.EV_LugarDeCelebracion__c : '');
		mapJson.put('name',campMember.Name);
		mapJson.put('language',campMember.EV_LeadId__c != null ? campMember.EV_LeadId__r.EV_Idiomas__c : campMember.EV_ContactId__r.EV_Idiomas__c);
		mapJson.put('documentType',0);
		mapJson.put('destination',campMember.Id);
		//mapJson.put('destination',campMember.EV_CodigoQR__c.substring(campMember.EV_CodigoQR__c.indexOf('https://www.caixa'), campMember.EV_CodigoQR__c.lastIndexOf('" alt')));
		mapJson.put('startHour',campMember.EV_CampaignId__r.EV_HoraInicioAC__c);
		mapJson.put('endHour',campMember.EV_CampaignId__r.EV_HoraFinAC__c);
		mapJson.put('date',campMember.EV_CampaignId__r.StartDate);
		mapJson.put('templateId','');

		String JSONBody = JSON.serialize(mapJson);

		EV_LogDebug.printLogDebug('@@JSONBody: ', JSONBody);

		return JSONBody;
	}

	public static Map<String, Object> getQRBinary(String urlQR){
		EV_LogDebug.printLogDebug('@@urlQR: ', urlQR);
		Map<String, Object> result = new Map<String, Object>();
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(urlQR);
		request.setMethod('GET');
		HttpResponse response = http.send(request);
		
		result.put(AV_IntegrationConstants.RESPONSE_REST_STATUS_CODE, String.valueOf(response.getStatusCode()));
		result.put(AV_IntegrationConstants.RESPONSE_REST_STATUS, String.valueOf(response.getStatus()));
		result.put(AV_IntegrationConstants.RESPONSE_REST_BODY, response.getBodyAsBlob());
		EV_LogDebug.printLogDebug('@@@ResultQR: ', String.valueof(result));
		return result;
	}
}