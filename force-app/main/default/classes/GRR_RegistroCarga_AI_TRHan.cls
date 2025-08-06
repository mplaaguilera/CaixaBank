public with sharing class GRR_RegistroCarga_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<GRR_RegistroCarga__c>) tp.newList);
    }
    
    private static void process(List<GRR_RegistroCarga__c> listNewObj) {         
        List<GRR_RegistroCarga__c> registrosCargaActaComite = GRR_RegistroCargaTriggerHelper.filtrarRegistrosCargaActaComiteHist(listNewObj);
        if(!registrosCargaActaComite.isEmpty()){
        	GRR_RegistroCargaTriggerHelper.crearNuevasURs(registrosCargaActaComite);
            GRR_RegistroCargaTriggerHelper.informarLookupUR(registrosCargaActaComite);
        }
    }

}