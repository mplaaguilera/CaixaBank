/**
 * @description Framework de procesos Apex Batch
 * executeBatch   : Solicitud de Ejecución de Batch
 * schedulleBatch : Solicitud de Planificación de Batch
 * statusBatch	  : Validación de jobs en ejecución
 * runBatches     : Proceso periódico que selecciona los batches a ejecutar
 * runBatch		  : Ejecución de proceso Batch 
 * statusBatch	  : Validación de jobs en ejecución
 * nextExecution  : Cálculo de fecha de próxima ejecución
 * findProject	  : Identificación del project
 * findProjectName: Identificación del project name
 * BatchProcessConfig : Wrapper Class
 * BatchProcessConfigBuilder : Wrapper Class Builder
 */
public with sharing class CBK_BatchJob{
     /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(String className){
        return new BatchProcessConfigBuilder(className)
            .execute();
    }
    
    /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param priority  : Tamaño del Batch
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(String className,Integer priority){
        return new BatchProcessConfigBuilder(className)
            .setPriority(priority)
            .execute();
    }
    
     /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param priority   : Orden de ejecución (0=inmediata)
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(String className, Integer batchSize,Integer priority){
        return new BatchProcessConfigBuilder(className)
            .setBatchSize(batchSize)
            .setPriority(priority)
            .execute();
    }    
    

    /**
     * @description Planificación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : Map de parámetros de entrada al Batch
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(String className, Integer batchSize, Map<String,Object> params){
        return new BatchProcessConfigBuilder(className)
            .setBatchSize(batchSize)
            .setParams(JSON.serialize(params))
            .execute();
    }
    
    /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : Map de parámetros de entrada al Batch
     * @param priority   : Orden de ejecución (0=inmediata)
	 * @return Resultado : Id del Job planificado. 
     */
     public static Id executeBatch(String className, Integer batchSize, Map<String,Object> params,Integer priority){
        return new BatchProcessConfigBuilder(className)
            .setBatchSize(batchSize)
            .setParams(JSON.serialize(params))
            .setPriority(priority)
            .execute();
    }

     /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(String className,String userContext){
        return new BatchProcessConfigBuilder(className)
            .setUserContext(userContext)
            .execute();
    }
    
    /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param priority  : Tamaño del Batch
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(String className,Integer priority,String userContext){
        return new BatchProcessConfigBuilder(className)
            .setPriority(priority)
            .setUserContext(userContext)
            .execute();
    }
    
     /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param priority   : Orden de ejecución (0=inmediata)
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(String className, Integer batchSize,Integer priority,String userContext){
        return new BatchProcessConfigBuilder(className)
            .setBatchSize(batchSize)    
            .setPriority(priority)
            .setUserContext(userContext)
            .execute();
    }    
    

    /**
     * @description Planificación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : Map de parámetros de entrada al Batch
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(String className, Integer batchSize, Map<String,Object> params,String userContext){
        return new BatchProcessConfigBuilder(className)
            .setBatchSize(batchSize)
            .setParams(JSON.serialize(params))
            .setUserContext(userContext)
            .execute();
    }    

    /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : Map de parámetros de entrada al Batch
     * @param priority   : Orden de ejecución (0=inmediata)
     * @param userContext   : Usuario de contexto de ejecución
	 * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(String className, Integer batchSize, Map<String,Object> params,Integer priority,String userContext){
        return new BatchProcessConfigBuilder(className)
            .setBatchSize(batchSize)
            .setParams(JSON.serialize(params))
            .setPriority(priority)
            .setUserContext(userContext)
            .execute();
    }

    /**
     * @description Planifcación de Batch desde invocación future Apex. Solventa problemática de Mixed DML
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : String de parámetros de entrada al Batch	 
     */
    @Future
    public static void executeBatchFuture(String className, Integer batchSize, String params){
        new BatchProcessConfigBuilder(className)
            .setBatchSize(batchSize)
            .setParams(params)
            .execute();
    }

    /**
    * @description Planifcación de Batch desde invocación future Apex con usuario de contexto. Solventa problemática de Mixed DML
    * @param className  : Clase Batch a ejecutar/planificar 
    * @param batchSize  : Tamaño del Batch
    * @param params     : String de parámetros de entrada al Batch	 
    * @param userContext : Usuario de contexto para la ejecución
    */
    @Future
    public static void executeBatchFutureContext(String className, Integer batchSize, String params, String userContext){
        new BatchProcessConfigBuilder(className)
            .setBatchSize(batchSize)
            .setParams(params)
            .setUserContext(userContext)
            .execute();
    }

     /**
     * @description Validación de jobs en ejecución 
     */
    public static void statusBatch(){
        Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Async_Apex_Job').getRecordTypeId();

        // Fetch all Running Jobs
        list<CBK_Framework_Batch__c> lstJobs = [SELECT Id,status__c,proyecto__c,Class_Name__c,BatchSize__c,RunningJobId__c, 
                                                       Tipo__c, params__c, priority__c,Tipo_de_periodicidad__c, Periodicidad__c, 
                                                       Calc_NextExec__c ,LastExec_Ini__c,LastExec_End__c,LastExec_Sched__c,NextExec__c,
                                                       Lunes__c,Martes__c,Miercoles__c,Jueves__c,Viernes__c,Sabado__c,Domingo__c,Activo__c,
                                                	   Email_Notif__c, Notif__c,Dependencia__r.name,JobPath__c, CBK_PublishedEventDate__c,CBK_ExecutedEventDate__c
                                                FROM CBK_Framework_Batch__c
                                				WHERE RunningJobId__c != null
                              					AND status__c NOT IN ('Aborted','Completed','Failed','')];
        
        list<Id> lstIds = new list<Id>();
        for (CBK_Framework_Batch__c job : lstJobs){
            lstIds.add(job.RunningJobId__c);
        }

        // Fetch all Running AsyncApexJob
        list<AsyncApexJob> lstAJobs = [SELECT Id,createddate,CompletedDate, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors ,ExtendedStatus
                                         FROM AsyncApexJob WHERE Id in :lstIds];
        Map<Id,AsyncApexJob> mAJob = new Map<Id,AsyncApexJob>();
        for (AsyncApexJob aJob : lstAJobs){
            mAJob.put(aJob.Id,aJob);
        }
		
        AsyncApexJob aJob ;
        list<CBK_Log__c> lstDetail = new list<CBK_Log__c>();
        for (CBK_Framework_Batch__c job : lstJobs){
            aJob = mAJob.get(job.RunningJobId__c);
            if (aJob!=null){
                job.Status__c = aJob.Status;
                job.Orden__c = 0;
                if ((aJob.Status == 'Aborted')||(aJob.Status == 'Completed')||(aJob.Status == 'Failed')||(Test.isRunningTest())){
                    if (job.proyecto__c == null) {
                        job.proyecto__c = CBK_BatchJob_Helper.findProjectName(job.Class_Name__c);
                    }
                    if (job.BatchSize__c == null) {
                        job.BatchSize__c = 200;
                    }                
    
                    job.LastExec_Ini__c = aJob.createddate;
                    job.LastExec_End__c = aJob.CompletedDate;              
                    job.LastExec_Sched__c = Job.NextExec__c;
                    job.LastExec_Status__c = aJob.Status;
                    job.Status__c = 'Queued';
                    job.RunningJobId__c='';
                    job.CBK_PublishedEventDate__c = null;
                    job.CBK_ExecutedEventDate__c = null;
                    job.Orden__c=null;
                    if (job.Tipo__c == 'Puntual'){
                        job.NextExec__c = null;
                        job.Status__c = 'Completed';
                        job.Activo__c = false;
                    } else {
                        CBK_BatchJob_Helper.nextExecution(job);
                    } 

                    // Create new Log record
                    CBK_Log__c detail = new CBK_Log__c ();    
                    detail.recordtypeId = recordTypeId;
                    detail.FwkJobId__c = Job.Id;
                    detail.Apex_Class__c=job.Class_Name__c;
                    detail.state__c = aJob.Status;
                    detail.batchSize__c=job.BatchSize__c;
                    detail.JobItemsProcessed__c=aJob.JobItemsProcessed;
                    detail.TotalJobItems__c=aJob.TotalJobItems;
                    detail.NumberOfErrors__c=aJob.NumberOfErrors;
                    detail.Job_Id__c = aJob.Id;
                    detail.params__c = String.valueOf(Job.params__c);
                    detail.jobType__c = Job.tipo__c;
                    detail.priority__c = Job.priority__c;
                    detail.createdDate__c = aJob.createddate;
                    detail.systemModstamp__c = aJob.CompletedDate;
                    detail.project__c = job.proyecto__c;
                    detail.Log_Message__c = aJob.ExtendedStatus;
                    lstDetail.add(detail);
                }
            }
        }
        
        update lstJobs;
        insert lstDetail;
    }

     /**
     * @description Validación de jobs en ejecución 
     */
    public static void reschedulledJobs(){
        //Se recoge el nº de minutos a añadir para ser utilizados en la búsqueda de PublishedEventDate; en el caso que la configuración no exista, será 3 por defecto
        CBK_Config__mdt mdtPublishedTimeCheck = CBK_Config__mdt.getInstance('PublishedTimeCheckMinutes');
        Integer iPublishedTimeCheckMinutes = (mdtPublishedTimeCheck != null && mdtPublishedTimeCheck.CBK_Active__c && String.isNotBlank(mdtPublishedTimeCheck.CBK_Paramertro1__c))? Integer.valueOf(mdtPublishedTimeCheck.CBK_Paramertro1__c) : 3;
		Datetime dtPublishedTimeCheck = System.now().addMinutes(iPublishedTimeCheckMinutes);        
        list<CBK_Framework_Batch__c> lstJobs = [SELECT Id,status__c,proyecto__c,Class_Name__c,BatchSize__c,RunningJobId__c,
                                                Tipo__c, params__c, priority__c,Tipo_de_periodicidad__c, Periodicidad__c, 
                                                Calc_NextExec__c ,LastExec_Ini__c,LastExec_End__c,LastExec_Sched__c,NextExec__c,
                                                Lunes__c,Martes__c,Miercoles__c,Jueves__c,Viernes__c,Sabado__c,Domingo__c,Activo__c,
                                                Email_Notif__c, Notif__c,Dependencia__r.name,JobPath__c,CBK_PublishedEventDate__c,CBK_ExecutedEventDate__c
                                                FROM CBK_Framework_Batch__c
                                                WHERE RunningJobId__c =null
                                                AND Activo__C=true
                                                AND(NextExec__c=null OR (CBK_PublishedEventDate__c > :dtPublishedTimeCheck AND CBK_ExecutedEventDate__c = null))
                                            	LIMIT 1000];
        
        for (CBK_Framework_Batch__c job : lstJobs){
                if (job.Tipo__c == 'Puntual'){
                job.NextExec__c = null;
                if ((job.Status__c == 'Aborted')||(job.Status__c == 'Completed')||(job.Status__c == 'Failed')||(Test.isRunningTest())){
                    job.Activo__c=false;
                    } 
            } else if (job.NextExec__c == null) {
                CBK_BatchJob_Helper.nextExecution(job);
                job.Status__c = 'Queued';
            } else {
                job.CBK_PublishedEventDate__c = null;
                job.CBK_ExecutedEventDate__c = null;
            }
        }
        update lstJobs;
    }    
    
     /**
     * @description Limpieza de Orden de Batch
     */
    public static void cleanBatchOrder (){
        
        list<CBK_Framework_Batch__c> lstJobs = [SELECT Id,Orden__c,RunningJobId__c
                                                FROM CBK_Framework_Batch__c
                                                WHERE Orden__c!=null
                                                AND Orden__c!=0]; 
    
        for (CBK_Framework_Batch__c job : lstJobs ){
            job.Orden__c=null;
        }
        update lstJobs;
    }
     
     /**
     * @description Selección de Orden de ejecución
     */    
    public static void batchOrder (){
        list<CBK_Framework_Batch__c> lstJobs = [SELECT Id,Orden__c,Name,Dependencia__r.Name,JobPath__c
                                                FROM CBK_Framework_Batch__c
                                                WHERE Activo__c = true
                                                AND NextExec__c != null 
                                                AND RunningJobId__c = null
                                                ORDER BY NextExec__c asc,priority__c ASC
                                                LIMIT 1000]; 
		
        Map<String,String> mapHierJobs= new Map<String,String>();
        
        list<CBK_Framework_Batch__c> lstJobsDef = [SELECT Id,Orden__c,Name,Dependencia__r.Name,JobPath__c
                                                    FROM CBK_Framework_Batch__c
                                                    WHERE Tipo__c!='Puntual'
                                                    LIMIT 1000]; 
        
        for (CBK_Framework_Batch__c job :lstJobsDef ){
            mapHierJobs.put(job.Name,job.Dependencia__r.Name);
        }
        
        Boolean continuar;
        String path;
        String item;
        String nextItem;
        for (CBK_Framework_Batch__c job :lstJobs ){
         	continuar=true;
            path=job.Name;
            item = mapHierJobs.get(job.Name);
            while(item!=null){
                path = item + '.' + path;
                nextItem=mapHierJobs.get(item);
            	item=nextItem;
            }
            job.JobPath__c = path.left(255);
        }
        update lstJobs;
        
        lstJobs = [SELECT Id,Orden__c,Name,Dependencia__r.Name, Class_Name__c,JobPath__c
					FROM CBK_Framework_Batch__c
                    WHERE Activo__c = true
                    AND NextExec__c != null 
                    AND RunningJobId__c = null
                    ORDER BY NextExec__c asc,priority__c asc,JobPath__c ASC
                    LIMIT 1000]; 

        
        
        Integer n=1;
        for (CBK_Framework_Batch__c job :lstJobs ){
            job.proyecto__c = CBK_BatchJob_Helper.findProjectName(job.Class_Name__c);
        	job.Orden__c=n;
            n++;
        }
        
        update lstJobs;
    }       
    
     /**
     * @description Planifcación de Batch desde invocación externa Apex 
     * @param batchName  : Alias del proceso Batch 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : Parñametros de entrada al proceso batch en formato map
     * @param sysTime    : Fecha solicitada de ejecución
     * @return Resultado : Para Ejecución inmediata Id del Job planificado. 
     *                     Para ejecución planificada Id del registro en CBK_Framework_Batch__c
     */
    public static Id schedulleBatch (String batchName, String className, Integer batchSize, map<String,Object> params, Datetime sysTime){    
        return schedulleBatch(new BatchProcessConfigBuilder(className)
            .setBatchName(batchName)
            .setBatchSize(batchSize)
            .setParams(String.valueOf(params))
            .setNextExec(sysTime)
            .buildProcessConfig());
    }

     /**
     * @description Planifcación de Batch desde invocación externa Apex 
     * @param myInstance  : Wrapper of BatchProcessConfig
     * @return Resultado : Para Ejecución inmediata Id del Job planificado. 
     *                     Para ejecución planificada Id del registro en CBK_Framework_Batch__c
     */
    public static Id schedulleBatch (BatchProcessConfig myInstance){    
        Id batchprocessid;

        //Identificación del Batch
        CBK_Framework_Batch__c jobDef;
        try {
                //Alta del Batch
                jobDef = new CBK_Framework_Batch__c(Name=myInstance.getBatchName(),
                                                    Class_Name__c= myInstance.getClassName());
                jobDef.tipo__c = 'Puntual';
                jobDef.Priority__c = 1;
                jobDef.NextExec__c = myInstance.getNextExec();
                jobDef.BatchSize__c = myInstance.getBatchSize();
                jobDef.params__c = myInstance.getParams();
                jobDef.proyecto__c = CBK_BatchJob_Helper.findProjectName(myInstance.getClassName());
                insert jobDef; 
                batchprocessid = jobDef.Id;
        } catch (Exception e) {
            CBK_BatchJob_Helper.errorJob(e, jobDef);
            throw(e); 
        }
        return batchprocessid;
    }
        
    /**
     * @description Ejecución de proceso Batch
     * @param className
     * @param batchSize
     * @param params paraámetros del batch 
     * @return JobId
     * 
	 */
    public static Id runBatch(String className, Integer batchSize, map<String,Object> params)  {
        return runBatch(new BatchProcessConfigBuilder(className)
            .setBatchSize(batchSize)
            .setParams(JSON.serialize(params))
            .buildProcessConfig());
    }
    
     /**
     * @description Ejecución de proceso Batch
     * @param myInstance  : Wrapper of BatchProcessConfig
     * @return JobId
     * 
	 */
    public static Id runBatch(BatchProcessConfig myInstance)  {
        ID batchprocessid;
        try {

            Type classInstance = Type.forName(myInstance.getClassName());
            Database.batchable<sObject> batch = (Database.batchable<sObject>)classInstance.newInstance();   
        	batch = (Database.Batchable<sObject>)JSON.deserialize(myInstance.getParams(), classInstance);

            if (myInstance.getBatchSize() == null) {
                batchprocessid = database.executeBatch(batch);
            } else {
                batchprocessid = database.executeBatch(batch, myInstance.getBatchSize());
            }
            
            AsyncApexJob aAj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                FROM AsyncApexJob 
                                WHERE ID =: batchprocessid];
            
        } catch (Exception e) {
            throw(e); 
        }
       return batchprocessid;
    }
    
     /**
     * @description Proceso periódico que selecciona los batches a ejecutar
     */
    public static void runBatches(){
        Datetime timer = system.now();

        list<CBK_Framework_Batch__c> lstJobDef = [SELECT Id,Name,status__c,Class_Name__c,batchSize__c,params__c,tipo__c,priority__c,proyecto__c,NextExec__c, Activo__c,
                                                	   Email_Notif__c, Notif__c,RunningJobId__c,dependencia__r.Name,JobPath__c,CBK_PublishedEventDate__c,CBK_ExecutedEventDate__c,
                                                  	   UsuarioContexto__c
                                                    FROM CBK_Framework_Batch__c 
                                                    WHERE runningJobId__c = null 
                                                    AND Activo__c = true
                                                    AND NextExec__c != null
                                                    AND NextExec__c <= :timer
                                                    AND CBK_PublishedEventDate__c = null
                                                    AND orden__c != null
                                                    ORDER BY orden__c asc
                                                    LIMIT 1000];
        
        list<AsyncApexJob> lstAsyncApexJob = [SELECT Id, ApexClass.Name 
                                                FROM AsyncApexJob 
                                                WHERE status NOT IN ('Aborted','Completed','Failed') 
                                                AND JobType='BatchApex'];
        
        //Recopilación de Running Jobs
        list<Id> lstRunningJobId = new list<Id>();
        for (AsyncApexJob aaj : lstAsyncApexJob){
            lstRunningJobId.add(aaj.Id);
        }
		list<CBK_Framework_Batch__c> lstRunningJobDef = [select Id, Name, Class_Name__c, RunningJobId__c, Proyecto__c,Tipo__c,dependencia__c,JobPath__c from CBK_Framework_Batch__c where RunningJobId__c in :lstRunningJobId];
        Map<Id,CBK_Framework_Batch__c> mapRunningJobDef = new Map<Id,CBK_Framework_Batch__c>();
        for (CBK_Framework_Batch__c job : lstRunningJobDef){
            mapRunningJobDef.put(job.RunningJobId__c,job);
        }
        
        list<CBK_BatchJob_Helper.batchJob> lstRunning = new list<CBK_BatchJob_Helper.batchJob>();
        for (AsyncApexJob aaj : lstAsyncApexJob){
			CBK_BatchJob_Helper.batchJob bj = new CBK_BatchJob_Helper.batchJob();
            bj.jobId=aaj.id;
            bj.batchName=mapRunningJobDef.get(aaj.Id)?.Name;
            bj.className=aaj.ApexClass.Name;
            bj.tipo=mapRunningJobDef.get(aaj.Id)?.Tipo__c;
            bj.Project=mapRunningJobDef.get(aaj.Id)?.Proyecto__c;   
            bj.dependencia=mapRunningJobDef.get(aaj.Id)?.dependencia__c;   
            bj.jobPath=mapRunningJobDef.get(aaj.Id)?.JobPath__c;
            lstRunning.add(bj);
        }

		Id batchprocessid;
        Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Async_Apex_Job').getRecordTypeId();
        list<CBK_Log__c> lstDetail = new list<CBK_Log__c>();

        list<Id> lstJobId = new list<Id>();
        Map<Id,String> mapStatus = new Map<Id,String>();
        Map<String,list<String>> mapConext = new Map<String,list<String>>();
        list<String> contextJobs;
        
        //Se utiliza este Integer para contar el nº de ejecuciones directas para que no superen las 50
        Integer iNumOfDirectExecutions = 0;

        //Inclusión de nuevos JOBS
        for (CBK_Framework_Batch__c jobDef : lstJobDef) {
            Boolean executed = true;
            try {
                if (CBK_BatchJob_Helper.jobEjecutable(jobDef,lstRunning)){     
                    executed = false;
                    
                    map<String,Object> params = new map<String,Object>();
                    if(jobDef.params__c!=null){
                        //params= (map<String,Object>)JSON.deserialize(jobDef.params__c, map<String,Object>.class);  
                        params = (Map<String, Object>)JSON.deserializeUntyped(jobDef.params__c);
                    }

                    if (jobDef.UsuarioContexto__c==null){
                        if(iNumOfDirectExecutions <= 50) {
                            //Ejecución directa
                            batchprocessid = runBatch(jobDef.Class_Name__c, (Integer)jobDef.batchSize__c, params);
                            lstJobId.add(batchprocessid);
                            jobDef.RunningJobId__c=batchprocessid; 
                            iNumOfDirectExecutions++;
                            executed = true;
                        }
                    } else {
                        //Ejecución por Platform Events
                        String userPlatformEvent = 'CBK_Context_' + jobDef.UsuarioContexto__c + '__e';
                        if (mapConext.containsKey(userPlatformEvent)){
                            contextJobs = mapConext.get(userPlatformEvent);
                        } else{
                            contextJobs = new list<String>();
                        }
                        contextJobs.add(jobDef.Id);
                        mapConext.put(userPlatformEvent, contextJobs);
                        executed = true;
                    }
                
                    if (executed){
                        CBK_BatchJob_Helper.batchJob bj = new CBK_BatchJob_Helper.batchJob();
                        bj.batchName=jobDef.Name;
                        bj.className=jobDef.Class_Name__c;
                        bj.tipo=jobDef.Tipo__c;
                        bj.Project=jobDef.Proyecto__c;   
                        bj.dependencia = jobDef.dependencia__r.Name;
                        bj.JobPath = jobDef.JobPath__c;
                        
                        lstRunning.add(bj);
                    }
                    
                    if (jobDef.NextExec__c==null) {
                        jobDef.NextExec__c=DateTime.now();
                    }
                }
            } catch (Exception e) {
                CBK_BatchJob_Helper.errorJob(e, jobDef);
                
                CBK_Log__c detail = new CBK_Log__c ();    
                detail.recordtypeId = recordTypeId;
                detail.FwkJobId__c = jobDef.Id;
                detail.Apex_Class__c=jobDef.Class_Name__c;
                detail.state__c = 'Error';
                detail.batchSize__c=jobDef.BatchSize__c;
                detail.params__c = jobDef.params__c;
                detail.jobType__c = jobDef.tipo__c;
                detail.priority__c = jobDef.priority__c;
                detail.project__c = jobDef.proyecto__c;
                detail.Log_Message__c = e.getMessage()?.left(2000);
                detail.createdDate__c = System.now();
                detail.systemModstamp__c = System.now();
                lstDetail.add(detail);
                
                if(jobDef.Tipo__c=='Puntual'){      
                    jobDef.NextExec__c=null;
                    jobDef.status__c='Error';
                }
                
            }
        }

        list<AsyncApexJob> lstStatus = [SELECT Id, Status 
                                        FROM AsyncApexJob 
                                        WHERE ID =: lstJobId];
        
        for (AsyncApexJob iStatus : lstStatus){
            mapStatus.put(iStatus.Id,iStatus.Status);
        }
        
        for (CBK_Framework_Batch__c jobDef : lstJobDef) {
            if (jobDef.RunningJobId__c!=null){
            	jobDef.status__c=mapStatus.get(jobDef.RunningJobId__c);     
            }
        }
        update lstJobDef;
        insert lstDetail;

        //Lista de entradas de CBK_Framework_Batch__c a actualizarles el PublishedEventDate__c
        List<CBK_Framework_Batch__c> listJobDefUpdate = new List<CBK_Framework_Batch__c>();
        
        //insert Platform Events
        //Insertamos platform events a posteriori para evitar bloqueo
        List<sObject> listPlatformEvents = new List<sObject>();
        for (String userPlatformEvent : mapConext.keySet()) {            
            for (String jobItem : mapConext.get(userPlatformEvent)){
                Type tipoObjeto = Type.forName(userPlatformEvent);
                // Verificar si el tipo de objeto es válido
                if (tipoObjeto != null && tipoObjeto.newInstance() instanceof sObject) {
                    // Instanciar el objeto utilizando el tipo
                    sObject evento = (sObject) tipoObjeto.newInstance();
                    evento.put('JobId__c', jobItem);
                    evento.put('Tipo__c', 'BatchProcess');
                    
                    //Se crea nueva instancia de CBK_Framework_Batch__c para ponerle el tiempo de publicación, para actualizarla después
                    CBK_Framework_Batch__c oJobDefUpdate = new CBK_Framework_Batch__c();
                    oJobDefUpdate.Id = jobItem;
                    oJobDefUpdate.CBK_PublishedEventDate__c = System.now();
                    listJobDefUpdate.add(oJobDefUpdate);

                    listPlatformEvents.add(evento);
                }                
            }
        }
        EventBus.publish(listPlatformEvents);

        //Se actualizan las entradas de CBK_Framework_Batch__c
        if(!listJobDefUpdate.isEmpty()){
            Database.update(listJobDefUpdate, false);
        }
    }

    // Wrapper Class (Inmutable)
    public class BatchProcessConfig  {

        // Atributos privados
        private BatchProcessConfigBuilder builder;        

        // Constructor privado
        private BatchProcessConfig (BatchProcessConfigBuilder builder) {
            this.builder = builder;
        }

        // Getters
        public BatchProcessConfigBuilder getBuilder() {return builder; }
        public String getType() { return builder.getType(); }
        public String getUserContext() { return builder.getUserContext(); }
        public Datetime getNextExec() { return builder.getNextExec(); }
        public Integer getPriority() { return builder.getPriority(); }
        public Integer getBatchSize() { return builder.getBatchSize(); }
        public String getParams() { return builder.getParams(); }
        public Boolean getNotifyErrors() { return builder.getNotifyErrors(); }
        public String getProject() { return builder.getProject(); }
        public String getNotificationEmail() { return builder.getNotificationEmail(); }
        public String getClassName() { return builder.getClassName(); }
        public String getBatchName() { return builder.getBatchName(); }
    }

    // Wrapper Class Builder (Mutable)
    public with sharing class BatchProcessConfigBuilder {
        private String type;
        private String userContext;
        private Datetime nextExec;
        private Integer priority;
        private Integer batchSize;
        private String params;
        private Boolean notifyErrors;
        private String project;
        private String notificationEmail;
        private String className;
        private String batchName;

        // Constructor
        public BatchProcessConfigBuilder (String className) {
            this.type = 'Puntual';
            this.userContext = '';
            this.nextExec = DateTime.now();
            this.priority = 1;
            this.batchSize = null;
            this.params = JSON.serialize(new map<String,Object>());
            this.className = className;
        }
        
        // Getters
        public String getType() { return type; }
        public String getUserContext() { return userContext; }
        public Datetime getNextExec() { return nextExec; }
        public Integer getPriority() { return priority; }
        public Integer getBatchSize() { return batchSize; }
        public String getParams() { return params; }
        public Boolean getNotifyErrors() { return notifyErrors; }
        public String getProject() { return project; }
        public String getNotificationEmail() { return notificationEmail; }
        public String getClassName() { return className; }
        public String getBatchName() { return batchName; }

        // Métodos del Builder para establecer los valores
        public BatchProcessConfigBuilder setClassName(String classname) {
            this.className = classname;
            return this;
        }

        public BatchProcessConfigBuilder setBatchName(String batchname) {
            this.batchName = batchname;
            return this;
        }

        public BatchProcessConfigBuilder setType(String type) {
            this.type = type;
            return this;
        }

        public BatchProcessConfigBuilder setUserContext(String userContext) {
            this.userContext = userContext;
            return this;
        }

        public BatchProcessConfigBuilder setNextExec(Datetime nextExec) {
            this.nextExec = nextExec;
            return this;
        }

        public BatchProcessConfigBuilder setPriority(Integer priority) {
            this.priority = priority;
            return this;
        }

        public BatchProcessConfigBuilder setBatchSize(Integer batchSize) {
            this.batchSize = batchSize;
            return this;
        }

        public BatchProcessConfigBuilder setParams(String params) {
            this.params = params;
            return this;
        }

        public BatchProcessConfigBuilder setNotifyErrors(Boolean notifyErrors) {
            this.notifyErrors = notifyErrors;
            return this;
        }

        public BatchProcessConfigBuilder setProject(String project) {
            this.project = project;
            return this;
        }

        public BatchProcessConfigBuilder setNotificationEmail(String notificationEmail) {
            this.notificationEmail = notificationEmail;
            return this;
        }

        //Método para ejecutar el batch con los datos del builder asignado al BatchProcessConfig
        public Id execute(){
            CBK_Framework_Batch__c jobDef;

            try {
                CBK_Framework_Batch_Apex__mdt conf = CBK_BatchJob_Helper.findProject(this.getClassName());

                //Alta del Batch
                jobDef = new CBK_Framework_Batch__c(Name=this.getClassName() + '_' + CBK_BatchJob_Helper.timestamp(),
                                                    Class_Name__c= this.getClassName());
                jobDef.tipo__c = this.getType();
                jobDef.UsuarioContexto__c = this.getUserContext();
                jobDef.Notif__c = this.getNotifyErrors() == null && conf != null ? conf.Notif__c : this.getNotifyErrors();
                jobDef.Proyecto__c = String.isBlank(this.getProject()) && conf != null ? conf.Proyecto__c : this.getProject();
                jobDef.Email_Notif__c = String.isBlank(this.getNotificationEmail()) && conf != null ? conf.Email_Notif__c : this.getNotificationEmail();
                jobDef.NextExec__c = this.getNextExec();
                jobDef.Priority__c = this.getPriority();
                jobDef.BatchSize__c = this.getBatchSize();
                jobDef.params__c = this.getParams();
                
                insert jobDef;
                    
            //Planificación inmediata del Batch   
                if (this.getPriority() == 0) {
                    BatchProcessConfig oBPC = new BatchProcessConfig(this);
                    Id batchprocessid = CBK_BatchJob.runBatch(oBPC);
                    AsyncApexJob aAj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                                            FROM AsyncApexJob 
                                            WHERE ID =: batchprocessid];
                    jobDef.RunningJobId__c = batchprocessid; 
                    jobDef.status__c = aAj.Status; 
                    jobDef.NextExec__c = DateTime.now();
                    jobDef.Orden__c = 0;

                    update jobDef;
                }

            } catch (Exception e) {
                CBK_BatchJob_Helper.errorJob(e,jobDef);
                throw(e); 
            }

            return jobDef.Id;
        }

        // Método build para crear una instancia de MyClass
        public BatchProcessConfig  buildProcessConfig() {
            // TODO VERIFY IF FIT'S TO THE BUSINESS REQUIEREMENT
            /*if (userContext == null || userContext == '') {
                throw new IllegalArgumentException('El usuario de contexto no puede ser vacio.');
            } else {*/
                return new BatchProcessConfig (this);
            /*}*/
        }
    }
}