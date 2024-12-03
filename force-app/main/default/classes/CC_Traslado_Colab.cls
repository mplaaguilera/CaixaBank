public class CC_Traslado_Colab {

    public static void reabrirTareaTrasladoColab(List<Id> casosId) {

        for (Id casoId : casosId) {
             //Verificamos si existe alguna tarea de traslado Colaborador abierta para el Caso
            List<Task> listaTareasAbiertas = new List<Task>();
            if (OT_Proyectos.registroProyecto(casoId) == 'OS') {
                listaTareasAbiertas = [SELECT Id FROM Task WHERE WhatId = :casoId AND Type = 'Traslado Colaborador' AND IsClosed = false AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task')];
                 
            } else {
                listaTareasAbiertas = [SELECT Id FROM Task WHERE WhatId = :casoId AND Type = 'Traslado Colaborador' AND IsClosed = false];
            }

            //Si ya existe alguna tarea de Traslado a Colaborador abierta, no se debe hacer nada. En caso contrario se busca la más reciente de entre las cerradas
            if (listaTareasAbiertas.isEmpty()) {
                List<Task> listaTareasCerradas = [SELECT Id FROM Task WHERE WhatId = :casoId AND Type = 'Traslado Colaborador' AND IsClosed = true
                                                    ORDER BY CreatedDate DESC LIMIT 1];
                List<Task> listaTareas = new List<Task>();

                //Se reabre la última tarea que estaba cerrada
                if (!listaTareasCerradas.isEmpty()) {
                    listaTareasCerradas[0].Status = 'Open';
                    listaTareas.add(listaTareasCerradas[0]);
                }

                if (!listaTareas.isEmpty()) {
                    Database.update(listaTareas);
                }
            }
        }
    }
}