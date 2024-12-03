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
        }
        
        //Validamos si hay tareas CC_Task
        if (!listNewTask.isEmpty())
        {
            validarCreacionTarea(listNewTask);
            informarCampoLlamada(listNewTask);
        }
        
        //Validamos si hay tareas OS_Task
        if (!listOsTask.isEmpty())
        {
            actualizarNumeroActividades(listOsTask);
            actualizarTieneActividadesLlamada(listOsTask);
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
}