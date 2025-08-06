public class CC_Task_AI_TRHan extends CC_TriggerHandlerBase {
    
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList, (Map<Id, Task>)tp.newMap);
    }
    
    private void process(List<Task> listNewObj, Map<Id, Task> mapNewObj) {
        //marcarComoTareaAutomatica(listNewObj);
        //Obtener las tareas CC_Task
        List<Task> listNewTask = new List<Task>();
        Id ccTaskRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');       
        //Obtener las tareas de OS_Task
        List<Task> listOsTask = new List<Task>();
        Id osTaskRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        //Obtener las tareas de AM_Task
        Id amTaskRTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
        List<Task> listCCOSAMTask = new List<Task>();
        
        for (Task taskObj : listNewObj)
        {
            if (taskObj.RecordTypeId == ccTaskRTId)
            {
                listNewTask.add(taskObj);
            }
            
            if (taskObj.RecordTypeId == osTaskRTId)
            {
                listOsTask.add(taskObj);
            }

            if (taskObj.RecordTypeId == ccTaskRTId || taskObj.RecordTypeId == osTaskRTId || taskObj.RecordTypeId == amTaskRTId)
            {
                listCCOSAMTask.add(taskObj);
            }
        }
        
        //Validamos si hay tareas CC_Task
        if (!listNewTask.isEmpty())
        {
            validarCreacionTarea(listNewTask);
            informarCampoLlamada(listNewTask);
            casoGestionTareasNoTiempo(listNewTask);  
            //informarTipoTarea(listNewTask);
            actualizarCases(listNewTask); //Actualizar cases dependiendo de si son tareas de traslado a tercer nivel o tareas personalizadas (si son tareas con whatId case)
            notificarCasoACliente(listNewTask); //Comprueba si debe llamar al método gestionarSeguimientoCliente
            actualizarPropietario(listNewTask); //Comprueba si debe llamar al método actualizarPropietarioTareas
            crearReclamacionMaximo(listNewTask); //Comprueba si debe llamar al método crearReclamacionMaximo
            cierreAutomaticoSolicitudInformacion(listNewTask); //Comprobar si debe lanzar schedulable para cerrar solicitud informacion
            CC_Calculo_KPI_Tareas.rellenarKPI(listNewTask); //Rellenar el KPI de las tareas
        }
        
        //Validamos si hay tareas OS_Task
        if (!listOsTask.isEmpty())
        {
            actualizarNumeroActividades(listOsTask);
            actualizarTieneActividadesLlamada(listOsTask);
        }

        if (!listCCOSAMTask.isEmpty()) {
            schedulablesTask(listCCOSAMTask, ccTaskRTId, osTaskRTId, amTaskRTId); //Comprueba si debe llamar a schedulables
        }
    }
    
    /*
    //Marca el flag "Automática" en caso de haber creado la tarea el usuario "System" o "Automated Process")
    private void marcarComoTareaAutomatica(List<Task> listNewObj) {
        
        List<Task> tareasUpdate = new List<Task>();
        
        for (Task tarea : listNewObj) {
            //Es necesario usar el Id porque en After Insert aún no se pueden consultar las joins
            if (tarea.CreatedById == [SELECT Id FROM User WHERE Name = 'System'].Id
            || tarea.CreatedById == [SELECT Id FROM User WHERE Name = 'Automated Process'].Id) {
                Task tareaBD = new Task(Id = tarea.Id);
                tareaBD.CC_Automatica__c = true;
                tareasUpdate.add(tareaBD);
            }
        }
        
        if (!tareasUpdate.isEmpty()) {
            update tareasUpdate;
        }
    }
    */
    
    /*
    && !tarea.Subject.toLowerCase().contains('acuse')
    && !tarea.Subject.toLowerCase().contains('contacto intermedio')
    */
    
    
    //Comprueba si está permitido crear la nueva tarea
    private void validarCreacionTarea(List<Task> listNewObj) {
        
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
            Id cc_Task_RTId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
            
            Set<Id> idsUsuarios = new Set<Id>();
            List<User> usuarios = [SELECT Id FROM User WHERE Name IN ('System','Automated Process','Administrador de sistema')];        
            for(User usuario : usuarios){
                idsUsuarios.add(usuario.Id);
            }
            
            Map<Id, Id> caseIdWithOwner = new Map<Id, Id>();
            Set<Id> idsCasos = new Set<Id>();
            for(Task tarea : listNewObj)
            {
                if (tarea.WhatId != null
                && (tarea.WhatId.getSObjectType().getDescribe().getName() == 'Case') && (tarea.RecordTypeId == cc_Task_RTId))
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
                && (tarea.WhatId.getSObjectType().getDescribe().getName() == 'Case') && (tarea.RecordTypeId == cc_Task_RTId)) { //Tareas hijas de casos
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
    
    private void informarCampoLlamada(List<Task> listNewObj)
    {
        List<id> lstNuevasTareas = new List<Id>(); 
        
        for(Task tareaToUpdate : listNewObj) { 
            
            //if (tareaToUpdate.Type != 'Cerrado' && tareaToUpdate.Type != 'Cierre Automático' && tareaToUpdate.Type != 'Cierre automático fallido' 
            if ((tareaToUpdate.Type.startsWith('Llamada') || tareaToUpdate.Type.startsWith('Consulta') || tareaToUpdate.Type.startsWith('Encuesta'))
                && tareaToUpdate.CC_Llamada_Id__c == null) 
            {
                lstNuevasTareas.add(tareaToUpdate.id);
            }
        }
        if(!lstNuevasTareas.isEmpty()){
            CC_Llamada_GC.informarLlamadaEnCurso(lstNuevasTareas);    
        }
    }
    
    private void actualizarNumeroActividades(List<Task> listNewObj)
    {
        List<id> lstNewTasks = new List<Id>(); 
        
        for(Task nuevaTarea : listNewObj) { 
            
            lstNewTasks.add(nuevaTarea.WhatId);       
        }
        
        OS_Numero_Actividades.sumarTask(lstNewTasks); 
    }
    private void actualizarTieneActividadesLlamada(List<Task> listNewObj)
    {
        List<id> idsLlamadas = new List<Id>(); 
        
        for(Task nuevaTarea : listNewObj) { 
            if (nuevaTarea.CC_Llamada_Id__c != null) {
                idsLlamadas.add(nuevaTarea.CC_Llamada_Id__c);
            }
        }
        if (!idsLlamadas.isEmpty()) {
            List<CC_Llamada__c> llamadas = [SELECT Id, OS_Tiene_Actividades__c FROM CC_Llamada__c WHERE Id IN :idsLlamadas];
            if (!llamadas.isEmpty()){
                for(CC_Llamada__c llamada : llamadas) { 
                    llamada.OS_Tiene_Actividades__c = true;
                }
                update llamadas;
            }
            
        }       
    }

    /*private void informarTipoTarea(List<Task> listNewObj) {
        List<Task> tareasUpdate = new List<Task>();
        for(Task tarea : listNewObj) {
            Task tareaUpdate = new Task();
            tareaUpdate.Id = tarea.Id;
            tareaUpdate.AV_Type__c = tarea.Type;
            tareasUpdate.add(tareaUpdate);
        }
        update tareasUpdate;
    }*/

    private void actualizarCases(List<Task> listNewObj) {
        //Set de ids para buscar los casos
        Set<Id> setIdsCases = new Set<Id>();
        //Mapa para guardar las ids de los casos que deben cambiar el traslado tercer nivel
        Map<Id, Id> mapaIdCasoTrasladoTercerNivel = new Map<Id, Id>();
        //Mapa para guardar las ids de los casos que deben cambiar la respuesta personalizada
        Map<Id, Id> mapaIdCasoRespuestaPersonalizada = new Map<Id, Id>();

        for (Task newTarea : listNewObj) {
            //Si la tarea tiene un what id y este es un Case
            if (String.isNotBlank(newTarea.WhatId) && newTarea.WhatId.getSObjectType().getDescribe().getName() == 'Case') {
                //Si es una tarea de traslado a tercer nivel
                if (newTarea.Type == 'Traslado Tercer Nivel') {
                    setIdsCases.add(newTarea.WhatId);
                    mapaIdCasoTrasladoTercerNivel.put(newTarea.WhatId, newTarea.WhatId);
                }
                //Si es una tarea con subject Personalizada
                if (newTarea.Subject == 'Personalizada') {
                    setIdsCases.add(newTarea.WhatId);
                    mapaIdCasoRespuestaPersonalizada.put(newTarea.WhatId, newTarea.WhatId);
                }
            }
        }

        //Buscar casos encontrados y comprobar si requieren actualización
        if (!setIdsCases.isEmpty()) {
            List<Case> listaCasos = [SELECT Id, CC_Trasladado_Tercer_Nivel__c, CC_Respuesta_Personalizada__c FROM Case WHERE Id IN :setIdsCases];

            //Mapa para guardar los casos a actualizar
            Map<Id, Case> mapaCasosActualizar = new Map<Id, Case>();
            //Recorrer los casos de la query
            for (Case caso : listaCasos) {
                //Si el traslado nivel 3 del caso es distinto a true y este caso está en el mapa de los que deben cambiar su traslado tercer nivel, se debe poner en true
                if (caso.CC_Trasladado_Tercer_Nivel__c != true && mapaIdCasoTrasladoTercerNivel.containsKey(caso.Id)) {
                    if (mapaCasosActualizar.containsKey(caso.Id)) {
                        mapaCasosActualizar.get(caso.Id).CC_Trasladado_Tercer_Nivel__c = true;
                    } else {
                        Case casoActualizar = new Case();
                        casoActualizar.Id = caso.Id;
                        casoActualizar.CC_Trasladado_Tercer_Nivel__c = true;
                        mapaCasosActualizar.put(casoActualizar.Id, casoActualizar);
                    }
                }
                //Si la respuesta personalizada del caso es distinta a true y este caso está en el mapa de los que deben cambiar su respuesta personalizada, se debe poner en true
                if (caso.CC_Respuesta_Personalizada__c != true && mapaIdCasoRespuestaPersonalizada.containsKey(caso.Id)) {
                    if (mapaCasosActualizar.containsKey(caso.Id)) {
                        mapaCasosActualizar.get(caso.Id).CC_Respuesta_Personalizada__c = true;
                    } else {
                        Case casoActualizar = new Case();
                        casoActualizar.Id = caso.Id;
                        casoActualizar.CC_Respuesta_Personalizada__c = true;
                        mapaCasosActualizar.put(casoActualizar.Id, casoActualizar);
                    }
                }
            }

            if (!mapaCasosActualizar.isEmpty()) {
                update mapaCasosActualizar.values();
            }
        }
    }

    private void notificarCasoACliente(List<Task> listNewObj) {
        //Obtener los tipos de tarea desde la Custom Metadata
        List<CC_ConfigNotifCliente__mdt> configs = [SELECT CC_TiposTareaCaso__c
                                                    FROM CC_ConfigNotifCliente__mdt
                                                    WHERE DeveloperName = 'CC_SegOperativa' LIMIT 1];
        
        if (!configs.isEmpty()) {
            List<Id> listaIdsTask = new List<Id>();
            for (Task task : listNewObj) {
                if (configs[0].CC_TiposTareaCaso__c.contains(task.Type)) {
                    listaIdsTask.add(task.Id);
                }
            }

            //Llamada apex
            if (!listaIdsTask.isEmpty()) {
                CC_NotifSegCaso.gestionarSeguimientoCliente(listaIdsTask);
            }
        }
    }

    private void actualizarPropietario(List<Task> listNewObj) {
        List<Id> listaIdsTask = new List<Id>();
        for (Task newTask : listNewObj) {
            if (newTask.IsClosed == false) {
                listaIdsTask.add(newTask.Id);
            }
        }

        if (!listaIdsTask.isEmpty()) {
            CC_Task.actualizarPropietarioTareas(listaIdsTask);
        }
    }

    private void crearReclamacionMaximo(List<Task> listNewObj) {
        List<Id> listaIdsTask = new List<Id>();
        for (Task newTask : listNewObj) {
            if (newTask.Type == 'Actividad manual' && newTask.Subject == 'Reclamación de cliente') {
                listaIdsTask.add(newTask.Id);
            }
        }

        if (!listaIdsTask.isEmpty()) {
            CC_Task_Methods.crearReclamacionMaximo(listaIdsTask);
        }
    }

    private void schedulablesTask(List<Task> listNewObj, Id ccTaskRTId, Id osTaskRTId, Id amTaskRTId) {
        List<Task> listataskVerifCliente = new List<Task>();
        Set<Id> setIdsCases = new Set<Id>();
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

        for (Task newTask : listNewObj) {
            if (newTask.RecordTypeId == ccTaskRTId && newTask.Subject == 'Verificación cliente') {
                //Si el whatid es de case, guardar id para updatear el status del caso
                if (String.isNotBlank(newTask.WhatId) && newTask.WhatId.getSObjectType().getDescribe().getName() == 'Case') {
                    setIdsCases.add(newTask.WhatId);
                }
                //Preparar schedulable
                CBK_SCH_PendingProcess__c pendingProcessTask = new CBK_SCH_PendingProcess__c();
                pendingProcessTask.recordId__c = newTask.Id;
                pendingProcessTask.Schedule_Time__c = newTask.CreatedDate.addHours(24);
                pendingProcessTask.className__c = 'CC_SchedulableTask';
                pendingProcessTask.Param1__c = 'CC_Task_Verificacion_Cliente';
                listaPendingProcess.add(pendingProcessTask);
            } 
            else if (newTask.Type == 'Traslado Colaborador' && newTask.Status == 'Open' && (newTask.RecordTypeId == ccTaskRTId || newTask.RecordTypeId == osTaskRTId || newTask.RecordTypeId == amTaskRTId)) {
                //Preparar a schedulables
                //Para CC_Fecha_1_Reclamacion_Auto__c
                if (newTask.CC_Fecha_1_Reclamacion_Auto__c != null) {
                    CBK_SCH_PendingProcess__c pendingProcessTask2 = new CBK_SCH_PendingProcess__c();
                    pendingProcessTask2.recordId__c = newTask.Id;
                    pendingProcessTask2.Schedule_Time__c = newTask.CC_Fecha_1_Reclamacion_Auto__c; 
                    pendingProcessTask2.className__c = 'CC_SchedulableTask';
                    pendingProcessTask2.Param1__c = 'sendMailRecTrasladoColab';
                    listaPendingProcess.add(pendingProcessTask2);
                }
                
                if (newTask.CC_Fecha_2_Reclamacion_Auto__c != null) {
                    //Para CC_Fecha_2_Reclamacion_Auto__c
                    CBK_SCH_PendingProcess__c pendingProcessTask3 = new CBK_SCH_PendingProcess__c();
                    pendingProcessTask3.recordId__c = newTask.Id;
                    pendingProcessTask3.Schedule_Time__c = newTask.CC_Fecha_2_Reclamacion_Auto__c;
                    pendingProcessTask3.className__c = 'CC_SchedulableTask';
                    pendingProcessTask3.Param1__c = 'sendMailRecTrasladoColab';
                    listaPendingProcess.add(pendingProcessTask3);
                }

                if (newTask.CC_Fecha_3_Reclamacion_Auto__c != null) {
                    //Para CC_Fecha_3_Reclamacion_Auto__c
                    CBK_SCH_PendingProcess__c pendingProcessTask4 = new CBK_SCH_PendingProcess__c();
                    pendingProcessTask4.recordId__c = newTask.Id;
                    pendingProcessTask4.Schedule_Time__c = newTask.CC_Fecha_3_Reclamacion_Auto__c;
                    pendingProcessTask4.className__c = 'CC_SchedulableTask';
                    pendingProcessTask4.Param1__c = 'sendMailRecTrasladoColab';
                    listaPendingProcess.add(pendingProcessTask4);
                }
                
                if (newTask.OS_Fecha_Fin_Reclamacion_Auto__c != null) {
                    //Para OS_Fecha_Fin_Reclamacion_Auto__c
                    CBK_SCH_PendingProcess__c pendingProcessTask5 = new CBK_SCH_PendingProcess__c();
                    pendingProcessTask5.recordId__c = newTask.Id;
                    pendingProcessTask5.Schedule_Time__c = newTask.OS_Fecha_Fin_Reclamacion_Auto__c;
                    pendingProcessTask5.className__c = 'CC_SchedulableTask';
                    pendingProcessTask5.Param1__c = 'sendMailRecTrasladoColab';
                    listaPendingProcess.add(pendingProcessTask5);
                }
            }
        }

        //Buscar casos encontrados y comprobar si requieren actualización
        if (!setIdsCases.isEmpty()) {
            List<Case> listaCasos = [SELECT Id, Status FROM Case WHERE Id IN :setIdsCases];

            if (!listaCasos.isEmpty()) {
                List<Case> listaCasosActualizar = new List<Case>();
                for (Case casoActualizar : listaCasos) {
                    if (casoActualizar.Status != 'Pendiente Cliente') {
                        casoActualizar.Status = 'Pendiente Cliente';
                        listaCasosActualizar.add(casoActualizar);
                    }
                }

                if (!listaCasosActualizar.isEmpty()) {
                    update listaCasosActualizar;
                }
            }
        }

        //Insertar pending process en caso de que los haya
        if (!listaPendingProcess.isEmpty()) {
            insert listaPendingProcess;
        }
    }

    private void cierreAutomaticoSolicitudInformacion(List<Task> listNewObj) {
        List<CBK_SCH_PendingProcess__c> listaPendingProcess = new List<CBK_SCH_PendingProcess__c>();

        for (Task newTask : listNewObj) {
            if (String.isNotBlank(newTask.WhatId) && newTask.WhatId.getSObjectType().getDescribe().getName() == 'Case' && newTask.Type == 'Solicitud Información' && newTask.Status == 'Open' && newTask.CC_Fecha_FinPlazo_SolInf__c != null) {
                //Preparar schedulable
                CBK_SCH_PendingProcess__c pendingProcessTask = new CBK_SCH_PendingProcess__c();
                pendingProcessTask.recordId__c = newTask.WhatId;
                pendingProcessTask.Schedule_Time__c = newTask.CC_Fecha_FinPlazo_SolInf__c;
                pendingProcessTask.className__c = 'CC_SchedulableTask';
                pendingProcessTask.Param1__c = 'sendMailSolicitudInf';
                listaPendingProcess.add(pendingProcessTask);
            }
        }

        //Insertar pending process en caso de que los haya
        if (!listaPendingProcess.isEmpty()) {
            insert listaPendingProcess;
        }
    }

    private void casoGestionTareasNoTiempo(List<Task> listNewObj) {
        List<Id> listaIdsCasosContador = new List<Id>(); //Solo para los que tienen que actualizar el contador de reclamaciones
        Map<Id, Case> mapCasosActualizar = new Map<Id, Case>();
        for (Task newTask : listNewObj) {
            if(String.isNotBlank(newTask.WhatId) && newTask.WhatId.getSObjectType().getDescribe().getName() == 'Case'){
                //Creo el caso que va a modificarse con las acciones de las tareas
                if (newTask.Subject == 'Reclamación de cliente') {
                    if (mapCasosActualizar.containsKey(newTask.WhatId)) {
                        mapCasosActualizar.get(newTask.WhatId).CC_Fecha_Ultima_Reclamacion__c = CBK_UtilsDate.nowSYS();
                    } else {
                        Case caso = new Case();
                        caso.Id = newTask.WhatId;
                        caso.CC_Fecha_Ultima_Reclamacion__c = CBK_UtilsDate.nowSYS();
                        mapCasosActualizar.put(caso.Id, caso);
                    }
                    
                    listaIdsCasosContador.add(newTask.WhatId); //Listado para llamar a la clase que actualiza el contador de reclamaciones
                }
                if(newTask.Status == 'Rechazada' && (newTask.Type == 'Traslado Colaborador' || newTask.Type == 'Solicitud Información')){
                    if (mapCasosActualizar.containsKey(newTask.WhatId)) {
                        mapCasosActualizar.get(newTask.WhatId).Status = 'Activo';
                    } else {
                        Case caso = new Case();
                        caso.Id = newTask.WhatId;
                        caso.Status = 'Activo';
                        mapCasosActualizar.put(caso.Id, caso);
                    }
                }
                if(newTask.Subject == 'Verificación Cliente' && newTask.Status == 'Completed'){ 
                    if (mapCasosActualizar.containsKey(newTask.WhatId)) {
                        mapCasosActualizar.get(newTask.Id).Status = 'Activo';
                    } else {
                        Case caso = new Case();
                        caso.Id = newTask.WhatId;
                        caso.Status = 'Activo';
                        mapCasosActualizar.put(caso.Id, caso);
                    }
                }
            }
        }

        if(!listaIdsCasosContador.isEmpty()){
            CC_Case_Reclamaciones_Cliente.actualizarContadorReclamacionesCliente(listaIdsCasosContador);
        }
        if (!mapCasosActualizar.isEmpty()) {
            update mapCasosActualizar.values();
        }
    }
}