/*****************************************************************
 * Name: SAC_GrupoColaboradorMetodos
 * Copyright © 2021  CaixaBank 
 * 
 * Proposito: Clase para los métodos de los triggers de CC_Grupo_Colaborador__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.1            US304889         Marcela Neira  04/05/2022      Creación                                                             
*****************************************************************/
public with sharing class SAC_GrupoColaboradorMetodos {
    public static void validarDeveloperName(List<CC_Grupo_Colaborador__c> listNewObj, Map<Id, CC_Grupo_Colaborador__c> mapOldObj) {
        List<String> listaDeveloperNames = new List<String>();

        for (CC_Grupo_Colaborador__c grupo : listNewObj) {
            
            if(mapOldObj == null){
                if(!String.isBlank(grupo.SAC_DeveloperName__c) ){
                    grupo.SAC_DeveloperName__c = grupo.SAC_DeveloperName__c.toUppercase();
                    listaDeveloperNames.add(grupo.SAC_DeveloperName__c);
                }
            }else{
                if(mapOldObj.containsKey(grupo.Id) && grupo.SAC_DeveloperName__c != mapOldObj.get(grupo.Id).SAC_DeveloperName__c && !String.isBlank(grupo.SAC_DeveloperName__c)){
                    grupo.SAC_DeveloperName__c = grupo.SAC_DeveloperName__c.toUppercase();
                    listaDeveloperNames.add(grupo.SAC_DeveloperName__c);         
                }       
            }
        }

        if(!listaDeveloperNames.isEmpty()){
            List<CC_Grupo_Colaborador__c> listaCoincidencias = [SELECT Id, SAC_DeveloperName__c FROM CC_Grupo_Colaborador__c WHERE SAC_DeveloperName__c IN: listaDeveloperNames];
            Map<String,String> mapaCoincidencias= new Map<String,String>(); 
            if(!listaCoincidencias.isEmpty()){
                for (CC_Grupo_Colaborador__c grupo : listaCoincidencias) {
                    mapaCoincidencias.put(grupo.SAC_DeveloperName__c, grupo.SAC_DeveloperName__c);
                }

                for (CC_Grupo_Colaborador__c grupo : listNewObj) {
                    if(mapaCoincidencias.containsKey(grupo.SAC_DeveloperName__c)){
                       grupo.addError('Ya existe un grupo con este developer name.');
                    }
                }
                
            }
        }
        
    }
    /*****************************************************************
     * Proposito: Rellenar el OS_Negocio__c para los grupos colaboradores de SAC.
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR               DATE         Description
     * 1.0            US516617         Jose Carlos Blanco   23/01/2023   Creación
    *****************************************************************/
    public static void rellenarNegocio(List<CC_Grupo_Colaborador__c> listNewObj){
        for (CC_Grupo_Colaborador__c grupo : listNewObj) {
            grupo.OS_Negocio__c = 'SAC';
        }
    }
}