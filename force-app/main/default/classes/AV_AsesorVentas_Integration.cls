/**********************************************************************************************************************
Name:      AV_AsesorVentas_Integration
Copyright © 2019  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Integración con GCF para la carterización
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
VERSION        USER_STORY                               AUTHOR               DATE                Description
1.0            SF - Integracion con Carterización       Esperanza Conde      14/07/2020          Init version
1.1                                                     Esperanza Conde      02/10/2020          Keep the response
1.2            Hotfix                                   Eric Vázquez         26/01/2021          Add error message in cambiarGestorCli
1.3            Val. Sprints                             Víctor Santiago      08/02/2021          Changed variable names from UpperCamelCase to lowerCamelCase
1.4			   AV_Query IT								Daniel Rodríguez	 3/02/2022			 Change AV_Query to SOQL for User and Account
***********************************************************************************************************************/
public with sharing class AV_AsesorVentas_Integration {
    

    public class ListaGestoresResponse {
        public String statusCode;
        public String errorMessage;
        public String errorCode;
        public List<Employee> data;
    } 

    public class GestoresList {
        public List<Employee> employees;
    } 

	public class Employee {
		public Integer employeeId;	//52391
		public String firstName;	//ANNA
		public String surname;	//ORRIOLS
		public String secondSurname;	//PEREZ
    }

    public class ReasignarCarteraRequest {
        public Integer newManager; //Obligatorio -> Matricula del nuevo empleado propietario de la cartera.
        public Integer newBranch; //Obligatorio -> Código del centro donde se asignara la cartera.
        public Boolean inheritCategories; //Opcional -> Indicador de si el nuevo empleado heredara las categorías del antiguo propietario de la cartera.
    } 
    
    public class ReasignarCarteraResponse {
        public String statusCode;
        public String errorMessage;
        public String errorCode;
        public String data;
    } 

    public class WarningResponse {
        public String warningMessage;
    }  
   
    public class CambiarGestorRequest {
        public String typeOperation; //Obligatorio -> Tipo de operación que se va a realizar: C = Carterización, D = Descarterización del cliente 
        public Integer customerPortfolioId; //Obligatorio -> Es el código de la cartera asignada al cliente
        public String typeReason;   // Opcional -> Motivo para carterizar o descarterizar (en este caso obligatorio)
        //1: Solicitado por el negocio, 2: Solicitado por el cliente, 9: Otros
        public String otherReason;  //Opcional -> Descripción del motivo. Nota: Obligatorio para typeOperation=D y typeReason=9
        public Boolean isNextYear;  //Opcional -> Si la operación es solo para la visión de próximo año o no.
        public List<String> Categories; // Opcional -> Para carterizar, lista de categórias del cliente que heredara el nuevo gestor.
    }
    
    public class CambiarGestorResponse {
        public String statusCode;
        public String errorMessage;
        public String errorCode;
    } 
    /** 
    public class Cartera_Error {
        public String status;
        public String errorCode;
        public String errorMessage;
    }
    */
    /**
    * @description             Devuelve un listado de todos los gestores asignados a un centro.
    * @param branchId     -> Aún por definir
    * @param parms          -> Paramétros necesarios para extraer los gestores
    */
    public static ListaGestoresResponse liEmplCentro(String branchId){
        
        ListaGestoresResponse resultMethod = new ListaGestoresResponse();
        String methodName = 'liEmplCentro';
        
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_ListGestores');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');

        String employeeIdUser = getUserLog();

        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('x-employeeId', employeeIdUser);
        mapHeader.put('x-branchId', branchId);

        String endpoint = dataInterface.CC_EndPoint__c.replace('{branchId}', branchId);
        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endpoint) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .setHeaders(mapHeader)
            .addContentTypeJsonHeader()
            .debugMode()
            //.setDataMockup('{"Employees":[{"employeeId": 52391,"firstName":"ANNA","surname":"ORRIOLS","secondSurname":"PEREZ"},{"employeeId":68044,"firstName":"DAVID","surname": "ROCA","secondSurname":"SALA"},{"employeeId":49224,"firstName":"GUILLEM","surname":"ZAMORA","secondSurname":"BARAT"}]}')
            .runCallout();
        
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        
        //Check status Code:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        if(reqStatusOK){
            AV_AsesorVentas_Integration.GestoresList bodyResponse = (AV_AsesorVentas_Integration.GestoresList)apiCallout.getBodyResponse('AV_AsesorVentas_Integration.GestoresList');
            resultMethod.data = bodyResponse.Employees;
        }
        else{
            ListaGestoresResponse bodyResponse = (AV_AsesorVentas_Integration.ListaGestoresResponse)apiCallout.getBodyResponse('AV_AsesorVentas_Integration.ListaGestoresResponse');
            resultMethod.errorMessage = bodyResponse.errorMessage;
            resultMethod.errorCode = bodyResponse.errorCode;
        }
                
        return resultMethod;
    }
    
    /**
    * @description        La función de este método consiste en proporcionar la funcionalidad de reasignar 
    *                     una cartera y todos sus clientes a otro gestor.
    * @param customerPortId -> Código de cartera a reasignar. Obligatorio
    * @param employeeId 	 -> Empleado logueado
    * @param branchId		 -> Centro logueado
    * @param parms          -> Paramétros necesarios para extraer los gestores
    */
    public static ReasignarCarteraResponse reasignarCartera(ReasignarCarteraRequest parms, String customerPortId, String branchId){
        
        ReasignarCarteraResponse resultMethod = new ReasignarCarteraResponse();
        String methodName = 'reasignarCartera';
        
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_ReasignarCartera');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        
        String employeeIdUser = getUserLog();

        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('x-employeeId', employeeIdUser); 
        if(branchId != Null){
            mapHeader.put('x-branchId', branchId);   
        }	
        AV_LogDebug.printLogDebug(methodName, 'Header: ' + mapHeader);
        ReasignarCarteraRequest ctcBody = new ReasignarCarteraRequest();
        ctcBody.newManager = parms.newManager;
        ctcBody.newBranch = parms.newBranch;
        ctcBody.inheritCategories = parms.inheritCategories;
        
        String endpoint = dataInterface.CC_EndPoint__c.replace('{customerPortfolioId}', customerPortId);
        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(endpoint) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .addContentTypeJsonHeader()
            .setHeaders(mapHeader)
            .setBody(ctcBody)
            //.setDataMockup('{"warningMessage": "Debido al volumen de la cartera esta petición no puede procesarse en On-line. Ha sido registrada y mañana estará disponible."}') 
            .debugMode()
            .runCallout(); 
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        
        //Check status Code:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        if(reqStatusOK){
            AV_AsesorVentas_Integration.WarningResponse bodyResponse = (AV_AsesorVentas_Integration.WarningResponse)apiCallout.getBodyResponse('AV_AsesorVentas_Integration.WarningResponse');
            resultMethod.data = bodyResponse.warningMessage;
            //Data puede ser nula => entonces se ha procesado
            //Data puede ser no nula => "Debido al volumen de la cartera esta petición no puede procesarse en On-line. Ha sido registrada y mañana estará disponible."
        }
        else{
            ReasignarCarteraResponse bodyResponse = (AV_AsesorVentas_Integration.ReasignarCarteraResponse)apiCallout.getBodyResponse('AV_AsesorVentas_Integration.ReasignarCarteraResponse');
            resultMethod.errorMessage = bodyResponse.errorMessage;
            resultMethod.errorCode = bodyResponse.errorCode;
        }
                
        return resultMethod;
    }

    /**
    * @description             Carterización unitaria de un cliente a una nueva cartera.
    * @param customerId     -> Identificador del cliente
    * @param employeedId 	 -> Empleado logueado
    * @param branchId		 -> Centro logueado
    * @param parms          -> Paramétros necesarios para el servicio carterizar o descarterizar
    */
    public static CambiarGestorResponse cambiarGestorCli(CambiarGestorRequest parms, String customerId, String branchId, String employeeId){
            
        CambiarGestorResponse resultMethod = new CambiarGestorResponse();
        String methodName = 'cambiarGestorCli';
        
        CC_InterfaceSettings__mdt dataInterface = AV_IntegrationUtilities.fetchMetadataInterface('AV_Carterizar');
        AV_LogDebug.printLogDebug(methodName, 'Interface: ' + dataInterface);
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        
        String employeeIdUser = getUserLog();

        Map<String, String> mapHeader = new Map<String, String>();
        Long longUser = long.valueOf(customerId);
        String hexDigest = AV_IntegrationUtilities.convertToHexadecimal(longUser);
        mapHeader.put('X-ABSIS-HEADER-SESSION-numperso',hexDigest);
        mapHeader.put('x-employeeId', employeeId);
        mapHeader.put('x-branchId', branchId);
        
        CambiarGestorRequest ctcBody = new CambiarGestorRequest();
        ctcBody.Categories = parms.Categories;
        ctcBody.customerPortfolioId = parms.customerPortfolioId;
        ctcBody.isNextYear = parms.isNextYear;
        ctcBody.otherReason = parms.otherReason;
        ctcBody.typeOperation = parms.typeOperation;
        ctcBody.typeReason = parms.typeReason;
        
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Header: ' +mapHeader+ ' y Request: ' + ctcBody);

        AV_ApiCallout apiCallout = new AV_ApiCallout()
            .setIsActive(dataInterface.CC_Activa__c)
            .setMethod(dataInterface.CC_TipoPeticion__c)
            .setEndpoint(dataInterface.CC_EndPoint__c) 
            .setCertificate(dataInterface.CC_Certificado__c)
            .addContentTypeJsonHeader()
            .setBody(ctcBody)
            .setHeaders(mapHeader)
            //.setDataMockup('{}') 
            .debugMode()
            .runCallout();
        
        AV_LogDebug.printLogDebug(methodName, '*****************************************');
        AV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());
        //Check statusCode:
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
        resultMethod.errorMessage = apiCallout.getErrorResponse();
        resultMethod.errorCode = apiCallout.getStatusCodeResponse();
        boolean reqStatusOK = apiCallout.checkErrorStatusCode();
        if(!reqStatusOK && !'500'.equalsIgnoreCase(resultMethod.statusCode)){
            CambiarGestorResponse bodyResponse = (AV_AsesorVentas_Integration.CambiarGestorResponse)apiCallout.getBodyResponse('AV_AsesorVentas_Integration.CambiarGestorResponse');
            resultMethod.errorMessage = bodyResponse.errorMessage;
            resultMethod.errorCode = bodyResponse.errorCode;
        }
                
        return resultMethod;
    }

    private static String getUserLog(){

        //String user;
        User user = [Select AV_ExternalID__c From User Where Id = :UserInfo.getUserId() limit 1];
        /*List<User> listUserLog = new AV_Query('User')
                                .selectFields('AV_ExternalID__c')
                                .addConditionEq('Id', UserInfo.getUserId())
                                .run();*/
        //if(!listUserLog.isEmpty()){
            //user = listUserLog.get(0).AV_ExternalID__c;
        //}  
        return String.valueOf(user.Id);
    }
    
}