/*****************************************************************
 * Name: SAC_AccionGGH
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Mirar si ya hay creada una tarea GGH por pretensió que salte 
 *              un error
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US431440      Marcela Neira   05/09/22       Creación
*****************************************************************/
public with sharing class SAC_AccionGGH {
    
    final static String RECORDTYPEACCIONMASETRO = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();

    public static void tareaUnicaGGH(List<SAC_Accion__c> listaAcciones) {
 
        List<SAC_MaestroAccionesReclamacion__c> maestroGHH =[SELECT id, SAC_DeveloperName__c FROM SAC_MaestroAccionesReclamacion__c WHERE SAC_DeveloperName__c = 'GGH' LIMIT 1]; 
        Set<Id> idePretensiones = new Set<Id>();

        for (SAC_Accion__c accion : listaAcciones) { //Nos quedamos solo con las tareas que en el maestro tengan de developer name GGH
            if(!maestroGHH.isEmpty() && accion.SAC_MaestroAccionesReclamacion__c == maestroGHH[0].Id){
                idePretensiones.add(accion.SAC_Pretension__c);
            }
        }

        if(!idePretensiones.isEmpty()){
            //Buscamos si hay mas tareas en la pretension con developer name GGH en el maestro de tareas
            List<SAC_Accion__c> listaTareasGGH = [SELECT Id, SAC_Pretension__c FROM SAC_Accion__c 
                WHERE RecordTypeId =: RECORDTYPEACCIONMASETRO AND SAC_Pretension__c IN: idePretensiones
                AND SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'GGH'];
            
            if (!listaTareasGGH.isEmpty()) {

                Map<Id,List<SAC_Accion__c>> mapaTareas = new Map<Id,List<SAC_Accion__c>>();

                for (Id ide : idePretensiones) { // iniciar el mapa para la comprobación de tareas repetidas
                    mapaTareas.put(ide, new List<SAC_Accion__c>());
                }

                for (SAC_Accion__c accion : listaTareasGGH) { //rellenamos el mapa con todas las tareas
                    if (mapaTareas.containsKey(accion.SAC_Pretension__c) ) {
                        List<SAC_Accion__c> listaAux = mapaTareas.get(accion.SAC_Pretension__c);
                        listaAux.add(accion);
                        mapaTareas.put(accion.SAC_Pretension__c, listaAux);
                    }
                }

                for (SAC_Accion__c accion : listaAcciones) {
                    if (mapaTareas.containsKey(accion.SAC_Pretension__c) ) {
                        if(!mapaTareas.get(accion.SAC_Pretension__c).isEmpty()){
                            accion.addError('Ya existe una tarea de GGH para esta pretensión');
                        }
                    }
                }
            }
        }
        
    }
}