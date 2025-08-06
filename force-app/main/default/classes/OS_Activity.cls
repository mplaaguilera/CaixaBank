public with sharing class OS_Activity {
    
	public static void crearActividad(Id idCaso, String tipo, String motivo) {
        insert new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task'),
            WhatId = idCaso,
            Type = tipo,
            Status = 'Completed',
            Subject = tipo,
            Description = motivo,
            ActivityDate = System.today()
        );
    }

    public static Task crearActividad(Id whatId, String tipo, String asunto, String descripcion, Map<String, Object> campos) {
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
        tarea.WhatId = whatId;
        tarea.Type = tipo;
        tarea.Subject = asunto;
        tarea.Description = descripcion;
        tarea.ActivityDate = System.today();
        tarea.Status = 'Completed';

        if (campos != null) {
            for (String nombreCampo : campos.keySet()) {
                tarea.put(nombreCampo, campos.get(nombreCampo));
            }
        }
        insert tarea;
        return tarea;
    }

    public static void crearEvento(Id idCaso, DateTime fecha, Id ownerId, String descripcion) {
        
        String nuevaDescripcion = 'Nuevo propietario: ' + [SELECT Name FROM User WHERE Id = :ownerId].Name;
        nuevaDescripcion += '\n\nDescripción: ' + descripcion;

        insert new Event(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', 'OS_Alerta'),
            Type = 'Alerta programada',
            WhatId = idCaso,
            StartDateTime = fecha,
            EndDateTime = fecha,
            OwnerId = ownerId,
            Subject = 'Alerta programada',
            Description = nuevaDescripcion
        );
    }

    public static void borrarEvento(Id idCaso, DateTime fecha) {
        List<Event> eventos = [SELECT Id FROM Event
                                WHERE WhatId = :idCaso
                                AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Event', 'OS_Alerta')
                                AND Type = 'Alerta programada'
                                AND StartDateTime = :fecha
                                LIMIT 1];
        delete eventos;
    }
}