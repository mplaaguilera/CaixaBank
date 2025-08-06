public with sharing class CC_Task_AU_TRHan extends CC_TriggerHandlerBase {

    private static boolean run = true;

    public override void mainEntry(CC_TriggerParameters tp) {
        System.Debug('::PROCESS'+(Map<Id, Task>)tp.newMap);
         if (runOnce()) {
            process((Map<Id, Task>)tp.newMap, (Map<Id, Task>)tp.oldMap);        
         }
	}
     
    private void process(Map<Id, Task> newMap, Map<Id, Task> oldMap) {
        //Procesar las tareas de CC
        Id recordTypeTask = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_Task');
        Id recordTypeTaskReadOnly = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_ReadOnly');
        //Procesar las tareas de OS
        Id rtTaskOs = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        //Set<Id> setTareas = new Set<Id>();
        Set<Task> setTareasUpdate = new Set<Task>();
        Set<Task> setTareasUpdateReadOnly = new Set<Task>();
        Set<Task> setTaskUpdateCops = new Set<Task>();

        for (Id tareaId : newMap.keySet()) {                
            if (newMap.get(tareaId).RecordTypeId == recordTypeTask) {
                //setTareas.add(newMap.get(tareaId).Id);
                setTareasUpdate.add(newMap.get(tareaId));                   
            }
              //tareas readonly
            if (newMap.get(tareaId).RecordTypeId == recordTypeTaskReadOnly) {
                setTareasUpdateReadOnly.add(newMap.get(tareaId));                   
            }
            //Tareas COPS
            if (newMap.get(tareaId).RecordTypeId == rtTaskOs) {
                setTaskUpdateCops.add(newMap.get(tareaId));                   
            }            
        }
        if (!setTareasUpdate.isEmpty()) {
            actualizarTasks(setTareasUpdate);
            informarCampoLlamada(setTareasUpdate);
            casoGestionTareasNoTiempo(setTareasUpdate, oldMap);
            generarOportunidadLlamadaFinalizada(setTareasUpdate, oldMap);
        }     
         if (!setTareasUpdateReadOnly.isEmpty()) {
            cambiarRTyRechazarCasoRona(setTareasUpdateReadOnly);
        } 
        if (!setTaskUpdateCops.isEmpty()) {
            reactivarCaso(setTaskUpdateCops, oldmap);
        }  
    }
    
    public static void actualizarTasks(Set<Task> tareas) {
        //List<Task> tareas = [SELECT LastModifiedDate FROM Task WHERE Id IN :idTareas];
        List<Task> tareasUpdate = new List<Task>();
        for (Task tarea : tareas) {
            Task tareaUpdate = new Task();
            tareaUpdate.Id = tarea.Id;
            tareaUpdate.CC_Ultima_Actualizacion__c = tarea.LastModifiedDate;
            //tareaUpdate.AV_Type__c = tarea.Type;
            tareasUpdate.add(tareaUpdate);
        }        
        update tareasUpdate;
    }
    
    private void informarCampoLlamada(Set<Task> tareas)
    {
        List<id> lstNuevasTareas = new List<Id>(); 
        
        for(Task tareaToUpdate : tareas) {
            
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
    
    private void reactivarCaso(Set<Task> tareas, Map<Id, Task> oldMap){
        List<Id> caseIds = new List<Id>();
        List<Case> casesUpdate = new List<Case>();
        
        for(Task tarea : tareas){
            if(tarea.Status != oldMap.get(tarea.id).Status){
                if(tarea.Status == 'Rechazada' && (tarea.Type == 'Traslado Colaborador' || tarea.Type == 'Solicitud Información')){
                    caseIds.add(tarea.WhatId); 
                }
            }
        }
        for (Case caso : [SELECT id, Status FROM Case WHERE id IN :caseIds AND Status != 'Activo']) {
            caso.Status = 'Activo';
            casesUpdate.add(caso); 
        }
        Update casesUpdate;
    }

    private void cambiarRTyRechazarCasoRona(Set<Task> tareas){
        List<Case> casesUpdate = new List<Case>();
        List<Id> caseIds = new List<Id>();
        List<CC_Llamada__c> llamadaUpdate = new List<CC_Llamada__c>();
        List<Id> llamadaIds = new List<Id>();
         Id usuarioBluewolfId = [SELECT Id FROM User WHERE Name = 'Bluewolf'].Id;
        
        for(Task t : [SELECT WhatId, CC_Llamada_Id__c FROM Task WHERE Id IN :tareas AND Type = 'Llamada entrante']){
            if(!String.isBlank(t.WhatId)){
                caseIds.add(t.WhatId);
            }
             if(!String.isBlank(t.CC_Llamada_Id__c)){
                llamadaIds.add(t.CC_Llamada_Id__c);
            }
            
            
        }
        if(!caseIds.isEmpty()){
            Id recordTypeIdReadOnly = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_ReadOnly');
                for(Case caso : [SELECT id, Status, RecordTypeId, OwnerId FROM Case WHERE Id IN :caseIds]){
                    caso.Status = 'Rechazado';
                    caso.RecordTypeId = recordTypeIdReadOnly;
                    caso.OwnerId = usuarioBluewolfId;
                    casesUpdate.add(caso);
                }
        }
          if(!llamadaIds.isEmpty()){
            Id recordTypeIdReadOnlyLlamada = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Llamada__c', 'CC_ReadOnly');
                for(CC_Llamada__c llamada : [SELECT id, RecordTypeId, OwnerId FROM CC_Llamada__c WHERE Id IN :llamadaIds]){
                    llamada.RecordTypeId = recordTypeIdReadOnlyLlamada;
                    llamada.OwnerId = usuarioBluewolfId;
                    llamadaUpdate.add(llamada);
                }
        }
        update casesUpdate;
        update llamadaUpdate;
    }

    public static Boolean runOnce() {
        if (run) {
            run = false;
            return true;
        } else {
            return run;       
        }          
    }


    private void casoGestionTareasNoTiempo(Set<Task> setTareasUpdate, Map<Id, Task> oldMap) {
        Map<Id, Case> mapCasosActualizar = new Map<Id, Case>();
        for (Task newTask : setTareasUpdate) {
            if(String.isNotBlank(newTask.WhatId) && newTask.WhatId.getSObjectType().getDescribe().getName() == 'Case'){
                //Creo el caso que va a modificarse con las acciones de las tareas
                if(oldMap.containsKey(newTask.Id) && oldMap.get(newTask.Id).Status != newTask.Status && newTask.Status == 'Rechazada' && (newTask.Type == 'Traslado Colaborador' || newTask.Type == 'Solicitud Información')){
                    if (mapCasosActualizar.containsKey(newTask.WhatId)) {
                        mapCasosActualizar.get(newTask.Id).Status = 'Activo';
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

        if(!mapCasosActualizar.isEmpty()){
            update mapCasosActualizar.values();
        }
    }

    private void generarOportunidadLlamadaFinalizada(Set<Task> setTareasUpdate, Map<Id, Task> oldMap) {
        List<Task> tareasParaCrearOportunidad = new List<Task>();
        Set<Id> caseIds = new Set<Id>();
        
        // Recopilar los IDs de casos para consultar las extensiones
        for(Task tarea : setTareasUpdate) {
            if(oldMap.get(tarea.Id).Status != tarea.Status && tarea.Status == 'Completed' && tarea.CC_Tipo_Cierre__c == 'Llamada finalizada') {
                if(tarea.CC_Llamada_Id__c != null && tarea.WhatId != null){
                    caseIds.add(tarea.WhatId);
                }
            }
        }
        
        // Consultar las extensiones de casos para verificar el campo CC_CrearOportunidadTrigger__c
        Map<Id, CBK_Case_Extension__c> caseExtensionsMap = new Map<Id, CBK_Case_Extension__c>();
        if(!caseIds.isEmpty()) {
            for(CBK_Case_Extension__c extension : [SELECT Id, Case_Id__c, CC_CrearOportunidadTrigger__c 
                                                   FROM CBK_Case_Extension__c 
                                                   WHERE Case_Id__c IN :caseIds]) {
                caseExtensionsMap.put(extension.Case_Id__c, extension);
            }
        }
        
        for(Task tarea : setTareasUpdate) {
            if(oldMap.get(tarea.Id).Status != tarea.Status && tarea.Status == 'Completed' && tarea.CC_Tipo_Cierre__c == 'Llamada finalizada') {
                if(tarea.CC_Llamada_Id__c != null && tarea.WhatId != null){
                    // Verificar si el campo CC_CrearOportunidadTrigger__c está activo
                    Boolean crearOportunidadTrigger = false;
                    if(caseExtensionsMap.containsKey(tarea.WhatId)) {
                        crearOportunidadTrigger = caseExtensionsMap.get(tarea.WhatId).CC_CrearOportunidadTrigger__c;
                    }
                    
                    // Verificar si se puede crear oportunidad si el campo está a True
                    if(crearOportunidadTrigger) {
                        // Verificar si se puede crear oportunidad
                        Map<String, Object> validacion = CC_Gestion_Derivar_CSBD.crearOportunidad(tarea.WhatId);
                        
                        if((Boolean)validacion.get('validacionCrearOportunidad')) {
                            tareasParaCrearOportunidad.add(tarea);
                        }
                    } else {
                        System.debug('No se creará oportunidad para el caso ' + tarea.WhatId + ' porque CC_CrearOportunidadTrigger__c no está activo');
                    }
                }
            }
        }
        
        // Crear oportunidades para las tareas válidas
        if(!tareasParaCrearOportunidad.isEmpty()) {
            for(Task tarea : tareasParaCrearOportunidad) {
                try {
                    Map<String, Object> resultado = CC_Gestion_Derivar_CSBD.crearOportunidadCSBD(tarea.WhatId);
                    
                    if((Boolean)resultado.get('oppCreada')) {
                        // Oportunidad creada exitosamente
                        System.debug('Oportunidad creada exitosamente para el caso: ' + tarea.WhatId + ' desde tarea: ' + tarea.Id);
                    } else if(resultado.containsKey('oportunidadSiExiste') && (Boolean)resultado.get('oportunidadSiExiste')) {
                        // Ya existe una oportunidad similar
                        System.debug('Oportunidad similar ya existe para el caso: ' + tarea.WhatId + ' - Mensaje: ' + resultado.get('mensaje'));
                    }
                } catch (Exception e) {
                    System.debug('Error al crear oportunidad para el caso ' + tarea.WhatId + ' desde tarea ' + tarea.Id + ': ' + e.getMessage());
                }
            }
        }
    }
}