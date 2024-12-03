/**
 * @description Helper del Framework de procesos Apex Batch
 */
public with sharing class CBK_BatchJob_Helper {

     /**
     * @description Declaración de objeto BatchJob para uso en la clase
     */
    public class BatchJob {
        public String jobId;
        public String batchName;
        public String classNane;
        public String project;
        public String tipo;
        public String dependencia;
        public String jobPath;
    }
    
    /**
     * @description Cálculo de siguiente ejecución (se controla que coja la fecha más reciente)
     * @param batchJob  : Id del Batch planificable
     */
    public static void nextExecution(CBK_Framework_Batch__c batchJob){   
        nextExecution_calc(batchJob);
        //Para evitar replanificaciones en fechas pasadas
        while (batchJob.NextExec__c<=DateTime.now()){
            batchJob.LastExec_Ini__c = batchJob.NextExec__c;
            batchJob.LastExec_End__c = batchJob.NextExec__c;
            batchJob.LastExec_Sched__c = batchJob.NextExec__c;
                
        	nextExecution_calc(batchJob);
        }
        
    }
    
    /**
     * @description Cálculo de siguiente ejecución
     * @param batchJob  : Id del Batch planificable
     */
    public static void nextExecution_Calc(CBK_Framework_Batch__c batchJob){   
    /*    CBK_Framework_Batch__c batchJob = [SELECT Id,Tipo_de_periodicidad__c, Periodicidad__c, Calc_NextExec__c ,
                                           		  LastExec_Ini__c,LastExec_End__c,LastExec_Sched__c,
                                           	      Lunes__c,Martes__c,Miercoles__c,Jueves__c,Viernes__c,Sabado__c,Domingo__c
                                             FROM CBK_Framework_Batch__c
                                            WHERE Id =:batchJobId];*/
        
        DateTime nextExec;
        try {
            DateTime lastExec =DateTime.now();
            switch on batchJob.Calc_NextExec__c {
                when 'INI' {	
                    lastExec =(batchJob.LastExec_Ini__c == null) ? DateTime.now() :  batchJob.LastExec_Ini__c;
                }
                when 'END' {	
                    lastExec =(batchJob.LastExec_End__c == null) ? DateTime.now() :  batchJob.LastExec_End__c;
                } 
                when 'SCHED' {	
                    lastExec =(batchJob.LastExec_Sched__c == null) ? DateTime.now() :  batchJob.LastExec_Sched__c;
                }            
            }
            
            
            if (batchJob.Activo__c){        
                switch on batchJob.Tipo_de_periodicidad__c {
                    when 'Meses' {	
						//No se utiliza addMonths por problemas con zona horaria y por que solo suma 30 días
                        nextExec = DateTime.newInstance( lastExec.Year(), lastExec.Month() + (integer)batchJob.Periodicidad__c, lastExec.day(),lastExec.hour(),lastExec.minute(),lastExec.second());
                    }	                    
                    when 'Dias' {	
                        nextExec = lastExec.addDays((integer)batchJob.Periodicidad__c);
                    }	
                    when 'Horas' {
                        nextExec = lastExec.addHours((integer)batchJob.Periodicidad__c);
                    }
                    when 'Minutos' {
                        nextExec = lastExec.addMinutes((integer)batchJob.Periodicidad__c);
                    }
                }
                
                //Si la fecha de planificación es pasada se actualiza a la actual

                if (nextExec <= DateTime.now()) {
                    nextExec=DateTime.now();
                }
                
                //Validación de días inhábiles
                Map<String,Boolean> diasHabiles = New Map<String,Boolean>();
                diasHabiles.put('1',batchJob.Lunes__c);
                diasHabiles.put('2',batchJob.Martes__c);
                diasHabiles.put('3',batchJob.Miercoles__c);
                diasHabiles.put('4',batchJob.Jueves__c);
                diasHabiles.put('5',batchJob.Viernes__c);
                diasHabiles.put('6',batchJob.Sabado__c);
                diasHabiles.put('7',batchJob.Domingo__c);
                
                integer n=0;
                while ( (n<7) && !(diasHabiles.get(nextExec.addDays(n).format('u')))){
                    n++;
                }
                
                nextExec=nextExec.addDays(n); 
                if ((n>0) && ((batchJob.Tipo_de_periodicidad__c=='Horas')||(batchJob.Tipo_de_periodicidad__c=='Minutos'))) {
                    //Truncado de fecha, para Redondeo a las 00:00:00 por cambio de día
                 	nextExec = Datetime.newInstance(nextExec.year(), nextExec.month(), nextExec.day(), 0, 0, 0);
                }

                //Control de cadenas para ajustar la fecha de próxima ejecución al job dependiente anterior
                if (string.isNotBlank(batchJob.Dependencia__c)){
                    list<CBK_Framework_Batch__c> lstParent = [select Id,NextExec__c from CBK_Framework_Batch__c where Id = :batchJob.Dependencia__c];     
                    if ((lstParent.size()>0) && (lstParent[0].NextExec__c > nextExec)) {
                        nextExec = lstParent[0].NextExec__c.addMinutes(1);
                    }
                }
            }
        } catch (Exception e) {
            List<Object> detalle = new List<Object> {'Batch: ' + batchJob.Class_Name__c};
            CBK_Log.error(e,detalle);
            	//throw(e); 
        }
        //return nextExec;
        batchJob.NextExec__c = nextExec;
    }
    
    /**
     * @description Detección de Proyecto a partir de la Clase Apex
     * @param apexClass
	 * @return Proyecto
	 */    
    public static String findProject(String apexClass) {
        return findProject(apexClass, New CBK_Framework_Batch_Apex__mdt());
    }

    /**
     * @description Detección de Proyecto a partir de la Clase Apex
     * @param apexClass
     * @param conf - > Datos del metadata CBK_Framework_Batch_Apex__mdt
     * @return Proyecto
	 */    
    public static String findProject(String apexClass,CBK_Framework_Batch_Apex__mdt conf) {    
        String proyecto = '';
        Map<String,CBK_Framework_Batch_Apex__mdt > mapPrj = New Map<String,CBK_Framework_Batch_Apex__mdt >();
        for(CBK_Framework_Batch_Apex__mdt  prj :[select label,proyecto__c, Email_Notif__c, Notif__c,Max__c from CBK_Framework_Batch_Apex__mdt ])
        {
            mapPrj.put(prj.label, prj);
        }
        
        conf = mapPrj.get(apexClass);
        if (conf != null){
            proyecto = conf.proyecto__c;
        } else if (apexClass?.indexOf('_')>0) {
            conf=mapPrj.get(apexClass.substring(0,apexClass.indexOf('_')+1)+'*');
            if (conf != null){
                proyecto = conf.proyecto__c;
            }
        }
        if (conf == null) {
            conf = mapPrj.get('Sin catalogar');
        }

        return proyecto;
    }
    
    
    /**
     * @description Lógica para determinar si el Job es ejecutable en ese instante
     * //Validación de si se puede ejecutar
        //	- No está en ejecución
        //	- Proyecto que no haya superado el tamaño de cola asignado 
        //	- No haya superado el tamaño de cola asignado Global           
     * @param job
     * @param lstRunning 
     * @return resultado
	 */         
    public static boolean jobEjecutable(CBK_Framework_Batch__c job, list<batchJob> lstRunning)  {       
        Map<String,CBK_Framework_Batch_Apex__mdt > mapPrj = New Map<String,CBK_Framework_Batch_Apex__mdt >();
        for(CBK_Framework_Batch_Apex__mdt  prj :[select label,proyecto__c, Email_Notif__c, Notif__c, Max__c from CBK_Framework_Batch_Apex__mdt ])
        {
            mapPrj.put(prj.label, prj);
        }
        
        String apexClass = job.Class_Name__c;
        CBK_Framework_Batch_Apex__mdt conf = mapPrj.get(apexClass);
        if ((conf == null) && (apexClass?.indexOf('_')>0)) {
            conf=mapPrj.get(apexClass.substring(0,apexClass.indexOf('_')+1)+'*');
        }
        if (conf == null) {
            conf = mapPrj.get('Sin catalogar');
        }
        
        boolean resultado =true;        
        
        Map<String,Integer> prjCount = new Map<String,Integer>();
        for (batchJob bj : lstRunning ){
            //Contaje de procesos por proyecto
            if(!prjCount.containsKey(bj.Project)){
                prjCount.put(bj.Project,0);
            }
            Integer currentInt=prjCount.get(bj.Project)+1;
            prjCount.put(bj.Project,currentInt);
            //Si el Job tipo planificado ya en ejecución o su dependencia, no se permite otra ejecución
//            if (((job.tipo__c=='Periódico') && (bj.batchName == job.Name)) || 
//                ((job.dependencia__c !=null) && (bj.batchName == job.dependencia__r.Name)) ||
//                ((bj.dependencia == job.Name)) ||
                 
            system.debug(bj);
            system.debug(job);
            
            if (((job.tipo__c=='Periódico') && (bj.batchName == job.Name)) || 
                ((job.JobPath__c !=null) && (bj.batchName !=null) && (job.JobPath__c.contains(bj.batchName)) && (job.JobPath__c!=bj.batchName)) ||    
                ((bj.jobPath !=null) &&(bj.jobPath.contains(job.Name)) && (bj.jobPath != job.Name))                
               ) {
                   resultado=false;
            }
        }
        
        if ((prjCount.get(conf.Proyecto__c)>=conf.Max__c )&&(resultado)) {
                //Superado el máximo por proyecto
                resultado=false;

        }
        
        if ((lstRunning.size()>=mapPrj.get('Global').Max__c )&&(resultado)) {
                //Superado el máximo Global
                resultado=false;

        }
            
        return resultado;
    }
    
    
    /**
     * @description Registro de error
     * @param err
     * @param jobDef 
	 */         
    public static void errorJob(Exception err, CBK_Framework_Batch__c jobDef)  {
        List<Object> detalle = new List<Object> {'Batch: ' + jobDef.Class_Name__c};
        CBK_Log.error(err,detalle);
        
        if ((jobDef.Notif__c) && (jobDef.Email_Notif__c!=null)) {
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'Framework de Login'];
            if (owea.size() > 0 ) {
                list<string> toAddresses =jobDef.Email_Notif__c.split(',');
            	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        		mail.setOrgWideEmailAddressId(owea.get(0).Id);
        		mail.setToAddresses(toAddresses);
            	if (jobDef.Tipo__c=='Unitario') {
            		mail.setSubject('Batch Apex Job Error: ' + jobDef.Class_Name__c);    
            	} else {
                	mail.setSubject('Batch Apex Job Error: ' + jobDef.Name);
            	}
            
        		mail.setBccSender(false);
        		mail.setUseSignature(false);
        		mail.setHtmlBody('<b> Proyecto: </b>' + jobDef.Proyecto__c +
            		             '<p><b> Job: </b>'   + jobDef.Name +                                 
            		             '<p><b> Clase: </b>' + jobDef.Class_Name__c +
                    		     '<p><b> Error : </b>' + err.getMessage() +'<p>');    
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
        }
    }
        
    
    
}