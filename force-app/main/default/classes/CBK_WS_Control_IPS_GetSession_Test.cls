@isTest
public class CBK_WS_Control_IPS_GetSession_Test {
    @isTest
	public static void wsGetSession(){
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/getSession'; 
        req.httpMethod = 'GET';
        RestContext.request = req;

        RestResponse res = new RestResponse();
        RestContext.response = res;
        CBK_WS_Control_IPS_GetSession.outPutId output;
        CBK_WS_Control_IPS_GetSession.getSessionId();
    
        output = (CBK_WS_Control_IPS_GetSession.outPutId) JSON.deserialize(
        res.responseBody.toString(),
        CBK_WS_Control_IPS_GetSession.outPutId.class);
        System.assertEquals(CBK_ServiceRestManager.CORRECT_STATUS_CODE, res.statusCode);
    }
}