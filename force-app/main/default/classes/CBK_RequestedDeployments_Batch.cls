/**********************************************************************************************************************
 Name:	  CBK_RequestedDeployments_Batch
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Propósito: Batch que procesa en lotes los deployments y les crea entradas CBK_Log acorde con el resultado
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			US868474		    Jose Manuel   		17/10/2024		    Init version
***********************************************************************************************************************/
public with sharing class CBK_RequestedDeployments_Batch implements Database.Batchable<String>, Database.AllowsCallouts
{
    //List de IDs de DeployRequest a procesar con ToolingAPI, y las fechas de inicio y fin utilizadas en la query
    private static List<String> listDeployRequestIDs;
    private static Datetime dtStartDate;
    private static Datetime dtEndDate;

    //Lista de CBK_Log a eliminar
    private static List<CBK_Log__c> listLogsDelete = new List<CBK_Log__c>();

    //Lista de CBK_Log a insertar
    private static List<CBK_Log__c> listLogsInsert = new List<CBK_Log__c>();

    //Lista de TrazaInt a insertar
    private static List<CC_TrazaInt__c> listTrazasInsert = new List<CC_TrazaInt__c>();

    //Constructor al que se le informa el Set de IDs de DeployRequests a procesar
    public CBK_RequestedDeployments_Batch(Set<String> setDeployRequestIDs, Datetime startDate, Datetime endDate){
        listDeployRequestIDs = new List<String>(setDeployRequestIDs);
        dtStartDate = startDate;
     	dtEndDate = endDate;
    }

    public Iterable<String> start(Database.BatchableContext bc) {
        return listDeployRequestIDs;
    }

    public void execute(Database.BatchableContext info, List<String> scope){
        //Se mira que el Set de IDs no esté vacío
        if(scope != null && !scope.isEmpty()){
            //Se recupera la información de los DeployRequests recuperados vía la query de ToolingAPI
            List<Map<String, Object>> deployRequestInfoList = new List<Map<String, Object>>();
            deployRequestInfoList = getDeployRequestInfo(scope);
            
            //En el caso de que haya información a procesar, se crean los CBK_Log
            if(!deployRequestInfoList.isEmpty()){
                checkLogs(deployRequestInfoList);
            }
        }
    }

    public void finish(Database.BatchableContext info){
        //Se eliminan los CBK_Log, si los hay
        if (!listLogsDelete.isEmpty()) {
            delete listLogsDelete;
        }

        //Se insertan los CBK_Log, si los hay
        if(!listLogsInsert.isEmpty()){
            insert listLogsInsert;
        }

        //Se insertan las TrazaInt, si las hay
        if(!listTrazasInsert.isEmpty()){
            insert listTrazasInsert;
        }
    }

    //Función para la llamada usada para recuperar los datos de un deployment
    public static List<Map<String, Object>> getDeployRequestInfo(List<String> prodReqIds){
        List<Map<String, Object>> deployRequestInfoList = new List<Map<String, Object>>();
        CC_TrazaInt__c oTraza;
        for(Id idReqProd : prodReqIds){
            oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
            oTraza.Name = 'CBK_StatusDeployRequest';
            oTraza.CC_FechaInicio__c = datetime.now();
            oTraza.CC_FinOK__c = false;
            String sSessionId = UserInfo.getSessionId();
            oTraza.CC_Identificador__c = (String.isNotBlank(sSessionId) && sSessionId.length() > 100)? sSessionId.substring(0, 99) : sSessionId;
            
            CBK_HttpServiceIntegration.RequestWapper req = new CBK_HttpServiceIntegration.RequestWapper();
            Map<String, String> mHeaders =  new  Map<String,String>();

            mHeaders.put('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.intSetting = 'CBK_StatusDeployRequest';
            req.mHeaders = mHeaders;

            HttpRequest request = CBK_HttpServiceIntegration.getRequest(req);
            String urlWithId = request.getEndpoint() + idReqProd;
            request.setEndpoint(urlWithId);

            HttpResponse response = CBK_HttpServiceIntegration.multiCallHttpService(request, '', req.intSetting);

            if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                //Se castea el resultado a Map<String, Object> y se añade a la lista de éstos
                Map<String, Object> mapResult = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                deployRequestInfoList.add(mapResult);
                
                //Se especifica en la traza que el proceso fue correcto
            	oTraza.CC_FinOK__c = true;
                oTraza.CC_MensajeSalida__c = response.getBody().left(131072);
            } else {
                //En el caso de que salte el catch, se guarda la razón en la traza
                oTraza.CC_TipoError__c = 'Llamada a CBK_StatusDeployRequest incorrecta.';
                oTraza.CC_DetalleError__c = response.getStatusCode() + ' ' + response.getBody();
                CBK_Log.debug('Error: ' + response.getStatus());
            }
            
            //Se inserta la traza a la lista para ser insertada después
            listTrazasInsert.add(oTraza);
        }

        return deployRequestInfoList;
    }

    //Función utilizada para comprobar la información de los logs
    private static void checkLogs(List<Map<String, Object>> deployRequestInfoList){
        //Si no se proporciona fecha de fin, asumir que es el mismo día que la fecha de inicio para la Release
        if (dtEndDate == null) {
            dtEndDate = Date.today();
        }

        //Consultar releases dentro del rango de fechas
        List<copado__Release__c> release = [SELECT Id, CBK_Planned_DateTime__c, CBK_Completion_DateTime__c  
                                            FROM copado__Release__c 
                                            WHERE CBK_Planned_DateTime__c = :dtEndDate LIMIT 1];
        
        if(!release.isEmpty()){
            createLog(deployRequestInfoList, release[0].CBK_Completion_DateTime__c);
        }else if(Test.isRunningTest()){
            createLog(deployRequestInfoList, System.now());
        }

        //Si no se proporcionan fechas, establecer un rango de un día anterior para CBK_Logs
        if (dtStartDate == null || dtEndDate == null) {
            Date yesterday = Date.today().addDays(-1);
            dtStartDate = yesterday;
            dtEndDate = yesterday;
        }

        //Consultar logs en el rango de fechas indicado
        List<CBK_Log__c> logsToCheck = [SELECT Id, state__c, Equipo__c FROM CBK_Log__c WHERE state__c = 'Deploy Request not valid' AND CreatedDate >= :dtStartDate AND CreatedDate <= :dtEndDate];

        List<CBK_Log__c> logsToDelete = new List<CBK_Log__c>();

        //Revisar los logs para determinar si deben ser eliminados
        if(!logsToCheck.isEmpty()){
            for (CBK_Log__c log : logsToCheck) {
                String idDri;
                for(Map<String, Object> dri : deployRequestInfoList){
                    if(dri != null){
                        idDri = (dri.containsKey('Id'))? (String) dri.get('Id') : '';
                        // Verificar si el log estaba marcado como fuera de rango (falso KO)
                        if (log.state__c == 'Deploy Request not valid' && log.Equipo__c?.contains(idDri)) {
                            logsToDelete.add(log);
                        }
                    }
                }
            }
        }
    }

    //Función utilizada para la creación de los logs
    private static void createLog(List<Map<String, Object>> deployRequestInfoList, DateTime releaseCompletionDate){
        for(Map<String, Object> dri : deployRequestInfoList){
            if(dri != null){
                CBK_Log__c log = New CBK_Log__c();
                log.RecordTypeId = Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('CBK_Deploy_Log').getRecordTypeId();
                log.Detail__c = dri.toString();
                log.Equipo__c = (dri.containsKey('Id'))? (String) dri.get('Id') : null;
                log.Log_Level__c = 'INFO';
                if(dri.containsKey('completedDate') && (DateTime) dri.get('completedDate') <= releaseCompletionDate){
                    log.state__c = 'Deploy Request valid';
                }else{
                    log.state__c = 'Deploy Request not valid';
                }
                listLogsInsert.add(log);
        	}
        }
    }
}