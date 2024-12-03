/**********************************************************************************************************************
 Name:	  EV_ConnectAPI
 Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
* @description Clase de conexión Named Credential.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US785364		Carolina Lopez    	14/12/2023			Init version
***********************************************************************************************************************/
public with sharing class EV_ConnectAPI {
    /**
 	* @description wrapper for response
 	*/
	public class Response {
		public String statusCode;
		public String errorMessage;
		public String errorCode;
	}
    /**
	 * @description  sending the request to update credentials 
	 * @param   input  -> map with credential values
     * @param   mappingExistsAlready  -> boolean value validity check
	 */
    public Response updateNamedCredential(Map<String, Object> input, Boolean mappingExistsAlready){ 
        EV_LogDebug.printLogDebug('updateNamedCredential: ', String.valueOf(input) + String.valueOf(mappingExistsAlready));
        String methodName = 'updateNamedCredential';
        AV_ApiCallout apiCallout = new AV_ApiCallout()
        .setIsActive(true)
        .setMethod(String.valueOf(mappingExistsAlready ? 'PUT' : 'POST'))
        .setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v56.0/named-credentials/credential')
        .addAuthorizationBearerHeader(UserInfo.getSessionId())
        .addContentTypeJsonHeader()
        .setBody(JSON.serialize(input))
        .setTimeout(120000)
        .debugMode()
        .runCallout();

        EV_LogDebug.printLogDebug(methodName, '*****************************************');
        EV_LogDebug.printLogDebug(methodName, 'Response: ' + apiCallout.getResponse());

        Response resultMethod = new Response();
        resultMethod.statusCode = apiCallout.getStatusCodeResponse();
		resultMethod.errorMessage = apiCallout.getErrorResponse();
		resultMethod.errorCode = apiCallout.getStatusCodeResponse();

        EV_LogDebug.printLogDebug('@@resultMethod', String.valueOf(resultMethod.statusCode) + ' '+String.valueOf(resultMethod.errorMessage));
		EV_LogDebug.printLogDebug(methodName, 'Body Response' + apiCallout.getBodyResponse());

        return resultMethod;
    }
}