@isTest
public class AM_Case_Test {
    
    @isTest
    public static void reapertura() {
        
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCaso;
        caso.Subject = 'Prueba reapertura';
        caso.Status = 'Cerrado';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Buzón Carteras';
        caso.CC_Canal_Resolucion__c = 'Buzón Carteras';
        caso.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso;
        
        Test.startTest();
        AM_Case.reapertura(caso.Id);
        Test.stopTest();
        System.assertEquals('Activo', [SELECT Status, Id FROM Case WHERE Id = :caso.Id LIMIT 1].Status);
           
    }

    
    @isTest
    public static void duplicarCaso() {
        Id recordTypeCaso = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();

        Case caso1 = new Case();
        caso1.CC_Idioma__c = 'es';
        caso1.RecordTypeId = recordTypeCaso;
        caso1.Subject = 'Prueba Duplicar Caso';
        caso1.Status = 'Activo';
        caso1.Origin = 'Email';
        caso1.CC_Canal_Procedencia__c = 'Buzón Carteras';
        caso1.CC_Canal_Resolucion__c = 'Buzón Carteras';
        caso1.CC_Tipo_Contacto__c = 'Asesoramiento';
        insert caso1;

        List<Task> tareas = new List<Task>();
        for (Integer x = 0; x < 2; x++) {
            Task tarea = new Task();
            tarea.recordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task');
            tarea.WhatId = caso1.Id;
            tarea.Type = 'Automática';
            tarea.Status = 'Completed';
            tarea.Subject = 'Prueba' + x;
            tarea.Description = 'Esto es una prueba';
            tarea.ActivityDate = System.today();
            tareas.add(tarea);
        }
        insert tareas;

        Test.startTest();
        Case casoHijo = AM_Case.duplicarCaso(caso1);
        Test.stopTest();

        //Probar que se ha insertado el caso
        System.assertNotEquals(null, casoHijo.Id);

        //Probar que se ha creado la actividad de caso duplicado
        List<Task> tareasDuplicar = [SELECT Id FROM Task
                                        WHERE WhatId = :casoHijo.Id AND RecordTypeId = :CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'AM_Task')];

        System.assert(tareasDuplicar.size() == 3);
    }
}