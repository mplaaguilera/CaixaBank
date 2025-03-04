/**********************************************************************************************************************
 Name:	  CBK_RequestedDeployments_Schedule
 Copyright © 2024  CaixaBank
------------------------------------------------------------------------------------------------
Propósito: Schedulable diario que compruebe los deployments realizados y revise si se han subido por copado
------------------------------------------------------------------------------------------------
Historial
---------------------
	VERSION		USER_STORY	        AUTHOR		   		DATE				Description
	1.0			US868474		    Jose Manuel   		17/10/2024		    Init version
***********************************************************************************************************************/
public with sharing class CBK_RequestedDeployments_Schedule extends CBK_SCH_Queueable_Abstract{

    private static DateTime now = System.now();
    private static final String ORG_ID = UserInfo.getOrganizationId();
    private static final Organization ORG = [SELECT IsSandbox FROM Organization];
    private static List<CC_TrazaInt__c> listTrazas = new List<CC_TrazaInt__c>();
    
    public override void execute(QueueableContext qc){
        CC_TrazaInt__c oTraza = new CC_TrazaInt__c(); //Creación de la traza para control de WS
        oTraza.Name = 'CBK_RequestedDeployments_Schedule';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_FinOK__c = false;
        String sSessionId = UserInfo.getSessionId();
        oTraza.CC_Identificador__c = (String.isNotBlank(sSessionId) && sSessionId.length() > 100)? sSessionId.substring(0, 99) : sSessionId;

        try{
            //Se procesan las entradas de CBK_SCH_PendingProcess (normalmente, solamente debería ser una, así que se procesa solamente la primera de la lista informada)
            work(this.lstInfoProcess[0]);

            //Se planifican nuevos Queueables            	
            AsyncOptions asyncOptions = new AsyncOptions();
            asyncOptions.DuplicateSignature = QueueableDuplicateSignature.Builder()
                .addId(UserInfo.getUserId())
                .build();
            Type typeProcessAction = Type.forName('CBK_RequestedDeployments_Schedule');
            CBK_SCH_Queueable_Abstract processAction = (CBK_SCH_Queueable_Abstract) typeProcessAction.newInstance();
            processAction.lstInfoProcess = this.lstInfoProcess;
            if(!Test.isRunningTest()){
                System.enqueueJob(processAction, asyncOptions);	
            }

            //Se especifica en la traza que el proceso fue correcto
            oTraza.CC_FinOK__c = true;
        }catch(Exception e){
            //En el caso de que salte el catch, se guarda la razón en la traza
            oTraza.CC_TipoError__c = 'Error revisar/programar revisión subidas.';
            oTraza.CC_DetalleError__c = e.getMessage() + ' ' + e.getStackTraceString();
        }		
        
        //Inserción de las trazas (incluyendo la del servicio)
        oTraza.CC_FechaFin__c = Datetime.now();
        listTrazas.add(oTraza);
        insert listTrazas;
    }

    private void work(CBK_SCH_PendingProcess__c incomingPendingProcess){
        //Se recorre la lista para ponerles el startDate y endDate
        Datetime startDate = (String.isNotBlank(incomingPendingProcess.Param1__c))? Datetime.valueOf(incomingPendingProcess.Param1__c) : null;
        Datetime endDate = (String.isNotBlank(incomingPendingProcess.Param2__c))? Datetime.valueOf(incomingPendingProcess.Param2__c) : null;
        Set<String> depReqIds = formToolingQuery(startDate, endDate);

        //Se genera la fecha de mañana para el reprogramado, y se reprograma
        if(depReqIds != null && !depReqIds.isEmpty()){
            Datetime dtTomorrow = now.addDays(1);
            CBK_ScheduleProcess_Controller.updateRecordSchProcess(depReqIds, dtTomorrow, true);
        }
    } 

    //Método para formar el WHERE
    public static Set<String> formToolingQuery(Datetime startDate, Datetime endDate){
        //IDs a retornar para el reprogramado
        Set<String> depReqIds = new Set<String>();

        //Se genera la query a partir de las fechas entradas por parámetro
        String baseQuery = 'SELECT+Id,CreatedDate+from+DeployRequest+where+';
        if (!ORG.IsSandbox || Test.isRunningTest()){
            if(startDate == null && endDate == null){
                baseQuery += 'CreatedDate=YESTERDAY+OR+CreatedDate=TODAY';
            }else{
                if(startDate != null){
                    baseQuery += 'CreatedDate>=' + datetimeToStringToolingAPI(startDate) + '+';
                    if(endDate != null){
                        baseQuery += 'AND+';
                    }
                }
                if(endDate != null){
                    baseQuery += 'CreatedDate+<=+' + datetimeToStringToolingAPI(endDate) + '+';
                }
            }
            baseQuery += 'ORDER+BY+CreatedDate+DESC';

            //Se accede a los registros
            Map<String, Object> mapResultToolingApiQuery = CBK_ToolingApiQuery.getInfo(baseQuery, false);
            
            //Se recupera la traza de la llamada a ToolingAPI, y se quita del Map
            if(mapResultToolingApiQuery.containsKey('TrazaInt') && mapResultToolingApiQuery.get('TrazaInt') != null){
                listTrazas.add((CC_TrazaInt__c)mapResultToolingApiQuery.get('TrazaInt'));
                mapResultToolingApiQuery.remove('TrazaInt');
            }
            
            if(mapResultToolingApiQuery != null && !mapResultToolingApiQuery.isEmpty() && mapResultToolingApiQuery.containsKey('records')){
                List<Object> listRecords = (List<Object>) mapResultToolingApiQuery.get('records');
                for (Object record : listRecords) {
                    Map<String, Object> recordMap = (Map<String, Object>) record;
                    depReqIds.add((String) recordMap.get('Id'));
                }
                checkDeployCopado(depReqIds, startDate, endDate);
            }
        }

        //Retorno de los depReqIds para el reprogramado
        return depReqIds;
    }

    //Método para comprobar los deployments realizados, revise si se han subido por copado y si está dentro de la ventana de subida
    private static void checkDeployCopado(Set<String> depReqIds, Datetime startDate, Datetime endDate){
        List<CBK_Log__c> logstoInsert = new List <CBK_Log__c>();
        List<Map<String, Object>> deployRequestInfoList = new List<Map<String, Object>>();
        Set<String> prodReqIds = new Set<String>();

        List <copado__Deployment_Job__c> jobsList = [SELECT Id, copado__Destination_Org__c FROM copado__Deployment_Job__c WHERE copado__Async_Job_ID__c IN :depReqIds];

        if(!jobsList.isEmpty()){
            for(copado__Deployment_Job__c job : jobsList){
                if(job.copado__Destination_Org__c == ORG_ID){
                    prodReqIds.add(job.copado__Async_Job_ID__c);
                }
            }
        }else if(Test.isRunningTest()){
            prodReqIds = depReqIds;
        }

        //Se llama al batch que procesará por lotes cada uno de los DeployRequest
        CBK_Config__mdt mdtDeployRequestBatchSize = CBK_Config__mdt.getInstance('CBK_RequestedDeploymentsBatchSize');
        Integer iBatchSize = (mdtDeployRequestBatchSize != null && mdtDeployRequestBatchSize.CBK_Paramertro1__c != null)? Integer.valueOf(mdtDeployRequestBatchSize.CBK_Paramertro1__c) : 10;
        Database.executeBatch(new CBK_RequestedDeployments_Batch(prodReqIds, startDate, endDate), iBatchSize);
    }

    //Función utilizada para convertir un Datetime en un String en el formato necesario para la query de ToolingAPI
    private static String datetimeToStringToolingAPI(Datetime dtDatetime){
        //Se convierte el Datetime en String en el formato 'yyyy-MM-ddTHH:mm:ss.SSS+'
        return dtDatetime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }
}