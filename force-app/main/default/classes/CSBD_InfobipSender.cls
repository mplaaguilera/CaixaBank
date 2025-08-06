public with sharing class CSBD_InfobipSender implements Queueable, Database.AllowsCallouts { 
    //Variables statics 
    final static Integer CALLOUT_LIMIT = 100;
    final static Integer TIEMPO_MAX = 2880;//48h en MINUTOS
    final static String  PLANTILLA_RCS_AUTOMATICO = 'Plantilla RCS Automatico';
 

    public List<Opportunity> oppsToHandle {private set;get;}
    public String sender {private set;get;}
    public String imageUrl {private set;get;}
    public Integer timeWait {private set;get;}
    public String taskType {private set;get;}
    public String cardSize {private set;get;}
    public Map<String, Id> plantillaPorIdioma {private set;get;}

    public CSBD_InfobipSender(List<Opportunity> opps) {
        this.oppsToHandle = opps;
        setInfobipData();       
    }

    public void execute(QueueableContext context) {
    
        Integer i = 0;
        List<Task> taskToInsert = new List<Task>();
        List<Task> taskToUpsert = new List<Task>();

        //Controlar el limite de callout por transaccion
        while(i < CALLOUT_LIMIT && i< this.oppsToHandle.size()){
        
            Opportunity opp = this.oppsToHandle.get(i);
            Map<String, Object> result = sendRCS(opp);  

            if((Boolean)result.get('isSuccess')){
                //Si fue success, crear la tarea con el message Id que es el external Id
                String messageId = (String)result.get('messageId');
                String bodyResponse = (String)result.get('bodyMessage');
                taskToUpsert.add(CSBD_Activity.crearActividadReturn(
                    new Task(), 
                    opp.Id, 
                    this.taskType, //La definida en el setting,
                    'Completed', 
                    'Envio de mensaje RCS - Enviado (Pendiente Entregar)', 
                    bodyResponse, 
                    new Map<String , String> {
                        'CSBD_Evento_Estado__c' => CSBD_InfobipController.STATUS_ENVIADO,
                        'AV_ExternalID__c' => messageId
                    }));
            }else{
                //Crear otra tarea indicando que hubo fallo y cual fue el fallo
                String errorMessage = (String)result.get('errorMessage');
                taskToInsert.add(CSBD_Activity.crearActividadReturn(
                    new Task(), 
                    opp.Id, 
                    this.taskType, //La definida en el setting,p
                    'Completed', 
                    'Envío de mensaje RCS - Intento Fallido', 
                    errorMessage,  
                    new Map<String , String> {
                        'CSBD_Evento_Estado__c' => CSBD_InfobipController.STATUS_ENVIOFALLIDO                        
                    }));
            }
            i ++;
        }

        //esto significa que hay mas opps que el limite que permitimos
        if(i < this.oppsToHandle.size()){
                
            //quitar las opps ya procesadas fuera del ciclo de procesamiento
            for(Integer j = 0; j < i; j++){
                this.oppsToHandle.remove(j);
            }
            //poner en cola el proceso nuevamente para procesar las opps que quedaron. 
            AsyncOptions options = new AsyncOptions();
            options.DuplicateSignature = QueueableDuplicateSignature.Builder()
                                .addId(UserInfo.getUserId())
                                .addString('InfobipSender')
                                .build();
            System.enqueueJob(
                new CSBD_InfobipSender(this.oppsToHandle),
                options
            );          
        }

        //Insertar las tareas al final del todo para evitar uncommited pending dml/callout exception
        CSBD_InfobipController.InfobipDataWrapper info = new CSBD_InfobipController.InfobipDataWrapper();
        info.origin = CSBD_InfobipController.ORIGIN_SENDER;
        info.taskToInsert = taskToInsert;
        info.taskToUpsert = taskToUpsert;
        CSBD_InfobipController.upsertTask(info);
      
    }

    public Map<String, Object> sendRCS(Opportunity opp){
        Boolean isSuccess = false;
        String messageId = '';            
        String errorMessage = '';            
        String bodyMessage = '';            
          
        try{
            CSBD_Infobip_Message_DTO newMessage = createMessageDTO(opp);
         
            //CBK FWK
            CBK_HttpServiceIntegration.RequestWapper httpRequestWrapper = new CBK_HttpServiceIntegration.RequestWapper();
            httpRequestWrapper.intSetting = 'CSBD_Infobip_SendMessage';
            httpRequestWrapper.body = JSON.serialize(newMessage);
            httpRequestWrapper.mHeaders = new Map<String,String>();//Para que no falle el CBK FWK
            
            HttpRequest httpRequest = CBK_HttpServiceIntegration.getRequest(httpRequestWrapper);//Se construye el request
            HttpResponse httpResponse = CBK_HttpServiceIntegration.callHttpService(httpRequest, 'CSBD_Infobip_Request-Message', httpRequestWrapper.intSetting);
       
            if (httpResponse.getStatusCode() == 200) {                
                CSBD_Infobip_MessageResponse_DTO infobipResponse = CSBD_Infobip_MessageResponse_DTO.parse(httpResponse.getBody());
                messageId = infobipResponse.messages[0].messageId;
                bodyMessage = 'Título enviado : ' + newMessage.messages[0].content.content.title + '\n' +
                'Mensaje enviado : ' + newMessage.messages[0].content.content.description.unescapeHtml4();//JSON.serializePretty(infobipResponse);
                isSuccess = true;
            } else {
                errorMessage = 'HTTP ERROR -' + httpResponse.getStatusCode() + ' Body - ' + JSON.serializePretty(httpResponse.getBody());             
            }
        }catch(Exception ex){
            errorMessage = ex.getMessage();          
        }

       return new Map<String, Object> {
         'isSuccess' => isSuccess, 
         'messageId' => messageId,
         'errorMessage' => errorMessage,
         'bodyMessage' => bodyMessage
       };
      
    }

    public CSBD_Infobip_Message_DTO createMessageDTO(Opportunity opp){

        //Obtener description y title
        Id templateId = this.plantillaPorIdioma.get(opp.CSBD_Idioma_Solicitud__c);
        if(templateId == null){
            throw new InfobipSenderException('No se encuentra plantilla para el idioma de la Oportunidad ' + opp.CSBD_Idioma_Solicitud__c); 
        }
        //else
        if(this.imageUrl == null){
            throw new InfobipSenderException('La URL de la imagen no está definida. Debe definirla en "CSBD Infobip Setting".'); 
        }
         //else
        if(this.sender == null){
            throw new InfobipSenderException('El Sender Id de Infobip no está definido. Debe definirlo en "CSBD Infobip Setting".'); 
        }

        Map<String,String> tempBodySubj = CSBD_EmailMessage.renderPlantillaSubjectTexto(
            new Map<String,Object> {
                'templateId' => templateId,
                'sObjectId' => opp.Id,
                'whoId' => opp.CSBD_Contact__c,
                'convertirATextoPlano' => true
            });

        CSBD_Infobip_Message_DTO newMessage = new CSBD_Infobip_Message_DTO();

        newMessage.messages[0].sender = this.sender;

        newMessage.messages[0].content.alignment = 'LEFT';
        newMessage.messages[0].content.orientation = 'VERTICAL';    
        newMessage.messages[0].content.type = 'CARD';
      
        newMessage.messages[0].content.content.title = tempBodySubj.get('subject');      
        newMessage.messages[0].content.content.description =  tempBodySubj.get('body');
        newMessage.messages[0].content.content.media.file.url = this.imageUrl;
        newMessage.messages[0].content.content.media.height = this.cardSize;
       
        CSBD_Infobip_Message_DTO.DestinationsDTO destination = new CSBD_Infobip_Message_DTO.DestinationsDTO();
        destination.to = verifyAndCorrectSpainNumber(opp.CSBD_Telefono_Solicitud__c);
        newMessage.messages[0].destinations.add(destination);
        newMessage.messages[0].options.smsFailover.sender = this.sender;
        newMessage.messages[0].options.smsFailover.text = tempBodySubj.get('body');

        if(this.timeWait != null && this.timeWait > 0 && this.timeWait <= TIEMPO_MAX){
            newMessage.messages[0].options.validityPeriod.amount = this.timeWait;
            newMessage.messages[0].options.validityPeriod.timeUnit = 'MINUTES';
        }

        newMessage.messages[0].webhooks.callbackData = opp.Id;
  

        return newMessage;
        
    }
    
    public void setInfobipData(){
        //Set Sender Id
        CSBD_Infobip_Setting__c sett = CSBD_Infobip_Setting__c.getOrgDefaults();        
        this.sender = sett.CSBD_Sender_Id__c;
        this.imageUrl = sett.CSBD_URL_Imagen__c;
        this.timeWait = Integer.valueOf(sett.CSBD_Tiempo_Espera__c);
        this.taskType = sett.CSBD_Tipo_Tarea__c != null ? sett.CSBD_Tipo_Tarea__c: 'Envio Mensaje RCS';
        this.cardSize = sett.CSBD_Card_Size__c != null ? sett.CSBD_Card_Size__c: 'MEDIUM';
        
        this.plantillaPorIdioma = new Map<String,String>();

        //Los idiomas y plantillas son un numero de combinaciones pequenna
        for(CSBD_Plantillas_Correo__mdt plantillasRCS : [
            SELECT Id, MasterLabel, DeveloperName, CSBD_Idioma__c, CSBD_Nombre_Plantilla__c 
            FROM CSBD_Plantillas_Correo__mdt 
            WHERE MasterLabel LIKE :PLANTILLA_RCS_AUTOMATICO
            AND CSBD_Idioma__c != NULL
            AND CSBD_Nombre_Plantilla__c != NULL
        ]){
            try{
                String idioma = plantillasRCS.CSBD_Idioma__c;
                if(!this.plantillaPorIdioma.containsKey(idioma)){
                    //Obtener el id del EmailTemplate
                    Id templateId = CSBD_EmailMessage.plantillaOperativaId(PLANTILLA_RCS_AUTOMATICO, idioma);
                    this.plantillaPorIdioma.put(idioma, templateId);
                 }    
            }catch(Exception ex){
                CBK_Log.debug('CSBD Infobip Sender - Plantillas por Idioma', ex.getMessage());
            }
        }       
    
    }

    // Method to validate the phone number
    public  String verifyAndCorrectSpainNumber(String phoneNumber) {
        // Define the pattern for Spanish mobile numbers
        String spanishPhoneStructure = '^(\\+34)?[6789]\\d{8}$';

        // Check if the phone number matches the pattern
        if (Pattern.matches(spanishPhoneStructure, phoneNumber)) {
            // If the phone number does not start with +34, add it
            if (!phoneNumber.startsWith('+34')) {
                phoneNumber = '+34' + phoneNumber;
            }           
        } 

        return phoneNumber;
    }

    public class InfobipSenderException extends Exception {}

}