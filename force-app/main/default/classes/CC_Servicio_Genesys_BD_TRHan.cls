public with sharing class CC_Servicio_Genesys_BD_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Servicio_Genesys__c>)tp.oldList);
    }
    
    private void process(List<CC_Servicio_Genesys__c> listNewObj) {
        
        list<id> ServicioGenesysId=new list<id>();
        
        for(CC_Servicio_Genesys__c serGenId : listNewObj) 
        {
            ServicioGenesysId.add(serGenId.Id);
        }

        list<CC_Servicio_Genesys_Detalle__c> relaciones_detalle = [SELECT Id FROM CC_Servicio_Genesys_Detalle__c WHERE CC_Servicio_Genesys_Relacionado__c in :ServicioGenesysId];

        if (relaciones_detalle.size() > 0) {
            delete relaciones_detalle;
        }
    }
    
}