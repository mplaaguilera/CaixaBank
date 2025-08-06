/*****************************************************************
 * Name: SAC_LCMP_ConsultasTareas
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Controlador componente
 *              
 *   LWC asociado: sAC_ConsultasTareas
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US380275      Marcela Neira    02/06/22      Creación Clase
*****************************************************************/
public without sharing class SAC_LCMP_ConsultasTareas {
    
    @AuraEnabled(cacheable=true)
    public static AsuntosWrapper getActionConsultaOffice (){
        Id recTypeConsulta = Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();

        id userId = userInfo.getUserId();
        /* SAC_Titulo__c, SAC_Descripcion__c, SAC_PlazoMaximo__c, SAC_FechaVencimientoInicial__c, SAC_FechaVencimientoProrroga__c, */
        List <SAC_Accion__c> lstTareas = [SELECT Id, RecordType.Name, toLabel(SAC_Estado__c), SAC_Reclamacion__r.CaseNumber, Owner.Name, SAC_Comentarios__c,
                                        SAC_Reclamacion__r.SAC_NombreContacto__c, SAC_Reclamacion__r.CC_SuppliedNIF__c, SAC_FechaVencimiento__c, SAC_Oficina__r.CC_Numero_Oficina__pc, SAC_Oficina__r.AV_NumeroCentroCaixaBank__c
                                        FROM SAC_Accion__c 
                                        WHERE  SAC_Reclamacion__r.CaseNumber != null AND Owner.Name != null AND SAC_Estado__c in ('SAC_PendienteAsignar', 'SAC_EnGestion', 'SAC_StandBy') 
                                        AND SAC_Oficina__c in (select AccountId from contact where AV_UsuarioAsociado__c =: userId )]; /*CC_OficinaGestoraId__c*/

        /* SAC_Titulo__c, toLabel(SAC_Estado__c) */
        List <SAC_Interaccion__c> lstConsultas = [SELECT Id, SAC_Pregunta__c, Owner.Name, SAC_Reclamacion__r.CaseNumber, SAC_Respuesta__c,
                                                SAC_Reclamante__c, SAC_Reclamacion__r.CC_SuppliedNIF__c, SAC_Fecha_Vencimiento__c, SAC_Oficina__r.CC_Numero_Oficina__pc, SAC_Oficina__r.AV_NumeroCentroCaixaBank__c
                                                FROM SAC_Interaccion__c 
                                                WHERE RecordTypeId = :recTypeConsulta AND (SAC_Estado__c = 'SAC_PendienteRespuesta' OR SAC_Estado__c = 'SAC_PendienteRespuestaDefinitiva') AND SAC_Reclamacion__r.CaseNumber != null AND Owner.Name != null AND
                                                SAC_Oficina__c in (select AccountId from contact where AV_UsuarioAsociado__c =: userId )];

        if(!lstTareas.isEmpty()){for (SAC_Accion__c tarea : lstTareas) {if(String.isNotBlank(tarea.SAC_Comentarios__c)){tarea.SAC_Comentarios__c = tarea.SAC_Comentarios__c.replaceAll('<[/a-zAZ0-9]*>','');}}}

        if(!lstConsultas.isEmpty()){for (SAC_Interaccion__c consulta : lstConsultas){if(String.isNotBlank(consulta.SAC_Pregunta__c)){consulta.SAC_Pregunta__c = consulta.SAC_Pregunta__c.replaceAll('<[/a-zAZ0-9]*>','');}if(String.isNotBlank(consulta.SAC_Respuesta__c)){consulta.SAC_Respuesta__c = consulta.SAC_Respuesta__c.replaceAll('<[/a-zAZ0-9]*>','');}}}
               
        AsuntosWrapper asuntos = new AsuntosWrapper(lstConsultas, lstTareas);
        return asuntos;
    }

    
    @AuraEnabled(cacheable=true)
    public static String getURLHomeOficinas() {
        return URL.getSalesforceBaseUrl().toExternalForm() +'/lightning/app/c__SAC_HomeOficinas/n/Home_Oficina';
    }

    public class AsuntosWrapper {

        @AuraEnabled public List <SAC_Interaccion__c> lstConsultas {get; set;}
        @AuraEnabled public List <SAC_Accion__c> lstTareas {get; set;}

        public AsuntosWrapper(List <SAC_Interaccion__c> lstConsultasC, List <SAC_Accion__c> lstTareasC){
            lstConsultas = lstConsultasC;
            lstTareas = lstTareasC;
        }
    }
}