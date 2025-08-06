@isTest
public with sharing class FRA_TaskTriggerHelper_Test {

    private static Task crearTarea() {
        Task tarea = new Task();
        tarea.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Task', 'FRA_Task');
        tarea.Type = 'Actividad Manual';
        tarea.Status = 'Completado';
        tarea.Priority = 'Normal';
        tarea.Subject = 'Personalizada';
        tarea.Description = 'Tarea FRAUDE Description Clase Test Borrado';

        insert tarea;
        return tarea;
    }

    @isTest
    public static void testErrorEliminarTarea() {
        System.runAs(FRA_TestDataFactory.usuarioPruebasFRA()) {
            //Crear tarea
            Task tareaCreada = crearTarea();

            Test.startTest();
            try{
                delete tareaCreada;
            } catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('No tiene permisos para eliminar el registro') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true, 'Se ha generado una excepción al intentar borrar una tarea.');
                System.AssertEquals(1, [SELECT COUNT() FROM Task WHERE Id = :tareaCreada.Id], 'La tarea creada no se ha eliminado');
            } 
            Test.stopTest();
            
        }
    }    
    
    @isTest
    public static void testPermitirEliminarTarea() {
        User usuarioPermisoBorrado = FRA_TestDataFactory.usuarioPruebasFRA();
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>();
        for (PermissionSet ps : [SELECT Id FROM PermissionSet WHERE Name IN ('FRA_PS_EliminarTareas')]) {
            PermissionSetAssignment psAssignment = new PermissionSetAssignment();
            psAssignment.AssigneeId = usuarioPermisoBorrado.Id;
            psAssignment.PermissionSetId = ps.Id;
            psAssignments.add(psAssignment);
        }
        insert psAssignments;
            
        System.runAs(usuarioPermisoBorrado) {
            //Crear tarea
            Task tareaCreadaEliminar = crearTarea();

            Test.startTest();
            delete tareaCreadaEliminar;
            System.AssertEquals(0, [SELECT COUNT() FROM Task WHERE Id = :tareaCreadaEliminar.Id], 'La tarea creada se ha eliminado correctamente');
            Test.stopTest();
            
        }
    } 
}