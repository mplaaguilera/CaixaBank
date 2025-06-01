public with sharing class CSBD_SIR {

    public static Map<String, Object> sirCalcLimites(String numperso, String presolicitud) {
        CC_InterfaceSettings__mdt parametrosInterfaz = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites');
        if (parametrosInterfaz == null) {
            return new Map<String, Integer>();
        } else {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(parametrosInterfaz.CC_EndPoint__c);
            req.setClientCertificateName(parametrosInterfaz.CC_Certificado__c);
            req.setMethod(parametrosInterfaz.CC_TipoPeticion__c);
            req.setHeader('Content-Type', parametrosInterfaz.CC_ContentType__c);

            String cuerpo = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sir="http://sircalclimites.riesgocalclimites.mca.si.absis.lacaixa.es/">';
            cuerpo += '<soapenv:Header/><soapenv:Body><sir:CalcLim><externalInputTO>';
            cuerpo += '<aplicacionInvocante>OCE</aplicacionInvocante>';
            cuerpo += '<canalInvocante>P</canalInvocante>';
            cuerpo += '<indicadorBureaus>N</indicadorBureaus>';
            cuerpo += '<numeroPersona>' + numperso + '</numeroPersona>';
            if (presolicitud != null) {
                cuerpo += '<numeroSolicitud>' + presolicitud + '</numeroSolicitud>';
            }
            cuerpo += '<tipoConsulta>A</tipoConsulta>';
            cuerpo += '<tipoLimite>1</tipoLimite>';
            cuerpo += '</externalInputTO></sir:CalcLim></soapenv:Body>';
            cuerpo += '</soapenv:Envelope>';
            req.setBody(cuerpo);

            HttpResponse response = new Http().send(req);
            return parsearRespuestaSirCalcLimites(response.getBody());
        }
    }

    /* Finalmente no es necesario invocar este servicio de SIR
    public static Map<String, Integer> sirConsultaScorings(String numperso) {
        CC_InterfaceSettings__mdt parametrosInterfaz = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings');
        if (parametrosInterfaz == null) {
            return new Map<String, Integer>();
        } else {
            Map<String, Integer> retorno = new Map<String, Integer>();

            HttpRequest req = new HttpRequest();
            req.setEndpoint(parametrosInterfaz.CC_EndPoint__c);
            req.setClientCertificateName(parametrosInterfaz.CC_Certificado__c);
            req.setMethod(parametrosInterfaz.CC_TipoPeticion__c);
            req.setHeader('Content-Type', parametrosInterfaz.CC_ContentType__c);

            String ticketSIR = numperso.leftPad(10, '0'); //falta fecha (9) y hora (9)

            String cuerpo = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sir="http://sircalclimites.riesgocalclimites.mca.si.absis.lacaixa.es/">';
            cuerpo += '<soapenv:Header/>';
            cuerpo += '<soapenv:Body>';
            cuerpo += '<sir:obDatTitulares>';
            cuerpo += '<Version>00</Version>';
            cuerpo += '<Opcion>00</Opcion>';
            cuerpo += '<Codapl>OCE</Codapl>';
            cuerpo += '<Empresa>00</Empresa>';
            cuerpo += '<Centrope>00</Centrope>';
            cuerpo += '<ListaTitulares>';
            cuerpo += '<ListaTitularesItem>';
            cuerpo += '<TicketSIR>' + ticketSIR + '<TicketSIR>';
            cuerpo += '</ListaTitularesItem>';
            cuerpo += '</ListaTitulares>';
            cuerpo += '</sir:obDatTitulares>';
            cuerpo += '</soapenv:Body>';
            cuerpo += '</soapenv:Envelope>';
            req.setBody(cuerpo);

            Http http = new Http();
            //HTTPResponse respuesta = http.send(req);
            //System.debug(respuesta.getBody());

            return retorno;
        }
    }
    */

    @TestVisible
    private static CC_InterfaceSettings__mdt obtenerParametrosIntegracion(String interfazDevName) {
        List<CC_InterfaceSettings__mdt> parametrosInterfaz = [SELECT DeveloperName, CC_Certificado__c, CC_Endpoint__c, CC_TipoPeticion__c, CC_ContentType__c
                                                                FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :interfazDevName AND CC_Activa__c = true LIMIT 1];
        if (!parametrosInterfaz.isEmpty()) {
            return parametrosInterfaz[0];
        } else {
            return null;
        }
    }

    private static Map<String, Object> parsearRespuestaSirCalcLimites(String respuesta) {
        Map<String, Object> resultado = new Map<String, Object>();
        DOM.Document docXML = new DOM.Document();
        docXML.load(respuesta);
        DOM.XmlNode root = docXML.getRootElement();
        if (root.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            for (DOM.XmlNode nodoRoot : root.getChildElements()) {
                if (nodoRoot.getName() == 'Body') {
                    for (DOM.XmlNode nodoBody : nodoRoot.getChildElements()) { //<ns2:CalcLimResponse>
                        for (DOM.XmlNode nodoelements : nodoBody.getChildElements()) { //<return>
                            for (DOM.XmlNode nodoDatosCalculo : nodoelements.getChildElement('datosCalculo', null).getChildElements()) {
                                if (nodoDatosCalculo.getName() == 'nivelRiesgo') {
                                    //Tramo de riesgo
                                    resultado.put('nivelRiesgo', String.valueOf(nodoDatosCalculo.getText().trim()));
                                } else if (nodoDatosCalculo.getName() == 'riesgoPrincipal') {
                                    //Escala maestra
                                    if (String.isBlank(nodoDatosCalculo.getText().trim())) {
                                        resultado.put('riesgoPrincipal',  null);
                                    } else {
                                        resultado.put('riesgoPrincipal', Decimal.valueOf(nodoDatosCalculo.getText().trim()).divide(10, 1, System.RoundingMode.UNNECESSARY));
                                    }
                                }
                            }
                            for (DOM.XmlNode nodoLimites : nodoelements.getChildElement('limites', null).getChildElements()) {
                                if (nodoLimites.getName() == 'prestamoOfiDisp' || nodoLimites.getName() == 'prestamoOnlDisp' || nodoLimites.getName() == 'tarjetasOfiDisp' || nodoLimites.getName() == 'tarjetasOnlDisp' || nodoLimites.getName() == 'compraEstOfiDisp') {
                                    resultado.put(nodoLimites.getName(), Decimal.valueOf(nodoLimites.getText().trim()));
                                }
                            }
                        }
                    }
                }
                break;
            }
        }
        return resultado;
    }

    public static void actualizarDatosRiesgoCliente(Id idContacto, Opportunity oportunidad) {

        Map<Id, List<Opportunity>> idContactoOportunidadesMap = new Map<Id, List<Opportunity>>();
        idContactoOportunidadesMap.put(idContacto, new List<Opportunity>{oportunidad});
        actualizarDatosRiesgoCliente(new List<Id>{idContacto}, idContactoOportunidadesMap);
    }

    public static Map<Id, Map<String, Object>> actualizarDatosRiesgoCliente(List<Id> idContactos, Map<Id, List<Opportunity>> idContactoOportunidadesMap) {
        //El retorno es un mapa con la respuesta para cada cliente (Map<idContacto, Map<Campo, Valor>>)
        Map<Id, Map<String, Object>> retorno = new Map<Id, Map<String, Object>>();

        Set<Id> idsContactos = new Set<Id>(idContactos);
        List<Opportunity> oportunidadesContactoList = new List<Opportunity>();
        List<Contact> contactos = [SELECT CC_NumPerso__c FROM Contact WHERE Id IN :idsContactos];
        for (Contact contacto : contactos) {
            if (String.isNotBlank(contacto.CC_NumPerso__c) && idContactoOportunidadesMap.containsKey(contacto.Id)) {
                oportunidadesContactoList = idContactoOportunidadesMap.get(contacto.Id);
                for (Opportunity oportunidad: oportunidadesContactoList) {
                    //Invocación al servicio de consulta de importes preconcedidos
                    Map<String, Object> respuestaLimites = sirCalcLimites(contacto.CC_NumPerso__c, oportunidad.CSBD_Now_Presolicitud__c);
                    /*
                    //Invocación al servicio de consulta de scoring
                    Map<String, Integer> respuestaScoring = sirConsultaScorings(contacto.CC_NumPerso__c);
                    */

                    //Actualización de los importes prconcedidos del contacto
                    if (!respuestaLimites.isEmpty()) {
                        contacto.CSBD_Actualizacion_Datos_Riesgo__c = true; //Inhabilita validation rule de bloqueo ALF
                        contacto.CSBD_Tramo_Riesgo__c = (String)respuestaLimites.get('nivelRiesgo');
                        contacto.CSBD_Escala_Maestra__c = (Decimal)respuestaLimites.get('riesgoPrincipal');
                        contacto.CSBD_Limite_Prestamos_Oficinas__c = (Decimal)respuestaLimites.get('prestamoOfiDisp');
                        contacto.CSBD_Limite_Prestamos_Canales__c = (Decimal)respuestaLimites.get('prestamoOnlDisp');
                        contacto.CSBD_Limite_Tarjetas_Oficinas__c = (Decimal)respuestaLimites.get('tarjetasOfiDisp');
                        contacto.CSBD_Limite_Tarjetas_Canales__c = (Decimal)respuestaLimites.get('tarjetasOnlDisp');
                        contacto.CSBD_Limite_Compra_Estrella__c = (Decimal)respuestaLimites.get('compraEstOfiDisp');
                        contacto.CSBD_Ultima_Actualizacion_SIR__c = System.now();

                        retorno.put(contacto.Id, respuestaLimites);
                    }

                    /*
                    //Actualización de los datos de scoring del contacto
                    if (!respuestaScoring.isEmpty()) {
                        //PENDIENTE ACTUALIZAR DATOS respuestaScoring
                    }
                    */
                }
            }
        }
        update contactos;

        //Desmarcar flag para inhabilitar validation rule de bloqueo ALF
        for (Contact contacto : contactos) {
            contacto.CSBD_Actualizacion_Datos_Riesgo__c = false;
        }
        update contactos;

        return retorno;
    }

    public static void actualizarDatosRiesgoClientesOportunidades(List<Id> idOportunidades, Boolean actualizarOportunidades) {
        List<Opportunity> oportunidades = [SELECT CSBD_Contact__c, CSBD_Contact_2__c, CSBD_Now_Presolicitud__c
                                            FROM Opportunity WHERE Id IN :idOportunidades AND CSBD_Account_Tipo_Persona__c != 'J'];

        Map<Id, List<Opportunity>> idContactoOportunidadesMap = new Map<Id, List<Opportunity>>();
        List<Opportunity> oportunidadesContactoList = new List<Opportunity>();

        for (Opportunity oportunidad : oportunidades) {
            if (!idContactoOportunidadesMap.containsKey(oportunidad.CSBD_Contact__c)) {
                idContactoOportunidadesMap.put(oportunidad.CSBD_Contact__c, new List<Opportunity>());
            }
            oportunidadesContactoList = idContactoOportunidadesMap.get(oportunidad.CSBD_Contact__c);
            oportunidadesContactoList.add(oportunidad);
        }

        // Eric
        List<Id> sumaTitulares = CC_MetodosUtiles.listaCampo(oportunidades, 'CSBD_Contact__c');
        sumaTitulares.addAll(CC_MetodosUtiles.listaCampo(oportunidades, 'CSBD_Contact_2__c'));
        sumaTitulares = CC_MetodosUtiles.descartarDuplicadosLista(sumaTitulares);

        Map<Id, Map<String, Object>> datosRiesgoClientes = actualizarDatosRiesgoCliente(sumaTitulares, idContactoOportunidadesMap);
        // Map<Id, Map<String, Object>> datosRiesgoClientes = actualizarDatosRiesgoCliente(CC_MetodosUtiles.listaCampo(oportunidades, 'CSBD_Contact__c'), idContactoOportunidadesMap);

        if (actualizarOportunidades) {
            for (Opportunity oportunidad : oportunidades) {
                Map<String, Object> datosRiesgoClienteOportunidad = datosRiesgoClientes.get(oportunidad.CSBD_Contact__c);
                oportunidad.CSBD_Limite_Prestamos_Oficinas__c = (Decimal)datosRiesgoClienteOportunidad.get('prestamoOfiDisp');
                oportunidad.CSBD_Limite_Prestamos_Canales__c = (Decimal)datosRiesgoClienteOportunidad.get('prestamoOnlDisp');
                oportunidad.CSBD_Limite_Tarjetas_Oficinas__c = (Decimal)datosRiesgoClienteOportunidad.get('tarjetasOfiDisp');
                oportunidad.CSBD_Limite_Tarjetas_Canales__c = (Decimal)datosRiesgoClienteOportunidad.get('tarjetasOnlDisp');
                oportunidad.CSBD_Limite_Compra_Estrella__c = (Decimal)datosRiesgoClienteOportunidad.get('compraEstOfiDisp');
            }
            update oportunidades;
        }
    }

    public static void actualizarDatosRiesgoClientesOportunidades(List<Id> idOportunidades) {
        actualizarDatosRiesgoClientesOportunidades(idOportunidades, false);
    }
}