public class SEG_LimpiezaContactosCPA_Batch implements Database.Batchable<sObject>, Database.Stateful, Schedulable{

    public SEG_LimpiezaContactosCPA_Batch() {
        CBK_Log.debug('Contructor - SEG_LimpiezaContactosCPA_Batch',logginglevel.INFO);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        CBK_Log.debug('Start - SEG_ContactPendienteAsociar_P1_Batch',logginglevel.INFO);
        return Database.getQueryLocator([
            SELECT Id FROM Contact WHERE CreatedDate = LAST_N_DAYS:30 and Account.Name ='CUENTA PENDIENTE ASOCIAR' and Account.RecordType.DeveloperName ='CC_ClienteSEG' and Email != null
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope){
        CBK_Log.debug('scope:' + scope.size()+'',logginglevel.INFO);
        if (!scope.isEmpty()) {
            Database.DeleteResult[] resultadoDelete = Database.delete(scope, false);
            for (Database.DeleteResult resDelete : resultadoDelete) {
                if (!resDelete.isSuccess() || Test.IsRunningTest()) {
                    for(Database.Error err : resDelete.getErrors()){
                        CBK_log.debug('SEG_LimpiezaContactosCPA_Batch: Deletion error returned: ' + err.getStatusCode() + ' - ' + err.getMessage(), LoggingLevel.ERROR);
                    }
                }
            }
        }
    }

    public void execute(SchedulableContext sc) {
		Database.executeBatch(new SEG_LimpiezaContactosCPA_Batch());
	}
    
    public void finish(Database.BatchableContext bc) {
        CBK_Log.debug('SEG - Finalización - Batch Limpieza Contactos CPA', logginglevel.INFO);
    }
}