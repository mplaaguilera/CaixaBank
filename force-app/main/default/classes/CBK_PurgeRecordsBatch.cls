/**********************************************************************************************************************
 Name:	  CC_PurgeProcess_TRDisp
 Copyright © 2021  CaixaBank
=======================================================================================================================
Proposito: Clase batch para el purgado del FW de purgado.
=======================================================================================================================
Historial
---------------------
	VERSION		USER_STORY			AUTHOR				DATE				Description
	1.0								Francisco Zaragoza	22/11/2021			Init version
***********************************************************************************************************************/
global class CBK_PurgeRecordsBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Integer recordsProcessed = 0;
    global String idRecordPurgeProcess;

    global String objetoPurgado;
    global String RTsDevNames;
    global Integer diasInicioIntervalo;
    global Integer diasLimitepurgado;
    global String  condicionClausula;
    global Boolean  usoFechaSysMod;
    global String limitValue;
    global Boolean  borradoPapelera;
    global String queryLog;
    global String logParentId;
    global Boolean logDeleteDetails;

    global CBK_PurgeRecordsBatch() {
        this.objetoPurgado = '';
        this.RTsDevNames = '';
        this.diasInicioIntervalo=0;
        this.diasLimitepurgado=0;
        this.condicionClausula = '';
        this.usoFechaSysMod=false;
        this.limitValue = '';
        this.borradoPapelera=false;
        this.logDeleteDetails = false;
    }

    global CBK_PurgeRecordsBatch(String idRecordPurgeProcess) {
        this.objetoPurgado = '';
        this.RTsDevNames = '';
        this.diasInicioIntervalo=0;
        this.diasLimitepurgado=0;
        this.condicionClausula = '';
        this.usoFechaSysMod=false;
        this.limitValue = '';
        this.idRecordPurgeProcess = idRecordPurgeProcess;
        this.borradoPapelera=false;
        this.logDeleteDetails = false;
    }


    /**
    * Create a list of sObjects to purge
    * @param bc  Database.BatchableContext param that contains the batch job ID
    */	
        global Database.QueryLocator start(Database.BatchableContext bc) {
            recordsProcessed = 0; 
            CBK_PurgeProcess__c recordPurgeProcess = [SELECT Id,CBK_objetoPurgado__c, CBK_RTsDevNames__c, CBK_diasAntiguedadMaxima__c, CBK_diasAntiguedadMinima__c, CBK_condicionClausula__c, CBK_usoFechaSysModTimestamp__c, CBK_limitValue__c,  CBK_Activo__c, CBK_Estado__c,CBK_HardDelete__c, CBK_DeleteDetails__c 
                                                            from CBK_PurgeProcess__c where id =:idRecordPurgeProcess LIMIT 1];
            if (recordPurgeProcess != null && recordPurgeProcess.CBK_Activo__c == true && recordPurgeProcess.CBK_Estado__c == 'Autorizado' ){
                this.objetoPurgado = recordPurgeProcess.CBK_objetoPurgado__c;
                this.RTsDevNames = recordPurgeProcess.CBK_RTsDevNames__c;
                this.diasInicioIntervalo=Integer.ValueOf(recordPurgeProcess.CBK_diasAntiguedadMaxima__c);   
                this.diasLimitepurgado=Integer.ValueOf(recordPurgeProcess.CBK_diasAntiguedadMinima__c);
                this.condicionClausula = recordPurgeProcess.CBK_condicionClausula__c;
                this.usoFechaSysMod=recordPurgeProcess.CBK_usoFechaSysModTimestamp__c;
                this.limitValue =String.Valueof(recordPurgeProcess.CBK_limitValue__c);      
                this.borradoPapelera = recordPurgeProcess.CBK_HardDelete__c;
                this.logDeleteDetails = recordPurgeProcess.CBK_DeleteDetails__c;    
            }
            logParentId = createLog('INFO', new List<Object>(), null);

            String query = 'SELECT Id FROM ';
            query += this.objetoPurgado + ' WHERE ';
            if (String.isNotEmpty(this.RTsDevNames)){
                list<String> devNamesRTs = this.RTsDevNames.split(',');
                list <RecordType> idRTsPurge = [SELECT id from Recordtype WHERE SobjectType = : this.objetoPurgado AND DeveloperName in :devNamesRTs];
                query += 'RecordtypeId IN  ( ' ;
                for (RecordType idenRT : idRTsPurge){
                    query += '\''+ idenRT.id +'\',' ;
                }
                query = query.RemoveEnd(',');
                query += ') AND ';
            }
            if (this.diasInicioIntervalo != null && this.diasInicioIntervalo != 0){
                query += (this.usoFechaSysMod?'SystemModstamp':'CreatedDate')+ '>=' + System.DateTime.Now().addDays(-this.diasInicioIntervalo).format('yyyy-MM-dd\'T\'HH:mm:ss') + 'Z AND ';
                query += (this.usoFechaSysMod?'SystemModstamp':'CreatedDate')+ '<=' + System.DateTime.Now().addDays(-this.diasLimitepurgado).format('yyyy-MM-dd\'T\'HH:mm:ss'+'Z') ;
            }
            else{
                query += (this.usoFechaSysMod?'SystemModstamp':'CreatedDate')+ '<=' + System.DateTime.Now().addDays(-this.diasLimitepurgado).format('yyyy-MM-dd\'T\'HH:mm:ss')+'Z' ;
            }
            if (String.isNotEmpty(this.condicionClausula)){
                query +=  ' AND ' + this.condicionClausula;
            }
            if(String.isNotBlank(limitValue)){
                query += ' LIMIT ' + limitValue; 
            }
            queryLog = query;
            return Database.getQueryLocator(query);
        }
        global void execute(Database.BatchableContext bc, List<sObject> listObjectsPurge){
            try{
                List<SObject> listSObjectssToDelete = new List<SObject>();
                recordsProcessed += listObjectsPurge.size();
                for(SObject purgeObject : listObjectsPurge){
                    if (purgeObject != null ){
						listSObjectssToDelete.add(purgeObject);
					}
                }           
                if(!listSObjectssToDelete.isEmpty()){
                    List<Database.DeleteResult> results = Database.delete(listSObjectssToDelete,false);
                    List<Object> errores = new List<Object>();
                    List<Object> lstDeletes = new List<Object>();
                    for (Database.DeleteResult result : results) {
                        if (!result.isSuccess()){
                            for(Database.Error err : result.getErrors()) {
                                if (err.getStatusCode() != StatusCode.ENTITY_IS_DELETED){
                                    errores.add(err);
                                }
                            }
                        }else{
                            lstDeletes.add(result.getId());
                        }
                    }
                    if (this.borradoPapelera){
                        Database.emptyRecycleBin(listSObjectssToDelete);
                    }

                    if (errores.size()>0){
                        createLog('ERROR', errores, null);
                    }

                    if(lstDeletes.size()>0){
                        createDetaillLog(logParentId, lstDeletes);
                    }
                }
            }catch(System.Exception e){
                createLog('ERROR', null, e);
            }
        }	
	global void finish(Database.BatchableContext bc){
        createLog('DEBUG', new List<Object>(), null);
	}
	
    public string createLog(String logLevel, List<Object> detalles, System.Exception exep){
        String strlog = 'Record Processed: ' + recordsProcessed + ' Query: ' + queryLog;
        Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_PurgeProcess').getRecordTypeId();
        String insertLogId = '';

        CBK_Log__c logs = new CBK_Log__c ();    
        logs.recordtypeId = recordTypeId;
        logs.CBK_PurgeProcessId__c = idRecordPurgeProcess;
        logs.Log_Level__c = String.isNotBlank(logLevel) ? logLevel : 'INFO';
        logs.Log_Message__c = strlog.left(2000);
        logs.createdDate__c = System.now();
        logs.systemModstamp__c = System.now();

        Database.SaveResult[] srListInfo = null;
        if (logLevel == 'ERROR' && exep == null){
            strlog = 'Error batch purgado SObject: [' + this.objetoPurgado + ']';
            logs.Log_Message__c = strlog.left(2000);
            logs.Transaction_ID__c = 'Error Purge Batch';
        }else if(logLevel == 'ERROR' && exep != null){
            strlog = exep.getMessage();
            logs.Log_Message__c = strlog?.left(2000);
            logs.Log_Message_Ext__c = strlog?.left(32000);
            logs.Apex_Stack_Trace__c = exep?.getStackTraceString()?.left(32000);
            logs.Error_Type__c = exep?.getTypeName()?.left(30);
            logs.Transaction_ID__c = 'Error Exeption Purge Batch';
        }else if(logLevel == 'INFO' && logDeleteDetails){
            strlog = 'ID\'s Eliminados';
            logs.Log_Message__c = strlog?.left(2000);
            srListInfo =  Database.insert(new List<CBK_Log__c>{logs},false) ;
        }
        
        Database.SaveResult[] srList = logLevel != 'INFO' ? Database.insert(new List<CBK_Log__c>{logs},false) : srListInfo;

        if (srList != null && srList.size() > 0) {
            for (Database.SaveResult sr : srList) {
                if (sr.success){
                    insertLogId = sr.getId();
                }
            }

            List<String> lstDetail =  new List<String>();
            List<CBK_Log_Detail__c> lstLogDetail = new List<CBK_Log_Detail__c>();
            if (String.isNotBlank(insertLogId) && detalles != null && detalles.size() > 0){
                String details = String.join(detalles,'@Det@');
                lstDetail = String.isNotBlank(details) ? details.split('@Det@') : new List<String>();
                for (String det: lstDetail){
                    CBK_Log_Detail__c logDetail = new CBK_Log_Detail__c();
                    logDetail.Framework_Logging__c = insertLogId;
                    logDetail.Detail__c=det;
                    lstLogDetail.add(logDetail);   
                }
                Database.insert(lstLogDetail,false);
            }
        }
        return insertLogId;
    }

    public void createDetaillLog(String parentLogId, List<Object> deleteDetails){
        List<String> lstDetail =  new List<String>();
        List<CBK_Log_Detail__c> lstLogDetail = new List<CBK_Log_Detail__c>();
        if (String.isNotBlank(parentLogId) && deleteDetails != null && deleteDetails.size() > 0){
            String details = String.join(deleteDetails,', ');
            CBK_Log_Detail__c logDetail = new CBK_Log_Detail__c();
            logDetail.Framework_Logging__c = parentLogId;
            logDetail.Detail__c=details?.left(32700);
            lstLogDetail.add(logDetail);   
            Database.insert(lstLogDetail,false);
        }
    }
}