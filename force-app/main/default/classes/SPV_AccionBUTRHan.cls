public with sharing class SPV_AccionBUTRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Accion__c>)tp.newList, (Map<Id, SAC_Accion__c>)tp.newMap, (List<SAC_Accion__c>)tp.oldList, (Map<Id, SAC_Accion__c>)tp.oldMap);
    }
    
    private void process(List<SAC_Accion__c> listNewObj, Map<Id, SAC_Accion__c> mapNewObj, List<SAC_Accion__c> listOldObj, Map<Id, SAC_Accion__c> mapOldObj) {

        List<SAC_Accion__c> listaAccionesSPV = new List<SAC_Accion__c>();

        //Filtrar acciones de SPV
        listaAccionesSPV = SPV_AccionHelper.filtrarAccionesSPV(listNewObj);

        if (!listaAccionesSPV.isEmpty()) {
            //Recuperar cola
            List<Group> cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SPV_PendienteAsignar' LIMIT 1];
            //LLamada a métodos
            SPV_AccionHelper.cambioDeOwner(listaAccionesSPV, mapOldObj, cola[0]); //Comprueba si ha cambiado el owner de la accion. En caso que haya cambiado, llama a método para comprobar si es un owner correcto.
            SPV_AccionHelper.cambioDeEstadosBU(listaAccionesSPV, mapOldObj); //Comprueba si ha cambiado el estado de la accion. En caso que haya cambiado, llama a los métodos necesarios dependiendo del cambio de estado (rellenar fecha ejecucion).
            SPV_AccionHelper.cambioMaestroDeAcciones(listaAccionesSPV, mapOldObj); //Comprueba si ha habido un cambio en el maestro de acciones de la accion. De ser asi, carga los datos del nuevo maestro de acciones.
            SPV_AccionHelper.calcularFechaVencimientoInicial(listaAccionesSPV); //Asignar una fecha de vencimiento inicial teniendo en cuenta las BusinessHours.
            SPV_AccionHelper.cambioFechaVencimientoProrroga(listaAccionesSPV, mapOldObj); //Comprueba si ha habido un cambio en la fecha de vencimiento de prorroga. De ser así, se prorrogan las tareas.
            SPV_AccionHelper.cambioValorPicklistTercero(listaAccionesSPV, mapOldObj); //Si se ha cambiado el valor de la picklist "Tercero" a none, limpiamos el campo "Fecha tentativa".
        }
    }
}