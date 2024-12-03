public  class NIS_CALL_WS_Adobe {
    public static CBK_HttpServiceIntegration.RequestWapper reqWrapper  { get; set; }

    public NIS_CALL_WS_Adobe(CBK_HttpServiceIntegration.RequestWapper fwkIntWrapper) {
        reqWrapper = fwkIntWrapper;
        callAdobeService();
    }

    private static void callAdobeService(){

        System.debug('Input: ' + reqWrapper);
        
        HttpRequest req =  CBK_HttpServiceIntegration.getRequest(reqWrapper);
        HttpResponse resp = CBK_HttpServiceIntegration.callHttpService(req, 'CSBD_WS_ADOBE_CAMPAIGN', reqWrapper.intSetting);

        System.debug('Rsponse: ' + resp);
    }
}