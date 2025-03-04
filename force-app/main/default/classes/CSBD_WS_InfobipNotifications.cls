@RestResource(urlMapping='/infobipNotification/*')
global with sharing class CSBD_WS_InfobipNotifications extends CBK_HttpServiceIntegration_Abstract{
    // This method will handle POST requests
    //URL DEVSERVICE: https://caixabankcc--devservice.sandbox.my.salesforce.com/services/apexrest/infobipNotification

    @HttpPost
    global static void handleDeliveryNotification() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        Datetime dtStart = Datetime.now();
        
        /*** LOG FOR TESTING ****/
        //CSBD_InfobipController.logInfobipTraza('WEBHOOK-DELIVERY-HEADER', JSON.serializePretty(req.headers), '');
        //CSBD_InfobipController.logInfobipTraza('WEBHOOK-DELIVERY-QUERY_PARAMS', JSON.serializePretty(req.params),'');
        //CSBD_InfobipController.logInfobipTraza('WEBHOOK-DELIVERY-BODY', req.requestBody.toString(),'');

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

                //for logging
                List<String> messagesIds = new List<String>();
                List<CSBD_InfobipController.InfobipDataWrapper> infoList = new List<CSBD_InfobipController.InfobipDataWrapper>();
                if(notifType.toLowerCase() == CSBD_InfobipController.DELIVERY_NOTIFICATION){
                    CSBD_Infobip_Delivered_DTO notification = (CSBD_Infobip_Delivered_DTO) JSON.deserialize(jsonBody, CSBD_Infobip_Delivered_DTO.class);
                    for(CSBD_Infobip_Delivered_DTO.DeliveryResult result: notification.results){                      
                        if(result.messageId != null && !String.isEmpty(result.messageId)){
                            CSBD_InfobipController.InfobipDataWrapper info = new CSBD_InfobipController.InfobipDataWrapper();
                            info.origin = CSBD_InfobipController.ORIGIN_NOTIFICATION;
                            info.messageId = result.messageId;
                            info.notificationType = notifType.toLowerCase();
                            info.channel = channel.toLowerCase();
                            info.status = result.status.groupName;
                            info.opportunityId = result.callbackData;
                            infoList.add(info);
                            //for logging
                            messagesIds.add(result.messageId);
                        }                     
                    }
                  
                    /*** LOG FOR MONITORING ****/
                    CSBD_InfobipController.logInfobipTraza(
                        'DELIVERY_WEBHOOK',                         
                        JSON.serializePretty(notification),
                        'MESSAGE ID => ' + messagesIds);

                }else if(notifType.toLowerCase() == CSBD_InfobipController.SEEN_NOTIFICATION){
                    CSBD_Infobip_Seen_DTO notification = (CSBD_Infobip_Seen_DTO) JSON.deserialize(jsonBody, CSBD_Infobip_Seen_DTO.class);                
                    for(CSBD_Infobip_Seen_DTO.SeenResult result: notification.results){                      
                        if(result.messageId != null && !String.isEmpty(result.messageId)){
                            CSBD_InfobipController.InfobipDataWrapper info = new CSBD_InfobipController.InfobipDataWrapper();
                            info.origin = CSBD_InfobipController.ORIGIN_NOTIFICATION;
                            info.messageId = result.messageId;
                            info.notificationType = notifType.toLowerCase();
                            info.channel = channel.toLowerCase();
                            infoList.add(info);
                            //for logging
                            messagesIds.add(result.messageId);
                        }                     
                    }

                    /*** LOG FOR MONITORING ****/
                    CSBD_InfobipController.logInfobipTraza(
                        'SEEN_WEBHOOK', 
                        JSON.serializePretty(notification),
                        'MESSAGE ID => ' + String.join(messagesIds, '-'));
                }      
            
                // Process the delivery notification             
                processDeliveryNotification(infoList);
                
                // Return a success message
                res.statusCode = 200;
                res.responseBody = Blob.valueOf('Notification processed successfully for Message Id = ' + messagesIds);

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
    public static void processDeliveryNotification(List<CSBD_InfobipController.InfobipDataWrapper> infoList) {
           
        if(!infoList.isEmpty()){  
            CSBD_InfobipController.upsertTask(infoList, CSBD_InfobipController.ORIGIN_NOTIFICATION);             
        }
      
    }  
}