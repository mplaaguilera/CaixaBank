@IsTest 
public with sharing class CC_Task_Methods_Test {
    
    @IsTest
    static void crearReclamacionMaximo() {
        
        String sRecordType = Schema.SObjectType.CC_Agrupador__c.getRecordTypeInfosByDeveloperName().get('CC_Incidencia').getRecordTypeId();
        
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.RecordTypeId = sRecordType;
        agrupador.CC_Titulo__c = 'Test';
        agrupador.CC_Descripcion__c = 'Test';
        insert agrupador;
        
        Case caso = new Case ();
        caso.CC_Agrupador_Id__c = agrupador.Id;
        insert caso;
        
        Task tarea = new Task ();
        tarea.Type = 'Reclamación';
        tarea.Subject = 'Prueba de Reclamacion';
        tarea.Status = 'Completado';
        tarea.Description = 'esto es una prueba de comentarios de la tarea';
        tarea.Priority = 'Normal';
        tarea.WhatId = caso.Id;
        insert tarea;  
        
        List<Id> idTareas = new List<Id>();
        idTareas.add(tarea.Id);
        
        CC_Task_Methods.crearReclamacionMaximo(idTareas);
        
        CC_Agrupador_Reclamacion__c agrupadorReclamacion = [SELECT Id FROM CC_Agrupador_Reclamacion__c LIMIT 1];
        
        System.assertEquals(agrupadorReclamacion != null, true);
        
    }
}