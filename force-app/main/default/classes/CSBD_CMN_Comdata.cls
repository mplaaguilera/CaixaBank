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
        
        try{
            Input input = (Input) JSON.deserialize(jsonInput, Input.class);

            CSBD_CMN_Comdata_Mensaje mensaje = inputToMensaje(input); // Convertir el input a mensaje

            String intSetting = 'CSBD_CMN_Comdata';

            // Creamos el header
            Map<String, String> mHeaders = new Map<String, String>();
            mHeaders.put('Content-Type', 'application/json; charset=UTF-8');

            //creamos el wrapper para la petición
            CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
                requestWrp.body = JSON.serialize(mensaje); // Convertir el mensaje a JSON
                requestWrp.intSetting = intSetting;
                requestWrp.mHeaders = mHeaders;

            //Creamos la traza
            CC_TrazaInt__c comdataTraza = new CC_TrazaInt__c();
            comdataTraza.Name = 'ComDataTraza';
            comdataTraza.CC_FechaInicio__c = Datetime.now();
            comdataTraza.CC_MensajeEntrada__c = requestWrp.body;
            insert comdataTraza;

            //Fin de la traza

            HttpRequest request = CBK_HttpServiceIntegration.getRequest(requestWrp);
            HttpResponse respuesta = CBK_HttpServiceIntegration.callHttpService(
                request,
                intSetting,
                intSetting
            );

            //guardamos la respuesta en la traza
            comdataTraza.CC_MensajeSalida__c = respuesta.getBody();
            comdataTraza.CC_DetalleError__c = respuesta.getStatusCode() + ':' + respuesta.getBody();
            insert comdataTraza;

            if(respuesta.getStatusCode() != 200) {
                CBK_Log.error('Error al enviar mensaje a Comdata: ' + respuesta.getBody());
                ComdataTraza.CC_DetalleError__c = respuesta.getStatusCode() + ':' + respuesta.getBody();
            } else {
                CSBD_CMN_Comdata_Respuesta resp = (CSBD_CMN_Comdata_Respuesta)JSON.deserialize(respuesta.getBody(), CSBD_CMN_Comdata_Respuesta.class);
                ComdataTraza.CC_MensajeSalida__c = respuesta.getBody();
            }
            update ComdataTraza;
        } catch (Exception e) {
            CBK_Log.error(e);
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

    
}