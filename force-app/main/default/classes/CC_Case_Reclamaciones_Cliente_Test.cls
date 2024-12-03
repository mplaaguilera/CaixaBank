@isTest
public class CC_Case_Reclamaciones_Cliente_Test {

	@isTest
    public static void actualizarContadorReclamacionesCliente() {
        //Alta de datos para la prueba
        List<Id> idsCaso = new List<Id>();
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.Subject = 'Asunto';
        insert caso;
        idsCaso.add(caso.Id);
        
        //Ejecución de la prueba
        Test.startTest();
        CC_Case_Reclamaciones_Cliente.actualizarContadorReclamacionesCliente(idsCaso);
        Test.stopTest();
                
        //Evaluación del resultado de la prueba
        Case casoResultado = [SELECT CC_Numero_Reclamaciones_Cliente__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(0, casoResultado.CC_Numero_Reclamaciones_Cliente__c);
    }
    
    @isTest
    public static void contadorReclamacionesCliente() {
        //Alta de datos para la prueba
        List<Id> idsCaso = new List<Id>();
        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        caso.CC_Idioma__c = 'es';
        caso.Origin = 'Chat';
        caso.CC_Canal_Procedencia__c = 'Web';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.Subject = 'Asunto';
        insert caso;
        idsCaso.add(caso.Id);
        
        Task tarea = new Task();
        tarea.Subject = 'Reclamación de cliente';
        tarea.WhatId = caso.Id;
		tarea.Type = 'Traslado Tercer Nivel';
        tarea.RecordTypeId = Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Task').getRecordTypeId();
       	insert tarea;
        
        //Ejecución de la prueba
        Test.startTest();
        CC_Case_Reclamaciones_Cliente.actualizarContadorReclamacionesCliente(idsCaso);
        Test.stopTest();
                
        //Evaluación del resultado de la prueba
        Case casoResultado = [SELECT CC_Numero_Reclamaciones_Cliente__c FROM Case WHERE Id = :caso.Id];
        System.assertEquals(1, casoResultado.CC_Numero_Reclamaciones_Cliente__c);
    }
    
}