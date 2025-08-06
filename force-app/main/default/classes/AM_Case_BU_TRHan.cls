public with sharing class AM_Case_BU_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Case>)tp.newList, (Map<ID, Case>)tp.newMap,(List<Case>)tp.oldList, (Map<Id, Case>)tp.oldMap);
    }

    private void process(List<Case> listObj, Map<ID, Case> mapObj, List<Case> listOldObj, Map<ID, Case> mapOldObj){
        List<Case> casosAM = AM_CaseTriggerHelper.filtrarCasosAM(listObj);
        List<Case> listNewObjCC = New List<Case>();

        if (!casosAM.isEmpty()){
            AM_CaseTriggerHelper.tematicaInformadoBU(casosAM,mapOldObj); 
            AM_CaseTriggerHelper.productoInformadoBU(casosAM,mapOldObj); 
            AM_CaseTriggerHelper.motivoInformadoBU(casosAM,mapOldObj); 
            AM_CaseTriggerHelper.personAccountBU(casosAM,mapOldObj);  
            AM_CaseTriggerHelper.identificarClienteAlfBU(casosAM,mapOldObj);
            AM_CaseTriggerHelper.identificarCambioClienteAlfBU(casosAM,mapOldObj);  
            AM_CaseTriggerHelper.blanqueoAccountBU(casosAM,mapOldObj);
            AM_CaseTriggerHelper.seInformaCanalRespuestaBU(casosAM,mapOldObj);
            AM_CaseTriggerHelper.empleadoCuentaBU(casosAM,mapOldObj);
            AM_CaseTriggerHelper.asociaActivoBU(casosAM,mapOldObj);
            AM_CaseTriggerHelper.informarOficinaAfectadaDetalleBU(casosAM,mapOldObj);
            AM_CaseTriggerHelper.informarOficinaAfectadaBU(casosAM,mapOldObj);
            AM_CaseTriggerHelper.actualizarColaProcedenciaBU(casosAM,mapOldObj);     
            AM_CaseTriggerHelper.causaInformadoBU(casosAM,mapOldObj);        
            AM_CaseTriggerHelper.solucionInformadoBU(casosAM,mapOldObj);        
        }
    }
}