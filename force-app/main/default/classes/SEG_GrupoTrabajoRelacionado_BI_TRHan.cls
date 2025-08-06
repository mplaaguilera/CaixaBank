public with sharing class SEG_GrupoTrabajoRelacionado_BI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SEG_GrupoTrabajoRelacionado__c>)tp.newList, (Map<Id, EmailMessage>)tp.newMap);
    }
    private void process(List<SEG_GrupoTrabajoRelacionado__c> listNewObj, Map<Id, EmailMessage> mapNewObj) {
        activacionGrupo(listNewObj);
        concatenacionGrupoServicio(listNewObj);
    }

    public static void activacionGrupo(List<SEG_GrupoTrabajoRelacionado__c> listNewObj){
        // Iterar sobre los registros insertados o actualizados
        for (SEG_GrupoTrabajoRelacionado__c grupo : listNewObj) {
                
            // Verificar si el campo SEG_Activo__c esta Activo
            if (grupo.SEG_Activo__c) {                 
                // Actualizar el campo SEG_FechaActivacion__c con la fecha actual datetime
                grupo.SEG_FechaActivacion__c = datetime.now();
            } else {
                // Si el campo SEG_Activo__c esta Inactivo
                // Actualizar el campo SEG_FechaDesactivacion__c con la fecha actual
                grupo.SEG_FechaDesactivacion__c = datetime.now();                   
            }
        }
    }

    public static void concatenacionGrupoServicio(List<SEG_GrupoTrabajoRelacionado__c> listNewObj){
        for (SEG_GrupoTrabajoRelacionado__c grupoTrabajo : listNewObj) {
            String valorFinal = '';
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