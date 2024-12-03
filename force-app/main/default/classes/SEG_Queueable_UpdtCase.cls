public with sharing class SEG_Queueable_UpdtCase extends CBK_SCH_Queueable_Abstract{
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
            
            Type typeProcessAction = Type.forName('SEG_Queueable_UpdtCase');
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
        List<Case> listCasos = new List<Case>();
        Boolean modificado = false;
        List<String> idCasos = new List<String>();
        for (CBK_SCH_PendingProcess__c procesoActualizacion : incomingPendingProcessList) {
            modificado = false;
            if (procesoActualizacion.RecordId__c != null) {
                Case casoUpdt = new Case();
                casoUpdt.Id = procesoActualizacion.RecordId__c;
                idCasos.add(procesoActualizacion.RecordId__c);
                if (procesoActualizacion.Param1__c != null) {
                    casoUpdt.AccountId = procesoActualizacion.Param1__c;
                    modificado = true;
                }
                if (procesoActualizacion.Param2__c != null) {
                    casoUpdt.ContactId = procesoActualizacion.Param2__c;
                    modificado = true;
                }
                if(modificado){
                    listCasos.add(casoUpdt);
                }   
            }
        }

        if (!listCasos.isEmpty()) {
            try {
                update listCasos;
                CBK_Log.debug('Entramos en la actualizacion de casos: ' + idCasos);
            } catch (Exception ex) {
                CBK_Log.error(ex);
            }           
        }
    }
}