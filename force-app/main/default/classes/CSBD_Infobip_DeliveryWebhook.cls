@RestResource(urlMapping='/infobipNotification/*')
global with sharing class CSBD_Infobip_DeliveryWebhook extends CBK_HttpServiceIntegration_Abstract{
    // This method will handle POST requests
    //URL DEVSERVICE: https://caixabankcc--devservice.sandbox.my.salesforce.com/services/apexrest/infobipNotification
    public static final String DELIVERY_NOTIFICATION = 'delivery';
    public static final String SEEN_NOTIFICATION = 'seen';
    public static final String RCS_CHANNEL = 'rcs';
    public static final String SMS_CHANNEL = 'sms';

    @HttpPost
    global static void handleDeliveryNotification() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Datetime dtStart = Datetime.now();
        
        //Quitarlo dpues de pruebas
        CSBD_Infobip_DeliveryWebhook.logInfobipTraza('INICIO-WEBHOOK-DELIVERY', 'HEADER', '', JSON.serializePretty(req.headers),'');
        CSBD_Infobip_DeliveryWebhook.logInfobipTraza('INICIO-WEBHOOK-DELIVERY', 'QUERY PARAMETERS', '', JSON.serializePretty(req.params),'');
        //CSBD_InfobipController.logInfobipTraza('INICIO-WEBHOOK-DELIVERY', 'BODY STRING', '', req.requestBody.toString(),'');

        String channel = req.params.get('channel') != null ? req.params.get('channel') : '';
        String notifType = req.params.get('notification') != null ? req.params.get('notification') : '';

        //Chequear que se hayan recibido los dos parametros esperados
        if(String.isBlank(channel) || String.isBlank(notifType)){          
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('Query parameter missing (channel:SMS or RCS, notification:delivery or seen )');
        }
        else{
            try {
                // Get the JSON body of the request
                String jsonBody = req.requestBody.toString();
               
                String messageId;
                String status;
                if(notifType.toLowerCase() == DELIVERY_NOTIFICATION){
                    CSBD_Infobip_Delivered_DTO notification = (CSBD_Infobip_Delivered_DTO) JSON.deserialize(jsonBody, CSBD_Infobip_Delivered_DTO.class);
                    messageId = notification.results[0].messageId;
                    status = notification.results[0].status.groupName;

                    /*** LOG QUITAR ****/
                    CSBD_Infobip_DeliveryWebhook.logInfobipTraza(
                        'TRY-WEBHOOK-DELIVERY', 
                        'BODY WRAPPER', 
                        '', 
                        JSON.serializePretty(notification),
                        'MESSAGE ID => ' + notification.results[0].messageId);

                }else if(notifType.toLowerCase() == SEEN_NOTIFICATION){
                    CSBD_Infobip_Seen_DTO notification = (CSBD_Infobip_Seen_DTO) JSON.deserialize(jsonBody, CSBD_Infobip_Seen_DTO.class);
                    messageId = notification.results[0].messageId;

                    /*** LOG QUITAR ****/
                    CSBD_Infobip_DeliveryWebhook.logInfobipTraza(
                        'TRY-WEBHOOK-DELIVERY', 
                        'BODY WRAPPER', 
                        '', 
                        JSON.serializePretty(notification),
                        'MESSAGE ID => ' + notification.results[0].messageId);
                }      
            
                // Process the delivery notification here
                processDeliveryNotification(messageId, notifType.toLowerCase(), channel.toLowerCase(), status);
                
                // Return a success message
                res.statusCode = 200;
                res.responseBody = Blob.valueOf('Notification processed successfully.');

            } catch (Exception ex) {
                // Handle any errors during processing
                res.statusCode = 500;
                res.responseBody = Blob.valueOf('Error processing the delivery notification: ' + ex.getMessage());
            }
        }
       
        //Log
        Datetime dtStop = Datetime.now();
        register(req,res,dtStart,dtStop,'CSBD_Infobip_Traza','CSBD_Infobip_WebhookDelivery');
       
    }
    
    // This method will process the delivery notification (update task related)
    private static void processDeliveryNotification(String messageId, String notificationType, String channel, String status) {
           
        if(String.isNotEmpty(messageId)){ 
            try{
                Task taskToUpdate = new Task();
                taskToUpdate.AV_ExternalID__c = messageId;                
                String smsAlternativo = (channel == SMS_CHANNEL) ? ' (SMS Alternativo)' : '';

                if(notificationType == SEEN_NOTIFICATION){
                    taskToUpdate.CSBD_Evento_Estado__c = 'RCS Visto'; 
                    taskToUpdate.Subject  = 'Envío de mensaje RCS - Visto';                     
                }
                else if(notificationType == DELIVERY_NOTIFICATION){                  
                    if(CSBD_InfobipController.statusEntregadoList.contains(status)){
                        taskToUpdate.CSBD_Evento_Estado__c = 'RCS Entregado' + smsAlternativo;                       
                        taskToUpdate.Subject  = 'Envío de mensaje RCS - Entregado' + smsAlternativo;   
                    }else if(CSBD_InfobipController.statusFallidoList.contains(status)){
                        taskToUpdate.CSBD_Evento_Estado__c = 'RCS Envío Fallido';  
                        taskToUpdate.Subject = 'Envío de mensaje RCS - Intento Fallido';              
                    }
                }               

                upsert taskToUpdate AV_ExternalID__c;

            }catch(Exception ex){
                CSBD_Infobip_DeliveryWebhook.logInfobipTraza('WEBHOOK-TASK-ERROR', 'UPSERT TASK', ex.getMessage(), '', 'MESSAGE ID => ' + messageId );
            }           
        }
      
    } 
    
    /************************************** Traza *********************************************/
    public static void logInfobipTraza(String estado, String mensaje, String error, String request, String messageId ){
            
        CC_TrazaInt__c traza = new CC_TrazaInt__c();
        traza.Name = 'CSBD_Infobip_Traza';
        traza.CC_FechaInicio__c = System.now();
        traza.CC_FechaFin__c = System.now();
        traza.CC_Identificador__c = 'CSBD_Infobip_Traza';
        traza.CC_MensajeEntrada__c = mensaje?.left(131072);
        traza.CC_MensajeSalida__c = request?.left(131072);
        traza.CC_DetalleError__c = error?.left(32768);
        traza.CC_EstadoInt__c = estado;
        traza.CC_TipoError__c = messageId;
        traza.CC_FinOK__c = true;
    
        insert traza;  
    }
    
      
}