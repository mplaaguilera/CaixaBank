/**********************************************************************************************************************
Name:	  AV_KafkaEv_Integration
Copyright © 2023  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: Enviar conjuntos de eventos a Kafka, para usar en triggers de Event
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US-0006226       David Ramos  Dominguez         28-09-2023     Created
*****************************************************************/
public with sharing class AV_KafkaEv_Integration {
    /**
    * Identificador de un CBK_IntegrationSetting__c con los datos para conectarse a Kafka
    * wsc.NamedCredential__c = callout:API_GWT_MC_PRO/tech/kfkcrp/cbcrsf/topics/cai-cbcrsf-eventos
    * equivalente a 'https://api.tst.internal.cer.caixabank.com/tech/kfkcrp/cbcrsf/topics/cai-cbcrsf-eventos'
    * wsc.CBK_Method__c = 'POST'
    * wsc.CBK_ContentType__c = application/vnd.kafka.avro.v2+json
    */
    private static final String AV_KAFKA_EVENTS = 'AV_KafkaEvents';
    
    /**
    * AV_KafkaConfiguration__mdt contiene dos campos con datos para la comunicacion con Kafka:
    * ActivateKafka: si true se permite la comunicacion con kafka, si false no
    * OfficeNumbers: la lista de oficinas permitidas en kafka, con los numeros separados por comas
    * si esta vacio se permiten todas las oficinas
    */
    private static String METADATA = 'AV_KafkaEvent'; 

    private static AV_KafkaConfiguration__mdt kafkaMetaData;

    //valor de "value_scheme" equivalente a "value_schema_id":488 en pre
    //para que funcione en developer console hay que camiar todo \" por \\"
    private static String schemaContents = '{\"type\":\"record\",\"name\":\"EventosMisClientesValue\",\"namespace\":\"com.caixabank.cbcrsf.eventos.avro.domain\",'+
                                            '\"fields\":[{\"name\":\"ID\",\"type\":\"string\"},'+
                                            '{\"name\":\"ENDDATETIME\",\"type\":\"string\"},'+
                                            '{\"name\":\"OWNERID\",\"type\":\"string\"},'+
                                            '{\"name\":\"STARTDATETIME\",\"type\":\"string\"},'+
                                            '{\"name\":\"SUBJECT\",\"type\":\"string\"},'+
                                            '{\"name\":\"WHATID\",\"type\":\"string\"},'+
                                            '{\"name\":\"WHOID\",\"type\":\"string\"},'+
                                            '{\"name\":\"RECORDTYPEID\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_CODIGOGESTORASIGNADO__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_EXTERNALID__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_INOUTBOUND__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_TASK__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_TIPO__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_TODELETE__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"CSBD_EVENTO_ESTADO__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_ORIGENAPP__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_FECHAPREVISTACONTACTO__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_AINICIATIVADEL__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"ISALLDAYEVENT\",\"type\":\"string\"},'+
                                            '{\"name\":\"LOCATION\",\"type\":\"string\"},'+
                                            '{\"name\":\"ISPRIVATE\",\"type\":\"string\"},'+
                                            '{\"name\":\"ISRECURRENCE2\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_ASSOCIATEDOPPORTUNITYID__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"LASTMODIFIEDBYID\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_BRANCHPHYSICALMEET__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"AV_CENTER__C\",\"type\":\"string\"},'+
                                            '{\"name\":\"CREATEDDATE\",\"type\":\"string\"}]}';                             

    public class MessageContent{
        public String valueTempUnderscoreschema;
        public list<Record> records;
    }

    public class Record {
        public BodyFields value;
    }

    public class BodyFields{
        public String ID;
        public String ENDDATETIME;
        public String OWNERID;
        public String STARTDATETIME;
        public String SUBJECT;
        public String WHATID;
        public String WHOID;
        public String RECORDTYPEID;
        public String AVTempUnderscoreCODIGOGESTORASIGNADOTempXYZC;
        public String AVTempUnderscoreEXTERNALIDTempXYZC;
        public String AVTempUnderscoreINOUTBOUNDTempXYZC;
        public String AVTempUnderscoreTASKTempXYZC;
        public String AVTempUnderscoreTIPOTempXYZC;
        public String AVTempUnderscoreTODELETETempXYZC;
        public String CSBDTempUnderscoreEVENTOTempUnderscoreESTADOTempXYZC;
        public String AVTempUnderscoreORIGENAPPTempXYZC;
        public String AVTempUnderscoreFECHAPREVISTACONTACTOTempXYZC;
        public String AVTempUnderscoreAINICIATIVADELTempXYZC;
        public String ISALLDAYEVENT;
        public String LOCATION;
        public String ISPRIVATE;
        public String ISRECURRENCE2;
        public String AVTempUnderscoreASSOCIATEDOPPORTUNITYIDTempXYZC;
        public String LASTMODIFIEDBYID;
        public String AVTempUnderscoreBRANCHPHYSICALMEETTempXYZC;
        public String AVTempUnderscoreCENTERTempXYZC;
        public String CREATEDDATE;
    }

/****************************************************************
 * Proposito: obtener el nombre del metadato que va a usar, principalmente para testing
 * Return            -> nombre del metadato
---------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US-0006226       David Ramos Dominguez          16-10-2023     Created
*****************************************************************/
    public static String getMetadataName(){
        return METADATA;
    }
/****************************************************************
 * Proposito: cambiar el nombre del metadato que va a usar, principalmente para testing
 * Parameters: newName            -> nuevo nombre del metadato
---------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US-0006226       David Ramos Dominguez          16-10-2023     Created
*****************************************************************/
    public static void setMetadataName(String newName){
        METADATA = newName;
    }

/****************************************************************
 * Proposito: ejecutar todas las partes, primero el filtrado y despues la conexion a kafka
 * Parameters: eventsNew            -> Eventos recibidos del trigger 
---------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US-0006226       David Ramos Dominguez          09-10-2023     Created
*****************************************************************/
    public static void syncEventsKafka(List<Event> eventsNew){
        Integer intrandomNumber = Integer.valueof((Math.random() * 1000));
        String integrationId = String.valueOf(intrandomNumber);
        List<Event> listEventsKafka = AV_KafkaEv_Integration.filterEvents(eventsNew);
        // system.debug('se enviaran ' +listEventsKafka.size() +' eventos a Kafka');
        if(!listEventsKafka.isEmpty()){
            AV_KafkaEv_Integration.sendEvents(listEventsKafka, integrationId);
        }
    }


/****************************************************************
 * Proposito: Este método filtra los eventos segun su Oficina asignada
 * Parameters: listEvents         -> Eventos a comprobar
 * Returns:    List<Event>        -> los eventos que quedan despues del filtrado
---------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US-0006226       David Ramos Dominguez          05-10-2023     Created
*****************************************************************/
    public static List<Event> filterEvents(List<Event> listEvents){
        List<Event> eventsToUse = new List<Event>();

        boolean filterByOffices = true;

        //coger el metadata con todos los numeros de oficinas validos
        List<AV_KafkaConfiguration__mdt> listData = [SELECT 
            DeveloperName, AV_ActivateKafka__c,AV_OfficeNumbers__c 
            FROM AV_KafkaConfiguration__mdt 
            WHERE DeveloperName = :METADATA];
        
        if (listData!=null && !listData.isEmpty() && listData.size()==1) {
            kafkaMetaData = listData.get(0);
        }
        // system.debug(kafkaMetaData);

        String officesKafka = kafkaMetaData.AV_OfficeNumbers__c;
        //contiene una lista de numeros de Office permitidos separados por comas

        // List<String> listOfficeIds = new List<String>();

        if (String.isEmpty(officesKafka)){
            filterByOffices = false;
        }
        // else {
        //     listOfficeIds = officesKafka.split(',');
        // }

        //hacer el select con un map para estar fuera del bucle
        List<String> allWhatIds = new List<String>();
        for(Event e : listEvents){
            String whatIdEvent = e.whatId;
            //no deberia llegar vacío en casos reales pero lo compruebo para evitar excepciones
            if (whatIdEvent!=null && whatIdEvent!=''){
                allWhatIds.add(whatIdEvent);
            }
        }
        List<Account> oficinasEvents = new List<Account>();
        oficinasEvents = [SELECT Id, AV_OficinaPrincipal__c, AV_OficinaPrincipal__r.CC_Numero_Oficina__c FROM Account WHERE Id IN :allWhatIds AND AV_OficinaPrincipal__c!=null AND AV_OficinaPrincipal__r.CC_Numero_Oficina__c!=null];

        //map que empareja <Id de la oficina, Numero de la oficina>
        Map<String,String> idOficinas =  new Map<String, String>();
        for (Account a : oficinasEvents){
            idOficinas.put(a.Id,a.AV_OficinaPrincipal__r.CC_Numero_Oficina__c);
        }

        for(Event e : listEvents){
            if (filterByOffices && oficinasEvents.size()>0){
                //si se quiere filtrar por oficinas tiene que haber alguna oficina en el conjunto
                String whatIdEvent = e.whatId;
                // system.debug('el evento ' +e.id +' tiene id oficina asignada: '+ whatIdEvent);
                //no deberia llegar vacío en casos reales pero lo compruebo para evitar excepciones
                if (whatIdEvent!=null && whatIdEvent!=''){
                    String numOficinaEvent = idOficinas.get(whatIdEvent);
                    // system.debug('la oficina ' +whatIdEvent +' tiene numero oficina: '+ numOficinaEvent);
                    //si la oficina asignada no tiene numero se descarta
                    if (numOficinaEvent!=null && numOficinaEvent!=''){
                    //como los Id estan siempre separados por comas buscando un substring puedes encontrar si el que quieres esta en el conjunto
                        if (officesKafka.contains(numOficinaEvent)){
                            if ((!e.IsRecurrence && !e.IsRecurrence2) || e.AV_Tipo__c == AV_AppConstants.VIDEOLLAMADA_TIPO){
                                eventsToUse.add(e);
                                // system.debug('se acepta el evento ' +e.id +' con numero oficina asignada: '+ numOficinaEvent);
                            }
                        }
                    }
                }
            }
            else if ((!e.IsRecurrence && !e.IsRecurrence2) || e.AV_Tipo__c == AV_AppConstants.VIDEOLLAMADA_TIPO){
                eventsToUse.add(e);
                // system.debug('se acepta el evento ' +e.id +' porque no es recurrente o es VLD');
            }
        }
        return eventsToUse;
    }


/****************************************************************
 * Proposito: Este método genera un objeto con todos los fields del contenido de un mensaje para Kafka
 *            El schema para kafka esta contenido en schemaContents  
 * Parameters: events                  -> elementos a enviar   
 * Returns: MessageContent             -> MessageContent con todo lo necesario para el body a enviar a Kafka
---------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US-0006226       David Ramos Dominguez          28-09-2023     Created
*****************************************************************/
    public static MessageContent generateMessageContent(List<Event> events){
        MessageContent result = new MessageContent();
        result.valueTempUnderscoreschema = schemaContents;


        list<Record> messageRecords = new list<Record>();
        BodyFields recordEvents = new BodyFields();

        for (Event e : events){
            BodyFields event = new BodyFields();
            //event.WHOID = e.WhoId != null ? e.WhoId : ' ';

            // //es required
            event.ID = e.Id;
            if (e.EndDateTime==null){
                event.ENDDATETIME = '';
            }
            else{
                event.ENDDATETIME = String.valueOf(e.EndDateTime);
            }
            // // owner cannot be blank
            event.OWNERID = e.OwnerId;
            if (e.StartDateTime==null){
                event.STARTDATETIME = '';
            }
            else{
                event.STARTDATETIME = String.valueOf(e.StartDateTime);
            }
            if (e.Subject==null){
                event.SUBJECT = '';
            }
            else{
                event.SUBJECT = e.Subject;
            }
            if (e.WhatId==null){
                event.WHATID = '';
            }
            else{
                event.WHATID = e.WhatId;
            }
            if (e.WhoId==null){
                event.WHOID = '';
            }
            else{
                event.WHOID = e.WhoId;
            }
            if (e.RecordTypeId==null){
                event.RECORDTYPEID = '';
            }
            else{
                event.RECORDTYPEID = e.RecordTypeId;
            }
            if (e.AV_CodigoGestorAsignado__c==null){
                event.AVTempUnderscoreCODIGOGESTORASIGNADOTempXYZC = '';
            }
            else{
                event.AVTempUnderscoreCODIGOGESTORASIGNADOTempXYZC = e.AV_CodigoGestorAsignado__c;
            }
            if (e.AV_ExternalID__c==null){
                event.AVTempUnderscoreEXTERNALIDTempXYZC = '';
            }
            else{
                event.AVTempUnderscoreEXTERNALIDTempXYZC = e.AV_ExternalID__c;
            }
            if (e.AV_InOutbound__c==null){
                event.AVTempUnderscoreINOUTBOUNDTempXYZC = '';
            }
            else{
                event.AVTempUnderscoreINOUTBOUNDTempXYZC = e.AV_InOutbound__c;
            }
            if (e.AV_Task__c==null){
                event.AVTempUnderscoreTASKTempXYZC = '';
            }
            else{
                event.AVTempUnderscoreTASKTempXYZC = e.AV_Task__c;
            }
            if (e.AV_Tipo__c==null){
                event.AVTempUnderscoreTIPOTempXYZC = '';
            }
            else{
                event.AVTempUnderscoreTIPOTempXYZC = e.AV_Tipo__c;
            }

            // //es required
            event.AVTempUnderscoreTODELETETempXYZC = String.valueOf(e.AV_ToDelete__c);
            if (e.CSBD_Evento_Estado__c==null){
                event.CSBDTempUnderscoreEVENTOTempUnderscoreESTADOTempXYZC = '';
            }
            else{
                event.CSBDTempUnderscoreEVENTOTempUnderscoreESTADOTempXYZC = e.CSBD_Evento_Estado__c;
            }
            if (e.AV_OrigenApp__c==null){
                event.AVTempUnderscoreORIGENAPPTempXYZC = '';
            }
            else{
                event.AVTempUnderscoreORIGENAPPTempXYZC = e.AV_OrigenApp__c;
            }
            //no existe en Event
            event.AVTempUnderscoreFECHAPREVISTACONTACTOTempXYZC = '';  //e.AV_FECHAPREVISTACONTACTO__C;
            //no existe en Event
            event.AVTempUnderscoreAINICIATIVADELTempXYZC = '';   //e.AV_AINICIATIVADEL__C;

            // //es required
            event.ISALLDAYEVENT = String.valueOf(e.IsAllDayEvent);
            if (e.Location==null){
                event.LOCATION = '';
            }
            else{
                event.LOCATION = e.Location;
            }

            // //es required 
            event.ISPRIVATE = String.valueOf(e.IsPrivate);

            // //es required
            event.ISRECURRENCE2 = String.valueOf(e.IsRecurrence2);
            if (e.AV_AssociatedOpportunityId__c==null){
                event.AVTempUnderscoreASSOCIATEDOPPORTUNITYIDTempXYZC = '';
            }
            else{
                event.AVTempUnderscoreASSOCIATEDOPPORTUNITYIDTempXYZC = e.AV_AssociatedOpportunityId__c;
            }
            //no puede ser null
            event.LASTMODIFIEDBYID = e.LastModifiedById;
            if (e.AV_BranchPhysicalMeet__c==null){
                event.AVTempUnderscoreBRANCHPHYSICALMEETTempXYZC = '';
            }
            else{
                event.AVTempUnderscoreBRANCHPHYSICALMEETTempXYZC = e.AV_BranchPhysicalMeet__c;
            }
            if (e.AV_Center__c==null){
                event.AVTempUnderscoreCENTERTempXYZC = '';
            }
            else{
                event.AVTempUnderscoreCENTERTempXYZC = e.AV_Center__c;
            }

            // //es required
            event.CREATEDDATE = String.valueOf(e.CreatedDate);

            Record r = new Record();
            r.value = event;
            messageRecords.add(r);
        }

        result.records = messageRecords;

        return result;
    }

    
/****************************************************************
 * Proposito: Este método envía eventos filtrados anteriormente
 * Parameters: eventsNew            -> Eventos a enviar
 *             integrationId        -> Información para trazas de integraciones   
---------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US-0006226       David Ramos Dominguez          28-09-2023     Created
*****************************************************************/

    public static void sendEvents(List<Event> eventsToSend, String integrationId){
        //comprobar que kafka esta activado
        if (kafkaMetaData.AV_ActivateKafka__c){
            MessageContent messageBody = new MessageContent();
            
            messageBody = generateMessageContent(eventsToSend);
            String jSONBody = JSON.serialize(messageBody);
            //qualityCloud no permite variables con underscore
            jSONBody = jSONBody.replaceAll('TempUnderscore', '_');
            //__C es invalido para nombres de wrappers, asi que lo cambio cuando ya es un String
            jSONBody = jSONBody.replaceAll('TempXYZC', '__C');
                    
            kafkaMetaData.AV_ActivateKafka__c=True;
            //hacer que no se ejecute si isQueueable() or isFuture() or isBatch()
            Boolean hasBulkApi = FeatureManagement.checkPermission('AV_AvoidBulkApi');
            if(!hasBulkApi && !System.isFuture() && !System.isBatch() && !System.isQueueable()){
                sendMessage(jSONBody, integrationId);
            }
        }
    }

/****************************************************************
 * Proposito: Este método envia el mensaje a Kafka
 * Parameters: jsonBody             -> Contenido del mensaje
 *             integrationId        -> Información para trazas de integraciones   
---------------------
Historial
---------------------    
    VERSION        USER_STORY       AUTHOR                         DATE           Description   
    1.0            US-0006226       David Ramos Dominguez          10-10-2023     Created
*****************************************************************/
    @future (callout=true)
    public static void sendMessage(String jSONBody, String integrationId){
        try{
            //valor de prueba
            //String JSONBody = '{"value_schema":"{\\"type\\":\\"record\\",\\"name\\":\\"EventosMisClientesValue\\",\\"namespace\\":\\"com.caixabank.cbcrsf.eventos.avro.domain\\",\\"fields\\":[{\\"name\\":\\"ID\\",\\"type\\":\\"string\\"},{\\"name\\":\\"ENDDATETIME\\",\\"type\\":\\"string\\"},{\\"name\\":\\"OWNERID\\",\\"type\\":\\"string\\"},{\\"name\\":\\"STARTDATETIME\\",\\"type\\":\\"string\\"},{\\"name\\":\\"SUBJECT\\",\\"type\\":\\"string\\"},{\\"name\\":\\"WHATID\\",\\"type\\":\\"string\\"},{\\"name\\":\\"WHOID\\",\\"type\\":\\"string\\"},{\\"name\\":\\"RECORDTYPEID\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_CODIGOGESTORASIGNADO__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_EXTERNALID__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_INOUTBOUND__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_TASK__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_TIPO__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_TODELETE__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"CSBD_EVENTO_ESTADO__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_ORIGENAPP__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_FECHAPREVISTACONTACTO__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_AINICIATIVADEL__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"ISALLDAYEVENT\\",\\"type\\":\\"string\\"},{\\"name\\":\\"LOCATION\\",\\"type\\":\\"string\\"},{\\"name\\":\\"ISPRIVATE\\",\\"type\\":\\"string\\"},{\\"name\\":\\"ISRECURRENCE2\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_ASSOCIATEDOPPORTUNITYID__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"LASTMODIFIEDBYID\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_BRANCHPHYSICALMEET__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"AV_CENTER__C\\",\\"type\\":\\"string\\"},{\\"name\\":\\"CREATEDDATE\\",\\"type\\":\\"string\\"}]}","records":[{"value":{"ID":"00U1X000004UsnJUAS","ENDDATETIME":"2023-04-18","OWNERID":"0051X00000D9EoGQAV","STARTDATETIME":"2023-04-18T15:30:00.000+0000","SUBJECT":"Videollamada 6","WHATID":"0016M00002TC6TgQAL","WHOID":" ","RECORDTYPEID":"0123Y000000XOJdQAO","AV_CODIGOGESTORASIGNADO__C":"U0146790","AV_EXTERNALID__C":"Evt-#1681825935674","AV_INOUTBOUND__C":"002","AV_TASK__C":"a3D1X000000U61fUAC","AV_TIPO__C":"VLD","AV_TODELETE__C":"false","CSBD_EVENTO_ESTADO__C":"Pendiente","AV_ORIGENAPP__C":"AV_Salesforce","AV_FECHAPREVISTACONTACTO__C":" ","AV_AINICIATIVADEL__C":" ","ISALLDAYEVENT":"false","LOCATION":" ","ISPRIVATE":"false","ISRECURRENCE2":"false","AV_ASSOCIATEDOPPORTUNITYID__C":" ","LASTMODIFIEDBYID":"0051X00000D9oGQAV","AV_BRANCHPHYSICALMEET__C":" ","AV_CENTER__C":"04135","CREATEDDATE":"2023-04-18T13:36:22.000+0000"}}]}';

            // system.debug('creating HttpRequest');
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(jSONBody, AV_KAFKA_EVENTS, '', new  Map<String, string>());
            // system.debug(request);
            // system.debug('sending HttpRequest');
            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, integrationId, AV_KAFKA_EVENTS);
            // system.debug('reading HttpResponse');
            // system.debug(response);
            // system.debug(response.getBody());
        }
        catch(Exception ex){
            CBK_Log.error('The following exception has occurred: ' + ex.getMessage());
            system.debug(ex.getMessage() + ' ' + ex.getLineNumber());
        }
    }

}