/**********************************************************************************************************************
Name:      CIBE_CitaPrevia_Integration 
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con API para Eventos
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION        USER_STORY                                           AUTHOR               DATE       Description
1.0            SF - Integración con API de Cita Previa Fwrk CBK     Luis Martínez       21/10/2022  Init version
1.1             US540629                                            Jose Maria          07/03/2023  Numper to GCF
1.2                                                                 Alex Campos         10/05/2023  Absorción de errores CBK_Log
2.0             US553360 - Evento Multigestor                       Luis Martínez       02/10/2023  Enviar asistentes a GCF
***********************************************************************************************************************/
public with sharing class CIBE_CitaPrevia_Integration {

    private static final String NAMED_CREDENTIAL_INT = 'CIBE_citaprevia_int';
    private static final String NAMED_CREDENTIAL_MOD = 'CIBE_citaprevia_mo';
    private static final String NAMED_CREDENTIAL_ATT = 'CIBE_pruebaAttendees';


    /**
    * @description             
    * @param parms     -> Event params
    * @param employeeId -> employee Id
    */
    public static InsCntResponse intCnt(Event parms, String employeeId) {
        String methodName = 'intCnt';
        if(parms == null || String.isBlank(employeeId)) {
            throw new AV_ApplicationException(methodName + ' method params must not be null.');
        }

        String body = '';

        try {
            body = JSON.serialize(new RequestAltaEvent(parms));
            system.debug('body '+ body);
            CBK_Log.debug(methodName, 'String body', new List<String>{body});
        } catch(Exception ex) {
            CBK_Log.error(methodName, new List<Event>{parms});
        }

        InsCntResponse resultMethod = new InsCntResponse();
        if(String.isNotBlank(body)) {

            Map<String, String> mapHeader = buildHeaderRequest(employeeId, String.valueOf(parms.branchId));
            body = body.replace('dateReplacement', 'date');
            HttpRequest frwReq = CBK_HttpServiceIntegration.getRequest(body, NAMED_CREDENTIAL_INT, CIBE_AppConstants.POST, mapHeader);

            if(frwReq != null) {
                CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(NAMED_CREDENTIAL_INT);
                String endpoint = wsc?.NamedCredential__c.replace('{employeeId}', employeeId);
                if(String.isNotBlank(endpoint)) {
                    frwReq.setEndpoint(endpoint);
                }
                HttpResponse respuesta = CBK_HttpServiceIntegration.multiCallHttpService(frwReq,null,null);
                Map<String,Object> resBody = new Map<String,Object>();
                try {
                    resBody = (Map<String,Object>) JSON.deserializeUntyped(respuesta.getBody());
                    CBK_Log.debug(methodName, 'Map<String,Object> resBody', new List<Map<String,Object>>{resBody});
                } catch(Exception ex) {
                    CBK_Log.error(methodName, respuesta.getBody());
                }
                
                resultMethod.statusCode = String.ValueOf(respuesta.getStatusCode());
                resultMethod.errorMessage = String.valueOf(resBody.get(CIBE_IntegrationConstants.RESPONSE_REST_ERROR));
                resultMethod.errorCode = String.valueOf(resBody.get(CIBE_IntegrationConstants.RESPONSE_REST_STATUS_CODE));
                resultMethod.eventPremiumId = CIBE_AppUtilities.checkErrorStatusCode(respuesta) ? String.valueOf(resBody.get('eventPremiumId')) : '';
            }
        }
        return resultMethod;
    }

    /**
    * @description             
    * @param parms     -> Event params
    * @param employeeId -> employee Id
    */
    public static MoCntResponse moCnt(Event parms, String employeeId, String eventPremiumId) {
        String methodName = 'moCnt';
        if(parms == null || String.isBlank(employeeId) || String.isBlank(eventPremiumId)) {
            throw new AV_ApplicationException(methodName + ' method params must not be null.');
        }

        String body = '';

        try {
            body = JSON.serialize(new RequestAltaEvent(parms));
            system.debug('body '+ body);

            //CBK_Log.debug(methodName, 'String body', new List<String>{body});
        } catch(Exception ex) {
            CBK_Log.error(methodName, new List<Event>{parms});
        }

        MoCntResponse resultMethod = new MoCntResponse();
        if(String.isNotBlank(body)) {
            Map<String, String> mapHeader = buildHeaderRequest(employeeId, String.valueOf(parms.branchId));
            body = body.replace('dateReplacement', 'date');

            HttpRequest frwReq = CBK_HttpServiceIntegration.getRequest(body, NAMED_CREDENTIAL_MOD, CIBE_AppConstants.POST, mapHeader);
            if(frwReq != null) {
                CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues(NAMED_CREDENTIAL_MOD);
                String endpoint = wsc?.NamedCredential__c.replace('{id}', eventPremiumId);
                if(String.isNotBlank(endpoint)) {
                    frwReq.setEndpoint(endpoint);
                }
                    system.debug('@@@ AQUI?');

                //HttpResponse respuesta = CBK_HttpServiceIntegration.callHttpService(frwReq,'',NAMED_CREDENTIAL_MOD);
                HttpResponse respuesta = CBK_HttpServiceIntegration.multiCallHttpService(frwReq,null,null);

                Map<String,Object> resBody = new Map<String,Object>();
                try {
                    resBody = (Map<String,Object>) JSON.deserializeUntyped(respuesta.getBody());
                    CBK_Log.debug(methodName, 'Map<String,Object> resBody', new List<Map<String,Object>>{resBody});
                } catch(Exception ex) {
                    CBK_Log.error(methodName, respuesta.getBody());
                }

                resultMethod.statusCode = String.ValueOf(respuesta.getStatusCode());
                resultMethod.errorMessage = String.valueOf(resBody.get(CIBE_IntegrationConstants.RESPONSE_REST_ERROR));
                resultMethod.errorCode = String.valueOf(resBody.get(CIBE_IntegrationConstants.RESPONSE_REST_STATUS_CODE));
            }
        }
        return resultMethod;
    }

    /**
    * @description            Construye el header de la peticion.
    * @param customerId     -> Identificador del cliente
    * @param employeeId     -> Identificador del empleado
    */
    public static Map<String, String> buildHeaderRequest(String employeeId, String branchId) {
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('x-branchId', branchId);
        mapHeader.put('x-employeeId', employeeId);
        mapHeader.put(CIBE_IntegrationConstants.HEADER_CONTENT_TYPE, CIBE_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON);
        return mapHeader;
    }

    public class RequestAltaEvent {
        public Event Event;

        public RequestAltaEvent(Event parms) {
            this.Event = parms;
        }
    }

public class Event {
    public String salesforceEventId;
    public String subject;
    public Customer Customer;    
    public String employeeEvent;
    public Integer branchId;
    //public List<String> MandatoryAssistance;
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
    public String dateReplacement;
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
    public String legalRepresentativeId;
    public String legalRepresentativeName;
    public List<String> MandatoryAssistance;

    
        public Event() {
            this.Customer = new Customer();
            this.MetadataFields = new List<MetadataField>();
        }
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
    public String statusCode;
    public String errorMessage;
    public String errorCode;
    public String eventPremiumId;
}

public class MoCntResponse {
    public String statusCode;
    public String errorMessage;
    public String errorCode;
} 

public class DelCntResponse {
    public String statusCode;
    public String errorMessage;
    public String errorCode;
} 

}