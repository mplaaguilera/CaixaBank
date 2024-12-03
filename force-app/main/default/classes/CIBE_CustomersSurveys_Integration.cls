/**********************************************************************************************************************
Name:     CIBE_CustomersSurveys_Integration
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración Data service for access to customer surveys with new Framework CBK_HttpServiceIntegration
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION     USER_STORY                              AUTHOR              DATE            Description
1.0         US738544                                Borja Lavesiera     02/01/2024      Init version

***********************************************************************************************************************/
public with sharing class CIBE_CustomersSurveys_Integration {

    private static final String PARAM_INTEGRATIONSETTING = 'CIBE_getSurveyDataExpCliente';
    private static final String PARAM_CUSTOMERINTERNALID  = 'x-absis-customerInternalId';

public class SurveyResponse {
        @AuraEnabled
        public Integer statusCode;
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
        public String triggerClon;
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
     * @description Recoge la información de Encuestas para el Componente Experiencia de Cliente.
     * @param Numperso         -> Identificación Numperso del Cliente 
     */
    public static SurveyResponse getSurveyData(String Numperso){
        SurveyResponse resultMethod = new SurveyResponse();
        Long longUser = long.valueOf(Numperso);
		String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
        String responseError = '';
        Map<String,string> mHeaders =  new  Map<String,string>();
        CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(PARAM_INTEGRATIONSETTING);
        //Si usamos la name credential de camaleon le metemos su cabecera
        if(wsc?.NamedCredential__c.contains('CAMALEON')){
            mHeaders.put('x-api-actor-simulated','ABSIS_GENERICO');
        }
        mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
        mHeaders.put(PARAM_CUSTOMERINTERNALID, hexDigest);
        if(Numperso != '') {
            try {
                CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
                reqWrapper.body = '';
                reqWrapper.intSetting = 'CIBE_getSurveyDataExpCliente';
                reqWrapper.method = 'GET';
                reqWrapper.mHeaders =  mHeaders;
                reqWrapper.mUriParams = new  Map<String,string>();
                reqWrapper.mQueryParams = new  Map<String,string>();

                HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);
                HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, Numperso, PARAM_INTEGRATIONSETTING);
                 CBK_log.debug('Response' + res, logginglevel.DEBUG);
                 if (res.getStatusCode() == 200) {
                    String responseBody = res.getBody();
                    // Reemplazamos trigger al estar reservado en el JSON de Respuesta
                    responseBody = responseBody.replace('"trigger":', '"triggerClon":');
                    SurveyListData bodyResponse = (CIBE_CustomersSurveys_Integration.SurveyListData)JSON.deserialize(responseBody,SurveyListData.class);
                    resultMethod.data = bodyResponse;
                    resultMethod.statusCode = res.getStatusCode();
                    system.debug('Respuesta body' + res.getStatusCode());
                }
                else if(res.getStatusCode() == 204) {
                    responseError = '204';
                    CBK_log.error(responseError);
                }
                else {
                    responseError = 'Fallo conexión con el servicio externo';
                    CBK_log.error(responseError);
                }
            }
            catch(Exception e) {
                responseError = 'Error al procesar los datos de la integración. Contacte con el administrador';
                CBK_log.error(responseError);
            }
            if(!string.isBlank(responseError)&& !Test.isRunningTest()){
                CBK_log.debug('Response Error' + responseError);
                throw new AuraHandledException(responseError);
            }
            CBK_HttpServiceIntegration.registroTrazaIntegracion();
        }
        return resultMethod;
    }
 }