trigger CBK_LogEventTrigger on CBK_LogEvent__e (after insert) {
    
    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'Framework de Login'];

    String emailNotif;
    Boolean notif;    
    CBK_Framework_Login__mdt conf;
    List<CBK_Log__c> lstLog = New List<CBK_Log__c>();
    List<CBK_Log_Detail__c> lstLogDetail = New List<CBK_Log_Detail__c>();
    
    Map<String,CBK_Framework_Login__mdt> mapPrj = New Map<String,CBK_Framework_Login__mdt>();
    list<Messaging.SingleEmailMessage> lstmail = New list<Messaging.SingleEmailMessage>();
        
    //Configuración de traza por clases o prefijos
    for(CBK_Framework_Login__mdt prj :[select label,proyecto__c, Email_Notif__c, Notif__c from CBK_Framework_Login__mdt])
    {
        mapPrj.put(prj.label, prj);
    }
    
    Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Apex_Log').getRecordTypeId();
    
    for (CBK_LogEvent__e event : Trigger.New) {
        try{
            CBK_Log__c EvtLog = New CBK_Log__c();
            EvtLog.RecordTypeId = String.isNotBlank(event.CBK_sfdcRecordType__c) ? event.CBK_sfdcRecordType__c : recordTypeId;
            EvtLog.OwnerId =event.txt_User__c;
            EvtLog.Transaction_ID__c=event.txt_Context__c?.left(30); 
            EvtLog.Log_Level__c = event.txt_Level__c;
            EvtLog.Log_Message__c = event.txt_Message__c?.left(2000);
            EvtLog.Log_Message_Ext__c = event.txt_Message__c?.left(32000);
            EvtLog.Error_Code__c='';
            EvtLog.Error_Type__c = (event.txt_ErrType__c != NULL) ? (event.txt_ErrType__c+'').left(30) : '';
            EvtLog.Apex_Stack_Trace__c= (event.txt_stacktrace__c)?.left(32000);
            EvtLog.createdBy__c = event.txt_User__c; 
            EvtLog.FromAddress__c = (event.txt_FromAddress__c)?.left(255); 
            EvtLog.ToAddress__c = (event.txt_ToAddress__c)?.left(255);
            EvtLog.subject__c = (event.txt_Message__c)?.left(255);
            EvtLog.Detail__c = (event.txt_Detail__c)?.left(32000);
            EvtLog.CBK_hdReturnPath__c = (event.CBK_hdReturnPath__c)?.left(255);
            EvtLog.CBK_hdResentMessageId__c = (event.CBK_hdResentMessageId__c)?.left(255);
            EvtLog.CBK_hdTo__c = (event.CBK_hdTo__c)?.left(255);
            EvtLog.CBK_hdMessageID__c = (event.CBK_hdMessageID__c)?.left(255);
            EvtLog.CBK_hdExchangeInboxRulesLoop__c = (event.CBK_hdExchangeInboxRulesLoop__c)?.left(255);
            EvtLog.CBK_hdResentFrom__c = (event.CBK_hdResentFrom__c)?.left(255);
            EvtLog.CBK_hdExchangeParentMessageId__c = (event.CBK_hdExchangeParentMessageId__c)?.left(255);
            EvtLog.CBK_hdSFDCOriginalRCPT__c = (event.CBK_hdSFDCOriginalRCPT__c)?.left(255);
            EvtLog.CBK_hdMSHasAttach__c = (event.CBK_hdMSHasAttach__c)?.left(255);
            EvtLog.CBK_hdDeliveredTo__c = (event.CBK_hdDeliveredTo__c)?.left(255);
            EvtLog.CBK_hdReference__c = (event.CBK_hdReference__c)?.left(255);
            EvtLog.CBK_hdInReplyTo__c = (event.CBK_hdInReplyTo__c)?.left(255);
            EvtLog.CBK_sfdcMessageId__c = (event.CBK_sfdcMessageId__c)?.left(255);
            EvtLog.CBK_sfdcReplyTo__c = (event.CBK_sfdcReplyTo__c)?.left(255);
            EvtLog.CBK_sfdcToAddress__c = (event.CBK_sfdcToAddress__c)?.left(255);
            EvtLog.CBK_sfdcFromAdress__c = (event.CBK_sfdcFromAdress__c)?.left(255);
            EvtLog.CBK_sfdcEmailMessageId__c = String.isNotBlank(event.CBK_sfdcEmailMessageId__c) ? event.CBK_sfdcEmailMessageId__c : '';
            EvtLog.CBK_sfdcCaseId__c = String.isNotBlank(event.CBK_sfdcCaseId__c) ? event.CBK_sfdcCaseId__c : '';
            EvtLog.CBK_sfdcResultStatus__c  = String.isNotBlank(event.CBK_sfdcResultStatus__c) ? event.CBK_sfdcResultStatus__c : '';
            EvtLog.CBK_sfdcResultDetail__c = String.isNotBlank(event.CBK_sfdcResultDetail__c) ? event.CBK_sfdcResultDetail__c : '';
            EvtLog.CBK_MessageException__c = (event.CBK_MessageException__c)?.left(32500);
            EvtLog.CBK_sfdcType__c = event.CBK_sfdcType__c;
            //popular los valores

            EvtLog.CBK_AggregateQueries__c  = event.CBK_AggregateQueries__c;
            EvtLog.CBK_LimitAggregateQueries__c  = event.CBK_LimitAggregateQueries__c;
            EvtLog.CBK_AsyncCalls__c  = event.CBK_AsyncCalls__c;
            EvtLog.CBK_LimitAsyncCalls__c  = event.CBK_LimitAsyncCalls__c;
            EvtLog.CBK_Callouts__c  = event.CBK_Callouts__c;
            EvtLog.CBK_LimitCallouts__c  = event.CBK_LimitCallouts__c;
            EvtLog.CBK_CpuTime__c  = event.CBK_CpuTime__c;
            EvtLog.CBK_LimitCpuTime__c  = event.CBK_LimitCpuTime__c;
            EvtLog.CBK_DMLRows__c  = event.CBK_DMLRows__c;
            EvtLog.CBK_LimitDMLRows__c  = event.CBK_LimitDMLRows__c;
            EvtLog.CBK_DMLStatements__c  = event.CBK_DMLStatements__c;
            EvtLog.CBK_LimitDMLStatements__c  = event.CBK_LimitDMLStatements__c;
            EvtLog.CBK_EmailInvocations__c  = event.CBK_EmailInvocations__c;
            EvtLog.CBK_LimitEmailInvocations__c  = event.CBK_LimitEmailInvocations__c;
            EvtLog.CBK_FutureCalls__c  = event.CBK_FutureCalls__c;
            EvtLog.CBK_LimitFutureCalls__c  = event.CBK_LimitFutureCalls__c;
            EvtLog.CBK_HeapSize__c  = event.CBK_HeapSize__c;
            EvtLog.CBK_LimitHeapSize__c  = event.CBK_LimitHeapSize__c;
            EvtLog.CBK_MobilePushApexCalls__c  = event.CBK_MobilePushApexCalls__c;
            EvtLog.CBK_LimitMobilePushApexCalls__c  = event.CBK_LimitMobilePushApexCalls__c;
            EvtLog.CBK_PublishImmediateDML__c  = event.CBK_PublishImmediateDML__c;
            EvtLog.CBK_LimitPublishImmediateDML__c  = event.CBK_LimitPublishImmediateDML__c;
            EvtLog.CBK_Queries__c  = event.CBK_Queries__c;
            EvtLog.CBK_LimitQueries__c  = event.CBK_LimitQueries__c;
            EvtLog.CBK_QueryLocatorRows__c  = event.CBK_QueryLocatorRows__c;
            EvtLog.CBK_LimitQueryLocatorRows__c  = event.CBK_LimitQueryLocatorRows__c;
            EvtLog.CBK_QueryRows__c  = event.CBK_QueryRows__c;
            EvtLog.CBK_LimitQueryRows__c  = event.CBK_LimitQueryRows__c;
            EvtLog.CBK_QueueableJobs__c  = event.CBK_QueueableJobs__c;
            EvtLog.CBK_LimitQueueableJobs__c  = event.CBK_LimitQueueableJobs__c;
            EvtLog.CBK_SoslQueries__c  = event.CBK_SoslQueries__c;
            EvtLog.CBK_LimitSoslQueries__c  = event.CBK_LimitSoslQueries__c;

            //EvtLog.Apex_Class__c=''; --> Cálculo en la función CBK_Log.populateLocation
            //EvtLog.Apex_Method__c='';--> Cálculo en la función CBK_Log.populateLocation
            //EvtLog.Apex_Num_line__c = '';--> Cálculo en la función CBK_Log.populateLocation
            CBK_Log.populateLocation(EvtLog);
            if (EvtLog.Log_Message__c.left(1)=='{') {CBK_Log.deserializeMsg(EvtLog);}
               
            
            //Cálculo del proyecto
            emailNotif='';
            notif=false;
            system.debug(EvtLog.Apex_Class__c);
            conf=mapPrj.get(EvtLog.Apex_Class__c);
            if (conf != null){
                EvtLog.Project__c = conf.proyecto__c;
                emailNotif = conf.Email_Notif__c;
                notif = conf.Notif__c;
            } else if (EvtLog.Apex_Class__c?.indexOf('_')>0) {
                conf=mapPrj.get(EvtLog.Apex_Class__c.substring(0,EvtLog.Apex_Class__c.indexOf('_')+1)+'*');
                if (conf != null){
                    EvtLog.Project__c = conf.proyecto__c;
                    emailNotif = conf.Email_Notif__c;
                    notif = conf.Notif__c;
                }
            }
            lstLog.add(EvtLog);
            
            //Notificaciones por mail
            if (notif && (EvtLog.Log_Level__c=='ERROR') && ( owea.size() > 0 ) && (emailNotif!='')) {
                lstmail.add(CBK_Log.enviomail(EvtLog,owea.get(0).Id,emailNotif));
            }
        }
        catch(Exception e){
			System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        // Set the Replay ID of the last successfully processed event message. 
        // If a limit is hit, the trigger refires and processing starts with the 
        // event after the last one processed (the set Replay ID).
        EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.replayId);
    }
    //Inserción de registros
    Database.SaveResult[] srList = Database.insert(lstLog,false);

    Set<String> sId = new Set<String>();
    map<String, CBK_Log__c> mLogsWithDetails =  new map<String, CBK_Log__c>();
    if ( srList != null && srList.size() > 0) {
        for (Database.SaveResult sr : srList) {
            if (sr.success){
                sId.add(sr.getId());
            }
        }
    }

    List<CBK_Log__c> lstlogs = [SELECT Id,Detail__c FROM CBK_Log__c WHERE Id IN :sId];
    if (lstlogs != null && lstlogs.size() > 0) {
        for(CBK_Log__c log : lstlogs){
            if (!mLogsWithDetails.containsKey(log.Id)){
                mLogsWithDetails.put(log.Id, log);
            }
        }
    }

    List<String> lstDetail =  new List<String>();
    for (CBK_Log__c log : mLogsWithDetails.values()){
        try{
            lstDetail = String.isNotBlank(log.Detail__c) ? log.Detail__c.split('@Det@') : new List<String>();
            for (String det: lstDetail){
                CBK_Log_Detail__c EvtLogDetail = New CBK_Log_Detail__c();
                EvtLogDetail.Framework_Logging__c = mLogsWithDetails.containsKey(log.Id)  ?  mLogsWithDetails.get(log.Id).Id : null;
                EvtLogDetail.Detail__c=det;
                lstLogDetail.add(EvtLogDetail);   
            }
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }

    Database.insert(lstLogDetail,false);
    
   	// Send the email you have created.
    for (Messaging.SingleEmailMessage msg : lstmail){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }	

}