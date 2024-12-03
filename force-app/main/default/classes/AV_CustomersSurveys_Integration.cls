/**********************************************************************************************************************
Name:     AV_CustomersSurveys_Integration
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración Data service for access to customer surveys.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY                              AUTHOR              DATE            Description
1.0         US363437                                Pablo Martínez          24/05/2022      Init version

***********************************************************************************************************************/
public with sharing class AV_CustomersSurveys_Integration {

    private static final String AV_CUSTOMERSURVEY = 'AV_CustomerSurvey';
    private static final String PARAM_CUSTOMERINTERNALID  = 'x-absis-customerInternalId';
    private static final String HEADER_CUSTOMER = 'x-absis-customer-context';

public class SurveyResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public SurveyListData data;
    }

    public class SurveyListData {
        @AuraEnabled
        public List<SurveyData> Surveys;
    }


    public class SurveyData {
        @AuraEnabled
        public String date_Z;
        @AuraEnabled
        public Integer customerInternalId;
        @AuraEnabled
        public Integer surveyId;
        @AuraEnabled
        public String invitationDate;
        @AuraEnabled
        public String responseDate;
        @AuraEnabled
        public Integer secondSurveyId;
        @AuraEnabled
        public String secondInvitationDate;
        @AuraEnabled
        public String secondResponseDate;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String rating;
        @AuraEnabled
        public String secondRating;
        @AuraEnabled
        public Integer branchCheckinId;
        @AuraEnabled
        public Integer branchManagementId;
        @AuraEnabled
        public String channel;
        @AuraEnabled
        public String secondChannel;
        @AuraEnabled
        public String trigger_Z;
        @AuraEnabled
        public String associateEmployeeId;
        @AuraEnabled
        public String customerAssociateEmployeeId;
        @AuraEnabled
        public String alertAssociateEmployeeId;
        @AuraEnabled
        public String comment;
        @AuraEnabled
        public String tabulatedComment;
        @AuraEnabled
        public Integer smiley;
        @AuraEnabled
        public String procedureStateDescription;
        @AuraEnabled
        public String procedureDate;
        @AuraEnabled
        public String dataDate;
        @AuraEnabled
        public String loadDate;
    }

    public class ErrorData {
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
    }


    /**
     * @description Recoge el SurveyId.
     * @param person         -> Identificación de encuesta
     */
    public static SurveyResponse getSurveyId(String person){
        SurveyResponse resultMethod = new SurveyResponse();
        String methodName = 'getSurveyId';
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_CUSTOMERSURVEY);
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');

        String endPoint=dataInterface.CC_EndPoint__c;
  
        Map<String, String> mapHeader = new Map<String, String>();
        
		Long longUser = long.valueOf(person);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);

		mapHeader.put(PARAM_CUSTOMERINTERNALID, hexDigest);
        
        AV_LogDebug.printLogDebug(methodName, 'mapHeader: ' + mapHeader);

        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setTimeOut(Integer.valueOf(dataInterface.CC_TimeOut__c))
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endPoint) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .addContentTypeJsonHeader()
            .setHeaders(mapHeader)
            .debugMode()
            //.setDataMockup(mockString)
            .runCallout();

        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

        //Check errors:
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();

        AV_LogDebug.printLogDebug(methodName, 'Request status: ' + +reqStatusOK);

        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();

        if (reqStatusOK){
            SurveyListData bodyResponse = (AV_CustomersSurveys_Integration.SurveyListData)apiCallout.getBodyResponse('AV_CustomersSurveys_Integration.SurveyListData');

            resultMethod.data = bodyResponse;
        } else {
            ErrorData bodyResponse = (AV_CustomersSurveys_Integration.ErrorData)apiCallout.getBodyResponse('AV_CustomersSurveys_Integration.ErrorData');
            resultMethod.errorMessage = bodyResponse.errorMessage;
            resultMethod.errorCode = bodyResponse.errorCode;
        }
        
        AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
        return resultMethod;
    }
 }