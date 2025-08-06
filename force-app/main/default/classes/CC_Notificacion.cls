public with sharing class CC_Notificacion {
    
    //Marc Pla, mayo 2019: Clase para métodos relacionados con notificaciones Toast.

    public static void publicarToast(List<String> mensajes, String type) {
        //Publica un mensaje Toast. 
        //El type puede ser 'info' (gris), 'success' (verde), 'warning' (amarillo) o 'error' (rojo)
        
        //List<Notification__e> notificaciones = new List<Notification__e>();
        List<CC_Aviso_Agrupador__e> notificacionesAgrupador = new List<CC_Aviso_Agrupador__e>();
        List<CC_Historial_Notificacion__c> notificacionesHist = new List<CC_Historial_Notificacion__c>();

        //Se añade cada mensaje indicado a la lista de Toast a publicar y en el histórico de notificaciones
        for (String mensaje : mensajes) {
            //notificaciones.add(new Notification__e(Message__c = mensaje,  Type__c = type));
            notificacionesAgrupador.add(new CC_Aviso_Agrupador__e(Message__c = mensaje,  Type__c = type));
            notificacionesHist.add(new CC_Historial_Notificacion__c(CC_Mensaje__c = mensaje, CC_Tipo__c = type));
        }

        //Se publican los mensajes de la lista y se inspecciona el resultado
        //List<Database.SaveResult> results = EventBus.publish(notificaciones);
        List<Database.SaveResult> results = EventBus.publish(notificacionesAgrupador);
        
        if (!notificacionesHist.isEmpty()) {
            Database.SaveResult[] ResultNH = Database.insert(notificacionesHist);
        }

        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    System.debug('Error publicando Toast de tipo "' + type + '": ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }       
        }
    }

    public static void publicarToastAviso(String mensaje) {
        List<String> mensajes = new List<String>();
        mensajes.add(mensaje);
        publicarToast(mensajes, 'warning');
    }

    //@InvocableMethod 
    //Para uso en process builder
    public static void publicarToastAviso(List<String> mensajes) {
        publicarToast(mensajes, 'warning');
    }

    @InvocableMethod 
    //Para uso en process builder
    public static void publicarToastAviso(List<AgrupadorMensajeInfo> agrupadorInfo) {
        Set <Id> idAgrup = new Set <Id> ();
        List <String> mensajes = new List <String> ();
        for (AgrupadorMensajeInfo agrupador : agrupadorInfo){
            idAgrup.add(agrupador.idAgrupador);
            mensajes.add(agrupador.mensaje);
        }
        
        List <Case> casos = ([SELECT Status, CC_Agrupador_Id__c, RecordType.DeveloperName, CC_NotIncidencia__c FROM Case WHERE CC_Agrupador_Id__c IN :idAgrup AND Status != 'Cerrado' AND Status != 'Pendiente Revisión']);
        Boolean isCliente = false;
        for (Case caso : casos) 
        {
            if (caso.RecordType.DeveloperName == 'CC_Cliente'){
                isCliente = true;
                break;
            }
        } 

        if (isCliente){
            publicarToast(mensajes, 'warning');
        }
    }
    
    public static void publicarToastInfo(List<String> mensajes) {
        publicarToast(mensajes, 'info');
    }

    public static void publicarToastInfo(String mensaje) {
        List<String> mensajes = new List<String>();
        mensajes.add(mensaje);
        publicarToast(mensajes, 'info');
    }

    public static void publicarToastError(List<String> mensajes) {
        publicarToast(mensajes, 'error');
    }

    public static void publicarToastError(String mensaje) {
        List<String> mensajes = new List<String>();
        mensajes.add(mensaje);
        publicarToast(mensajes, 'error');
    }

    public static void publicarToastExito(String mensaje) {
        List<String> mensajes = new List<String>();
        mensajes.add(mensaje);
        publicarToast(mensajes, 'success');
    }

    /*
    private class CC_Notificacion_JSON_Input {
        String customNotifTypeId;
        List<Id> recipientIds;
        String title;
        String body;
        String targetId;
    }

    private class CC_Notificacion_JSON {
        List<CC_Notificacion.CC_Notificacion_JSON_Input> inputs;
    }

    public class CC_Custom_Notification {
        public String idTipoNotificacion;
        public List<Id> idsDestinatarios;
        public String titulo;
        public String cuerpo;
        public Id idRegistro;
    }

    public static void enviarNotificaciones(List<CC_Notificacion.CC_Custom_Notification> notificaciones) {
        String restAPIURL = URL.getSalesforceBaseUrl().toExternalForm(); 
        restAPIURL += '/services/data/v46.0/actions/standard/customNotificationAction';  

        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setEndpoint(restAPIURL);
        httpRequest.setMethod('POST');   
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); 
        httpRequest.setHeader('Content-Type', 'application/json'); 
        httpRequest.setBody(serializarNotificaciones(notificaciones));

        Http http = new Http();
        HttpResponse httpResponse = http.send(httpRequest);  

        String response = '';
        try {  
            if (httpResponse.getStatusCode() == 200 ) {  
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));  
            } else {  
                throw new CalloutException(httpResponse.getBody());
            }   
        } catch(System.Exception e) {  
            System.debug('ERROR: ' + e);  
            throw e;  
        }
    }

    private static String serializarNotificaciones(List<CC_Notificacion.CC_Custom_Notification> notificaciones) {
        List<CC_Notificacion.CC_Notificacion_JSON_Input> json_inputs = new List<CC_Notificacion.CC_Notificacion_JSON_Input>();

        for (CC_Notificacion.CC_Custom_Notification notificacion : notificaciones) {
            CC_Notificacion.CC_Notificacion_JSON_Input json_input = new CC_Notificacion.CC_Notificacion_JSON_Input();
            json_input.customNotifTypeId = '0ML6E0000008OK6WAM'; //Para PRE este Id es 0ML5E0000004CAVWA2
            json_input.recipientIds = notificacion.idsDestinatarios;
            json_input.title = notificacion.titulo; //.substring(0, 250);
            json_input.body = notificacion.cuerpo; //.substring(0, 750);
            json_input.targetId = notificacion.idRegistro;

            json_inputs.add(json_input);
        }

        CC_Notificacion.CC_Notificacion_JSON jsonPost = new CC_Notificacion.CC_Notificacion_JSON();
        jsonPost.inputs = json_inputs;

        return JSON.serialize(jsonPost);
    }
    */
    public class AgrupadorMensajeInfo {      
        @InvocableVariable(required=true)
        public Id idAgrupador;
        
        @InvocableVariable(required=true)
        public String mensaje;
    }
}