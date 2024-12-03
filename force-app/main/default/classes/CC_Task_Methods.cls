public class CC_Task_Methods {
    @InvocableMethod(label='CC_Task_Methods Crear_Reclamacion_Maximo' description='Crear una reclamacion Maximo')
    public static void crearReclamacionMaximo (List<Id> idTareas) {
        if(!idTareas.isEmpty()) {
            List<Task> oTarea = [SELECT Id, WhatId, Subject, Description FROM Task WHERE Id IN :idTareas];
            List<CC_Agrupador_Reclamacion__c> listaAgrupadores =  new List<CC_Agrupador_Reclamacion__c>();
            
            Set<Id> whatIds = new Set<Id>();
            for (Task oAux : oTarea){
                whatIds.add(oAux.WhatId);
            } 
            
            if(!whatIds.isEmpty()){
                List<Case> casos = [SELECT Id, CC_Agrupador_Id__c  FROM Case WHERE Id IN : whatIds AND CC_Agrupador_Id__c != null];
                for ( Case caso : casos){
                    
                    CC_Agrupador_Reclamacion__c agrupadorReclamacion = new CC_Agrupador_Reclamacion__c ();
                    agrupadorReclamacion.CC_Agrupador_Id__c = caso.CC_Agrupador_Id__c;
                    agrupadorReclamacion.CC_Tipo_de_actividad__c = 'Reclamación';
                    //agrupadorReclamacion.CC_Descripcion__c = caso.Subject;
                    //agrupadorReclamacion.CC_Contenido__c = caso.Comments;
                    listaAgrupadores.add(agrupadorReclamacion);         
                }
            }
            if (!listaAgrupadores.isEmpty()){
                Database.SaveResult[] ResultSP = Database.insert(listaAgrupadores);
                /*Set<Id> idAgrupadorReclamacion = new Set <Id>();
                for ( CC_Agrupador_Reclamacion__c agrupador : listaAgrupadores ){
                    idAgrupadorReclamacion.add(agrupador.Id);
                }
                
                CC_WS_Methods_Maximo.crearReclamacionMaximo(idAgrupadorReclamacion);*/
            }
        }
    }
}