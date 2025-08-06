public class CC_Task_Verificacion_Cliente {

    @InvocableMethod(label='CC_Task_Verificacion_Cliente' description='Cuando se crea un tarea tipo "Verificación cliente" se cambia estado caso a Pendiente Revision o Cerrado')
    public static void CC_Task_Verificacion_Cliente (List<Id> idTask) {
    //--------------------------------------
    // Sergio Castro -> "25-02-2020" -> Cuando se crea un tarea tipo "Verificación cliente" se cambia estado caso a "Pendiente Revision" o "Cerrado"
    //--------------------------------------
    List<Task> listaTarea = [SELECT Status, WhatId FROM Task WHERE Id IN :idTask];
    List<Id> idCase = new List<Id>();
    for (Task tarea : listaTarea) {
        idCase.add(tarea.WhatId);  
    }

    List<Task> listasDeTareas = [SELECT Status, Subject FROM Task WHERE WhatId IN :idCase AND Status = 'Open' ]; 
    List<Case> listaCasos = [SELECT Status, CC_Detalles_Consulta__c, CC_Tipo_Contacto__c, CC_MCC_Motivo__c, CC_Canal_Procedencia__c,
                                CC_Canal_Resolucion__c, CC_Canal_Operativo__c, AccountId, ContactId 
                                FROM Case WHERE Id IN :idCase];

    //Preparamos las listas de casos
    List<Case> listaCasosCerrar = new List<Case>();
    List<Case> listaCasosRevisar = new List<Case>();
    List<Task> listaTaskCerradas = new List<Task>();

    //cerrar los caso de subject verificacion cliente antes primero comprar si hay mas de 1 
    //un for para recorrreme todas las listasdetareas luego si hay 1 y es verfiicacion cliente el subject pasarla a cerrada y cerrar el caso y si no si hay 2 o mas pasarlas a pendiente reviison
    for (Task tarea : listasDeTareas) {
        if(tarea.Subject == 'Verificación cliente' && listasDeTareas.size() == 1 ){ //lista de tareas abiertas = 1
            tarea.Status = 'Completed';
            listaTaskCerradas.add(tarea);
        }else if(tarea.Subject == 'Verificación cliente' && listasDeTareas.size() > 1 ){ //lista de tareas abiertas + 1
            tarea.Status = 'Completed';
            listaTaskCerradas.add(tarea);
        }
    }
    update listaTaskCerradas;
    List<Task> listasDeTareasActualizada = [SELECT Status, Subject FROM Task WHERE WhatId IN :idCase AND Status = 'Open' ]; //vuelvo a buscarlo para ver si la lista es isEmpty por si las tareas solo son 1

    for (Case caso : listaCasos) { 
        //compruebo que su estado no cambie
        if (caso.Status == 'Pendiente Cliente') {
            if (String.isNotBlank(caso.CC_MCC_Motivo__c) //solo hace falta validar el motivo ya que los demas dependen de él
            && String.isNotBlank(caso.CC_Detalles_Consulta__c) && String.isNotBlank(caso.CC_Canal_Procedencia__c) && String.isNotBlank(caso.CC_Canal_Resolucion__c) 
            && String.isNotBlank(caso.CC_Tipo_Contacto__c) && String.isNotBlank(caso.CC_Canal_Operativo__c) && String.isNotBlank(caso.AccountId) 
            && String.isNotBlank(caso.ContactId) && listasDeTareasActualizada.isEmpty()) {   //Cerramos el caso si tenemos todos los datos para cerrar y NO HAY ninguna actividad abierta
                caso.Status = 'Activo';
                listaCasosCerrar.add(caso);
            } else {
                caso.Status = 'Pendiente Revisión';
                listaCasosRevisar.add(caso);  
            }
        }
    }

    //actualizamos casos a cerrar 
    update listaCasosCerrar;
    for (Case caso : listaCasosCerrar) {
        caso.Status = 'Cerrado';
    }
    update listaCasosCerrar;

    //actualizamos casos a revisar
    update listaCasosRevisar;      
    }
}