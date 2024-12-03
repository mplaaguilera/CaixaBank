/*********************************************************************************************************
 * Name: SAC_GrupoColaboradorContact
 * Copyright © 2022  CaixaBank
 *  
 * Proposito: Clase para manejar la diferentes cauisticas del objeto Juntion Colaborador
 *              esta clase se llama desde el AI AU y AD del SAC_Grupo_Colaborador_Contact
 *  
 * Historial
 * -------
 * VERSION        USER_STORY            AUTHOR               DATE             Description
 * 1.0            US361683              Marcela Neira      05/02/22            Creación
**********************************************************************************************************/
public without sharing class SAC_GrupoColaboradorContact {

    /*****************************************************************
     * Proposito: Recalcular el check SAC_TieneUsuariosActivos__c del grupo si este tiene o no 
     *              usuarios activos
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR           DATE         Description
     * 1.0            US361683      Marcela Neira      05/02/22      Creación
    *****************************************************************/

    public static void recalcularUsuarioActivos(List<Id> listaIdesGrupos) {

        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        Id recTypeTareas =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Id recTypeLetrados =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();

        //List<CC_Grupo_Colaborador__c> listaGruposActualizar = new List<CC_Grupo_Colaborador__c>();
        Map<Id, CC_Grupo_Colaborador__c> mapaGruposActualizarFinal = new Map<Id, CC_Grupo_Colaborador__c>();
        
        List<CC_Grupo_Colaborador_Contact__c> listaColaboradores = [SELECT id, CC_Grupo_Colaborador__r.SAC_TieneUsuariosActivos__c, CC_Grupo_Colaborador__c, CC_Usuario__r.IsActive
                                                            FROM CC_Grupo_Colaborador_Contact__c 
                                                            WHERE CC_Usuario__r.IsActive = true AND CC_Grupo_Colaborador__c IN :listaIdesGrupos
                                                            AND (CC_Grupo_Colaborador__r.RecordTypeId =: recTypeProveedores
                                                            OR CC_Grupo_Colaborador__r.RecordTypeId =: recTypeTareas
                                                            OR CC_Grupo_Colaborador__r.RecordTypeId =: recTypeLetrados)];

        Map<Id,Boolean> mapaGruposActualizar = new  Map<Id,Boolean>();
        for (CC_Grupo_Colaborador_Contact__c gcc : listaColaboradores) {
            mapaGruposActualizar.put(gcc.CC_Grupo_Colaborador__c, false); 
            
            if(gcc.CC_Usuario__r.IsActive){
                mapaGruposActualizar.put(gcc.CC_Grupo_Colaborador__c, true);
            }
        }

        
        if(!mapaGruposActualizar.isEmpty()){
            for(Id ide : mapaGruposActualizar.keySet()){ 
                CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c();
                grupo.id = ide;
                grupo.SAC_TieneUsuariosActivos__c = mapaGruposActualizar.get(ide);
                //listaGruposActualizar.add(grupo);
                mapaGruposActualizarFinal.put(grupo.Id, grupo);
            }            
        }else{//Si no encuentra nada viene del Delete o no tiene usuarios activos
            for (Id ideGrupo : listaIdesGrupos) {
                CC_Grupo_Colaborador__c grupo = new CC_Grupo_Colaborador__c(Id = ideGrupo, SAC_TieneUsuariosActivos__c = false);
                //listaGruposActualizar.add(grupo);
                mapaGruposActualizarFinal.put(grupo.Id, grupo);
            }
        }

        if (!mapaGruposActualizarFinal.isEmpty()) { 
            //update listaGruposActualizar;
            Database.update(mapaGruposActualizarFinal.values(), false);
        }

    }
}