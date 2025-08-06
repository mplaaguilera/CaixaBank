public with sharing class SPV_AccionBITRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Accion__c>)tp.newList, (Map<Id, SAC_Accion__c>)tp.newMap);
	}

    private void process(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj) {

        List<SAC_Accion__c> listaAccionesSPV = new List<SAC_Accion__c>();

        //Filtrar acciones de SPV
        listaAccionesSPV = SPV_AccionHelper.filtrarAccionesSPV(listNewObj);

        if (!listaAccionesSPV.isEmpty()) {
            //LLamada a métodos
            SPV_AccionHelper.cargarDatosMaestroAcciones(listaAccionesSPV);
            SPV_AccionHelper.cargarDatos(listaAccionesSPV);
            SPV_AccionHelper.insertarAccionesReclamacion(listaAccionesSPV);
            SPV_AccionHelper.accionComprobarOwnerYStatus(listaAccionesSPV);
            SPV_AccionHelper.calcularFechaVencimientoInicial(listaAccionesSPV);
            SPV_AccionHelper.comprobarTareaUnicaGGH(listaAccionesSPV);
        }
    }
}