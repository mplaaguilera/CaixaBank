/**********************************************************************************************************************
 Name:	  CBK_APIGraph_Reprocesado_Batch
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Propósito: Batch llamado de forma manual o con posibilidad a ser programado que revisa los registros actuales de CBK_Log
relacionados con APIGraph para su reenviado
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			USXXXXXX		    Jose Manuel   	    25/11/2024		    Init version
***********************************************************************************************************************/
global class CBK_APIGraph_Reprocesado_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    //Variables usadas para la llamada manual
    private final List<String> listaBuzones;
    private final Date fechaInicio;
    private final Date fechaFin;
    static final List<CBK_WS_APIGraph.ResponseWrapperDTO> respDTOAll = new List<CBK_WS_APIGraph.ResponseWrapperDTO>();
    static final List<CBK_Log__c> listCBKLogsReprocesado = new List<CBK_Log__c>();
    static final List<CC_TrazaInt__c> listTrazasInt = new List<CC_TrazaInt__c>();
    private final Datetime dtNow = System.now();
    private final Datetime dt20MinsAgo = dtNow.addMinutes(-20);

    
    //Clase utilizada para la llamada manual
    public CBK_APIGraph_Reprocesado_Batch(List<String> lListaBuzones, Date dFechaInicio, Date dFechaFin){
        listaBuzones = lListaBuzones;
        fechaInicio = dFechaInicio;
        fechaFin = dFechaFin;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        //Se recupera una List de Mailboxes que tienen el reenvío activo a partir de los que haya por procesar
        List<String> listaBuzonesReenvio = getMailboxesToForward();

        //Se genera una lista de tipos de log a buscar
        List<String> listTiposLog = new List<String>{'Monitorizado', 'Perdido', 'Reprocesado'};

        //Se monta la query de forma dinámica dependiendo de los parámetros informados
        Id sRecordTypeIdAutditEmail = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_AutditEmail').getRecordTypeId();
        String query = 'SELECT Id, CBK_sfdcType__c, CBK_BuzonCorreo__c, CBK_hdMessageID__c, Subject__c, CBK_sfdcFromAdress__c, CBK_sfdcToAddress__c, CBK_CCToAddress__c ' +
            'FROM CBK_Log__c ' +
            'WHERE CBK_sfdcType__c IN :listTiposLog ' +
            'AND RecordTypeId = :sRecordTypeIdAutditEmail ';

        if(listaBuzones != null && !listaBuzones.isEmpty()){
            query += ' AND CBK_BuzonCorreo__c IN :listaBuzones ';
        }else{
            query += ' AND CBK_BuzonCorreo__c IN :listaBuzonesReenvio ';
        }
        
        if(fechaInicio != null){
            query += ' AND CreatedDate >= :dFechaInicio ';
        }else{
            query += ' AND CreatedDate >= :dt20MinsAgo ';
        }
        
        if(fechaInicio != null){
            query += ' AND CreatedDate <= :dFechaFin ';
        }else{
            query += ' AND CreatedDate <= :dtNow ';
        }

        query += 'ORDER BY CreatedDate DESC ';
        
        //Se lanza la query
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CBK_Log__c> scope)
    {
        //Map en el que se almacenarán los correos con el MessageId como clave
        Map<String, List<CBK_Log__c>> mapCorreoLogs = new Map<String, List<CBK_Log__c>>();
        Set<String> setMailboxes = new Set<String>();

        //Se recorre el scope para llenar el Map con los logs ordenados por su fecha de creación y divididos por su MessageId
        for(CBK_Log__c logCorreo : scope){
            String sMessageId = logCorreo.CBK_hdMessageID__c;
            if(String.isNotBlank(sMessageId)){
                //Se inicializa la lista para ese MessageId si no existía ya
                if(!mapCorreoLogs.containsKey(sMessageId)){
                    mapCorreoLogs.put(sMessageId, new List<CBK_Log__c>());
                }
                mapCorreoLogs.get(sMessageId).add(logCorreo);
                
                //Se guarda el mailbox para saber si procesarlo o no con el reenvío después
                setMailboxes.add(logCorreo.CBK_BuzonCorreo__c);
            }
        }
        
        //Se recuperan los buzones de correo necesarios para el reprocesado
        Map<String, String> mapMailboxes = new Map<String, String>();
        for(CBK_APIGraph_Mailbox__c oMailbox : [SELECT Id, CBK_MailboxID__c
                                                FROM CBK_APIGraph_Mailbox__c
                                               	WHERE Id IN :setMailboxes])
        {
            mapMailboxes.put(oMailbox.Id, oMailbox.CBK_MailboxId__c);
        }

        //Se revisa cuáles de los MessageId recuperados no tienen una entrada de tipo "Monitorizado",
        //y si no lo tienen, se procede a llamar al servicio de /forward
        for(String sMessageId : mapCorreoLogs.keySet()){
            //Variable en la que almacenar el log de tipo 'Perdido'
            CBK_Log__c oLogPerdido;

            //Contador para indicar el nº de reprocesos para ese mensaje
            Integer iReprocesados = 0;

            //Check para comprobar si existe un log de tipo "Monitorizado"
            Boolean bMonitorizado = false;

            //Se recorre la lista de logs para ese mensaje
            for(CBK_Log__c oLog : mapCorreoLogs.get(sMessageId)){
                String sTipoLog = oLog.CBK_sfdcType__c;
                if(String.isNotBlank(sTipoLog)){
                    switch on sTipoLog{
                        //Se marcará el boolean como 'true' en el caso de que se encuentre entrada de tipo "Monitorizado" para indicar que no debe reprocesarse
                        when 'Monitorizado'{
                            bMonitorizado = true;
                            break;
                        }

                        //Se almacena el log de tipo "Perdido"
                        when 'Perdido'{
                            oLogPerdido = oLog;
                        }

                        //Se aumenta el nº de logs de tipo "Reprocesado"
                        when 'Reprocesado'{
                            iReprocesados++;
                        }
                    }
                }
            }

            //En el caso de que ese mensaje no tenga entrada de log de tipo "Monitorizado" y no tenga más de 3 logs de tipo "Reprocesado" se procede a llamar al servicio de /forward
            if(oLogPerdido != null && !bMonitorizado && iReprocesados < 3){
                //Se monta la lista de correos a los que hacer forward
                CBK_Log__c oLog = mapCorreoLogs.get(sMessageId)[0];
                List<CBK_WS_APIGraph.EmailAddress> mailRecipients = generateRecipientsList(oLog.CBK_sfdcToAddress__c, oLog.CBK_CCToAddress__c);
                callApiGraphForward(oLogPerdido, mailRecipients, mapMailboxes.get(oLogPerdido.CBK_BuzonCorreo__c));
            }
        }
    }

    global void finish(Database.BatchableContext BC) {
        //Se insertan los logs de los que se han procesado correctamente
        if(!listCBKLogsReprocesado.isEmpty()){
            insert listCBKLogsReprocesado;
        }

        //Se insertan las TrazasInt, si las hay
        if(!listTrazasInt.isEmpty()){
            insert listTrazasInt;
        }
    }

    //Entrada
    public class APIGraph_Forward{
        private String tenant {get; set;}
        private String emailId {get; set;}
        public String comment {get; set;}
        public List<CBK_WS_APIGraph.EmailAddress> toRecipients {get; set;}
    }

    public static void callApiGraphForward(CBK_Log__c oLog, List<CBK_WS_APIGraph.EmailAddress> mailRecipients, String sMailboxId){
        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de la llamada
        oTraza.Name = 'CBK_APIGraph_RevisionLogs_Batch__APIGraph_Forward';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_FinOK__c = false;
        String sSessionId = UserInfo.getSessionId();
        oTraza.CC_Identificador__c = (String.isNotBlank(sSessionId) && sSessionId.length() > 100)? sSessionId.substring(0, 99) : sSessionId;

        String sMessageId = oLog.CBK_hdMessageID__c;
        CBK_ExecuteAllHandlerEmailMessage__mdt hasNamedCredential = CBK_ExecuteAllHandlerEmailMessage__mdt.getInstance('CBK_ActiveNamedCredential');
        CBK_WS_APIGraph.ResponseWrapperDTO respDTO;
        CBK_WS_APIGraph.ResponseErrorWrapperDTO respErrorDTO;
        Map<String, String> mHeaders =  new Map<String, String>();
        //if (!Test.isRunningTest() && hasNamedCredential != null && !hasNamedCredential.CBK_ActivateAllExecution__c) {
            //mHeaders.put('Authorization', CBK_WS_APIGraph.getTokenAccess('TokenApiGraph'));
        //}
        //mHeaders.put('Accept', 'application/json');

        CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
        requestWrp.body = generateBodyAPIGraphForward(mailRecipients, sMessageId, sMailboxId);
        requestWrp.method = 'POST';
        requestWrp.mHeaders = mHeaders;
        requestWrp.mUriParams = null;
        requestWrp.mQueryParams = null;
        oTraza.CC_MensajeEntrada__c = requestWrp.body;

        try{
            HttpRequest req;
            String url;
            requestWrp.intSetting = 'CBK_API_Graph_Forward';
            req = CBK_HttpServiceIntegration.getRequest(requestWrp);
            String setting = requestWrp.intSetting;
            HttpResponse res = CBK_HttpServiceIntegration.multiCallHttpService(req, setting, setting);

            Integer iStatusCode = res.getStatusCode();
            if (iStatusCode == 202){                
                //Se crea el log de Reprocesado y se guarda en la lista a insertar al acabar
                createLogReprocesado(oLog);

                //Se especifica en la traza que el proceso fue correcto
                oTraza.CC_FinOK__c = true;
            }else{
                if(String.isNotBlank(res.getBody())){
                    respErrorDTO = (CBK_WS_APIGraph.ResponseErrorWrapperDTO) JSON.deserialize(res.getBody().replace('"request-id"', '"requestId"').replace('"client-request-id"', '"clientRequestId"').replace('"date"', '"vdate"'), CBK_WS_APIGraph.ResponseErrorWrapperDTO.class);
                }
                String sRespErrorDTO = json.serialize(respErrorDTO);
                CBK_Log.debug('Response Error APIGraph: ' + sRespErrorDTO);

                //En el caso de que hubiera un error en la llamada, se indica qué pasó
                oTraza.CC_TipoError__c = 'Código fallido llamada APIGraph/Forward: ' + iStatusCode;
                oTraza.CC_DetalleError__c = iStatusCode + ' - ' + sRespErrorDTO;
            }
        }catch(Exception e){
            //En el caso de que salte el catch, se guarda la razón en la traza
            oTraza.CC_TipoError__c = 'Error llamada APIGraph/Forward.';
            oTraza.CC_DetalleError__c = e.getMessage() + ' ' + e.getStackTraceString();
        }

        //Se añade la traza a la lista de trazas a insertar
        listTrazasInt.add(oTraza);
        
        insert listTrazasInt;
    }

    private static String generateBodyAPIGraphForward(List<CBK_WS_APIGraph.EmailAddress> mailRecipients, String sEmailId, String sTenant){
        //Se genera la lista de direcciones de correo a las que hacer forward
        APIGraph_Forward oBodyForward = new APIGraph_Forward();
        oBodyForward.tenant = sTenant;
        oBodyForward.emailId = sEmailId;
        oBodyForward.comment = 'Forward ' + Datetime.now();
        oBodyForward.toRecipients = mailRecipients;

        return JSON.serialize(oBodyForward);
    }    

    private static List<CBK_WS_APIGraph.EmailAddress> generateRecipientsList(String toAddresses, String ccToAddresses){
        //Se juntan la lista de correos y las de correos CC si es necesario
        List<String> listToAddresses = toAddresses.split(';');
        if(String.isNotBlank(ccToAddresses)){
            listToAddresses.addAll(ccToAddresses.split(';'));
        }

        //Se genera la lista de correos a los que reenviar
        List<CBK_WS_APIGraph.EmailAddress> listEmailAddress = new List<CBK_WS_APIGraph.EmailAddress>();
        for(String toAddress : listToAddresses){
            CBK_WS_APIGraph.EmailAddress emailAddress = new CBK_WS_APIGraph.EmailAddress();
            emailAddress.name = toAddress;
            emailAddress.address = toAddress;
            listEmailAddress.add(emailAddress);
        }
        return listEmailAddress;
    }
    
    private static List<String> getMailboxesToForward(){
        //Se buscan los Mailboxes que tengan el reenvío activo
		List<String> listMailboxesForward = new List<String>();
		for(CBK_APIGraph_Mailbox__c oMailbox : [SELECT CBK_MailboxID__c
                                                FROM CBK_APIGraph_Mailbox__c
                                               	WHERE CBK_Forward__c = true])  
        {
            listMailboxesForward.add(oMailbox.CBK_MailboxID__c);
        }
        
        //Retorno
        return listMailboxesForward;
    }

    private static void createLogReprocesado(CBK_Log__c oLogOriginal){
        //Se clona el Log original y se le cambia el estado y el mensaje, y se añade a la lista de insertado
        CBK_Log__c oLogReprocesado = oLogOriginal.clone(false, true, false, false);
        oLogReprocesado.CBK_sfdcResultStatus__c = 'OK';
        oLogReprocesado.CBK_sfdcResultDetail__c = 'Successful email reprocess [SFDC]';
        oLogReprocesado.CBK_sfdcType__c = 'Reprocesado';
        listCBKLogsReprocesado.add(oLogReprocesado);
    }
}