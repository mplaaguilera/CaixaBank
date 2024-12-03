@isTest
public class SAC_MockHttpResponseGenerator implements HttpCalloutMock {

	protected Integer code;
	protected String status;
	protected String body;
	protected Map<String, String> responseHeaders;
	
	/*
	*
	* @methodName               SAC_MockHttpResponseGenerator
	* @received parameters      Integer code, String status, String body, Map<String, String> responseHeaders
	* @return                   HttpResponse response
	*
	*/
	
	public SAC_MockHttpResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders){
		this.code = code;
		this.status = status;
		this.body = body;
		this.responseHeaders = responseHeaders;
	}

	/*
	*
	* @methodName               mockResponse
	* @received parameters      HttpRequest request
	* @return                   HttpResponse response
	*
	*/
	
	public HttpResponse respond(HttpRequest request) {
		if (request.getEndpoint().contains('servicing/servicingIssue/claims/request')) {
			HTTPResponse res = new HTTPResponse();
			res.setBody('[ { "customerIds": [ "12345678z" ], "claimCode": "236742", "expedient": "20190712134618", "resolutionType": " ", "productService": "Avales Fianzas y Otras Garantías", "causeDetail": "Comisión de Mantenimiento", "claimStatus": "P1 Alta de Expediente", "creationDate": "2019-07-12", "claimType": "SAC" } ]');
			res.setStatusCode(code);
			res.setStatus(status);
			return res;
		}else if(request.getEndpoint().contains('nonITAndNonHREnterpriseServices/legalCompliance/bankruptcyProcs/request/bulk')){ //GESCON
			HTTPResponse res = new HTTPResponse();
			res.setBody('[ { "contracts": [ "02888-0008224-013-60", "09620-0948392-251-34", "09612-4622527-012-33", "09612-8748656-050-81" ], "procCode": "70043599C", "expedient": "-00192", "procPhase": "Fase común", "procStatus": "Abierta", "creationDate": "2021-05-17" } ]');
			res.setStatusCode(code);
			res.setStatus(status);
			return res;
		}else if(request.getEndpoint().contains('nonITAndNonHREnterpriseServices/legalCompliance/specialProcs/request/bulk')){ //PROESP
			HTTPResponse res = new HTTPResponse();
			res.setBody('[ { "customerIds": [ "A08952277" ], "subjects": [ "Depósitos de efectivo", "Operaciones no autorizadas" ], "procCode": "2015-02801", "expedient": "5316950", "resolutionDocuments": [ { "fileName": "|", "downloadLink": "https://pre01.tf7.lacaixa.es/TF71/CA.OFI/ExpedienteRiesgoGesExternalizada/verDocumento.tf7?_flowId=verDocumento-flow&_flowRType=FR&referenciaExterna=99703772&aplicacionInv=PJU&idDocumento=|&aplicacionExpedienteX=PJU" } ],"procStatus": "Fin del procedimiento", "creationDate": "2015-03-18", "dueDate": "2018-03-02" } ]');
			res.setStatusCode(code);
			res.setStatus(status);
			return res;
		}else if(request.getEndpoint().contains('corporateServices/legalCompliance/debtClaims/request')){ //PROMOR
			HTTPResponse res = new HTTPResponse();
			res.setBody('[ { "customerIds": [ "B97782270-DIAMETRAL CONCEPTOS S.L." ], "contracts": [ "9320509703062-84" ], "claimCode": "99703772", "affectedOffice": "09457", "product": "GSL", "claimStatus": "Abierta", "resolutionDocuments": [ { "fileName": "|", "downloadLink": "https://pre01.tf7.lacaixa.es/TF71/CA.OFI/ExpedienteRiesgoGesExternalizada/verDocumento.tf7?_flowId=verDocumento-flow&_flowRType=FR&referenciaExterna=99703772&aplicacionInv=PJU&idDocumento=|&aplicacionExpedienteX=PJU" } ], "claimAmount": 19512.57, "creationDate": "2015-03-07" } ]');
			res.setStatusCode(code);
			res.setStatus(status);
			return res;
		}else if(request.getEndpoint().contains('tech/gdsusr/api/GGHAPI/AltaReclamacion')){ //GGH_Callout
			HTTPResponse res = new HTTPResponse();
			res.setBody('{"IdPretension":"2-5946720753","Result":true,"Error":null,"TipoGestion":0}');
			res.setStatusCode(code);
			res.setStatus(status);
			return res;
		}else if(request.getEndpoint().contains('/servicing/servicingIssue/claims/details')){ //DetalleReclamacion
			HTTPResponse res = new HTTPResponse();
			res.setBody('[{"claimCode":"209603","expedient":"201422328","claimType":"Reclamación","affectedEntity":"1","originCompany":"Caixabank, S.A.","affectedCompany":"Caixabank, S.A.","claimStatus":"EXPEDIENTE FINALIZO","claimSource":"Banco de España","entranceChannel":"SUPERVISORES","claimFamily":"Operaciones activas","claimProductService":"010-Descubiertos en cuenta (anticipos) /Posibilidad de descubierto (cuenta nomina)","claimFamilyCause":"Intereses / retribuciones","causeDetail":"Tipo de cambio","contractNumber":["numProducto1;numProducto2;numProducto3"],"contractType":["nomProducto1;nomProducto2;nomProducto3"],"receptionDate":"2018-06-25","creationDate":"2014-10-13","resolutionDate":"2014-10-28","dueDate":"2018-08-11","resolutionType":"Desfavorable entidad totalmente","amountClaimed":44.67,"amountPaid":99.5,"customer":{"customerTypeId":"NIF","customerId":"12345678Z","customerName":"qwert","customerFirstSurname":"qwert1","customerSecondSurname":"qwert2","customerPhone":{}},"agent":{"agentId":"12345678Z","agentName":"qwert3","agentFirstSurname":"qwert4","agentSecondSurname":"qwert5"}}]');
			res.setStatusCode(code);
			res.setStatus(status);
			return res;
		}
		else{
			final HttpResponse response = new HttpResponse();
			response.setStatusCode(code);
			response.setStatus(status);
			response.setBody(body);
			if(responseHeaders != null){
				for(String key : responseHeaders.keySet()){
					response.setHeader(key, responseHeaders.get(key));
				}
			}
			return response;
		}
	}

}