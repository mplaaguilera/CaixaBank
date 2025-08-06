public with sharing class FRA_TaskTriggerHelper {

    public static List<Task> filtrarTareasFRA(List<Task> lstTareas) {
        List<Task> tareasFRA = new List<Task>();
        Id fraRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
        for (Task tarea : lstTareas) {
            if (tarea.recordTypeId == fraRTId) {
                tareasFRA.add(tarea);
            }
        } 
        return tareasFRA;
    }

    public static void validarBorradoTareas(List<Task> lstTareas) {
        Boolean permisoBorrado = FeatureManagement.checkPermission('FRA_Eliminar_Tareas'); 

        for (Task tarea: lstTareas){
            if (permisoBorrado == false){                      
                tarea.addError('No tiene permisos para eliminar el registro'); 
            }
        }
    }
    
}