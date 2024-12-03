/**********************************************************************************************************************
 Name:      AV_C2C_Controller
 Copyright © 2019  CaixaBank
=======================================================================================================================
Proposito: Integración con Rainbow para la funcionalidad de Click-to-Call (C2C)
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            C2C Callout      David Rufo       11/02/2020          Init version
   1.1            C2C Callout      David Rufo       11/02/2020          Improvement to include the response treatment

***********************************************************************************************************************/
public with sharing class AV_C2C_Controller {

    private static final String INTERFACE_SETTING = 'AV_C2C';

    public class ClickToCallRequest {
        public String calledDevice;
        public String callingDevice;
    }

    public class ClickToCallResponse {
        public String Result;
        public String StatusCode;
    }

    /**
     * @description             Method to perfom the connection with Rainbow and
     *                          execute the functionality of the click-to-call
     * @param calledDevice      -> origin number
     * @param callingDevice     -> target number
     */
    @AuraEnabled
    public static List<String> c2cMakeCall(String calledDevice, String callingDevice){
        List<String> resultMethod = new List<String>();
        String methodName = 'c2cMakeCall';
        try {
            CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(INTERFACE_SETTING);
            AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
            AV_LogDebug.printLogDebug(methodName, '*****************************************');

            ClickToCallRequest ctcBody = new ClickToCallRequest();
            ctcBody.calledDevice = calledDevice;
            ctcBody.callingDevice = callingDevice;

            AV_ApiCallout apiCallout = new AV_ApiCallout()
                    .setIsActive(dataInterface.CC_Activa__c)
                    .setMethod(dataInterface.CC_TipoPeticion__c)
                    .setEndpoint(dataInterface.CC_EndPoint__c)
                    .setCertificate(dataInterface.CC_Certificado__c)
                    .addContentTypeJsonHeader()
                    .setBody(ctcBody)
                    //.setDataMockup(getMockResponse())
                    //.debugMode()
                    .runCallout();

            AV_LogDebug.printLogDebug(methodName, '*****************************************');
            AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

            //Check errors:
            boolean reqStatusOK = apiCallout.checkErrorStatusCode();
            if (reqStatusOK){
                AV_C2C_Controller.ClickToCallResponse dataResponse = (AV_C2C_Controller.ClickToCallResponse)apiCallout.getBodyResponse('AV_C2C_Controller.ClickToCallResponse');
                if ('0'.endsWithIgnoreCase(dataResponse.Result) && '0'.endsWithIgnoreCase(dataResponse.StatusCode)){
                    resultMethod.add(AV_AppConstants.SUCCESS);
                    resultMethod.add(Label.AV_CMP_C2C_OK);
                }
                else if ('1'.endsWithIgnoreCase(dataResponse.Result) && '4'.endsWithIgnoreCase(dataResponse.StatusCode)){
                    resultMethod.add(AV_AppConstants.WARN);
                    resultMethod.add(Label.AV_CMP_C2C_ERR_PERMISSIONS);
                }
                else if ('2'.endsWithIgnoreCase(dataResponse.Result) && '9'.endsWithIgnoreCase(dataResponse.StatusCode)){
                    resultMethod.add(AV_AppConstants.ERROR);
                    resultMethod.add(Label.AV_CMP_C2C_ERR_MOBILE);
                }
                else if ('4'.endsWithIgnoreCase(dataResponse.Result) && '13'.endsWithIgnoreCase(dataResponse.StatusCode)){
                    resultMethod.add(AV_AppConstants.ERROR);
                    resultMethod.add(Label.AV_CMP_C2C_ERR_CON_CUSTOMER);
                }
                else{
                    resultMethod.add(AV_AppConstants.ERROR);
                    resultMethod.add(Label.AV_UnknownError);
                }
            }else{
                resultMethod = AV_IntegrationUtilities.handleErrorMessages(methodName, apiCallout);
            }
        }catch(Exception e){
            resultMethod = AV_IntegrationUtilities.handleExceptionError(methodName, e);
        }
        return resultMethod;
    }

    public static ClickToCallResponse getMockResponse(){
        ClickToCallResponse ctcResponseMock = new ClickToCallResponse();
        ctcResponseMock.Result = '0';
        ctcResponseMock.StatusCode = '0';
        return ctcResponseMock;
    }

}