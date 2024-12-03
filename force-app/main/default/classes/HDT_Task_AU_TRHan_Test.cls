@isTest 
public class HDT_Task_AU_TRHan_Test
{
    @TestSetup
    static void makeData(){
        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        tarea.Subject = 'Tarea para ver si se actualiza el campo última actualización';
        tarea.Status = 'Activo';
        insert tarea;
    }

    @isTest
    private static void crearTaskTest() {    
        System.runAs(new User(Id = UserInfo.getUserId())) {

        Task tarea = new Task();
        tarea.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId();
        tarea.Subject = 'Tarea para ver si se actualiza el campo última actualización';
        tarea.Status = 'Cerrada';
        
        Test.startTest();

            insert tarea;   
        Test.stopTest();
        
        List<Task> tareas = [SELECT LastModifiedDate, CC_Ultima_Actualizacion__c FROM Task WHERE Id = :tarea.Id];
        
        System.assertEquals(null, tareas[0].CC_Ultima_Actualizacion__c);
        //System.assertEquals(tareas[0].LastModifiedDate, tareas[0].CC_Ultima_Actualizacion__c);  
        }      
    }

}