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
 * 1.1              US1208226     Raúl Santos    24/04/2025      Modificación: reutilizar para el proyecto SPV  
*****************************************************************/
public with sharing class SAC_LCMP_AsuntosPendientes {  

    private static Set<String> objetos = new Set<String>{'SAC_Interaccion__c','SAC_Accion__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    
    final static Id RECTYPECONSULTA = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Consulta').getRecordTypeId();
    final static Id RECTYPEESCALADONV2 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_Escalado').getRecordTypeId();
    final static Id RECTYPEESCALADONV3 = mapRTsObjects.get('SAC_Interaccion__c').get('SAC_EscaladoNV3').getRecordTypeId();
    final static Id RECTYPEOTRATAREA = mapRTsObjects.get('SAC_Accion__c').get('SAC_OtrasTareas').getRecordTypeId();
    final static Id RECTYPEMAESTROTAREA = mapRTsObjects.get('SAC_Accion__c').get('SAC_MaestroDeTareas').getRecordTypeId();
  
    final static Id RECTYPECONSULTA_SPV = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Consulta').getRecordTypeId();
    final static Id RECTYPEESCALADO_SPV = mapRTsObjects.get('SAC_Interaccion__c').get('SPV_Escalado').getRecordTypeId();
    final static Id RECTYPEOTRATAREA_SPV = mapRTsObjects.get('SAC_Accion__c').get('SPV_Acciones').getRecordTypeId();
    final static Id RECTYPEMAESTROTAREA_SPV = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();


    @AuraEnabled
    public static AsuntosPendientesWrapper comprobarAsuntos(String idCaso) {
        
        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();
        String mensaje;

        try {
            List<SAC_Accion__c> listaTareas = [SELECT id, Name, CreatedDate, SAC_Estado__c, SAC_FechaVencimientoInicial__c 
                                                FROM SAC_Accion__c 
                                                WHERE RecordTypeId IN (:RECTYPEOTRATAREA, :RECTYPEMAESTROTAREA, :RECTYPEOTRATAREA_SPV, :RECTYPEMAESTROTAREA_SPV) AND SAC_Reclamacion__c =:idCaso AND (SAC_Estado__c <> 'SAC_Finalizada' AND SAC_Estado__c <> 'SAC_FinalizadaIncompleta'  AND SAC_Estado__c <> 'SAC_Descartada')];

            List<SAC_Interaccion__c> listaInteracciones = [SELECT Id, Name, SAC_Estado__c, CreatedDate, SAC_Conclusion__c, SAC_CasoEscalado__c, RecordTypeId,
                                                        SAC_GrupoColaborador__r.Name, SAC_Titulo__c
                                                        FROM SAC_Interaccion__c 
                                                        WHERE RecordTypeId IN (:RECTYPECONSULTA, :RECTYPEESCALADONV2, :RECTYPEESCALADONV3, :RECTYPECONSULTA_SPV, :RECTYPEESCALADO_SPV) AND (SAC_CasoEscalado__c =: idCaso OR SAC_Reclamacion__c =: idCaso) AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva')];

            for(SAC_Interaccion__c interaccion: listaInteracciones){
                if(interaccion.RecordTypeId == RECTYPEESCALADONV2 || interaccion.RecordTypeId == RECTYPEESCALADONV3 || interaccion.RecordTypeId == RECTYPEESCALADO_SPV){
                    listaEscalados.add(interaccion);
                }else if(interaccion.RecordTypeId == RECTYPECONSULTA || interaccion.RecordTypeId == RECTYPECONSULTA_SPV){
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