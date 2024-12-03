public with sharing class OB_Activity {

    public static Task crearActividad(Id whatId, Map<String, Object> campos, Boolean insertar) {       
        
        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('OB_Task').getRecordTypeId();
        tarea.WhatId = whatId;
        tarea.ActivityDate = System.today();
        tarea.CC_Fecha_Inicio__c = System.now();

        if (campos != null) {
            for (String nombreCampo : campos.keySet()) {
                tarea.put(nombreCampo, campos.get(nombreCampo));
            }
        }

        if (tarea.Status == 'Completed' && tarea.CC_Fecha_Fin__c == null) {
            tarea.CC_Fecha_Fin__c = System.now();
        }

        if (insertar) {
            insert tarea;
        }
        return tarea;
    }

    public static Task crearActividad(Id whatId, Map<String, Object> campos) {       
        return crearActividad(whatId, campos, true);
    }
}