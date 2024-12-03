public with sharing class CC_Task_AU_TRHan extends CC_TriggerHandlerBase {

    private static boolean run = true;

    public override void mainEntry(CC_TriggerParameters tp) {
        
         if (runOnce()) {
            process((Map<Id, Task>)tp.newMap, (Map<Id, Task>)tp.oldMap);        
         }
	}
     
    private void process(Map<Id, Task> newMap, Map<Id, Task> oldMap) {
        //Procesar las tareas de CC
        Id recordTypeTask = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        Id recordTypeTaskReadOnly = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'CC_ReadOnly');
        //Procesar las tareas de OS
        Id rtTaskOs = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('OS_Task').getRecordTypeId();
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
}