public with sharing class SEG_AOR_Altapeticion {
    public static Boolean SEG_AOR_AltapeticionSend(id casoid, String tipologia1AOR, String tipologia2AOR, String consultaAORaura) {
        Boolean conexionRealizada = false;    
        //CC_InterfaceSettings__mdt oConfig = getConfig ('SEG_AOR');
            String sDescError = '';
            String sDetalleError = '';
            CC_TrazaInt__c oTraza;
            List<CC_TrazaInt__c> oListTrazas = new List<CC_TrazaInt__c>();
            oTraza = new CC_TrazaInt__c();
            oTraza.Name = 'SEG_AOR_Create';
            oTraza.CC_FechaInicio__c = datetime.now();
            
    
            Case casoSeg=new Case();
            casoSeg=[SELECT Id,OwnerId, CaseNumber, SEG_Numero_centro__c, Account.Name,SEG_AORTipologiaN1__c,SEG_AORTipologia_N2__c, Account.CC_Numero_Documento__c,SEG_Consulta_AOR__c,SEG_Identificador_AOR__c FROM Case WHERE id=:casoid];
            oTraza.CC_Identificador__c = casoSeg.CaseNumber;
            User oUser = new User();
            String matricula = '';
            if (casoSeg.OwnerId != null)
            {
                oUser = [SELECT Id, FederationIdentifier, EmployeeNumber FROM User WHERE Id = : casoSeg.OwnerId];
                if(oUser.EmployeeNumber != null){
                    matricula = oUser.EmployeeNumber;
                }
            }
            
            DatosAltaPeticionAOR sendCase = new DatosAltaPeticionAOR();
            sendCase.user = matricula;
            sendCase.center = casoSeg.SEG_Numero_centro__c;
            sendCase.typology_1 = tipologia1AOR;//'7681001edbb368508bfabc45f3961964';
            sendCase.typology_2 = tipologia2AOR;//'fa81001edbb368508bfabc45f3961964';
            sendCase.client = casoSeg.Account.Name;
            sendCase.clientid = casoSeg.Account.CC_Numero_Documento__c;
            sendCase.query = consultaAORaura;
            //sendCase.express_chanel = 'Y';// TODO: lo eliminamos 
            sendCase.ext_reference = casoSeg.Id;
            String jsonToCognitive = JSON.serialize(sendCase);
            //espacio para lanzar llamada HHTP

            // Custom Setting
            String intSetting = 'SEG_AOR';
            
            try {

                // Crear HEADER
                Map<String,string> mHeaders =  new  Map<String,string>();
                mHeaders.put('Content-Type', 'application/json;charset=UTF-8');

                CBK_HttpServiceIntegration.RequestWapper rqwpr = new CBK_HttpServiceIntegration.RequestWapper();
                rqwpr.body = jsonToCognitive;
                rqwpr.intSetting = intSetting;
                rqwpr.method = 'PUT';
                rqwpr.mHeaders = mHeaders;
                rqwpr.mUriParams = null;
                rqwpr.mQueryParams = null;
                HttpRequest request = CBK_HttpServiceIntegration.getRequest(rqwpr);
                HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, intSetting, intSetting);


                oTraza.CC_MensajeEntrada__c = String.valueOf(jsonToCognitive);
                
                String jsonResults = response.getBody();
                
                if (response.getStatusCode() == 200) {
                    SEG_receiveFromAOR results = new SEG_receiveFromAOR();

                    oTraza.CC_MensajeSalida__c = response.getBody();             
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = true;
                    
                    results = SEG_receiveFromAOR.parse(response.getBody());
    
                    if(jsonResults!=null) {
                        System.JSONParser parserSR = System.JSON.createParser(String.valueOf(jsonResults));
                        while (parserSR.nextToken() != null){
                            if ((parserSR.getCurrentToken() == JSONToken.FIELD_NAME) && (parserSR.getText() == 'request')) {
                                parserSR.nextToken();
                                //sDescError = parserSR.getText();
                                casoSeg.SEG_Identificador_AOR__c=parserSR.getText();
                                casoSeg.SEG_AORTipologiaN1__c = tipologia1AOR;
                                casoSeg.SEG_AORTipologia_N2__c = tipologia2AOR;
                                casoSeg.SEG_Consulta_AOR__c = consultaAORaura;
                                casoSeg.Status = 'Pendiente';
                                casoSeg.SEG_Subestado__c = 'Envío pendiente de respuesta jurídica';
                                conexionRealizada = true;
                            }
                        }

                        FeedItem feed = new FeedItem();
                        feed.ParentId = casoid; 
                        feed.Body = 'Caso de Asesoría Jurídica generado: RITM - ' + casoSeg.SEG_Identificador_AOR__c + '\n Consulta : ' + casoSeg.SEG_Consulta_AOR__c; 
                        insert feed;
                        update casoSeg;                                                                            
                    }
                    
                }
                else {
                    oTraza.CC_FechaFin__c = datetime.now();
                    oTraza.CC_FinOK__c = false;
                    oTraza.CC_TipoError__c = 'Error comunicaciones.';
                    oTraza.CC_DetalleError__c = response.getStatusCode() + ':' + response.getBody();
                }
            } catch (Exception e) {
                conexionRealizada = false;

                oTraza.CC_FechaFin__c = datetime.now();
                oTraza.CC_FinOK__c = false;
                oTraza.CC_TipoError__c = 'Error comunicaciones.';
                oTraza.CC_DetalleError__c = e.getMessage();
            }
            insert oTraza;       
            return conexionRealizada;
        } 
        public class DatosAltaPeticionAOR {
            public String user; //Opcional
            public String center; //Opcional Identificador del centro peticionario
            public String typology_1; //Obligatorio identificador de la tipología de nivel 1 en ServiceNow
            public String typology_2; //Obligatorio identificador de la tipología de nivel 2 en ServiceNow
            public String client; //Opcional nombre del cliente para el cual se realiza la petición. Opcional.
            public String clientid; //Obligatorio identificador del cliente para el cual se realiza la petición. Puede ser DNI, número del pasaporte, etc
            public String query; //Obligatorio  consulta legal que se quiere hacer. Obligatorio. (longitud 4000)
            public String expresschanel; //Y/N para saber si la petición tiene una prioridad alta. Opcional.
            public String ext_reference; //será el identificador del caso en SalesForce. Obligatorio.
        }

        //Queda deprecado por el cambio a framework de integraciones
        /*
        static public CC_InterfaceSettings__mdt getConfig (String sInterfaz){
            if (sInterfaz == null){
                return null;
            }
    
            if (sInterfaz == ''){
                return null;
            }
    
            CC_InterfaceSettings__mdt oInterfaz;
    
            List<CC_InterfaceSettings__mdt> oConfig = [SELECT Id, CC_EndPoint__c, CC_Certificado__c, CC_TrazaActiva__c, 
                                                       CC_TrazaEntrada__c, CC_Activa__c
                                                       FROM CC_InterfaceSettings__mdt 
                                                       WHERE DeveloperName =: sInterfaz];
            if (oConfig.size()==1){
                if (oConfig[0] != null){
                    oInterfaz = oConfig[0];
                }
            }
    
            return oInterfaz;
        } 
        */
}