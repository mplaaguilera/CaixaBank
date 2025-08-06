@RestResource(urlMapping='/RegistrarTicketOcp/*')
global with sharing class CBK_WS_RegistrarTicketOcp {

    @HttpPost
    global static CBK_WS_RegistrarTicketOcp.Output registrarTicketOcp() {

        CBK_WS_RegistrarTicketOcp.Input entrada = new CBK_WS_RegistrarTicketOcp.Input();
        CBK_WS_RegistrarTicketOcp.Output salida = new CBK_WS_RegistrarTicketOcp.Output();
        String jsonEntrada = RestContext.request.requestBody.toString();
        CC_TrazaInt__c traza;

        try {
            entrada = (CBK_WS_RegistrarTicketOcp.Input)JSON.deserialize(jsonEntrada, CBK_WS_RegistrarTicketOcp.Input.class);
            traza = CC_TrazaInt.inicioTraza('CBK_WS_RegistrarTicketOcp', 'Genesys', entrada.referencia, jsonEntrada);

            if (String.isBlank(entrada.referencia)) {
                salida.resultado = 'KO';
                salida.error = 'referencia es obligatorio';
            } else if (entrada.tipoLlamadaId != 'Name' && entrada.tipoLlamadaId != 'ConnId') {
                salida.resultado = 'KO';
                salida.error = 'tipoLlamadaId debe ser \'Name\' o \'ConnId\'';
            } else {
                salida.referencia = entrada.referencia;
                entrada.marcarLlamadasDuplicadas();

                Map<String, CBK_WS_RegistrarTicketOcp.TicketOcp> mapaNombreLlamadaTicketOcp = new Map<String, CBK_WS_RegistrarTicketOcp.TicketOcp>();
                for (CBK_WS_RegistrarTicketOcp.TicketOcp ticketOcp : entrada.ticketsOcp) {
                    if (ticketOcp.error != 'Identificador de llamada duplicado') {
                        //Resultado por defecto
                        ticketOcp.resultado = 'KO';
                        ticketOcp.error = '';

                        if (String.isBlank(ticketOcp.llamadaId) || String.isBlank(ticketOcp.ticketOcp)) {
                            if (String.isBlank(ticketOcp.llamadaId)) {
                                ticketOcp.resultado = 'KO';
                                ticketOcp.error = 'llamadaId es obligatorio';
                            }
                            if (String.isBlank(ticketOcp.ticketOcp)) {
                                ticketOcp.resultado = 'KO';
                                ticketOcp.error = 'ticketOcp es obligatorio';
                            }
                        } else {
                            mapaNombreLlamadaTicketOcp.put(ticketOcp.llamadaId, ticketOcp);
                        }
                    }
                }

                if (!mapaNombreLlamadaTicketOcp.isEmpty()) {
                    //Preparar update de llamadas
                    List<CC_Llamada__c> llamadas;
                    if (entrada.tipoLlamadaId == 'ConnId') {
                        llamadas = [SELECT CC_ConnId__c, OB_Estado__c, OB_Campanya_Id__c, OB_Producto_Id__c, OB_No_Quiere_Telemarketing__c FROM CC_Llamada__c
                                    WHERE RecordType.DeveloperName = 'OB_Cliente' AND OB_Campanya_Id__c != NULL AND OB_Producto_Id__c != NULL
                                    AND CC_ConnId__c IN :mapaNombreLlamadaTicketOcp.keySet()];
                    } else {
                        llamadas = [SELECT Name, OB_Estado__c, OB_Campanya_Id__c, OB_Producto_Id__c, OB_No_Quiere_Telemarketing__c FROM CC_Llamada__c
                                    WHERE RecordType.DeveloperName = 'OB_Cliente' AND OB_Campanya_Id__c != NULL AND OB_Producto_Id__c != NULL
                                    AND Name IN :mapaNombreLlamadaTicketOcp.keySet()];
                    }
                    entrada.marcarLlamadasNoEncontradas(llamadas);

                    String campoIdentificadorLlamada = entrada.tipoLlamadaId == 'ConnId' ? 'CC_ConnId__c' : 'Name';

                    Map<String, Id> mapaNombreIdLlamada = new Map<String, Id>();
                    Map<Id, String> mapaIdNombreLlamada = new Map<Id, String>();
                    for (CC_Llamada__c llamada : llamadas) {
                        mapaNombreIdLlamada.put(llamada.get(campoIdentificadorLlamada).toString(), llamada.Id);
                        mapaIdNombreLlamada.put(llamada.Id, llamada.get(campoIdentificadorLlamada).toString());
                    }

                    Map<Id, Set<Id>> campanyasProductosConValidacion = campanyasProductosConValidacion(llamadas);

                    for (CC_Llamada__c llamada : llamadas) {
                        //Informar ticket en la llamada
                        llamada.CBK_Ticket_OCP__c = mapaNombreLlamadaTicketOcp.get(llamada.get(campoIdentificadorLlamada).toString()).ticketOcp;

                        //Avanzar flujo de estados de la llamada
                        if (llamada.OB_No_Quiere_Telemarketing__c) {
                            llamada.OB_Estado__c = 'OB_Cerrada';
                        } else if (llamada.OB_Estado__c == 'OB_Pendiente_Grabacion_Negativa') {
                            llamada.OB_Estado__c = 'OB_Rechazada';
                        } else if (llamada.OB_Estado__c == 'OB_Pendiente_Grabacion'
                        && campanyasProductosConValidacion.containsKey(llamada.OB_Campanya_Id__c)
                        && campanyasProductosConValidacion.get(llamada.OB_Campanya_Id__c).contains(llamada.OB_Producto_Id__c)) {
                            llamada.OB_Estado__c = 'OB_Pendiente_Validacion';
                        } else {
                            llamada.OB_Estado__c = 'OB_Cerrada';
                        }
                    }

                    //Resultado del update de llamadas
                    for (Database.SaveResult resultadoUpdate : Database.update(llamadas, false)) {
                        CBK_WS_RegistrarTicketOcp.TicketOcp ticketOcp = mapaNombreLlamadaTicketOcp.get(mapaIdNombreLlamada.get(resultadoUpdate.getId()));
                        if (resultadoUpdate.isSuccess()) {
                            ticketOcp.resultado = 'OK';
                        } else {
                            ticketOcp.resultado = 'KO';
                            String error = '';
                            for (Database.Error errorUpdate : resultadoUpdate.getErrors()) {
                                error += errorUpdate.getMessage();
                            }
                            ticketOcp.error = error;
                        }
                    }
                }
            }
        } catch (Exception e) {
            salida.resultado = 'KO';
            salida.error = 'ExceptionType: ' + e.getTypeName() + ' - ExceptionMessage: ' + e.getMessage() + ' - Line: ' + e.getStackTraceString().substringBetween('Class.', '\nClass.');
            CBK_Log.error(e);
        }

        salida.ticketsOcp = entrada.ticketsOcp;
        salida.calcularResultado();

        String jsonSalida = JSON.serializePretty(salida);
        if (salida.resultado == 'OK') {
            CC_TrazaInt.finTraza(traza, jsonSalida); //Fin traza OK
        } else {
            CC_TrazaInt.finTraza(traza, jsonSalida, 'KO', salida.error); //Fin traza KO
        }
        return salida;
    }

    private static Map<Id, Set<Id>> campanyasProductosConValidacion(List<CC_Llamada__c> llamadas) {
        Map<Id, Set<Id>> retorno = new Map<Id, Set<Id>>();
        for (OB_Parametrizacion__c relacion : [SELECT OB_Parametrizacion_Padre__c, OB_Parametrizacion_Relacionada__c FROM OB_Parametrizacion__c
                                                WHERE RecordType.DeveloperName = 'OB_Relacion_Campanya_Producto' AND OB_Tipo_Validacion__c = 'BackOffice'
                                                AND (OB_Parametrizacion_Padre__c = :CC_MetodosUtiles.listaCampo(llamadas, 'OB_Campanya_Id__c')
                                                OR OB_Parametrizacion_Relacionada__c = :CC_MetodosUtiles.listaCampo(llamadas, 'OB_Producto_Id__c'))]) {
            if (!retorno.containsKey(relacion.OB_Parametrizacion_Padre__c)) {
                retorno.put(relacion.OB_Parametrizacion_Padre__c, new Set<Id>{relacion.OB_Parametrizacion_Relacionada__c});
            } else {
                retorno.get(relacion.OB_Parametrizacion_Padre__c).add(relacion.OB_Parametrizacion_Relacionada__c);
            }
        }
        return retorno;
    }

    @TestVisible
    private class TicketOcp {
        @TestVisible
        String llamadaId {get;set;}
        @TestVisible
        String ticketOcp {get;set;}
        String resultado {get;set;}
        String error {get;set;}

        public TicketOcp() {
            this.llamadaId = '';
            this.ticketOcp = '';
            this.resultado = '';
            this.error = '';
        }
    }

    @TestVisible
    private class Input {
        @TestVisible
        String referencia {get;set;}
        @TestVisible
        String tipoLlamadaId {get;}
        @TestVisible
        List<TicketOcp> ticketsOcp {get;set;}

        public Input() {
            this.referencia = '';
            this.ticketsOcp = new List<CBK_WS_RegistrarTicketOcp.TicketOcp>();
        }

        public void marcarLlamadasDuplicadas() {
            Set<String> nombresLlamadas = new Set<String>();
            for (CBK_WS_RegistrarTicketOcp.TicketOcp ticketOcp : this.ticketsOcp) {
                if (!nombresLlamadas.contains(ticketOcp.llamadaId)) {
                    nombresLlamadas.add(ticketOcp.llamadaId);
                } else {
                    ticketOcp.resultado = 'KO';
                    ticketOcp.error = 'Identificador de llamada duplicado';
                }
            }
        }

        public void marcarLlamadasNoEncontradas(List<CC_Llamada__c> llamadasEncontradas) {
            List<String> nombresLlamadasEncontradas = CC_MetodosUtiles.listaCampo(
                llamadasEncontradas,
                this.tipoLlamadaId == 'ConnId' ? 'CC_ConnId__c' : 'Name'
            );
            for (CBK_WS_RegistrarTicketOcp.TicketOcp ticketOcp : this.ticketsOcp) {
                if (!nombresLlamadasEncontradas.contains(ticketOcp.llamadaId)) {
                    ticketOcp.resultado = 'KO';
                    ticketOcp.error = 'Llamada no encontrada';
                }
            }
        }
    }

    global class Output {
        String referencia {get;set;}
        @TestVisible
        String resultado {get;set;}
        String error {get;set;}
        List<TicketOcp> ticketsOcp {get;set;}

        public Output() {
            this.referencia = '';
            this.resultado = '';
            this.error = '';
            this.ticketsOcp = new List<TicketOcp>();
        }

        public void calcularResultado() {
            if (this.resultado != 'KO') {
                this.resultado = 'OK';
                for (CBK_WS_RegistrarTicketOcp.TicketOcp ticketOcp : this.ticketsOcp) {
                    if (ticketOcp.resultado == 'KO') {
                        this.resultado = 'OK con errores';
                        break;
                    }
                }
            }
        }
    }

    private class DefaultException extends Exception {}
}