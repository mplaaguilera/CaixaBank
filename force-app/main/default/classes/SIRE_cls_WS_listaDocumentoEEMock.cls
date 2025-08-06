/********************************************************************************
    Name:  SIRE_cls_WS_listaDocumentoEEMock
    Copyright © 2021  CaixaBank
    
    Proposito:   Clases Mock necesario de la clase de test del WS en la clase SIRE_cls_WS_listaDocumentoEE                                                                                               
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/11/2021     	  Created    

******************************************************************************************/    
@isTest  
public with sharing class SIRE_cls_WS_listaDocumentoEEMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');           
    
        String body;        
        SIRE_cls_WS_listaDocumentoEE.ListDocumentsRequest bodyLlamada = (SIRE_cls_WS_listaDocumentoEE.ListDocumentsRequest)JSon.deserialize(req.getBody(), SIRE_cls_WS_listaDocumentoEE.ListDocumentsRequest.class);      
        
        if(bodyLlamada.relation.customerInternalId == 200){            
           body = '[{"metadata":{"documentId":166545614,"version":1,"format":"pdf","catalogueId":4195,"documentDescription":"Exampledocumentdescription","monthReference":"JANUARY_01","yearReference":"2023","originId":"OUTSOURCED_SERVICE_14","securityLevel":"PUBLIC_0","valijaSignal":"NOT_VALIJA_APPLICATION","ticketOCP":6287722695164947000},"relation":{"operation":9999700044332,"customerInternalId":214759120,"applicationXFile":"SRC","extReferenceXFile":"EXAMPLE_EXT_REF"},"structure":{"folder":{"order":1,"description":"Cliente","type":"PERSON"},"subFolder":{"order":2,"description":"Fincabilidad"}},"transaction":{"application":"SRC","branchId":"09712","uploadDate":{},"language":"SPANISH","enterprise":"001","accessId":142},"errorData":{"errorCode":"ERR_65015","errorMessage":"Inactivedocumenttype"}},{"metadata":{"documentId":226545622,"version":1,"format":"pdf","catalogueId":4195,"documentDescription":"OtroExampledocumentdescription","monthReference":"FEBRUARY_02","yearReference":"2023","originId":"OUTSOURCED_SERVICE_22","securityLevel":"PUBLIC_0","valijaSignal":"NOT_VALIJA_APPLICATION","ticketOCP":6287722695164947222},"relation":{"operation":9999700044322,"customerInternalId":214759120,"applicationXFile":"SRC","extReferenceXFile":"EXAMPLE_EXT_REF"},"structure":{"folder":{"order":1,"description":"Cliente","type":"PERSON"},"subFolder":{"order":2,"description":"Fincabilidad"}},"transaction":{"application":"SRC","branchId":"09712","uploadDate":{},"language":"SPANISH","enterprise":"001","accessId":142},"errorData":{"errorCode":"ERR_65015","errorMessage":"Inactivedocumenttype"}}]';
           response.setStatusCode(200);
        }else{            
           body = '{"_class": "com.caixabank.absis.arch.common.exception.AbsisException","cause": {"_class": "com.caixabank.absis.arch.common.exception.AbsisException","cause": null,"type": "/runtime",   "title": "RUNTIME","status": 500,"detail": "Filter threw Exception","code": "com.netflix.zuul.exception.ZuulException","translated": false},"type": "/runtime","title": "RUNTIME","status": 500,"detail": "Caught in Zuul","code": 0,"translated": false}';
           response.setStatusCode(500);
        }        
        response.setBody(body);
        return response;
    }
  }