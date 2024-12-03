public with sharing class CC_Task {
    @InvocableMethod(label='CC_Task Modificar_Propietario_Tareas' description='Modificar el propietario de las actividades abiertas')
    public static void actualizarPropietarioTareas(List<Id> oTareas) {

        if (!oTareas.isEmpty()) {
            List<Task> oTarea = [SELECT WhatId, IsClosed,
                                 TYPEOF What WHEN Case THEN OwnerId END // Recupera el owner Id del caso
                                 FROM Task WHERE Id IN :oTareas];
            List<Task> listaTareas =  new List<Task>();
            
            for (Task oAux : oTarea) {
                if (!oAux.IsClosed && oAux.WhatId != null && oAux.WhatId.getSObjectType() == Schema.Case.SObjectType) {
                    Case caso = oAux.What;
                    String idProp = (String)caso.OwnerId;
                    if (idProp.startsWith('005')) {   
                        oAux.OwnerId = caso.OwnerId;
                        listaTareas.add(oAux);  
                    }
                }
            } 
            
            if (!listaTareas.isEmpty()) {
                Database.SaveResult[] ResultSP = Database.update(listaTareas);
            }
        }
    }
    
    @AuraEnabled
    public static boolean permisosNuevaTarea (String casoId){
        String ownerId = [SELECT Id, OwnerId FROM Case WHERE Id =: casoId LIMIT 1].OwnerId;
        Id userId = UserInfo.getUserId();
        if(ownerId != userId){
            return false;
        }else{
            return true;
        }        
    }
}