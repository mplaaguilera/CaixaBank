/**********************************************************************************************************************
 Name:      AV_ApiCallout
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Class for callouts
 - Status of the callout (Default: true)
 - Http verb (PUT,POST,DELETE,GET,...)
 - Endpoint of server
 - List of properties for header
 - Data of request body
 - Name of the certificate for the connection with the back-end
 - Timeout of the request (Default: 120000 milliseconds)
 - Export the full response (Default: false)
 - Export the body as blob (Default: false)
 - Print the log of the request and response (Default: false)
 - Response of the callout
 - Error with the severity + details message
 - Flag to indicate if the request is SOAP
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            Integrations     David Rufo       12/02/2020          Init version

***********************************************************************************************************************/
public with sharing class AV_ApiCallout {

    @TestVisible private Boolean isActive;               //Status of the callout (Default: true)
    @TestVisible private String method;                  //Http verb (PUT,POST,DELETE,GET,...)
    @TestVisible private String endpoint;                //Endpoint of server
    @TestVisible private Map<String, String> headers;    //List of properties for header
    private Object body;                    //Data of request body
    private String certificate;             //Name of the certificate for the connection with the back-end
    @TestVisible private Integer timeout;                //Timeout of the request (Default: 120000 milliseconds)
    @TestVisible private Boolean exportFullResponse;     //Export the full response (Default: false)
    private Boolean exportBodyAsBlob;       //Export the body as blob (Default: false)
    @TestVisible private Boolean debugMode;              //Print the log of the request and response (Default: false)
    private String dataMockup;              //String for the mockup (Default: empty)
    @TestVisible private Map<String, Object> response;   //Response of the callout
    @TestVisible private ErrorMessage errorMessage;      //Error with the severity + details message
    private Boolean isSOAP;           //Flag to indicate is the request is SOAP (Default: false)

    public class ErrorMessage {
        public String severity;
        public String msg;
    }

    /**
     * Constructor of the callout
     */
    public AV_ApiCallout(){
        this.headers = new Map<String, String>();
        this.timeout = AV_IntegrationConstants.REQUEST_REST_TIMEOUT;
        this.exportFullResponse = false;
        this.exportBodyAsBlob = false;
        this.response = new Map<String, Object>();
        this.debugMode = false;
        this.dataMockup = null;
        this.errorMessage = null;
        this.isSOAP = false;
    }

    /**
     * Flag to indicate if the callout should be executed or not (Default: false)
     * @param isActive      -> flag to indicate the status of the integration
     */
    public AV_ApiCallout setIsActive(Boolean isActive){
        if (isActive==null){
            throw new AV_ApplicationException('Illegal Arguments: \'isActive\' attribute cannot be null');
        }
        this.isActive = isActive;
        return this;
    }

    /**
     * Set the method of the callout
     * @param method    -> http verb of the callout (POST, GET, DELETE, PUT, PATCH,...)
     */
    public AV_ApiCallout setMethod(String method){
        if (String.isBlank(method)){
            throw new AV_ApplicationException('Illegal Arguments: \'method\' attribute cannot be empty');
        }
        this.method = method;
        return this;
    }

    /**
     * Set the endpoint of the callout.
     * If the endpoint doesn't start by 'http(s)' then will try to connect through Named Credential's.
     * @param endpoint  -> endpoint to connect with the back-end
     */
    public AV_ApiCallout setEndpoint(String endpoint){
        if (String.isBlank(endpoint)){
            throw new AV_ApplicationException('Illegal Arguments: \'endpoint\' attribute cannot be empty');
        }
        //If it doesn't start by callout nor by http, concatenate 'callout'
        if (!endpoint.startsWithIgnoreCase(AV_IntegrationConstants.CALLOUT) && !endpoint.startsWithIgnoreCase(AV_IntegrationConstants.HTTP_PROTOCOL)){
            this.endpoint = AV_IntegrationUtilities.getEndpoint(endpoint);
        }else{
            this.endpoint = endpoint;
        }
        return this;
    }

    /**
     * Put all the headers
     * @param headers -> map with all the headers
     */
    public AV_ApiCallout setHeaders(Map<String, String> headers){
        if (headers==null || headers.isEmpty()){
            throw new AV_ApplicationException('Illegal Arguments: params attribute cannot be empty');
        }
        if (this.headers==null){
            this.headers = new Map<String, String>();
        }
        this.headers.putAll(headers);
        return this;
    }

    /**
     * Add the key and value in the list of headers.
     * @param key   -> key of the header
     * @param val   -> value of the header
     */
    public AV_ApiCallout addHeader(String key, String val){
        if (String.isBlank(key)){
            throw new AV_ApplicationException('Illegal Arguments: \'key\' attribute cannot be empty');
        }
        if (String.isBlank(val)){
            throw new AV_ApplicationException('Illegal Arguments: \'val\' attribute cannot be empty');
        }
        if (this.headers==null){
            this.headers = new Map<String, String>();
        }
        this.headers.put(key, val);
        return this;
    }

    /**
     * Add the content type JSON into the header
     */
    public AV_ApiCallout addContentTypeJsonHeader(){
        if (this.headers==null){
            this.headers = new Map<String, String>();
        }
        this.headers.put(AV_IntegrationConstants.HEADER_CONTENT_TYPE, AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_JSON);
        return this;
    }

    /**
     * Add the content type XML into the header
     */
    public AV_ApiCallout addContentTypeXmlHeader(){
        if (this.headers==null){
            this.headers = new Map<String, String>();
        }
        this.headers.put(AV_IntegrationConstants.HEADER_CONTENT_TYPE, AV_IntegrationConstants.HEADER_CONTENT_TYPE_VALUE_XML);
        this.isSOAP = true;
        return this;
    }

    /**
     * Add the token into authorization header (Basic)
     */
    public AV_ApiCallout addAuthorizationBasicHeader(String token){
        if (String.isBlank(token)){
            throw new AV_ApplicationException('Illegal Arguments: \'token\' attribute cannot be empty');
        }
        if (this.headers==null){
            this.headers = new Map<String, String>();
        }
        this.headers.put(AV_IntegrationConstants.HEADER_AUTHORIZATION, AV_IntegrationConstants.HEADER_AUTHORIZATION_VALUE_BASIC + token);
        return this;
    }

    /**
     * Add the token into authorization header (Bearer)
     */
    public AV_ApiCallout addAuthorizationBearerHeader(String token){
        if (String.isBlank(token)){
            throw new AV_ApplicationException('Illegal Arguments: \'token\' attribute cannot be empty');
        }
        if (this.headers==null){
            this.headers = new Map<String, String>();
        }
        this.headers.put(AV_IntegrationConstants.HEADER_AUTHORIZATION, AV_IntegrationConstants.HEADER_AUTHORIZATION_VALUE_BEARER + token);
        return this;
    }

    /**
     * Add the salesforce username to the header
     */
    public AV_ApiCallout addUsernameHeader(){
        if (this.headers==null){
            this.headers = new Map<String, String>();
        }
        this.headers.put(AV_IntegrationConstants.HEADER_USERNAME, System.UserInfo.getUserName());
        return this;
    }

    /**
     * Set the body of the callout
     * @param body             -> set the body of the request
     * @param serializeBody    -> flag to indicate if the body should be convert to JSON (true), false in other case
     */
    public AV_ApiCallout setBody(Object body){
        if (body==null){
            throw new AV_ApplicationException('Illegal Arguments: \'body\' attribute cannot be empty');
        }
        if (!(body instanceof String)){
            this.body = AV_IntegrationUtilities.parseObjectToJson(body);
        }else{
            this.body = body;
        }
        return this;
    }

    /**
     *  Set the certificate chain in the request. (Only API Name)
     *  The configuration of the certificate should be include in salesforce "Certificate and Key Management"
     * @param certificate -> API Name of the certificate
     */
    public AV_ApiCallout setCertificate(String certificate){
        if (String.isBlank(certificate)){
            throw new AV_ApplicationException('Illegal Arguments: \'certificate\' attribute cannot be empty');
        }
        this.certificate = certificate;
        return this;
    }

    /**
     * Set the callout in mockup mode.
     * When this attribute contain data then the callout is not executed
     * @param dataMockup    -> Body response with the mockup data
     */
    public AV_ApiCallout setDataMockup(String dataMockup){
        if (String.isBlank(dataMockup)){
            throw new AV_ApplicationException('Illegal Arguments: \'dataMockup\' attribute cannot be empty');
        }
        this.dataMockup = dataMockup;
        return this;
    }

    /**
     * Set the callout in mockup mode.
     * When this attribute contain data then the callout is not executed
     * @param dataMockup    -> Body response with the mockup data
     */
    public AV_ApiCallout setDataMockup(Object dataMockup){
        if (dataMockup==null){
            throw new AV_ApplicationException('Illegal Arguments: \'dataMockup\' attribute cannot be empty');
        }
        this.dataMockup = AV_IntegrationUtilities.parseObjectToJson(dataMockup);
        return this;
    }

    /**
     * Set the value of the callout (Default: 60000 milliseconds)
     * @param timeout   -> value in milliseconds (max value 120000 milliseconds)
     */
    public AV_ApiCallout setTimeout(Integer timeout){
        if (timeout==null){
            throw new AV_ApplicationException('Illegal Arguments: \'timeout\' attribute cannot be null');
        }
        this.timeout = timeout;
        return this;
    }

    /**
     * Flag to indicate if the full response of the callout is include in the result of the method "runCallout"
     * @param exportFullResponse    -> possible values: true or false
     */
    public AV_ApiCallout setExportFullResponse(Boolean exportFullResponse){
        if (exportFullResponse==null){
            throw new AV_ApplicationException('Illegal Arguments: \'exportFullResponse\' attribute cannot be null');
        }
        this.exportFullResponse = exportFullResponse;
        return this;
    }

    /**
     * Flag to export the body as blob
     * @param exportBodyAsBlob  -> possible values: true or false
     */
    public AV_ApiCallout setExportBodyAsBlob(Boolean exportBodyAsBlob){
        if (exportBodyAsBlob==null){
            throw new AV_ApplicationException('Illegal Arguments: \'exportBodyAsBlob\' attribute cannot be null');
        }
        this.exportBodyAsBlob = exportBodyAsBlob;
        return this;
    }

    /**
     * Add parameters to the request
     * @param params -> map of the parameters: key - value
     */
    public AV_ApiCallout addQueryString(Map<String,String> params){
        if (String.isBlank(this.endpoint)){
            throw new AV_ApplicationException('Illegal Arguments: \'endpoint\' attribute cannot be empty');
        }
        if (params==null || params.isEmpty()){
            throw new AV_ApplicationException('Illegal Arguments: \'params\' attribute cannot be empty');
        }
        this.endpoint = AV_IntegrationUtilities.addQueryString(this.endpoint, params);
        return this;
    }

    /**
     * Activate the debug mode
     */
    public AV_ApiCallout debugMode(){
        this.debugMode = true;
        return this;
    }

    /**
     * Print the content of the current object
     */
    public AV_ApiCallout print(){
        AV_LogDebug.printLogDebug('print', this.toString());
        return this;
    }

    /**
     * Get the response of the callout
     */
    public Map<String, Object> getResponse(){
        return this.response;
    }

    /**
     * Check if th status code is error or not.
     * Usually the responses accepted are: 200, 201 or 204
     */
    public boolean checkErrorStatusCode(){
        Set<String> httpStatusList = new Set<String>();
        httpStatusList.add(AV_IntegrationConstants.HTTP_STATUS_OK);
        httpStatusList.add(AV_IntegrationConstants.HTTP_STATUS_CREATED);
        httpStatusList.add(AV_IntegrationConstants.HTTP_STATUS_ACCEPTED);
        return this.checkErrorStatusCode(httpStatusList);
    }

    /**
     * Check if th status code is error or not.
     * @param httpStatusList    -> list of the valid status.
     */
    public boolean checkErrorStatusCode(Set<String> httpStatusList){
        if (httpStatusList==null || httpStatusList.isEmpty()){
            throw new AV_ApplicationException('Illegal Arguments: \'httpStatusList\' attribute cannot be empty');
        }
        if (response==null || response.isEmpty()) {
            throw new AV_ApplicationException('No response data found');
        }
        return httpStatusList.contains(getStatusCodeResponse());
    }

    /**
     * Retrieve the status code of the response
     */
    public String getStatusCodeResponse(){
        if (response==null || response.isEmpty()) {
            throw new AV_ApplicationException('No response data found');
        }
        return (String)response.get(AV_IntegrationConstants.RESPONSE_REST_STATUS_CODE);
    }

    /**
     * Retrieve the status of the response
     */
    public String getStatusResponse(){
        if (response==null || response.isEmpty()) {
            throw new AV_ApplicationException('No response data found');
        }
        return (String)response.get(AV_IntegrationConstants.RESPONSE_REST_STATUS);
    }

    /**
     * Retrieve the body response
     */
    public String getBodyResponse(){
        if (response==null || response.isEmpty()) {
            throw new AV_ApplicationException('No response data found');
        }
        String result = null;
        if (!exportFullResponse) {
            result = (String)response.get(AV_IntegrationConstants.RESPONSE_REST_BODY);
            if (String.isBlank(result)) {
                throw new AV_ApplicationException('The body response is empty');
            }
        }else{
            HTTPResponse response = (HTTPResponse)response.get(AV_IntegrationConstants.RESPONSE_REST);
            if (response==null || String.isBlank(response.getBody())) {
                throw new AV_ApplicationException('The body response is empty');
            }
            result = response.getBody();
        }
        return result;
    }

    /**
     * Retrieve the body response
     */
    public Dom.Document getBodyResponseDocument(){
        if (response==null || response.isEmpty()) {
            throw new AV_ApplicationException('No response data found');
        }
        dom.Document result = null;
        if (!exportFullResponse) {
            String res = (String)response.get(AV_IntegrationConstants.RESPONSE_REST_BODY);
            if (String.isBlank(res)) {
                throw new AV_ApplicationException('The body response is empty');
            }
            result = new Dom.Document();
            result.load(res);
        }else{
            HTTPResponse response = (HTTPResponse)response.get(AV_IntegrationConstants.RESPONSE_REST);
            if (response==null || String.isBlank(response.getBody())) {
                throw new AV_ApplicationException('The body response is empty');
            }
            result = new Dom.Document();
            result.load(response.getBody());
        }
        return result;
    }

    /**
     * @return  -> retrieve the result of the response in object data
     */
    public Object getBodyResponse(String clazzName){
        if (response==null || response.isEmpty()) {
            throw new AV_ApplicationException('No response data found');
        }
        Object result = null;
        if (!exportFullResponse) {
            String bodyResponse = (String)response.get(AV_IntegrationConstants.RESPONSE_REST_BODY);
            if (String.isBlank(bodyResponse)) {
                throw new AV_ApplicationException('The body response is empty');
            }
            String jsonReplace =  bodyResponse.replace('"time":', '"time_Z":');
            jsonReplace =  jsonReplace.replace('"date":', '"date_Z":');
            jsonReplace =  jsonReplace.replace('"trigger":', '"trigger_Z":');
            //jsonReplace = jsonReplace.replace('"isTarget":false', '"isTarget":true');
            result = AV_IntegrationUtilities.parseJsonToObject(jsonReplace, clazzName);
        }else{
            HTTPResponse httpResponse = (HTTPResponse)response.get(AV_IntegrationConstants.RESPONSE_REST);
            if (httpResponse==null || String.isBlank(httpResponse.getBody())) {
                throw new AV_ApplicationException('The body response is empty');
            }
            result = AV_IntegrationUtilities.parseJsonToObject(httpResponse.getBody(), clazzName);
        }
        return result;
    }

    /**
     * @return  -> Error of the response
     */
    public String getErrorResponse(){
        if (response==null || response.isEmpty()) {
            throw new AV_ApplicationException('No response data found');
        }
        return (String)response.get(AV_IntegrationConstants.RESPONSE_REST_ERROR);
    }

    /**
     * @return  -> Retrieve the error message to display into screen
     */
    public ErrorMessage getMsgUserError(){
        this.errorMessage = new ErrorMessage();
        String errorResponse = this.getErrorResponse();
        if (String.isBlank(errorResponse)){
            errorResponse = this.getBodyResponse();
        }
        this.errorMessage.msg = Label.AV_UnknownError + AV_AppConstants.HTML_BREAKLINE
                                + Label.AV_MoreInfo + AV_AppConstants.HTML_BREAKLINE + '<i>' + errorResponse + '</i>';
        this.errorMessage.severity = AV_AppConstants.ERROR;
        return this.errorMessage;
    }

    /**
     * @return  -> Retrieve the default error message to display into screen
     */
    public static ErrorMessage getDefaultMsgError(String msg){
        ErrorMessage errorMessage = new ErrorMessage();
        errorMessage.msg = Label.AV_UnknownError;
        if (String.isNotBlank(msg)) {
            errorMessage.msg += AV_AppConstants.HTML_BREAKLINE + Label.AV_MoreInfo
                                + AV_AppConstants.HTML_BREAKLINE + '<i>' + msg + '</i>';
        }
        errorMessage.severity = AV_AppConstants.ERROR;
        return errorMessage;
    }

    /**
     * @description             Invoke for get response of endpoint by Rest Full
     * @param metadataCallout   Metadata of the callout
     * @return                  Map with result of the response
     *                          -> exportFullResponse (true): retrieve the key AV_IntegrationConstants.RESPONSE_REST
     *                          -> exportFullResponse (false): retrieve the key's:
     *                                  - AV_IntegrationConstants.RESPONSE_REST_STATUS_CODE
     *                                  - AV_IntegrationConstants.RESPONSE_REST_STATUS
     *                                  - AV_IntegrationConstants.RESPONSE_REST_BODY
     *                                  - AV_IntegrationConstants.RESPONSE_REST_BODY_BLOB (if exportBodyAsBlob equal true)
     *
     *                          If there are error then retrieve the key's:
     *                                  - AV_IntegrationConstants.RESPONSE_REST_STATUS_CODE
     *                                  - AV_IntegrationConstants.RESPONSE_REST_ERROR
     */
    public AV_ApiCallout runCallout() {
        String methodName = 'runCallout';
        if (String.isBlank(method) || String.isBlank(endpoint)){
            String msg = 'Illegal Arguments: \'method\' or \'endpoint\' attributes cannot be empty';
            if (debugMode) {
                AV_LogDebug.printLogDebug(methodName, msg);
            }
            throw new AV_ApplicationException(msg);
        }

        //Check if the callout is active
        if (!isActive){
            String msg = 'The API callout is not active';
            AV_LogDebug.printLogInfo(methodName, msg);
            throw new AV_ApplicationException(msg);
        }

        //Time execution init
        decimal currentTime = System.now().getTime();

        Map<String, Object> result = new Map<String, Object>();
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod(method);
            req.setTimeout(timeout);

            //Set the headers in the request
            if (headers!=null && !headers.isEmpty()){
                for (String key : headers.keySet()) {
                    String val = headers.get(key);
                    if (String.isNotBlank(val) && !val.startsWithIgnoreCase(AV_IntegrationConstants.REQUEST_REST_NO_SEND_IN_REQ)){
                        req.setHeader(key, val);
                    }
                }
            }

            //Set data of body
            if (body!=null){
                req.setBody(String.valueOf(body));
                body = null;        //Clean memory
            }

            //Set certificate
            if (String.isNotBlank(certificate)) {
                req.setClientCertificateName(certificate);
            }
            
            //Set endpoint
            req.setEndpoint(endpoint);
            //Execute web service call here
            Http http = new Http();
            HTTPResponse res = String.isNotBlank(dataMockup) ? getDataMockup() : http.send(req);
            if (this.debugMode){
                AV_LogDebug.printLogDebug(methodName, 'Request: ' + req);
                AV_LogDebug.printLogDebug(methodName, 'Body: ' + req.getBody());
                AV_LogDebug.printLogDebug(methodName, 'Response: ' + res);
            }

            //Put in the result the values get of response
            if (!exportFullResponse) {
                result.put(AV_IntegrationConstants.RESPONSE_REST_STATUS_CODE, String.valueOf(res.getStatusCode()));
                result.put(AV_IntegrationConstants.RESPONSE_REST_STATUS, String.valueOf(res.getStatus()));
                result.put(AV_IntegrationConstants.RESPONSE_REST_BODY, res.getBody());
                if (exportBodyAsBlob) {
                    result.put(AV_IntegrationConstants.RESPONSE_REST_BODY_BLOB, res.getBodyAsBlob());
                }
            }
            else {
                result.put(AV_IntegrationConstants.RESPONSE_REST, res);
            }
        } catch(System.CalloutException ce) {
            AV_LogDebug.printException(methodName, ce);
            result = new Map<String, Object>();
            result.put(AV_IntegrationConstants.RESPONSE_REST_STATUS_CODE, AV_IntegrationConstants.HTTP_STATUS_SERVER_ERROR);
            result.put(AV_IntegrationConstants.RESPONSE_REST_ERROR, ce.getMessage());
        }

        //Calculate time execution callout
        decimal timeCallout = null;
        if (result!=null){
            //Time final
            decimal currentTime2 = System.now().getTime();
            timeCallout = currentTime2 - currentTime;
            result.put(AV_IntegrationConstants.RESPONSE_REST_TIME_ELAPSED, timeCallout);
        }

        this.response.putAll(result);
        return this;
    }


    /**
     * Generate the response for the mockup data
     */
    private HTTPResponse getDataMockup(){
        AV_LogDebug.printLogDebug('getDataMockup', 'Data mockup activated');
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(Integer.valueOf(AV_IntegrationConstants.HTTP_STATUS_OK));
        res.setStatus('OK');
        res.setBody(this.dataMockup);
        this.exportFullResponse = false;
        return res;
    }
}