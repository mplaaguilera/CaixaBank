/**
 * @description       : 
 * @author            : D. Elizama
 * @group             : 
 * @last modified on  : 26-05-2022
 * @last modified by  : fzaragoza
 * Modifications Log
 * Ver   Date         Author      Modification
 * 1.0   		      delizama   Initial Version
 * 1.1   25-05-2022   fzaragoza   Inclusión del registro en objeto CC_TrazaInt__c
**/
public class CBK_HttpServiceIntegration {
	public class HttpServiceIntegrationException extends Exception { }

	public static Integer multiCall = 0;
	public static HttpRequest requestWrp;
	public static HttpResponse responseWrp;
	public static String configSetting;
	public static Map<string, RegistroTrazaWrapper> mResultTraza = new Map<string, RegistroTrazaWrapper>();
	private static Map<HttpRequest, Map<String,String>> headerByRequest = new Map<HttpRequest, Map<String,String>>();

	public static HttpRequest getRequest(String body, String intSetting, String method, Map<String, string> mHeaders) {
		CBK_CheckCustomSettingIntegration__mdt mcm = CBK_CheckCustomSettingIntegration__mdt.getInstance('ControlDate_ParamsWithReferences');
		CBK_IntegrationSetting__c wsc = CBK_WebServiceConfiguration.getConfiguration(intSetting);
		if (wsc.CreatedDate > mcm.CBK_ControlDate__c){
			throw new CBK_HttpServiceIntegration.HttpServiceIntegrationException('Método deprecado getRequest(String body, String intSetting, String method, Map<String, string> mHeaders)');
		}
		return getRequest(body, intSetting, method, mHeaders, false, false, new  Map<String, string>(), new Map<String, string>());
	}

	//Para Request con/sin uri params y/o query params
	public static HttpRequest getRequest(String body, String intSetting, Map<String, string> mHeaders, Map<String, String> mUriParams, Map<String, String> mQueryParams) {
		CBK_CheckCustomSettingIntegration__mdt mcm = CBK_CheckCustomSettingIntegration__mdt.getInstance('ControlDate_ParamsWithReferences');
		CBK_IntegrationSetting__c wsc = CBK_WebServiceConfiguration.getConfiguration(intSetting);
		if (wsc.CreatedDate > mcm.CBK_ControlDate__c){
			throw new CBK_HttpServiceIntegration.HttpServiceIntegrationException('Método deprecado getRequest(String body, String intSetting, Map<String, string> mHeaders, Map<String, String> mUriParams, Map<String, String> mQueryParams');
		}
		return getRequest(body, intSetting, '', mHeaders, false, false,mUriParams, mQueryParams);
	}

	public static HttpRequest getRequest(RequestWapper reqWrp){
		//return getRequest(reqWrp.body, reqWrp.intSetting, reqWrp.method, reqWrp.mHeaders, false, false, reqWrp.mUriParams, reqWrp.mQueryParams);
		HttpRequest request = new HttpRequest();

		try {
			CBK_IntegrationSetting__c wsc = CBK_WebServiceConfiguration.getConfiguration(reqWrp.intSetting);
			if (wsc == null || String.isBlank(wsc.NamedCredential__c)){
				throw new CBK_HttpServiceIntegration.HttpServiceIntegrationException('Integration Setting was not defined for the specified configuration.');
			}

			string vUrl = wsc.NamedCredential__c;
			request.setEndpoint(vUrl);

			if ((reqWrp.mUriParams != null  && !reqWrp.mUriParams.isEmpty()) || (reqWrp.mQueryParams != null && !reqWrp.mQueryParams.isEmpty())){
				request.setEndpoint(createUrlWithParams(vUrl, reqWrp.mUriParams, reqWrp.mQueryParams));
			}

			if(String.isNotBlank(reqWrp.method)){
				request.setMethod(reqWrp.method);
			}else if(String.isNotBlank(wsc.CBK_Method__c)){
				request.setMethod(wsc.CBK_Method__c);
			}

			if(reqWrp.bodyBlob != null){
				request.setBodyAsBlob(reqWrp.bodyBlob);
			}else if(String.isNotBlank(reqWrp.body)){
				request.setBody(reqWrp.body);
			}

			if (String.isNotBlank(wsc.CBK_ContentType__c)){
				reqWrp.mHeaders.put('Content-Type', wsc.CBK_ContentType__c);
			}
			
			for (string st : reqWrp.mHeaders.keySet()){
				request.setHeader(st, reqWrp.mHeaders.get(st));
				CBK_log.debug('Request - Headers: '+ st + ' : ' + reqWrp.mHeaders.get(st), LoggingLevel.INFO);
			}

			if (String.isNotBlank(String.valueOf(wsc.CBK_TimeOut__c))){
				request.setTimeout(Integer.valueOf(wsc.CBK_TimeOut__c));
			}else{
				request.setTimeout(120000);
			}

			CBK_log.debug('Request:  ' + request, LoggingLevel.INFO);
			CBK_log.debug('Request - Body:  ' + reqWrp.body, LoggingLevel.INFO);

		} catch(Exception ex) {
			request = null;
			CBK_log.error(ex, 'Error : CBK_HttpServiceIntegration - getRequest()' + ex.getMessage());	
		}

		if(reqWrp.mHeaders != null){
			headerByRequest.put(request, reqWrp.mHeaders);
		}

		requestWrp = new HttpRequest();
		requestWrp = request;
		return request;
	}
	
	private static HttpRequest getRequest(String body, String intSetting, String method, Map<String, string> mHeaders, Boolean oAuth2, Boolean refreshToken, Map<String, string> mUriParams, Map<String, string> mQueryParams) {
		HttpRequest request = new HttpRequest();
		configSetting = intSetting; //Guardamos el valor para poder utilizarlo en el callHttpService
		RequestWapper requestWrp = new RequestWapper();
		requestWrp.body = body;
		requestWrp.intSetting = intSetting;
		requestWrp.method = method;
		requestWrp.mHeaders = mHeaders;
		requestWrp.mUriParams = mUriParams;
		requestWrp.mQueryParams = mQueryParams;

		return getRequest(requestWrp);
	}

	//Metodo deprecado
	public static HttpResponse callHttpService(HttpRequest request) {
		Http http = new Http();
		HttpResponse response = new HttpResponse();
		Datetime dtStart;
		DateTime dtStop;
		CBK_CheckCustomSettingIntegration__mdt mcm = CBK_CheckCustomSettingIntegration__mdt.getInstance('Control_Date');
			try {
				dtStart = Datetime.now();
				CBK_IntegrationSetting__c wsc = CBK_WebServiceConfiguration.getConfiguration(configSetting);
				if (wsc.CreatedDate > mcm.CBK_ControlDate__c){
					throw new CBK_HttpServiceIntegration.HttpServiceIntegrationException('Método deprecado callHttpService(HttpRequest request).');
				}
				response = http.send(request);
				dtStop = Datetime.now();
				CBK_log.debug('Response:  ' + response, LoggingLevel.INFO);

				if (response.getStatusCode() >= CBK_ServiceRestManager.CORRECT_STATUS_CODE && response.getStatusCode() <= CBK_ServiceRestManager.CORRECT_STATUS_CODE_ACCEPTED_MAX_RANGE){
					CBK_log.debug('Response OK: Status = ' + response.getStatusCode() + ' Body = ' + response.getBody() , LoggingLevel.INFO);
				}else{
					CBK_log.debug('Response KO:  Status = ' + response.getStatusCode() + ' Body = ' + response.getBody() , LoggingLevel.INFO);
					throw new CBK_ServiceRestManager.BadResponseException(response.getBody(), response.getStatus(), response.getStatusCode());
				}
			} catch(Exception ex) {
				CBK_log.error(ex, 'Error : CBK_HttpServiceIntegration ' + ex.getMessage());
			}
			CBK_HttpServiceIntegration.registroTrazaIntegracion(request,response, dtStart,dtStop, '','');
		return response;
	}

	public static HttpResponse callHttpService(HttpRequest request, String identificador, String configInt){
		Http http = new Http();
		HttpResponse response = new HttpResponse();
		Datetime dtStart;
		DateTime dtStop;
		CBK_CheckCustomSettingIntegration__mdt mcm = CBK_CheckCustomSettingIntegration__mdt.getInstance('Control_Date');
		CBK_IntegrationSetting__c wsc = CBK_WebServiceConfiguration.getConfiguration(configInt);

		try {
			dtStart = Datetime.now();
			multiCall++;
			if (wsc.CreatedDate > mcm.CBK_ControlDate__c && multiCall > 1){
				throw new CBK_HttpServiceIntegration.HttpServiceIntegrationException('Método deprecado para llamadas multiples - callHttpService(HttpRequest request, String identificador, String configInt). Utilice los nuevos métodos para multillamada - "multiCallHttpService(HttpRequest request, String identificador, String configInt)" y para registro de trazas - "registroTrazaIntegracion()"');
			}

			response = http.send(request);
			dtStop = Datetime.now();
			CBK_log.debug('Response:  ' + response, LoggingLevel.INFO);

			if (response.getStatusCode() >= CBK_ServiceRestManager.CORRECT_STATUS_CODE && response.getStatusCode() <= CBK_ServiceRestManager.CORRECT_STATUS_CODE_ACCEPTED_MAX_RANGE){
				CBK_log.debug('Response OK: Status = ' + response.getStatusCode() + ' Body = ' + response.getBody() , LoggingLevel.INFO);
			}else{
				CBK_log.debug('Response KO:  Status = ' + response.getStatusCode() + ' Body = ' + response.getBody() , LoggingLevel.INFO);
				throw new CBK_ServiceRestManager.BadResponseException(response.getBody(), response.getStatus(), response.getStatusCode());
			}
		} catch(Exception ex) {
			CBK_log.error(ex, 'Error : CBK_HttpServiceIntegration ' + ex.getMessage());
		}
		CBK_HttpServiceIntegration.registroTrazaIntegracion(request,response, dtStart,dtStop,identificador, configInt);
		return response;
	}

	//nuevo metodo multillamada para registrar trazas de integracion
	public static HttpResponse multiCallHttpService(HttpRequest request, String identificador, String configInt){
		Http http = new Http();
		HttpResponse response = new HttpResponse();
		Datetime dtStart;
		DateTime dtStop;
		try {
			dtStart = Datetime.now();
			response = http.send(request);
			responseWrp = response;
			multiCall++;
			dtStop = Datetime.now();
			CBK_log.debug('Response:  ' + response, LoggingLevel.INFO);

			// informacion traza
			RegistroTrazaWrapper rw = new RegistroTrazaWrapper();		
			rw.requestInt = requestWrp;
			rw.responsetInt = responseWrp;
			rw.configIntegration = string.isNotBlank(configInt) ? configInt : '';
			rw.identificador = string.isNotBlank(identificador) ? identificador : '';
			rw.startWr = dtStart;
			rw.stopWr = dtStop;
			mResultTraza.put(String.valueOf(multiCall), rw);
			//

			if (response.getStatusCode() >= CBK_ServiceRestManager.CORRECT_STATUS_CODE && response.getStatusCode() <= CBK_ServiceRestManager.CORRECT_STATUS_CODE_ACCEPTED_MAX_RANGE){
				CBK_log.debug('Response OK: Status = ' + response.getStatusCode() + ' Body = ' + response.getBody() , LoggingLevel.INFO);
			}else{
				CBK_log.debug('Response KO:  Status = ' + response.getStatusCode() + ' Body = ' + response.getBody() , LoggingLevel.INFO);
				throw new CBK_ServiceRestManager.BadResponseException(response.getBody(), response.getStatus(), response.getStatusCode());
			}
		} catch(Exception ex) {
			CBK_log.error(ex, 'Error : CBK_HttpServiceIntegration ' + ex.getMessage());
		}
		return response;
	}

	//nuevo metodo para registrar trzas en multillamadas
	public static void registroTrazaIntegracion(){
		
		CC_TrazaInt__c registroIntegracion; 
		List<CC_TrazaInt__c> lstRegInt = new List<CC_TrazaInt__c>();
		Boolean registroTraza = false;
		
		for(String key : mResultTraza.keySet()){
			RegistroTrazaWrapper infoTraza  = mResultTraza.get(key);
			CBK_IntegrationSetting__c wsc = String.isNotBlank(infoTraza.configIntegration) ? CBK_IntegrationSetting__c.getValues(infoTraza.configIntegration) : null;
			registroTraza = wsc != null ? wsc.RegistroTrazaIntegracion__c : false;
			if (wsc != null && registroTraza) {
				registroIntegracion = new CC_TrazaInt__c ();
				registroIntegracion.Name = wsc.Name.length() > 80 ? wsc.Name.substring(0, 79) : wsc.Name;
				registroIntegracion.CC_Identificador__c = String.isNotBlank(infoTraza.identificador) ? infoTraza.identificador : wsc.NamedCredential__c.length() > 100 ? wsc.NamedCredential__c.substring(0, 99) : wsc.NamedCredential__c;
				registroIntegracion.CC_FechaInicio__c = infoTraza.startWr;
				registroIntegracion.CC_FechaFin__c = infoTraza.stopWr;
				registroIntegracion.CC_MensajeEntrada__c = infoTraza?.requestInt?.toString().left(32760);
				registroIntegracion.CBK_Body__c = infoTraza?.requestInt?.getBody()?.left(32760);

				if(infoTraza.responsetInt.getStatusCode() >= CBK_ServiceRestManager.CORRECT_STATUS_CODE && infoTraza.responsetInt.getStatusCode() <= CBK_ServiceRestManager.CORRECT_STATUS_CODE_ACCEPTED_MAX_RANGE){
					registroIntegracion.CC_FinOK__c = true;
					registroIntegracion.CC_MensajeSalida__c = infoTraza?.responsetInt?.getBody()?.left(32760);
				}else{
					registroIntegracion.CC_FinOK__c = false;
					registroIntegracion.CC_DetalleError__c = infoTraza?.responsetInt?.getBody()?.left(32760);
				}
				lstRegInt.add(registroIntegracion);
			}
		}
		if(lstRegInt.size() > 0){
			Database.SaveResult[] srList = Database.insert(lstRegInt,false);
			CBK_log.debug('Insertado de Trazas de integración = ' + JSON.serialize(srList) , LoggingLevel.INFO);
		}
	}

	public static void registroTrazaIntegracion(HttpRequest request,HttpResponse response,Datetime dtStart,DateTime dtStop, String identificador, String configInt) {
		// validamos del metadato si se requiere registro en CC_Traza_Int
		Boolean registroTraza = false;
		CBK_IntegrationSetting__c wsc = String.isNotBlank(configInt) ? CBK_IntegrationSetting__c.getValues(configInt) : null;
		registroTraza = wsc != null ? wsc.RegistroTrazaIntegracion__c : false;
		if (wsc == null) {
			List<CBK_IntegrationSetting__c> lstWsc = CBK_IntegrationSetting__c.getAll().values();
			for (CBK_IntegrationSetting__c intSetting : lstWsc){
				if(request?.getEndpoint()?.equals(intSetting.NamedCredential__c)){
					wsc = intSetting;
					registroTraza = intSetting.RegistroTrazaIntegracion__c;
					break;
				}
			}
		}

		if (wsc != null && registroTraza) {
			CC_TrazaInt__c registroIntegracion = new CC_TrazaInt__c ();
			registroIntegracion.Name = wsc.Name.length() > 80 ? wsc.Name.substring(0, 79) : wsc.Name;
			registroIntegracion.CC_Identificador__c = String.isNotBlank(identificador) ? identificador : wsc.NamedCredential__c.length() > 100 ? wsc.NamedCredential__c.substring(0, 99) : wsc.NamedCredential__c;
			registroIntegracion.CC_FechaInicio__c = dtStart;
			registroIntegracion.CC_FechaFin__c = dtStop;
			registroIntegracion.CC_MensajeEntrada__c = request?.toString().left(32760);
			registroIntegracion.CBK_Body__c = request?.getBody()?.left(32760);

			if(wsc.CBK_Traza_Envio_Header__c && headerByRequest.containsKey(request)){
				
				String headerCompleto = '';
				for (HttpRequest req : headerByRequest.keySet()) {
					//headerCompleto = headerCompleto + ' - ' + req;
					Map<String, String> headers = headerByRequest.get(req);
					for (String key : headers.keySet()) {
						String value = headers.get(key);
						headerCompleto = headerCompleto + ' - ' + key + ' - ' + value;
					}
				}

				registroIntegracion.CBK_Datos_Envio__c = headerCompleto.left(10000);
			}

			if(wsc.CBK_Traza_Respuesta_Header__c){
				for (String keyHeader : response.getHeaderKeys()) {
					registroIntegracion.CBK_Datos_Respuesta__c =  ' ' + keyHeader + ': ' + response.getHeader(keyHeader);
				}
				if (registroIntegracion.CBK_Datos_Respuesta__c <> null) {
					registroIntegracion.CBK_Datos_Respuesta__c = registroIntegracion.CBK_Datos_Respuesta__c.left(10000);
				}
				
			}

			if(response.getStatusCode() >= CBK_ServiceRestManager.CORRECT_STATUS_CODE && response.getStatusCode() <= CBK_ServiceRestManager.CORRECT_STATUS_CODE_ACCEPTED_MAX_RANGE){
				registroIntegracion.CC_FinOK__c = true;
				registroIntegracion.CC_MensajeSalida__c = response?.getBody()?.left(32760);
			}else{
				registroIntegracion.CC_FinOK__c = false;
				registroIntegracion.CC_DetalleError__c = response?.getBody()?.left(32760);
			}
			insert registroIntegracion;	
		}
	}

	public static string createUrlWithParams(string vUrl, Map<String, String> mUriParams, Map<String, String> mQueryParams){
		String urlparams = vUrl;

		if (mUriParams != null){
			for (String key : mUriParams.keySet()){
				urlparams = urlparams.replace('{'+key+'}', mUriParams.get(key));	
			}
		}

		List<String> params = new List<String>();
		if(mQueryParams != null){
			for (String key2 : mQueryParams.keySet()){
				params.add(EncodingUtil.urlEncode(key2, 'UTF-8') + '=' + EncodingUtil.urlEncode(mQueryParams.get(key2), 'UTF-8'));
			}
		}

		if (params.size() > 0){
			urlparams += '?' + String.join(params, '&');
		}
		return urlparams;
	}

	public class RegistroTrazaWrapper{
		public HttpRequest requestInt{ get; set; }
		public HttpResponse responsetInt{ get; set; }
		public String configIntegration { get; set; }
		public String identificador { get; set; }
		public Datetime startWr { get; set; }
		public Datetime stopWr { get; set; }
    }

	public class RequestWapper{
		public String body { get; set; }
		public Blob bodyBlob { get; set; }
		public String intSetting { get; set; }
		public String method { get; set; }
		public Map<String, string> mHeaders { get; set; }
		public Map<String, string> mUriParams { get; set; }
		public Map<String, string> mQueryParams { get; set; }

		public RequestWapper() {
			this.bodyBlob = null;
			this.mHeaders = new Map<String, string>();
			this.mUriParams = new Map<String, string>();
			this.mQueryParams = new Map<String, string>();
		}
	}
}