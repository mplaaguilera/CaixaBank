/**********************************************************************************************************************
Name:	  AV_DNI_Integration
Copyright © 2024  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Handling  DNI API Callout
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY	   		AUTHOR		   			DATE				Description
    1.0			US820938	   		Luis Fernández	   	   	19/06/2024			Init version
***********************************************************************************************************************/
public with sharing class AV_DNI_Integration {


    public static final String ENDPOINTFIRSTCALL = 'AV_DNI';
    public static final String ENDPOINTSECONDCALL = 'AV_DNI_IMG';
    public static final String BINARY_CODE_KEY = 'binaryCode';
    public static final String SECOND_CALL_MAIN_KEY = 'BinaryList';
    public static final String TICKET_TYPE_KEY = 'ticketType';

    public class ApiException extends Exception{}
    @AuraEnabled
    public static Map<String,String> callDNIApi(String accountId){
        
        return handleDNIReception(accountId);
    }
 
    private static Map<String,String> handleDNIReception(String accountId){
        List<Account> acc = [SELECT Id,AV_NumPerso__c FROM Account where Id = :accountId LIMIT 1];
        if(!acc.isEmpty() && acc[0].AV_Numperso__c != null){
            String numper = acc[0].AV_Numperso__c;
            
            String anvers;
            String revers;
           
            CBK_HttpServiceIntegration.RequestWapper firstCallWrapper = new CBK_HttpServiceIntegration.RequestWapper();
            firstCallWrapper.intSetting = ENDPOINTFIRSTCALL;
            firstCallWrapper.method = AV_IntegrationConstants.HTTP_VERB_GET;
            firstCallWrapper.mHeaders = new Map<String, String>{
            'Content-Type' =>'application/json',
            'x-absis-customerInternalId' => numper
            };
            firstCallWrapper.mUriParams = new Map<String,String>{'typeofdni' => AV_AppConstants.DOCUMENT_PARAM};
            firstCallWrapper.mQueryParams = new Map<String,String>();
            HttpRequest firstCallRequest = CBK_HttpServiceIntegration.getRequest(firstCallWrapper);
            HttpResponse ticketResponse;
            try{

                ticketResponse = CBK_HttpServiceIntegration.multiCallHttpService(firstCallRequest,null,ENDPOINTFIRSTCALL);
                if(!String.valueOf(ticketResponse.getStatusCode()).equals(AV_IntegrationConstants.HTTP_STATUS_OK)){
                    throw new ApiException(ticketResponse.getBody());
                }

            }catch(Exception err){
                CBK_Log.error(err);
                return new Map<String,String>{
                'response' => 'NOK',
                'errorMessage' => err.getMessage() 
                };
            }

            CBK_HttpServiceIntegration.RequestWapper secondCallWrapper = new CBK_HttpServiceIntegration.RequestWapper();
                secondCallWrapper.intSetting = ENDPOINTSECONDCALL;
                secondCallWrapper.method = AV_IntegrationConstants.HTTP_VERB_POST;
                secondCallWrapper.mHeaders = new Map<String, String>{
                    'Content-Type' =>'application/json'
            };
            secondCallWrapper.mQueryParams = new Map<String,String>();
            
            HttpRequest finalCallRequest = CBK_HttpServiceIntegration.getRequest(secondCallWrapper);

            finalCallRequest.setBody(ticketResponse.getBody());//WE PASS THE TICKET IN ORDER TO GET THE BLOB

            HttpResponse finalCall;
            //NOW THAT WE HAVE THE TICKET,WE GET THE IMG
            try{
                finalCall = CBK_HttpServiceIntegration.multiCallHttpService(finalCallRequest,null,ENDPOINTSECONDCALL);

                if(String.valueOf(finalCall.getStatusCode()).equals(AV_IntegrationConstants.HTTP_STATUS_OK)){
                    Map<String,Object> mappedBody = (Map<String,Object>) JSON.deserializeUntyped(finalCall.getBody());
                        List<Object> infoList = (List<Object>) mappedBody.get(SECOND_CALL_MAIN_KEY);
                        for(Object param : infoList){
                            Map<String,Object> currentTicket = ( Map<String,Object>) param;
                            if(currentTicket.containsKey(BINARY_CODE_KEY)){
                                if(currentTicket.get(TICKET_TYPE_KEY).equals(AV_AppConstants.DOCUMENT_ANVERS)){
                                    anvers = (String) currentTicket.get(BINARY_CODE_KEY);
                                }
                            }
                        }
                }else{
                    throw new ApiException(finalCallRequest.getBody());

                }
            }catch(Exception err){
                CBK_Log.error(err);
                return new Map<String,String>{
                'response' => 'NOK',
                'errorMessage' => err.getMessage() 
                };
            }

            
            
            
            return new Map<String,String>{
                'response' =>  'OK',
                'anvers' => getArrayMapFromApiResponse(anvers)
            };
        }else{
            return new Map<String,String>{
                'response' => 'NOK',
                'errorMessage' => 'El cliente no tiene numperso'
            };
        }

    }  

    private static String getArrayMapFromApiResponse(String binaryCode){
        String correctKey = binaryCode.substringBetween(AV_AppConstants.DOT);
        if(correctKey != null){
            String decodedArrayMap = EncodingUtil.base64Decode(correctKey).toString();
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(decodedArrayMap);
            return (String) jsonMap.get('value');
        }else{
            return null;
        }

    }
          

}