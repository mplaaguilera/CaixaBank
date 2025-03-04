/**********************************************************************************************************************
 Name:	  CBK_ToolingApiQuery
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Propósito: Framework utilizado para consultas/queries vía ToolingAPI
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			US868474		    Jose Manuel   	    17/10/2024		    Init version
***********************************************************************************************************************/
public with sharing class CBK_ToolingApiQuery {
    public static Map<String, Object> getInfo(String query, Boolean bInsertTraza){

        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
        oTraza.Name = 'CBK_ToolingApiQuery';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_FinOK__c = false;
        String sSessionId = UserInfo.getSessionId();
        oTraza.CC_Identificador__c = (String.isNotBlank(sSessionId) && sSessionId.length() > 100)? sSessionId.substring(0, 99) : sSessionId;

        CBK_HttpServiceIntegration.RequestWapper req = new CBK_HttpServiceIntegration.RequestWapper();
        Map<String, String> mHeaders =  new  Map<String,String>();
        Map<String, Object> responseMap = new Map<String, Object>();

        mHeaders.put('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.intSetting = 'CBK_ToolingQuery';
        req.mHeaders = mHeaders;

        try {
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(req);
            if(request != null){
                String urlWithQuery = request.getEndpoint() + query;
                request.setEndpoint(urlWithQuery);
                oTraza.CC_MensajeEntrada__c = String.valueOf(urlWithQuery);
                HttpResponse response = CBK_HttpServiceIntegration.multicallHttpService(request, '', req.intSetting);
        
                if (response != null && response.getStatusCode() == 200 && response.getBody() != null) {
                    oTraza.CC_MensajeSalida__c = response.getStatusCode() + ' - ' + response.getBody();
                    oTraza.CC_FinOK__c = true;
                    responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());      
                } else {
                    if (response == null) {
                        oTraza.CC_MensajeSalida__c = 'Conexión no realizada';
                    } else if (response.getBody() != null){
                        oTraza.CC_MensajeSalida__c = response.getStatusCode() + ' - ' + response.getBody();
                    }
                }
            }    
        } catch (Exception e) {
            oTraza.CC_TipoError__c = 'Error comunicaciones.';
            oTraza.CC_DetalleError__c = e.getStackTraceString();
        }

        oTraza.CC_FechaFin__c = datetime.now();
        if(bInsertTraza){
            insert oTraza;
        }else{
            responseMap.put('TrazaInt', oTraza);
        }
        
        return responseMap;
    }
}