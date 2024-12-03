public without sharing class TMS_WS_Upd_Case_Aux {

    public static List<Task> updateTasksWithoutSharing(List<Task> tareas) {
        try {
            update tareas;
            return tareas;
        } catch (Exception e) {
            CBK_Log.error(e, 'TMS_WS_Upd_Case_Aux: Error al actualizar tareas con without sharing. ' + tareas);
            throw e;
        }
    }
}