public with sharing class SPV_AccionAITRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Accion__C>)tp.newList, (Map<Id, SAC_Accion__C>)tp.newMap);
    }

    private void process(List<SAC_Accion__C> listNewObj, Map<Id, SAC_Accion__C> mapNewObj) {

        //Llamada al método que filtra las acciones de SPV
        List<SAC_Accion__C> listAccionesSPV = SPV_AccionHelper.filtrarAccionesSPV(listNewObj);

        if(!listAccionesSPV.isEmpty()){
           SPV_AccionHelper.insertarPermisosAccion(listAccionesSPV);
           SPV_AccionHelper.tareaReclamacionCerrada(listAccionesSPV);
           SPV_AccionHelper.automatizarCasoAplicaTarea(listAccionesSPV);
           SPV_AccionHelper.crearThreadId(listAccionesSPV);
           SPV_AccionHelper.insertarTMEs(listAccionesSPV);
        }

    }
}