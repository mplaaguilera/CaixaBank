public class CC_Task_Gestion {

    @InvocableMethod(label='CC_Task_Gestion Modificar_Propietario_Tareas' description='Modificar el propietario de las actividades abiertas')
    public static void actualizarPropietarioTareas (List<Id> idCasos)
    {
        // Obtener los casos con tareas no cerradas para actualizar el ownerId con el nuevo propietario
        List<Task> oTarea = [SELECT Id, WhatId, IsClosed FROM Task WHERE WhatId IN :idCasos];
        List<Id> idCasosConTareaAbierta = new List<Id>();

        for(Task tarea : oTarea){
            if(tarea.IsClosed == false){
                idCasosConTareaAbierta.add(tarea.WhatId);
            }
        }

        List<Task> listaTareas =  new List<Task>();
        List<Case> listaCasos = [SELECT Id, OwnerId FROM Case WHERE Id IN :idCasosConTareaAbierta];
        
        for (Task oAux : oTarea){
            for(Case caso : listaCasos){
                if(caso.Id == oAux.WhatId){
                    oAux.OwnerId = caso.OwnerId;
                    listaTareas.add(oAux);  
                }
            }
        } 
        
        if (!listaTareas.isEmpty())
        {
            Database.SaveResult[] ResultSP = Database.update(listaTareas);               
        }
        



    }
}