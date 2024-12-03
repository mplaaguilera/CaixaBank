public with sharing class SEG_SchedulePlanificacion extends CBK_SCH_Queueable_Abstract {

    List<CBK_SCH_PendingProcess__c> procesadosList;
    List<CBK_SCH_PendingProcess__c> noProcesadosList;

    public override void execute(QueueableContext ctx) {
        integer counter=0;
        boolean startNewQueue=false;
        try
        {   
            procesadosList = New List<CBK_SCH_PendingProcess__c>();
            noProcesadosList = New List<CBK_SCH_PendingProcess__c>();
            List<CBK_SCH_PendingProcess__c> incomingPendingProcessList = this.lstInfoProcess;          

            //Recuperamos el máximo del lote a procesar. Si está nulo lo dejamos en 25
            String maxRecordsStr = SEG_MetodosComunes.recuperarParametrosValor('SEG_BatchSizeReclamaciones');
            integer maxRecords =integer.valueOf((String.isNotBlank(maxRecordsStr)) ? maxRecordsStr : '25');  

            if (Test.isRunningTest()){
                maxRecords=1;
            }

            for(CBK_SCH_PendingProcess__c pending :incomingPendingProcessList)
            {
                if(!startNewQueue)
                {
                    if(pending!=null)
                    {
                        try
                        {
                            ProcesadosList.add(pending);
                        }
                        catch(Exception ex)
                        {
                            CBK_Log.error(ex);
                        }
                        counter=counter+1;
                    }
                    system.debug('Procesados :'+ counter);
                    if(counter>maxRecords)
                    {
                        startNewQueue=true;
                    }                         
                } else {
                    noProcesadosList.add(pending);
                }
            }

            if (procesadosList.size()>0) {
                //Se procesa el primer subconjunto limitado a MAX_RECORD
                work(procesadosList);
            }
            
            Type typeProcessAction = Type.forName('SEG_SchedulePlanificacion');
            CBK_SCH_Queueable_Abstract processAction = (CBK_SCH_Queueable_Abstract) typeProcessAction.newInstance();
            processAction.lstInfoProcess = noProcesadosList;
            if(startNewQueue)
            { 
                //Se planificaN nuevo Queuables con los no procesados                	
				System.enqueueJob(processAction);				     
                counter=0;               
            }
        }
        catch(Exception ex)
        {
            CBK_Log.error(ex);
        }


    }

    private void work(List<CBK_SCH_PendingProcess__c> incomingPendingProcessList) {  
        String methodName = 'work';
        Set<Id> pendingProcessCaseIdSet = new Set<Id>();
        Set<String> procesosFallidos = new Set<String>();
        Map<String, String> mapCasoProceso = new Map<String, String>();
        for(CBK_SCH_PendingProcess__c pendingProcess: incomingPendingProcessList){
            pendingProcessCaseIdSet.add(pendingProcess.RecordId__c);
            mapCasoProceso.put(pendingProcess.RecordId__c,pendingProcess.Id);
        }

         Case[] pendingProcessCaseList = [SELECT OwnerId, Status, SEG_Subestado__c, AccountId, ContactId, SEG_Fecha_planificaci_n__c FROM Case WHERE Id=:pendingProcessCaseIdSet FOR UPDATE ];

        Map<Id, Case> idCaseMap = new Map<Id, Case>();

        for(Case caso: pendingProcessCaseList){
            idCaseMap.put(caso.Id, caso);
        }

        List<Case> lstCasosUpdt = new List<Case>();
        List<Case> lstCaseDup = new List<Case> ();
        Set<Case> caseToset = new Set<Case>();
        List<Case> lstCasosAccContIguales = new List<Case>();
        Id idColaSegBo = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' LIMIT 1].Id;

        for (Integer i = 0; i < incomingPendingProcessList.size(); i++) {
            if(idCaseMap.containsKey(incomingPendingProcessList[i].RecordId__c)){
                Case caso = idCaseMap.get(incomingPendingProcessList[i].RecordId__c);
                Case casoAnterior = new Case();
                if(i > 0){
                    casoAnterior = idCaseMap.get(incomingPendingProcessList[i-1].RecordId__c);
                }
                
                //if(caso.Status == 'Planificado' && caso.SEG_Fecha_planificaci_n__c != null && caso.SEG_Fecha_planificaci_n__c <= DateTime.now().addMinutes(5) && caso.SEG_Fecha_planificaci_n__c >= DateTime.now().addMinutes(-5)){
                if(caso.Status == 'Planificado' && caso.SEG_Fecha_planificaci_n__c != null ){   
                    try {
                        Case casoUpdt = new Case();
                        casoUpdt.Id = caso.Id;
                    	casoUpdt.OwnerId = idColaSegBo;
						casoUpdt.Status = 'Activo';
						casoUpdt.SEG_Subestado__c = 'Por Fecha Planificación';
                        if(i == 0 || (caso.AccountId != casoAnterior.AccountId && caso.ContactId != casoAnterior.ContactId)){
                            lstCasosUpdt.add(casoUpdt);
                        } else {
                            lstCasosAccContIguales.add(casoUpdt);
                        }
                    } catch (Exception e) {
                        CBK_Log.error(e);
                        throw(e);
                    }
                }
            }
        }

        if(!lstCasosAccContIguales.isEmpty()){
            lstCasosUpdt.addAll(lstCasosAccContIguales);
        }

        if(!lstCasosUpdt.isEmpty()){
            if (Schema.sObjectType.Case.fields.OwnerId.isUpdateable() && Schema.sObjectType.Case.fields.Status.isUpdateable()  && Schema.sObjectType.Case.fields.SEG_Subestado__c.isUpdateable()) {

                caseToset.addAll(lstCasosUpdt);
                lstCaseDup.addAll(caseToset);
                List<Database.SaveResult> results = Database.update(lstCaseDup,false);
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        CBK_log.debug('SEG_SchedulePlanification: Caso planificación actualizado.', LoggingLevel.INFO);
                    } else {
                        for(Database.Error err : sr.getErrors()) {
                            CBK_log.debug('SEG_SchedulePlanification: Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
                        }
                        if(mapCasoProceso.containsKey(sr.getId())){
                            procesosFallidos.add(mapCasoProceso.get(sr.getId()));
                        }
                    }       
                }             
            }
        }

        if(!procesosFallidos.isEmpty()){
            DateTime proximaEjecucion = Datetime.now().addMinutes(2);
            CBK_ScheduleProcess_Controller.updateRecordSchProcess(procesosFallidos,proximaEjecucion,true);
        }
    }
}