/*****************************************************************
 * Name: SAC_LCMP_AsuntosPendientes
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador del componente sAC_AsuntosPendientes
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0              US308697     Marcela Neira   24/03/2022      Creación
*****************************************************************/
public with sharing class SAC_LCMP_AsuntosPendientes {  
    @AuraEnabled
    public static AsuntosPendientesWrapper comprobarAsuntos(String idCaso) {
        Id RECTYPEESCALADON2= Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
        Id RECTYPEESCALADON3= Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();
        Id RECTYPECONSULTA= Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        
        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();
        String mensaje;

    try {
        List<SAC_Accion__c> listaTareas = [SELECT id, Name, CreatedDate, SAC_Estado__c, SAC_FechaVencimientoInicial__c 
                                            FROM SAC_Accion__c 
                                            WHERE SAC_Reclamacion__c =:idCaso AND (SAC_Estado__c <> 'SAC_Finalizada' AND SAC_Estado__c <> 'SAC_FinalizadaIncompleta'  AND SAC_Estado__c <> 'SAC_Descartada')];
        List<SAC_Interaccion__c> listaInteracciones = [SELECT Id, Name, SAC_Estado__c, CreatedDate, SAC_Conclusion__c, SAC_CasoEscalado__c, RecordTypeId,
                                                    SAC_GrupoColaborador__r.Name, SAC_Titulo__c
                                                    FROM SAC_Interaccion__c 
                                                    WHERE (SAC_CasoEscalado__c =: idCaso OR SAC_Reclamacion__c =: idCaso) AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva')];

        for(SAC_Interaccion__c interaccion: listaInteracciones){
            if(interaccion.RecordTypeId == RECTYPEESCALADON2 || interaccion.RecordTypeId == RECTYPEESCALADON3){
                listaEscalados.add(interaccion);
            }else if(interaccion.RecordTypeId == RECTYPECONSULTA){
                listaConsultas.add(interaccion);
            }
        }

        if(listaTareas.isEmpty() && listaConsultas.isEmpty() && listaEscalados.isEmpty()){
            mensaje='No tiene asuntos pendientes';
        }else {
            mensaje='OK';
        }

        AsuntosPendientesWrapper  apw = new AsuntosPendientesWrapper(listaTareas, listaEscalados , listaConsultas, mensaje);
        return  apw;

    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
        }
    }

    /**************************************************************************
     * Proposito: Clase wrapper para los asuntos pendientes
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0             US308697     Marcela Neira   24/03/2022      Creación
    **************************************************************************/  

    public class AsuntosPendientesWrapper{
        @AuraEnabled public List<SAC_Accion__c> listaTareas {get; set;}
        @AuraEnabled public List<SAC_Interaccion__c> listaEscalados {get; set;}
        @AuraEnabled public List<SAC_Interaccion__c> listaConsultas {get; set;}
        @AuraEnabled public String mensaje {get; set;}

        public AsuntosPendientesWrapper(List<SAC_Accion__c> listaTareasC, List<SAC_Interaccion__c> listaEscaladosC, List<SAC_Interaccion__c> listaConsultasC, String mensajeC){
            listaTareas = listaTareasC;
            listaEscalados = listaEscaladosC;
            listaConsultas = listaConsultasC;
            mensaje = mensajeC;
        }
    }
}