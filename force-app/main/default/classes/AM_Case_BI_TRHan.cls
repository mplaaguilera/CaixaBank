public with sharing class AM_Case_BI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList);
    }

    private void process(List<Case> listObj){
        List<Case> casosAM = AM_CaseTriggerHelper.filtrarCasosAM(listObj);

        if (!casosAM.isEmpty()){
            AM_CaseTriggerHelper.personAccountBI(casosAM); 
            AM_CaseTriggerHelper.identificarClienteAlfBI(casosAM);  
            AM_CaseTriggerHelper.creacionCaso_BI(casosAM);
            AM_CaseTriggerHelper.creacionCasoPropuestasBI(casosAM);
            AM_CaseTriggerHelper.seInformaCanalRespuestaBI(casosAM);
            AM_CaseTriggerHelper.causaInformadoBI(casosAM);
            AM_CaseTriggerHelper.solucionInformadoBI(casosAM);    
            AM_CaseTriggerHelper.informarOficinaAfectadaBI(casosAM);   
            AM_CaseTriggerHelper.tematicaInformadoBI(casosAM);                    
            AM_CaseTriggerHelper.productoInformadoBI(casosAM);                    
            AM_CaseTriggerHelper.motivoInformadoBI(casosAM);                    
        }
    }
}