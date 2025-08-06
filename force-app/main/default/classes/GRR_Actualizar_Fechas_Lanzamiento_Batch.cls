public class GRR_Actualizar_Fechas_Lanzamiento_Batch implements Database.Batchable<sObject> {

    public GRR_Actualizar_Fechas_Lanzamiento_Batch() {
        CBK_Log.debug('Constructor - Batch GRR_Actualizar_Fechas_Lanzamiento_Batch');
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        // Consulta para obtener las UR y sus lanzamientos
        String query = 'SELECT Id, GRR_Id_UR__c, GRR_Situacion_Proximo_Lanzamiento__c,  GRR_Situacion_Ultimo_Lanzamiento__c, ' + 
                        '(SELECT Id, GRR_Fecha_Prevista_Posesion__c, GRR_Situacion__c FROM Lanzamientos__r ' + 
                        'ORDER BY GRR_Fecha_Prevista_Posesion__c ASC) ' + 
                        'FROM GRR_UR__c ' + 
                        'WHERE GRR_Fecha_Proximo_Lanzamiento__c >= TODAY AND GRR_Fecha_Proximo_Lanzamiento__c < TOMORROW AND Id IN (SELECT GRR_UR__c FROM GRR_Lanzamiento__c WHERE GRR_UR__c != null)';
        
        return Database.getQueryLocator(query);
        
    }
    
    public void execute(Database.BatchableContext bc, List<GRR_UR__c> scope) {
        List<GRR_UR__c> listURtoUpdate = new List<GRR_UR__c>();
        System.debug(scope);

        Datetime fechaProxima = null;
        String situacionProxima = null;
        Datetime fechaUltima = null;
        String situacionUltima = null;
        
        // Obtener la fecha actual
        Date hoy = date.today();
        for(GRR_UR__c ur : scope) {
            
            // Verificar los lanzamientos asociados
            for(GRR_Lanzamiento__c lanzamiento : ur.Lanzamientos__r) {
                Datetime fechaLanzamiento = lanzamiento.GRR_Fecha_Prevista_Posesion__c;
                String situacion = lanzamiento.GRR_Situacion__c;

                // Lanzamiento futuro
                if (fechaLanzamiento.date() > hoy) {
                    if (fechaProxima == null || fechaLanzamiento < fechaProxima) {
                        fechaProxima = fechaLanzamiento;
                        situacionProxima = situacion;
                    }
                }
                // Lanzamiento pasado
                else {
                    if (fechaUltima == null || fechaLanzamiento > fechaUltima) {
                        fechaUltima = fechaLanzamiento;
                        situacionUltima = situacion;
                    }
                }
            }

            // Actualizar los campos en la UR
            ur.GRR_Fecha_Proximo_Lanzamiento__c = fechaProxima;
            ur.GRR_Fecha_Ultimo_Lanzamiento__c = fechaUltima;
            ur.GRR_Situacion_Proximo_Lanzamiento__c = situacionProxima;
            ur.GRR_Situacion_Ultimo_Lanzamiento__c = situacionUltima;
            
            listURtoUpdate.add(ur);

            fechaProxima = null;
            situacionProxima = null;
            fechaUltima = null;
            situacionUltima = null;
        }

        // Actualizar las UR en lotes
        update listURtoUpdate;
    }
    
    public void finish(Database.BatchableContext bc){
		CBK_Log.debug('Finalización - Batch GRR_Actualizar_Fechas_Lanzamiento_Batch');
	}
}