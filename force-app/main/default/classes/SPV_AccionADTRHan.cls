public with sharing class SPV_AccionADTRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Accion__c>)tp.newList, (Map<Id, SAC_Accion__c>)tp.newMap, (List<SAC_Accion__c>)tp.oldList, (Map<Id, SAC_Accion__c>)tp.oldMap);
    }

    private void process(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj, List<SAC_Accion__c> listOldObj, Map<Id, SAC_Accion__c> mapOldObj) {

        List<SAC_Accion__c> listaAccionesSPV = new List<SAC_Accion__c>();

        //Filtrar acciones de SPV
        listaAccionesSPV = SPV_AccionHelper.filtrarAccionesSPV(listOldObj);

        if (!listaAccionesSPV.isEmpty()) {
            SPV_AccionHelper.automatizarCasoAplicaTareaDel(listaAccionesSPV);
            SPV_AccionHelper.calculoImportesDelete(listaAccionesSPV);
        }
    }
    
}