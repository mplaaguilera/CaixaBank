public with sharing class TMS_Task_BI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<Task>)tp.newList);
    }

    private void process(List<Task> listNewObj) {
        List<Task> listTMS = new List<Task>(descartarTareasNoTMS(listNewObj));
        if(!listTMS.isEmpty()){
            modifyTasks(listTMS);
        }
    }

    private static void modifyTasks(List<Task> tareasTMS) {
        List<Id> idCasosTareas = new List<Id>();

        //Primero se calcula los dos días en milisegundos
        Long intervaloDias = 2 * 24 * 60 * 60 * 1000;
        
        //Se guarda el horario laboral a partir de la query de la BusinessHours que se llama TMS_Horario_Laboral
        BusinessHours horarioLaboral = [SELECT Id FROM BusinessHours WHERE Name = 'TMS_Horario_Laboral'];

        //Se itera sobre las distintas tareas
        for (Task tarea : tareasTMS) {

            //Se comprueba que no se ha seleccionado un día de expiración por lo que se añaden dos días laborales respecto a la fecha actual
            if(tarea.ActivityDate == null){                
                tarea.ActivityDate = BusinessHours.add(horarioLaboral.Id, System.Now(), intervaloDias).date();
            }

            if(!idCasosTareas.contains(tarea.WhatId)){
                idCasosTareas.add(tarea.WhatId);
            }
        }
        
        Map<Id, Case> mapaCasos= new Map<Id, Case>([SELECT Id, Status, TMS_Numexp__c, OwnerId FROM Case WHERE Id IN :idCasosTareas]);
        List<Case> casos =[SELECT Status FROM Case WHERE Id IN :mapaCasos.keySet()];
        List<String> estados = new List<String>();
        if(!casos.isEmpty()){
            for (Case caso : casos) {
                estados.add(caso.Status);
            }
        }
        List<CaseStatus> estadoCaso =[SELECT MasterLabel, ApiName FROM CaseStatus WHERE ApiName IN :estados];
        Map<String, String> mapaEstados = new Map<String, String>();
        for (CaseStatus caso : estadoCaso) {
            mapaEstados.put(caso.ApiName, caso.MasterLabel);
        }
        if(!mapaCasos.isEmpty() && !mapaEstados.isEmpty()){
            for (Task tarea : tareasTMS) {
                if (mapaCasos.containsKey(tarea.WhatId) && (tarea.type == 'Actividad manual' || tarea.type == 'Envio correo')){
                    tarea.CC_Consulta__c = mapaCasos.get(tarea.WhatId).TMS_Numexp__c;
                    tarea.CC_Categoria__c = mapaEstados.get(mapaCasos.get(tarea.WhatId).Status);
                    tarea.OwnerId = mapaCasos.get(tarea.WhatId).OwnerId;

                }
                
            }

        }

    }

    private static List<Task> descartarTareasNoTMS(List<Task> tareas) {
        List<Task> tareasTMS = new List<Task>();
        Id rtTarea=Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
        for (Task tarea : tareas) {
            
            if(tarea.RecordTypeId == rtTarea){
                tareasTMS.add(tarea);
            }
        }
        return tareasTMS;
    }
}