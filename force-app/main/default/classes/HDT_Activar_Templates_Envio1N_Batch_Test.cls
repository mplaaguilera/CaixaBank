@IsTest
public with sharing class HDT_Activar_Templates_Envio1N_Batch_Test {
    // Método de configuración para crear datos de prueba
    static void setupTestData() {
        // Creamos un registro de Custom Setting HDT_Parametros__c para la prueba
        HDT_Parametros__c customSetting = new HDT_Parametros__c(
            Name = 'HDT_Envio_Encuesta_EdG',
            HDT_Activo__c = false, // Inicialmente en false
            HDT_Configuracion_1__c = 'email_castellano@test.com',
            HDT_Configuracion_2__c = 'email_catalan@test.com'
        );
        insert customSetting;
    }

     // Método para probar la ejecución del batch
     @isTest
     static void testBatchExecution() {
        System.runAs(HDT_TestDataFactory.usuarioAHdt()) {

         // Llamamos al método para crear datos de prueba
         setupTestData();

         // Inicializamos el batch
         HDT_Activar_Templates_Envio1N_Batch batch = new HDT_Activar_Templates_Envio1N_Batch();
        
       // Ejecutamos el método 'start' para obtener los datos a procesar
       Database.QueryLocator queryLocator = batch.start(null);
        
        // Convertimos el QueryLocator a una lista para pasarla al método 'execute'
        List<HDT_Parametros__c> registrosProcesados = [SELECT Id, HDT_Activo__c FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta_EdG'];
        
        // Ejecutamos manualmente el método 'execute'
        batch.execute(null, registrosProcesados);
        
        // Finalmente, llamamos al método 'finish'
        batch.finish(null);

     
         // Verificamos que el campo Activo__c ha sido actualizado a true
         HDT_Parametros__c updatedSetting = [SELECT HDT_Activo__c FROM HDT_Parametros__c WHERE Name = 'HDT_Envio_Encuesta_EdG'];
         System.assertEquals(true, updatedSetting.HDT_Activo__c, 'El campo Activo__c debería estar actualizado a true.');
        }
     }
}