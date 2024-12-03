/**********************************************************************************************************************
Name:      AV_GDPR_Integration
Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Integración con CLI para la ficha de cliente
=======================================================================================================================
Historial
---------------------
VERSION        USER_STORY                               AUTHOR              DATE                Description
1.0            SF - Integración con API's de CLI      Esperanza Conde       27/07/2020          Init version
1.1            SF - Integración con API's de CLI      David Rufo            16/09/2020          Update class for retrieve the treatments
1.2            US246780                               Sandra Gómez          18/08/2021          new version
1.3			   										  Vladislav Lityagin	14/03/2023			Added new method checkTreatmentsFw

***********************************************************************************************************************/
public with sharing class AV_GDPR_Integration {

    private static final String AV_GDPR = 'AV_GDPR';

    public class GDPRResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public GDPR data;
    }

    public class GDPR {
        @AuraEnabled
        public String treatmentId;
        @AuraEnabled
        public String isResult;
        @AuraEnabled
        public Integer userId;
        @AuraEnabled
        public List<ConsentsList> consentList;
    }
    
    public class ErrorData {
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorCode;
	}

    public class ConsentsList implements Comparable {
        @AuraEnabled
        public Integer consentId; 
        @AuraEnabled
        public String consentDesc;
        @AuraEnabled
        public String isConsent;
        @AuraEnabled
        public String consentContent;
        
        public Integer compareTo(Object compareTo) {
            ConsentsList compareToEmp = (ConsentsList)compareTo;
            if (consentId == compareToEmp.consentId){
                return 0;
            }
            if (consentId > compareToEmp.consentId) {
                return -1;
            }
            return 1;
        }
    }

    public class GDPR_Error {
        public String status;
        public String errorCode;
        public String errorMessage;
        public String title; 
        public String detail;
        public List<Object> stackTrace;
        public String type;
    }


    public static GDPRResponse checkTreatmentsFw(String treatmentId, String appCode, String userId, String applicantId){
        GDPRResponse resultMethod = new GDPRResponse();
        String methodName = 'checkTreatmentsFw';
        Map<String, String> mapHeader = new Map<String, String>();
		Map<String,Object> resBody = new Map<String,Object>();
        String csGdpr = 'AV_GDPR';
        Long longUser = long.valueOf(userId);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
		mapHeader.put('x-absis-customerInternalId',hexDigest);
        mapHeader.put('x-absis-externalId',applicantId);

        HttpRequest frwReq = CBK_HttpServiceIntegration.getRequest(null, csGdpr, CIBE_AppConstants.GET, mapHeader);
        if(frwReq != null){
            //Sacamos del CS el endpoint cuyo name credential es el de la integración
			CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(csGdpr);
			String endpoint = wsc?.NamedCredential__c+'?treatmentId='+treatmentId+'&appCode='+appCode;
		
			if(endpoint !=null){frwReq.setEndpoint(endpoint);}
			//Llamamos al callot del Framework con el endpoint corregido
			HttpResponse respuesta = CBK_HttpServiceIntegration.callHttpService(frwReq/*, userId, csGdpr*/);//@@@ probar solo con fwReq
            if(respuesta!=null){
				resBody = (Map<String,Object>) JSON.deserializeUntyped(respuesta.getBody());

				//Check errors:
				resultMethod.statusCode = String.ValueOf(respuesta.getStatusCode());
				resultMethod.errorMessage =(String)resBody.get('detail');
				resultMethod.errorCode = String.ValueOf(respuesta.getStatusCode());
				//Revisar reqStatusOK
				boolean reqStatusOK = CIBE_AppUtilities.checkErrorStatusCode(respuesta);
   
				if(reqStatusOK){
					GDPR bodyResponse = new GDPR();
					bodyResponse.treatmentId = (String)resBody.get('treatmentId');
					bodyResponse.isResult = String.ValueOf(resBody.get('isResult'));
                    bodyResponse.userId = (Integer)resBody.get('userId');
                    // Obtener la respuesta del servicio web
                    String response = String.valueOf(resBody.get('consentList'));
            
                    // Remover los paréntesis y separar los objetos individuales
                    String consentStrings = response.replace('{', '{"').replace('=', '"=').replace(', ', ', "').replace('=', ':').replace(', "{', ', {').replace('(', '[').replace(')', ']');
                
                    // Asignar la lista de objetos 'ConsentsList' al atributo 'consentList' de 'bodyResponse'
                    //bodyResponse.consentList = consentList;
                    bodyResponse.consentList = (List<ConsentsList>)JSON.deserialize(consentStrings, List<ConsentsList>.class);
					resultMethod.data = bodyResponse;	
				}else{
					ErrorData bodyResponse = new ErrorData();
					bodyResponse.errorMessage = resultMethod.errorMessage;
					bodyResponse.errorCode = resultMethod.errorCode;
				}
			}
        }
        
        return resultMethod;
    }

    //Datos de prueba: AV_GDPR_Integration.checkTreatments('0001-A', 'GCC', '12542', 'U0185227');
    /**
     * @description             Gestiona las validaciones de consentimientos GDPR para ejecutar un tratamiento de una persona. Apificación de Portero. 
     * @param treatmentId    -> Identificador del tratamiento (longitud 6)
     * @param appCode        -> Código de la aplicación invocante
     * @param userId         -> Identificación de cliente (NUMPER)
     * @param applicantId    -> Empleado que consulta los consentimientos (U01)
     */
    public static GDPRResponse checkTreatments(String treatmentId, String appCode, String userId, String applicantId){
        GDPRResponse resultMethod = new GDPRResponse();
        String methodName = 'checkTreatments';
   
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_GDPR);
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');

        String endpoint = dataInterface.CC_EndPoint__c +'?treatmentId='+treatmentId+'&appCode='+appCode;
        AV_LogDebug.printLogDebug(methodName, 'Endpoint : '+endpoint);

        Map<String, String> mapHeader = new Map<String, String>();
        Long longUser = long.valueOf(userId);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
		mapHeader.put('x-absis-customerInternalId',hexDigest);
        mapHeader.put('x-absis-externalId',applicantId);
        
        AV_LogDebug.printLogDebug(methodName, 'Header: '+mapHeader);

        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endpoint)
            .setCertificate(dataInterface.CC_Certificado__c)
            .addContentTypeJsonHeader()
            .setHeaders(mapHeader)
            .debugMode()
            //.setDataMockup('{"treatmentId": "0001-A", "result": "true", "userId": 12542, "consentsList": [{"consentId": 3, "isConsent": "true"},{"consentId": 1, "isConsent": "false"},{"consentId": 4, "isConsent": "true"},{"consentId": 5, "isConsent": "true"},{"consentId": 6, "isConsent": "true"},{"consentId": 7, "isConsent": "true"},{"consentId": 9, "isConsent": "true"}]}')
            .runCallout();

        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

        //Check errors:
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();

        if (reqStatusOK){
            GDPR bodyResponse = (AV_GDPR_Integration.GDPR)apiCallout.getBodyResponse('AV_GDPR_Integration.GDPR');
            resultMethod.data = bodyResponse;
        }else{
            GDPR_Error bodyResponse = (AV_GDPR_Integration.GDPR_Error)apiCallout.getBodyResponse('AV_GDPR_Integration.GDPR_Error');
            if (bodyResponse!=null && String.isNotBlank(bodyResponse.detail)){
                resultMethod.errorMessage = bodyResponse.detail;
            	resultMethod.errorCode = bodyResponse.status;
            }else{
            	resultMethod.errorMessage = bodyResponse.errorMessage;
            	resultMethod.errorCode = bodyResponse.errorCode;
            }
        }

        AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
        return resultMethod;
    }
 
   
}