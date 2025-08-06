/**********************************************************************************************************************
Name:	  AV_IntegrationUtilities_Test
Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de test para AV_IntegrationUtilities
=======================================================================================================================
Historial
---------------------
VERSION		USER_STORY		AUTHOR				DATE			Description
1.0			Text Class		Esperanza Conde 	21/03/2020		Init version
1.0			Text Class		Álvaro López     	29/09/2020		Update content

***********************************************************************************************************************/
@isTest
public class AV_IntegrationUtilities_Test {
    
    public class RequestTest {
        public String request1; 
        public String request2; 
    } 
    public class OtherException extends Exception {}

    
    @isTest
    public static void testJSON(){
        
        RequestTest request = new RequestTest();
        request.request1 = 'Test1';
        request.request2 = 'Test2';
        
        Test.startTest();	
        String result = AV_IntegrationUtilities.parseObjectToJson(request); 
        System.Assert(result.contains('Test1'));
        System.Assert(result.contains('Test2'));
        
        Test.stopTest();
    }
    
    @isTest
    public static void testExecute(){
        
        Date dateValue = Date.newInstance(1960, 2, 17);
        Map<String,String> params = new Map<String,String>();
        params.put('key','test');
        
        Test.startTest();	
        String result = AV_IntegrationUtilities.formatDate(dateValue, 'YYYY-MM-DD'); 
        System.AssertEquals('1960-02-48', result);
        Boolean isBoolean = AV_IntegrationUtilities.statusHeapSize();
        System.Assert(true);
		String endpoint = AV_IntegrationUtilities.getEndpoint('TestEndpoint');
        System.AssertEquals('callout:TestEndpoint', endpoint);
        String query = AV_IntegrationUtilities.addQueryString(endpoint,params);
        System.AssertEquals('callout:TestEndpoint?key=test', query);
        CC_InterfaceSettings__mdt metadata = AV_IntegrationUtilities.fetchMetadataInterface('AV_C2C');
        System.AssertEquals('AV_C2C', metadata.DeveloperName);
        Test.stopTest();
    }
    
    @isTest
    public static void testError(){
        OtherException extensionTest = new OtherException();
        AV_ApiCallout apiCall = new AV_ApiCallout();
        //apiCall.ErrorMessage.msg = 'Error';
        
        Test.startTest();	
        List<String> errorList = AV_IntegrationUtilities.handleExceptionError('notMethod',extensionTest);
        System.AssertEquals('error',errorList.get(0));
        try{
         	List<String> errorHandlerList = AV_IntegrationUtilities.handleErrorMessages('notMethod', apiCall);
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('No response data found') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        Test.stopTest();
    }
    
    /*@isTest
    public static void testAddDomXmlNode(){
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_Webex_CreateMeeting');
        String bodyRequest = dataInterface.CC_Body__c;
        Dom.Document result = new Dom.Document();
        result.load(bodyRequest);
        Dom.XmlNode envelope = result.getRootElement();
        Dom.XmlNode bodyContent = envelope.getChildElement('body', null).getChildElement('bodyContent', null);        
        Test.startTest();	
        Dom.XmlNode accessControl = AV_IntegrationUtilities.addDomXmlNode(bodyContent, 'accessControl', null, null, '');
        Dom.XmlNode num = AV_IntegrationUtilities.addDomXmlNode(bodyContent, 'accessControl', null, null, 1);
        Dom.XmlNode booleano = AV_IntegrationUtilities.addDomXmlNode(bodyContent, 'accessControl', null, null, true);
        Test.stopTest();
    }*/


    @isTest
    public static void testConvertToHexadecimal(){
        Test.startTest();
        String result = AV_IntegrationUtilities.convertToHexadecimal(Long.valueOf('13550'));
        System.assertEquals('34EE', result);
        Test.stopTest();
    }

    @isTest
    public static void testLeftPadZero(){
        Test.startTest();
        String result = AV_IntegrationUtilities.leftPadZero('1', 3);
        System.assertEquals('001', result);
        Test.stopTest();
    }

    @isTest
    public static void testParseJsonToObject(){
        Test.startTest();
        String bodyResponse = AV_MockCallout_Test.RESPONSE_CLI_CUSTOMMERDATA;
        AV_FichaCliente_Integration.CustomerData result = (AV_FichaCliente_Integration.CustomerData)AV_IntegrationUtilities.parseJsonToObject(bodyResponse, 'AV_FichaCliente_Integration.CustomerData');
        System.assertEquals(13550, result.customerInternalId);
        Test.stopTest();
    }

}