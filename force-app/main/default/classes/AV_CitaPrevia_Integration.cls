/**********************************************************************************************************************
Name:      AV_CitaPrevia_Integration 
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con API para Eventos
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION        USER_STORY                               AUTHOR               DATE        Description
1.0            SF - Integración con API de Cita Previa  Jashanpreet          19/10/2020  Init version
1.1            US304978                                 Víctor Santiago      07/04/2022  branchPhysicalMeet from int to str
1.2            IN1123492                                Elisabeth R.         04/04/2024  Add legalRepresentativeId and legalRepresentativeName params
1.3            Fix                                      Sandra Gómez         18/04/2024  Comment legalRepresentativeName and legalRepresentativeId
1.4			   PPM100538432								Sandra Gómez		 11/09/2024	 Change to FWK and add parameters legalRepresentativeName, legalRepresentativeId and MandatoryAssistance
***********************************************************************************************************************/
public with sharing class AV_CitaPrevia_Integration {

	public class Event {
		public String salesforceEventId;
		public String subject;
		public Customer Customer;    
		public String employeeEvent;
		public Integer branchId;
		//public List<String> MandatoryAssistances;
		//public List<String> OptionalAssistances;
		public String branchPhysicalMeet;
		public String type;
		public String locationType;
		public String remoteMeeting; 
		public String physicalMeeting;   
		public String meetingPlace;  
		public String meetingRequester;  
		public String reason;
		public String reasonOther;
		public String status;
		public String date_X;
		public String startTime;
		public String endTime;
		public String serialMeetingId;
		public String previousWarning;
		public String colour;
		public Boolean isPrivate;
		public String comment;
		public Boolean aniversary;
		public String urlVideocall;
		public String urlQrPk;
		public String urlQrPdf;
		public String mifidId;
		public String metadataId;
		public List<MetadataField> MetadataFields;
		public Boolean isPhoneSale;
		public Boolean isDigitalCustomer;
		public String legalRepresentativeId;
		public String legalRepresentativeName;
		public List<String> MandatoryAssistance;
	}
	
	public class MetadataField{
		public String fieldId;
		public String value;
	}
	public class Customer{
		public Integer customerId;
		public String name;
		public String surname;
		public String secondSurname;
	}
	
	public class InsCntResponse {
		public String StatusCode;
		public String errorMessage;
		public String errorCode;
		public String eventPremiumId;
	}
	
	public class MoCntResponse {
		public String StatusCode;
		public String errorMessage;
		public String errorCode;
	} 

	public class DelCntResponse {
		public String StatusCode;
		public String errorMessage;
		public String errorCode;
	} 
	
	public class RequestAltaEvent {
		public Event Event;
		public RequestAltaEvent(Event parms) {
            this.Event = parms;
        }
	}

	private static final String NAMED_CREDENTIAL_INT = 'AV_citaprevia_int';
    private static final String NAMED_CREDENTIAL_MOD = 'AV_citaprevia_mo';

	 /**
    * @description            Construye el header de la peticion.
    * @param customerId     -> Identificador del cliente
    * @param employeeId     -> Identificador del empleado
    */
    public static Map<String, String> buildHeaderRequest(String employeeId, String branchId) {
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('x-branchId', branchId);
        mapHeader.put('x-employeeId', employeeId);
        mapHeader.put('Content-Type', 'application/json');
        return mapHeader;
    }

	/**
     * Check if th status code is error or not.
     * Usually the responses accepted are: 200, 201 or 204
     */
    public static boolean checkErrorStatusCode(HTTPResponse response){
        Set<String> httpStatusList = new Set<String>();
        httpStatusList.add('200');
        httpStatusList.add('201');
        httpStatusList.add('204');
        String codigoStado = String.valueOf(response.getStatusCode());
        return httpStatusList.contains(codigoStado);
    }

	/**
	* @description             
	* @param parms     -> Event params
	* @param employeeId -> employee Id
	*/
	public static InsCntResponse intCnt(Event parms, String employeeId, String branchId) {
		String methodName = 'intCnt';
		if(parms == null || String.isBlank(employeeId)) {
			throw new AV_ApplicationException(methodName + ' method params must not be null.');
		}
		String body = '';
		try {
			body = JSON.serialize(new RequestAltaEvent(parms));
			CBK_Log.debug(methodName, 'String body', new List<String>{body});
		} catch(Exception ex) {
			CBK_Log.error(methodName, new List<Event>{parms});
		}
		InsCntResponse resultMethod = new InsCntResponse();
		if(String.isNotBlank(body)) {
			Map<String, String> mapHeader = buildHeaderRequest(employeeId, branchId);
			body = body.replace('date_X', 'date');
			CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
			requestWrp.body = body;
			requestWrp.intSetting = NAMED_CREDENTIAL_INT;
			requestWrp.method = 'POST';
			requestWrp.mHeaders = mapHeader;
			requestWrp.mUriParams = new  Map<String, string>();
			requestWrp.mQueryParams = new  Map<String, string>();
			AV_LogDebug.printLogDebug(methodName, 'requestWrp: ' + requestWrp);
			HttpRequest frwReq = CBK_HttpServiceIntegration.getRequest(requestWrp);
			if(frwReq != null) {
				CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(NAMED_CREDENTIAL_INT);
				String endpoint = wsc?.NamedCredential__c.replace('{employeeId}', employeeId);
				if(String.isNotBlank(endpoint)) {
					frwReq.setEndpoint(endpoint);
				}
				AV_LogDebug.printLogDebug(methodName, 'frwReq: ' + frwReq);
				HttpResponse respuesta = CBK_HttpServiceIntegration.multiCallHttpService(frwReq,null,null);
				Map<String,Object> resBody = new Map<String,Object>();
				try {
					resBody = (Map<String,Object>) JSON.deserializeUntyped(respuesta.getBody());
					CBK_Log.debug(methodName, 'Map<String,Object> resBody', new List<Map<String,Object>>{resBody});
				} catch(Exception ex) {
					CBK_Log.error(methodName, respuesta.getBody());
				}
				resultMethod.statusCode = String.ValueOf(respuesta.getStatusCode());
				resultMethod.errorMessage = String.valueOf(resBody.get('ErrorDetail'));
				resultMethod.errorCode = String.valueOf(resBody.get('StatusCode'));
				resultMethod.eventPremiumId = checkErrorStatusCode(respuesta) ? String.valueOf(resBody.get('eventPremiumId')) : '';
			}
		}
		return resultMethod;
	}

	/*---OLD CODE -----
	public static InsCntResponse intCnt( Event parms, String employeeId, String branchId){
		InsCntResponse resultMethod = new InsCntResponse();
		String methodName = 'intCnt';
		  
		CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CitaPrevia_IntCnt');
		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		if(!String.isEmpty(branchId)){
			branchId = branchId.contains('-') ? branchId.substringAfter('-') : branchId;
		}
		Map<String, String> mapHeader = buildHeaderRequest(employeeId, branchId);
		RequestAltaEvent request = new RequestAltaEvent();
		request.event = parms;
		String endpoint;
		if(dataInterface.CC_EndPoint__c != null){
			endpoint = dataInterface.CC_EndPoint__c.replace('{employeeId}', employeeId);
		}
		String body = System.JSON.serialize(request).replace('date_X', 'date');
		
		AV_LogDebug.printLogDebug(methodName, 'Request endpoint: ' + endpoint);
		AV_LogDebug.printLogDebug(methodName, 'Request Header: ' +mapHeader);
		AV_LogDebug.printLogDebug(methodName, 'Request Body: ' + body);

		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(endpoint) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.setHeaders(mapHeader)
			.setBody(body)
			.addContentTypeJsonHeader()
			.debugMode()
			//.setDataMockup('{"statusCode": "201","eventPremiumId": "8911100000000001"}')
			.runCallout();
		
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		
		//Check errors:
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		if(reqStatusOK){
			Map<String,Object> resBody = (Map<String,Object>) JSON.deserializeUntyped(apiCallout.getBodyResponse());
			resultMethod.eventPremiumId = String.valueOf(resBody.get('eventPremiumId'));
		}
		AV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
		AV_LogDebug.printLogDebug(methodName, '## statusCode: ' + resultMethod.statusCode);
		AV_LogDebug.printLogDebug(methodName, '## errorCode: ' + resultMethod.errorCode);
		AV_LogDebug.printLogDebug(methodName, '## resultMethod: ' + resultMethod);
		
		return resultMethod;
	}*/

	 /**
	* @description             
	* @param parms     -> Event params
	* @param employeeId -> employee Id
	*/
	public static MoCntResponse moCnt(Event parms, String employeeId, String eventPremiumId, String branchId) {
        String methodName = 'moCnt';
        if(parms == null || String.isBlank(employeeId) || String.isBlank(eventPremiumId)) {
            throw new AV_ApplicationException(methodName + ' method params must not be null.');
        }
        String body = '';
        try {
            body = JSON.serialize(new RequestAltaEvent(parms));
            CBK_Log.debug(methodName, 'String body', new List<String>{body});
        } catch(Exception ex) {
            CBK_Log.error(methodName, new List<Event>{parms});
        }
        MoCntResponse resultMethod = new MoCntResponse();
        if(String.isNotBlank(body)) {
            Map<String, String> mapHeader = buildHeaderRequest(employeeId, branchId);
			body = body.replace('date_X', 'date');
			CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
			requestWrp.body = body;
			requestWrp.intSetting = NAMED_CREDENTIAL_MOD;
			requestWrp.method = 'POST';
			requestWrp.mHeaders = mapHeader;
			requestWrp.mUriParams = new  Map<String, string>();
			requestWrp.mQueryParams = new  Map<String, string>();
			AV_LogDebug.printLogDebug(methodName, 'requestWrp: ' + requestWrp);
            HttpRequest frwReq = CBK_HttpServiceIntegration.getRequest(requestWrp);
            if(frwReq != null) {
                CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(NAMED_CREDENTIAL_MOD);
                String endpoint = wsc?.NamedCredential__c.replace('{id}', eventPremiumId);
                if(String.isNotBlank(endpoint)) {
                    frwReq.setEndpoint(endpoint);
                }
				AV_LogDebug.printLogDebug(methodName, 'frwReq: ' + frwReq);
                HttpResponse respuesta = CBK_HttpServiceIntegration.multiCallHttpService(frwReq,null,null);
                Map<String,Object> resBody = new Map<String,Object>();
                try {
                    resBody = (Map<String,Object>) JSON.deserializeUntyped(respuesta.getBody());
                    CBK_Log.debug(methodName, 'Map<String,Object> resBody', new List<Map<String,Object>>{resBody});
                } catch(Exception ex) {
                    CBK_Log.error(methodName, respuesta.getBody());
                }
                resultMethod.statusCode = String.ValueOf(respuesta.getStatusCode());
                resultMethod.errorMessage = String.valueOf(resBody.get('ErrorDetail'));
                resultMethod.errorCode = String.valueOf(resBody.get('StatusCode'));
            }
        }
        return resultMethod;
    }
	/*---OLD CODE -----
	public static MoCntResponse moCnt( Event parms, String employeeId, String eventPremiumtId, String branchId){
		MoCntResponse resultMethod = new MoCntResponse();
		String methodName = 'moCnt';
		
		CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CitaPrevia_MoCnt');
		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		if(!String.isEmpty(branchId)){
			branchId = branchId.contains('-') ? branchId.substringAfter('-') : branchId;
		}
		Map<String, String> mapHeader = buildHeaderRequest(employeeId, branchId);
		RequestAltaEvent request = new RequestAltaEvent();
		request.event = parms;
		String endpoint = dataInterface.CC_EndPoint__c.replace('{eventPremiumId}', eventPremiumtId);
		String body = System.JSON.serialize(request).replace('date_X', 'date');
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(endpoint) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.setHeaders(mapHeader)
			.setBody(body)
			.addContentTypeJsonHeader()
			.debugMode()
			//.setDataMockup('{"statusCode": "200"}')
			.runCallout();
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		
		//Check errors:
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		AV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
		
		return resultMethod;
	}*/

	
	 /**
	* @description             
	* @param parms     -> Event params
	* @param employeeId -> employee Id
	*/
	public static DelCntResponse delCnt(  String employeeId, String eventId, String branchId){
		DelCntResponse resultMethod = new DelCntResponse();
		String methodName = 'deCnt';
		
		CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CitaPrevia_DelCnt');
		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		if(!String.isEmpty(branchId)){
			branchId = branchId.contains('-') ? branchId.substringAfter('-') : branchId;
		}
		Map<String, String> mapHeader = buildHeaderRequest2(employeeId, branchId);
		String endpoint = dataInterface.CC_EndPoint__c.replace('{eventId}', eventId);
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(endpoint) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.setHeaders(mapHeader)
			.addContentTypeJsonHeader()
			.debugMode()
			//.setDataMockup('{"statusCode": "200"}')
			.runCallout();
		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
		
		//Check errors:
		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
		/*if(reqStatusOK){
			//Event updated. Body: {statusCode 200}.
		}*/
		AV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
		
		return resultMethod;
	}



	 /**
	* @description            Construye el header de la peticion.
	* @param customerId     -> Identificador del cliente
	* @param employeeId     -> Identificador del empleado
	*/
	public static Map<String, String> buildHeaderRequest2( String employeeId, String branchId){
		Map<String, String> mapHeader = new Map<String, String>();
		mapHeader.put('x-branchId', branchId);
		mapHeader.put('x-employeeId', employeeId);
		return mapHeader;
	}

}