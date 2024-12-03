/*****************************************************************
 * Name: SAC_Case_BI_TRHan
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Trigger Handler para controlar el Before Insert del objeto SAC_Interaccion__c
 * Clases test: SAC_LCMP_InsertarReescalado_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US219272         Carlos Solis   15/07/21     Creación
*****************************************************************/
public without sharing class SAC_Interaccion_BI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Interaccion__c>)tp.newList, (Map<Id, SAC_Interaccion__c>)tp.newMap);
	}

    private void process(List<SAC_Interaccion__c> listNewObj, Map<Id, SAC_Interaccion__c> mapNewObj) {
        //Obtener record Type
        Id recTypeConsulta =Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        Id recTypeEscaladoNv2 =Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
        Id recTypeEscaladoNv3 =Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();

        //Listas
        List<SAC_Interaccion__c> listaConsultasYEscalados = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();

        //Recorrer la lista del trigger new y asignar las interacciones que tengan el record type deseado a la lista con la que queremos trabajar.
        for (SAC_Interaccion__c interaccion : listNewObj) {
            if (interaccion.recordTypeId == recTypeConsulta || interaccion.recordTypeId == recTypeEscaladoNv2 || interaccion.recordTypeId == recTypeEscaladoNv3) {
                listaConsultasYEscalados.add(interaccion);
            }
            if(interaccion.recordTypeId == recTypeConsulta){
                listaConsultas.add(interaccion);
            }
        }
    
        //Si la lista listaConsultasYEscalados no está vacía, trabajamos con nuestros metodos
        if (!listaConsultasYEscalados.isEmpty()) {
            SAC_Interaccion.rellenarNifYNombreReclamante(listaConsultasYEscalados);
            SAC_Interaccion.rellenarGrupoCreador(listaConsultas);
        }
    }
}