/**********************************************************************************************************************
Name:	  AV_HGM_Integration
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con HGM Experiencia Cliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION		USER_STORY							    AUTHOR			  	DATE			Description
1.0			US268687                            	Sandra Gómez      	13/09/2021		Init version
1.1			US268687								Maria Martinez		29/09/2021		Created new class: CustomerDataError
1.2         US505964        						Patricia Solano  	09/01/2023      Modify method getHGMCustomer_fw tho change namedCrName 
1.3         US517394        						Patricia Solano  	08/02/2023 		Modify method getHGMCustomer to control null responses
1.4         FIX        								Patricia Solano  	22/02/2023 		Modify method getSurveyId_fw to add triggerId, namedCrName in the callHttpService
1.5			US584558								Patricia Villacañas	09/05/2023		Added center parameter in method getHGMCustomer_fw
1.6        US540119        							Alexandre Perez		18/07/2023		Adapted to new body returned in the new NPS endpoint
***********************************************************************************************************************/
public with sharing class AV_HGM_Integration {

    private static final String AV_HGMSURVEY = 'AV_HGMSurvey';
	private static final String AV_HGMINVITE = 'AV_HGMInvite';

    private static final String PARAM_CUSTOMERINTERNALID  = 'x-absis-customerInternalId';

	private static final String AV_APP		= 'AV_CRM_Intouch';
	private static final String CIBE_APP_CIB	= 'CIBE_MisClientesCIB';
	private static final String CIBE_APP_EMP	= 'CIBE_MisClientesEMP';

    public class SurveyResponse {
		@AuraEnabled
		public String statusCode;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorCode;
		@AuraEnabled
		public SurveyData data;
	}

    public class SurveyData {
        @AuraEnabled
		public Integer surveyId;
		@AuraEnabled
		public String name;
    }

	public class CustomerResponse {
		@AuraEnabled
		public String statusCode;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorCode;
        @AuraEnabled
		public string discardReasonId;
		@AuraEnabled
		public String description;
	}

	public class ErrorData {
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorCode;
	}

	public class CustomerData {
        @AuraEnabled
		public String firstname;
		@AuraEnabled
		public String lastname;
		@AuraEnabled
		public String email;
		@AuraEnabled
		public String prefix;
		@AuraEnabled
		public String phone;
		@AuraEnabled
		public String language;
		@AuraEnabled
		public Date startDate;
		@AuraEnabled
		public Date endDate;
		@AuraEnabled
		public List<String> attributes;
    }

    /**
	 * @description	Recoge el SurveyId.
	 * @param triggerId		 	-> Identificación de encuesta
	 */
	public static SurveyResponse getSurveyId(String triggerId){

		SurveyResponse resultMethod = new SurveyResponse();
		String methodName = 'getSurveyId';
		CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_HGMSURVEY);
		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');

		//String mockString = '{"surveyId": 842982,"name": "Momento - Visita all-in-one (simple)"}';
		String endPoint=dataInterface.CC_EndPoint__c.replace('{triggerId}',triggerId);
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
            .setTimeOut(Integer.valueOf(dataInterface.CC_TimeOut__c))
			.setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(endPoint) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.addContentTypeJsonHeader()
			//.setHeaders()
			.debugMode()
			//.setDataMockup(mockString)
			.runCallout();

		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

		//Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();

		AV_LogDebug.printLogDebug(methodName, 'Request status: ' + +reqStatusOK);

		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();

		if (reqStatusOK){
			SurveyData bodyResponse = (AV_HGM_Integration.SurveyData)apiCallout.getBodyResponse('AV_HGM_Integration.SurveyData');
			resultMethod.data = bodyResponse;
		} else {
			ErrorData bodyResponse = (AV_HGM_Integration.ErrorData)apiCallout.getBodyResponse('AV_HGM_Integration.ErrorData');
			resultMethod.errorMessage = bodyResponse.errorMessage;
			resultMethod.errorCode = bodyResponse.errorCode;
		}

		AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
		return resultMethod;
	}

    /**
	 * @description	Recoge el SurveyId.
	 * @param triggerId		 	-> Identificación de encuesta
	 */

	public static SurveyResponse getSurveyId_fw(String triggerId){
		SurveyResponse resultMethod = new SurveyResponse();
		String methodName = 'getSurveyId_fw';
		String namedCrName = null;
		Map<String, String> mapHeader = new Map<String, String>();
		Map<String,Object> resBody = new Map<String,Object>();

		if(CIBE_AppUtilities.getAppDefinition()!=null && (CIBE_AppUtilities.getAppDefinition() == CIBE_APP_CIB || CIBE_AppUtilities.getAppDefinition() == CIBE_APP_EMP)) {
			namedCrName = 'CIBE_CSurvey_triggers';
		} else {
			namedCrName = 'AV_CSurvey_triggers';
		}
		HttpRequest frwReq = CBK_HttpServiceIntegration.getRequest(null, namedCrName, CIBE_AppConstants.GET, mapHeader);
		if(frwReq != null){
			//Sacamos del CS el endpoint cuyo name credential es el de la integración
			CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(namedCrName);
			//reemplazmos el employeeId
			String endpoint = wsc?.NamedCredential__c.replace('{triggerId}', triggerId);
			system.debug(methodName+ ' Endpoint: ' + endpoint);
			if(endpoint !=null){frwReq.setEndpoint(endpoint);}
			//Llamamos al callot del Framework con el endpoint corregido
			HttpResponse respuesta = CBK_HttpServiceIntegration.callHttpService(frwReq, triggerId, namedCrName);
			system.debug(methodName+ ' respuesta: ' + respuesta);

			if(respuesta!=null){
				system.debug(methodName+ 'resBody: ' + resBody);
				resBody = (Map<String,Object>) JSON.deserializeUntyped(respuesta.getBody());

				//Check errors:
				resultMethod.statusCode = String.ValueOf(respuesta.getStatusCode());
				resultMethod.errorMessage =(String)resBody.get(AV_IntegrationConstants.RESPONSE_REST_ERROR);
				resultMethod.errorCode = (String)resBody.get(AV_IntegrationConstants.RESPONSE_REST_STATUS_CODE);
				//Revisar reqStatusOK
				boolean reqStatusOK = CIBE_AppUtilities.checkErrorStatusCode(respuesta);
				system.debug(methodName+ 'reqStatusOK: ' + reqStatusOK);

				if(reqStatusOK){
					//SurveyData bodyResponse = (SurveyData)resBody.get('Data');
					SurveyData bodyResponse = new SurveyData();
					bodyResponse.surveyId = (Integer)resBody.get('surveyId');
					bodyResponse.name = (String)resBody.get('name');
					resultMethod.data = bodyResponse;	
					system.debug(methodName+ 'bodyResponse: ' + bodyResponse);
					system.debug(methodName+ 'resultMethod: ' + resultMethod);
					system.debug(methodName+ 'resultMethod.data: ' + resultMethod.data);
				}else{
					system.debug('KO: ');

					ErrorData bodyResponse = new ErrorData();
					bodyResponse.errorMessage = (String)resBody.get('errorMessage');
					bodyResponse.errorCode = (String)resBody.get('errorCode');	
					resultMethod.errorMessage = (String)resBody.get('errorMessage');
					resultMethod.errorCode = (String)resBody.get('errorCode');		
					system.debug('errorCode: '+resultMethod.errorCode);
					system.debug('resultMethod.errorMessage: '+resultMethod.errorMessage);
		
				}
			}
		}
		return resultMethod;
	}
	/**
	 * @description			 Invita a una cliente a participar en una encuesta en línea.
	 * @param userId		 	-> Identificación de cliente
	 * @param surveyId		 	-> Identificación de HGM
	 * @param datacliente	 	-> Datos del cliente para la encuesta
	 */
	public static CustomerResponse getHGMCustomer_fw(String userId, Integer surveyId, CustomerData datacliente, String center){	
		
		String methodName = 'getHGMCustomer_fw';
        CustomerResponse resultMethod = new CustomerResponse();
		String namedCrName = null;
		CustomerResponse bodyResponse = null;
		if(CIBE_AppUtilities.getAppDefinition()!=null && (CIBE_AppUtilities.getAppDefinition() == CIBE_APP_CIB || CIBE_AppUtilities.getAppDefinition() == CIBE_APP_EMP)) {
			namedCrName = 'CIBE_CSurvey_Survey';
		} else {
			namedCrName = 'AV_CSurvey_Survey';
		}
		Map<String, String> mapHeader = new Map<String, String>();
		Long longUser = long.valueOf(userId);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
		mapHeader.put(PARAM_CUSTOMERINTERNALID, hexDigest);
		mapHeader.put(AV_IntegrationConstants.HEADER_CONTENT_TYPE, AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON);
		AV_LogDebug.printLogDebug(methodName,'mapHeader: '+mapHeader);
		
        //Fill fix values (order by HGM API)
        if (datacliente!=null){
            List<String> listAttr = new List<String>();
            listAttr.add(center); 	//Always a number
            listAttr.add('1'); 		//Number or text fix
            listAttr.add('2'); 		//Number or text fix
            listAttr.add('3'); 		//Number or text fix
            listAttr.add('4'); 		//Number or text fix
            listAttr.add('5'); 		//Number or text fix
            listAttr.addAll(datacliente.attributes);
            datacliente.attributes = listAttr;
        }
		HttpRequest frwReq = CBK_HttpServiceIntegration.getRequest(System.JSON.serialize(datacliente), namedCrName, CIBE_AppConstants.POST, mapHeader);
		AV_LogDebug.printLogDebug(methodName,'frwReq: ' + frwReq);

		Map<String,Object> resBody = new Map<String,Object>();
		//String mockString = '{"firstname": "Phinehas","lastname": "Asel","email": "phinehas.asel@gmail.com","prefix": "0034","phone": "693825714","language": "es","startDate": "2021-05-01","endDate": "2021-05-31","attributes": ["03386","U0138145","1"]}';
        //String mockString = '{"errorMessage":"OK","errorCode":"000"}';
        if(frwReq != null){
			//Sacamos del CS el endpoint cuyo name credential es el de la integración
			CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(namedCrName);
			//reemplazmos el employeeId
			String endpoint = wsc?.NamedCredential__c.replace('{surveyId}', String.valueOf(surveyId));
			AV_LogDebug.printLogDebug(methodName,'Endpoint: ' + endpoint);
			if(endpoint !=null){frwReq.setEndpoint(endpoint);}
			//Llamamos al callot del Framework con el endpoint corregido
			HttpResponse respuesta = CBK_HttpServiceIntegration.callHttpService(frwReq);
			AV_LogDebug.printLogDebug(methodName,'respuesta: ' + respuesta);
			if(respuesta!=null){
				AV_LogDebug.printLogDebug(methodName,'respuesta body: ' + respuesta.getBody());
				if (respuesta.getBody() != null && respuesta.getBody()!= '') {
					resBody = (Map<String,Object>) JSON.deserializeUntyped(respuesta.getBody());
					system.debug(resBody);
					system.debug((Map<String,Object>)resBody.get('discardReason'));
					//Check errors:
					resultMethod.statusCode = String.ValueOf(respuesta.getStatusCode());
					resultMethod.errorMessage =(String)resBody.get(AV_IntegrationConstants.RESPONSE_REST_ERROR);
					resultMethod.errorCode = (String)resBody.get(AV_IntegrationConstants.RESPONSE_REST_STATUS_CODE);
					//Revisar reqStatusOK
					boolean reqStatusOK = CIBE_AppUtilities.checkErrorStatusCode(respuesta);
					if(reqStatusOK){
						try{
							Map<String,Object> discardReason = new Map<String,Object>();
							if(resBody.containsKey('discardReason')){
								discardReason = (Map<String,Object>)resBody.get('discardReason');
							}
							resultMethod.discardReasonId  = (string)discardReason.get('discardReasonId');
							resultMethod.description = (String)discardReason.get('description');
							resultMethod.errorMessage = resBody!= null && String.isNotBlank((String)discardReason.get('description')) ? (String)discardReason.get('description') : (String)discardReason.get('errorMessage');
							resultMethod.errorCode = resBody!= null && String.isNotBlank(String.valueOf(discardReason.get('discardReasonId'))) ? String.valueOf(discardReason.get('discardReasonId')) : String.valueOf(discardReason.get('errorCode'));
						}catch(AV_ApplicationException ex){
							AV_LogDebug.printLogDebug(methodName, 'Excepcion:: '+ex);
						}
					}else{
						resultMethod.statusCode  = (String)resBody.get('statusCode');
						resultMethod.errorMessage =  (String)resBody.get('errorMessage');
						resultMethod.errorCode = (String)resBody.get('errorCode');
					}
				} else {
					resultMethod.statusCode = String.ValueOf(respuesta.getStatusCode());
				}
			}

		}
		AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
		return resultMethod;
	}

	/**
	 * @description			 Invita a una cliente a participar en una encuesta en línea.
	 * @param userId		 	-> Identificación de cliente
	 * @param surveyId		 	-> Identificación de HGM
	 * @param datacliente	 	-> Datos del cliente para la encuesta
	 */
	public static CustomerResponse getHGMCustomer(String userId, Integer surveyId, CustomerData datacliente, String center){
		String methodName = 'getHGMCustomer';

        CustomerResponse resultMethod = new CustomerResponse();
		
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_HGMINVITE);
		AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
		AV_LogDebug.printLogDebug(methodName, '*****************************************');

        //Fill fix values (order by HGM API)
        if (datacliente!=null){
            List<String> listAttr = new List<String>();
            listAttr.add(center); 	//Always a number
            listAttr.add('1'); 		//Number or text fix
            listAttr.add('2'); 		//Number or text fix
            listAttr.add('3'); 		//Number or text fix
            listAttr.add('4'); 		//Number or text fix
            listAttr.add('5'); 		//Number or text fix
            listAttr.addAll(datacliente.attributes);
            datacliente.attributes = listAttr;
        }

		Map<String, String> mapHeader = new Map<String, String>();
		Long longUser = long.valueOf(userId);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
		mapHeader.put(PARAM_CUSTOMERINTERNALID, hexDigest);



		String endPoint=dataInterface.CC_EndPoint__c.replace('{surveyId}',String.valueOf(surveyId));
		//String mockString = '{"firstname": "Phinehas","lastname": "Asel","email": "phinehas.asel@gmail.com","prefix": "0034","phone": "693825714","language": "es","startDate": "2021-05-01","endDate": "2021-05-31","attributes": ["03386","U0138145","1"]}';
        //String mockString = '{"errorMessage":"OK","errorCode":"000"}';
        
		AV_ApiCallout apiCallout = new AV_ApiCallout()
			.setIsActive(dataInterface.CC_Activa__c)
			.setTimeOut(Integer.valueOf(dataInterface.CC_TimeOut__c))
            .setMethod(dataInterface.CC_TipoPeticion__c)
			.setEndpoint(endPoint) 
			.setCertificate(dataInterface.CC_Certificado__c)
			.addContentTypeJsonHeader()
			.setHeaders(mapHeader)
            .setBody(datacliente)
			.debugMode()
			//.setDataMockup(mockString)
			.runCallout();

		AV_LogDebug.printLogDebug(methodName, '*****************************************');
		AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

		resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        
        //Check errors:
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        AV_LogDebug.printLogDebug(methodName, 'Request status: ' + +reqStatusOK);
        if (reqStatusOK){
            CustomerResponse bodyResponse = null;
            try{
                bodyResponse = (AV_HGM_Integration.CustomerResponse)apiCallout.getBodyResponse('AV_HGM_Integration.CustomerResponse');
                resultMethod.errorMessage = bodyResponse!=null && String.isNotBlank(bodyResponse.description) ? bodyResponse.description : bodyResponse.errorMessage;
				resultMethod.errorCode = bodyResponse!=null && bodyResponse.discardReasonId!=null ? String.valueOf(bodyResponse.discardReasonId) : bodyResponse.errorCode;

            }catch(AV_ApplicationException ex){
				AV_LogDebug.printLogDebug(methodName, 'Excepcion: ' + ex);
            }
        }


		AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
		return resultMethod;
	}
}