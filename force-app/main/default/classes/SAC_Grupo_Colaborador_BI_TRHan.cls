/*****************************************************************
 * Name: SAC_Grupo_Colaborador_BI_TRHan
 * Copyright © 2019  CaixaBank 
 * 
 * Proposito: Trigger Handler para controlar el Before Insert del objeto CC_Grupo_Colaborador__c
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR               DATE         Description
 * 1.0            US213183         Carlos Solis         13/05/21     Creación
 * 1.1            US304889         Marcela Neira        04/05/2022   Modificación para que el campo SAC_DeveloperName__c sea único.
 * 1.2            US516617         Jose Carlos Blanco   23/01/2023   Modificación                                                            
*****************************************************************/
public with sharing class SAC_Grupo_Colaborador_BI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<CC_Grupo_Colaborador__c>)tp.newList, (Map<Id, CC_Grupo_Colaborador__c>)tp.newMap);
	}

    private void process(List<CC_Grupo_Colaborador__c> listNewObj, Map<Id, CC_Grupo_Colaborador__c> mapNewObj) {
        //Obtener record Type
        Id recTypeProveedores =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoProveedores').getRecordTypeId();
        Id recTypeTareas =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_GrupoResponsableAccion').getRecordTypeId();
        Id recTypeLetrados =Schema.SObjectType.CC_Grupo_Colaborador__c.getRecordTypeInfosByDeveloperName().get('SAC_Letrados').getRecordTypeId();

        //Recorrer la lista del trigger new y asignar los grupos que tengan el record type SAC_GrupoProveedores a la lista con la que queremos trabajar.
        List<CC_Grupo_Colaborador__c> listaGrupos = new List<CC_Grupo_Colaborador__c>();
        List<CC_Grupo_Colaborador__c> listaGruposSAC = new List<CC_Grupo_Colaborador__c>();

        for (CC_Grupo_Colaborador__c grupo : listNewObj) {
            if (grupo.RecordTypeId == recTypeProveedores) {
                listaGrupos.add(grupo);
                listaGruposSAC.add(grupo);
            }else if (grupo.RecordTypeId == recTypeTareas){
                listaGruposSAC.add(grupo);
            }else if(grupo.RecordTypeId == recTypeLetrados){
                listaGruposSAC.add(grupo);
            }
        }
        //Si la lista con los grupos no está vacia, trabajamos con nuestros métodos
        if (!listaGrupos.isEmpty()) {
            SAC_PorcentajesGrupoColaborador.establecerPorcentajeAsignacion(listaGrupos); //Establece el campo porcentaje de asignación a 100 si es el primer grupo en entrar en el sistema, si no a 0
            SAC_PorcentajesGrupoColaborador.comprobarPorcentajeInsert(listaGrupos); //Comprueba que el porcenatje de todos los grupos que ya existen más el nuevo insertado sea igual a 100
        }
        if(!listaGruposSAC.isEmpty()){
            SAC_GrupoColaboradorMetodos.validarDeveloperName(listaGruposSAC, null);
            SAC_GrupoColaboradorMetodos.rellenarNegocio(listaGruposSAC); //<-----
        }
    }

}