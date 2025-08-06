public with sharing class SPV_AccionAUTRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Accion__c>)tp.newList, (Map<Id, SAC_Accion__c>)tp.newMap, (List<SAC_Accion__c>)tp.oldList, (Map<Id, SAC_Accion__c>)tp.oldMap);
    }

    private void process(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj, List<SAC_Accion__c> listOldObj, Map<Id, SAC_Accion__c> mapOldObj) {

        List<SAC_Accion__c> listaAccionesSPV = new List<SAC_Accion__c>();

        //Filtrar acciones de SPV
        listaAccionesSPV = SPV_AccionHelper.filtrarAccionesSPV(listNewObj);

        if (!listaAccionesSPV.isEmpty()) {
            //LLamada a métodos
            SPV_AccionHelper.cambioDeEstadosAU(listaAccionesSPV, mapOldObj); //Comprueba si ha cambiado el owner de la accion. Dependiendo del cambiado, Hace las siguientes acciones: finalizar TMEs, cerrar la reclamacion si se han finalizado todas las tareas, calculo de importes, mandar tarea a ggh en caso que lo sea.
            SPV_AccionHelper.cambioImportes(listaAccionesSPV, mapOldObj); //Comprueba si han cambiado los importes de la tarea. En caso afirmativo, recalcula el importe abonado y resuelto del caso
            SPV_AccionHelper.crearTMEProrroga(listaAccionesSPV, mapOldObj);
            SPV_AccionHelper.lanzarAlertasTareas(listaAccionesSPV, mapOldObj);
        }
    }
    
}