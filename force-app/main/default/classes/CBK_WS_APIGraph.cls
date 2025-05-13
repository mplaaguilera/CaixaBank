public class CBK_WS_APIGraph implements Queueable, Database.AllowsCallouts{
    APIGraph_MailboxRequest body;
    CBK_ScheduleControls__c inputScheduleinfo;
    List<CBK_APIGraph_Mailbox__c> inputMailbox = new List<CBK_APIGraph_Mailbox__c>();
    static final List<ResponseWrapperDTO> respDTOAll = new List<ResponseWrapperDTO>();
    static final List<CC_TrazaInt__c> listTrazasInt = new List<CC_TrazaInt__c>();
    Boolean islink = false;
    String nextPage = '1';
    CBK_APIGraph_Mailbox__c mailboxNextPage;

    //Métodos invocables desde proceso queueable
    public void CBK_WS_APIGraph_Body(){
        body = new APIGraph_MailboxRequest();
        body.nextPage = nextPage;
    }

    public void CBK_WS_APIGraph_Body(Integer interval, Integer offset, Datetime lastMonitoringDate, String buzon){
        body = new APIGraph_MailboxRequest();
        body.tenant = buzon;
        Datetime dtStartDate = System.now().addMinutes(-offset);
        body.startDate = dtStartDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'', 'GMT');
        body.endDate = dtStartDate.addMinutes(interval).format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'', 'GMT');
        body.topLimit = integer.valueOf(inputScheduleinfo.CBK_QueueableLimit__c);
        CBK_Log.debug('Cuerpo entrada request:' + String.valueOf(body));
    }

    //Process Queueable
    public CBK_WS_APIGraph(List<CBK_APIGraph_Mailbox__c> buzones, CBK_ScheduleControls__c scheduleinfo){
        inputMailbox = buzones;
        inputScheduleinfo = scheduleinfo; 
    }

    //Paginación
    public CBK_WS_APIGraph(String linkNextPag, Boolean isNextlink, CBK_APIGraph_Mailbox__c mailboxObjNextPag){
        nextPage = linkNextPag;
        islink = isNextlink;
        mailboxNextPage = mailboxObjNextPag;
    }
	
    public void execute(QueueableContext context) {	
        try{
            if (inputMailbox.size() > 0){
                CBK_Log.debug('Lista buzones mdt ' + JSON.serialize(inputMailbox));
                for (CBK_APIGraph_Mailbox__c bzn : inputMailbox){
                    CBK_WS_APIGraph_Body(Integer.valueOf(bzn.CBK_IntervalMinutes__c), Integer.valueOf(bzn.CBK_OffsetMinutes__c), bzn.CBK_LastMonitoringDate__c, String.valueOf(bzn.CBK_MailboxID__c));
                    callApiGraph(body, islink, bzn);
                }
            }else if (islink){
                CBK_WS_APIGraph_Body();
                callApiGraph(body, true, mailboxNextPage);
            }
            CBK_Log.debug('Lista con Todas las respuestas de la APIGraph: ' + JSON.serialize(respDTOAll));
            if(respDTOAll.size() > 0 && !Test.isRunningTest()){
                CBK_WS_APIGraph_MAP mapToSF = new CBK_WS_APIGraph_MAP(respDTOAll);
                System.enqueueJob(mapToSF);
            }
        }catch(Exception e){
            System.debug(e.getStackTraceString() + ' ' + e.getMessage());
            CBK_log.error(e, 'Error CBK_WS_APIGraph - execute ' + e.getLineNumber() + ' ' + e.getMessage());
            
            //En el caso de que salte el catch, se guarda la razón en una traza
            CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
            oTraza.Name = 'CBK_WS_APIGraph';
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_FinOK__c = false;
            String sSessionId = UserInfo.getSessionId();
            oTraza.CC_Identificador__c = (String.isNotBlank(sSessionId) && sSessionId.length() > 100)? sSessionId.substring(0, 99) : sSessionId;
            oTraza.CC_TipoError__c = 'Error llamadas APIGraph.';
            oTraza.CC_DetalleError__c = e.getMessage() + ' ' + e.getStackTraceString();
            listTrazasInt.add(oTraza);
        }

        //Se insertan las TrazasInt, si las hay
        if(!listTrazasInt.isEmpty()){
            insert listTrazasInt;
        }
    }

    public static void callApiGraph(APIGraph_MailboxRequest body, Boolean isNextlink, CBK_APIGraph_Mailbox__c inputMailbox){
        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
        oTraza.Name = 'CBK_WS_APIGraph__APIGraphMessages';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_FinOK__c = false;
        String sSessionId = UserInfo.getSessionId();
        oTraza.CC_Identificador__c = (String.isNotBlank(sSessionId) && sSessionId.length() > 100)? sSessionId.substring(0, 99) : sSessionId;

        CBK_ExecuteAllHandlerEmailMessage__mdt hasNamedCredential = CBK_ExecuteAllHandlerEmailMessage__mdt.getInstance('CBK_ActiveNamedCredential');
        ResponseWrapperDTO respDTO;
        ResponseErrorWrapperDTO respErrorDTO;
        Map<String, String> mHeaders =  new Map<String, String>();
        //if (!Test.isRunningTest() && hasNamedCredential != null && !hasNamedCredential.CBK_ActivateAllExecution__c) {
            //mHeaders.put('Authorization', getTokenAccess('TokenApiGraph'));
        //}
        //mHeaders.put('Accept', 'application/json');

        CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
        requestWrp.body = JSON.serialize(body);
        requestWrp.method = 'POST';
        //requestWrp.method = 'GET';
        requestWrp.mHeaders = mHeaders;
        requestWrp.mUriParams = null;
        requestWrp.mQueryParams = null;

        HttpRequest req;
        String url;
        requestWrp.intSetting = 'CBK_API_Graph';

        oTraza.CC_MensajeEntrada__c = JSON.serialize(body);

        req = CBK_HttpServiceIntegration.getRequest(requestWrp);

        String setting = requestWrp.intSetting;
        HttpResponse res = CBK_HttpServiceIntegration.multiCallHttpService(req, setting, setting);

        Integer iStatusCode = res.getStatusCode();
        if (iStatusCode == CBK_ServiceRestManager.CORRECT_STATUS_CODE){
            oTraza.CC_MensajeSalida__c = res.getBody().left(131072);

            //.replace('"from"', '"fromm"').replace('"@odata.etag"', '"odata_etag"').replace('"@odata.nextLink"', '"odata_nextLink"').replace('"@odata.context"', '"odata_context"')
            respDTO = (ResponseWrapperDTO) JSON.deserialize(res.getBody(), ResponseWrapperDTO.class);
            CBK_Log.debug('Response APIGraph: ' + json.serialize(respDTO));
            
            //Se revisan los correos y se descartan aquellos que tengan el mismo "From" y "To"
            if(respDTO.Mails != null){
                Value oMail;
                for (Integer i = (respDTO.Mails.size()-1); i >= 0; i--){
                    oMail = respDTO.Mails.get(i);
                    //Se comprueba que haya solamente un correo en "mailRecipients", y si es así, que es igual al correo en "mailFrom". En ese caso, se quita de la lista
                    if(oMail.mailRecipients != null && oMail.mailRecipients.size() == 1 && oMail.mailFrom != null && oMail.mailFrom.address == oMail.mailRecipients[0].address){
                        respDTO.Mails.remove(i);
                    }
                }
            }
            
            respDTOAll.add(respDTO);
            CBK_Log.debug('Response APIGraph All: ' + json.serialize(respDTOAll));

            //Se especifica en la traza que el proceso fue correcto
            oTraza.CC_FinOK__c = true;
            //Se informan tanto el mailbox a actualizar como el valor de X-SFDC-Original-RCPT para poder utilizarlos después
            respDTO.mailbox = inputMailbox;
            respDTO.xSFDCOriginalRCPT = res.getHeader('X-SFDC-Original-RCPT');
        }else{
            String sRespErrorDTO;
            if(String.isNotBlank(res.getBody())){
                sRespErrorDTO = res.getBody();
                //respErrorDTO = (ResponseErrorWrapperDTO) JSON.deserialize(res.getBody().replace('"request-id"', '"requestId"').replace('"client-request-id"', '"clientRequestId"').replace('"date"', '"vdate"'), ResponseErrorWrapperDTO.class);
            }
            //sRespErrorDTO = json.serialize(respErrorDTO);
            CBK_Log.debug('Response Error APIGraph: ' + sRespErrorDTO);

            //En el caso de que hubiera un error en la llamada, se indica qué pasó
            oTraza.CC_TipoError__c = 'Código fallido llamada APIGraph/Messages: ' + iStatusCode;
            oTraza.CC_DetalleError__c = iStatusCode + ' - ' + sRespErrorDTO;
        }
        
        //Se añade la traza a la lista de las que se deben insertar
        listTrazasInt.add(oTraza);
        //insert listTrazasInt; // Eliminar el insert
    }

    //Entrada
    public class APIGraph_MailboxRequest{
        public String tenant {get; set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
        public Integer topLimit {get; set;}
        public String nextPage {get; set;}
    }

    //Response OK
    public class ResponseWrapperDTO{
        public String odata_context  { get; set; }
        public String nextPage { get; set; }
        public List<Value> Mails { get; set; }
        public CBK_APIGraph_Mailbox__c mailbox { get; set; }
        public String xSFDCOriginalRCPT { get; set; }
    }

    public class Value{
        public String emailId { get; set; }
        public String createdDate { get; set; }
        public String receivedDate { get; set; }
        public Boolean attachments { get; set; }
        public String internetMessageId { get; set; }
        public String subject { get; set; }
        public EmailAddress mailSender {get; set;}
        public EmailAddress mailFrom {get; set;}
        public EmailAddress[] mailRecipients {get; set;}
        public EmailAddress[] mailCCRecipients {get; set;}
        public EmailAddress[] mailBCCRecipients {get; set;}
        public String referenceId {get; set;}

        /*public String id { get; set; }
        public String createdDateTime { get; set; }
        public String receivedDateTime { get; set; }
        public Boolean hasAttachments { get; set; }
        public String internetMessageId { get; set; }
        public String subject { get; set; }
        public EmailAddressObj sender {get; set;}
        public EmailAddressObj from {get; set;}
        public List<EmailAddressObj> toRecipients {get; set;}
        public List<EmailAddressObj> ccRecipients {get; set;}
        public List<EmailAddressObj> bccRecipients {get; set;}/*

        /*public String odata_etag { get; set; }
        public String lastModifiedDateTime { get; set; }
		public String changeKey { get; set; }
        public List<String> categories { get; set; }
        public String sentDateTime { get; set; }
        public String bodyPreview { get; set; }
        public String importance { get; set; }
        public String parentFolderId { get; set; }
        public String conversationId { get; set; }
        public String conversationIndex { get; set; }
        public Boolean isDeliveryReceiptRequested { get; set; }
        public Boolean isReadReceiptRequested { get; set; }
        public Boolean isRead { get; set; }
        public Boolean isDraft { get; set; }
        public String webLink { get; set; }
        public String inferenceClassification { get; set; }
        public BodyObject body {get; set;}
        public List<EmailAddressObj> replyTo {get; set;}
        public Flag flag {get; set;}*/
	}

    /*public class EmailAddressObj{
		public EmailAddress emailAddress { get; set; }
	}*/

    public class EmailAddress{
		public String name { get; set; }
        public String address { get; set; }	
	}

    /*public class Flag{
		public String flagStatus { get; set; }
	}

    public class BodyObject{
		public String contentType { get; set; }
        public String content { get; set; }
	}*/

    //Response OK
    public class ResponseErrorWrapperDTO{
		public ErrorDetail error { get; set;}
	}

    public class ErrorDetail{
		public String code { get; set;}
        public String message { get; set;}  
        public InnerError innerError { get; set;} 

	}

    public class InnerError{
	    public String vdate { get; set;} 
        public String requestId { get; set;}
        public String clientRequestId { get; set;}
	}  

    //GET TOKEN
    public static String getTokenAccess(String configToken){
        CBK_IntegrationToken_Setting__c conf = CBK_IntegrationToken_Setting__c.getValues(configToken);
        String accessToken = '';
        String client_id = conf.ClientId__c;
        String client_secret = conf.ClientSecret__c;
        String scope = conf.CBK_Scope__c;
        String grant_type = conf.CBK_GrantType__c;
        String tenant = conf.UserName__c;
 
        List<String> urlParams = new List<String> {
                'grant_type=' + EncodingUtil.urlEncode(grant_type, 'UTF-8'),
                'scope=' + EncodingUtil.urlEncode(scope, 'UTF-8'),
                'client_id=' + EncodingUtil.urlEncode(client_id, 'UTF-8'),
                'client_secret=' + EncodingUtil.urlEncode(client_secret, 'UTF-8'),
                'tenant=' + EncodingUtil.urlEncode(tenant, 'UTF-8')
        };
 
        try{
            String body = String.join(urlParams, '&');
            Map<String, String> mHeaders =  new Map<String, String>();
            mHeaders.put('Content-Type', 'application/x-www-form-urlencoded');

            String intSetting = 'CBK_APIGraphToken';
            CBK_HttpServiceIntegration.RequestWapper requestWrp = new CBK_HttpServiceIntegration.RequestWapper();
            requestWrp.body = body;
            requestWrp.intSetting = intSetting;
            requestWrp.method = 'GET';
            requestWrp.mHeaders = mHeaders;
            requestWrp.mUriParams = null;
            requestWrp.mQueryParams = null;

            HttpRequest req = CBK_HttpServiceIntegration.getRequest(requestWrp);
            HttpResponse res = CBK_HttpServiceIntegration.multiCallHttpService(req, intSetting, intSetting);
            if (res.getStatusCode() == CBK_ServiceRestManager.CORRECT_STATUS_CODE){
                Map<String, String> mapToken = (Map<String, String>) (JSON.deserialize(res.getBody(), Map<String, String>.class));
                accessToken = mapToken.get('access_token');
                //if (accessToken == '' || accessToken == null) {
                	//throw new CBK_ServiceRestManager.PreconditionFailedException('Received null token', res.getStatusCode());
                //}
            }else{
            	throw new CBK_ServiceRestManager.BadResponseException(res.getBody(), res.getStatus(), res.getStatusCode());
            }      
        }catch(CallOutException ce){
            CBK_Log.error(ce);
            throw ce;
        }
        return 'Bearer ' + accessToken;
    }
}