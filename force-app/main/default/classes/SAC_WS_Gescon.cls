/**
*   @author     	IBM
*   @since      	Jan, 2022
*   @description	Clase del servicio de SAC para Antecedentes de Gescon
*   @history    	Jan, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_Gescon{

	private static final String SAC_GESCON   = 'SAC_Gescon';
    private static final String SPV_GESCON   = 'SPV_Gescon';

	public class GesconResponse {

		@AuraEnabled
        public String statusCode;
		@AuraEnabled
        public String errorMessage;
		@AuraEnabled
        public String errorCode;
		@AuraEnabled
        public List<SAC_WS_Gescon_RP.ClaimWrapper> gescon;
    }

	/**
		* @description invocacion del servicio de Antecedentes para ATR
		* @param reqWrapper : wrapper con los datos de la request
	*/
	public static List<SAC_WS_Gescon_RP.ClaimWrapper> sendRequest( SAC_WS_Gescon_RQ.RequestWrapper reqWrapper, String perfilUser){
		
		CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
		String jsonBody						= reqWrapper.serialize();
		String metadataGescon = '';
		if(perfilUser == 'SPV_General'){
            metadataGescon = SPV_GESCON;
        }else{
            metadataGescon = SAC_GESCON;
        
        }
		CC_InterfaceSettings__mdt oConfig   = SAC_Utils.getInterfazConfigBody (metadataGescon);
		GesconResponse responseGescon	    = new GesconResponse();

		if (oConfig.CC_TrazaActiva__c || Test.isRunningTest()){
			oTraza = new CC_TrazaInt__c();
			oTraza.Name = metadataGescon;
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
		reqWap.intSetting = metadataGescon;
		reqWap.method = oConfig.CC_TipoPeticion__c;
		reqWap.mHeaders = mapHeaders;
		
		HttpRequest request = CBK_HttpServiceIntegration.getRequest(reqWap);

		if (oConfig.CC_TrazaEntrada__c){
			oTraza.CC_MensajeEntrada__c = request.toString();
		}

		//RESPONSE
		HTTPResponse response = CBK_HttpServiceIntegration.multiCallHttpService(request, jsonBody, metadataGescon);
		String statusCode = String.valueOf(response.getStatusCode());
		
		if ((oConfig.CC_TrazaActiva__c || Test.isRunningTest()) && oTraza != null)
		{
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
            responseGescon.gescon = (List<SAC_WS_Gescon_RP.ClaimWrapper>)getBodyResponse(responseBody, 'List<SAC_WS_Gescon_RP.ClaimWrapper>');
            responseGescon.statusCode = statusCode;
			responseGescon.gescon[0].setTraza(oTraza);
        }else{
			String responseBody = response.getbody();
			responseGescon.statusCode = statusCode;
            responseGescon.errorCode = 'Error en el servicio.';
            responseGescon.errorMessage = response.getStatus();
			SAC_WS_Gescon_RP.ClaimWrapper responseTrazas = new SAC_WS_Gescon_RP.ClaimWrapper(oTraza);
			List<SAC_WS_Gescon_RP.ClaimWrapper> resWrapper = new List<SAC_WS_Gescon_RP.ClaimWrapper>();
			resWrapper.add(responseTrazas);
			return resWrapper;	 
        } 
        return responseGescon.gescon;	
	}


	private static Object getBodyResponse(String response, String clazzName){
        Object result = parseJsonToObject(response, clazzName);
        return result;   
    }

    private static Object parseJsonToObject(String jsonData, String jsonType){
        Type typeClass = Type.forName(jsonType);
        return System.JSON.deserializeStrict(jsonData, typeClass);
    }
}