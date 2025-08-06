public with sharing class CC_KnowledgeVencimientoBatch implements Database.Batchable<sObject> {
   
    public CC_KnowledgeVencimientoBatch() {
        CBK_Log.debug('CC_KnowledgeVencimientoBatch: Inicio del batch'); //avoiding QC no sense error :P
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        CC_KnowledgeCaseHandler.KnowledgeSettings config = CC_KnowledgeCaseHandler.getCustomSetting();
        //Si no hay configuración o no se activa el envío de correos, no se generara casos ni envio de correos. 
        if(config == null ) {
            CBK_Log.debug('CC_KnowledgeVencimientoBatch: No se encontró la configuración para el ejecucion de la notificacion de articulos vencidos config :' + config);
             // Opción para forzar que el batch no se ejecute
             return Database.getQueryLocator('SELECT Id FROM Knowledge__kav WHERE Id = null');
        }

        List<String> condicionesFechas = new List<String>();
        for(Integer dias : config.diasAvisoAntes) {
            Datetime fechaCaducidad = CBK_UtilsDate.todayDT().addDays(dias);
            String fechaFormateada = fechaCaducidad.format('yyyy-MM-dd');
            condicionesFechas.add('DAY_ONLY(CC_Fecha_Caducidad__c) = ' + fechaFormateada);
        }

        String tiposArticulos = '';
        if(config.tiposArticulos != null && !config.tiposArticulos.isEmpty()) {
            List<String> tiposConComillas = new List<String>();
            for(String tipo : config.tiposArticulos) {
                tiposConComillas.add('\'' + tipo + '\'');
            }
            tiposArticulos = String.join(tiposConComillas, ', ');
        }

        String query = 'SELECT Id, KnowledgeArticleId, CC_Area_Responsable__c, CC_Fecha_Caducidad__c, Title, Answer__c ' +
                      'FROM Knowledge__kav ' +
                      'WHERE (' + String.join(condicionesFechas, ' OR ') + ') ' +
                      'AND PublishStatus = \'Online\' AND CC_Tipo__c IN (' + tiposArticulos + ')';
        return Database.getQueryLocator(query);
    } 
    
    public void execute(Database.BatchableContext bc, List<Knowledge__kav> scope) {
  
        try {
            CC_KnowledgeCaseHandler.gestionarArticulosNotificaciones(scope);            
        } catch(Exception e) {
            CBK_Log.error('CC_KnowledgeVencimientoBatch: ' + e.getMessage() + ' - ' + e.getStackTraceString());
        }
    }  
    
    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('CC_KnowledgeVencimientoBatch: Fin del batch');//avoiding QC no sense error :P
    }  


}