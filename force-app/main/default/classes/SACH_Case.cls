public with sharing class SACH_Case {

    public static Case crearCaso(String recordTypeDeveloperName) {
        return crearCaso(recordTypeDeveloperName, new Map<String, Object>());
    }

    public static Case crearCaso(String recordTypeDeveloperName, Map<String, Object> campos) {
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', recordTypeDeveloperName);
        for (String campo : campos.keySet()) {
            caso.put(campo, campos.get(campo));
        }
        insert caso;
        return caso;
    }

    public static Case reapertura(Id idCaso, String descripcionTarea, Boolean cambiarPropietario, Boolean sinUpdate) {
        //Reapertura caso por respuesta (el estado pasa a Activo y se registra el motivo de reapertura en una nueva actividad)
        Case caso = [SELECT Status FROM Case WHERE Id = :idCaso WITH SECURITY_ENFORCED];
        if (caso.Status != 'Activo') {
            Task tareaReactivacion = new Task();
            tareaReactivacion.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
            tareaReactivacion.WhatId = idCaso;
            tareaReactivacion.Status = 'Completed';
            tareaReactivacion.Type = 'Reactivación';
            tareaReactivacion.Subject = 'Reactivación';
            tareaReactivacion.Description = descripcionTarea;
            tareaReactivacion.ActivityDate = System.today();
            tareaReactivacion.CC_Fecha_Inicio__c = System.now();
            insert tareaReactivacion;

            caso.Status = 'Activo';
            caso.CC_Fecha_Reapertura__c = Datetime.valueOf(System.now());
            if (cambiarPropietario) {
                caso.OwnerId = UserInfo.getUserId();
            }

            if (!sinUpdate) {
                update caso;
            }
        }
        return caso;
    }

    public static Case reapertura(Id idCaso, String descripcionTarea) {
        return reapertura(idCaso, descripcionTarea, true, false);
    }
}