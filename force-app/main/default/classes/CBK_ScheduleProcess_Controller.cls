global class CBK_ScheduleProcess_Controller implements Schedulable {

	global void execute(SchedulableContext sc) {

		try {
			CBK_ScheduleControls__c scheduleinfo = CBK_ScheduleControls__c.getValues('ScheduleInfo');
			try {
				CBK_log.debug('Pending Process (SchedulableContext): ' + sc, LoggingLevel.INFO);
				executePendingProcess();
				
				DateTime nextexecution = system.now().addminutes(integer.valueof(scheduleinfo.ExecutionPeriod__c));
				String day = string.valueOf(nextexecution.day());
				String month = string.valueOf(nextexecution.month());
				String hour = string.valueOf(nextexecution.hour());
				String minute = string.valueOf(nextexecution.minute());
				String second = '00';
				String year = string.valueOf(nextexecution.year());
				String strJobName = 'Job-Pending Process Recurrent_' + system.now().format('yyyyMMddHHmmss');

				if (Test.isRunningTest()) {
					strJobName = 'JOB Pending Test Process_' + system.now().format('yyyyMMddHHmmss');
				}

				String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
				
				if(sc != null && checkjob(String.valueOf(sc.getTriggerId()), ''))
					system.abortJob(sc.getTriggerId());

				if (!checkjob('', strJobName)){
					System.schedule(strJobName, strSchedule, new CBK_ScheduleProcess_Controller());
				}

				scheduleinfo.Date_Last_Execution__c = system.now();
				update scheduleinfo;
			} catch(Exception ex) {
				CBK_log.error(ex, 'ERROR CBK_ScheduleProcess_Controller: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
				if(sc != null && checkjob(String.valueOf(sc.getTriggerId()), ''))
					system.abortJob(sc.getTriggerId());
				CBK_log.debug('ERROR CBK_ScheduleProcess_Controller: ' + ' sc: '+ sc + ' - ' + ex.getMessage() + ' ' + ex.getStackTraceString(), LoggingLevel.INFO);
			}
		} catch(Exception ex){
			CBK_log.error(ex, 'ERROR CBK_ScheduleProcess_Controller: ' + ex.getMessage() + ' ' + ex.getStackTraceString());
		}
	}

	private static void executePendingProcess()
	{
		CBK_ScheduleControls__c scheduleinfo = CBK_ScheduleControls__c.getValues('ScheduleInfo');
		Decimal MAX_RETRIES = scheduleinfo.Retries__c > 0 ? scheduleinfo.Retries__c : 0;
		string DISPACHER_SCH = 'CBK_ScheduleProcess_Dispacher';

		CBK_log.debug('Execute Pending Process', LoggingLevel.INFO);

		Datetime vToday = datetime.now();
		Map<String, List<CBK_SCH_PendingProcess__c>> mapPendingProcess = new Map<String, List<CBK_SCH_PendingProcess__c>> ();
        Map<String, Map<String,List<CBK_SCH_PendingProcess__c>>> mapPendingProcessUser = new Map<String, Map<String,List<CBK_SCH_PendingProcess__c>>>();
        //Map<Usuario, Map<Clase, List<CBK_SCH_PendingProcess__c>>>

		List<CBK_SCH_PendingProcess__c> lstPP = [SELECT Id, ClassName__c, Type__c, RecordId__c, Param1__c, Param2__c, Check__c, Retries__c, Schedule_Time__c, QueuedDate__c,UsuarioContexto__c,CBK_ParamTextArea__c FROM CBK_SCH_PendingProcess__c
		                                         WHERE Retries__c<:MAX_RETRIES AND Schedule_Time__c <= :vToday and Queued__c = false limit 200];

		List<CBK_SCH_PendingProcess__c> lstPPupdate = new List<CBK_SCH_PendingProcess__c> ();
        string context ='';
		for (CBK_SCH_PendingProcess__c pp : lstPP)
		{
			pp.Queued__c = true;
			pp.QueuedDate__c = datetime.now();
            context=pp.UsuarioContexto__c == null ? 'DEFAULT' : 'CBK_Context_' + pp.UsuarioContexto__c + '__e';
                
            if (!mapPendingProcessUser.containsKey(context))
			{
                mapPendingProcess=new Map<String, List<CBK_SCH_PendingProcess__c>> ();
			}
			else {
                mapPendingProcess=mapPendingProcessUser.get(context);
            }
            
            if (!mapPendingProcess.containsKey(pp.ClassName__c))
            {
                mapPendingProcess.put(pp.ClassName__c, new List<CBK_SCH_PendingProcess__c> { pp });
                lstPPupdate.add(pp);
            }
            else {
                mapPendingProcess.get(pp.ClassName__c).add(pp);
                lstPPupdate.add(pp);
            }
			
            mapPendingProcessUser.put(context,mapPendingProcess);
            
		}
		//Update Queued to true
		update lstPPupdate;

		if (mapPendingProcessUser.size()> 0)
		{
            for (string userPlatformEvent : mapPendingProcessUser.keySet()){
                if (userPlatformEvent=='DEFAULT'){
	                //Se procesan directamente los que no tengan contexto contexto Admin 
                    Type typeProcessAction = Type.forName(DISPACHER_SCH);
	                CBK_log.debug('CBK_ScheduleProcess_Controller - ' + DISPACHER_SCH + ' Map: ' + mapPendingProcess, LoggingLevel.INFO);	
    	            CBK_ScheduleProcess_Abstract processAction = (CBK_ScheduleProcess_Abstract) typeProcessAction.newInstance();
        	        processAction.execute(mapPendingProcessUser.get('DEFAULT'));        
                } else {
                    cbk_log.debug(userPlatformEvent);
                    Type tipoObjeto = Type.forName(userPlatformEvent);
                	// Verificar si el tipo de objeto es válido
                    if (tipoObjeto != null && tipoObjeto.newInstance() instanceof sObject) {
                        //Creamo un list con todos los Ids a pasarle al platform event
                        List<String> pendingList = new List<String>();
                        for (List<CBK_SCH_PendingProcess__c> pp : mapPendingProcessUser.get(userPlatformEvent).values()) {
                            for (CBK_SCH_PendingProcess__c p : pp) {
                                pendingList.add(p.Id);
                            }
                        }
                        //Instanciar el objeto utilizando el tipo
                        sObject evento = (sObject) tipoObjeto.newInstance();
                        evento.put('Tipo__c', 'SchedProcess');
                        evento.put('JobList__c',JSON.serialize(pendingList));
                        EventBus.publish(evento);   
                    }                                    
                }
            }
		}
	}


	public static List<ResponseInsert> createRecordSchProcess(List<CBK_SCH_PendingProcess__c> lstPP)
	{
		CBK_ScheduleControls__c scheduleinfo = CBK_ScheduleControls__c.getValues('ScheduleInfo');
		Decimal MAX_RETRIES = scheduleinfo.Retries__c > 0 ? scheduleinfo.Retries__c : 0;

		List<ResponseInsert> lstRes = new List<ResponseInsert> ();
		ResponseInsert res;
		List<CBK_SCH_PendingProcess__c> lstPPinsert = new List<CBK_SCH_PendingProcess__c> ();
		string checkSum;
		Map<String, CBK_SCH_PendingProcess__c> existMap = checkExistList(lstPP);
		List<CBK_SCH_PendingProcess__c> lstUpd = new List<CBK_SCH_PendingProcess__c> ();
		CBK_SCH_PendingProcess__c ppUpd;
		if (existMap.size() > 0) {
			for (CBK_SCH_PendingProcess__c pendingProcess : lstPP)
			{
				checkSum = getCheckSum(pendingProcess).replaceAll('[^(a-zA-Z1-9) ]', '').deleteWhitespace();
				if (!existMap.containsKey(checkSum)) {
					lstPPinsert.add(pendingProcess);
				}
				else {
					res = new ResponseInsert();
					res.CheckSum = checkSum;
					res.hasError = true;
					if (existMap.get(checkSum).Retries__c >= MAX_RETRIES && pendingProcess.Schedule_Time__c == existMap.get(checkSum).Schedule_Time__c) {
						ppUpd = existMap.get(checkSum);
						lstUpd.add(ppUpd);
						res.errorCode = 'ITEM_EXCEEDED_RETRIES';
						res.errorMessage = 'Item already exceeds retry limit';
					}
					else if (pendingProcess.Schedule_Time__c == existMap.get(checkSum).Schedule_Time__c) {
						res.errorCode = 'ITEM_EXIST';
						res.errorMessage = 'Item already exist in Pending Process';
					}
					else {
						res.hasError = false;
						lstPPinsert.add(pendingProcess);
					}
					res.PendingProcess = existMap.get(checkSum);
					lstRes.add(res);
				}
			}
		}
		else {
			lstPPinsert = lstPP;
		}
		System.debug(lstPPinsert);
		List<ResponseInsert> responseInsert = dmlOperation(Database.insert(lstPPinsert, false), lstPPinsert);
		update lstUpd;
		lstRes.addAll(responseInsert);
		CBK_log.debug('Create Record - Response: ' + lstRes, LoggingLevel.INFO);

		return lstRes;
	}

	private static List<ResponseInsert> dmlOperation(Database.SaveResult[] resultOperation, List<CBK_SCH_PendingProcess__c> lstOperation)
	{
		List<ResponseInsert> listResp = new List<ResponseInsert> ();
		ResponseInsert response;
		for (Integer i = 0; i<resultOperation.size(); i++) {
			response = new ResponseInsert();
			response.checkSum = getCheckSum(lstOperation.get(i));
			response.pendingProcess = lstOperation.get(i);
			if (!resultOperation[i].isSuccess())
			{
				response.hasError = true;
				response.errorCode = String.valueOf(resultOperation[i].getErrors() [0].getStatusCode());
				response.errorMessage = resultOperation[i].getErrors() [0].getMessage();
				listResp.add(response);
			}
			else {
				response.hasError = false;
				lstOperation.get(i).Id = resultOperation[i].getId();
				response.pendingProcess = lstOperation.get(i);
				listResp.add(response);
			}
		}
		return listResp;
	}

	private static Map<String, CBK_SCH_PendingProcess__c> checkExistList(List<CBK_SCH_PendingProcess__c> lstPP)
	{
		Set<String> checkSums = new Set<String> ();
		Map<String, CBK_SCH_PendingProcess__c> existMap = new Map<String, CBK_SCH_PendingProcess__c> ();
		String checkSum;
		for (CBK_SCH_PendingProcess__c pendingProcess : lstPP) {
			checkSum = getCheckSum(pendingProcess).replaceAll('[^(a-zA-Z1-9) ]', '').deleteWhitespace();
			checkSums.add(checkSum);
		}

		List<CBK_SCH_PendingProcess__c> lstExsitPP = [SELECT Id, ClassName__c, Type__c, Param1__c, Param2__c, Retries__c, Check__c, Schedule_Time__c,CBK_ParamTextArea__c FROM CBK_SCH_PendingProcess__c
		                                              WHERE Check__c IN :checkSums];
		for (CBK_SCH_PendingProcess__c existPP : lstExsitPP) {
			existMap.put(existPP.Check__c, existPP);
		}
		return existMap;
	}

	private static string getCheckSum(CBK_SCH_PendingProcess__c pendingProcess)
	{
		string strDate = String.valueOf(pendingProcess.Schedule_Time__c).replaceAll('[^(a-zA-Z1-9) ]', '').deleteWhitespace();

		return(String.isNotBlank(pendingProcess.ClassName__c) ? pendingProcess.ClassName__c : '')
		+ (String.isNotBlank(pendingProcess.Type__c) ? pendingProcess.Type__c : '')
		+ (String.isNotBlank(pendingProcess.RecordId__c) ? pendingProcess.RecordId__c : '')
		+ (String.isNotBlank(strDate) ? strDate : '');
	}

	public static void deleteRecordSchProcess(Set<String> IdsPp) {
		List<CBK_SCH_PendingProcess__c> lstPP = [SELECT Id, Check__c,CBK_ParamTextArea__c FROM CBK_SCH_PendingProcess__c
		                                         WHERE Id IN :IdsPp];
		if (lstPP.size()> 0) {
			delete lstPP;
		}
	}

	/*public static void updateRetriesPendingProcess(Set<String> IdsPp) {
	  List<CBK_SCH_PendingProcess__c> lstPP = [SELECT Id, Check__c, Retries__c FROM CBK_SCH_PendingProcess__c
	  WHERE Id IN :IdsPp];
	  for (CBK_SCH_PendingProcess__c pp : lstPP)
	  {
	  pp.Retries__c = pp.Retries__c + 1;
	  pp.Queued__c = false;
	  }
	  if (lstPP.size() > 0) {
	  update lstPP;
	  }
	  }*/

	public static void updateRecordSchProcess(Set<String> IdsPp, Datetime newDateTime, Boolean sumRetrie) {

		List<CBK_SCH_PendingProcess__c> lstPP = [SELECT Id, Check__c, Schedule_Time__c, Retries__c,CBK_ParamTextArea__c FROM CBK_SCH_PendingProcess__c
		                                         WHERE Id IN :IdsPp];
		Datetime ppDate;
		Decimal retries;
		for (CBK_SCH_PendingProcess__c pp : lstPP)
		{
			ppDate = pp.Schedule_Time__c;
			retries = pp.Retries__c;
			pp.Schedule_Time__c = String.isNotBlank(String.valueOf(newDateTime)) ? newDateTime : ppDate;
			pp.Retries__c = sumRetrie ? retries + 1 : retries;
			pp.Queued__c = false;
		}
		if (lstPP.size() > 0) {
			update lstPP;
		}
	}

	public static Boolean checkjob(String vId, String vjobname){
		Datetime vtoday = System.now();
		list<CronTrigger> lstjobs  =  new list<CronTrigger>();
		Boolean exist = false;

		if (string.isNotBlank(vjobname)){
			lstjobs = [SELECT Id,CreatedDate, CronJobDetail.name, State 
					FROM CronTrigger
					WHERE CronJobDetail.name = :vjobname];
			
			exist = lstjobs.size() > 0 ? true : false;
		}
		if (string.isNotBlank(vId)){
			lstjobs = [SELECT Id,CreatedDate, CronJobDetail.name, State 
					FROM CronTrigger
					WHERE Id = :vId];
			
			exist = lstjobs.size() > 0 ? true : false;
		}
		return exist;
	}

	public static List<CBK_SCH_PendingProcess__c> getInfoRecordSchProcess(Set<String> Ids) {
		List<CBK_SCH_PendingProcess__c> lstPP = [SELECT Id, ClassName__c, Type__c, RecordId__c, Param1__c, Param2__c, Check__c, Retries__c, Schedule_Time__c, QueuedDate__c,CBK_ParamTextArea__c FROM CBK_SCH_PendingProcess__c
		                                         WHERE RecordId__c IN :Ids];

		return lstPP;
	}

	//Response
	public class ResponseInsert
	{
		public String checkSum { get; set; }
		public Boolean hasError { get; set; }
		public CBK_SCH_PendingProcess__c pendingProcess { get; set; }
		public String errorMessage { get; set; }
		public String errorCode { get; set; }
	}
}