/**
* @description Clase bach para la fusión de registros 
*/
public class CBK_Fusion_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
     /**
     * @description QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id FROM CBK_Fusion__c where pendiente__c = true';
        return Database.getQueryLocator(query);
    } 
    
     /**
     * @description Execute
     */
    public void execute(Database.BatchableContext bc, List<CBK_Fusion__c> fusionList) {
       
        for(CBK_Fusion__c item : fusionList)
        {        
            CBK_Fusion.exec(item.Id);
        }
    }   
    
     /**
     * @description Finish
     */
    public void finish(Database.BatchableContext bc) {
        
  }
}