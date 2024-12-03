public with sharing class CSBD_CMN_Comdata {

    @SuppressWarnings('PMD.VariableNamingConventions')
    public class Input {
        public String recordId {get;set;}
        public String producto {get;set;}
        public String telefono {get;set;}
        public String nombre {get;set;}
        public String apellido_1 {get;set;}
        public String apellido_2 {get;set;}
        public String nif {get;set;}
        public String origen {get;set;}
        public String proceso {get;set;}
    }

    @SuppressWarnings('PMD.VariableNamingConventions')
    public class CSBD_CMN_Comdata_Mensaje {
        public String producto {get;set;}
        public String telefono {get;set;}
        public String nombre {get;set;}
        public String apellido_1 {get;set;}
        public String apellido_2 {get;set;}
        public String nif {get;set;}
        public String origen {get;set;}
        public String proceso {get;set;}
    }

    public class CSBD_CMN_Comdata_Respuesta {
        public String ok {get;set;} 
        public String mensaje {get;set;} 
        public String transaccion {get;set;} 
    }

    public static void enviarCMNComdata(Input input) {
        enviarCMNComdata(JSON.serialize(input));
    }

    @future(callout=true)
    public static void enviarCMNComdata(String jsonInput) {

        Input input = (Input)JSON.deserialize(jsonInput, Input.class);
        CSBD_CMN_Comdata_Mensaje mensaje = inputToMensaje(input);

        //Se recuperan los parámetros para la integración
        CC_InterfaceSettings__mdt parametrosInterfaz = obtenerParametrosIntegracion('CSBD_CMN_Comdata');

        //Envío del mensaje
        HttpRequest req = new HttpRequest();
        req.setEndpoint(parametrosInterfaz.CC_EndPoint__c);
        req.setClientCertificateName(parametrosInterfaz.CC_Certificado__c);
        req.setMethod(parametrosInterfaz.CC_TipoPeticion__c);
        req.setHeader('Content-Type', parametrosInterfaz.CC_ContentType__c);
        req.setBody(JSON.serialize(mensaje));

        Http http = new Http();
        if (!Test.isRunningTest()) {
            HTTPResponse httpResponse = http.send(req);
            CSBD_CMN_Comdata_Respuesta respuesta = (CSBD_CMN_Comdata_Respuesta)JSON.deserialize(httpResponse.getBody(), CSBD_CMN_Comdata_Respuesta.class);
        
            //Creación de la tarea de la oportunidad
            if (!Test.isRunningTest()) {
                if (String.isNotBlank(input.recordId)) {
                    String asuntoTarea;
                    if (respuesta.ok == 'true') {
                        asuntoTarea = 'Externalización de CMN a Comdata';
                    } else {
                        asuntoTarea = 'Externalización de CMN a Comdata (ERROR)';
                    }
                    CSBD_Activity.crearActividad( input.recordId, asuntoTarea, 'Completed', asuntoTarea, JSON.serialize(mensaje) + '\n\n\n' + httpResponse.getBody(), null);
                }
            }
        }
    }

    private static CSBD_CMN_Comdata_Mensaje inputToMensaje(Input input) {
        //Descartar prefijo internacional de España
        input.telefono = input.telefono.removeStart('+34').removeStart('0034').removeStart('034');

        CSBD_CMN_Comdata_Mensaje mensaje = new CSBD_CMN_Comdata_Mensaje();
        mensaje.producto = input.producto;
        mensaje.telefono = input.telefono;
        mensaje.nombre = input.nombre;
        mensaje.apellido_1 = input.apellido_1;
        mensaje.apellido_2 = input.apellido_2;
        mensaje.nif = input.nif;
        mensaje.origen = input.origen;
        mensaje.proceso = input.proceso;
        return mensaje;
    }

    private static CC_InterfaceSettings__mdt obtenerParametrosIntegracion(String interfazDevName) {
        List<CC_InterfaceSettings__mdt> parametrosInterfaz = [SELECT DeveloperName, CC_Certificado__c, CC_Endpoint__c, CC_TipoPeticion__c, CC_ContentType__c
                                                                FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :interfazDevName AND CC_Activa__c = true];
        CC_InterfaceSettings__mdt resultado = null;
        if (!parametrosInterfaz.isEmpty()) {
            resultado = parametrosInterfaz[0];
        }
        return resultado;
    }
}