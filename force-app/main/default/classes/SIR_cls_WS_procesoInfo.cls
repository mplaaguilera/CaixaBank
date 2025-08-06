/******************************************************************************
    Name:  SIR_cls_WS_procesoInfo
    Copyright © 2023  CaixaBank

    Proposito:   Llamada a endpoint de SIREC para saber en que tarea se encuentra un proceso

        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US448852         Atmira         07/06/2023     	  Created    

****************************************************************************************/
public with sharing class SIR_cls_WS_procesoInfo {
    
    public static List<Object> sincronizaProceso(String masteRecordId){
        List<Object> response = new List<Object>();     
        
        if(SIR_WS_Configuration__mdt.getInstance('procesoInfo').SIR_fld_isActive__c){
                
            CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
            reqWrapper.body = '';  
            reqWrapper.intSetting = SIR_cls_Utils.getActorPrefix() + 'procesoInfo';
            reqWrapper.method = 'GET';
            
            reqWrapper.mHeaders =  new  Map<String,string>();
            reqWrapper.mHeaders.put('Content-Type', 'application/json;charset=UTF-8');       
            reqWrapper.mHeaders.put('Accept-Language', 'es');
            reqWrapper.mUriParams = new  Map<String,string>();
            reqWrapper.mUriParams.put('idProceso', masteRecordId);
            reqWrapper.mQueryParams = new  Map<String,string>();
      
            response = SIR_cls_WS_SIREC.llamar(reqWrapper);               
        }else{            
            response.add('OK');
        }
        return response;
    }     
}