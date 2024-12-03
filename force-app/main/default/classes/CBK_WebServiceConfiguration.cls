public class CBK_WebServiceConfiguration {

	//GET SERVICE CONFIGURATION
	public static CBK_IntegrationSetting__c getConfiguration(String serviceName)
	{
		CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(serviceName);
		
		CBK_log.debug('Integration Setting: ' + wsc, LoggingLevel.INFO);

		return wsc;
	}

	//GET ACCESS TOKEN
	//public static String getAccessToken(String serviceName, Boolean forceRefreshToken)
	//{
		//string accessToken = '';

		//try {
			//CBK_IntegrationSetting__c config = CBK_WebServiceConfiguration.getConfiguration(serviceName);
			//CBK_log.debug('WEB SERVICE SETTING: ' + config, LoggingLevel.INFO);

			//String keyServiceName = 'local.CBKCache.' + serviceName + 'AccessToken';

			//if (cache.Org.contains(keyServiceName) && !forceRefreshToken) {
				//CBK_log.debug('ENTER EXIST TOKEN: ' + 'Bearer ' + (string) cache.Org.get(keyServiceName), LoggingLevel.INFO);

				//return 'Bearer ' + (string) cache.Org.get(keyServiceName);
			//}
		
			//if (config != null) {

				//CBK_log.debug('ENTER NOT EXIST TOKEN: ' + config, LoggingLevel.INFO);

				//string client_id = config.ClientId__c;
				//string client_secret = config.ClientSecret__c;
				//string scope = config.Scope__c;
				//string grant_type = config.GrantType__c;
				//string authUrl = config.AuthUrl__c;

				//List<String> urlParams = new List<String> {
					//'grant_type=' + EncodingUtil.urlEncode(grant_type, 'UTF-8'),
					//'scope=' + EncodingUtil.urlEncode(scope, 'UTF-8'),
					//'client_id=' + EncodingUtil.urlEncode(client_id, 'UTF-8'),
					//'client_secret=' + EncodingUtil.urlEncode(client_secret, 'UTF-8')
				//};

				//Http h = new Http();
				//HttpRequest req = new HttpRequest();
				//req.setEndpoint(authUrl);
				//req.setMethod('POST');
				//req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
				//String body = String.join(urlParams, '&');
				//req.setBody(body);

				//HttpResponse res = h.send(req);
				//Map<String, String> mapToken = (Map<String, String>) (JSON.deserialize(res.getBody(), Map<String, String>.class));

				//if (res.getStatusCode() == CBK_ServiceRestManager.CORRECT_STATUS_CODE)
				//{
					//Integer expires = Integer.valueOf(mapToken.get('expires_in'));
					//expires = (expires - 300) <= 300 ? 300 : expires - 300;
					//accessToken = mapToken.get('access_token');

					//if (accessToken == '' || accessToken == null) {
						//throw new CBK_WebServiceConfiguration.WebServiceConfigurationException('Received null token');
					//} else {
						////SET Cache
						//Cache.Org.put(keyServiceName, accessToken, expires, Cache.Visibility.ALL, true);
					//}
				//}else
					//throw new CBK_ServiceRestManager.BadResponseException(res.getBody(), res.getStatus(), res.getStatusCode());
			//} else {
				//throw new CBK_WebServiceConfiguration.WebServiceConfigurationException('Not exist configuration for this application: ' + serviceName);
			//}
		//} catch(Exception ex) {
			//String textEx = '(Exception) GetToken: ' + ex.getTypeName() + ' message: ' + ex.getMessage();
			//CBK_log.error(ex, textEx);

		//}
		//return 'Bearer ' + accessToken;
	//}
}