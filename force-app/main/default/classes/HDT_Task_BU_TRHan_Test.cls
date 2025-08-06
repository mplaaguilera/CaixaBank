@isTest
private class HDT_Task_BU_TRHan_Test {

    @isTest
    static void testProcess() {
            // create test data
            System.runAs(new User(Id = UserInfo.getUserId())){
                List<Task> tasks = new List<Task>{
                    new Task(Subject = 'Test Task 1', Type = 'Call', RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId()),
                    new Task(Subject = 'Test Task 2', Type = 'Call', RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId()),
                    new Task(Subject = 'Test Task 3', Type = 'Call', RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId()),
                    new Task(Subject = 'Test Task 4', Type = 'Call', RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId()),
                    new Task(Subject = 'Test Task 5', Type = 'Call', RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('HDT_Task').getRecordTypeId())
                };
        
                insert tasks;
        
                /*
                // create trigger context
                CC_TriggerParameters tp = new CC_TriggerParameters();
                tp.newList = tasks;
                tp.newMap = new Map<Id, Task>(tasks);
                
                
                
        
                // call the mainEntry method
                HDT_Task_BU_TRHan handler = new HDT_Task_BU_TRHan();
                handler.mainEntry(tp);
        
                // assert the results
                List<Task> updatedTasks = [SELECT Id, OS_Tipo__c FROM Task WHERE Id IN :tasks];
        
                for(Task t : updatedTasks) {
                    if(t.Type == 'Call') {
                        System.assertEquals('Call', t.OS_Tipo__c, 'Incorrect OS_Tipo__c value');
                    } else {
                        System.assertEquals(null, t.OS_Tipo__c, 'Incorrect OS_Tipo__c value');
                    }
                }*/
                for(Task tarea :tasks){
                    tarea.Type = 'Email';
                }
    
                update tasks;
    
                List<Task> tareasActualizadas = [SELECT Id, OS_Tipo__c FROM Task WHERE Id IN :tasks AND OS_Tipo__c = 'Email'];
                    
                
                System.assertEquals(tareasActualizadas.size(), tasks.size(), 'Las tareas se han actualizado correctamente');
            }        
    }
}