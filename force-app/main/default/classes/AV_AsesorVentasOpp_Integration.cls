/**********************************************************************************************************************
Name:      AV_AsesorVentasOpp_Integration
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con API para Oportunidades
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION        USER_STORY                               AUTHOR               DATE                Description
    1.0            SF - Integracion con Oportunidades       Esperanza Conde      25/08/2020          Init version
    1.1            SF - Integracion con Oportunidades       David Rufo           29/10/2020          Retrieve the ID of the opportunity (New)
    1.2            Val. Sprints                             Víctor Santiago      08/02/2021          Changed variables from UpperCamelCase to lowerCamelCase
	1.3            Fix lowerCamelCase Problems				David Rufo      	 02/07/2021          Problems detected with lowerCamelCase

***********************************************************************************************************************/
public with sharing class AV_AsesorVentasOpp_Integration {

    public class ConOppResponse {
        public String StatusCode;
        public String errorMessage;
        public String errorCode;
        public Opportunity data;
    } 

    public class ResponseOpportunity{
        public Opportunity Opportunity; 
    }
    
    public class RequestAltaOpp {
        public Opportunity Opportunity;
    }

    public class Opportunity {
		public Integer opportunityId;	//34567
		public Integer employeeId;	//96827
		public Date offerUntil;	//2021-03-31
		public String potential;	//S
		public String holdingOtherEntities;	//S
		public String entityName;	//BBVA                                              
		public Double amountOtherEntities;	//113243.5
		public Date dueDate;	//
		public String commentary;	//alta nueva pea
		public Integer userId;	//13550
		public Double interestRate;	//0
		public String noOfferUntil;	//
		public Double monthlyFee;	//0
		public String warningIndicator;	//N
	}

    public class AltaOppResponse {
        public String StatusCode;
        public String errorMessage;
        public String errorCode;
        public AltaOppResponseId responseGCF;
    }

    public class AltaOppResponseId {
        public String opportunityId;
    }

    public class ModOppResponse {
        public String StatusCode;
        public String errorMessage;
        public String errorCode;
    } 
    
 
    /**
    * @description             Recupera el detalle de una oportunidad de un cliente.
    * @param customerId     -> Identificador del cliente
    * @param oppId          -> Identificador de la oportunidad
    */
    public static ConOppResponse conOportunidad(String customerId, String oppId, String employeeId){
        
        ConOppResponse resultMethod = new ConOppResponse();
        String methodName = 'conOportunidad';
        
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_DetalleOpp');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        
        Map<String, String> mapHeader = new Map<String, String>();
        Long longUser = long.valueOf(customerId);
        String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
        mapHeader.put('X-ABSIS-HEADER-SESSION-numperso',hexDigest);
        mapHeader.put('x-employeeId', employeeId);
        
        String endpoint = dataInterface.CC_EndPoint__c.replace('{opportunityId}', oppId);
        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endpoint) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .setHeaders(mapHeader)
            .addContentTypeJsonHeader()
            .debugMode()
			//.setDataMockup('{"Opportunity":{"opportunityId":34568,"employeeId":96827,"offerUntil":"2021-03-31","potential":"S","holdingOtherEntities":"S","entityName":"BBVA","amountOtherEntities":113243.50,"dueDate":"2021-09-21","commentary":"alta nueva pea","userId":13550,"interestRate":0.00,"noOfferUntil":"2021-09-21","monthlyFee":0.00,"warningIndicator":"S"}}')
            .runCallout();
        
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        
        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        if(reqStatusOK){
            AV_AsesorVentasOpp_Integration.ResponseOpportunity bodyResponse = (AV_AsesorVentasOpp_Integration.ResponseOpportunity)apiCallout.getBodyResponse('AV_AsesorVentasOpp_Integration.ResponseOpportunity');
            resultMethod.data = bodyResponse.Opportunity;
        }
        return resultMethod;
    }
    
       /**
    * @description             Alta de una nueva oportunidad de un cliente.
    * @param customerId     -> Identificador del cliente
    * @param employeeId     -> Identificador del empleado
    * @param parms          -> Parametros necesarios para dar de alta la Oportunidad
    */
    public static AltaOppResponse altaOportunidad(Opportunity parms, String customerId, String employeeId){
        AltaOppResponse resultMethod = new AltaOppResponse();
        String methodName = 'altaOportunidad';
        
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_AltaOpp');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        
        Map<String, String> mapHeader = buildHeaderRequest(customerId, employeeId);
        Opportunity ctcBody = buildBodyRequest(parms);
        RequestAltaOpp request = new RequestAltaOpp();
        request.opportunity = ctcBody;
        String endpoint = dataInterface.CC_EndPoint__c;
        
        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endpoint) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .setHeaders(mapHeader)
            .setBody(request)
            .addContentTypeJsonHeader()
            .debugMode()
            .runCallout();
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        String strBodyReponse = null;
        try{
            strBodyReponse = apiCallout.getBodyResponse();
        }catch(AV_ApplicationException e){
            AV_LogDebug.printLogError(methodName, 'Error response: ' + e.getMessage());
            strBodyReponse = null;
        }
        
        if(reqStatusOK){
            //Oportunidad creada. Body: {statusCode 201}.
            AltaOppResponseId response = (AltaOppResponseId)apiCallout.getBodyResponse('AV_AsesorVentasOpp_Integration.AltaOppResponseId');
            resultMethod.responseGCF = response;
        }
        else if (String.isNotBlank(strBodyReponse) && strBodyReponse.contains('errorCode')){
            AltaOppResponse responseError = (AltaOppResponse)apiCallout.getBodyResponse('AV_AsesorVentasOpp_Integration.AltaOppResponse');
            resultMethod.errorMessage = responseError.errorMessage;
        	resultMethod.errorCode = responseError.errorCode;
        }
        AV_LogDebug.printLogDebug(methodName, 'ResultMethod: ' + resultMethod);
        AV_LogDebug.printLogDebug(methodName, 'Response status: ' + reqStatusOK);
        
        return resultMethod;
    }

   /**
    * @description             Modificación de una oportunidad existente de un cliente.
    * @param customerId     -> Identificador del cliente
    * @param employeeId     -> Identificador del empleado
    * @param parms          -> Paramétros que se sincronizan de la oportunidad
    */
    public static ModOppResponse modOportunidad(Opportunity parms, String customerId, String employeeId, String opportunityId){
        ModOppResponse resultMethod = new ModOppResponse();
        String methodName = 'modOportunidad';
        
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_ModOpp');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        
        Map<String, String> mapHeader = buildHeaderRequest(customerId, employeeId);
        Opportunity ctcBody = buildBodyRequest(parms);
        RequestAltaOpp request = new RequestAltaOpp();
        request.opportunity = ctcBody;
        String endpoint = dataInterface.CC_EndPoint__c.replace('{opportunityId}',opportunityId);
        
        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endpoint) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .setHeaders(mapHeader)
            .setBody(request)
            .addContentTypeJsonHeader()
            .debugMode()
            .runCallout();
        
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        
        //Check errors:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        String strBodyReponse = null;
        try{
            strBodyReponse = apiCallout.getBodyResponse();
        }catch(AV_ApplicationException e){

            AV_LogDebug.printLogError(methodName, 'Error response: ' + e.getMessage());

            strBodyReponse = null;
        }
        
        if (String.isNotBlank(strBodyReponse) && strBodyReponse.contains('errorCode')){
            ModOppResponse responseError = (ModOppResponse)apiCallout.getBodyResponse('AV_AsesorVentasOpp_Integration.ModOppResponse');
            resultMethod.errorMessage = responseError.errorMessage;
        	resultMethod.errorCode = responseError.errorCode;
        }
        AV_LogDebug.printLogDebug(methodName, 'ResultMethod: ' + resultMethod);
        AV_LogDebug.printLogDebug(methodName, 'Response status: ' + reqStatusOK);
        
        return resultMethod;
    }


   /**
    * @description            Construye el header de la peticion.
    * @param customerId     -> Identificador del cliente
    * @param employeeId     -> Identificador del empleado
    */
    public static Map<String, String> buildHeaderRequest(String customerId, String employeeId){
        Map<String, String> mapHeader = new Map<String, String>();
        Long longUser = long.valueOf(customerId);
        String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
        mapHeader.put('X-ABSIS-HEADER-SESSION-numperso',hexDigest);
        mapHeader.put('x-employeeId', employeeId);
        
        return mapHeader;
    }

    /**
    * @description             Construye el body de la peticion
    * @param parms          -> Paramétros que se sincronizan de la oportunidad
    */
    public static Opportunity buildBodyRequest(Opportunity parms){
        Opportunity ctcBody = new Opportunity();
        ctcBody.opportunityId = parms.opportunityId;
        ctcBody.employeeId = parms.employeeId;
        ctcBody.offerUntil = parms.offerUntil;
        ctcBody.potential = parms.potential;
        ctcBody.holdingOtherEntities = parms.holdingOtherEntities;
        ctcBody.entityName = parms.entityName;
        ctcBody.amountOtherEntities = parms.amountOtherEntities;
        ctcBody.userId = parms.userId;
        ctcBody.dueDate = parms.dueDate;
        ctcBody.commentary = parms.commentary;
        ctcBody.interestRate = parms.interestRate;
        ctcBody.noOfferUntil = parms.noOfferUntil;
        ctcBody.monthlyFee = parms.monthlyFee;
        ctcBody.warningIndicator = parms.warningIndicator;
        return ctcBody;
    }

    /* NO ELIMINAR, 
     * ES PARA PROBAR CASOS DE ERROR EN EL FLUJO DE ALTA DE OPORTUNIDAD
    private static String getNewOppError(){
        return '{ "Opportunity": {"opportunityId": 345670,"employeeId": 96827,"offerUntil": "2021-03-31","potential": "S","holdingOtherEntities": "S","entityName": "BBVA    ",' + 
            					 '"amountOtherEntities": 113243.50,"dueDate": "","commentary": "alta nueva pea","userId": 13550,"interestRate": 0.00,"noOfferUntil": "","monthlyFee": 0.00,' + 
            					 '"warningIndicator": "N"}}';
    }*/

}