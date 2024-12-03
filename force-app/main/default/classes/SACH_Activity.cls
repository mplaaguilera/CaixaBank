public with sharing class SACH_Activity {

    public static void crearlstTareas(List<Task> lstTarea) {
        Database.insert(lstTarea, false);
    }

    public static Task crearTarea(String recordTypeDeveloperName, Map<String, Object> campos) {
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', recordTypeDeveloperName);
        for (String campo : campos.keySet()) {
            tarea.put(campo, campos.get(campo));
        }
        return tarea;
    }

    public static Event crearEvento(String recordTypeDeveloperName, Map<String, Object> campos) {
        String methodName = 'crearEvento';
        //Alta de tarea
        Id idRecordType = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', recordTypeDeveloperName);
        List<Event> lstEvento = new List<Event>();
        Event evento = new Event();
        
        evento.RecordTypeId = idRecordType;
        for (String campo : campos.keySet()) {
            evento.put(campo, campos.get(campo));
        }
        lstEvento.add(evento);
        List<Database.SaveResult> listInsertResult = Database.insert(lstEvento,false);
        SACH_AppUtilities.displayErrors(methodName,listInsertResult);
        return evento;
    }

    public static void finalizarActividadCaso(Id idCaso, String tipo, String tipoCierre, String descripcion) {
        List<Task> actividades = [SELECT Id FROM Task WHERE Status = 'Open' AND Type = :tipo AND WhatId = :idCaso
                                    WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC];
        for (Task actividad : actividades) {
            actividad.Status = 'Completed';
			actividad.CC_Tipo_Cierre__c = tipoCierre;
			actividad.Description = descripcion;
            actividad.CC_Fecha_Fin__c = System.now();
        }
        Database.update(actividades, false);
    }

    public static void finalizarActividadesCaso(List<Task> lstTareas, String tipo) {
        String methodName = 'finalizarActividadesCaso';
        
        for (Task actividad : lstTareas) {

            actividad.CC_Fecha_Fin__c = System.now();
            actividad.Status = 'Completed';

            if (tipo == 'Traslado Colaborador') {
                actividad.CC_Fecha_1_Reclamacion_Auto__c = null;
                actividad.CC_Fecha_2_Reclamacion_Auto__c = null;
                actividad.CC_Fecha_3_Reclamacion_Auto__c = null;
            }
        }

        List<Database.SaveResult> listInsertResult = Database.update(lstTareas,false);
        SACH_AppUtilities.displayErrors(methodName,listInsertResult);
    }

    public static Id crearActividadRetipificacion(Id idCaso, String tematicaAnterior, String productoAnterior, String motivoAnterior) {
        Case caso = [SELECT CC_MCC_Tematica__r.Name, CC_MCC_ProdServ__r.Name, CC_MCC_Motivo__r.Name FROM Case WHERE Id = :idCaso WITH SECURITY_ENFORCED LIMIT 1];

        if (motivoAnterior != null && motivoAnterior != '') {
            //Crear actividad
            String descripcion = 'Se ha retipificado el caso.\n\n';
            descripcion += 'Clasificación anterior:\n· Temática: '+ tematicaAnterior + '\n· Producto/Servicio: '+ productoAnterior + '\n· Motivo: '+ motivoAnterior + '\n\n';
            descripcion += 'Clasificación nueva:\n· Temática: '+ caso.CC_MCC_Tematica__r.Name + '\n· Producto/Servicio: '+ caso.CC_MCC_ProdServ__r.Name + '\n· Motivo: '+ caso.CC_MCC_Motivo__r.Name + '\n';

            Map<String, Object> camposTarea = new Map<String, Object>();
            camposTarea.put('WhatId', idCaso);
            camposTarea.put('Type', 'Reclasificación');
            camposTarea.put('Subject', 'Reclasificación del caso');
            camposTarea.put('ActivityDate', System.today());
            camposTarea.put('Status', 'Completed');
            camposTarea.put('Description', descripcion);

            Task tarea = crearTarea('SACH_Task', camposTarea);
            List<Task> lstTarea = new List<Task>{tarea};
            crearlstTareas(lstTarea);

			return tarea.Id;
        } else {
            return null;
        }
    }

    public static void reabrirTareaTrasladoColab(Id idCaso) {

        String methodName = 'reabrirTareaTrasladoColab';
        List<Case> lstCase = new List<Case>();
        List<Task> listaTareasCerradas = new List<Task>();

        //Verificamos si ya existe alguna tarea de traslado Colaborador abierta para el Caso
        List<Task> tareasTrasladoAbiertas = [SELECT Id FROM Task
                                                WHERE WhatId = :idCaso AND Type = 'Traslado Colaborador' AND IsClosed = FALSE WITH SECURITY_ENFORCED LIMIT 1];

        //Si existe no es necesario hacer nada. Si no existe se busca la cerrada más reciente para reabrirla
        if (tareasTrasladoAbiertas.isEmpty()) {
            listaTareasCerradas = [SELECT Id FROM Task
                                                WHERE WhatId = :idCaso AND Type = 'Traslado Colaborador' AND IsClosed = TRUE WITH SECURITY_ENFORCED
                                                ORDER BY CreatedDate DESC LIMIT 1];
            if (!listaTareasCerradas.isEmpty()) {
                Case caso = new Case(Id = idCaso);
                caso.Status = 'Pendiente Colaborador';
                lstCase.add(caso);
                
                listaTareasCerradas[0].Status = 'Open';
            }
        }

        List<Database.SaveResult> listInsertResultCase = Database.update(lstCase,false);
        SACH_AppUtilities.displayErrors(methodName,listInsertResultCase);

        List<Database.SaveResult> listInsertResultTask = Database.update(listaTareasCerradas,false);
        SACH_AppUtilities.displayErrors(methodName,listInsertResultTask);
    }

    public static void eliminarTareas(List<Event> lstTareas) {
        String methodName = 'eliminarTarea';
        if (!lstTareas.isEmpty()) {
            List<Database.DeleteResult> listDeleteResult = Database.delete(lstTareas, false);
            SACH_AppUtilities.displayErrorsDelete(methodName, listDeleteResult);
        }
    }
}