@RestResource(urlMapping = '/getSession')
global with sharing class CBK_WS_Control_IPS_GetSession extends CBK_HttpServiceIntegration_Abstract{
    @HttpGet
	global static void getSessionId(){
        Datetime dtStart = Datetime.now();
        RestRequest req = RestContext.request;
        RestResponse restResponse = RestContext.response;
        outPutId sesId = new outPutId();
        try{
            restResponse.addHeader('Content-Type', 'application/json; charset=utf-8');
            String host = URL.getSalesforceBaseUrl().getHost();
            if (host.contains('sandbox') || Test.isRunningTest()){
                sesId.sessionId = UserInfo.getOrganizationId() + UserInfo.getSessionId().substring(15);
                restResponse.statusCode = CBK_ServiceRestManager.CORRECT_STATUS_CODE;
                if (String.isBlank(sesId?.sessionId)){
                    sesId.sessionId = '';
                }  
		        restResponse.responseBody = Blob.valueOf(JSON.serialize(sesId));
                Datetime dtStop = Datetime.now();
                register(req, restResponse, dtStart, dtStop, req.resourcePath, 'WS Entornos INTs IPS');
            }
        }catch(Exception e){
            CBK_log.error(e, 'Error WS CBK_WS_Control_IPS_GetSession - ' + JSON.serialize(sesId));
        }
    }

    public class outPutId {
		public string sessionId { get; set; }
	}
}