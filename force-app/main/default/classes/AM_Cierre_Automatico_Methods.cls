public with sharing class AM_Cierre_Automatico_Methods {
    @InvocableMethod(label='Cierre Autom. Sol. Inf. CAM' description='Cierre Autom. Sol. Inf. CAM')
    public static void closeTaskSolicitudInfCAM(List<Id> ListCasoId){

        Id recordTypeClienteCAM = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Cliente').getRecordTypeId();
        Id recordTypeEmpleadoCAM = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('AM_Empleado').getRecordTypeId();

        List<Case> casosAct = new List<Case>();
        List<Task> tasksCrear = new List<Task>();
        Set<Id> setIdCasos = new Set<Id>();

        for (Id casoId : ListCasoId) {
            setIdCasos.add(casoId);
        }
                
        List<Case> listCases = [SELECT RecordTypeId, CC_Fecha_Cierre_SolInf__c, Status, CC_Tipo_Cliente__c, CC_Idioma__c, CC_Buzon_Salida__c,
                                CC_Detalles_Consulta__c, CC_Detalles_Solucion__c
                                FROM Case WHERE Id IN :setIdCasos];

        for(Case caso: listCases){
            
            CC_Activity.finalizarActividadCaso(caso.Id, 'Solicitud información', 'Cierre automático', 'Cierre automático Solicitud Información');
            
            caso.CC_Fecha_Cierre_SolInf__c = null;
            caso.Status = 'Cerrado';
            caso.CC_Admin__c = true;
            
            if(caso.RecordTypeId == recordTypeEmpleadoCAM){
                if (String.isEmpty(caso.CC_Detalles_Consulta__c)){
                	caso.CC_Detalles_Consulta__c = 'Cierre automático por falta de respuesta del empleado.';
                }
                if (String.isEmpty(caso.CC_Detalles_Solucion__c)){
                	caso.CC_Detalles_Solucion__c = 'Cierre automático por falta de respuesta del empleado.';
                }
            }else if(caso.RecordTypeId == recordTypeClienteCAM){
                if (String.isEmpty(caso.CC_Detalles_Consulta__c)){
                	caso.CC_Detalles_Consulta__c = 'Cierre automático por falta de respuesta del cliente.';
                }
                if (String.isEmpty(caso.CC_Detalles_Solucion__c)){
                	caso.CC_Detalles_Solucion__c = 'Cierre automático por falta de respuesta del cliente.';
                }
            }

			casosAct.add(caso);
            
            // Crear Tarea de Cierre Automatico Solicitud Informacion
            Task task = new Task();
            task.ActivityDate = system.today();
            task.Subject = 'Cierre Automático Solicitud Información';
            task.Type = 'Cierre Automático';
            task.Status = 'Completed';
            task.WhatId = caso.Id;
            tasksCrear.add(task);

        }
        
        System.debug('casosAct::: '+casosAct);

        //DataBase Update para la lista de Casos.
        Update casosAct;
        //Insertar tareas
        Database.SaveResult[] resultsTask =  CC_Activity.crearActividades(tasksCrear, false);

    }
}