/******************************************************************************
    Name:  SIR_cls_WS_procesoInfo
    Copyright © 2023  CaixaBank

    Proposito:   Llamada a endpoint de SIREC para saber en que tarea se encuentra un proceso

        Historial
        -------                                                            
        VERSION        USER_STORY       AUTHOR         DATE               Description
        1.0            US448852         Atmira         07/06/2023     	  Created    

****************************************************************************************/
// El framework de llamadas a endpoints HttpServiceIntegrationException no permite realizar
// llamadas GET pasando un parámetro. Para poder trabajar hasta que se realice la modificacion 
// en el framework copiamos el código de la clase SIR_cls_WS_SIREC y HttpServiceIntegrationException
// para agregar parámetro. 
/***************************************************************************************/
public with sharing class SIR_cls_WS_procesoInfo {
    
    public static List<Object> sincronizaProceso(String idProceso, String masterRecordId){
        List<Object> response = new List<Object>();        
        if(SIR_WS_Configuration__mdt.getInstance('procesoInfo').SIR_fld_isActive__c){
                Map<String,string> mHeaders =  new  Map<String,string>();                
                ///////////////////////////////////////////////////////////////////////////////////                
                //  LLAMAR A LA CLASE DEFINIDA EN ESTA MISMA CLASE Y PASANDO masterRecordId COMO PARAMETRO ///
                //  PASAR EL PARAMETRO DEL BODY A NULL PORQUE SINO SOBRECARGA EL METODO Y UTILIZA POST
                //response = SIR_cls_WS_SIREC.llamar(JSON.serialize(body), 'procesoInfo' , 'GET'); 
                response = llamar(null, 'procesoInfo' , 'GET', masterRecordId);                                
                //////////////////////////////////////////////////////////////////////////////////
        }else{
            //llamada al mock, por ahora siempre devuelve ok
            response.add('OK');
        }
        return response;
    }  

    ///////////////////////////////////////////////////////////////////////////////////    
    // Copia de la clase SIREC para permitir Parametro en la URL   
    //////////////////////////////////////////////////////////////////////////////////
    
    public static List<Object> llamar(String body, String destino, string metodo, String parametro){
        List<Object> response = new List<Object>();
        HttpRequest req;
        HttpResponse res;    
        try {
            Map<String,string> mHeaders =  new  Map<String,string>();
            mHeaders.put('Content-Type', 'application/json;charset=UTF-8');
            mHeaders.put('Accept-Language', 'es');
                        
            ///////////////////////////////////////////////////////////////////////////////////
            // LLAMAR A LA CLASE DEFINIDA EN ESTA MISMA CLASE Y PASANDO masterRecordId COMO PARAMETRO ///
            //req = CBK_HttpServiceIntegration.getRequest(body, destino, metodo, mHeaders);    
            //res = CBK_HttpServiceIntegration.callHttpService(req, 'SIR', destino);            
            req = getRequest(body, destino, metodo, mHeaders, parametro);    
            res = callHttpService(req, 'SIR', destino);                     
            //////////////////////////////////////////////////////////////////////////////////

            Map<String, Object> desearilazedItem = (Map<String, Object>)JSON.deserializeUntyped(res.getbody());
            Map<String, Object> respuesta= (Map<String, Object>)desearilazedItem.get('respuesta') ;
            Map<String, Object> info = (Map<String, Object>)desearilazedItem.get('info');
            //Las siguientes líne existe porque nos están pasando una lista, habría que ver porque esto es así
            Map<String, Object> error;
            String errormsg = '';
            String descripcionError = '';
            if(desearilazedItem.containsKey('error')){
                List<Object> lstError = (List<Object>)desearilazedItem.get('error');
                error = (Map<String, Object>)lstError.get(0);
                errormsg = ' ' + (String)error.get('codigo') + ' - ' + (String)error.get('mensaje');
                descripcionError =  (String)error.get('mensaje');
            }            
            
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){      
                if( (Integer)info.get('codigo') == 1){    
                    response.add('OK');
                    response.add(respuesta);                
                }else{        
                    response.add('KO');                    
                    response.add('Se ha producido un error en la sincronización, contacte con el administrador.');
                    response.add('Error: ' + (Integer)info.get('codigo') + ' - ' + (String)info.get('descripcion'));
                }
            }else{      
                response.add('KO');   
                if(res.getStatusCode() == 300){
                   response.add('Inténtelo más tarde.');                    
                   response.add(descripcionError);
                }else{
                   response.add('Se ha producido un error en la sincronización, inténtelo más tarde.');
                   response.add('Error: ' + mapHttpMsg.get(res.getStatusCode()) + errormsg );
                }                

                CBK_log.error('Error : SIR_cls_WS_SIREC.llamar -  '+ destino + ' el request ' + body + ' y response ' + res.getStatusCode() + ' - ' +  res.getBody());                
            }                       
            return response;
            
        } catch (Exception ex) {
            response.add('KO');
            response.add('Se ha producido un error, contacte con el administrador.');
            response.add(res.getStatusCode() + ' - ' +  mapHttpMsg.get(res.getStatusCode()));
            CBK_log.error(ex, 'Error : SIR_cls_WS_SIREC.llamar -  '+ destino + ' con request ' + body + ' y response ' + res.getStatusCode() + ' - ' +  res.getBody() + ' ' + ex.getTypeName() + ': ' + ex.getMessage());
            return response;
        }
    }

    private static Map<Integer, String> mapHttpMsg = new Map<Integer,String>{300 => ' ', 
                                                                            401 => 'No autorizado',
                                                                            403 => 'Prohibido',
                                                                            404 => 'No encontrado',
                                                                            500 => 'Error en el servidor',
                                                                            503 => 'Error en el servidor'};

    ////////////////////////////////////////////////////////////////////////////////////////////////////    
    ///// codigo del FWK de integraciones modificado para poder llamar con metodo GET y parametro en URL
    ////////////////////////////////////////////////////////////////////////////////////////////////////

    public class HttpServiceIntegrationException extends Exception { }

	public static HttpRequest getRequest(String body, String intSetting, String method, Map<String, string> mHeaders, String parametro) {
		return getRequest(body, intSetting, method, mHeaders, false, false, parametro);
	}

	public static HttpRequest getRequest(String body, String intSetting, String method, Map<String, string> mHeaders, Boolean oAuth2, Boolean refreshToken, String parametro) {

		HttpRequest request = new HttpRequest();

		try {
			CBK_IntegrationSetting__c wsc = CBK_WebServiceConfiguration.getConfiguration(intSetting);
			if (wsc == null || String.isBlank(wsc.NamedCredential__c)){
				throw new CBK_HttpServiceIntegration.HttpServiceIntegrationException('Integration Setting was not defined for the specified configuration.');
			}

			string vUrl = wsc.NamedCredential__c;
            ///////////////////////////////////////////////////////////////////////////////////
            /////////////////// agregar paramtro en URL ///////////////////////////////////////
			//request.setEndpoint(vUrl);
			request.setEndpoint(vUrl + '/' + parametro);            
            /////////////////// /////////////////////////////////////////////////////////////

			request.setMethod(method);

			if(String.isNotBlank(body)){
				request.setBody(body);
			}

			for (string st : mHeaders.keySet()){
				string headerValue = mHeaders.get(st);
				request.setHeader(st, headerValue);
			}
			request.setTimeout(120000);

			CBK_log.debug('Request:  ' + request, LoggingLevel.INFO);
			for (string st : mHeaders.keySet()){
				CBK_log.debug('Request - Headers: '+ st + ' : ' + request.getHeader(st), LoggingLevel.INFO);
			}
			CBK_log.debug('Request - Body:  ' + request.getBody(), LoggingLevel.INFO);

		} catch(Exception ex) {
			CBK_log.error(ex, 'Error : CBK_HttpServiceIntegration - getRequest()' + ex.getMessage());	
		}
		return request;
	}

	public static HttpResponse callHttpService(HttpRequest request, String identificador, String configInt) {
		Http http = new Http();
		HttpResponse response = new HttpResponse();
		Datetime dtStart;
		DateTime dtStop;
			try {
				dtStart = Datetime.now();
				response = http.send(request);
				dtStop = Datetime.now();
				CBK_log.debug('Response:  ' + response, LoggingLevel.INFO);

				if (response.getStatusCode() != CBK_ServiceRestManager.CORRECT_STATUS_CODE) {
					CBK_log.debug('Response KO:  Status = ' + response.getStatusCode() + ' Body = ' + response.getBody() , LoggingLevel.INFO);
					throw new CBK_ServiceRestManager.BadResponseException(response.getBody(), response.getStatus(), response.getStatusCode());
				} else {
					CBK_log.debug('Response OK: Status = ' + response.getStatusCode() + ' Body = ' + response.getBody() , LoggingLevel.INFO);
				}
			} catch(Exception ex) {
				CBK_log.error(ex, 'Error : CBK_HttpServiceIntegration ' + ex.getMessage());
			}
			CBK_HttpServiceIntegration.registroTrazaIntegracion(request,response, dtStart,dtStop,identificador, configInt);
		return response;
	}
}