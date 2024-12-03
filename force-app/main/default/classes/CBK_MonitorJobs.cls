@SuppressWarnings('PMD.ApexSuggestUsingNamedCred,PMD.AvoidDeeplyNestedIfStmts')
/**
 * @description Framework de captura de resultados de carga Bulk API
 */
global without sharing class CBK_MonitorJobs implements Schedulable {
    
    /**
     * @description   
     * @param ctx SchedulableContext
     */ 
    global void execute(SchedulableContext ctx) {
        CBK_MonitorJobs_CoreBatch batch = new CBK_MonitorJobs_CoreBatch();
		database.executeBatch(batch,1);  
    }
    
    /**
     * @description objeto para almacenar datos de conexión
     */ 
    global class Conexion {
        String instance_url;
        String sessionID; 
    }
    
    /**
     * @description Objeto para alamacenat datos de proyectos y equipos     
     */ 
    global class Monitor {
        String entidad;
        String equipo;
        String proyecto;
    }

    /**
     * @description  Clase para para obtener datos de la conexión actual
     * @return objconex  Datos de la conexión
     */ 
    global static conexion CBK_Login() {
		conexion objconex = new conexion();        
        objconex.sessionID = UserInfo.getSessionId();  
        objconex.instance_url = URL.getSalesforceBaseUrl().toExternalForm();

        return objconex;
    }

    /**
     * @description  Clase principal para la captura de Jobs por API
     */ 
    global static void CBK_Jobs() {
        conexion objconex = CBK_Login();        
        List<string> lstpages = new List<string>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(objconex.instance_url + '/services/data/v49.0/jobs/ingest/');
        request.setMethod('GET');
        request.setHeader('Authorization','Bearer ' + objconex.sessionID);
        HttpResponse response = http.send(request);
		String nextRecord='/services/data/v49.0/jobs/ingest/';        

        while (nextRecord!=null){
            lstpages.add(objconex.instance_url + nextRecord);
            nextRecord=CBK_endPoint(objconex,objconex.instance_url + nextRecord);
        }
                        
        for (string vendpoint: lstpages){
            
            CBK_Job_pagina(vendpoint,objconex.sessionID);
        }        

        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(60);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        CBK_MonitorJobsDetail scheduler = new CBK_MonitorJobsDetail();
        System.schedule('Jobs Details' + sysTime,chron_exp,scheduler);

    }
      
    /**
     * @description  Llamada para captura de datos (solo lisdtado para solventar timeouts)
     * @param objconex  : Datos de la conexión
     * @param endpoint  : endPoint de entrada
     * @return nextRecord
     */ 
    global static string CBK_EndPoint(conexion objconex,string endpoint) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Authorization','Bearer ' + objconex.sessionID);
        HttpResponse response = http.send(request);
		String nextRecord=null;
        
        
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> records = (List<Object>) results.get('records');
            nextRecord=(String)results.get('nextRecordsUrl');
        }
        
        return nextRecord;
    }
    
/*	@Future(callout=true)*/

    /**
     * @description  Llamada para captura del detalle de los datos
     * @param vEndPoint  : Datos de la conexión
     * @param vsessionID  : endPoint de entrada
     */ 
   
	global static void CBK_Job_Pagina (string vEndPoint, string vsessionID ){
        CBK_Job_Pagina ( vEndPoint,  vsessionID, new list<Id>());
    }
    
    global static void CBK_Job_Pagina (string vEndPoint, string vsessionID, list<Id> usrIdExluidoQuery){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(vEndPoint);
        request.setMethod('GET');
        request.setHeader('Authorization','Bearer ' + vsessionID);
        HttpResponse response = http.send(request);
		String campo;
        List<CBK_Log__c> lstjob = new List<CBK_Log__c>();
        
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> records = (List<Object>) results.get('records');
            Id recordTypeId =Schema.SObjectType.CBK_Log__c.getRecordTypeInfosByDeveloperName().get('Data_Load_Log').getRecordTypeId();
            
            for (Object record: records) {
                JSONParser parser = JSON.createParser(JSON.serialize(record)); 
                CBK_Log__c  job = New CBK_Log__c();
                job.RecordTypeId=recordTypeId;
                
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                        Campo=parser.getText();
                        parser.nextToken();
                        if (Campo== 'id') 			{job.Job_Id__c=parser.getText();}
                        if (Campo== 'operation') 	{job.operation__c=parser.getText();}
                        if (Campo== 'object') 		{job.object__c=parser.getText();}
                        if (Campo== 'createdById')	{job.createdBy__c=parser.getText();}
                        if (Campo== 'createdDate') 	{job.createdDate__c=parser.getDatetimeValue();}
                        if (Campo== 'systemModstamp') {job.systemModstamp__c=parser.getDatetimeValue();}
                        if (Campo== 'state') 		{job.state__c=parser.getText();}
                        if (Campo== 'concurrencyMode') {job.concurrencyMode__c=parser.getText();}
                        if (Campo== 'contentType') 	{job.contentType__c=parser.getText();}
                        if (Campo== 'apiVersion') 	{job.apiVersion__c=parser.getText();}
                        if (Campo== 'jobType') 		{job.jobType__c=parser.getText();}                 
                	}
                }
                if ((vEndPoint.contains('ingest')&&(job.operation__c!='query'))||
                    (vEndPoint.contains('query')&&(!usrIdExluidoQuery.contains(job.createdBy__c)))){
                    lstjob.add(job);
                }
            }   
            upsert lstjob Job_Id__c;
        }
    }
    
    /**
     * @description  Llamada para captura de la informació detalle ampliado de los datos
     * @param jobId  : Id del Builk API Job
     */ 
    global static void CBK_JobDetail(Id jobId) {
        CBK_Log__c job = [SELECT Id, Job_Id__c, operation__c, Project__c, object__c,Rec_Loaded__c,Rec_Success__c, Rec_Error__c, createdBy__r.Name , createdDate__c, systemModstamp__c, state__c, concurrencyMode__c, contentType__c, apiVersion__c, jobType__c, Completado__c ,
                             totalProcessingTime__c, apiActiveProcessingTime__c,retries__c
                             FROM CBK_Log__c where Job_Id__c=:JobId]; 

        conexion objconex = CBK_Login();        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        if (job.operation__c == 'query') {
            request.setEndpoint(objconex.instance_url + '/services/data/v49.0/jobs/query/' + JobId);    
        } else {
            request.setEndpoint(objconex.instance_url + '/services/data/v49.0/jobs/ingest/' + JobId);    
        }
        
        request.setMethod('GET');
        request.setHeader('Authorization','Bearer ' + objconex.sessionID);
        HttpResponse response = http.send(request);
		String campo;
        monitor datos = new monitor();

		datos=CBK_obtenerEquipo(job.createdBy__r.Name,job.object__c);
        job.Entidad__c=datos.entidad;
        job.Equipo__c=datos.equipo;
        job.Project__c=datos.proyecto;

        Boolean callbatchesbyJobId = false;

        if (response.getStatusCode() == 200) {
            job.Rec_Error__c=0;
            job.Rec_Success__c=0;
            job.Rec_Loaded__c=0;
            JSONParser parser = JSON.createParser(response.getBody()); 
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                        Campo=parser.getText();
                        parser.nextToken();
                        if (Campo== 'numberRecordsProcessed') {job.Rec_Loaded__c=parser.getDoubleValue();}
                        if (Campo== 'numberRecordsFailed') {job.Rec_Error__c =parser.getDoubleValue();}
                        if (Campo== 'totalProcessingTime') {job.totalProcessingTime__c=parser.getDoubleValue();}
                        if (Campo== 'apiActiveProcessingTime') {job.apiActiveProcessingTime__c=parser.getDoubleValue();}
                        if (Campo== 'retries') {job.retries__c=parser.getDoubleValue();}
                	}
                    
                    job.Rec_Success__c = job.Rec_Loaded__c - job.Rec_Error__c;       
                    if ((job.state__c=='Failed')||(job.state__c=='JobComplete')||(job.state__c=='Aborted')){
                        job.Completado__c=true;
                    }else if(job.state__c=='Closed' && job.operation__c == 'query'){
                        callbatchesbyJobId = true;
                    }
                }

            if (callbatchesbyJobId){
                http = new Http();
                request = new HttpRequest();
                request.setEndpoint(objconex.instance_url + '/services/async/59.0/job/' + JobId + '/batch');
                request.setMethod('GET');
                request.setHeader('X-SFDC-Session', objconex.sessionID);
                HttpResponse resp = http.send(request);

                String contentType = resp?.getHeader('Content-Type');
                lstInfobatches lstResponse = parseResponse(resp, contentType);
                Boolean allcompleted = true;
                List<dateTime> finish = new List<dateTime>();
                for(responseParse info : lstResponse.batchInfo){
                    if(info.state != 'Completed' && info.state != 'Failed' && info.state != 'NotProcessed'){
                        allcompleted = false;
                    }else{
                        string strfinishDate = '"' + info.systemModstamp +'"';
                        Datetime finishDate  = Datetime.valueOf(json.deserialize(strfinishDate, datetime.class));
                        finish.add(finishDate);
                    }
                }
                if (allcompleted){
                    finish.sort();
                    job.Completado__c=true;
                    job.systemModstamp__c = finish.get(finish.size()-1);
                }
            }
        }
        upsert job Job_Id__c;             
    }
    
        
    /**
     * @description  Llamada para captura de la informació detalle ampliado de los datos (para reprocesamientos)
     * @param jobId  : Id del Builk API Job
     */ 
    global static void CBK_JobDetail2(Id jobId) {
        monitor datos = new monitor();
        CBK_Log__c job = [SELECT Id, Job_Id__c, operation__c, object__c, project__c, Rec_Success__c, Rec_Error__c , createdBy__r.Name , createdDate__c, systemModstamp__c, state__c, concurrencyMode__c, contentType__c, apiVersion__c, jobType__c, Completado__c ,
                             totalProcessingTime__c, apiActiveProcessingTime__c,retries__c
                             FROM CBK_Log__c where Job_Id__c=:JobId];

		datos=CBK_obtenerEquipo(job.createdBy__r.Name,job.object__c);
        job.Entidad__c=datos.entidad;
        job.Equipo__c=datos.equipo;   
        job.project__c=datos.proyecto;   
        upsert job Job_Id__c;             
    }
    
    /**
     * @description  Datos de equipo a partir de objeto y usuar
     * @param usuario  Usuario de Carga
     * @param objeto   Objeto cargado
     * @return retorno
     */ 
    global static monitor CBK_ObtenerEquipo(String usuario,string objeto){
		monitor retorno = new monitor();        
        
        list<CBK_Monitor_Job__mdt> mon = [SELECT Objeto__c, Usuario__c, Entidad__c, Proyecto__c, MasterLabel FROM CBK_Monitor_Job__mdt where Usuario__c= :usuario and Objeto__c= :objeto LIMIT 1];    
		if (mon.size()==0) {mon = [SELECT Objeto__c, Usuario__c, Entidad__c, Proyecto__c, MasterLabel FROM CBK_Monitor_Job__mdt where Usuario__c= '' and Objeto__c= :objeto];   }         
		if (mon.size()==0) {mon = [SELECT Objeto__c, Usuario__c, Entidad__c, Proyecto__c, MasterLabel FROM CBK_Monitor_Job__mdt where Objeto__c= :objeto LIMIT 1];    }
        if (mon.size()==0) {mon = [SELECT Objeto__c, Usuario__c, Entidad__c, Proyecto__c, MasterLabel FROM CBK_Monitor_Job__mdt where Usuario__c= :usuario and Objeto__c= 'All' LIMIT 1];    }
        if (mon.size()!=0) {
            retorno.equipo=mon[0].MasterLabel;
            retorno.proyecto=mon[0].Proyecto__c;            	
            retorno.entidad=mon[0].Entidad__c;
            if (string.isBlank(retorno.entidad)){
                try{
                    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                    Schema.SObjectType leadSchema = schemaMap.get(objeto);
                    retorno.entidad=leadSchema.getDescribe().getLabel();
                }
                catch(Exception e){
                    cbk_log.error(e);
                }
            }
        } else {
            try{
                Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            	Schema.SObjectType leadSchema = schemaMap.get(objeto);
            	retorno.entidad=leadSchema.getDescribe().getLabel();
            	retorno.equipo='';
                retorno.proyecto='';
            } catch(Exception e){
                cbk_log.error(e);
            }
        }
        return retorno;
    }

    public static lstInfobatches parseResponse (HttpResponse resp, String type){
        lstInfobatches infobatches = new lstInfobatches();
        if (type == 'application/json'){
            infobatches = (lstInfobatches) JSON.deserialize(resp.getBody(), lstInfobatches.class);
            CBK_Log.debug('response by JSON: ' + json.serialize(infobatches));
        }else{
            Dom.Document xml = new Dom.Document();
            xml.load(resp.getBody());
            Dom.XMLNode rootElement = xml.getRootElement();  
            List<responseParse> lstbatchInfo = new List<responseParse>();
            for(Dom.XmlNode childNode :rootElement.getChildElements()){
                responseParse batchInfo = new responseParse();
                for (Dom.XMLNode detailElement : childNode.getChildElements() ){ 
                    if (detailElement.getName() == 'id'){
                        batchInfo.id = detailElement.getText();
                    }else if(detailElement.getName() == 'jobId'){
                        batchInfo.jobId = detailElement.getText();
                    }else if(detailElement.getName() == 'state'){
                        batchInfo.state = detailElement.getText();
                    }else if(detailElement.getName() == 'systemModstamp'){
                        batchInfo.systemModstamp = detailElement.getText();
                    } 
                }  
                lstbatchInfo.add(batchInfo);
            }
            infobatches.batchInfo = lstbatchInfo;
            CBK_Log.debug('response by XML: ' + json.serialize(infobatches));
        }
        return infobatches;
    }


    public class responseParse {
		public string state { get; set; }
        public string jobId { get; set; }
        public string id { get; set; }
        public string systemModstamp { get; set; }
	}

    public class lstInfobatches {
        public List<responseParse> batchInfo { get; set; }
	}
}