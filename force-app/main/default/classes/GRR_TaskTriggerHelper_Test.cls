@isTest
public with sharing class GRR_TaskTriggerHelper_Test {
    
    private static Case crearCaso() {
        Case caso = new Case (
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'GRR_Cliente'),
            Subject = 'Caso Test',
            Status = 'Pendiente Colaborador'
        );
        insert caso;
        return caso;
    }

    private static Task crearTarea(String idcaso) {
        Case caso = [SELECT Id FROM Case WHERE Id = :idcaso];
        Task tarea = new Task(
            RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'GRR_Task'),
            Type = 'Traslado Colaborador',
            Status = 'Open',
            WhatId = caso.Id
        );
        insert tarea;
        return tarea;
    }
    
    @isTest
    public static void testReactivarCaso() {
        System.runAs(GRR_TestDataFactory.usuarioPruebasGRR()) {
            Case caso = crearCaso();
            Task tarea = crearTarea(caso.Id);
            Map<Id, Task> oldMap = new Map<Id, Task>([SELECT Id, Type, Status, WhatId FROM Task]);
            tarea.Status = 'Rechazada';
            update tarea;
            Map<Id, Task> newMap = new Map<Id, Task>([SELECT Id, Type, Status, WhatId FROM Task]);
            
            Test.startTest();
            GRR_TaskTriggerHelper.reactivarCaso(newMap, oldMap);
            Test.stopTest();
            
            Case casoActualizado = [SELECT Id, Status FROM Case WHERE Status = 'Activo' LIMIT 1];
            System.assertEquals('Activo', casoActualizado.Status);    
        }
    }

}