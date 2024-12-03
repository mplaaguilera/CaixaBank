public with sharing class TMS_Task_AU_TRHan extends CC_TriggerHandlerBase {

    public override void mainEntry(CC_TriggerParameters tp) {
		process((Map<Id, Task>)tp.newMap, (Map<Id, Task>)tp.oldMap);
	}
    
    private static void process(Map<Id, Task> newMap, Map<Id, Task> oldMap) {
        Id idRecordTypeTMS = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('TMS_Tarea').getRecordTypeId();
        List<Task> tareasDesactivar = new List<Task>();
        List<Id> caso = new List<Id>();
        for (Id idTarea : newMap.keySet()) {
            if (newMap.get(idTarea).RecordTypeId == idRecordTypeTMS) {
                if (newMap.get(idTarea).Subject == 'Primer intento de llamada'
                && oldMap.get(idTarea).Status != 'Completed' && newMap.get(idTarea).Status == 'Completed') {
                    caso.add(newMap.get(idTarea).WhatId);
                }
            }
        }
        if(!caso.isEmpty()){
            List<Task> segundaLlamada=[SELECT Id,Status FROM Task WHERE WhatId IN :caso AND Subject = 'Segundo intento de llamada'];
            if(!segundaLlamada.isEmpty()){
                for (Task tarea : segundaLlamada) {
                    tarea.Status ='Rechazada';
                    tareasDesactivar.add(tarea);
                }
                if(!tareasDesactivar.isEmpty()){
                    update tareasDesactivar;
                }
            }
        }
    }
}