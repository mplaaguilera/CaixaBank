public with sharing class CC_WS_Onboarding {
    public static String recuperarClienteOnboarding(String recordId, String nif) {
        String retorno;
        try {
            System.debug('::: recordId: ' + recordId);
            System.debug('::: nif: ' + nif);
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
                System.debug('::: xmlResponse: ' + xmlResponse);
                String jsonResponse = convertXMLToJSON(xmlResponse);
                System.debug('::: jsonResponse: ' + jsonResponse);
                Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);

                System.debug('::: jsonMap: ' + jsonMap);

                Map<String, Object> body = (Map<String, Object>) jsonMap.get('Body');
                Map<String, Object> ConsultaEstadoSolicitudResponse = (Map<String, Object>) body.get('ConsultaEstadoSolicitudResponse');
                Map<String, Object> consultaEstadoSolicitudSalesforceResponse = (Map<String, Object>) ConsultaEstadoSolicitudResponse.get('consultaEstadoSolicitudSalesforceResponse');

                Map<String, Object> resultado = (Map<String, Object>) consultaEstadoSolicitudSalesforceResponse.get('resultado');
                String codigo = (String) resultado.get('codigo');
                System.debug('::: codigo: ' + codigo);
                Case caso = [SELECT CBK_Case_Extension_Id__c, AccountId FROM Case WHERE Id = :recordId LIMIT 1];
                System.debug('::: caso: ' + caso);
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

                    if (caso.CBK_Case_Extension_Id__c != null) {
                        CBK_Case_Extension__c caseExtension = [SELECT Id FROM CBK_Case_Extension__c WHERE Id = :caso.CBK_Case_Extension_Id__c LIMIT 1];
                        caseExtension.CC_EmpresaONB__c = empresa;
                        caseExtension.CC_EstadoONB__c = estado;
                        caseExtension.CC_SubestadoONB__c = subestado;
                        caseExtension.CC_FechaEstadoONB__c = fechaEstado;
                        caseExtension.CC_MotivoCierreONB__c = motivoCierre;
                        caseExtension.CC_NumSR__c = idReferencia;

                        update caseExtension;
                    } else {
                        CBK_Case_Extension__c caseExtensionNew = new CBK_Case_Extension__c();
                        caseExtensionNew.Case_Id__c = recordId;
                        caseExtensionNew.CC_EmpresaONB__c = empresa;
                        caseExtensionNew.CC_EstadoONB__c = estado;
                        caseExtensionNew.CC_SubestadoONB__c = subestado;
                        caseExtensionNew.CC_FechaEstadoONB__c = fechaEstado;
                        caseExtensionNew.CC_MotivoCierreONB__c = motivoCierre;
                        caseExtensionNew.CC_NumSR__c = idReferencia;
                        insert caseExtensionNew; 

                        caso.CBK_Case_Extension_Id__c = caseExtensionNew.Id;
                        actualizarCaso = true;
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
                        Account nuevaCuenta = new Account();
                        nuevaCuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
                        nuevaCuenta.CC_Numero_Documento__c = numeroDocumento;
                        nuevaCuenta.FirstName = nombreSeparado[0];
                        nuevaCuenta.LastName = nombreSeparado[1] + ' ' + nombreSeparado[2];
                        nuevaCuenta.PersonMobilePhone = telefono;
                        nuevaCuenta.PersonBirthdate = fechaNac;
                        
                        insert nuevaCuenta;

                        caso.AccountId = nuevaCuenta.Id;
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

        if (estado == 'Validación Vídeo Desasistida') {
            if (subestado == 'Validación Vídeo Desasistida') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Espera Validación Vídeo Desasistida') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está resolviendo una incidencia técnica que se ha detectado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            }
        } else if (estado == 'Alta Cliente') {
            if (subestado == 'Alta Cliente') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Incidencia Alta Cliente') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está resolviendo una incidencia técnica que se ha detectado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            }
        } else if (estado == 'Alta Contratos') {
            if (subestado == 'Revisión Alta Contratos') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está resolviendo una incidencia técnica que se ha detectado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Revisión Señal 034 – Alta Cliente Internet') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Incidencia Alta Contratos') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está resolviendo una incidencia técnica que se ha detectado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            }
        } else if (estado == 'Revisión Documentación') {
            if (subestado == 'Revisión Señal 034 – Alta Cliente Internet') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Revisión Previa Salesforce') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está resolviendo una incidencia técnica que se ha detectado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Revisión Documentación Autónomo') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando, junto con tu documentación como autónomo, si ya nos la has enviado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud.';
            } else if (subestado == 'Espera Documentación Autónomo') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos a la espera de recibir tu documentación como autónomo. Recuerda que debe ser un documento original, no una fotocopia. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Incidencia Revisión Documentación Autónomo') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está revisando tu documentación como autónomo. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Revisión Documentación Nómina') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando, junto con tu documentación de ingresos, tu nómina/pensión, si ya nos la has enviado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Espera Documentación Nómina') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos a la espera de recibir tus documentos de ingresos, tu nómina/pensión. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Incidencia Revisión Documentación Nómina') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está revisando, junto con tu documentación de ingresos, tu nómina/pensión. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Revisión Cert. UE') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando, junto con tu Certificado de la Unión Europea, si nos lo has enviado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Espera Cert. UE') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos a la espera de recibir tu Certificado de la Unión Europea. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Incidencia Cert. UE') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está revisando, junto con tu Certificado de la Unión Europea, si nos lo has enviado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Revisión Doc Id (ICAR)') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Espera Doc Id (ICAR)') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Incidencia revisión Doc Id (ICAR)') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está revisando. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Pendiente Digitalizar NIF') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Ver Error Envío NIF') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está gestionando. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            }
        } else if (estado == 'Espera Firma o Iberpay o Señales') {
            if (subestado == 'Revisión Previa Salesforce') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está resolviendo una incidencia técnica que se ha detectado. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Pendiente Firma') {
                comentarioCliente = 'Tu solicitud ya está gestionada y el alta como cliente está pendiente de tu firma a través de la App. En cuanto firmes, recibirás el resto de información a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Validación Presencial') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos finalizando la gestión. Los compañeros de la oficina te irán informando del avance y recibirás también información a través del correo electrónico que nos facilitaste';
            } else if (subestado == 'Pendiente Retirada Señal 213') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos finalizando la gestión. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Revisión Retirada Señal 213') {
                comentarioCliente = 'Hemos recibido tu solicitud y se está resolviendo una incidencia técnica para finalizar la gestión. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Pendiente Retirada Señal Crédito') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos finalizando la gestión. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Revisión Retirada Señal Crédito') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos finalizando la gestión. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Pendiente Señal 034 – Pendiente Verificar Oficina') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos finalizando la gestión. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Revisión Señal 034 – Pendiente Verificar Oficina') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos finalizando la gestión. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            } else if (subestado == 'Gestión Productos Adicionales') {
                comentarioCliente = 'Hemos recibido tu solicitud y estamos finalizando la gestión. Te iremos informando del avance en el proceso a través del correo electrónico que nos indicaste en la solicitud';
            }
        } else if (estado == 'Finalizado OK') {
            if (subestado == 'Finalizado OK') {
                comentarioCliente = 'Tu solicitud de alta ha finalizado correctamente, te hemos enviado un e-mail de bienvenida, revisa las carpetas de spam de tu correo electrónico y ya puedes empezar a operar a través de la app. ';
            } else if (subestado == 'Revisión Salesforce') {
                comentarioCliente = 'Tu solicitud de alta ha finalizado correctamente, te hemos enviado un e-mail de bienvenida, revisa las carpetas de spam de tu correo electrónico y ya puedes empezar a operar a través de la app.';
            }else if (subestado == 'Espera Verificación Oficina') {
                comentarioCliente = 'Tu solicitud de alta ha finalizado correctamente, te hemos enviado un e-mail de bienvenida, revisa las carpetas de spam de tu correo electrónico.  Contacta por favor con tu oficina para cualquier consulta.';
            }else if (subestado == 'Revisión Espera Verificación Oficina') {
                comentarioCliente = 'Tu solicitud de alta ha finalizado correctamente, te hemos enviado un e-mail de bienvenida, revisa las carpetas de spam de tu correo electrónico.  Contacta por favor con tu oficina para cualquier consulta.';
            }else if (subestado == 'Comprobación Verificación Oficina') {
                comentarioCliente = 'Tu solicitud de alta ha finalizado correctamente, te hemos enviado un e-mail de bienvenida, revisa las carpetas de spam de tu correo electrónico.  Contacta por favor con tu oficina para cualquier consulta.';
            }else if (subestado == 'Revisión Alta S214') {
                comentarioCliente = 'Tu solicitud de alta ha finalizado correctamente, sólo falta pasar por una oficina para validar tu documentación';
            }
        }
        return comentarioCliente;
    }

}