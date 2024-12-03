public class SAC_CaseReclamante_BI_TRHan extends CC_TriggerHandlerBase  {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_CaseReclamante__c>)tp.newList, (Map<Id, SAC_CaseReclamante__c>)tp.newMap);
	}

    private void process(List<SAC_CaseReclamante__c> listNewObj, Map<Id, SAC_CaseReclamante__c> mapNewObj) {
        //system.debug('entro trigger insert');
        SAC_CaseReclamanteHandler.compruebaPrincipal(listNewObj);
        SAC_CaseReclamanteHandler.rellenarDatosCaseReclamante(listNewObj);
        //system.debug('fin trigger insert');
    }

}