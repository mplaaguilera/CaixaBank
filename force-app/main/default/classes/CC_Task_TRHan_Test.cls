@isTest 
public class CC_Task_TRHan_Test
{
    @isTest
    static void insertTask(){
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Trigger Task';
        caso.Status = 'Activo';
        caso.Origin='Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.CC_Canal_Resolucion__c = 'Buzón KYC Renewal';
        insert caso;
        
        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tarea.Subject = 'Tarea para ver si se actualiza el campo última actualización';
        tarea.Status = 'Open';
        tarea.Type = 'Actividad manual';
        tarea.WhatId = caso.id;
        insert tarea;
        
        Task tarea2 = new Task();
        tarea2.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
        tarea2.Subject = 'Tarea para ver si se actualiza el campo última actualización';
        tarea2.Status = 'Open';
        tarea2.Type = 'Automática';
        tarea2.WhatId = caso.id;
        tarea2.Description = 'Tarea description';
        insert tarea2;
    } 
    
    @isTest
    static void campoUltimaActualizacion(){
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Trigger Task';
        caso.Status = 'Activo';
        caso.Origin='Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.CC_Canal_Resolucion__c = 'Buzón KYC Renewal';
        insert caso;
        
        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('OS_Task').getRecordTypeId();
        tarea.Subject = 'Tarea para ver si se actualiza el campo última actualización';
        tarea.Status = 'Open';
        tarea.Type = 'Traslado Colaborador';
        tarea.WhatId = caso.id;
        insert tarea;
        
        tarea.Status = 'Rechazada';
        
        // Ejecución de la prueba
        Test.startTest();
		update tarea;
        Test.stopTest();

    } 

    @isTest
    static void actualizarTieneActividadesLlamada(){
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Trigger Task';
        caso.Status = 'Activo';
        caso.Origin='Email';
        caso.CC_Canal_Procedencia__c = 'Buzón KYC Renewal';
        caso.CC_Canal_Resolucion__c = 'Buzón KYC Renewal';
        insert caso;

        CC_Llamada__c llamada = new CC_Llamada__c();
        llamada.RecordTypeId = Schema.getGlobalDescribe().get('CC_Llamada__c').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        llamada.CC_ConnId__c = 'test02092021.00001';
        llamada.CC_Tipo__c = 'Entrante';
        llamada.CC_Idioma__c = 'es';
        llamada.CC_ANI__c = '666666415';
        llamada.CC_DNIS__c = '666444578';
        llamada.CC_Fecha_Inicio__c = System.now();
        llamada.OS_Nombre_Fichero_Grabacion__c = 'test02092021.00001.mp3';
        insert llamada;
        
        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('OS_Task').getRecordTypeId();
        tarea.Subject = 'Tarea para ver si se actualiza el campo \'Tiene actividades\' en llamada';
        tarea.Status = 'Open';
        tarea.Type = 'Traslado Colaborador';
        tarea.WhatId = caso.id;
        tarea.CC_Llamada_Id__c = llamada.Id;
        Test.startTest();
        insert tarea;
        Test.stopTest();
        
        System.assertEquals(true, [SELECT OS_Tiene_Actividades__c FROM CC_Llamada__c WHERE ID = :Llamada.Id].OS_Tiene_Actividades__c);
        
    }
}