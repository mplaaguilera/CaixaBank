public class CC_SDOC_MCC_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //Eliminado (Funcionalidad SDoc)
        return null;
    }

    public void execute(Database.BatchableContext bc, List<CC_MCC_Plantilla__c> mccPlantillasBuscar) {               
        //Eliminado (Funcionalidad SDoc)
    }

    public void finish(Database.BatchableContext bc) {
       //Eliminado (Funcionalidad SDoc)
    }
}