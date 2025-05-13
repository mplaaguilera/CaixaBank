global class CBK_WS_APIGraph_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        CBK_ScheduleControls__c scheduleinfo = CBK_ScheduleControls__c.getValues('ScheduleApiGraph');
        // DateTime nextexecution = system.now().addminutes(integer.valueof(scheduleinfo.ExecutionPeriod__c));
        // String day = string.valueOf(nextexecution.day());
        // String month = string.valueOf(nextexecution.month());
        // String hour = string.valueOf(nextexecution.hour());
        // String minute = string.valueOf(nextexecution.minute());
        // String second = '00';
        // String year = string.valueOf(nextexecution.year());
        // String strJobName = 'Job-ApiGraph Process_' + system.now().format('yyyyMMddHHmmss');
        // String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        // if (Test.isRunningTest()) {
		// 	strJobName = 'Job-ApiGraph Test Process_' + system.now().format('yyyyMMddHHmmss');
		// }
        Map<String, CBK_APIGraph_Mailbox__c> apiConf = CBK_APIGraph_Mailbox__c.getAll();
        List<CBK_APIGraph_Mailbox__c> lstBuzones = new List<CBK_APIGraph_Mailbox__c>();
        Map<String, List<CBK_APIGraph_Mailbox__c>> mapLaunch = new Map<String, List<CBK_APIGraph_Mailbox__c>>();

        integer lanzamiento = 1;
        integer buzones = 0;
        CBK_Log.debug('Lista de Buzones a consultar APi Graph: ' + JSON.serialize(apiConf));
        for(String key : apiConf.keySet()){
            boolean active = Test.isRunningTest() ? true : apiConf.get(key).CBK_Active__c;
            if (active){
                if (mapLaunch.containsKey(string.valueOf(lanzamiento))){
                    if(buzones < scheduleinfo.CBK_QueueableLimit__c){
                        mapLaunch.get(string.valueOf(lanzamiento)).addAll(new List<CBK_APIGraph_Mailbox__c>{apiConf.get(key)});
                        buzones++;
                    }
                    if(buzones == scheduleinfo.CBK_QueueableLimit__c){
                        lanzamiento++;
                        buzones = 0;
                    }
                }else{
                    mapLaunch.put(string.valueOf(lanzamiento), new List<CBK_APIGraph_Mailbox__c>{apiConf.get(key)});
                    buzones++;
                }
            }
        }
        //CBK_Log.debug('Numero de queueble: '+ mapLaunch.size()+' en pack de '+ string.valueOf(scheduleinfo.CBK_QueueableLimit__c.format())+ ' Total: '+ apiConf.keySet().size()+' \n' + JSON.serialize(mapLaunch));
        try {
            for(string key : mapLaunch.keySet()){
                List <CBK_APIGraph_Mailbox__c> lstmdt =  mapLaunch.get(key);
                CBK_Log.debug('Launch paquete nº: ' + key + ' count: ' + lstmdt.size());
                if (!Test.isRunningTest()) {
                    CBK_WS_APIGraph api = new CBK_WS_APIGraph(lstmdt, scheduleinfo);
                    System.enqueueJob(api);
                }
            }
            //stopOrStarSchedule(sc, strJobName, strSchedule);
            stopOrStarSchedule(sc);
        } catch(Exception ex) {
            //stopOrStarSchedule(sc, strJobName, strSchedule);
            stopOrStarSchedule(sc);
            CBK_log.error(ex, 'Error CBK_WS_APIGraph_Schedule: ' +ex.getMessage());
        }
    }

    private void stopOrStarSchedule(SchedulableContext sc){//SchedulableContext sc, String jobName, String expSchedule
        CBK_ScheduleControls__c scheduleinfo = CBK_ScheduleControls__c.getValues('ScheduleApiGraph');
        DateTime nextexecution = (scheduleinfo.ExecutionPeriod__c != null)? system.now().addminutes(integer.valueof(scheduleinfo.ExecutionPeriod__c)) : System.now();
        String day = string.valueOf(nextexecution.day());
        String month = string.valueOf(nextexecution.month());
        String hour = string.valueOf(nextexecution.hour());
        String minute = string.valueOf(nextexecution.minute());
        String second = '00';
        String year = string.valueOf(nextexecution.year());
        String strJobName = 'Job-ApiGraph Process_' + system.now().format('yyyyMMddHHmmss');
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        if (Test.isRunningTest()) {
			strJobName = 'Job-ApiGraph Test Process_' + system.now().format('yyyyMMddHHmmss');
		}
        if(sc != null){
            system.abortJob(sc.getTriggerId());
        }
        System.schedule(strJobName, strSchedule, new CBK_WS_APIGraph_Schedule());
        
    }
}