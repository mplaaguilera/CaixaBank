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

    //US1063712 - Raúl Santos - 07/11/24 - Nueva lógica para al actualizar los importes de las tareas y comentado el importe de intereses legales
    @AuraEnabled
    public static void modificarImportesTarea(Id caseId, String[] arrayImportes){
        try {
            List<SAC_Accion__c> listaTareas = [SELECT Id, SAC_Estado__c, SAC_ImpResueltoNotaria__c, SAC_ImpResueltoGestoria__c, SAC_ImpResueltoRegistros__c,
                                SAC_ImpResueltoTasacion__c, SAC_ImpResueltoInteresesLegales__c, SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c
                                FROM SAC_Accion__C WHERE SAC_Pretension__c =:caseId AND SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'GGH' AND SAC_Estado__c = 'SAC_PendienteEnviar'];
                                // AND (
                                //     (SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'GGH' AND SAC_Estado__c = 'SAC_PendienteEnviar')
                                //     OR (SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c = 'FE' AND SAC_Estado__c = 'SAC_PendienteEnviar')
                                //     )];

            Boolean actualizar = false;
         

            if(!listaTareas.isEmpty()){
                for (SAC_Accion__c accion : listaTareas) {
                    if (accion.SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c == 'GGH') {
                        if(arrayImportes[0] == null && accion.SAC_ImpResueltoNotaria__c != null){
                            accion.SAC_ImpResueltoNotaria__c = null;
                            actualizar = true;
                        }else if (arrayImportes[0] != null && accion.SAC_ImpResueltoNotaria__c != Decimal.valueOf(arrayImportes[0])) {
                            accion.SAC_ImpResueltoNotaria__c = Decimal.valueOf(arrayImportes[0]);
                            actualizar = true;
                        }


                        if(arrayImportes[1] == null && accion.SAC_ImpResueltoGestoria__c != null){
                            accion.SAC_ImpResueltoGestoria__c = null;
                            actualizar = true;
                        }else if (arrayImportes[1] != null && accion.SAC_ImpResueltoGestoria__c != Decimal.valueOf(arrayImportes[1])) {
                            accion.SAC_ImpResueltoGestoria__c = Decimal.valueOf(arrayImportes[1]);
                            actualizar = true;
                        }


                        if(arrayImportes[2] == null && accion.SAC_ImpResueltoRegistros__c != null){
                            accion.SAC_ImpResueltoRegistros__c = null;
                            actualizar = true;
                        }else if (arrayImportes[2] != null && accion.SAC_ImpResueltoRegistros__c != Decimal.valueOf(arrayImportes[2])) {
                            accion.SAC_ImpResueltoRegistros__c = Decimal.valueOf(arrayImportes[2]);
                            actualizar = true;
                        }


                        if(arrayImportes[3] == null && accion.SAC_ImpResueltoTasacion__c != null){
                            accion.SAC_ImpResueltoTasacion__c = null;
                            actualizar = true;
                        }else if (arrayImportes[3] != null && accion.SAC_ImpResueltoTasacion__c != Decimal.valueOf(arrayImportes[3])) {
                            accion.SAC_ImpResueltoTasacion__c = Decimal.valueOf(arrayImportes[3]);
                            actualizar = true;
                        }
                    }
                    // if (accion.SAC_MaestroAccionesReclamacion__r.SAC_DeveloperName__c == 'FE') {
                    //     //estos deben ser los de la tarea de intereses legales
                    //     if (accion.SAC_ImpResueltoInteresesLegales__c != arrayImportes[4]) {
                    //         accion.SAC_ImpResueltoInteresesLegales__c = arrayImportes[4];
                    //         actualizar = true;
                    //     }
                    // }
                }
            }

            if (actualizar) {
                SAC_DatabaseDML.updateListDML(listaTareas, true);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}