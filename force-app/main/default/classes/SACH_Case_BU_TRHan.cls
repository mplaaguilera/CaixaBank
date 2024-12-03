public with sharing class SACH_Case_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<ID, Case>)tp.newMap,(List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listObj, Map<ID, Case> mapObj, List<Case> listOldObj, Map<ID, Case> mapOldObj){
        List<Case> casosSACH = SACH_CaseTriggerHelper.filtrarCasosSACH(listObj);

        if (!casosSACH.isEmpty()){
            SACH_CaseTriggerHelper.personAccountBU(casosSACH,mapOldObj);  
            SACH_CaseTriggerHelper.identificarClienteAlfBU(casosSACH,mapOldObj);
            SACH_CaseTriggerHelper.identificarCambioClienteAlfBU(casosSACH,mapOldObj);  
            SACH_CaseTriggerHelper.blanqueoAccountBU(casosSACH,mapOldObj);
            SACH_CaseTriggerHelper.noIdentificaClienteBU(casosSACH,mapOldObj);
            SACH_CaseTriggerHelper.validarOperativaPromor(casosSACH,mapOldObj);
        }
    }
}