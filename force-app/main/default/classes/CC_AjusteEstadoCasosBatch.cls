public with sharing class CC_AjusteEstadoCasosBatch implements Database.batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext dbc) {
        DateTime hoy = System.today();
        DateTime dema = System.today().addDays(1);
        
        return Database.getQueryLocator([SELECT Id, Status
                                            FROM Case 
                                            WHERE (RecordType.DeveloperName ='CC_Cliente' OR RecordType.DeveloperName ='CC_Empleado') AND LastModifiedDate >=: hoy AND LastModifiedDate <=: dema AND Status = 'Pendiente Cliente']
                                        );
    }

    public void execute(Database.BatchableContext dbc, List<Case> listaCasos){
        List<Case> toUpd = new List <Case>();
        if(!listaCasos.isEmpty()){

            // Consulta para recuperar tareas (no penalizar en el QueryLocator)
            Set<Id> idsCasos = new Set<Id>();
            for (Case caso : listaCasos)
            {
                idsCasos.add(caso.Id);
            }

            List<Case> listadoCasosTratar = [SELECT Id, Status, (SELECT Id, Status, CreatedDate  FROM Tasks WHERE Type = 'Solicitud Información' ORDER BY CreatedDate DESC LIMIT 1)
                                                FROM Case 
                                                WHERE Id IN :idsCasos];
            
            for (Case caso : listadoCasosTratar) {
                // Tratar los que tienen realmente tareas.
                for (Task tarea : caso.Tasks)
                {
                    if(tarea.Status == 'Completed'){
                        caso.Status = 'Activo';
                        toUpd.add(caso);
                        break;
                    }
                }
            }

            if(!toUpd.isEmpty()){
                Database.update(toUpd);
            }
        }
    }

    public void finish(Database.BatchableContext dbc){
        CBK_log.debug('Fin batch ajuste estado casos CC');
    }
}