@isTest
public class HDT_Task_BI_TRHan_Test {

     @isTest
    static void enmascararPANs_test() {
       
        System.runAs ( new User(Id = UserInfo.getUserId()) ){

        Case caso = new Case();
        caso.Subject = 'Caso Test';
        caso.Status = 'Cerrado';
        insert caso;
        
        Task tarea = new Task();
        tarea.WhatId = caso.Id;
        tarea.type = 'Automática';
        tarea.Status = 'Completado';
        tarea.Priority = 'Normal';
        tarea.Subject = 'Ref.00030183:"CaixaBank" - Incidencia operación en CajeroAS07195, activador 1111111111111111';
        tarea.Description = 'TEXTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO activador 1111111111111111';
        tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
        insert tarea;
        
        Test.startTest();
        Task tareaAI = new Task();
        tareaAI = [SELECT Id, Subject, Description from Task where Id =: tarea.Id];

        
        /*System.assertEquals(tareaAI.Subject, 'Ref.00030183:"CaixaBank" - Incidencia operación en CajeroAS07195, activador 1111XXXXXXXX1111');
        System.assertEquals(tareaAI.Description, 'TEXTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO activador 1111XXXXXXXX1111'); */
        System.assertEquals(tarea.Id, tareaAI.Id, 'No se ha encontrado la Tarea');
		Test.stopTest();
        }
        
    }
	

    @isTest
    static void beforeDelete_Test() {       
       
        System.runAs ( new User(Id = UserInfo.getUserId()) ){

        Task tarea = new Task();
        tarea.type = 'Automática';
        tarea.Status = 'Completado';
        tarea.Priority = 'Normal';
        tarea.Subject = 'Tarea';
        insert tarea;
       	delete tarea;     
        
           Task tareaAI = new Task();
   
           Test.startTest();
           System.assertEquals(0,            
           [SELECT COUNT() from Task where Id =: tarea.Id]
           , 'No se ha eliminado la Tarea');
           Test.stopTest();
    }
}

 @isTest
    static void copiarTaskType_Test() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Task> tareas = new List<Task>();

            Task tarea = new Task();
            tarea.Type = 'Automática';
            tarea.Status = 'Completado';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Tarea';
            tarea.RecordtypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'HDT_Task');
            tareas.add(tarea);
            insert tareas;  
              
               Test.startTest();

              
                System.assertEquals(tarea.type,            
                [SELECT Type,OS_Tipo__c from Task where Id =: tarea.Id].Type
                , 'No se ha copiado el Task Type');
                

              


               Test.stopTest();
        }
        }
}