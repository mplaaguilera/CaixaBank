public class GRR_MarcarBorrarURs_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful{
    
    public GRR_MarcarBorrarURs_Batch () 
    {
        CBK_log.debug('Comienzo batch MarcarBorrarURs');
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {

        Datetime fechaBorrado = CBK_UtilsDate.nowSYS().addYears(-8);  // REGISTROS CON MÁS DE 8 AÑOS
        //Datetime fechaBorrado = CBK_UtilsDate.nowSYS();
        return Database.getQueryLocator([
            SELECT Id, GRR_ToDelete__c 
            FROM GRR_UR__c 
            WHERE Id NOT IN (SELECT  GRR_UR_Relacionada__c FROM Case WHERE GRR_UR_Relacionada__c != null and RecordType.DeveloperName LIKE 'GRR%') 
            and CreatedDate < :fechaBorrado
            and GRR_ToDelete__c = false
        ]); 
    }

    public void execute(Database.BatchableContext bc, List<GRR_UR__c> records) {
        if(!records.isEmpty()) {
            for(GRR_UR__c ur : records) {
                ur.GRR_ToDelete__c = true;
            }
            update records;
        }
    }

    public void finish(Database.BatchableContext bc) {
        CBK_log.debug('Fin batch MarcarBorrarURs');        
    }
}