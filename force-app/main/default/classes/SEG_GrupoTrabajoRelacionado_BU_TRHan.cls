public with sharing class SEG_GrupoTrabajoRelacionado_BU_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_GrupoTrabajoRelacionado__c>)tp.newList, (Map<Id, SEG_GrupoTrabajoRelacionado__c>)tp.newMap, (Map<Id, SEG_GrupoTrabajoRelacionado__c>)tp.oldMap);
    }

    private void process(List<SEG_GrupoTrabajoRelacionado__c> listNewObj, Map<Id, SEG_GrupoTrabajoRelacionado__c> mapNewObj, Map<Id, SEG_GrupoTrabajoRelacionado__c> mapOldObj) {
        activacionGrupo(listNewObj, mapNewObj, mapOldObj);
        concatenacionGrupoServicio(listNewObj, mapOldObj);
    }

    public static void activacionGrupo(List<SEG_GrupoTrabajoRelacionado__c> listNewObj, Map<Id, SEG_GrupoTrabajoRelacionado__c> mapNewObj, Map<Id, SEG_GrupoTrabajoRelacionado__c> mapOldObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_GrupoTrabajoRelacionado__c grupo : listNewObj) {              
            // Verificar si el campo SEG_Activo__c esta cambiando 
            if (mapNewObj.get(grupo.Id).SEG_Activo__c != mapOldObj.get(grupo.Id).SEG_Activo__c) {
                // comprobamos si activo esta en true
                if(mapNewObj.get(grupo.Id).SEG_Activo__c){
                    // Actualizar el campo SEG_FechaActivacion__c con la fecha actual datetime
                    grupo.SEG_FechaActivacion__c = datetime.now();
                } else {
                    // Si el campo SEG_Activo__c esta Inactivo
                    // Actualizar el campo SEG_FechaDesactivacion__c con la fecha actual
                    grupo.SEG_FechaDesactivacion__c = datetime.now();
                }           
            }
        }
    }

    public static void concatenacionGrupoServicio(List<SEG_GrupoTrabajoRelacionado__c> listNewObj, Map<Id, SEG_GrupoTrabajoRelacionado__c> mapOldObj){
        for (SEG_GrupoTrabajoRelacionado__c grupoTrabajo : listNewObj) {
            String valorFinal = '';
            if (grupoTrabajo.SEG_GrupoTrabajo__c != mapOldObj.get(grupoTrabajo.Id).SEG_GrupoTrabajo__c || grupoTrabajo.SEG_ServiciosCSO__c != mapOldObj.get(grupoTrabajo.Id).SEG_ServiciosCSO__c) {
                if (grupoTrabajo.SEG_GrupoTrabajo__c != null) {
                    valorFinal = grupoTrabajo.SEG_GrupoTrabajo__c;
                }
                if (grupoTrabajo.SEG_ServiciosCSO__c != null) {
                    valorFinal= valorFinal + grupoTrabajo.SEG_ServiciosCSO__c;
                }
                grupoTrabajo.SEG_GrupoTrabajoCSO__c = valorFinal; 
            }
        }
    }
}