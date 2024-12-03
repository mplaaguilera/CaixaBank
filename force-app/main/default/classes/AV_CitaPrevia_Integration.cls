/**********************************************************************************************************************
Name:      AV_CitaPrevia_Integration 
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con API para Eventos
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION        USER_STORY                               AUTHOR               DATE       Description
1.0            SF - Integración con API de Cita Previa  Jashanpreet          19/10/2020 Init version
1.1            US304978                                 Víctor Santiago      07/04/2022 branchPhysicalMeet from int to str

***********************************************************************************************************************/
public with sharing class AV_CitaPrevia_Integration {

    public class Event {
        public String salesforceEventId;
        public String subject;
        public Customer Customer;    
        public String employeeEvent;
        public Integer branchId;
        //public List<String> MandatoryAssistances;
        //public List<String> OptionalAssistances;
        public String branchPhysicalMeet;
        public String type;
        public String locationType;
        public String remoteMeeting; 
        public String physicalMeeting;   
        public String meetingPlace;  
        public String meetingRequester;  
        public String reason;
        public String reasonOther;
        public String status;
        public String date_X;
        public String startTime;
        public String endTime;
        public String serialMeetingId;
        public String previousWarning;
        public String colour;
        public Boolean isPrivate;
        public String comment;
        public Boolean aniversary;
        public String urlVideocall;
        public String urlQrPk;
        public String urlQrPdf;
        public String mifidId;
        public String metadataId;
        public List<MetadataField> MetadataFields;
        public Boolean isPhoneSale;
        public Boolean isDigitalCustomer;
    }
    
    public class MetadataField{
        public String fieldId;
        public String value;
    }
    public class Customer{
        public Integer customerId;
        public String name;
        public String surname;
        public String secondSurname;
    }
    
    public class InsCntResponse {
        public String StatusCode;
        public String errorMessage;
        public String errorCode;
        public String eventPremiumId;
    }
    
    public class MoCntResponse {
        public String StatusCode;
        public String errorMessage;
        public String errorCode;
    } 

    public class DelCntResponse {
        public String StatusCode;
        public String errorMessage;
        public String errorCode;
    } 
    
    public class RequestAltaEvent {
        public Event Event;
    }

    /**
    * @description             
    * @param parms     -> Event params
    * @param employeeId -> employee Id
    */
    public static InsCntResponse intCnt( Event parms, String employeeId, String branchId){
        InsCntResponse resultMethod = new InsCntResponse();
        String methodName = 'intCnt';
          
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CitaPrevia_IntCnt');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        if(!String.isEmpty(branchId)){
            branchId = branchId.contains('-') ? branchId.substringAfter('-') : branchId;
        }
        Map<String, String> mapHeader = buildHeaderRequest(employeeId, branchId);
        RequestAltaEvent request = new RequestAltaEvent();
        request.event = parms;
        String endpoint = dataInterface.CC_EndPoint__c.replace('{employeeId}', employeeId);
        String body = System.JSON.serialize(request).replace('date_X', 'date');
        
        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endpoint) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .setHeaders(mapHeader)
            .setBody(body)
            .addContentTypeJsonHeader()
            .debugMode()
            //.setDataMockup('{"statusCode": "201","eventPremiumId": "8911100000000001"}')
            .runCallout();
        
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        
        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        if(reqStatusOK){
            Map<String,Object> resBody = (Map<String,Object>) JSON.deserializeUntyped(apiCallout.getBodyResponse());
            resultMethod.eventPremiumId = String.valueOf(resBody.get('eventPremiumId'));
        }
        AV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
        AV_LogDebug.printLogDebug(methodName, '## statusCode: ' + resultMethod.statusCode);
        AV_LogDebug.printLogDebug(methodName, '## errorCode: ' + resultMethod.errorCode);
        AV_LogDebug.printLogDebug(methodName, '## resultMethod: ' + resultMethod);
        
        return resultMethod;
    }

     /**
    * @description             
    * @param parms     -> Event params
    * @param employeeId -> employee Id
    */
    public static MoCntResponse moCnt( Event parms, String employeeId, String eventPremiumtId, String branchId){
        MoCntResponse resultMethod = new MoCntResponse();
        String methodName = 'moCnt';
        
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CitaPrevia_MoCnt');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        if(!String.isEmpty(branchId)){
            branchId = branchId.contains('-') ? branchId.substringAfter('-') : branchId;
        }
        Map<String, String> mapHeader = buildHeaderRequest(employeeId, branchId);
        RequestAltaEvent request = new RequestAltaEvent();
        request.event = parms;
        String endpoint = dataInterface.CC_EndPoint__c.replace('{eventPremiumId}', eventPremiumtId);
        String body = System.JSON.serialize(request).replace('date_X', 'date');
        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endpoint) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .setHeaders(mapHeader)
            .setBody(body)
            .addContentTypeJsonHeader()
            .debugMode()
            //.setDataMockup('{"statusCode": "200"}')
            .runCallout();
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        
        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        /*if(reqStatusOK){
            //Event updated. Body: {statusCode 201}.
        }*/
        AV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
        
        return resultMethod;
    }

    
     /**
    * @description             
    * @param parms     -> Event params
    * @param employeeId -> employee Id
    */
    public static DelCntResponse delCnt(  String employeeId, String eventId, String branchId){
        DelCntResponse resultMethod = new DelCntResponse();
        String methodName = 'deCnt';
        
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_CitaPrevia_DelCnt');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        if(!String.isEmpty(branchId)){
            branchId = branchId.contains('-') ? branchId.substringAfter('-') : branchId;
        }
        Map<String, String> mapHeader = buildHeaderRequest(employeeId, branchId);
        String endpoint = dataInterface.CC_EndPoint__c.replace('{eventId}', eventId);
        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endpoint) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .setHeaders(mapHeader)
            .addContentTypeJsonHeader()
            .debugMode()
            //.setDataMockup('{"statusCode": "200"}')
            .runCallout();
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        
        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        /*if(reqStatusOK){
            //Event updated. Body: {statusCode 200}.
        }*/
        AV_LogDebug.printLogDebug(methodName, 'Estado de la request: ' + +reqStatusOK);
        
        return resultMethod;
    }



     /**
    * @description            Construye el header de la peticion.
    * @param customerId     -> Identificador del cliente
    * @param employeeId     -> Identificador del empleado
    */
    public static Map<String, String> buildHeaderRequest( String employeeId, String branchId){
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('x-branchId', branchId);
        mapHeader.put('x-employeeId', employeeId);
        return mapHeader;
	}

}