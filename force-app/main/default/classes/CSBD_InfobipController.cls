public with sharing class CSBD_InfobipController {
    //Status enviados por Infobip
    public final static String STATUS_PENDING = 'PENDING';
    public final static String STATUS_UNDELIVERABLE = 'UNDELIVERABLE';
    public final static String STATUS_DELIVERED = 'DELIVERED';
    public final static String STATUS_EXPIRED = 'EXPIRED';
    public final static String STATUS_REJECTED = 'REJECTED';

    //status manejados en Salesforce
    public final static String STATUS_ENVIADO = 'RCS Enviado';
    public final static String STATUS_ENVIOFALLIDO = 'RCS Envío Fallido';
    public final static String STATUS_VISTO = 'RCS Visto';
    public final static String STATUS_ENTREGADO = 'RCS Entregado';

    //Notificaciones recibidas por Infobip
    public final static String DELIVERY_NOTIFICATION = 'delivery';
    public final static String SEEN_NOTIFICATION = 'seen';
    public final static String RCS_CHANNEL = 'rcs';
    public final static String SMS_CHANNEL = 'sms';

    //Status agrupados por los que vamos a mapear en SF
    public static List<String> statusPendienteList = new List<String> {STATUS_PENDING};
    public static List<String> statusEntregadoList = new List<String> {STATUS_DELIVERED};
    public static List<String> statusFallidoList = new List<String> {STATUS_EXPIRED,STATUS_UNDELIVERABLE,STATUS_REJECTED};

    //Origin para el upsert del Task
    public final static String ORIGIN_SENDER = 'Sender';
    public final static String ORIGIN_NOTIFICATION = 'Notification';

    public List<Opportunity> oppsToHandle {private set;get;}


    public static void sendInfobipMessage(String inputJson){

        CSBD_WS_AltaOportunidad_NowInSales.InputLogicaAsincrona oppsInput =  (
            (CSBD_WS_AltaOportunidad_NowInSales.InputLogicaAsincrona)JSON.deserializeStrict(
                inputJson, 
                CSBD_WS_AltaOportunidad_NowInSales.InputLogicaAsincrona.class
            )
        );

        CSBD_InfobipController infoCtrl =  new CSBD_InfobipController();
        if(infoCtrl.checkConditionsBeforeSend()){
            infoCtrl.setOpps(oppsInput.idOportunidades);
            infoCtrl.sendRCSMessage();
        }
      
    }
  
    //update task
    public static void updateTask(List<InfobipDataWrapper> infoList){

        Map<String, Task> messageTaskMap = new Map<String, Task>();
        Map<String, InfobipDataWrapper> messageInfoMap = new Map<String, InfobipDataWrapper>();
        List<Task> taskToUpdate = new List<Task>();

        for(InfobipDataWrapper info: infoList){
            messageTaskMap.put(info.messageId, new Task());
            messageInfoMap.put(info.messageId, info);
        }
      
        List<Task> tList = [
            SELECT Id, AV_ExternalID__c, CSBD_Evento_Estado__c, Subject
            FROM Task
            WHERE AV_ExternalID__c =: messageTaskMap.keySet()
        ];

        if(!tList.isEmpty()){
            for(Task t: tList){
                messageTaskMap.put(t.AV_ExternalID__c, t);
            }          
        }
        else{
            logInfobipTraza('CSBD_InfobipController',  'No se encuentra Task con external Id : ' + String.join(messageTaskMap.keySet(), '-'), ''); 
            CSBD_Infobip_Setting__c sett = CSBD_Infobip_Setting__c.getOrgDefaults(); 
            for(String messageId : messageInfoMap.keySet()){
                InfobipDataWrapper info = messageInfoMap.get(messageId);
                Task t = CSBD_Activity.crearActividadReturn(
                    new Task(), 
                    info.opportunityId, 
                    sett.CSBD_Tipo_Tarea__c != null ? sett.CSBD_Tipo_Tarea__c: 'Envio Mensaje RCS', //La definida en el setting,
                    'Completed', 
                    '', 
                    '', 
                    new Map<String , String> {                       
                        'AV_ExternalID__c' => messageId
                    });              
                messageTaskMap.put(messageId, t);
            }     
        }

        for(String key: messageTaskMap.keySet()){
            Task t = messageTaskMap.get(key);
            InfobipDataWrapper info = messageInfoMap.get(key);
            t = setNotificationData(info, t);
            taskToUpdate.add(t);
        }   

        upsert taskToUpdate AV_ExternalID__c;          
    }

    public static Task setNotificationData(InfobipDataWrapper info, Task taskToUpdate){
        String channel = info.channel;
        String notificationType = info.notificationType;
        String status = info.status;

        String smsAlternativo = (channel == SMS_CHANNEL) ? ' (SMS Alternativo)' : '';

        if(notificationType == SEEN_NOTIFICATION){
            taskToUpdate.CSBD_Evento_Estado__c = STATUS_VISTO; 
            taskToUpdate.Subject  = 'Envío de mensaje RCS - Visto';                     
        }
        else if(notificationType == DELIVERY_NOTIFICATION){                  
            if(CSBD_InfobipController.statusEntregadoList.contains(status) && taskToUpdate.CSBD_Evento_Estado__c != STATUS_VISTO){
                taskToUpdate.CSBD_Evento_Estado__c = STATUS_ENTREGADO + smsAlternativo;                       
                taskToUpdate.Subject  = 'Envío de mensaje RCS - Entregado' + smsAlternativo;   
            }else if(CSBD_InfobipController.statusFallidoList.contains(status)){
                taskToUpdate.CSBD_Evento_Estado__c = STATUS_ENVIOFALLIDO;  
                taskToUpdate.Subject = 'Envío de mensaje RCS - Intento Fallido';              
            }
        }    
        
        return taskToUpdate;
    }

    //update task
    public static void upsertTask(InfobipDataWrapper info){
         upsertTask(new List<InfobipDataWrapper> {info}, ORIGIN_SENDER);         
    }

    //update task
    public static void upsertTask(List<InfobipDataWrapper> infoList, String origin){
        try{
            if(origin == ORIGIN_SENDER){
                //desde el envío siempre se procesa un mensaje a la vez
                InfobipDataWrapper info = infoList[0];
                if(info.taskToInsert != null && !info.taskToInsert.isEmpty()){ 
                    insert info.taskToInsert; //son tareas con estados fallidos por validaciones de negocio
                }
                if(info.taskToUpsert != null && !info.taskToUpsert.isEmpty()){ //son tareas que representan mensajes enviados por Infobip    
                    List<Task> tasksAfter = checkTaskBeforeUpdate(info.taskToUpsert);
                    upsert tasksAfter AV_ExternalID__c;
                }
            }
            if(origin == ORIGIN_NOTIFICATION){
                updateTask(infoList);
            }
            //throw new CSBD_InfobipSender.InfobipSenderException('Enforce UNABLE_TO_LOCK_ROW');
        }catch(Exception ex){
            logInfobipTraza(
                'CSBD_InfobipController', 
                'InfobipDataWrapper => ' + JSON.serializePretty(infoList), 
                'Exception =>' + ex.getMessage()
            ); 
            //Si la exception es por lock entonces, hacer el intento como queueable.     
            if(ex.getMessage().contains('UNABLE_TO_LOCK_ROW')){
                enqueueUpdater(infoList, origin);
            }                          
        }   
      
    }

    public static List<Task> checkTaskBeforeUpdate(List<Task> taskToUpsert){
        Map<String, Task> messagesIdTask = new Map<String, Task>();
        for(Task t: taskToUpsert){
            messagesIdTask.put(t.AV_ExternalID__c, t);
        }
        List<Task> tListExist = [
            SELECT Id, AV_ExternalID__c, CSBD_Evento_Estado__c, Subject, Description
            FROM Task
            WHERE AV_ExternalID__c IN: messagesIdTask.keySet()
            ORDER BY CreatedDate DESC
        ];

        if(!tListExist.isEmpty()){
            for(Task tExist: tListExist){
                Task tNew = messagesIdTask.get(tExist.AV_ExternalID__c);
                if(tExist.CSBD_Evento_Estado__c != tNew.CSBD_Evento_Estado__c){
                    //respetar el estado de la tarea existente
                    tNew.CSBD_Evento_Estado__c = tExist.CSBD_Evento_Estado__c; 
                }
                if(tExist.Subject != tNew.Subject){
                    //respetar el subject de la tarea existente
                    tNew.Subject = tExist.Subject; 
                }
            }
        }

        return messagesIdTask.values();
    }

    public static void enqueueUpdater(List<InfobipDataWrapper> infoList, String origin){
        CSBD_Infobip_Setting__c sett = CSBD_Infobip_Setting__c.getOrgDefaults();       
        //para evitar duplicados en el queueable          
        Integer randomNumber = Integer.valueOf(Math.floor(Math.random() * (99999 - 10000 + 1)) + 10000);   

        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                            .addId(UserInfo.getUserId())
                            .addString('IBU_' + randomNumber) 
                            .build();
        
        if(sett.CSBD_Delay_Update__c != null){
            options.MinimumQueueableDelayInMinutes = Integer.valueOf(sett.CSBD_Delay_Update__c);
        }                   

        CSBD_InfobipUpdaterQueueable infoUpdateQueue = new CSBD_InfobipUpdaterQueueable(
            infoList,
            origin
        );     
        System.enqueueJob(infoUpdateQueue, options);
    }

    public void sendRCSMessage(){
        //Llamar al InfobipSender Queueable pasandole el wrapper
        if(this.oppsToHandle.size() > 0){   
            //Signature to avoid duplicate queauable in same transaction. QC required. 
            Integer randomNumber = Integer.valueOf(Math.floor(Math.random() * (99999 - 10000 + 1)) + 10000);   

            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                .addId(UserInfo.getUserId())
                                .addString('IBS_' + randomNumber)
                                .build();
            System.enqueueJob(
                new CSBD_InfobipSender(this.oppsToHandle), 
                options
            );
        }
    }

    public void setOpps(List<Id> oppsToCheckIds){
        //recuperar los campos que me sirvan para identificar las Opps que deben ser enviadas
        Id prestamoRT = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Opportunity', 'CSBD_Prestamo');
        List<Opportunity> oppList = [
            SELECT Id, 
                CSBD_Idioma_Solicitud__c,
                CSBD_Contact__c,
                CSBD_Now_Codigo_Producto_Formato__c, 
                CSBD_Now_Codigo_Producto__c, 
                CSBD_Telefono_Solicitud__c
            FROM Opportunity
            WHERE Id IN: oppsToCheckIds
            AND RecordTypeId =: prestamoRT
            AND CSBD_Contact__c != null
            AND CSBD_Telefono_Solicitud__c != null
            AND IsClosed = false 
        ];   

        this.oppsToHandle = oppList;
    }

    public Boolean checkConditionsBeforeSend(){
        CSBD_Infobip_Setting__c sett = CSBD_Infobip_Setting__c.getOrgDefaults();
        return sett.CSBD_Envio_Automatico_Activo__c;        
    }  

    /************************************** Traza *********************************************/
    public static void logInfobipTraza(String estado, String mensaje, String error ){
            
        CC_TrazaInt__c traza = new CC_TrazaInt__c();
        traza.Name = 'CSBD_Infobip_Traza';
        traza.CC_FechaInicio__c = System.now();
        traza.CC_FechaFin__c = System.now();
        traza.CC_Identificador__c = 'CSBD_Infobip_Traza';
        traza.CC_MensajeEntrada__c = mensaje?.left(131072);
        traza.CC_DetalleError__c = error?.left(32768);
        traza.CC_EstadoInt__c = estado;
        traza.CC_FinOK__c = true;
    
        insert traza;  
    }

    public class InfobipDataWrapper {
        public String messageId {set;get;}
        public String notificationType {set;get;}
        public String channel {set;get;}
        public String status {set;get;}    
        public String origin {set;get;}  
        public List<Task> taskToInsert {set;get;}     
        public List<Task> taskToUpsert {set;get;}          
       //  public Boolean handleQueueable = false; 
       // public Integer minutesDelayed {set;get;}  
        public String opportunityId {set;get;}  
    }

}