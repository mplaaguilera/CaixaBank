public with sharing class HDT_Task_AI_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap);
    }

    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj) {
        Id hdtTaskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        List<Task> listHdtTask = new List<Task>();
        List<Id> listHdtTaskMaximo = new List<Id>();
        for (Task taskObj : listNewObj) {
            if (taskObj.RecordTypeId == hdtTaskRTId) {
                listHdtTask.add(taskObj);
                if(taskObj.Type == 'Actividad Manual' && taskObj.Subject == 'Reclamación de cliente'){
                    listHdtTaskMaximo.add(taskObj.Id);
                }
            }
        }

        //Validamos si hay tareas que necesitan crear Reclamación Maximo
        if (!listHdtTaskMaximo.isEmpty())
        {
            CC_Task_Methods.crearReclamacionMaximo(listHdtTaskMaximo);
        }

        //Validamos si hay tareas HDT_Task
        if (!listHdtTask.isEmpty())
        {
            actualizarNumeroActividades(listHdtTask);
            actualizarTieneActividadesLlamada(listHdtTask);
        }
    }

    @Testvisible
    //Comprueba si está permitido crear la nueva tarea
    private static void validarCreacionTarea(List<Task> listNewObj) {

        Boolean validarActividadManual = false;
        for(Task tareaToUpdate : listNewObj) {
            if (tareaToUpdate.Type == 'Actividad manual')
            {
                validarActividadManual = true;
                break;
            }
        }

        if (validarActividadManual)
        {

            Id hdtTaskRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');

            Set<Id> idsUsuarios = new Set<Id>();
            List<User> usuarios = [SELECT Id FROM User WHERE Name IN ('System','Automated Process','Administrador de sistema')];
            for(User usuario : usuarios){
                idsUsuarios.add(usuario.Id);
            }

            Map<Id, Id> caseIdWithOwner = new Map<Id, Id>();
            Set<Id> idsCasos = new Set<Id>();
            for(Task tarea : listNewObj)
            {
                system.debug('++++ PRUEBAS ++++');
                system.debug(tarea.WhatId);
                system.debug(tarea.WhatId.getSObjectType().getDescribe().getName());
                system.debug(tarea.CreatedById);



                if (tarea.WhatId != null
                && (tarea.WhatId.getSObjectType().getDescribe().getName() == 'Case') && (tarea.RecordTypeId == hdtTaskRTId))
                {
                    idsCasos.add(tarea.WhatId);
                    //caseIdWithOwner.put(tarea.WhatId, tarea.OwnerId);
                }
            }

            for(Case caso : [SELECT Id, OwnerId FROM Case WHERE Id IN :idsCasos]){
                caseIdWithOwner.put(caso.Id, caso.OwnerId);
            }

            for (Task tarea : listNewObj) {
                if (tarea.WhatId != null
                && (tarea.WhatId.getSObjectType().getDescribe().getName() == 'Case') && (tarea.RecordTypeId == hdtTaskRTId)) { //Tareas hijas de casos
                    //Solo pueden crear actividades los propietarios del caso (excepto ciertos tipos)
                    if ((tarea.Type == 'Actividad manual')
                    &&  (!idsUsuarios.contains(tarea.CreatedById))
                    && caseIdWithOwner.get(tarea.WhatId) != UserInfo.getUserId()
                    && tarea.Subject != 'Reclamación de cliente' && tarea.Subject != 'Gestiones a realizar')  {
                        //Rollback del insert de la tarea
                        tarea.addError('Solo los propietarios de un caso pueden dar de alta este tipo de tareas.');
                    }
                }
            }
        }

    }

    @Testvisible
    private static void informarCampoLlamada(List<Task> listNewObj)
    {
        List<id> lstNuevasTareas = new List<Id>();

        for(Task tareaToUpdate : listNewObj) {

            if (tareaToUpdate.Type != 'Cerrado' && tareaToUpdate.Type != 'Cierre Automático' && tareaToUpdate.Type != 'Cierre automático fallido'
            && tareaToUpdate.CC_Llamada_Id__c == null)
            {
                lstNuevasTareas.add(tareaToUpdate.id);
            }
        }
        if (!lstNuevasTareas.isEmpty()) {
            CC_Llamada.informarLlamadaEnCurso(lstNuevasTareas);
        }
    }

    private void actualizarNumeroActividades(List<Task> listNewObj) {
        List<id> lstNewTasks = new List<Id>();
        for(Task nuevaTarea : listNewObj) {
            lstNewTasks.add(nuevaTarea.WhatId);
        }
        OS_Numero_Actividades.sumarTask(lstNewTasks);
    }

    private void actualizarTieneActividadesLlamada(List<Task> listNewObj) {
        List<id> idsLlamadas = new List<Id>();

        for(Task nuevaTarea : listNewObj) {
            if (nuevaTarea.CC_Llamada_Id__c != null) {
                idsLlamadas.add(nuevaTarea.CC_Llamada_Id__c);
            }
        }
        if (!idsLlamadas.isEmpty()) {
            List<CC_Llamada__c> llamadas = [SELECT OS_Tiene_Actividades__c FROM CC_Llamada__c WHERE Id IN :idsLlamadas];
            if (!llamadas.isEmpty()){
                for(CC_Llamada__c llamada : llamadas) {
                    llamada.OS_Tiene_Actividades__c = true;
                }
                update llamadas;
            }

        }
    }
}