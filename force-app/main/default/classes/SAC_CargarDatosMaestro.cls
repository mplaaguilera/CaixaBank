/*****************************************************************
 * Name: SAC_CargarDatosMaestro
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Cargar los datos como descripción, equipo responsable,
 *          plazo máximo cuando se dé de alta una tarea en el objeto
 *          SAC_Accion__c con RecorType del 
 *          Maestro de tareas  
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR             DATE         Description
 * 1.0            US204750         Marcela Neira    18/05/21       Creación
*****************************************************************/
public with sharing class SAC_CargarDatosMaestro {
    public static void cargarDatos(List<SAC_Accion__c> listNew) {

        System.debug(listNew.size());

        Id recTypeMaestroAcciones = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();
        Set<Id> setIdMaestroAcciones = new Set<Id>();
    
        for(SAC_Accion__c tareas: listNew){
            if(tareas.RecordTypeId == recTypeMaestroAcciones && tareas.SAC_MaestroAccionesReclamacion__c != null){
                setIdMaestroAcciones.add(tareas.SAC_MaestroAccionesReclamacion__c);
                //System.debug(tareas);
            }
        }
        
        if(!setIdMaestroAcciones.isEmpty() && Schema.SObjectType.SAC_MaestroAccionesReclamacion__c.isAccessible()){
            Map<Id,SAC_MaestroAccionesReclamacion__c> mapaMaestroAcciones = new Map<Id,SAC_MaestroAccionesReclamacion__c>
                                                                            ([SELECT id, SAC_Descripcion__c, SAC_EquipoResponsable__c,SAC_PlazoMaximo__c, SAC_Prorroga__c
                                                                            FROM SAC_MaestroAccionesReclamacion__c 
                                                                            WHERE id IN:setIdMaestroAcciones]);        

        
            if(!mapaMaestroAcciones.isEmpty()){
                for(SAC_Accion__c tareas: listNew){                 
                    if(tareas.SAC_MaestroAccionesReclamacion__c != null){
                        SAC_MaestroAccionesReclamacion__c datosMaestroAux = mapaMaestroAcciones.get(tareas.SAC_MaestroAccionesReclamacion__c);    
                        tareas.SAC_Descripcion__c= datosMaestroAux.SAC_Descripcion__c;
                        tareas.SAC_EquipoResponsable__c =  datosMaestroAux.SAC_EquipoResponsable__c; 
                        tareas.SAC_PlazoMaximo__c =  datosMaestroAux.SAC_PlazoMaximo__c; 
                        tareas.SAC_Prorroga__c=datosMaestroAux.SAC_Prorroga__c;
                    }   
                    
                }
            }           
    
        }
    }
}