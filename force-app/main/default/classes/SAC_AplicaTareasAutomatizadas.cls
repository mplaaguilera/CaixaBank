public without sharing class SAC_AplicaTareasAutomatizadas {
/*****************************************************************
 * Name: SAC_AplicaTareasAutomatizadas
 * Copyright © 2021  CaixaBank
 * ============================================================
 * Proposito: Automatizar el estado del campo 'No aplica Tareas'
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US248481         Luis Mesa      14/07/21     Creación clase
*****************************************************************/

    public static void automatizarCasoAplicaTarea(List<SAC_Accion__c> acciones){
    /*****************************************************************
     * Proposito: Método updatear el caso si corresponde, concretamente el campo SAC_NoAplicaTareas__c; Insert
     * ============================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US248481         Luis Mesa     14/07/21      Creación Método
    *****************************************************************/
        Set<Id> idPretensiones = new Set<Id>(); 
        List<SAC_Accion__c> misAcciones = new List<SAC_Accion__c>();
        List<Case> porActualizar = new List<Case>();
        for(SAC_Accion__c accion : acciones){
            if(String.isNotBlank(accion.SAC_Pretension__c)){
                idPretensiones.add(accion.SAC_Pretension__c);
                misAcciones.add(accion);
            }
        }

        List<Case> pretensiones = [SELECT Id, SAC_NoAplicaTareas__c FROM Case WHERE Id IN: idPretensiones];
        List<SAC_Accion__c> accionesExistentes = [SELECT Id, SAC_Pretension__c FROM SAC_Accion__c WHERE SAC_Pretension__c IN: pretensiones];

        Map<Id, List<SAC_Accion__c>> mapPretAcciones = new Map<Id, List<SAC_Accion__c>>();

        for(Case caso : pretensiones){
            List<SAC_Accion__c> falsilla = new List<SAC_Accion__c>();
            mapPretAcciones.put(caso.Id, falsilla);
        }

        for(SAC_Accion__c miAccion : accionesExistentes){
            List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
            if(mapPretAcciones.containsKey(miAccion.SAC_Pretension__c)){
                listaAcciones = mapPretAcciones.get(miAccion.SAC_Pretension__c);
                listaAcciones.add(miAccion);
                mapPretAcciones.put(miAccion.SAC_Pretension__c, listaAcciones);
            }
        }

        for(SAC_Accion__c miAccion : misAcciones){
            List<SAC_Accion__c> listaAcciones = new List<SAC_Accion__c>();
            if(mapPretAcciones.containsKey(miAccion.SAC_Pretension__c)){
                listaAcciones = mapPretAcciones.get(miAccion.SAC_Pretension__c);
                listaAcciones.add(miAccion);
                mapPretAcciones.put(miAccion.SAC_Pretension__c, listaAcciones);
            }
        }

        for(Case miPretension : pretensiones){
            List<SAC_Accion__c> accionesFinales = mapPretAcciones.get(miPretension.Id);
            if(accionesFinales.size() == 2){
                if(miPretension.SAC_NoAplicaTareas__c){ miPretension.SAC_NoAplicaTareas__c = false; porActualizar.add(miPretension); }
            }
        }
        if(porActualizar.size() > 0){ update porActualizar; }
    }

    public static void automatizarCasoAplicaTareaDel(List<SAC_Accion__c> listaAcciones){
     /*****************************************************************
     * Proposito: Método updatear el caso si corresponde, concretamente el campo SAC_NoAplicaTareas__c; Delete
     * ============================================================
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US248481         Luis Mesa     16/07/21      Creación Método
    *****************************************************************/
        Set<Id> idPretensiones = new Set<Id>(); 
        List<SAC_Accion__c> misAcciones = new List<SAC_Accion__c>();
        List<Case> porActualizar = new List<Case>();
        for(SAC_Accion__c accion : listaAcciones){
            if(String.isNotBlank(accion.SAC_Pretension__c)){
                idPretensiones.add(accion.SAC_Pretension__c);
                misAcciones.add(accion);
            }
        }

        List<Case> pretensiones = [SELECT Id, SAC_NoAplicaTareas__c FROM Case WHERE Id IN: idPretensiones];
        List<SAC_Accion__c> accionesExistentes = [SELECT Id, SAC_Pretension__c FROM SAC_Accion__c WHERE SAC_Pretension__c IN: pretensiones];

        Map<Id, List<SAC_Accion__c>> mapPretAcciones = new Map<Id, List<SAC_Accion__c>>();
        
        for(Case caso : pretensiones){
            List<SAC_Accion__c> falsilla = new List<SAC_Accion__c>();
            mapPretAcciones.put(caso.Id, falsilla);
        }

        for(SAC_Accion__c miAccion : accionesExistentes){
            List<SAC_Accion__c> acciones = new List<SAC_Accion__c>();
            if(mapPretAcciones.containsKey(miAccion.SAC_Pretension__c)){
                acciones = mapPretAcciones.get(miAccion.SAC_Pretension__c);
                acciones.add(miAccion);
                mapPretAcciones.put(miAccion.SAC_Pretension__c, acciones);
            }
        }

        for(SAC_Accion__c miAccion : misAcciones){
            List<SAC_Accion__c> acciones = new List<SAC_Accion__c>();
            if(mapPretAcciones.containsKey(miAccion.SAC_Pretension__c)){
                acciones = mapPretAcciones.get(miAccion.SAC_Pretension__c);
                acciones.add(miAccion);
                mapPretAcciones.put(miAccion.SAC_Pretension__c, acciones);
            }
        }

        for(Case miPretension : pretensiones){
            List<SAC_Accion__c> accionesFinales = mapPretAcciones.get(miPretension.Id);
            if(accionesFinales.size() == 1){
                if(!miPretension.SAC_NoAplicaTareas__c){ miPretension.SAC_NoAplicaTareas__c = true; porActualizar.add(miPretension); }
            }
        }

        if(porActualizar.size() > 0){ update porActualizar; }
    }
}