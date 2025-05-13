public class CBK_WS_APIGraph_MAP implements Queueable, Database.AllowsCallouts{
    List<CBK_WS_APIGraph.ResponseWrapperDTO> response;
    static final List<CBK_WS_APIGraph.ResponseWrapperDTO> respDTOAll = new List<CBK_WS_APIGraph.ResponseWrapperDTO>();
    public CBK_WS_APIGraph_MAP(List<CBK_WS_APIGraph.ResponseWrapperDTO> resp){
        response = resp;
    }

    public void execute(QueueableContext context) {	
        mapApiGraphToSF(response);
    }


    //Entrada
    public class APIGraph_Forward{
        public String comment {get; set;}
        public List<CBK_WS_APIGraph.EmailAddress> toRecipients {get; set;}
    }

    public static void mapApiGraphToSF(List<CBK_WS_APIGraph.ResponseWrapperDTO> responseApi) {
        List<CBK_APIGraph_Mailbox__c> listMailbox = new List<CBK_APIGraph_Mailbox__c>();
        Set<String> setInternetMessageId = new Set<String>();
        Map<String, CBK_WS_APIGraph.Value> mApiGraphById = new Map<String, CBK_WS_APIGraph.Value>();
        Map<String, String> mMailboxById = new Map<String, String>();
        for (CBK_WS_APIGraph.ResponseWrapperDTO respdto : responseApi){
            //Solamente se actualizará la fecha de último procesado del buzón en el caso de que no haya más correos a procesar
            if(respdto.nextPage == null){
                listMailbox.add(respdto.mailbox);
            }

            if(respdto.Mails != null){
                for(CBK_WS_APIGraph.Value val : respdto.Mails){
                    if(respdto.mailbox != null){
                        mMailboxById.put(val.internetMessageId, respdto.mailbox.Id);
                    }
                    mApiGraphById.put(val.internetMessageId, val);
                    setInternetMessageId.add(val.internetMessageId.left(255));
                }
            }
        }
        CBK_Log.debug('Informacion a mapear en SF: nº '+ mApiGraphById.size()+ '  ' + JSON.serialize(mApiGraphById));

        //Se guarda una lista de Emails para comprobar después si las entradas de CBK_Log tienen un email relacionado a ellas o no
        Map<String, EmailMessage> mapEmails = new Map<String, EmailMessage>([SELECT Id
                                                                             FROM EmailMessage
                                                                             WHERE Id IN : mApiGraphById.keySet()
                                                                             AND CBK_sfdcMessageId__c IN : setInternetMessageId]);

        List<CBK_Log__c> lstCBKlog =  [SELECT Id,CreatedDate,   CBK_sfdcType__c, Subject__c,RecordType.DeveloperName, CBK_sfdcResultStatus__c, CBK_hdReturnPath__c, CBK_hdResentMessageId__c, CBK_hdTo__c, CBK_hdMessageID__c , CBK_hdExchangeInboxRulesLoop__c, CBK_hdResentFrom__c, CBK_hdExchangeParentMessageId__c, CBK_hdSFDCOriginalRCPT__c,CBK_hdMSHasAttach__c,CBK_hdDeliveredTo__c, CBK_hdReference__c,CBK_hdInReplyTo__c,  CBK_sfdcMessageId__c, CBK_sfdcToAddress__c,CBK_sfdcFromAdress__c, CBK_sfdcReplyTo__c,CBK_sfdcEmailMessageId__c, CBK_sfdcCaseId__c,  CBK_sfdcResultDetail__c
                                        FROM CBK_Log__c
                                        WHERE CBK_sfdcMessageId__c IN : mApiGraphById.keySet()
                                        AND CBK_Valido__c = true];

        Map<String, CBK_Log__c> mapAuditados = new Map<String, CBK_Log__c>();
        Map<String, CBK_Log__c> mapResultos = new Map<String, CBK_Log__c>();
        Map<String, CBK_Log__c> mapMissingEmails = new Map<String, CBK_Log__c>();

        for (CBK_Log__c log : lstCBKlog){
            if (log.CBK_sfdcType__c == 'Entrada'){
                mapAuditados.put(log.CBK_sfdcMessageId__c, log);
            }else if(log.CBK_sfdcType__c == 'Resultado'){
                mapResultos.put(log.CBK_sfdcMessageId__c, log);
            }else if (log.CBK_sfdcType__c == 'Perdido'){
                mapMissingEmails.put(log.CBK_sfdcMessageId__c, log);
            }
        }
        
        List<CBK_Log__c> lstResults = new List<CBK_Log__c>();
        CBK_Log__c result;
        CBK_WS_APIGraph.Value apiInfo;
        String emailMessageId;
        String sInternetMessageId;
        String sMailboxId;
        for (string key : mApiGraphById.keySet()){
            apiInfo = mApiGraphById.get(key);
            sMailboxId = mMailboxById.get(key);
            sInternetMessageId = key.left(255);
            if(mapEmails.containsKey(key)){
                if (mapAuditados.containsKey(key) && mapResultos.containsKey(key) && !mapMissingEmails.containsKey(key)){ 
                    emailMessageId = String.isNotBlank(mapResultos.get(key).CBK_sfdcEmailMessageId__c) ? mapResultos.get(key).CBK_sfdcEmailMessageId__c : '';
                    result = createLog(key, 'OK', 'Successful email process [SFDC]', emailMessageId, apiInfo, 'Monitorizado', sInternetMessageId, sMailboxId);
                    lstResults.add(result);
                }else if (mapAuditados.containsKey(key) && !mapResultos.containsKey(key) && !mapMissingEmails.containsKey(key)){
                    result = createLog(key, 'KO', 'Email with process Error [SFDC]', '', apiInfo, 'Resultado', sInternetMessageId, sMailboxId);
                    lstResults.add(result);
                }else if (!mapAuditados.containsKey(key) && mapResultos.containsKey(key) && !mapMissingEmails.containsKey(key)){
                    result = createLog(key, 'KO', 'Email Found', '', apiInfo, 'Entrada', sInternetMessageId, sMailboxId);
                    lstResults.add(result);
                }else if (!mapAuditados.containsKey(key) && !mapResultos.containsKey(key) && !mapMissingEmails.containsKey(key)){
                    result = createLog(key, 'KO', 'Email Not Found', '', apiInfo, 'Monitorizado', sInternetMessageId, sMailboxId);
                    lstResults.add(result);
                }
            }else{
                result = createLog(key, 'KO', 'Email Lost', '', apiInfo, 'Perdido', sInternetMessageId, sMailboxId);

                lstResults.add(result);
            }
        }

        if (lstResults.size() > 0){
            CBK_Log.debug('Registros APIgraph para insertar en CBK_log: ' + JSON.serialize(lstResults));
            Database.SaveResult[] srList = Database.insert(lstResults,false);
            CBK_Log.debug('Registros Insertados APIGraph: ' + JSON.serialize(srList));
        }
        
        if(!listMailbox.isEmpty()){
            CBK_Log.debug('Registros CustomSetting CBK_APIGraph_Mailbox__c a actualizar: ' + JSON.serialize(listMailbox));
            Datetime dtNow = System.now();
            for(CBK_APIGraph_Mailbox__c oMailbox : listMailbox){
                oMailbox.CBK_LastMonitoringDate__c = dtNow;
            }
            Database.SaveResult[] srList = Database.update(listMailbox, false);
            CBK_Log.debug('Registros Actualizados CBK_APIGraph_Mailbox__c: ' + JSON.serialize(listMailbox));
        }

        //tratar paginaciones
        Map<String, CBK_APIGraph_Mailbox__c> nexExecutionParams = new Map<String, CBK_APIGraph_Mailbox__c>();
        for(CBK_WS_APIGraph.ResponseWrapperDTO resp : responseApi){
            if (String.isNotBlank(resp.nextPage) && resp.mailbox != null){
                nexExecutionParams.put(resp.nextPage, resp.mailbox);
            }
        }
        system.debug('Link de paginacion a obtener: ' + nexExecutionParams);
        executeSchedule(nexExecutionParams);
    }

    public static CBK_Log__c createLog(String messageId, String status, String detail, String emailMessageId, CBK_WS_APIGraph.Value apiInfo, String type, String sXSFDCOriginalRCPT, String sMailboxId){
        Id recordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_AutditEmail').getRecordTypeId();
        CBK_Log__c result = new CBK_Log__c(); 
        result.recordTypeId = recordTypeId;
        result.CBK_hdExchangeParentMessageId__c = apiInfo.emailId;
        result.CBK_sfdcMessageId__c = messageId;
        result.CBK_sfdcResultStatus__c = status;
        result.CBK_sfdcResultDetail__c = detail;
        result.Subject__c = apiInfo.subject?.left(29);
        result.CBK_sfdcEmailMessageId__c = String.isNotBlank(emailMessageId) ? emailMessageId : '';
        result.CBK_sfdcFromAdress__c = apiInfo.mailFrom.address;
        result.CBK_sfdcType__c = type;
        result.CBK_hdSFDCOriginalRCPT__c = sXSFDCOriginalRCPT;
        List<String> toAddressStr = new List<String>(); 
        for(CBK_WS_APIGraph.EmailAddress to : apiInfo.mailRecipients){
            toAddressStr.add(to.address);
        }
        result.CBK_sfdcToAddress__c = string.join(toAddressStr, ';')?.left(254);
        List<String> CCToAddressStr = new List<String>(); 
        for(CBK_WS_APIGraph.EmailAddress to : apiInfo.mailCCRecipients){
            toAddressStr.add(to.address);
        }
        result.CBK_CCToAddress__c = string.join(CCToAddressStr, ';')?.left(254);
        result.CBK_BuzonCorreo__c = sMailboxId;
        result.CBK_FechaCorreo__c = (String.isNotBlank(apiInfo.receivedDate))? Datetime.valueOf(apiInfo.receivedDate) : System.now();
        return result;
    }    

    public static void executeSchedule(Map<String, CBK_APIGraph_Mailbox__c> nexExecutionParams){
        if (nexExecutionParams != null && nexExecutionParams.size() > 0){
            System.enqueueJob(new CBK_WS_APIGraph_NextLink_Schedule(nexExecutionParams), 1);
        }
    }
}