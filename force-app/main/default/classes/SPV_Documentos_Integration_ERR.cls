public with sharing class SPV_Documentos_Integration_ERR{
    
    public static final String HEADER_CONTENT_TYPE 		= 'Content-Type';
    public static final String APPLICATION_JSON 		= 'application/json';
    private static final String SPV_GET_DOCUMENTO_EER   = 'SPV_Get_Documento_EER';
    private static final String SPV_POST_DOCUMENTO_EER  = 'SPV_Post_Documento_ERR';

    public class GetDocumentoResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public Documento documento;
    }

    public class Documento{
        @AuraEnabled
        public String file;	//R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLCAgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=
        @AuraEnabled
        public Metadata metadata;
        @AuraEnabled
        public Relation relation;
        @AuraEnabled
        public Structure structure;
    }
	public class Metadata {
		@AuraEnabled
        public Integer documentId;	//166545614
		@AuraEnabled
        public Integer version;	//1
		@AuraEnabled
        public String format;	//pdf
		@AuraEnabled
        public Integer catalogueId;	//4195
		@AuraEnabled
        public String documentDescription;	//Example document description
		@AuraEnabled
        public String monthReference;	//JANUARY_01
		@AuraEnabled
        public String yearReference;	//2023
		@AuraEnabled
        public String originId;	//OUTSOURCED_SERVICE_14
		@AuraEnabled
        public String securityLevel;	//PUBLIC_0
		@AuraEnabled
        public String valijaSignal;	//NOT_VALIJA_APPLICATION
		@AuraEnabled
        public Long ticketOCP;	//6287722695164947000
	}
	public class Relation {
		@AuraEnabled
        public Long operation;	//9999700044332
		@AuraEnabled
        public Integer customerInternalId;	//214759120
		@AuraEnabled
        public String applicationXFile;	//SRC
		@AuraEnabled
        public String extReferenceXFile;	//EXAMPLE_EXT_REF
	}
	public class Structure {
		@AuraEnabled
        public Folder folder;
		@AuraEnabled
        public SubFolder subFolder;
	}
	public class Folder {
		@AuraEnabled
        public Integer order;	//1 
		@AuraEnabled
        public String description;	//Cliente
		@AuraEnabled
        public String type;	//PERSON
	}
	public class SubFolder {
		@AuraEnabled
        public Integer order;	//2
		@AuraEnabled
        public String description;	//Fincabilidad
	}

    public class PostDocumentoResponse {
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public DocumentoDetail documentoDetail;
    }

    public class DocumentoDetail {
        @AuraEnabled
        public Metadata metadata;
        @AuraEnabled
        public Relation relation;
        @AuraEnabled
        public Structure structure;
        @AuraEnabled
        public Transaccion transactionAux;
        @AuraEnabled
        public ErrorData errorData;
    }

	public class Transaccion {
		@AuraEnabled
        public String application;	//SRC
		@AuraEnabled
        public Integer branchId;	//9712
		@AuraEnabled
        public String uploadDate;	//1675209600000
		@AuraEnabled
        public String language;	//SPANISH
		@AuraEnabled
        public String enterprise;	//001
		@AuraEnabled
        public String accessId;	//142
	}
	public class ErrorData {
		@AuraEnabled
        public String errorCode;	//ERR_65015
		@AuraEnabled
        public String errorMessage;	//A Json object containing the error data (code and error message)
	}

    //Integracion con EER para obtener el documento a partir del ticketEER
    @AuraEnabled
    public static GetDocumentoResponse getDocument(String idEER, String reclamacionId){
        
        GetDocumentoResponse responseDocumento = new GetDocumentoResponse();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put(HEADER_CONTENT_TYPE, 'application/json');
        
        CBK_HttpServiceIntegration.RequestWapper reqWap = new CBK_HttpServiceIntegration.RequestWapper();
        reqWap.body = '{"transaction": {"metadata": {"application": "SRC", "branchId": 1111}}}';
        reqWap.intSetting = SPV_GET_DOCUMENTO_EER;
        reqWap.method = 'POST';
        reqWap.mHeaders = mapHeader;
        
        HttpRequest request = CBK_HttpServiceIntegration.getRequest(reqWap);
        system.debug('Espe endpoint '+request);
        String endpoint = request.getEndpoint().replace('{documentId}', idEER);
        request.setEndpoint(endpoint);

        String dataMockup = '{"file":"R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLCAgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=","metadata":{"documentId":166545614,"version":1,"format":"pdf","catalogueId":4195,"documentDescription":"Example document description","monthReference":"JANUARY_01","yearReference":"2023","originId":"OUTSOURCED_SERVICE_14","securityLevel":"PUBLIC_0","valijaSignal":"NOT_VALIJA_APPLICATION","ticketOCP":6287722695164947905},"relation":{"operation":9999700044332,"customerInternalId":214759120,"applicationXFile":"SRC","extReferenceXFile":"EXAMPLE_EXT_REF"},"structure":{"folder":{"order":1,"description":"Cliente","type":"PERSON"},"subFolder":{"order":2,"description":"Fincabilidad"}}}';

        /**if(Test.isRunningTest()){
            dataMockup = '{"file":"R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLCAgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs=","metadata":{"documentId":166545614,"version":1,"format":"pdf","catalogueId":4195,"documentDescription":"Example document description","monthReference":"JANUARY_01","yearReference":"2023","originId":"OUTSOURCED_SERVICE_14","securityLevel":"PUBLIC_0","valijaSignal":"NOT_VALIJA_APPLICATION","ticketOCP":6287722695164947905},"relation":{"operation":9999700044332,"customerInternalId":214759120,"applicationXFile":"SRC","extReferenceXFile":"EXAMPLE_EXT_REF"},"structure":{"folder":{"order":1,"description":"Cliente","type":"PERSON"},"subFolder":{"order":2,"description":"Fincabilidad"}}}';
        }*/

        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.callHttpService(request, reclamacionId, SPV_GET_DOCUMENTO_EER);
        system.debug('Espe Response '+resp);
        
        String statusCode = String.valueOf(resp.getStatusCode());
        
        if(statusCode.equalsIgnoreCase('200')){
            responseDocumento.documento = (SPV_Documentos_Integration_ERR.Documento)getBodyResponse(resp.getbody(), 'SPV_Documentos_Integration_ERR.Documento');
            responseDocumento.statusCode = statusCode;
        }else{
            responseDocumento.statusCode = statusCode;
            responseDocumento.errorCode = 'Error en el servicio.';
            responseDocumento.errorMessage = resp.getStatus(); 
        } 
        system.debug('Espe Response Clase '+responseDocumento);
        return responseDocumento;
        
    }

    //Integracion con EER para cargar el documento y que nos devuelvan el ticketEER
    @AuraEnabled
    public static PostDocumentoResponse postDocument(String reclamacionId){

        PostDocumentoResponse response = new PostDocumentoResponse();
        SPV_RQ_Documentos_Integration.RequestDocument peticion = new SPV_RQ_Documentos_Integration.RequestDocument();
        peticion = SPV_RQ_Documentos_Integration.buildMock();
        system.debug('Espe request 1: '+peticion);
        List<ContentVersion> lstConVer = [SELECT Id, versionData, FileExtension, title FROM contentVersion];
        ContentVersion conVer = lstConVer.get(0);
        peticion.file = EncodingUtil.base64Encode(conVer.VersionData);
        system.debug('Espe file: '+peticion.file);
        system.debug('Espe request 2: '+peticion);
        String documentJSON = JSON.serialize(peticion);
        documentJSON.replace('transactionAux','transaction');
        system.debug('Espe documento: '+documentJSON);
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setHeader('Content-Type', 'multipart/form-data');
        req.setMethod('POST');
        req.setEndpoint('https://api.pre.private.cer.caixabank.com/documentLibrary/eer/documents');
        
        Blob documentBlob = EncodingUtil.base64Decode(documentJSON);
        req.setBodyAsBlob(documentBlob);
        system.debug('Espe request 3: '+req);

        String dataMockup = '{"metadata":{"documentId":166545614,"version":1, "format":"pdf","catalogueId":4195,"documentDescription":"Example document description","monthReference":"JANUARY_01", "yearReference":"2023", "originId":"OUTSOURCED_SERVICE_14","securityLevel":"PUBLIC_0","valijaSignal":"NOT_VALIJA_APPLICATION", "ticketOCP":6287722695164947905}, "relation":{"operation":9999700044332,"customerInternalId":214759120,"applicationXFile":"SRC","extReferenceXFile":"EXAMPLE_EXT_REF"}, "structure":{"folder":{"order":1,"description":"Outputs the description of the folder","type":"PERSON"},"subFolder":{"order":1,"description":"Outputs the description of the folder"}}, "transaction":{"application":"SRC","branchId":9712.0, "uploadDate":"1675209600000","language":"SPANISH", "enterprise":"001","accessId":"142"},"errorData":{"errorCode":"ERR_65015","errorMessage":"A Json object containing the error data (code and error message)"}}';
        HTTPResponse resp = String.isNotBlank(dataMockup) ? getDataMockup(dataMockup) : CBK_HttpServiceIntegration.callHttpService(req, reclamacionId, SPV_POST_DOCUMENTO_EER);

        String statusCode = String.valueOf(resp.getStatusCode());

        if(statusCode.equalsIgnoreCase('200') || statusCode.equalsIgnoreCase('201')){
            resp.getbody().replace('transaction','transactionAux');
            response.documentoDetail = (SPV_Documentos_Integration_ERR.DocumentoDetail)getBodyResponse(resp.getbody(), 'SPV_Documentos_Integration_ERR.DocumentoDetail');
            response.statusCode = statusCode;
        }else{
            response.statusCode = statusCode;
            response.errorCode = 'Error en el servicio.';
            response.errorMessage = resp.getStatus(); 
        } 
       
        return response;
    }
    
    /**
    * @description Generate the response for the mockup data
    */
    private static HTTPResponse getDataMockup(String dataMockup){
        
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(Integer.valueOf('200'));
        res.setStatus('OK');
        res.setBody(dataMockup);
        return res;
    }
    
    /**
    * @description Convertir en objeto el json de la response
    */
    private static Object getBodyResponse(String response, String clazzName){
        
        Object result = parseJsonToObject(response, clazzName);
        return result;
        
    }
    
    /**
    * @description Convertir en objeto el json de la response
    */
    private static Object parseJsonToObject(String jsonData, String jsonType){
        Type typeClass = Type.forName(jsonType);
        return System.JSON.deserializeStrict(jsonData, typeClass);
    }

}