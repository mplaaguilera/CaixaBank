/**********************************************************************************************************************
Name:	  AV_Trazabilidad_Integration
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Trazabilidad API
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR              DATE			Description
    1.0         US414208                                            Patricia Solano     13/09/2022		Init version
    1.1         US457343                                            Patricia Solano     27/09/2022		Modified CustomerResponse
***********************************************************************************************************************/
public with sharing class AV_Trazabilidad_Integration {

    private static final String AV_TRAZABILIDAD = 'AV_Trazabilidad'; 

    public class CustomerResponse {
		@AuraEnabled
		public String statusCode;
		@AuraEnabled
		public String errorMessage;
		@AuraEnabled
		public String errorCode;
		@AuraEnabled
		public CustomerTrackingBodyOutResponse data;
        @AuraEnabled
		public String moreElements;
	}

    public class CustomerPetitionsBodyRequest{
        @AuraEnabled
        public String petitionStatus;
        @AuraEnabled
        public integer customerInternalId;
        @AuraEnabled
        public String customerId;
        @AuraEnabled
        public String startDate;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String pagekey;
    }

    public class CustomerTrackingBodyOutResponse {
        @AuraEnabled
        public String moreElements;
        @AuraEnabled
        public List<PetitionCustomerData> petitionsList;
    }

    public class PetitionCustomerData {
        @AuraEnabled
        public String petitionId;
        @AuraEnabled
        public String petitionStatus;
        @AuraEnabled
        public integer processId;
        @AuraEnabled
        public String processDescriptionCat;
        @AuraEnabled
        public String processDescriptionCas;
        @AuraEnabled
        public integer customerInternalId;
        @AuraEnabled
        public String personName;
        @AuraEnabled
        public integer branchId;
        @AuraEnabled
        public integer scopeId;
        @AuraEnabled
        public String scopeDescriptionCat;
        @AuraEnabled
        public String scopeDescriptionCas;
        @AuraEnabled
        public String startPetitionDate;
        @AuraEnabled
        public String endDatePetition;
        @AuraEnabled
        public String statusDescriptionCat;
        @AuraEnabled
        public String statusDescriptionCas;
        @AuraEnabled
        public integer stepNum;
        @AuraEnabled
        public String employeeId;
        @AuraEnabled
        public List<StepData> stepList;
    }

    public class StepData {
        @AuraEnabled
        public String stepId;
        @AuraEnabled
        public integer stepNumber;
        @AuraEnabled
        public String stepDate;
        @AuraEnabled
        public String stepExpectedDate;
        @AuraEnabled
        public String stepRealDate;
        @AuraEnabled
        public String stepDescriptionCat;
        @AuraEnabled
        public String stepDescriptionCas;
    }

    /**
     * @description   Este método permite obtener una lista de peticiones o procesos asociados a un cliente
     * @param petitionStatus           -> identifica si el proceso es activo "A" o si forma parte del historial "H"
     * @param numPerso                 -> Identifica el NumPerso del cliente
     * @param pagekey                  -> Identifica la paginación de elementos
     */
    @AuraEnabled
    public static CustomerResponse getCustomerTrackings(String petitionStatus, integer numPerso, String pagekey){

        CustomerResponse resultMethod = new CustomerResponse();
        CustomerPetitionsBodyRequest customerRequest = new CustomerPetitionsBodyRequest();
        
        String methodName = 'getCustomerTrackings';

        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface(AV_TRAZABILIDAD);
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');

        customerRequest.petitionStatus = petitionStatus;
        customerRequest.customerInternalId = numPerso;
        customerRequest.customerId = null;
        customerRequest.startDate = null;
        customerRequest.endDate = null;
        customerRequest.pagekey = pagekey;

        AV_ApiCallout apiCallout = new AV_ApiCallout()
        .setIsActive(dataInterface.CC_Activa__c)
        .setTimeOut(Integer.valueOf(dataInterface.CC_TimeOut__c))
        .setMethod(dataInterface.CC_TipoPeticion__c)
        .setEndpoint(dataInterface.CC_EndPoint__c) 
        .setCertificate(dataInterface.CC_Certificado__c)
        .addContentTypeJsonHeader()
        //.setHeaders()
        .debugMode()
        .setBody(customerRequest)
        //.setDataMockup('{"moreElements": "S","petitionsList": [{ "petitionId": "97120012545544","petitionStatus": "A","processId": 33, "processDescriptionCat": "Procés dinformació","processDescriptionCas": "Proceso de información", "customerInternalId": 13550, "personName": "SILVIA MARTÍN","branchId": 9712,"scopeId": 10,"scopeDescriptionCat": "Hipoteca","scopeDescriptionCas": "Hipoteca","startPetitionDate": "2020-01-25","endDatePetition": "2021-01-21","statusDescriptionCat": "Cita pendent","statusDescriptionCas": "Pendiente cita","stepNum": 1,"employeeId": "U0123456","stepList": [{"stepId": "22000001","stepNumber": 1,"stepDate": "2020-11-30","stepExpectedDate": "2020-12-31","stepRealDate": "2020-12-20","stepDescriptionCat": "Primer pas","stepDescriptionCas": "Primer paso"}]}, { "petitionId": "97120012545544","petitionStatus": "A","processId": 33, "processDescriptionCat": "Procés dinformació","processDescriptionCas": "Proceso de información", "customerInternalId": 13550, "personName": "VICTOR SAULER","branchId": 9712,"scopeId": 10,"scopeDescriptionCat": "Financiació","scopeDescriptionCas": "Financiación","startPetitionDate": "2020-09-25","endDatePetition": "2022-09-21","statusDescriptionCat": "Finalitzat","statusDescriptionCas": "Finalizado","stepNum": 3,"employeeId": "U0123456","stepList": [{"stepId": "22000001","stepNumber": 1,"stepDate": "2020-11-30","stepExpectedDate": "2020-12-31","stepRealDate": "2020-12-20","stepDescriptionCat": "Primer pas","stepDescriptionCas": "Primer paso"}]}, { "petitionId": "97120012545544","petitionStatus": "A","processId": 33, "processDescriptionCat": "Procés dinformació","processDescriptionCas": "Proceso de información", "customerInternalId": 13550, "personName": "VICTOR SAULER","branchId": 9712,"scopeId": 10,"scopeDescriptionCat": "Financiació","scopeDescriptionCas": "Financiación","startPetitionDate": "2022-09-10","endDatePetition": "2022-09-19","statusDescriptionCat": "Actiu","statusDescriptionCas": "Pendiente cita","stepNum": 2,"employeeId": "U0123456","stepList": [{"stepId": "22000001","stepNumber": 1,"stepDate": "2020-11-30","stepExpectedDate": "2021-12-31","stepRealDate": "2021-12-20","stepDescriptionCat": "Primer pas","stepDescriptionCas": "Primer paso"}]}]}')
        .runCallout();

        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
		boolean reqStatusOK = apiCallout.checkErrorStatusCode();

        if (reqStatusOK) {
            CustomerTrackingBodyOutResponse bodyResponse = (AV_Trazabilidad_Integration.CustomerTrackingBodyOutResponse)apiCallout.getBodyResponse('AV_Trazabilidad_Integration.CustomerTrackingBodyOutResponse');
            resultMethod.data = bodyResponse;
            resultMethod.moreElements = bodyResponse.moreElements;
        }  
        AV_LogDebug.printLogDebug(methodName, 'Result method: ' + resultMethod);
        return resultMethod;
    }
}