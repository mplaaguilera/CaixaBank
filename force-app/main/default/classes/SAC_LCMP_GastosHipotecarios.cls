/*****************************************************************
 * Name: SAC_LCMP_GastosHipotecarios
 * Copyright © 2022 CaixaBank  
 * 
 * Proposito: Controlador del LWC sac_GastosHipotecarios, Adaptación GGH
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0             US431440      Marcela Neira  31/08/22        Creación      
*****************************************************************/
public with sharing class SAC_LCMP_GastosHipotecarios {

    /*****************************************************************
     * Proposito: Comprar si la tarea de GGH todavia se puede modificar
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US431440       Marcela Neira  05/09/22        Creación  
    *****************************************************************/

    @AuraEnabled(cacheable=true)
    public static Boolean comprobarTareas(Id caseId){

        Boolean noSePuedeModificarTarea = true;

        try {
            List<SAC_Accion__C> listaTareas = [SELECT Id, SAC_Estado__c FROM SAC_Accion__C WHERE SAC_Pretension__c =:caseId 
            AND SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'GGH'];

            if(!listaTareas.isEmpty()){
                for (SAC_Accion__C tarea : listaTareas) {
                    if(tarea.SAC_Estado__c == 'SAC_PendienteEnviar'){
                        noSePuedeModificarTarea = false;
                    }else{
                        noSePuedeModificarTarea = true;
                    }
                }
            }else{
                noSePuedeModificarTarea = false;
            }

            return  noSePuedeModificarTarea;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void modificarImportesTarea(Id caseId, Integer[] arrayImportes){
        try {
            List<SAC_Accion__c> listaTareas = [SELECT Id, SAC_Estado__c, SAC_ImpResueltoNotaria__c, SAC_ImpResueltoGestoria__c, SAC_ImpResueltoRegistros__c,
                                SAC_ImpResueltoTasacion__c, SAC_ImpResueltoInteresesLegales__c, SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c
                                FROM SAC_Accion__C WHERE SAC_Pretension__c =:caseId 
                                AND (
                                    (SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'GGH' AND SAC_Estado__c = 'SAC_PendienteEnviar')
                                    OR (SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'FE' AND SAC_Estado__c = 'SAC_PendienteEnviar')
                                    )];

            Boolean actualizar = false;
         

            if(!listaTareas.isEmpty()){
                for (SAC_Accion__c accion : listaTareas) {
                    if (accion.SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c == 'GGH') {
                        if (accion.SAC_ImpResueltoNotaria__c != arrayImportes[0]) {
                            accion.SAC_ImpResueltoNotaria__c = arrayImportes[0];
                            actualizar = true;
                        }
                        if (accion.SAC_ImpResueltoGestoria__c != arrayImportes[1]) {
                            accion.SAC_ImpResueltoGestoria__c = arrayImportes[1];
                            actualizar = true;
                        }
                        if (accion.SAC_ImpResueltoRegistros__c != arrayImportes[2]) {
                            accion.SAC_ImpResueltoRegistros__c = arrayImportes[2];
                            actualizar = true;
                        }
                        if (accion.SAC_ImpResueltoTasacion__c != arrayImportes[3]) {
                            accion.SAC_ImpResueltoTasacion__c = arrayImportes[3];
                            actualizar = true;
                        }
                    }
                    if (accion.SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c == 'FE') {
                        //estos deben ser los de la tarea de intereses legales
                        if (accion.SAC_ImpResueltoInteresesLegales__c != arrayImportes[4]) {
                            accion.SAC_ImpResueltoInteresesLegales__c = arrayImportes[4];
                            actualizar = true;
                        }
                    }
                }
            }

            if (actualizar) {
                  update listaTareas;
            }
            

        } catch (Exception e) {
            System.debug('mensaje del error ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}