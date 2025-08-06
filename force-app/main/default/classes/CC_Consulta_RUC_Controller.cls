public with sharing class CC_Consulta_RUC_Controller {
   
 @AuraEnabled //List<CC_Consulta_RUC_JSON.Contacto>
    public static List<Map<String,Object>> ejecutarConsulta(String numPerso, String fechaIni, String fechaFin){
        //system.debug('Este es el num'+ numPerso); // GMD quitar
String json ='{'+
'   \"ResultError\":    {'+
'      \"codError\": \"0\",'+
'      \"descError\": \"Resultado correcto\"'+
'   },'+
'   \"ListadoContactos\":    ['+
'            {'+
'         \"anoMes\": 201803,'+
'         \"numPerson\": 7415279,'+
'         \"codContacto\": 47809680,'+
'         \"fechaContacto\": 1521414000000,'+
'         \"codFuente\": 6,'+
'         \"descFuente\": \"RTD\",'+
'         \"descOrigen\": \"Servicios centrales\",'+
'         \"empleado\": -2,'+
'         \"centro\": -1,'+
'         \"codMedio\": 6,'+
'         \"descMedio\": \"Pop-Up\",'+
'         \"codCanal\": 20030000,'+
'         \"tipoComunicacion\": 1,'+
'         \"descComunic\": \"Comercial (Venta)\"'+
'      },'+
'     {'+
'         \"anoMes\": 201803,'+
'         \"numPerson\": 7415279,'+
'         \"codContacto\": 47809680,'+
'         \"fechaContacto\": 1521414000000,'+
'         \"codFuente\": 6,'+
'         \"descFuente\": \"RTD\",'+
'         \"descOrigen\": \"Servicios centrales\",'+
'         \"empleado\": -2,'+
'         \"centro\": -1,'+
'         \"codMedio\": 6,'+
'         \"descMedio\": \"Pop-Up\",'+
'         \"codCanal\": 20030000,'+
'         \"tipoComunicacion\": 1,'+
'         \"descComunic\": \"Comercial (Venta)\"'+
'      },'+
'         {'+
'         \"anoMes\": 201804,'+
'         \"numPerson\": 33333,'+
'         \"codContacto\": 47809680,'+
'         \"fechaContacto\": 232334223,'+
'         \"codFuente\": 7,'+
'         \"descFuente\": \"sMS\",'+
'         \"descOrigen\": \"HHHHHHHHH\",'+
'         \"empleado\": -2,'+
'         \"centro\": -1,'+
'         \"codMedio\": 6,'+
'         \"descMedio\": \"Pop-Up\",'+
'         \"codCanal\": 20030000,'+
'         \"tipoComunicacion\": 1,'+
'         \"descComunic\": \"Comercial\"'+
'      },'+
'     {'+
'         \"anoMes\": 201805,'+
'         \"numPerson\": 7415279,'+
'         \"codContacto\": 47809680,'+
'         \"fechaContacto\": 1521414000000,'+
'         \"codFuente\": 6,'+
'         \"descFuente\": \"RTD\",'+
'         \"descOrigen\": \"Servicios centrales\",'+
'         \"empleado\": -2,'+
'         \"centro\": -1,'+
'         \"codMedio\": 6,'+
'         \"descMedio\": \"Pop-Up\",'+
'         \"codCanal\": 20030000,'+
'         \"tipoComunicacion\": 1,'+
'         \"descComunic\": \"Comercial (Venta)\"'+
'      },'+
'         {'+
'         \"anoMes\": 201806,'+
'         \"numPerson\": 7415279,'+
'         \"codContacto\": 47809680,'+
'         \"fechaContacto\": 232334223,'+
'         \"codFuente\": 7,'+
'         \"descFuente\": \"sMS\",'+
'         \"descOrigen\": \"HHHHHHHHH\",'+
'         \"empleado\": -2,'+
'         \"centro\": -1,'+
'         \"codMedio\": 6,'+
'         \"descMedio\": \"Pop-Up\",'+
'         \"codCanal\": 20030000,'+
'         \"tipoComunicacion\": 1,'+
'         \"descComunic\": \"Comercial\"'+
'      },'+
'         {'+
'         \"anoMes\": 201807,'+
'         \"numPerson\": 7415279,'+
'         \"codContacto\": 47809680,'+
'         \"fechaContacto\": 1521414000000,'+
'         \"codFuente\": 7,'+
'         \"descFuente\": \"GMS\",'+
'         \"descOrigen\": \"Servicios Comerciales\",'+
'         \"empleado\": -2,'+
'         \"centro\": -1,'+
'         \"codMedio\": 6,'+
'         \"descMedio\": \"Pop-Up\",'+
'         \"codCanal\": 20030000,'+
'         \"tipoComunicacion\": 1,'+
'         \"descComunic\": \"Comercial (Venta)\"'+
'      }'+
'   ]'+
'}';
    
    if (Test.isRunningTest()){
        numPerso = '12576341'; // GMD pruebas hardcodeas
    }
    String resultado ='OK';
    String codFuente;
    List<CC_Parametros__mdt> listcodFuente = [SELECT Valor_Texto__c FROM CC_Parametros__mdt where label ='CC_codigoFuente_RUC' LIMIT 1];
            if (!listcodFuente.isEmpty()){
            codFuente = listcodFuente[0].Valor_Texto__c;
            }    
    // system.debug('el codigo recuperado es:'+ codFuente);   
	List<CC_TrazaInt__c> listTrazas = new List<CC_TrazaInt__c>();
	//CC_InterfaceSettings__mdt consultaRUC = CC_MetodosUtiles.getInterfazConfigBody('CC_Consulta_RUC');
	String errorCode;
	String errorMsg;
		
     // Recuperar configuración integración     
  	  CC_InterfaceSettings__mdt configRUC = CC_MetodosUtiles.getInterfazConfigBody('CC_Consulta_RUC');
	
        if( configRUC != null){
            //Gestión trazas
            CC_TrazaInt__c traza;
            String descError = '';
            String detalleError = '';
            String salida = '';
            
            //Iniciamos trazas para guardar si faltan datos por informar
            if (configRUC.CC_TrazaActiva__c || Test.isRunningTest()) {
                    traza = new CC_TrazaInt__c();
                    traza.Name = 'CC_Consulta_RUC';
                    traza.CC_FechaInicio__c = datetime.now();                }
            
            //Comprobamos que los datos están informados.            
            if ( numPerso != null){
                 //Contruimos el Body de la petición remplanzando los datos recuperados
                 String body = configRUC.CC_Body__c;            
                 body = body.replace('##numPerson##', numPerso);
                 body = body.replace('##fechaDesde##', fechaIni);
                 body = body.replace('##fechaHasta##', fechaFin);
                 body = body.replace('##codFuente##', codFuente);
				 //system.debug('Json'+ body); // GMD quitar
                
                //Enviamos la consulta RUC
                try {
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(configRUC.CC_EndPoint__c);
                    request.setMethod(configRUC.CC_TipoPeticion__c);
                    request.setHeader('Content-Type',configRUC.CC_ContentType__c);
                    request.setClientCertificateName(configRUC.CC_Certificado__c);
                    request.setBody(body);
                    HttpResponse response = http.send(request);
                    //System.debug(response.getBody());
                    // Parse the JSON response
                    /*if(response.getStatusCode() == 200){  //GMD  puesto == solo mostrar en local
                        descError = 'Error petición.';
                        detalleError = response.getStatus() + ' (' + response.getStatusCode() + ')';
                        // Guardar codigo error y mensaje de error

                    } else {
                       	salida = String.valueOf(response.getBody());
                        CC_Consulta_RUC_JSON datos = CC_Consulta_RUC_JSON.parse(json);
						List<Map<String,Object>> oList = new List<Map<String,Object>>();                        
                        //system.debug('desc' + datos.ResultError);
						 String codigoError = datos.ResultError.codError;
                        
                        if (codigoError =='0'){
                            for (CC_Consulta_RUC_JSON.Contacto contacto : datos.ListadoContactos ){
                                Map<String,Object> oData = new Map<String,Object>();
                                oData.put('numPerson', String.valueOf(contacto.numPerson));
                                oData.put('anoMes', String.valueOf(contacto.anoMes));
                                oData.put('descFuente', contacto.descFuente);
                                oData.put('codContacto', String.valueOf(contacto.codContacto));
                                oData.put('descOrigen', contacto.descOrigen);
                                oData.put('descMedio', contacto.descMedio); 
                                oData.put('descComunic', contacto.descComunic);
                                oList.add(oData);            
                            }
                            return oList;
                        } else{
                       		detalleError =  datos.ResultError.descError;
                           	descError = codigoError;
                        }
                    }*/

                } catch (Exception e){
                            // Error comunicaciones.
                            descError = 'Error comunicaciones.';
                            detalleError = e.getMessage();
                }
                
            } else{
                    // Registrar traza sin datos de envío.
                    descError = 'Datos entrada no informados.';
                    detalleError = 'No están informados todos los datos obligatorios. Comunicación: ';          
            	  } 
          // finalizamos la traza
          if ((configRUC.CC_TrazaActiva__c || Test.isRunningTest()) && traza != null){
                    traza.CC_FechaFin__c = datetime.now();
                    
                    if ((configRUC.CC_TrazaSalida__c || Test.isRunningTest()) && salida != '')
                        traza.CC_MensajeSalida__c = salida;
                    
                    if (descError != ''){
                        traza.CC_FinOK__c = false;
                        traza.CC_TipoError__c = descError;
                        traza.CC_DetalleError__c = detalleError;
                    } else{
                        traza.CC_FinOK__c = true;
                    }
                    
                    listTrazas.add(traza);
                }
            // Insertar las trazas generadas.
           if (listTrazas.size() > 0){
                Database.SaveResult[] resUp = Database.insert(listTrazas, false);
           }            
     	}
        
      return null;
  }
}