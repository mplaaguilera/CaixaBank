/*****************************************************************
 * Name: SAC_LCMP_TareasReclamacion
 * Copyright © 2025  CaixaBank
 * 
 * Propósito: Clase controlador del componente sac_TareasReclamacion
 * Clase test: SAC_LCMP_TareasReclamacion_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            --              Iria ANPC     08/01/25        Creación
*****************************************************************/
public with sharing class SAC_LCMP_TareasReclamacion {

    @AuraEnabled(cacheable=true)
    public static List<SAC_Accion__c> getRelatedTareas(Id reclamacionId) {
        return [SELECT Id, Name, toLabel(SAC_Estado__c), SAC_MaestroAccionesReclamacion__c, SAC_MaestroAccionesReclamacion__r.Name, SAC_Propietario__c FROM SAC_Accion__c WHERE SAC_Reclamacion__c = :reclamacionId];
    }
}