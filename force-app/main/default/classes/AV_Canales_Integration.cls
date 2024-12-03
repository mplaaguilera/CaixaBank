/**********************************************************************************************************************
Name:      AV_Canales_Integration
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con CLI para la ficha de cliente
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION        USER_STORY                             AUTHOR              DATE                Description
1.0            SF - Integración con API's de CLI      Sandra Gómez        06/04/2021          Init version
1.1            US477490                               Elisabeth R.        20/01/2023          Changed structure of callout response

***********************************************************************************************************************/
public with sharing class AV_Canales_Integration {

    private static final String AV_CANALES   = 'AV_Canales';
    private static final String PARAM_USERID_OLD   = 'x-absis-customerInternalId';

    public class ChannelResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public Map<String, List<String>> nameValueMap;
    }

    public class Metric {
        @AuraEnabled
        public String metricName;
        @AuraEnabled
        public String metricValue;
        @AuraEnabled
        public String metricTime;
        @AuraEnabled
        public String metricDescription;
    }
    public class ChannelError {
        @AuraEnabled
        public DataError result;
    }

    public class DataError {
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String code;
    }

    public static ChannelResponse getChannels(String userId){

		ChannelResponse resultMethod = new ChannelResponse();
		String methodName = 'getChannels';

            CBK_IntegrationSetting__c dataInterface = [SELECT NamedCredential__c FROM CBK_IntegrationSetting__c WHERE Name='AV_Channels'];

			Map<String, String> mapHeader = new Map<String, String>();
			Long longUser = long.valueOf(userId);
			String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
			mapHeader.put(PARAM_USERID_OLD,hexDigest);

			AV_ApiCallout apiCallout = new AV_ApiCallout()
                .setIsActive(true)
				.setMethod('GET')
				.setEndpoint(dataInterface.NamedCredential__c)  
				.setCertificate('MisClientes_2wSSL')
				.addContentTypeJsonHeader()
				.setHeaders(mapHeader)
				.debugMode()
				.runCallout();
				
			AV_LogDebug.printLogDebug(methodName, '*****************************************');
			AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
			
			//Check errors:
			boolean reqStatusOK = apiCallout.checkErrorStatusCode();
			resultMethod.statusCode = apiCallout.getStatusCodeResponse();
			resultMethod.errorMessage = apiCallout.getErrorResponse();
			resultMethod.errorCode = apiCallout.getStatusCodeResponse();

			if (reqStatusOK){
                String responseString = apiCallout.getBodyResponse();

                Map<String, List<Metric>> metricMap = (Map<String, List<Metric>>)JSON.deserialize(responseString, Map<String, List<Metric>>.class);

                List<Metric> metricsResult = new List<Metric>();
                metricsResult = (List<Metric>)metricMap.get('Metrics');
                Map<String, List<String>> nameValueTimeDescriptionMap = new Map<String, List<String>>();
                for(Metric mt : metricsResult){
                    List<String> valueTimeDecriptionList  = new List<String>();
                    valueTimeDecriptionList.add(mt.metricValue);
                    valueTimeDecriptionList.add(mt.metricTime);
                    valueTimeDecriptionList.add(mt.metricDescription);

                    nameValueTimeDescriptionMap.put(mt.metricName, valueTimeDecriptionList);
                }
                resultMethod.nameValueMap = nameValueTimeDescriptionMap;
			} else {
                ChannelError bodyResponse = (AV_Canales_Integration.ChannelError)apiCallout.getBodyResponse('AV_Canales_Integration.ChannelError');
                resultMethod.errorMessage = bodyResponse.result.description;
                resultMethod.errorCode = bodyResponse.result.code;
            }

		AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
		return resultMethod;
	}
}