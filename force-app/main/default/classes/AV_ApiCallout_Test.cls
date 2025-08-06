/**********************************************************************************************************************
Name:	  AV_ApiCallout_Test
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de test para AV_ApiCallout
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Text Class		Esperanza Conde 	17/03/2020		Init version

***********************************************************************************************************************/
@isTest
public class AV_ApiCallout_Test {
    
    @isTest
    public static void testIsActiveError(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setIsActive(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testIsActive(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        AV_ApiCallout result = controller.setIsActive(true); 
        System.AssertEquals(true, result.isActive);
        Test.stopTest();
    }
    
    @isTest
    public static void testSetMethodFail(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setMethod(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testSetMethod(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        AV_ApiCallout result = controller.setMethod('GET'); 
        System.AssertEquals('GET', result.method);
        Test.stopTest();
    }
    
    @isTest
    public static void testSetEndpointNull(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setEndpoint(''); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testSetEndpointNotHTTP(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        AV_ApiCallout result = controller.setEndpoint('TestCallOut'); 
        System.AssertEquals('callout:TestCallOut', result.endpoint);
        Test.stopTest();
    }
    
    @isTest
    public static void testAddHeaderKeyNull(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.addHeader(Null, AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testAddHeaderVarNull(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.addHeader(AV_IntegrationConstants.HEADER_CONTENT_TYPE, Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testAddHeader(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        AV_ApiCallout result = controller.addHeader(AV_IntegrationConstants.HEADER_CONTENT_TYPE, AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON); 
        system.AssertEquals(AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON, result.headers.get(AV_IntegrationConstants.HEADER_CONTENT_TYPE));
        Test.stopTest();
    }
    
    @isTest
    public static void testSetHeadersNull(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setHeaders(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testSetHeaders(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(AV_IntegrationConstants.HEADER_CONTENT_TYPE, AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON);
        AV_ApiCallout result = controller.setHeaders(mapHeader); 
        system.AssertEquals(AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON, result.headers.get(AV_IntegrationConstants.HEADER_CONTENT_TYPE));
        Test.stopTest();
    }
    
    @isTest
    public static void testaddContentTypeJsonHeader(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(AV_IntegrationConstants.HEADER_CONTENT_TYPE, AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON);
        AV_ApiCallout result = controller.addContentTypeJsonHeader(); 
        system.AssertEquals(mapHeader, result.headers);
        Test.stopTest();
    }
    
    @isTest
    public static void testaddContentTypeXmlHeader(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(AV_IntegrationConstants.HEADER_CONTENT_TYPE, AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_XML);
        AV_ApiCallout result = controller.addContentTypeXmlHeader(); 
        system.AssertEquals(mapHeader, result.headers);
        Test.stopTest();
    }
    
    @isTest
    public static void testaddAuthorizationBasicHeaderNull(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.addAuthorizationBasicHeader(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testaddAuthorizationBasicHeader(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(AV_IntegrationConstants.HEADER_AUTHORIZATION, AV_IntegrationConstants.HEADER_AUTHORIZATION_VALUE_BASIC + 'tokenUser');
        AV_ApiCallout result = controller.addAuthorizationBasicHeader('tokenUser'); 
        system.AssertEquals(mapHeader, result.headers);
        Test.stopTest();
    }
    
    public static void testaddAuthorizationBearerHeaderNull(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.addAuthorizationBearerHeader(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testaddAuthorizationBearerHeader(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(AV_IntegrationConstants.HEADER_AUTHORIZATION, AV_IntegrationConstants.HEADER_AUTHORIZATION_VALUE_BEARER + 'tokenUser');
        AV_ApiCallout result = controller.addAuthorizationBearerHeader('tokenUser'); 
        system.AssertEquals(mapHeader, result.headers);
        Test.stopTest();
    }
    
    @isTest
    public static void testaddUsernameHeader(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(AV_IntegrationConstants.HEADER_USERNAME, System.UserInfo.getUserName());
        AV_ApiCallout result = controller.addUsernameHeader(); 
        system.AssertEquals(mapHeader, result.headers);
        Test.stopTest();
    }
    
    @isTest
    public static void testsetDataMockupNull(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setDataMockup(''); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testsetTimeoutpNull(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setTimeout(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testsetTimeout(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        AV_ApiCallout result = controller.setTimeout(60000); 
        System.AssertEquals(60000, result.timeOut);
        Test.stopTest();
    }
    
    @isTest
    public static void testrunCalloutFail(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            controller.endpoint = Null;
            AV_ApiCallout result = controller.runCallout(); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testcertificateFail(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setCertificate(''); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testsetbody(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        controller.setEndpoint('TestCallOut');
        controller.setIsActive(true);
        controller.setMethod('GET'); 
        controller.setBody(Blob.valueOf('{Test}'));
        controller.setDataMockup('TestMockup');
        AV_ApiCallout result = controller.runCallout();
        
        system.assertEquals('TestMockup', result.response.get(AV_IntegrationConstants.RESPONSE_REST_BODY));
        String body = controller.getBodyResponse();
        system.assertEquals('TestMockup', body);
        try{
            Object objectBody = controller.getBodyResponse('TestMockup');
            Dom.Document doc = controller.getBodyResponseDocument();
        }catch(Exception e){

        }
        Test.stopTest();
        
    }
    
    @isTest
    public static void testsetBodyFail(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setBody(Null); 
            String body = controller.getBodyResponse();
            
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testsetExportFullResponseFail(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setExportFullResponse(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testsetExportBodyAsBlobFail(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.setExportBodyAsBlob(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testaddQueryStringFail(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            AV_ApiCallout result = controller.addQueryString(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testaddQueryStringFailEnp(){
        
        Test.startTest();	
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            controller.setEndpoint('TestCallOut'); 
            AV_ApiCallout result = controller.addQueryString(Null); 
        }catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments:') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testaddQueryString(){
        
        Map<String,String> params = new Map<String,String>();
        params.put('key','Id');
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        controller.setEndpoint('TestCallOut'); 
        AV_ApiCallout result = controller.addQueryString(params); 
        system.AssertEquals('callout:TestCallOut?key=Id', result.endpoint);
        Test.stopTest();
    }
    
    @isTest
    public static void testdebugMode(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        controller.print();
        controller.debugMode(); 
        system.AssertEquals(true, controller.debugMode);
        Test.stopTest();
    }
    
    @isTest
    public static void testcheckError(){
        
        Test.startTest();	
        
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            Boolean isTrue = controller.checkErrorStatusCode(); 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No response data found') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void teststatusError(){
        
        Test.startTest();	
        
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            Boolean isTrue = controller.checkErrorStatusCode(Null); 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void teststatusError2(){
        
        Set<String> setString = new Set<String>();
        setString.add('id');
        
        Test.startTest();	
        
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            controller.response = Null;
            controller.checkErrorStatusCode(setString); 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No response data found') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testgetStatusCodeResponse(){
        
        Test.startTest();	
        
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            controller.response = Null;
            controller.getStatusCodeResponse(); 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No response data found') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testgetStatusResponse(){
        
        Test.startTest();	
        
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            controller.response = Null;
            controller.getStatusResponse(); 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No response data found') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testgetErrorResponse(){
        
        Test.startTest();	
        
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            controller.response = Null;
            controller.getErrorResponse(); 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No response data found') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest();
    }
    
    @isTest
    public static void testgetMsgUserError(){
        
        Test.startTest();	
        
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            controller.response = Null;
            controller.getMsgUserError(); 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No response data found') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest(); 
    }
    
    @isTest
    public static void testgetBodyResponseDocument(){
        
        Test.startTest();	
        
        try{
            AV_ApiCallout controller = new AV_ApiCallout();
            controller.response = Null;
            controller.getBodyResponseDocument(); 
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No response data found') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        Test.stopTest(); 
    }
    
    @isTest
    public static void testgetDefaultMsgError(){
        
        Test.startTest();	
        AV_ApiCallout.ErrorMessage error = AV_ApiCallout.getDefaultMsgError(Label.AV_UnknownError); 
        system.assertEquals(AV_AppConstants.ERROR, error.severity);
        Test.stopTest(); 
    }
    
    @isTest
    public static void testIsnotActive(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        controller.setEndpoint('TestCallOut');
        controller.setIsActive(true);
        controller.setMethod('GET'); 
        controller.setBody(Blob.valueOf('{Test}'));
        controller.setDataMockup('TestMockup');
        controller.isActive = false;
        
        try{
            AV_ApiCallout result = controller.runCallout();   
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('The API callout is not active') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void testResponseDoc(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        controller.setEndpoint('TestCallOut');
        controller.setIsActive(true);
        controller.setMethod('GET'); 
        controller.setBody(Blob.valueOf('{Test}'));
        controller.setDataMockup('TestMockup');
        AV_ApiCallout result = controller.runCallout();
        
        system.assertEquals('TestMockup', result.response.get(AV_IntegrationConstants.RESPONSE_REST_BODY));
        
        try{
            Dom.Document body = controller.getBodyResponseDocument();    
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Failed to parse XML') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    @isTest
    public static void testResponseDoctrue(){
        
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        controller.setEndpoint('TestCallOut');
        controller.setIsActive(true);
        controller.setMethod('GET'); 
        controller.setBody(Blob.valueOf('{Test}'));
        controller.setDataMockup('TestMockup');
        AV_ApiCallout result = controller.runCallout();
        system.assertEquals('TestMockup', result.response.get(AV_IntegrationConstants.RESPONSE_REST_BODY));
        Map<String, Object> result2 = controller.getResponse();
        
        try{
            controller.exportFullResponse = true;
            Dom.Document body = controller.getBodyResponseDocument();    
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('The body response is empty') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    @isTest
    public static void testsetMockUpFail(){
        
        String dataMockup = '';
        Test.startTest();	
        AV_ApiCallout controller = new AV_ApiCallout();
        
        try{
            controller.setDataMockup(dataMockup);
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Illegal Arguments') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    @isTest
	public static void testOK() {
		
		String userId = '13550';

		Test.startTest();		
		Test.setMock(HttpCalloutMock.class, new AV_MockCallout_Test('CLI_SIGNALDATA','OK'));
		AV_FichaCliente_Integration.SignalsResponse signalsResponse = AV_FichaCliente_Integration.getSignals(userId);		
		Test.stopTest();
		System.assertEquals('200', signalsResponse.statusCode);
	}
    
}