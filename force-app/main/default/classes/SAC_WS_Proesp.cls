/**
*   @author     	IBM
*   @since      	Jan, 2022
*   @description	Clase del servicio de SAC para PROESP
*   @history    	Jan, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_Proesp{

	private static final String SAC_PROESP   = 'SAC_Proesp';
    private static final String SPV_PROESP   = 'SPV_Proesp';

	public class ProespResponse {

		@AuraEnabled
        public String statusCode;
		@AuraEnabled
        public String errorMessage;
		@AuraEnabled
        public String errorCode;
		@AuraEnabled
        public List<SAC_WS_Proesp_RP.ClaimWrapper> proesp;
    }

	/**
		* @description invocacion del servicio de Antecedentes para proesp
		* @param reqWrapper : wrapper con los datos de la request
	*/
	public static List<SAC_WS_Proesp_RP.ClaimWrapper> sendRequest(SAC_WS_Proesp_RQ.RequestWrapper reqWrapper, String perfilUser){
		
		CC_TrazaInt__c oTraza 			  = new CC_TrazaInt__c();
		ProespResponse responseProesp 	  = new ProespResponse();
		String jsonBody					  = reqWrapper.serialize();
		String metadataProesp = '';
		if(perfilUser == 'SPV_General'){
            metadataProesp = SPV_PROESP;
        }else{
            metadataProesp = SAC_PROESP;
        
        }

		CC_InterfaceSettings__mdt oConfig = SAC_Utils.getInterfazConfigBody (metadataProesp);
		
		if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
			oTraza = new CC_TrazaInt__c();
			oTraza.Name = metadataProesp;
			oTraza.CC_Identificador__c = jsonBody;
			oTraza.CC_FechaInicio__c = datetime.now();
		}

		//HEADERS
		Map< String, String > mapHeaders	= new Map< String, String >();
		mapHeaders.put( 'x-absis-auto-profile', 'CBK;OFFICE' );
		mapHeaders.put( 'Content-Type', 'application/json' );
		
		//REQUEST
		CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
		reqWap.body = jsonBody;
		reqWap.intSetting = metadataProesp;
		reqWap.method = oConfig.CC_TipoPeticion__c;
		reqWap.mHeaders = mapHeaders;
		
		HttpRequest request = CBK_HttpServiceIntegration.getRequest(reqWap);
		
		if (oConfig.CC_TrazaEntrada__c){
			oTraza.CC_MensajeEntrada__c = request.toString();
		}

		//RESPONSE
		HTTPResponse response = CBK_HttpServiceIntegration.multiCallHttpService(request, jsonBody, metadataProesp);
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
		
		if(statusCode.equalsIgnoreCase('200')){
			String responseBody = response.getbody();
            responseProesp.proesp = (List<SAC_WS_Proesp_RP.ClaimWrapper>)getBodyResponse(responseBody, 'List<SAC_WS_Proesp_RP.ClaimWrapper>');
            responseProesp.statusCode = statusCode;
			responseProesp.proesp[0].setTraza(oTraza);
        }else{
			String responseBody = response.getbody();
			responseProesp.statusCode = statusCode;
            responseProesp.errorCode = 'Error en el servicio.';
            responseProesp.errorMessage = response.getStatus();
			
			SAC_WS_Proesp_RP.ClaimWrapper responseTrazas = new SAC_WS_Proesp_RP.ClaimWrapper(oTraza);
			
			List<SAC_WS_Proesp_RP.ClaimWrapper> resWrapper = new List<SAC_WS_Proesp_RP.ClaimWrapper>();
			resWrapper.add(responseTrazas);
			
			return resWrapper;	 
        } 
        return responseProesp.proesp;		
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