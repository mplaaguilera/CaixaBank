global class CBK_MonitorJobs_CoreBatch implements Database.Batchable<String>, Database.AllowsCallouts {

	global Iterable<String> start(Database.BatchableContext BC) {
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
                        
        return lstpages;
       
    }    
    global void execute(Database.BatchableContext BC, List<String> lstpages) {
        system.debug('start');	
        conexion objconex = CBK_Login();
        for (string vendpoint: lstpages){
            system.debug(vendpoint);
            CBK_MonitorJobs.CBK_Job_pagina(vendpoint,objconex.sessionID);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(60);
        //String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        //CBK_MonitorJobsDetail scheduler = new CBK_MonitorJobsDetail();
        //System.schedule('Jobs Details' + sysTime,chron_exp,scheduler);
        //        CBK_MonitorJobs_Batch batch = new CBK_MonitorJobs_Batch();
		//		  database.executeBatch(batch,1); 
		CBK_BatchJob.schedulleBatch('CBK_MonitorJobs_Batch' + '_' + String.valueof(DateTime.now().getTime()), 'CBK_MonitorJobs_Batch',1,null,sysTime);

    }
/***************/    
    global class conexion {
        String instance_url;
        String sessionID; 
    }
    
    global class monitor {
        String entidad;
        String equipo;
        String proyecto;
    }

    global static conexion CBK_Login() {
		conexion objconex = new conexion();        
        objconex.sessionID = UserInfo.getSessionId();  
        objconex.instance_url = URL.getSalesforceBaseUrl().toExternalForm();

        return objconex;
    }

    global static string CBK_endPoint(conexion objconex,string endpoint) {
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
            system.debug(nextRecord);
        }
        
        return nextRecord;
    }
}