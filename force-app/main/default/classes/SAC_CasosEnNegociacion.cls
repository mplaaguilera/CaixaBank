/*****************************************************************
 * Name: SAC_CasosEnNegociacion
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Redacción final de la reclamación
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US447862     Marcela Neira     07/09/22      Creación
*****************************************************************/
public without sharing class SAC_CasosEnNegociacion {

     /*****************************************************************
    * Proposito: Informa la fecha de resolución si alguna de las pretensiones ha entrado en 
    *            estado de negociación
    *
    * Modificacion 1.1: A las reclamaciones a las que se le informa una fecha de resolución, se les crea
    * una task para mis clientes. Esta creación se lleva a cabo mediante la llamada al método crearTaskMisClientes
    *
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US447862     Marcela Neira     07/09/22      Creación
    * 1.1            US542308     Carlos Solis      17/05/23      Modificación
    *****************************************************************/ 

    public static void informarFechaResolucion(Set<Id> setReclamaciones, List<Case> listaCasosSelect,  map<Id,Case> mapaDatosCasosActualizar) {
 
        Map<Id,Case> mapaReclamaciones = new Map<Id,Case>();
        
        for (Id Ide : setReclamaciones) {  //Creamos el mapa con las ides de la reclamación
            mapaReclamaciones.put(Ide, null);
        }
 
        for (Case reclamacion : listaCasosSelect) {  // Solo si la fecha de resolucion de la reclamación es nula la debemos informar
            if(mapaReclamaciones.containsKey(reclamacion.Id) && reclamacion.OS_Fecha_Resolucion__c == null){ 
                mapaReclamaciones.put(reclamacion.Id, reclamacion);
            }
        } 

        for(Id ide : mapaReclamaciones.keySet()){ //Borramos los items que estan a nulo esto quiere decir que ya tienen una fecha de resolución y no se debe pisar
            Case item = mapaReclamaciones.get(ide);
            if(item == null){
                mapaReclamaciones.remove(Ide);
            }        
        }

        //Mod 1.1
        List<Case> listaCasosTask = new List<Case>();
        //Fin Mod 1.1
        for (Case caso : mapaReclamaciones.values())  { // Guardamos en el mapa generico de actualizaciones que viene del trigger en esta caso del AU
            if(mapaDatosCasosActualizar.containsKey(caso.id)){
                Case casoAux = mapaDatosCasosActualizar.get(caso.id);
                casoAux.OS_Fecha_Resolucion__c = System.now();
                mapaDatosCasosActualizar.put(caso.id, casoAux);
            }else{
                mapaDatosCasosActualizar.put(caso.id, caso);
            }
            //Mod 1.1
            //Dar valor a la fecha de resolución para que en la llamada al método crearTaskMisClientes pueda hacer las comprobaciones (con este valor no se hace nada, no es el que updatea)
            if (caso.OS_Fecha_Resolucion__c == null) {
                caso.OS_Fecha_Resolucion__c = System.now();
            }
            listaCasosTask.add(caso);
            //Fin Mod1.1
        } 

        //Mod 1.1
        if (!listaCasosTask.isEmpty()) {
            SAC_Reclamacion.crearTaskMisClientes(listaCasosTask, listaCasosSelect);
        }
        //Fin Mod 1.1
    }
}