public with sharing class CSBD_Activity {

    public static Task crearActividad(Id whatId, String tipoTarea, String estado, String asunto, String cuerpo) {
        return crearActividad(whatId, tipoTarea, estado, asunto, cuerpo, null);
    }

    public static Task crearActividad(Id whatId, String tipoTarea, String estado, String asunto, String cuerpo, Map<String, String> campos) {
        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId();
        tarea.Type = tipoTarea;
        tarea.WhatId = whatId;   
        tarea.ActivityDate = System.today();
        tarea.CC_Fecha_Inicio__c = System.now();
        tarea.Subject = asunto;
        tarea.Description = cuerpo;
        tarea.Status = estado;
        if (campos != null) {
            for (String campo : campos.keySet()) {
                tarea.put(campo, campos.get(campo));
            }
        }
        insert tarea;
        return tarea;
    }

    public static Task crearActividadReturn(Task tarea, Id whatId, String tipoTarea, String estado, String asunto, String cuerpo, Map<String, String> campos) {
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId();
        tarea.Type = tipoTarea;
        tarea.WhatId = whatId;   
        tarea.ActivityDate = System.today();
        tarea.CC_Fecha_Inicio__c = System.now();
        tarea.Subject = asunto;
        tarea.Description = cuerpo;
        tarea.Status = estado;
        if (campos != null) {
            for (String campo : campos.keySet()) {
                tarea.put(campo, campos.get(campo));
            }
        }
        return tarea;
    }

    public static List<Task> crearActividad(Set<Id> idOportunidades, String tipoTarea, String estado, String asunto, String cuerpo) {
        List<Task> tareasInsert = new List<Task>();
        for(Id oportunidadId: idOportunidades) {
            Task tarea = new Task();
            tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSBD_Task').getRecordTypeId();
            tarea.Type = tipoTarea;
            tarea.WhatId = oportunidadId;   
            tarea.ActivityDate = System.today();
            tarea.CC_Fecha_Inicio__c = System.now();
            tarea.Subject = asunto;
            tarea.Description = cuerpo;
            tarea.Status = estado;
            tareasInsert.add(tarea);
        }

        return tareasInsert;
    }

    public static void crearActividadReasignacion(Set<Id> idOportunidades, String tipoTarea, String cuerpo) {
        Map<Id, Opportunity> oportunidadesMap = new Map<Id, Opportunity>([SELECT Owner.Name FROM Opportunity WHERE Id IN :idOportunidades]);
        List<Task> tareasInsert = crearActividad(idOportunidades, tipoTarea, 'Completed', tipoTarea, cuerpo);
        
        for(Task tarea: tareasInsert) {
            if(oportunidadesMap.containsKey(tarea.WhatId)){
                tarea.Subject = tarea.Subject + ' al usuario ' + oportunidadesMap.get(tarea.WhatId).Owner.Name;
            }
            
        }
        insert tareasInsert;

    }

    public static void cerrarActividadPendienteCliente(Id idOportunidad) {
        List<Task> tareasPendienteCliente = [SELECT Id FROM Task WHERE WhatId = :idOportunidad
                                                AND Type = 'Pendiente Cliente' AND Status = 'Open'];
        for (Task tareaPendienteCliente : tareasPendienteCliente) {
            tareaPendienteCliente.CC_Fecha_Fin__c = System.now();
            tareaPendienteCliente.Status = 'Completed';
        }
        update tareasPendienteCliente;
    }
}