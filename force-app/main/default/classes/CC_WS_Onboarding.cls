public with sharing class CC_WS_Onboarding {
    public static String recuperarClienteOnboarding(String recordId, String nif) {
        String retorno;
        try {
            // 77788590F
            // 29785500D
            String httpRequestBody = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><m:ConsultaEstadoSolicitud xmlns:m="http://GDS707A/ConsultaEstadoSolicitud.tws"><m:consultaEstadoSolicitudRequest><m:numeroSolicitud>' + nif + '</m:numeroSolicitud><m:tipoIdentificacion>N</m:tipoIdentificacion><m:origenConsulta>C</m:origenConsulta></m:consultaEstadoSolicitudRequest></m:ConsultaEstadoSolicitud></soap:Body></soap:Envelope>';
            Map<String, String> mHeaders = new Map<String, String>();
            mHeaders.put('HTTP-HEADER-ACTOR', 'CBCCSF'); // Solo DEV

            CBK_HttpServiceIntegration.RequestWapper integracion = new CBK_HttpServiceIntegration.RequestWapper();
            integracion.body = httpRequestBody;
            integracion.intSetting = 'CC_Onboarding';
            integracion.mHeaders = mHeaders;

            HttpRequest request = CBK_HttpServiceIntegration.getRequest(integracion);
            request.setClientCertificateName('cc_camaleon'); // Solo DEV
            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, null, 'CC_Onboarding');

            if (response.getStatusCode() != 200) {
                CBK_Log.debug('::: Error Status Code: ' + response.getStatusCode());
            } else {
                // La integración nos devuelve un body en XML, asi que lo pasamos a JSON con los siguientes metodos
                String xmlResponse = response.getBody();
                String jsonResponse = convertXMLToJSON(xmlResponse);
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

                Map<String, Object> body = (Map<String, Object>) jsonMap.get('Body');
                Map<String, Object> consultaEstadoSolicitudResponse = (Map<String, Object>) body.get('ConsultaEstadoSolicitudResponse');
                Map<String, Object> consultaEstadoSolicitudSalesforceResponse = (Map<String, Object>) consultaEstadoSolicitudResponse.get('consultaEstadoSolicitudSalesforceResponse');

                Map<String, Object> resultado = (Map<String, Object>) consultaEstadoSolicitudSalesforceResponse.get('resultado');
                String codigo = (String) resultado.get('codigo');
                Case caso = [SELECT CBK_Case_Extension_Id__c, AccountId FROM Case WHERE Id = :recordId LIMIT 1];
                Boolean actualizarCaso = false;

                if (codigo != null && codigo == '-1') {
                    retorno = 'El cliente no esta en proceso de Onboarding';
                } else {
                    /************* Gestion del Caso *********/

                    // Datos para el caso
                    String idReferencia = (String) consultaEstadoSolicitudSalesforceResponse.get('idReferencia');
                    String fechaEstado = (String) consultaEstadoSolicitudSalesforceResponse.get('fechaEstado');
                    String estado = (String) consultaEstadoSolicitudSalesforceResponse.get('estado');
                    String empresa = (String) consultaEstadoSolicitudSalesforceResponse.get('empresa');
                    String subestado = (String) consultaEstadoSolicitudSalesforceResponse.get('subestado');
                    String motivoCierre = (String) consultaEstadoSolicitudSalesforceResponse.get('motivoCierre');

                    CBK_Case_Extension__c caseExtension;
                    String operacionCaseExtension;
                    if (caso.CBK_Case_Extension_Id__c != null) {
                        caseExtension = [SELECT Id FROM CBK_Case_Extension__c WHERE Id = :caso.CBK_Case_Extension_Id__c LIMIT 1];
                        operacionCaseExtension = 'update';
                    } else {
                        caseExtension = new CBK_Case_Extension__c();
                        caseExtension.Case_Id__c = recordId;
                        operacionCaseExtension = 'insert';
                    }
                    caseExtension.CC_EmpresaONB__c = empresa;
                    caseExtension.CC_EstadoONB__c = estado;
                    caseExtension.CC_SubestadoONB__c = subestado;
                    caseExtension.CC_FechaEstadoONB__c = fechaEstado;
                    caseExtension.CC_MotivoCierreONB__c = motivoCierre;
                    caseExtension.CC_NumSR__c = idReferencia;
                    caseExtension.CC_CodigoONB__c = codigo;
                    if (operacionCaseExtension == 'insert') {
                        insert caseExtension;
                        caso.CBK_Case_Extension_Id__c = caseExtension.Id;
                        actualizarCaso = true;
                    } else {
                        update caseExtension;
                    }
                    /****************************************/

                    /********* Gestion de la Cuenta *********/
                    
                    // Datos para la cuenta
                    String numeroDocumento = (String) consultaEstadoSolicitudSalesforceResponse.get('numeroDocumento');
                    String nombre = (String) consultaEstadoSolicitudSalesforceResponse.get('nombre');
                    String telefono = (String) consultaEstadoSolicitudSalesforceResponse.get('telefono');
                    String fechaNacimiento = (String) consultaEstadoSolicitudSalesforceResponse.get('fechaNacimiento');
                    
                    //Factorizacion de los datos para poder hacer los insert/update de forma correcta
                    List<String> nombreSeparado = nombre.split(' ');
                    List<String> fechaSplit = fechaNacimiento.split('-');
                    String fechaConstruct = fechaSplit[1] + '/' + fechaSplit[0] + '/' + fechaSplit[2];
                    Date fechaNac = date.parse(fechaConstruct);

                    if (caso.AccountId != null) {
                        Account cuenta = [SELECT CC_Numero_Documento__c, FirstName, LastName, PersonMobilePhone, PersonBirthdate FROM Account WHERE Id = :caso.AccountId LIMIT 1];

                        cuenta.CC_Numero_Documento__c = numeroDocumento;
                        cuenta.FirstName = nombreSeparado[0];
                        cuenta.LastName = nombreSeparado[1] + ' ' + nombreSeparado[2];
                        cuenta.PersonMobilePhone = telefono;
                        cuenta.PersonBirthdate = fechaNac;

                        update cuenta;
                        retorno = 'OK';
                    } else {
                        String operacion;
                        List<Account> lstCuenta = [SELECT CC_Numero_Documento__c, FirstName, LastName, PersonMobilePhone, PersonBirthdate FROM Account WHERE CC_Numero_Documento__c = :numeroDocumento LIMIT 1];
                        Account cuenta;
                        if (lstCuenta.isEmpty()) {
                            cuenta = new Account();
                            operacion = 'insert';
                        } else {
                            cuenta = lstCuenta[0];
                            operacion = 'update';
                        }
                        cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
                        cuenta.CC_Numero_Documento__c = numeroDocumento;
                        cuenta.FirstName = nombreSeparado[0];
                        cuenta.LastName = nombreSeparado[1] + ' ' + nombreSeparado[2];
                        cuenta.PersonMobilePhone = telefono;
                        cuenta.PersonBirthdate = fechaNac;

                        if (operacion == 'insert') {
                            insert cuenta;
                        } else {
                            update cuenta;
                        }
                        caso.AccountId = cuenta.Id;
                        actualizarCaso = true;
                        retorno = 'El cliente esta en proceso de Onboarding';
                    }
                    /****************************************/
                }
                if (actualizarCaso) {
                    update caso;
                }
            }
        } catch (Exception e) {
            CBK_Log.error(e); 
        }
        return retorno;
    }

    @AuraEnabled
    public static String recuperarCliente(String recordId, String nif) {
        return recuperarClienteOnboarding(recordId, nif);
    }

    private static String convertXMLToJSON(String xmlString) {
        Dom.Document doc = new Dom.Document();
        doc.load(xmlString);
        Dom.XmlNode root = doc.getRootElement();
        
        Map<String, Object> jsonMap = new Map<String, Object>();
        parseXMLToMap(root, jsonMap);
        
        return JSON.serialize(jsonMap);
    }

    private static void parseXMLToMap(Dom.XmlNode nodo, Map<String, Object> mapa) {
        for (Dom.XmlNode child : nodo.getChildElements()) {
            if (child.getChildElements().size() > 0) {
                Map<String, Object> childMap = new Map<String, Object>();
                parseXMLToMap(child, childMap);
                mapa.put(child.getName(), childMap);
            } else {
                mapa.put(child.getName(), child.getText());
            }
        }
    }

    public static String matrizOnboarding(String estado, String subestado, String motivoCierre) {
        String comentarioCliente = '';
        if (String.isNotBlank(motivoCierre)) {
            comentarioCliente = recuperarMotivoCierre(motivoCierre);
        } else {
            comentarioCliente = recuperarEstadoSubestado(estado, subestado);
        }
        
        return comentarioCliente;
    }

    public static String recuperarMotivoCierre(String motivoCierre) {
        String comentarioCliente = '';
        Id idValorRT = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');

        List<CC_Lista_Valores__c> listaValores = [SELECT CC_Mensajes_Mostrar__c
                                                    FROM CC_Lista_Valores__c
                                                    WHERE RecordTypeId = :idValorRT
                                                    AND CC_Activa__c = true
                                                    AND CC_Lista__r.CC_Activa__c = true
                                                    AND CC_Valor2__c = 'Motivo Cierre'
                                                    AND Name = :motivoCierre];

        if (!listaValores.isEmpty() && String.isNotBlank(listaValores[0].CC_Mensajes_Mostrar__c)) {
            comentarioCliente = listaValores[0].CC_Mensajes_Mostrar__c;
        }
        return comentarioCliente;
    }

    public static String recuperarEstadoSubestado(String estado, String subestado) {
        String comentarioCliente = '';
        Id idValorRT = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_ValorSubestado');

        List<CC_Lista_Valores__c> listaValores = [SELECT CC_Mensajes_Mostrar__c FROM CC_Lista_Valores__c
                                                  WHERE RecordTypeId = :idValorRT AND CC_Activa__c = true
                                                  AND Name = :subestado AND CC_Valor2__c = 'Subestado'
                                                  AND CC_Lista__r.Name = :estado
                                                  AND CC_Activa__c = true
                                                  AND CC_Lista__r.CC_Activa__c = true
                                                  AND CC_Lista__r.CC_Lista__r.CC_Activa__c = true];
        
        if (!listaValores.isEmpty() && String.isNotBlank(listaValores[0].CC_Mensajes_Mostrar__c)) {
            comentarioCliente = listaValores[0].CC_Mensajes_Mostrar__c;
        }

        return comentarioCliente;
    }

}