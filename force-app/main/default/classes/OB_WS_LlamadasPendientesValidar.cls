@RestResource(urlMapping='/LlamadasPendientesValidarOutbound/*')
global with sharing class OB_WS_LlamadasPendientesValidar {

    @HttpPost
    global static OB_WS_LlamadasPendientesValidar.Output llamadasPendientesValidar() {

        OB_WS_LlamadasPendientesValidar.Input entrada = new OB_WS_LlamadasPendientesValidar.Input();
        OB_WS_LlamadasPendientesValidar.Output salida = new OB_WS_LlamadasPendientesValidar.Output();
        String jsonEntrada = RestContext.request.requestBody.toString();
        CC_TrazaInt__c traza;

        try {
            entrada = (OB_WS_LlamadasPendientesValidar.Input)JSON.deserialize(jsonEntrada, OB_WS_LlamadasPendientesValidar.Input.class);
            traza = CC_TrazaInt.inicioTraza('OB_WS_LlamadasPendientesValidar', 'Genesys', entrada.referencia, jsonEntrada);

            if (String.isBlank(entrada.referencia)) {
                salida.resultado = 'KO';
                salida.error = 'referencia es obligatorio';
            } else {
                salida.referencia = entrada.referencia;

                /*
                Date fecha = Date.newInstance(
                    Integer.valueOf(entrada.fecha.substring(0, 4)),
                    Integer.valueOf(entrada.fecha.substring(4, 6)),
                    Integer.valueOf(entrada.fecha.substring(6, 8))
                );
                */

                List<CC_Llamada__c> llamadas = [SELECT CC_ConnId__c FROM CC_Llamada__c
                                                WHERE RecordType.DeveloperName = 'OB_Cliente' AND CC_ConnId__c != NULL
                                                AND OB_Estado__c IN ('OB_Pendiente_Grabacion', 'OB_Pendiente_Grabacion_Negativa')
                                                //AND DAY_ONLY(CC_Fecha_Inicio__c) = :fecha];
                                                ORDER BY CC_Fecha_Inicio__c ASC];
                salida.connIds = CC_MetodosUtiles.listaCampo(llamadas, 'CC_ConnId__c');
            }
        } catch (Exception e) {
            salida.resultado = 'KO';
            salida.error = 'ExceptionType: ' + e.getTypeName() + ' - ExceptionMessage: ' + e.getMessage() + ' - Line: ' + e.getStackTraceString().substringBetween('Class.', '\nClass.');
            CBK_Log.error(e);
        }

        String jsonSalida = JSON.serializePretty(salida);
        if (salida.resultado == 'OK') {
            CC_TrazaInt.finTraza(traza, jsonSalida); //Fin traza OK
        } else {
            CC_TrazaInt.finTraza(traza, jsonSalida, 'KO', salida.error); //Fin traza KO
        }
        return salida;
    }

    @TestVisible
    private class Input {
        @TestVisible
        String referencia {get; set;}
        String fecha {get; set;}
    }

    global class Output {
        String referencia {get; set;}
        String resultado {get; set;}
        String error {get; set;}
        List<String> connIds {get; set;}

        public Output() {
            this.resultado = 'OK';
            this.error = '';
            this.connIds = new List<String>();
        }
    }
}