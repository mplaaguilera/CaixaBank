@isTest
public class HDT_Task_BD_TRHan_Test {
    
    @isTest
    public static void borrar_task_error_ok() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Task tarea = new Task();
        tarea.RecordTypeId=Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        tarea.type = 'Automática';
        tarea.Status = 'Completado';
        tarea.Priority = 'Normal';
        tarea.Subject = 'Ref.00030183:"CaixaBank" - Incidencia operación en CajeroAS07195, activador 1111111111111111';
        tarea.Description = 'TEXTOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO activador 1111111111111111';
        insert tarea;
        
        CBK_Activity_Extension__c ext = new CBK_Activity_Extension__c();
        ext.AV_ActivityId__c=tarea.id;
        insert ext;

        
        Test.startTest();
        ext.CBK_Eliminable__c=true;
        update ext;
		delete tarea;
        
        list<Task> lstTask = [Select Id from Task where id=:tarea.Id]; 
        System.AssertEquals(lstTask.size(), 0);
        Test.stopTest();
        }
    }

    @isTest
    public static void borrar_task_error_text() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Task tarea = new Task();
        tarea.RecordTypeId=Schema.getGlobalDescribe().get('Task').getDescribe().getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
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