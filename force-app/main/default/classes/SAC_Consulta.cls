/*****************************************************************************************
 * Name: SAC_Consulta
 * Copyright © 2021  CaixaBank
 * 
 * Propósito: Clase que contiene un método para rellenar datos de un caso de tipo consulta insertado.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE          Description
 * 1.0                          Daniel Benito     22/02/22      Creación Clase
******************************************************************************************/

public without sharing class SAC_Consulta {

    public static void rellenarDatosCreacion(List<Case> listNewCase){

        List<SAC_EmailService__c> emailService =  [SELECT Id, Name, SAC_GroupName__c, SAC_Naturaleza__c, SAC_RecordTypeDeveloperName__c FROM SAC_EmailService__c WHERE SAC_RecordTypeDeveloperName__c = 'SAC_Consulta' LIMIT 1];
        if(!emailService.isEmpty()){
            List<CC_Grupo_Colaborador__c> grupo = [SELECT id FROM CC_Grupo_Colaborador__c WHERE Name =: emailService[0].SAC_GroupName__c LIMIT 1];
            if(!grupo.isEmpty()){
                for (Case newCase : listNewCase) {
                    newCase.SEG_Grupo__c = grupo[0].id;
                    newCase.SAC_Naturaleza__c = emailService[0].SAC_Naturaleza__c;
                    if(newCase.Origin == 'SAC_Manual'){
                        newCase.Status = 'SAC_011';
                        newCase.SAC_StatusAuxiliar__c = 'SAC_011';
                }
            }
        }        
    }
}
    public static void desmarcarCheckReclamacion(List<Case> listaCasosSelect, Set<Id> setIdesRecCheck, Map<Id,Case> mapaDatosCasosActualizar) { 

        Map<Id,List<Case>> mapaReclaConsultas = new Map<Id,List<Case>>();

        for (Id ide : setIdesRecCheck) {
            mapaReclaConsultas.put(ide, new List<Case>());
        }

        for (Case consulta : listaCasosSelect) {
            if(mapaReclaConsultas.containsKey(consulta.CC_CasoRelacionado__c) && 
               (consulta.Status != 'SAC_008' && consulta.Status != 'SAC_012' && consulta.Status != 'SAC_013')){
                List<Case> listaConsultas = mapaReclaConsultas.get(consulta.CC_CasoRelacionado__c);
                listaConsultas.add(consulta);
                mapaReclaConsultas.put(consulta.CC_CasoRelacionado__c, listaConsultas);
            }
        }     

        for (Id ide : setIdesRecCheck) {
            if(mapaDatosCasosActualizar.containsKey(ide)){ 
                mapaDatosCasosActualizar.get(ide).SAC_NuevaConsulta__c = (mapaReclaConsultas.get(ide).isEmpty())? false : true;               
            }else if (!mapaDatosCasosActualizar.containsKey(ide)){
                mapaDatosCasosActualizar.put(ide, New Case(id = ide, SAC_NuevaConsulta__c = (mapaReclaConsultas.get(ide).isEmpty())? false : true));
            }
        }

        System.debug('mapaDatosCasosActualizar' + mapaDatosCasosActualizar);
    }
}