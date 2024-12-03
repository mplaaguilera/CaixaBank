/********************************************************************************
    Name:  SIRE_cls_WS_detalleDocumentoEEMock
    Copyright © 2021  CaixaBank
    
    Proposito:   Clases Mock necesario de la clase de test del WS en la clase SIRE_cls_WS_detalleDocumentoEE                                                                                               
    
        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0                             Atmira         06/11/2021     	  Created    

******************************************************************************************/    
/*@isTest  
public with sharing class SIRE_cls_WS_detalleDocumentoEEMock implements HttpCalloutMock {
 private Integer nroCall = 0;
    public HTTPResponse respond(HTTPRequest req) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');           
    
        String body;        
        SIRE_cls_WS_detalleDocumentoEE.DetalleDocumentRequest bodyLlamada = (SIRE_cls_WS_detalleDocumentoEE.DetalleDocumentRequest)JSon.deserialize(req.getBody(), SIRE_cls_WS_detalleDocumentoEE.DetalleDocumentRequest.class);      
        
       // if(bodyLlamada.transactionx.aplication == 'SRC'){            
        if (status == 200){
           body = '{"file":{"data":"R0lGODlhDAAMAIQAAP//9/X17unp5WZmZgAAAOfn515eXvPz7Y6OjuDg4J+fn5OTk6enp56enmlpaWNjY6Ojo4SEhP/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++f/++SH+Dk1hZGUgd2l0aCBHSU1QACwAAAAADAAMAAAFLCAgjoEwnuNAFOhpEMTRiggcz4BNJHrv/zCFcLiwMWYNG84BwwEeECcgggoBADs="},"metadata":{"documentId":166545614,"version":1,"format":"pdf","catalogueId":4195,documentDescription":"Exampledocumentdescription","monthReference":"JANUARY_01",yearReference":"2023","originId":"OUTSOURCED_SERVICE_14","securityLevel":"PUBLIC_0","valijaSignal":"NOT_VALIJA_APPLICATION","ticketOCP":6287722695164947000},"relation":{"applicationXFile":"SRC","extReferenceXFile":"EXAMPLE_EXT_REF"},"structure":{"folder":{"order":1,"description":"Cliente","type":"OPERATION"},"subFolder":{"order":2,"description":"Fincabilidad"}}}';
           response.setStatusCode(200);
        }else{            
           body = '{"_class": "com.caixabank.absis.arch.common.exception.AbsisException","cause": {"_class": "com.caixabank.absis.arch.common.exception.AbsisException","cause": null,"type": "/runtime",   "title": "RUNTIME","status": 500,"detail": "Filter threw Exception","code": "com.netflix.zuul.exception.ZuulException","translated": false},"type": "/runtime","title": "RUNTIME","status": 500,"detail": "Caught in Zuul","code": 0,"translated": false}';
           response.setStatusCode(500);
        }        
        nroCall++;
        system.debug('ALR' +nroCall);
        response.setBody(body);
        return response;
    }
  }*/
  @isTest
public class SIRE_cls_WS_detalleDocumentoEEMock implements HttpCalloutMock {
	protected HttpRequest request { get; set; }
	protected HttpResponse response { get; set; }

    	protected String bodyMock;
	protected Integer statusCodeMock;

	public SIRE_cls_WS_detalleDocumentoEEMock(String bodyM, Integer statusCM) {
		
		this.bodyMock = bodyM;	
		this.statusCodeMock = statusCM;
	}

	public SIRE_cls_WS_detalleDocumentoEEMock(HttpResponse response) {
	System.debug('ffsfdasdfasdfadsfa');
		this.response = response;
	}

	public HTTPResponse respond(HTTPRequest req) {
		if (response == null) {
			// Create a fake response	
			response = new HttpResponse();
			response.setHeader('Content-Type', 'application/json');
			response.setBody(bodyMock);
			response.setStatusCode(statusCodeMock);
		}

		return response;
	}

}