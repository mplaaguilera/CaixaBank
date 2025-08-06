public with sharing class SACH_Case_BI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList);
    }

    private void process(List<Case> listObj){
        List<Case> casosSACH = SACH_CaseTriggerHelper.filtrarCasosSACH(listObj);

        if (!casosSACH.isEmpty()){
            SACH_CaseTriggerHelper.personAccountBI(casosSACH); 
            SACH_CaseTriggerHelper.identificarClienteAlfBI(casosSACH); 
        }
    }
}