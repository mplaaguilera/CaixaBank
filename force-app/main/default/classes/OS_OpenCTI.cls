global class OS_OpenCTI {

    webService static String registrarLlamadaEntrante(String inputJson) {
        CC_TrazaInt__c traza;
        String respuesta;
        try {
            OS_Llamada.Input input = jsonToLlamadaInput(EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            traza = CC_TrazaInt.inicioTraza('masvoz', 'regLlamadaEntrante', input.connId, EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            respuesta = JSON.serialize(OS_Llamada.openCTI_registrarLlamadaEntrante(input));
            CC_TrazaInt.finTraza(traza, respuesta);
            return respuesta;
        } catch(Exception e) {
            CC_TrazaInt.finTraza(traza, respuesta, e.getTypeName(), e.getMessage());
            return respuesta;
        }
    }
    
    webService static String registrarConsulta(String inputJson) {
        CC_TrazaInt__c traza;
        String respuesta;
        try {
            OS_Llamada.Input input = jsonToLlamadaInput(EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            traza = CC_TrazaInt.inicioTraza('masvoz', 'regConsulta', input.connId, EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            respuesta = OS_Llamada.openCTI_registrarConsulta(input);
            CC_TrazaInt.finTraza(traza, respuesta);
            return respuesta;
        } catch(Exception e) {
            CC_TrazaInt.finTraza(traza, respuesta, e.getTypeName(), e.getMessage());
            return respuesta;
        }
    }

    webService static String finalizarConsulta(String inputJson) {
        CC_TrazaInt__c traza;
        String respuesta;
        try {
            OS_Llamada.Input input = jsonToLlamadaInput(EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            traza = CC_TrazaInt.inicioTraza('masvoz', 'finalizarConsulta', input.connId, EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            respuesta = OS_Llamada.openCTI_finalizarConsulta(input);
            CC_TrazaInt.finTraza(traza, respuesta);
            return respuesta;
        } catch(Exception e) {
            CC_TrazaInt.finTraza(traza, respuesta, e.getTypeName(), e.getMessage());
            return respuesta;
        }
    }

    webService static String obtenerPrefijo(String inputJson) {
        CC_TrazaInt__c traza;
        String respuesta;
        try {
            OS_Llamada.Input input = jsonToLlamadaInput(EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            traza = CC_TrazaInt.inicioTraza('masvoz', 'obtenerPrefijo', input.connId, EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            respuesta = OS_Llamada.openCTI_obtenerPrefijo(input);
            CC_TrazaInt.finTraza(traza, respuesta);
            return respuesta;
        } catch(Exception e) {
            CC_TrazaInt.finTraza(traza, respuesta, e.getTypeName(), e.getMessage());
            return respuesta;
        }
    }

    webService static void registrarLlamadaSaliente(String inputJson) {
        CC_TrazaInt__c traza;
        try {
            OS_Llamada.Input input = jsonToLlamadaInput(EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            traza = CC_TrazaInt.inicioTraza('masvoz', 'regLlamadaSaliente', input.connId, EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            CC_Llamada__c llamada = OS_Llamada.openCTI_registrarLlamadaSaliente(input);
            CC_TrazaInt.finTraza(traza, null);
        } catch(Exception e) {
            CC_TrazaInt.finTraza(traza, '', e.getTypeName(), e.getMessage());
        }
    }

    webService static void finalizarLlamada(String inputJson) {
        CC_TrazaInt__c traza;
        try {
            OS_Llamada.Input input = jsonToLlamadaInput(EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            traza = CC_TrazaInt.inicioTraza('masvoz', 'finalizarLlamada', input.connId, EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            OS_Llamada.openCTI_finalizarLlamada(input);
            CC_TrazaInt.finTraza(traza, null);
        } catch(Exception e) {
            CC_TrazaInt.finTraza(traza, '', e.getTypeName(), e.getMessage());
        }
    }
    
    webService static void transferirLlamada(String inputJson) {
        CC_TrazaInt__c traza;
        try {
            OS_Llamada.Input input = jsonToLlamadaInput(EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            traza = CC_TrazaInt.inicioTraza('masvoz', 'transferirLlamada', input.connId, EncodingUtil.urlDecode(inputJson, 'UTF-8'));
            OS_Llamada.openCTI_transferirLlamada(input);
            CC_TrazaInt.finTraza(traza, null);
        } catch(Exception e) {
            CC_TrazaInt.finTraza(traza, '', e.getTypeName(), e.getMessage());
        }
    }

    private static OS_Llamada.Input jsonToLlamadaInput(String inputJson) {
        return (OS_Llamada.Input)JSON.deserialize(inputJson, OS_Llamada.Input.class);
    }
}