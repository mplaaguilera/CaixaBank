/******************************************************************************
    Name:  SIR_cls_WS_consultaPropuesta
    Copyright © 2023  CaixaBank

    Proposito:   Llamada a endpoint de SIREC para consultar el detalle de un 
                 plan de pago o acuerdo de pago

        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         04/04/2024     	  Created    

****************************************************************************************/
public with sharing class SIR_cls_WS_consultaPropuesta {
    
    public static List<Object> consultaPropuesta(String idPropuesta){
        List<Object> response = new List<Object>();     
        
        if(SIR_WS_Configuration__mdt.getInstance('consultaPropuesta').SIR_fld_isActive__c){
                
            CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
            reqWrapper.body = '';  
            reqWrapper.intSetting = SIR_cls_Utils.getActorPrefix() + 'consultaPropuesta';
            reqWrapper.method = 'GET';
            
            reqWrapper.mHeaders =  new  Map<String,string>();
            reqWrapper.mHeaders.put('Content-Type', 'application/json;charset=UTF-8');       
            reqWrapper.mHeaders.put('Accept-Language', 'es');
            reqWrapper.mUriParams = new  Map<String,string>();
            reqWrapper.mUriParams.put('idPropuesta', idPropuesta);
            reqWrapper.mQueryParams = new  Map<String,string>();
      
            response = SIR_cls_WS_SIREC.llamar(reqWrapper);               
        }else{            
            response.add('OK');
        }
        return response;
    }     
}