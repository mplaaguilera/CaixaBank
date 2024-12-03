/*********************************************************************************
     Name:  SIRE_cls_WS_detalleDocumentoEE
    Copyright © 2023  CaixaBank
    Proposito:   Llamar al microservicio /documents/{documentId}/request de Expediente Electónico
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         02/11/2023     	  Created    

    ****************************************************************************/
public with sharing class SIRE_cls_WS_detalleDocumentoEE {

    public static List<Object> detalleDocumentoEE(Integer documentId){
        List<Object> response = new List<Object>();               
        if(SIR_WS_Configuration__mdt.getInstance('detalleDocumentoEE').SIR_fld_isActive__c){
       
           try { 
              DetalleDocumentRequest body = new DetalleDocumentRequest();
           
              CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
		      reqWrapper.body = JSON.serialize(body,true).replaceAll('transactionx', 'transaction');  
		      reqWrapper.intSetting = SIR_cls_Utils.getActorPrefix() + 'detalleDocumentoEE';
		      reqWrapper.method = 'POST';
		      
		      reqWrapper.mHeaders =  new  Map<String,string>();
              reqWrapper.mHeaders.put('Content-Type', 'application/json;charset=UTF-8');       
              reqWrapper.mUriParams = new  Map<String,string>();
              reqWrapper.mUriParams.put('documentId', String.valueOf(documentId));
              reqWrapper.mQueryParams = new  Map<String,string>();
		
              HttpRequest req = CBK_HttpServiceIntegration.getRequest(reqWrapper);              
              HttpResponse res = CBK_HttpServiceIntegration.callHttpService(req, 'SIR', reqWrapper.intSetting);                           

              if(res.getStatusCode() == 200){                
                 response.add('OK');                 
                 response.add(res.getbody());        
              }else{        
                 response.add('KO');                    
                 response.add('Se ha producido un error al llamar a Expediente Electrónico, contacte con el administrador.');      
                 response.add('Error: ' + mapHttpMsg.get(res.getStatusCode()));
                 CBK_log.error('Error : SIRE_cls_WS_detalleDocumentoEE.detalleDocumentoEE - con request ' + reqWrapper.body + ' y response ' + res.getStatusCode() + ' - ' +  res.getBody());                
              }            
         } catch (Exception ex) {
                response.add('KO');
                response.add('Se ha producido un error, contacte con el administrador.');                
                CBK_log.error(ex, 'Error : SIRE_cls_WS_detalleDocumentoEE.detalleDocumentoEE - ' + ex.getTypeName() + ': ' + ex.getMessage());                
            }                        
        }
        return response;
    }
                                                               

    public class DetalleDocumentRequest{        
        public Integer version=1;  // habría que pasarle la version del documento que nos devuelve la lista?        
        // public Relation relation= new Relation();
        public Transactionx transactionx= new Transactionx();      
    }     
        public class Relation{           
            public String operation;
            public Integer customerInternalId;
            public String applicationXFile;        
            public String extReferenceXFile;    
        }
        public class Transactionx{            
            public String application='SRC';
            public Integer branchId=9712;
            public String uploadDate;
            public String[] language;
            public String enterprise;
            public Integer accessId;
        }
  
       private static Map<Integer, String> mapHttpMsg = new Map<Integer,String>{300 => ' ', 
                                                                                400 => 'Código de documento incorrecto',
                                                                                401 => 'No autorizado',
                                                                                403 => 'Prohibido',
                                                                                404 => 'No encontrado',
                                                                                404 => 'Documento no encontrado',
                                                                                500 => 'Error en el servidor',
                                                                                503 => 'Error en el servidor'};            
}