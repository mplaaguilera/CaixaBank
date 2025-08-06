/**
 * @description       : 
 * @author            :  D. Elizama
 * @group             : 
 * @last modified on  : 26-05-2022
 * @last modified by  : fzaragoza
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   		      delizama   Initial Version
 * 1.1   25-05-2022   fzaragoza   Inclusión del registro en objeto CC_TrazaInt__c
**/
public abstract class CBK_HttpServiceIntegration_Abstract {
	public static void register(RestRequest  req) {
		CBK_log.debug('Register Integration Request:  ' + req, LoggingLevel.INFO);
		CBK_log.debug('Request Body: ' + req.requestBody.toString() + ' Url: ' + req.requestURI, LoggingLevel.INFO);
	}

	public static void register(RestResponse res) {
		CBK_log.debug('Register Integration Response:  ' + res, LoggingLevel.INFO);
		CBK_log.debug('Response Body: ' + res.responseBody.toString() + ' Status: ' + res.statusCode , LoggingLevel.INFO);
	}

	public static void register(RestRequest  req, RestResponse res,Datetime dtStart, DateTime dtStop, String identificador, String configInt) {
		CBK_log.debug('Register Integration Request:  ' + req, LoggingLevel.INFO);
		CBK_log.debug('Request Body: ' + req.requestBody.toString() + ' Url: ' + req.requestURI, LoggingLevel.INFO);
		CBK_log.debug('Register Integration Response:  ' + res, LoggingLevel.INFO);
		CBK_log.debug('Response Body: ' + res.responseBody.toString() + ' Status: ' + res.statusCode , LoggingLevel.INFO);

		Boolean registroTraza = false;
		CBK_IntegrationSetting__c wsc = String.isNotBlank(configInt) ? CBK_IntegrationSetting__c.getValues(configInt) : null;
		registroTraza = wsc != null ? wsc.RegistroTrazaIntegracion__c : false;
		if (wsc == null) {
			List<CBK_IntegrationSetting__c> lstWsc = CBK_IntegrationSetting__c.getAll().values();
			for (CBK_IntegrationSetting__c intSetting : lstWsc){
				if(req.resourcePath == '/services/apexrest/' + intSetting.ResourcePath__c){
					wsc = intSetting;
					registroTraza = intSetting.RegistroTrazaIntegracion__c;
					break;
				}
			}
		}

		if (wsc != null && registroTraza) {
			CC_TrazaInt__c registroIntegracion = new CC_TrazaInt__c ();
			registroIntegracion.Name = wsc.Name.length() > 80 ? wsc.Name.substring(0, 79) : wsc.Name;//req.resourcePath.length() > 80 ? req.resourcePath.substring(0, 79) : req.resourcePath;
			registroIntegracion.CC_Identificador__c =  String.isNotBlank(identificador) ? identificador : req.resourcePath.length() > 100 ? req.resourcePath.substring(0, 99) : req.resourcePath;
			registroIntegracion.CC_FechaInicio__c = dtStart;
			registroIntegracion.CC_FechaFin__c = dtStop;
			registroIntegracion.CC_MensajeEntrada__c = req.requestBody.toString();
			if ((res.statusCode == CBK_ServiceRestManager.CORRECT_STATUS_CODE)){
				registroIntegracion.CC_FinOK__c = true;
				registroIntegracion.CC_MensajeSalida__c = res.responseBody.toString();
			}else{
				registroIntegracion.CC_FinOK__c = false;
				registroIntegracion.CC_DetalleError__c = res.responseBody.toString();
			}
			insert registroIntegracion;	
		}
	}
}