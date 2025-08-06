public with sharing class GRR_Case_AI_TRHan extends CC_TriggerHandlerBase{

     public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<Id, Case>)tp.newMap);
    }

      private void process(List<Case> listNewObj, Map<Id, Case> mapNewObj) {

         List<Case> casosGRR = GRR_CaseTriggerHelper.filtrarCasosGRR(listNewObj);
        if(!casosGRR.isEmpty()){
            //GRR_CaseTriggerHelper.informarDatosEntradaCOPS(casosGRR);
            GRR_CaseTriggerHelper.handleAfterInsert(casosGRR);
            

        }

      }


    
}