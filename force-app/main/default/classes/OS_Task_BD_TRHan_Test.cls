@isTest
public with sharing class OS_Task_BD_TRHan_Test {
    
    @isTest
    public static void borrar_task_error_text() {
        System.runAs(HDT_TestDataFactory.usuarioPruebasHdt()) {
            Task tarea = new Task();
            tarea.RecordTypeId=Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('OS_Task').getRecordTypeId();
            tarea.type = 'Automática';
            tarea.Status = 'Completado';
            tarea.Priority = 'Normal';
            tarea.Subject = 'Ref.00030183:"CaixaBank" - Incidencia operación en CajeroAS07195, activador 1111111111111111';
            tarea.Description = 'TEXTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO activador 1111111111111111';
            insert tarea;
            
            Test.startTest();
            
            try{
                delete tarea;
            } catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('No tiene permisos para eliminar el registro') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            } 
            
            Test.stopTest();
        }
        
    }
}