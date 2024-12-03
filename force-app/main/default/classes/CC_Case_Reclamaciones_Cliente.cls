public with sharing class CC_Case_Reclamaciones_Cliente {

    @InvocableMethod
    public static void actualizarContadorReclamacionesCliente(List<Id> idsCaso) {
        List<Case> casosActualizar = new List<Case>();        
        Set<Id> setIdCasos = new Set<Id>();
        Map<Id, Integer> mapCasosReclamaciones = new Map<Id, Integer>();        
        Integer numReclamaciones;
        
        for(Id caso :idsCaso){
            setIdCasos.add(caso);
        }
        
        for(Task tarea : [SELECT WhatId FROM Task WHERE WhatId IN :setIdCasos AND Subject = 'Reclamación de cliente']){
            if(mapCasosReclamaciones?.get(tarea?.WhatId) != null){
                numReclamaciones =  mapCasosReclamaciones.get(tarea.WhatId) +1;                
                mapCasosReclamaciones.put(tarea.WhatId, numReclamaciones);
            }else{
                mapCasosReclamaciones.put(tarea.WhatId, 1);
            }
        }
        
        for (Id casoId :idsCaso){
            Case caso = new Case();
            caso.Id = casoId;
            if(mapCasosReclamaciones?.get(casoId) != null){
                caso.CC_Numero_Reclamaciones_Cliente__c  = mapCasosReclamaciones.get(casoId);
            }            
            casosActualizar.add(caso);
        }
        
        update casosActualizar;
    }
    
}