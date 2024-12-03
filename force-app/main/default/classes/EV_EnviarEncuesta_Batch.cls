public class EV_EnviarEncuesta_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	public EV_EnviarEncuesta_Batch() {
        System.debug('hola');
    }
    
    public EV_EnviarEncuesta_Batch(Id v1, Id v2) {
        System.debug('hola');
    }

    public Database.QueryLocator start(Database.BatchableContext bc) { 
		String query = 'Select Id from Campaign limit 1';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Campaign> scope) {

    }

    public void finish(Database.BatchableContext bc) {
     
    }
    
    
}