/**********************************************************************************************************************
 Name:      AV_IntegrationConstants
 Copyright © 2020  CaixaBank
=======================================================================================================================
Proposito: Clase de constantes para integraciones
=======================================================================================================================
Historial
---------------------
   VERSION        USER_STORY       AUTHOR           DATE                Description
   1.0            Integrations     David Rufo       11/02/2020          Init version

***********************************************************************************************************************/
global with sharing class AV_IntegrationConstants {

    /**
	 * Values for Header 'Authorization'
     */
    public static final String HEADER_AUTHORIZATION = 'Authorization';
    public static final String HEADER_AUTHORIZATION_VALUE_BASIC = 'Basic ';
    public static final String HEADER_AUTHORIZATION_VALUE_BEARER = 'Bearer ';

    /**
	 * Values for Header 'Content-Type'
     */
    public static final String HEADER_CONTENT_TYPE = 'Content-Type';
    public static final String HEADER_CONTENT_TYPE_VALUE_FORM_URLENCODED = 'application/x-www-form-urlencoded';
    public static final String HEADER_CONTENT_TYPE_VALUE_JSON = 'application/json';
    public static final String HEADER_CONTENT_TYPE_VALUE_XML  = 'application/xml';

    /**
     * Values for Header 'Accept'
     */
    public static final String HEADER_ACCEPT = 'Accept';
    public static final String HEADER_ACCEPT_VALUE_JSON = 'application/json';

    /**
     * Values for Header 'X-Smart-Token'
     */
    public static final String HEADER_X_SMART_TOKEN = 'X-Smart-Token';

    /**
     * Values for Header 'Username'
     */
    public static final String HEADER_USERNAME = 'X-Username-Call';

    /**
     * Values for Header 'content-disposition'
     */
    public static final String HEADER_CONTENT_DISPOSITION = 'content-disposition';

    /**
     * Values for HTTP Verb
     */
    public static final String HTTP_VERB_POST 	= 'POST';
    public static final String HTTP_VERB_GET 	= 'GET';
    public static final String HTTP_VERB_PUT 	= 'PUT';
    public static final String HTTP_VERB_PATCH 	= 'PATCH';
    public static final String HTTP_VERB_DELETE = 'DELETE';


    /**
     * Values return connection REST
     */
    public static final String HTTP_STATUS_OK 						= '200';
    public static final String HTTP_STATUS_CREATED					= '201';
    public static final String HTTP_STATUS_ACCEPTED					= '202';
    public static final String HTTP_STATUS_NO_CONTENT				= '204';
    public static final String HTTP_STATUS_MOVED_PERMANENTLY		= '301';
    public static final String HTTP_STATUS_SEE_OTHER				= '303';
    public static final String HTTP_STATUS_NOT_MODIFIED				= '304';
    public static final String HTTP_STATUS_TEMPORARY_REDIRECT		= '307';
    public static final String HTTP_STATUS_BAD_REQUEST				= '400';
    public static final String HTTP_STATUS_UNAUTHORIZED				= '401';
    public static final String HTTP_STATUS_FORBIDDEN 				= '403';
    public static final String HTTP_STATUS_NOT_FOUND 				= '404';
    public static final String HTTP_STATUS_NOT_ACCEPTABLE			= '406';
    public static final String HTTP_STATUS_CONFLICT 				= '409';
    public static final String HTTP_STATUS_GONE	 					= '410';
    public static final String HTTP_STATUS_PRECONDITION_FAILED 		= '412';
    public static final String HTTP_STATUS_UNSUPPORTED_MEDIA_TYPE 	= '415';
    public static final String HTTP_STATUS_SERVER_ERROR 			= '500';
    public static final String HTTP_STATUS_SERVICE_UNAVAILABLE 		= '503';

    /**
     * Values for enconding
     */
    public static final String ENCONDING_UTF8 = 'UTF-8';

    /**
     * HTTP PROTOCOLS
     */
    public static final String HTTP_PROTOCOL    = 'http';
    public static final String HTTPS_PROTOCOL   = 'https';
    public static final String CALLOUT          = 'callout:';

    /**
     * Values return for method 'getResponseRest'
     */
    public static final Integer REQUEST_REST_TIMEOUT        = 60000;
    public static final String RESPONSE_REST_STATUS         = 'Status';
    public static final String RESPONSE_REST_STATUS_CODE    = 'StatusCode';
    public static final String RESPONSE_REST_BODY           = 'Body';
    public static final String RESPONSE_REST_BODY_BLOB      = 'BodyBlob';
    public static final String RESPONSE_REST                = 'Response';
    public static final String RESPONSE_REST_TIME_ELAPSED   = 'TimeElapsed';
    public static final String RESPONSE_REST_ERROR          = 'ErrorDetail';

    public static final String REQUEST_REST_NO_SEND_IN_REQ          = 'NoSend-';
    public static final String REQUEST_REST_TYPE_OPERATION          = REQUEST_REST_NO_SEND_IN_REQ + 'TypeOperation';
    public static final String REQUEST_REST_ID_ENT_SF               = REQUEST_REST_NO_SEND_IN_REQ + 'IdEntitySalesforce';
    public static final String REQUEST_REST_ID_ENT_EXT              = REQUEST_REST_NO_SEND_IN_REQ + 'IdExternalEntity';
    public static final String REQUEST_REST_TYPE_COMMUNICATION      = REQUEST_REST_NO_SEND_IN_REQ + 'TypeCommunication';

}