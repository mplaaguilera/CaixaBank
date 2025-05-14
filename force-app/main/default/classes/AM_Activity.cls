public with sharing class AM_Activity {

	public static void crearActividad(Id idCaso, String tipo, String motivo) {
        insert new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task'),
            WhatId = idCaso,
            Type = tipo,
            Status = 'Completed',
            Subject = tipo,
            Description = motivo,
            ActivityDate = System.today()
        );
    }

    public static void crearActividadPendiente(Id idCaso, String tipo, String motivo) {
        insert new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task'),
            WhatId = idCaso,
            Type = tipo,
            Status = 'Open',
            Subject = tipo,
            Description = motivo,
            ActivityDate = System.today()
        );
    }
}