@isTest
public class OS_Numero_Actividades_Test {

    @TestSetup
    static void makeData(){
        User usuarioOperador = OS_Usuarios.usuarioOperador();
    }

	@isTest
    static void sumarTask() {
        User usuarioOperador = [SELECT Id FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];

        Id recordTypeCaso = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('OS_Cliente').getRecordTypeId();
        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Prueba Duplicar Caso';
        caso1.Status = 'Cerrado';
        caso1.Origin = 'Phone';
        caso1.CC_Canal_Procedencia__c = 'Teléfono COPS atención clientes';
        caso1.CC_Canal_Resolucion__c = 'Teléfono COPS atención clientes';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso1;

        CaseShare csNuevo = new CaseShare();
        csNuevo.CaseId = caso1.Id;
        csNuevo.UserOrGroupId = usuarioOperador.Id;
        csNuevo.CaseAccessLevel='Edit';
        insert csNuevo;
        
        List<Id> idCasos = new List<Id>();
        idCasos.add(caso1.Id); 
        
        List<Task> tareas = new List<Task>();
        for (Integer x = 0; x < 2; x++) {
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'OS_Task');
            tarea.WhatId = caso1.Id;
            tarea.Type = 'Automática';
            tarea.Status = 'Completed';
            tarea.Subject = 'Prueba' + x;
            tarea.Description = 'Esto es una prueba';
            tarea.ActivityDate = System.today();
            tareas.add(tarea);
        }
        insert tareas;
        
        List<Id> idTareas = new List<Id>();
        
        for(Task tarea : tareas){
            idTareas.add(tarea.Id);            
        }
                
        System.runAs (usuarioOperador) {
            Test.startTest();
            OS_Numero_Actividades.sumarTask(idCasos);
            Test.stopTest();

            System.assertEquals(3, [SELECT OS_Numero_Actividades__c FROM Case WHERE Id = :caso1.Id].OS_Numero_Actividades__c);
        }
    }
}