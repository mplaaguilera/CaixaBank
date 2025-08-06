/*********************************************************************************************************
 * Name: SPV_GrupoColaboradorHelper
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Clase para los métodos de los triggers de CC_Grupo_Colaborador__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0             US828257           Raúl Santos          29/04/24             Creación
**********************************************************************************************************/

public with sharing class SPV_GrupoColaboradorHelper {
    
    /*****************************************************************
     * Proposito: Rellenar el OS_Negocio__c para los grupos colaboradores de SPV.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR               DATE         Description
     * 1.0            US828257       Raúl Santos          29/04/24         Creación
    *****************************************************************/
    public static void rellenarNegocio(List<CC_Grupo_Colaborador__c> listNewObj){
        for (CC_Grupo_Colaborador__c grupo : listNewObj) {
            grupo.OS_Negocio__c = 'SPV';
        }
    }
}