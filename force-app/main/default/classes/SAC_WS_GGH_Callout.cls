/**
*   @author     	IBM
*   @since      	May, 2022
*   @description	Clase del servicio de SAC para GGH
*   @history    	May, 2022 - IBM - Create Apex Class 
*/
public with sharing class SAC_WS_GGH_Callout{

	private static final String SAC_GGH_CALLOUT   = 'SAC_GGH_Callout';
    private static final String SPV_GGH_CALLOUT  = 'SPV_GGH_Callout';

	/**
		* @description invocacion del servicio de GGH
		* @param reqWrapper : wrapper con los datos de la request
	*/
	public static SAC_WS_GGH_Callout_RP.GGHResponse sendRequest( SAC_WS_GGH_Callout_RQ.GGHRequest reqWrapper, String perfilUser ){
		CC_TrazaInt__c oTraza = new CC_TrazaInt__c();
		String gghCallout = '';
        
        if(perfilUser == 'SPV_General'){
            gghCallout = SPV_GGH_CALLOUT;
        }else{
            gghCallout = SAC_GGH_CALLOUT;
        
        }

		Id userId = UserInfo.getUserId();
            

		Map< String, String > mapHeaders	= new Map< String, String >();
		mapHeaders.put( 'x-absis-auto-profile', 'CBK;OFFICE' );
		mapHeaders.put( 'Content-Type', 'application/json' );

		CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
		reqWap.body = reqWrapper.serialize();
		reqWap.intSetting = gghCallout;
		reqWap.method = 'POST';
		reqWap.mHeaders = mapHeaders;
			
		HttpRequest request = CBK_HttpServiceIntegration.getRequest(reqWap);

		HTTPResponse response = CBK_HttpServiceIntegration.callHttpService(request, userId, gghCallout);

		SAC_WS_GGH_Callout_RP.GGHResponse resWrapper = SAC_WS_GGH_Callout_RP.deserialize( response.getBody() );
		resWrapper.setTraza(oTraza);
		return resWrapper;

	}
}