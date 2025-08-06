/**********************************************************************************************************************
 Name:	  EV_TokenHelper
 Copyright © 2020  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
* @description Permite la verificación y actualización de tokens de seguridad y sesiones en el contexto de Named Credentials.
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY		AUTHOR				DATE				Description
	1.0			US785364		Carolina Lopez    	14/12/2023			Init version
    1.1         FIX             Carolina Lopez      14/02/2024          Add method getPrincipalByName.
***********************************************************************************************************************/
public with sharing class EV_TokenHelper {
    private static final String CREDENTIALNAME_TOKEN_SECURITY = 'SECURITY';
    private static final String CREDENTIALNAME_TOKEN_SESSION = 'SESSION';
    private static final String CREDENTIALNAME_EXPIRES = 'EXPIRES';
    private static final String CREDENTIALNAME_SFTOKEN = 'SFTokens';
    @TestVisible
    private static Map<String, Map<String, Map<ConnectApi.CredentialPrincipalType, ConnectApi.Credential>>> getCredentialTestResults;
    /**
	* @description  getCredential 
	* @param   externalCredential  -> External credential name
	* @param   principalName  -> principal name 
	* @param   principalType  -> type
	*/
    private ConnectApi.Credential getExtCredential(String externalCredential, String principalName, ConnectApi.CredentialPrincipalType principalType){
        if(Test.isRunningTest() && getCredentialTestResults != null){
            return getCredentialTestResults.get(externalCredential).get(principalName).get(principalType);
        }
        return ConnectApi.NamedCredentials.getCredential(externalCredential, principalName, principalType);
    }
    /**
	* @description  getPrincipalByName 
	* @param   principalList  -> list principal
	* @param   principalName  -> principal name 
	*/
    private ConnectApi.ExternalCredentialPrincipal getPrincipalByName(List<ConnectApi.ExternalCredentialPrincipal> principalList, String xprincipalName){
        if(!principalList.isEmpty()){
            for (ConnectApi.ExternalCredentialPrincipal principal : principalList) {
                if (principal.principalName.equals(xprincipalName)) {
                    return principal;
                }
            }
        }
        return null;
    }
    /**
	 * @description  check token validity 
	 * @param   externalCredName  -> External credential name
	*/
    public static Boolean checkTokenValidity(String externalCredName){
        String methodName = 'checkTokenValidity';
        EV_LogDebug.printLogDebug(methodName, '@@Entra');
        EV_TokenHelper insToken = new EV_TokenHelper();
        ConnectApi.ExternalCredential externalCred = ConnectApi.NamedCredentials.getExternalCredential(externalCredName);
        ConnectApi.ExternalCredentialPrincipal principalExt = insToken.getPrincipalByName(externalCred.principals, CREDENTIALNAME_SFTOKEN);
        if(externalCred != null && !String.isBlank(String.valueOf(principalExt.principalName))){ 
            ConnectApi.Credential cred = insToken.getExtCredential(externalCredName, principalExt.principalName, ConnectApi.CredentialPrincipalType.NamedPrincipal);
            if(cred != null && cred.credentials.containsKey(CREDENTIALNAME_TOKEN_SECURITY) && 
                cred.credentials.containsKey(CREDENTIALNAME_TOKEN_SESSION) && 
                cred.credentials.containsKey(CREDENTIALNAME_EXPIRES)){
                ConnectApi.CredentialValue expires = cred.credentials.get(CREDENTIALNAME_EXPIRES);
                return (expires.value != null && (Datetime.valueOf(expires.value) < Datetime.now())); 
            }else{
                return true; 
            }
        }
        return false;
    }
    /**
	 * @description  update the parameters
	 * @param   externalCredName  -> External credential name
     * @param   newSecurityToken -> security credentials
     * @param   newSessionToken -> session credentials
     * @param   expires -> expiration date
	 */
    public static void updateToken(String externalCredName, String newSecurityToken, String newSessionToken, Datetime expires){
        String methodName = 'updateToken';
        EV_TokenHelper insToken = new EV_TokenHelper();
        ConnectApi.ExternalCredential externalCred = ConnectApi.NamedCredentials.getExternalCredential(externalCredName);
        if(externalCred != null && !externalCred.principals.isEmpty()){
            ConnectApi.ExternalCredentialPrincipal principalExt = insToken.getPrincipalByName(externalCred.principals, CREDENTIALNAME_SFTOKEN);
            ConnectApi.Credential cred = insToken.getExtCredential(externalCredName, principalExt.principalName, ConnectApi.CredentialPrincipalType.NamedPrincipal);
            if(cred != null){
                Boolean mappingExistsAlready = true;
                Map<String, Object> input = convertCredToInput(cred);
                if(((Map<String, Map<String, Object>>)input.get('credentials')).keySet().isEmpty()){
                    mappingExistsAlready = false;
                }
                ((Map<String, Map<String, Object>>)input.get('credentials')).put(CREDENTIALNAME_TOKEN_SECURITY, new Map<String, Object>{
                        'encrypted' => false,
                        'value' => newSecurityToken
                });
                ((Map<String, Map<String, Object>>)input.get('credentials')).put(CREDENTIALNAME_TOKEN_SESSION, new Map<String, Object>{
                        'encrypted' => false,
                        'value' => newSessionToken
                });
                ((Map<String, Map<String, Object>>)input.get('credentials')).put(CREDENTIALNAME_EXPIRES, new Map<String, Object>{
                        'encrypted' => false,
                        'value' => String.valueOf(expires) 
                });
                EV_ConnectAPI conAPI = new EV_ConnectAPI();
                EV_ConnectAPI.Response resp = conAPI.updateNamedCredential(input, mappingExistsAlready);
            }else{
                EV_LogDebug.printLogDebug(methodName, '@@ELSE');
            }   
        }
    }
    /**
	 * @description  Retrieve credentials mapping 
     * @param   cred -> current credentials
	 */
    public static Map<String, Object> convertCredToInput(ConnectApi.Credential cred){
        Map<String, Object> input = new Map<String, Object>();
        input.put('authenticationProtocol', String.valueOf(cred.authenticationProtocol));
        input.put('externalCredential', String.valueOf(cred.externalCredential));
        input.put('principalName', String.valueOf(cred.principalName));
        input.put('principalType', String.valueOf(cred.principalType));
        Map<String, Map<String, Object>> credentials = new Map<String, Map<String, Object>>(); 
        for(String credKey : cred.credentials.keySet()){
            ConnectApi.CredentialValue credValue = cred.credentials.get(credKey);
            credentials.put(credKey, new Map<String, Object>{
                'value' => credValue.value, 
                'encrypted' => credValue.encrypted
            });
        }
        input.put('credentials', credentials);
        return input;
    } 
}