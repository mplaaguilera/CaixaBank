public with sharing class HDT_Activar_Templates_Envio1N_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    // Id batchJobId = Database.executeBatch(new HDT_Activar_Templates_Envio1N_Batch(), 200);
    public HDT_Activar_Templates_Envio1N_Batch() {
        CBK_Log.debug('Inicia - HDT_Activar_Templates_Envio1N_Batch',logginglevel.INFO);
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {

         // Realizamos una consulta SOQL para obtener el registro del Custom Setting
         String query = 'SELECT Name,HDT_Activo__c, HDT_Configuracion_1__c, HDT_Configuracion_2__c FROM HDT_Parametros__c WHERE Name = \'HDT_Envio_Encuesta_EdG\'';
         return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<HDT_Parametros__c> scope) {
        // Creamos una lista para acumular los registros a actualizar
        List<HDT_Parametros__c> parametrosToUpdate = new List<HDT_Parametros__c>();

        // Procesamos el registro devuelto
        for (HDT_Parametros__c parametro : scope) {
           // Actualizamos el campo Activo__c a true
           parametro.HDT_Activo__c = true;

           // Agregamos el registro a la lista
            parametrosToUpdate.add(parametro);
        }

        // Realizamos el DML fuera del bucle
    if (!parametrosToUpdate.isEmpty()) {
        update parametrosToUpdate;
    }
    }

    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('Finalización - HDT_Activar_Templates_Envio1N_Batch',logginglevel.INFO);

    }
}