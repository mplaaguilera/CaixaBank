public class CC_Agrupador_Rechazado {
    
    @InvocableMethod(label='CC_Agrupador_Rechazado' description='Acciones a realizar cuando se rechaza un agrupador')
    public static void agrupadorRechazado (List<Id> agrupadores)
    {
    
    	if (!agrupadores.isEmpty())
        { 
            List<Case> casosUpdate = new List<Case>();            
            Set<Id> idsCasos = new Set<Id>();
            for(Case caso: [SELECT Id, Status, CC_Fecha_Activo_Formulario__c FROM Case WHERE CC_Agrupador_Id__c IN :agrupadores AND Status <>'Cerrado' AND Status <> 'Rechazado']){
                //Set id
                idsCasos.add(caso.Id);
                caso.Status = 'Activo';
                caso.CC_Fecha_Activo_Formulario__c = dateTime.now();
                casosUpdate.add (caso);
            }
            
            if(!casosUpdate.isEmpty())
            {
                 update casosUpdate;  
            }
            
            List<Task> tareasUpdate = new List<Task>();
            for(Task tarea: [SELECT Id, Status FROM Task WHERE WhatId IN: idsCasos AND Status = 'Open' AND Type = 'Traslado Incidencia']){                           
                tarea.Status = 'Rechazada';
                tareasUpdate.add (tarea);
            }
             if(!tareasUpdate.isEmpty())
            {
                 update tareasUpdate;  
            }  
        }
    }
}