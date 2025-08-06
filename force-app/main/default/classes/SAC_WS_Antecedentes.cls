/**
*   @author     	IBM
*   @since      	Jan, 2022
*   @description	Clase del servicio de SAC para Antecedentes
*   @history    	Jan, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_Antecedentes{

	private static final String SAC_ANTECEDENTES   = 'SAC_Antecedentes';
    private static final String SPV_ANTECEDENTES   = 'SPV_Antecedentes';

	public class AntecedentesResponse {

		@AuraEnabled
        public String statusCode;
		@AuraEnabled
        public String errorMessage;
		@AuraEnabled
        public String errorCode;
        @AuraEnabled
        public CC_TrazaInt__c traza;
		@AuraEnabled
        public List<SAC_WS_Antecedentes_RP.ClaimWrapper> antecedentes;
    }

	public static SAC_WS_Antecedentes.AntecedentesResponse sendRequest(SAC_WS_Antecedentes_RQ.RequestWrapper reqWrapper, String perfilUser){
		
		CC_TrazaInt__c oTraza 					  = new CC_TrazaInt__c();
		AntecedentesResponse responseAntecedentes = new AntecedentesResponse();
		String jsonBody						 	  = reqWrapper.serialize();
		String metadataAntecedente = '';
		if(perfilUser == 'SPV_General'){
            metadataAntecedente = SPV_ANTECEDENTES;
        }else{
            metadataAntecedente = SAC_ANTECEDENTES;
        
        }

		system.debug('Espe '+metadataAntecedente);

		CC_InterfaceSettings__mdt oConfig    	  = SAC_Utils.getInterfazConfigBody(metadataAntecedente);

		if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
			oTraza = new CC_TrazaInt__c();
			oTraza.Name = metadataAntecedente;
			oTraza.CC_Identificador__c = jsonBody;
			oTraza.CC_FechaInicio__c = datetime.now();
		}

		//HEADERS
		Map<String, String> mapHeaders = new Map<String, String>();
		mapHeaders.put('x-absis-auto-profile', 'CBK;OFFICE');
		mapHeaders.put('Content-Type', 'application/json');

		//REQUEST
		CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
		reqWap.body = jsonBody;
		reqWap.intSetting = metadataAntecedente;
		reqWap.method = oConfig.CC_TipoPeticion__c;
		reqWap.mHeaders = mapHeaders;
		
		HttpRequest request = CBK_HttpServiceIntegration.getRequest(reqWap);

		if (oConfig.CC_TrazaEntrada__c){
			oTraza.CC_MensajeEntrada__c = request.toString();
		}

		//RESPONSE
		HTTPResponse response = CBK_HttpServiceIntegration.callHttpService(request, jsonBody, metadataAntecedente);
		String statusCode = String.valueOf(response.getStatusCode());	

		if ((oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null){
			oTraza.CC_FechaFin__c = datetime.now();

			if (oConfig.CC_TrazaSalida__c || Test.isRunningTest()){
				oTraza.CC_MensajeSalida__c = response.getBody().left(32700);
			}
			if (response.getStatusCode() != 200)
			{
				oTraza.CC_FinOK__c = false;
			}else{
				oTraza.CC_FinOK__c = true;
			}

		}
		responseAntecedentes.statusCode = statusCode;
		if(statusCode.equalsIgnoreCase('200')){
			String responseBody = response.getbody();
            responseAntecedentes.antecedentes = (List<SAC_WS_Antecedentes_RP.ClaimWrapper>)getBodyResponse(responseBody, 'List<SAC_WS_Antecedentes_RP.ClaimWrapper>');
			responseAntecedentes.antecedentes[0].setTraza(oTraza);
        }else{
            responseAntecedentes.errorCode = 'Error en el servicio.';
            responseAntecedentes.errorMessage = response.getStatus(); 
        }
        
        responseAntecedentes.traza = oTraza;
        return responseAntecedentes;	
	}

	
    private static Object getBodyResponse(String response, String clazzName){
        Object result = parseJsonToObject(response, clazzName);
        return result;   
    }


    private static Object parseJsonToObject(String jsonData, String jsonType){
        Type typeClass = Type.forName(jsonType);
        return System.JSON.deserialize(jsonData, typeClass);
    }
}