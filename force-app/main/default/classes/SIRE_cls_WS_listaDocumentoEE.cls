/*********************************************************************************
     Name:  SIRE_cls_WS_listaDocumentoEE
    Copyright © 2023  CaixaBank
    Proposito:   Llamar al microservicio listDocuments de Expediente Electónico
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         02/11/2023     	  Created    

    ****************************************************************************/
public with sharing class SIRE_cls_WS_listaDocumentoEE {

    public static List<Object> listaDocumentoEE(String numPerso){
        // Numero de persona que en TST tiene lista de documntos y que el detalle trae el file
         //numperso='1352897';
       
        List<Object> response = new List<Object>();               
        if(SIR_WS_Configuration__mdt.getInstance('listaDocumentoEE').SIR_fld_isActive__c){
       
           try { 
              ListDocumentsRequest body = new ListDocumentsRequest(numPerso);
              
              CBK_HttpServiceIntegration.RequestWapper reqWrapper =  new CBK_HttpServiceIntegration.RequestWapper();
		      reqWrapper.body = JSON.serialize(body,true).replaceAll('transactionx', 'transaction');  
		      reqWrapper.intSetting = SIR_cls_Utils.getActorPrefix() + 'listaDocumentoEE';
		      reqWrapper.method = 'POST';

              reqWrapper.mHeaders =  new  Map<String,string>();
              reqWrapper.mHeaders.put('Content-Type', 'application/json;charset=UTF-8');       
              reqWrapper.mUriParams = new  Map<String,string>();
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
                 CBK_log.error('Error : SIRE_cls_WS_listaDocumentoEE.listaDocumentoEE - con request ' + reqWrapper.body + ' y response ' + res.getStatusCode() + ' - ' +  res.getBody());                
              }            
         } catch (Exception ex) {
                response.add('KO');
                response.add('Se ha producido un error, contacte con el administrador.');                
                CBK_log.error(ex, 'Error : SIRE_cls_WS_listaDocumentoEE.listaDocumentoEE - ' + ex.getTypeName() + ': ' + ex.getMessage());                
            }                        
        }
        return response;
    }
                                                               

    public class ListDocumentsRequest{
        public Relation relation= new Relation();
        public Transactionx transactionx= new Transactionx();
        public Filter filter= new filter();          

        public ListDocumentsRequest(String numPerso){                        
            relation.customerInternalId = Integer.valueOf(numPerso);        
            transactionx.application = 'SRC';
            transactionx.branchId = 9712;
        }    
    }     
        public class Relation{           
            public String operation;
            public Integer customerInternalId;
            public String applicationXFile;        
            public String extReferenceXFile;    
        }
        public class Transactionx{            
            public String application;
            public Integer branchId;
            public String[] uploadDate;
            public String language;
            public String enterprise;
            public Integer accessId;
        }
        public class Filter{           
      	   public String action='CATALOGUE_ID';
           public String data='296';
           // en TST no hay tipo de documento 296 probamos con 92   
 		   //public String data='92';
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