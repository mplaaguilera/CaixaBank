/****************************************************************************************
    Name:  SIR_cls_WS_procesosAgencias
    Copyright © 2024  CaixaBank

    Proposito:   Llamada a endpoint de SIREC para consultar los procesos abiertos  
                 en agencias externas

        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         07/06/2024     	  Created    

****************************************************************************************/
public with sharing class SIR_cls_WS_procesosAgencias {
    
    public static List<Object> procesosAgencias(String idPersona, boolean historico){
        List<Object> response = new List<Object>();     
        
        if(SIR_WS_Configuration__mdt.getInstance('procesosAgencias').SIR_fld_isActive__c){
                
            CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
            ProcesosAgenciasRequest body = new ProcesosAgenciasRequest(idPersona, historico);
            reqWrapper.body = JSON.serialize(body);  
            reqWrapper.intSetting = SIR_cls_Utils.getActorPrefix() + 'procesosAgencias';
            reqWrapper.method = 'POST';
            
            reqWrapper.mHeaders =  new  Map<String,string>();
            reqWrapper.mHeaders.put('Content-Type', 'application/json;charset=UTF-8');       
            reqWrapper.mHeaders.put('Accept-Language', 'es');
            reqWrapper.mUriParams = new  Map<String,string>();
            reqWrapper.mQueryParams = new  Map<String,string>();
            
            response = SIR_cls_WS_SIREC.llamar(reqWrapper);               
        }else{            
            response.add('OK');
        }
        return response;
    }     

    public class ProcesosAgenciasRequest{
        public Blob idPersona;
        public String estadoProceso;
        
        public ProcesosAgenciasRequest(String idPersona, boolean historico){
                       
            //this.idPersona = idPersona;  
            //parametro que indica si trae los procesos historicos (C=cerrados o V=vigentes)
            this.estadoProceso = historico ? 'C' :'V';
            String skey;
            if (Test.isRunningTest()){
                //desde las clases test no se pueden llamar a ConnectApi utilizamos clave test
                sKey = SIR_Constantes.KEY_NUMPERSO_TEST;
            } else {
                // RECUPERAR LAS CLAVES DE EXTERNAL CREDENTIALS
                ConnectApi.ExternalCredential externalCred = ConnectApi.NamedCredentials.getExternalCredential(SIR_Constantes.EXT_CRED_KEY_NUMPERSO);
                ConnectApi.Credential cred = ConnectApi.NamedCredentials.getCredential(SIR_Constantes.EXT_CRED_KEY_NUMPERSO, externalCred.principals[0].principalName, ConnectApi.CredentialPrincipalType.NamedPrincipal);
                ConnectApi.CredentialValue credValueKey = cred.credentials.get(SIR_Constantes.EXT_CRED_KEY_PRINCIPAL);     
                sKey = credValueKey.value;
            }    

            ///ENCRIPTAR con claves recuperadas de External Credentials
            Blob data = Blob.valueOf(idPersona); 
            Blob bKey = EncodingUtil.base64Decode(sKey);
            this.idPersona = Crypto.encryptWithManagedIV('AES128', bKey, data);
        }
    }
}