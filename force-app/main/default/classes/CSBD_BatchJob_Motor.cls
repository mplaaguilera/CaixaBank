public class CSBD_BatchJob_Motor implements Database.Batchable<sObject>, Database.Stateful {
    private Decimal registrosPorLote = 100;
    private Decimal tiempoEsperaMinutos = 5;

    public CSBD_BatchJob_Motor() {

    }


    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        this.registrosPorLote = 100;
        this.tiempoEsperaMinutos = 5;

        List<CSBD_ParametrosBatch__c> parametrosBatch = [SELECT CSBD_RegistrosPorLote__c, CSBD_TiempoIntervalos__c FROM CSBD_ParametrosBatch__c limit 1];

        if(!parametrosBatch.isEmpty()){
            registrosPorLote = parametrosBatch[0].CSBD_RegistrosPorLote__c;
            tiempoEsperaMinutos = parametrosBatch[0].CSBD_TiempoIntervalos__c;
        }
     
        String query = 'SELECT Id, Name, CSBD_Estado__c ' +
                       'FROM CSBD_Gestor_Oportunidad__c ' +
                       'WHERE CSBD_Estado__c = \'Fuera horario comercial\' ' +
                       'ORDER BY CreatedDate ASC';

        if (registrosPorLote != null) {
            query += ' LIMIT ' + String.valueOf(registrosPorLote);
        }
        
        
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<CSBD_Gestor_Oportunidad__c> oportunidadesGestionadas) {
      
        try {
            if(!oportunidadesGestionadas.isEmpty()){
                CBK_Log.debug('CSBD_BatchJob_Motor oportunidadesGestionadas:: ' + oportunidadesGestionadas);
                
                for (CSBD_Gestor_Oportunidad__c opp : oportunidadesGestionadas ) {
                        opp.CSBD_Estado__c = 'Pendiente de asignar';
                }

                update oportunidadesGestionadas;

                CBK_SCH_PendingProcess__c pendingProcess = new CBK_SCH_PendingProcess__c();
                pendingProcess.Schedule_Time__c = System.now().addMinutes(tiempoEsperaMinutos.intValue());
                pendingProcess.ClassName__c = 'CBK_SCH_CSBD_ScheduleBatchGestorOppty';
                insert pendingProcess;
            }

        } catch (Exception e) {
            CBK_Log.error(e);
        }
    }

    public void finish(Database.BatchableContext bc) {
            CBK_Log.debug('Fin batch gestores oportunidad fuera de horario',logginglevel.INFO);
            }
        
    

}