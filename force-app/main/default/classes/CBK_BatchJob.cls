/**
 * @description Framework de procesos Apex Batch
 * executeBatch   : Solicitud de Ejecución de Batch
 * schedulleBatch : Solicitud de Planificación de Batch
 * statusBatch	  : Validación de jobs en ejecución
 * runBatches     : Proceso periódico que selecciona los batches a ejecutar
 * runBatch		  : Ejecución de proceso Batch 
 * statusBatch	  : Validación de jobs en ejecución
 * nextExecution  : Cálculo de fecha de próxima ejecución
 * findProject	  : Identificación del proyecto
 * timestamp	  : formateo de timestamp
 */
public with sharing class CBK_BatchJob{
     /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(string className){
        Id batchprocessid = executeBatch(className,null,new map<String,Object>(),1);
        return batchprocessid;
    }
    
    /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param priority  : Tamaño del Batch
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(string className,integer priority){
        Id batchprocessid = executeBatch(className,null,new map<String,Object>(),priority);
        return batchprocessid;
    }
    
     /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param priority   : Orden de ejecución (0=inmediata)
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(string className, integer batchSize,integer priority){
        Id batchprocessid = executeBatch(className,batchSize,new map<String,Object>(),priority);
        return batchprocessid;
    }    
    

    /**
     * @description Planificación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : Map de parámetros de entrada al Batch
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(string className, integer batchSize, map<String,Object> params){
        Id batchprocessid = executeBatch(className,batchSize,params,1);
        return batchprocessid;
    }
    
    /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : Map de parámetros de entrada al Batch
     * @param priority   : Orden de ejecución (0=inmediata)
	 * @return Resultado : Id del Job planificado. 
     */
     public static Id executeBatch(string className, integer batchSize, map<String,Object> params,integer priority){
        Id batchprocessid = executeBatch(className,batchSize,params,priority,'');
        return batchprocessid;
    }

     /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(string className,string userContext){
        Id batchprocessid = executeBatch(className,null,new map<String,Object>(),1,userContext);
        return batchprocessid;
    }
    
    /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param priority  : Tamaño del Batch
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(string className,integer priority,string userContext){
        Id batchprocessid = executeBatch(className,null,new map<String,Object>(),priority,userContext);
        return batchprocessid;
    }
    
     /**
     * @description Planifcación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param priority   : Orden de ejecución (0=inmediata)
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(string className, integer batchSize,integer priority,string userContext){
        Id batchprocessid = executeBatch(className,batchSize,new map<String,Object>(),priority,userContext);
        return batchprocessid;
    }    
    

    /**
     * @description Planificación de Batch desde invocación externa inmediata Apex 
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : Map de parámetros de entrada al Batch
     * @return Resultado : Id del Job planificado. 
     */
    public static Id executeBatch(string className, integer batchSize, map<String,Object> params,string userContext){
        Id batchprocessid = executeBatch(className,batchSize,params,1,userContext);
        return batchprocessid;
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
     public static Id executeBatch(string className, integer batchSize, map<String,Object> params,integer priority,string userContext){         
         Id batchprocessid;
		CBK_Framework_Batch__c jobDef;
        try {
            //Alta del Batch
            jobDef = New CBK_Framework_Batch__c(name=className + '_' + timestamp(),Class_Name__c= className);
            jobDef.tipo__c = 'Puntual';
            jobDef.UsuarioContexto__c = userContext;
            jobDef.NextExec__c=DateTime.now();
            jobDef.Priority__c = priority;
            jobDef.BatchSize__c = batchSize;
//            List<Object> lst_JsonParse = (List<Object>)Json.deserializeUntyped(Json string);
	        //jobDef.params__c=String.valueOf(params);
            jobDef.params__c = JSON.serialize(params);
            
            CBK_Framework_Batch_Apex__mdt conf =new CBK_Framework_Batch_Apex__mdt();
            jobDef.proyecto__c = CBK_BatchJob_Helper.findProject(className,conf);
            if (conf!=null) {
                jobDef.Notif__c= conf.Notif__c;
            	jobDef.Email_Notif__c= conf.Email_Notif__c;
            }
            
            insert jobDef; 
            
            //Planificación inmediata del Batch   
            if (priority==0) {
                batchprocessid = runBatch(className,batchSize,params);
                AsyncApexJob aAj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];
                jobDef.RunningJobId__c=batchprocessid; 
                jobDef.status__c=aAj.Status; 
                jobDef.NextExec__c=DateTime.now();
                jobDef.Orden__c=0;
                update jobDef;
            } else {
                batchprocessid = jobDef.Id;
            }
        } catch (Exception e) {
            CBK_BatchJob_Helper.errorJob(e,jobDef);
            throw(e); 
        }
        return jobDef.Id;
    } 
    /**
     * @description Planifcación de Batch desde invocación future Apex. Solventa problemática de Mixed DML
     * @param className  : Clase Batch a ejecutar/planificar 
     * @param batchSize  : Tamaño del Batch
     * @param params     : String de parámetros de entrada al Batch	 
     */
     @Future
     public static void executeBatchFuture(string className, integer batchSize, string params){
         Map<String, Object> params2 = (Map<String, Object>)JSON.deserializeUntyped(params);
         executeBatch(className,batchSize, params2,1);
    }

    /**
    * @description Planifcación de Batch desde invocación future Apex con usuario de contexto. Solventa problemática de Mixed DML
    * @param className  : Clase Batch a ejecutar/planificar 
    * @param batchSize  : Tamaño del Batch
    * @param params     : String de parámetros de entrada al Batch	 
    * @param userContext : Usuario de contexto para la ejecución
    */
    @Future
    public static void executeBatchFutureContext(string className, integer batchSize, string params, string userContext){
        Map<String, Object> params2 = (Map<String, Object>)JSON.deserializeUntyped(params);
        executeBatch(className,batchSize, params2,1, userContext);
    }

     /**
     * @description Validación de jobs en ejecución 
     */
    public static void statusBatch(){
        Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Async_Apex_Job').getRecordTypeId();
        list<CBK_Framework_Batch__c> lstJobs = [SELECT Id,status__c,proyecto__c,Class_Name__c,BatchSize__c,RunningJobId__c, 
                                                       Tipo__c, params__c, priority__c,Tipo_de_periodicidad__c, Periodicidad__c, 
                                                       Calc_NextExec__c ,LastExec_Ini__c,LastExec_End__c,LastExec_Sched__c,NextExec__c,
                                                       Lunes__c,Martes__c,Miercoles__c,Jueves__c,Viernes__c,Sabado__c,Domingo__c,Activo__c,
                                                	   Email_Notif__c, Notif__c,Dependencia__r.name,JobPath__c
                                                  FROM CBK_Framework_Batch__c
                                				 WHERE RunningJobId__c !=null
                              					   AND status__c not in ('Aborted','Completed','Failed','')];
        
        list<Id> lstIds = New list<Id>();
        for (CBK_Framework_Batch__c job : lstJobs){
            lstIds.add(job.RunningJobId__c);
        }

        list<AsyncApexJob> lstAJobs = [SELECT Id,createddate,CompletedDate, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors ,ExtendedStatus
                                         FROM AsyncApexJob where Id in :lstIds];
       Map<Id,AsyncApexJob> mAJob = New Map<Id,AsyncApexJob>();
        for (AsyncApexJob aJob : lstAJobs){
            mAJob.put(aJob.Id,aJob);
        }
		
        AsyncApexJob aJob ;
        list<CBK_Log__c> lstDetail = New list<CBK_Log__c>();
        for (CBK_Framework_Batch__c job : lstJobs){
            aJob = mAJob.get(job.RunningJobId__c);
            if (aJob!=null){
                job.Status__c = aJob.Status;
                job.Orden__c=0;
                if ((aJob.Status == 'Aborted')||(aJob.Status == 'Completed')||(aJob.Status == 'Failed')||(Test.isRunningTest())){
                    if (job.proyecto__c == null) {
                        job.proyecto__c = CBK_BatchJob_Helper.findProject(job.Class_Name__c);
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
                    job.Orden__c=null;
                    if (job.Tipo__c == 'Puntual'){
                        job.NextExec__c = null;
                        job.Status__c = 'Completed';
                        job.Activo__c = false;
                    } else {
                        CBK_BatchJob_Helper.nextExecution(job);
                    } 
                    CBK_Log__c detail = New CBK_Log__c ();    
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
        list<CBK_Framework_Batch__c> lstJobs = [SELECT Id,status__c,proyecto__c,Class_Name__c,BatchSize__c,RunningJobId__c,
                                                Tipo__c, params__c, priority__c,Tipo_de_periodicidad__c, Periodicidad__c, 
                                                Calc_NextExec__c ,LastExec_Ini__c,LastExec_End__c,LastExec_Sched__c,NextExec__c,
                                           	    Lunes__c,Martes__c,Miercoles__c,Jueves__c,Viernes__c,Sabado__c,Domingo__c,Activo__c,
                                                Email_Notif__c, Notif__c,Dependencia__r.name,JobPath__c
												  FROM CBK_Framework_Batch__c
                                				 WHERE RunningJobId__c =null
                                                   AND NextExec__c=null
                                                   AND Activo__C=true
                                               LIMIT 1000];

        
        for (CBK_Framework_Batch__c job : lstJobs){
            try{
                if (job.Tipo__c == 'Puntual'){
                    job.NextExec__c = null;
                    if ((job.Status__c == 'Aborted')||(job.Status__c == 'Completed')||(job.Status__c == 'Failed')||(Test.isRunningTest())){
                        job.Activo__c=false;
                        } 
                } else {
                    CBK_BatchJob_Helper.nextExecution(job);
                    //job.NextExec__c = CBK_BatchJob_Helper.nextExecution(job.Id);
                    job.Status__c = 'Queued';
                } 
            } catch (Exception e) {
                CBK_BatchJob_Helper.errorJob(e, job);
            	//throw(e); 
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
                                				 WHERE Activo__c=true
                                                   AND NextExec__c!=null 
                                               	   AND RunningJobId__c=null
                                                 ORDER BY NextExec__c asc,priority__c asc
                                               LIMIT 1000]; 
		
        Map<String,String> mapHierJobs= New Map<String,String>();
        
        list<CBK_Framework_Batch__c> lstJobsDef = [SELECT Id,Orden__c,Name,Dependencia__r.Name,JobPath__c
												  FROM CBK_Framework_Batch__c
                                				 WHERE Tipo__c!='Puntual'
                                               LIMIT 1000]; 
        
        for (CBK_Framework_Batch__c job :lstJobsDef ){
            mapHierJobs.put(job.Name,job.Dependencia__r.Name);
        }
        
        boolean continuar;
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
                                				 WHERE Activo__c=true
                                                   AND NextExec__c!=null 
                                               	   AND RunningJobId__c=null
                                                 ORDER BY NextExec__c asc,priority__c asc,JobPath__c asc
                                               LIMIT 1000]; 

        
        
        integer n=1;
        CBK_Framework_Batch_Apex__mdt conf =new CBK_Framework_Batch_Apex__mdt();
        for (CBK_Framework_Batch__c job :lstJobs ){
            job.proyecto__c = CBK_BatchJob_Helper.findProject(job.Class_Name__c,conf);
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
    public static Id schedulleBatch (string batchName, string className, integer batchSize, map<String,Object> params,Datetime sysTime){    
        Id batchprocessid;

        //Identificación del Batch
        CBK_Framework_Batch__c jobDef;
        try {
//            list<CBK_Framework_Batch__c> lstobDef = [Select Id from CBK_Framework_Batch__c where name=:batchName];
//            if (lstobDef.size()==0){ //CONTROLADO DESDE VALIDATION RULE
                //Alta del Batch
                jobDef = New CBK_Framework_Batch__c(name=batchName,Class_Name__c= className);
                jobDef.tipo__c = 'Puntual';
                jobDef.Priority__c = 1;
                jobDef.NextExec__c = sysTime;
                jobDef.BatchSize__c = batchSize;
                jobDef.params__c=String.valueOf(params);
                jobDef.proyecto__c = CBK_BatchJob_Helper.findProject(className);
                
                
                insert jobDef; 
//            } else {
//                //Error Job ya planificado
//                throw new applicationException('El Job ' + batchName + 'ya está planificado');
//            }
        
        } catch (Exception e) {
            CBK_BatchJob_Helper.errorJob(e, jobDef);
            throw(e); 
        }
        batchprocessid=jobDef.Id;
        return batchprocessid;
    }
        
    /**
     * @description Ejecución de proceso Batch
     * @param className
     * @param batchSize
     * @param params paraámetros del batch 
     * @return JobId
     * 
     *   EJEMPLO: 
     * 		map<String,Object> params = New map<String,Object>();
     * 		params.put('param1', 'test');
     * 		Id jobId=CBK_BatchJob.runBatch('Batch_Class',100,params);
     * 
	 */
    public static Id runBatch(string className, integer batchSize, map<String,Object> params)  {
        ID batchprocessid;
//        try {
            Type classInstance = Type.forName(className);
            //Database.Batchable<String> batch = (Database.Batchable<String>)classInstance.newInstance();
            Database.batchable<sObject> batch = (Database.batchable<sObject>)classInstance.newInstance();   
        
          	/*Map<String, Object> variableMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(batch));
			for (Id key : params.keySet()) {
                variableMap.set(key,emailDiseaseMap.get(key));
                List<String> toAddresses = emailDiseaseMap.get(key);
            }
			batch = (Database.Batchable<sObject>)JSON.deserialize(JSON.serialize(variableMap), classInstance);*/
        
        	batch = (Database.Batchable<sObject>)JSON.deserialize(JSON.serialize(params), classInstance);
            if (batchSize==null) {
                batchprocessid = database.executeBatch(batch);
            } else {
                batchprocessid = database.executeBatch(batch,batchSize);
            }
            cbk_log.debug(batchprocessid);
            
            AsyncApexJob aAj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: batchprocessid ];
            
/*       } catch (Exception e) {
           CBK_BatchJob_Helper.errorJob(Exception e, jobDef);
           throw(e); 
       }*/
       return batchprocessid;
    }
    
    /**
     * @description Formateo de fecha-hora
     * @return fecha hora en
     **/
    public static String timestamp() {
		return String.valueof(DateTime.now().getTime());
            //System.now().formatGmt('HH:mm:ss.SSS');
	}
    
     /**
     * @description Proceso periódico que selecciona los batches a ejecutar
     */
    public static void runBatches(){
        Datetime timer = system.now();

        list<CBK_Framework_Batch__c> lstJobDef = [select Id,Name,status__c,Class_Name__c,batchSize__c,params__c,tipo__c,priority__c,proyecto__c,NextExec__c, Activo__c,
                                                	   Email_Notif__c, Notif__c,RunningJobId__c,dependencia__r.Name,JobPath__c,
                                                  	   UsuarioContexto__c
                                                    from CBK_Framework_Batch__c 
                                                   where runningJobId__c = null 
                                                     and Activo__c = true
                                                     and NextExec__c != null
                                                  	 and NextExec__c <= :timer
                                                     and orden__c != null
                                                   order by orden__c asc
                                                   LIMIT 1000];
        
        list<AsyncApexJob> lstAsyncApexJob = [SELECT Id, ApexClass.Name FROM AsyncApexJob WHERE status not in ('Aborted','Completed','Failed') and JobType='BatchApex'];
        
        //Recopilación de Running Jobs
        list<Id> lstRunningJobId = New list<Id>();
        for (AsyncApexJob aaj : lstAsyncApexJob){
            lstRunningJobId.add(aaj.Id);
        }
		list<CBK_Framework_Batch__c> lstRunningJobDef = [select Id, Name, Class_Name__c, RunningJobId__c, Proyecto__c,Tipo__c,dependencia__c,JobPath__c from CBK_Framework_Batch__c where RunningJobId__c in :lstRunningJobId];
        Map<Id,CBK_Framework_Batch__c> mapRunningJobDef = New Map<Id,CBK_Framework_Batch__c>();
        for (CBK_Framework_Batch__c job : lstRunningJobDef){
            mapRunningJobDef.put(job.RunningJobId__c,job);
        }
        
        list<CBK_BatchJob_Helper.batchJob> lstRunning = New list<CBK_BatchJob_Helper.batchJob>();
        for (AsyncApexJob aaj : lstAsyncApexJob){
			CBK_BatchJob_Helper.batchJob bj = New CBK_BatchJob_Helper.batchJob();
            bj.jobId=aaj.id;
            bj.batchName=mapRunningJobDef.get(aaj.Id)?.Name;
            bj.classNane=aaj.ApexClass.Name;
            bj.tipo=mapRunningJobDef.get(aaj.Id)?.Tipo__c;
            bj.Project=mapRunningJobDef.get(aaj.Id)?.Proyecto__c;   
            bj.dependencia=mapRunningJobDef.get(aaj.Id)?.dependencia__c;   
            bj.jobPath=mapRunningJobDef.get(aaj.Id)?.JobPath__c;
            lstRunning.add(bj);
        }

		Id batchprocessid;
        Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Async_Apex_Job').getRecordTypeId();
        list<CBK_Log__c> lstDetail = New list<CBK_Log__c>();

        list<Id> lstJobId = New list<Id>();
        Map<Id,String> mapStatus = New Map<Id,String>();
        Map<String,list<String>> mapConext = new Map<String,list<String>>();
        list<String> contextJobs;
        
        //Inclusión de nuevos JOBS
        for (CBK_Framework_Batch__c jobDef : lstJobDef) {
            try {
                cbk_log.debug(jobDef.name);
                if (CBK_BatchJob_Helper.jobEjecutable(jobDef,lstRunning)){
                    CBK_BatchJob_Helper.batchJob bj = New CBK_BatchJob_Helper.batchJob();
            		bj.batchName=jobDef.Name;
            		bj.classNane=jobDef.Class_Name__c;
            		bj.tipo=jobDef.Tipo__c;
            		bj.Project=jobDef.Proyecto__c;   
                    bj.dependencia = jobDef.dependencia__r.Name;
                    bj.JobPath = jobDef.JobPath__c;
                    
            		lstRunning.add(bj);
                    
                    map<String,Object> params = New map<String,Object>();
                    if(jobDef.params__c!=null){
                        //params= (map<String,Object>)JSON.deserialize(jobDef.params__c, map<String,Object>.class);  
                        params = (Map<String, Object>)JSON.deserializeUntyped(jobDef.params__c);
                    }


                    if (jobDef.UsuarioContexto__c==null) {
						//Ejecución directa
                        batchprocessid = runBatch(jobDef.Class_Name__c, (integer)jobDef.batchSize__c, params);
	                    lstJobId.add(batchprocessid);
	                    jobDef.RunningJobId__c=batchprocessid; 
                    } else {
                        //Ejecución por Platform Events
                        string userPlatformEvent = 'CBK_Context_' + jobDef.UsuarioContexto__c + '__e';
                        if (mapConext.containsKey(userPlatformEvent)){
                            contextJobs = mapConext.get(userPlatformEvent);
                        } else{
                            contextJobs = new list<String>();
                        }
                        contextJobs.add(jobDef.Id);
                        mapConext.put(userPlatformEvent, contextJobs);
                    }
                    
                    if (jobDef.NextExec__c==null) {
                        jobDef.NextExec__c=DateTime.now();
                    }
                }
            } catch (Exception e) {
                CBK_BatchJob_Helper.errorJob(e, jobDef);
                
                CBK_Log__c detail = New CBK_Log__c ();    
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

        list<AsyncApexJob> lstStatus = [SELECT Id, Status FROM AsyncApexJob WHERE ID =: lstJobId];
        
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
        
        //insert Platform Events
        //Insertamos platform events a posteriori para evitar bloqueo
        for (String userPlatformEvent : mapConext.keySet()) {            
            for (string jobItem : mapConext.get(userPlatformEvent)){
                Type tipoObjeto = Type.forName(userPlatformEvent);
                // Verificar si el tipo de objeto es válido
                if (tipoObjeto != null && tipoObjeto.newInstance() instanceof sObject) {
                    // Instanciar el objeto utilizando el tipo
                    sObject evento = (sObject) tipoObjeto.newInstance();
                    evento.put('JobId__c', jobItem);
                    evento.put('Tipo__c', 'BatchProcess');
                    EventBus.publish(evento);   
                }                
            }
        } 
    }
    
    /*
    public void schedulleBatch(string className,Datetime sysTime,String chronexp)  {
        //String className = 'CBK_MonitorJobsDetail';
        //Datetime sysTime = System.now();
        //sysTime = sysTime.addSeconds(60);
        //String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        Type classInstance = Type.forName(className);
        Schedulable scheduler = (Schedulable)classInstance.newInstance();
        System.schedule('Jobs Details' + sysTime,chron_exp, scheduler);
    }*/
    
}