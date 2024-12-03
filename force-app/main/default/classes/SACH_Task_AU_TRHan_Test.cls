@isTest
public with sharing class SACH_Task_AU_TRHan_Test {

    @isTest
    private static void test() {
        Case caso = new Case();
        caso.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'SACH_Cliente');
        caso.Origin = 'Phone';
        caso.CC_Canal_Procedencia__c = 'SACH';
        caso.Status = 'Pendiente Colaborador';
        insert caso;

        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'SACH_Task');
        tarea.WhatId = caso.Id;
        tarea.Type = 'Traslado Colaborador';
        insert tarea;

        Test.startTest();
        tarea.Status = 'Rechazada';
        update  tarea;
        Test.stopTest();

        System.assertEquals(
            'Activo',
            [SELECT Status FROM Case WHERE Id = :caso.Id].Status,
            'El caso no ha pasado a estado "Activo"'
        );
    }
}