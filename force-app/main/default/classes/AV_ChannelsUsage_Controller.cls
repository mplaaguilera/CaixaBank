/**********************************************************************************************************************
Name:	  AV_ChannelsUsage_Controller
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Controller for the LWC av_ChannelsUsage
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY							   AUTHOR			  DATE				Description
1.0			SF - Integración con API's de Canales  Sandra Gómez		  08/04/2021		Init version
1.1		    AV_Query IT	                           Daniel Rodríguez	  04/02/2022	    Change AV_Query to SOQL for User and Account
1.2         US477490                               Elisabeth R.       20/01/2023        Changed Response wrapper

***********************************************************************************************************************/
public with sharing class AV_ChannelsUsage_Controller {

    public class Response {
		@AuraEnabled
		public String severity;
		@AuraEnabled
		public String descError;
		@AuraEnabled
		public Map<String, List<String>> nameValueMap;

		public Response() {
			severity = AV_AppConstants.OK;
		}
	}

    /**
	 * @description	 Retrieve the treatments of the customer
	 * @param   recordId  -> SF Identifier of the customer
	 */
	@AuraEnabled
	public static Response getChannels(String recordId) {
		Response resp = new Response();
		String methodName = 'getChannels';
        try{
            Account acc = [Select Id, AV_Numperso__c, AV_FechaRefrescoCanales__c, AV_JSONCanales__c From Account Where Id = :recordId limit 1];
            /*Account acc = (Account)new AV_Query('Account')
                                .selectFields('Id, AV_Numperso__c, AV_FechaRefrescoCanales__c, AV_JSONCanales__c')
                                .addConditionEq('Id', recordId)
                                .fetch();*/
            boolean statusOK = true;
            if (acc==null || String.isBlank(acc.AV_Numperso__c)){
                resp.severity = AV_AppConstants.ERROR;
                String msg = Label.AV_GDPR_ErrorNumper;
                resp.descError = Label.AV_UnknownError + AV_AppConstants.BREAK_LINE + msg;
                AV_LogDebug.printLogDebug(methodName, msg);
                statusOK = false;
            }
            
            if (statusOK){
                String numper = acc.AV_Numperso__c;
                Long hours = 0;
                if(acc.AV_FechaRefrescoCanales__c != Null){
                    hours = AV_AppUtilities.calculateTimeDifferences(acc.AV_FechaRefrescoCanales__c, DateTime.now());
                }
                if(String.isBlank(acc.AV_JSONCanales__c) || (acc.AV_FechaRefrescoCanales__c != null && hours>24)) {
                    AV_Canales_Integration.ChannelResponse dataChannel = AV_Canales_Integration.getChannels(numper);
                    if (dataChannel !=null && !AV_IntegrationConstants.HTTP_STATUS_OK.equalsIgnoreCase(dataChannel.StatusCode)){
                        resp.severity = AV_AppConstants.ERROR;
                        String msg = dataChannel.errorCode + ' - ' + dataChannel.errorMessage;
                        resp.descError = Label.AV_UnknownError + msg;
                        AV_LogDebug.printLogDebug(methodName, msg);
                    } else {
                        resp.nameValueMap = dataChannel.nameValueMap;
                        if('200'.equalsIgnoreCase(dataChannel.StatusCode)){
                            acc.AV_JSONCanales__c =  JSON.serialize(resp);
                            acc.AV_FechaRefrescoCanales__c = Datetime.now();
                            Database.update(acc);
                        }
                    }
                    AV_LogDebug.printLogDebug(methodName, '********************++++++++++++++++++++++++');
                    AV_LogDebug.printLogDebug(methodName, resp.toString());
                }else{
                    Type typeClass = Type.forName('AV_ChannelsUsage_Controller.Response');
                    AV_ChannelsUsage_Controller.Response avConsent = (AV_ChannelsUsage_Controller.Response)JSON.deserializeStrict(acc.AV_JSONCanales__c, typeClass);
                    resp = avConsent;
                }
            }
        }catch(Exception e){
            AV_LogDebug.printException(methodName, e);
            resp.severity = AV_AppConstants.ERROR;
            resp.descError = Label.AV_UnknownError + AV_AppConstants.BREAK_LINE + e.getMessage();
        }
		return resp;
	}
}