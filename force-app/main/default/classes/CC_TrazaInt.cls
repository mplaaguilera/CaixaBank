public with sharing class CC_TrazaInt {

    public static CC_TrazaInt__c inicioTraza(String nombre, String origen, String identificador, String mensajeEntrada) {
        
        //Creación de traza en curso
        //Ejemplo de invocación: CC_Traza__c traza = CC_TrazaInt.inicioTraza('masvoz', 'registrarLlamadaEntrante', inputJson.connId, JSON.serialize(inputJson));
        
        if (trazaActiva(nombre)) {
            CC_TrazaInt__c traza = new CC_TrazaInt__c();
            traza.CC_FechaInicio__c = System.now();
            traza.Name = nombre;
            traza.CC_IdOrigen__c = origen.left(20);
            traza.CC_Identificador__c = identificador;
            traza.CC_MensajeEntrada__c = mensajeEntrada;
            insert traza;
            return traza;
        } else {
            return null;
        }
    }

    public static CC_TrazaInt__c finTraza(CC_TrazaInt__c traza, String mensajeSalida) {
        
        //Finalización de traza en curso con resultado OK
        //Ejemplos de invocación: CC_TrazaInt.finTraza(traza, JSON.serialize(output.JSON));

        if (traza != null) {
            traza.CC_FechaFin__c = System.now();
            traza.CC_FinOK__c = true;
            traza.CC_MensajeSalida__c = mensajeSalida;
            update traza;
        }
        return traza;
    }

    public static CC_TrazaInt__c finTraza(CC_TrazaInt__c traza, String mensajeSalida, String tipoError, String detalleError) {
        
        //Finalización de traza en curso con resultado KO
        //Ejemplos de invocación: CC_TrazaInt.finTraza(traza, JSON.serialize(output.JSON), codigoError, mensajeError);

        if (traza != null) {
            traza.CC_FechaFin__c = System.now();
            traza.CC_FinOK__c = false;
            traza.CC_MensajeSalida__c = mensajeSalida;
            traza.CC_TipoError__c = tipoError;
            traza.CC_DetalleError__c = detalleError;
            update traza;
        }
        return traza;
    }

    public static CC_TrazaInt__c traza(CC_TrazaInt__c traza) {
        
        //Creación de traza ya finalizada
        
        if (trazaActiva(traza.Name)) {
            traza.CC_IdOrigen__c = traza.CC_IdOrigen__c.left(20);
            traza.CC_FechaInicio__c = traza.CC_FechaInicio__c == null ? System.now() : traza.CC_FechaInicio__c;
            traza.CC_FechaFin__c = traza.CC_FechaFin__c == null ? System.now() : traza.CC_FechaFin__c;
            insert traza;
            return traza;
        } else {
            return null;
        }
    }

    public static CC_TrazaInt__c generarTraza(String nombreTraza, String identificador, String estado, String mensajeEntrada, String detalleError, String requestString, Boolean finOK) {
        if (trazaActiva(nombreTraza)) {
            CC_TrazaInt__c traza = new CC_TrazaInt__c();
            traza.Name = nombreTraza;
            traza.CC_FechaInicio__c = System.now();
            traza.CC_FechaFin__c = System.now();
            traza.CC_Identificador__c = identificador;
            traza.CC_MensajeEntrada__c = mensajeEntrada?.left(131072);
            traza.CC_MensajeSalida__c = requestString?.left(131072);
            traza.CC_DetalleError__c = detalleError?.left(32768);
            traza.CC_EstadoInt__c = estado;
            traza.CC_FinOK__c = finOK;
            return traza;
        }
        else {
            return null; 
        }
    }
    //método traza activa
    public static Boolean trazaActiva(String nombre) {

        if (Test.isRunningTest()) {
            return true;
        } else {
            return [SELECT Count() FROM CC_Traza_Activa__mdt
                    WHERE MasterLabel = :nombre AND CC_Activa__c = TRUE LIMIT 1] == 1;
        }
    }
}