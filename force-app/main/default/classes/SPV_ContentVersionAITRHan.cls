public with sharing class SPV_ContentVersionAITRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<ContentVersion>)tp.newList, (Map<Id, ContentVersion>)tp.newMap);
    }
    
    private void process(List<ContentVersion> listNewObj, Map<Id, ContentVersion> mapNewObj) {
        
        Map<Id, Case> mapaDatosCasos = new Map<Id, Case>();

        List<ContentVersion> listNewObjFiltrado = SPV_ContentVersionHelper.filtrarRTSPV(listNewObj, mapaDatosCasos);

        if(!listNewObjFiltrado.isEmpty()){
            SPV_ContentVersionHelper.envioEER(listNewObjFiltrado);

            if(!mapaDatosCasos.isEmpty()){
                SPV_ContentVersionHelper.alertaNuevaDocuReclamacion(listNewObjFiltrado, mapaDatosCasos);
            }
        }

    }
}