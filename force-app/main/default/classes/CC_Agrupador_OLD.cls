public without sharing class CC_Agrupador_OLD {
    //No aplicar sharing settings/rules para que las tareas se puedan cerrar
    //aunque sea un objeto privado (solo editable por el propietario)

	@InvocableMethod(label='CC_Agrupador Cierre' description='Automatizaciones al cerrar un Agrupador')
    public static void cierreAgrupador (List<Id> agrupadores) {
        /*Objetivo de la función: Al Cerrar un Agrupador se deben cerrar automáticamente las tareas de traslado a incidencia asociadas al mismo
        y los casos asociados al mismo. En caso de no poder cerrar los casos se deben quedar en 'Pendiente Revisar'*/
        
        //Listado para obtener las tareas abiertas de tipo 'Traslado Incidencia' asociadas al Agrupador
        List<Task> tareasIncAbiertas = [SELECT Status FROM Task WHERE Agrupador__c IN :agrupadores AND Status = 'Open' AND Type = 'Traslado Incidencia'];
        
        //Listado para obtener los casos asociados al Agrupador
        List<Case> listaCasos = [SELECT Status, CC_CanalNotifCli__c FROM Case WHERE CC_Agrupador_Id__c IN :agrupadores];
        
        //Listado para guardar las tareas a modificar
        List<Task> tareasModif = new List<Task>();
        
        // Lista de tareas a notificar.
        List<ID> oTaskAviso = new List<Id>();
        Set<ID> oTaskAvisoNoDup = new Set<ID>();
        
        //Listados para guardar los casos a modificar, los casos que NO se han podido modificar correctamente y los casos que SÍ se han podido modificar
        List<Case> casosModif = new List<Case>();
        List<Case> casosModifKO = new List<Case>();
        List<Id> casosModifOK = new List<Id>();
        
        //Listado para guardar las nuevas tareas que se crean para asociarlas al caso
        List<Task> nuevasTareas = new List<Task>();

        //Se cierran las tareas de traslado a incidencia asociadas al Agrupador que estuvieran abiertas
        for (Task tAux : tareasIncAbiertas) {
            tAux.Status = 'Completed';
            tareasModif.add(tAux);
            
            oTaskAvisoNoDup.add(tAux.Id);
        }
        
        oTaskAviso.addAll(oTaskAvisoNoDup);
        oTaskAvisoNoDup = null;

        if (!tareasModif.isEmpty()) {
            Database.SaveResult[] results = Database.update(tareasModif, false);
        }
        
        //Recorremos los Casos asociados al Agrupador
        for (Case cAux : listaCasos) {
            //Si el Caso está Cerrado, no hacemos nada. En caso contrario lo cerramos
            if (cAux.Status != 'Cerrado') {
                cAux.Status = 'Cerrado';

                if (cAux.CC_CanalNotifCli__c == 'SMS') {
                    cAux.CC_Canal_Respuesta__c = 'SMS';
                }
                casosModif.add(cAux);
            }
        } 
        
        //Este update es para ver el pete que da de las nuevas validaciones, con el Database no se ven los petes
        //update casosModif;
        
        //Actualizamos los casos cerrados anteriormente
        if (!casosModif.isEmpty()) {
            Database.SaveResult[] results = Database.update(casosModif, false);
            
            //Recorremos los resultados de los casos modificados
            for (Database.SaveResult result : results) {
                
                //No es posible recuperar los Id de los Casos que no se han podido modificar, por lo que recuperamos los de los casos modificados correctamente
                if (result.isSuccess()) {
                    casosModifOK.add(result.getId());
                    
                    //Creación de Actividad asociada al Caso
                    Task nuevaTarea = new Task();
                    nuevaTarea.Type = 'Cierre Automático';
                    nuevaTarea.Subject = 'Cierre Automático';
                    nuevaTarea.WhatId = result.getId();
                    nuevaTarea.Status = 'Completed';
                    nuevaTarea.Description = 'Cierre Automático por cierre de Agrupador';
                    nuevasTareas.add(nuevaTarea);
                }       
            } 
            
            //Recuperamos los casos que no se han podido modificar haciendo descarte sobre el total de casos a modificar menos los modificados correctamente
            for (Case cAux2 : casosModif) {
                if (!casosModifOK.contains(cAux2.Id)) {
                    Case oCasoAux = new Case();
                    oCasoAux.Id = cAux2.Id;
                    //casosModifKO.add([SELECT Id FROM Case WHERE Id = :cAux2.Id]);
                    casosModifKO.add(oCasoAux);
                }  
            }
        }

        if (!nuevasTareas.isEmpty()) {
            insert nuevasTareas;
        }
        
        //Nuevo listado para añadir los casos que están pendientes de revisión (no se han podido modificar correctamente)
        List<Case> casosPtesRev = new List<Case>();
        //Nuevo listado para añadir las tareas nuevas de los casos pendientes de revisión
        List<Task> tareasPtesRev = new List<Task>();
        
        //Recorremos los casos que no se han podido cerrar y los ponemos en Pendiente Revisión
        if (!casosModifKO.isEmpty())  {
            for (Case cAux3 : casosModifKO) {
                cAux3.Status = 'Pendiente Revisión';
                cAux3.CC_Admin__c = false;
                casosPtesRev.add(cAux3);
                
                //Creación de Actividad asociada al Caso
                Task nuevaTarea = new Task();
                nuevaTarea.Type = 'Cierre automático fallido';
                nuevaTarea.Subject = 'Cierre automático fallido';
                nuevaTarea.WhatId = cAux3.Id;
                nuevaTarea.Status = 'Completed';
                nuevaTarea.Description = 'No se ha podido realizar el cierre automático del Caso al cerrar el Agrupador';
                tareasPtesRev.add(nuevaTarea);     
            }   
        }
        
        if (!casosPtesRev.isEmpty()) {
            Database.SaveResult[] results = Database.update(casosPtesRev, false);
        }
        
        if (!tareasPtesRev.isEmpty()) {
            insert tareasPtesRev;
        }
        
        //Contamos cuantos casos hay pendientes de revisar y mostramos un mensaje para que el agente lo gestione.
        List<String> ListaMensajes = new List<String>();
        String mensaje = '';
        if (casosModifKO.size() > 0) {
            if(casosModifKO.size() == 1) {
        	    mensaje = 'Hay ' + casosModifKO.size() + ' caso que no se ha podido cerrar y se debe revisar.';
                ListaMensajes.add(mensaje);
            }
            if(casosModifKO.size() > 1) {
                mensaje = 'Hay ' + casosModifKO.size() + ' casos que no se han podido cerrar y se deben revisar.';
                ListaMensajes.add(mensaje);
            }
        }
        CC_Notificacion.publicarToast(ListaMensajes, 'error');
        
        // Lanzamos las llamadas de aviso a cliente.
        if (!oTaskAviso.isEmpty())
        {
            CC_NotifSegInc.gestionarCierreIncidencia(oTaskAviso);
        }
    }
    
    @future
    public static void actualizarNumeroCasos(List<Id> idsAgrupador) {
        List<CC_Agrupador__c> agrupadores = new List<CC_Agrupador__c>();
        for (Id idAgrupador : idsAgrupador) {
            CC_Agrupador__c agrupador = new CC_Agrupador__c(Id = idAgrupador);
            agrupador.CC_Numero_Casos__c = [SELECT Count() FROM Case WHERE CC_Agrupador_Id__c = :idAgrupador];
            agrupadores.add(agrupador);
        }
        update agrupadores;
    }
}