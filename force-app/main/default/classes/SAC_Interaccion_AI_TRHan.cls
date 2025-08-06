/*
Clases test: SAC_LCMP_InsertarReescalado_Test, SAC_Notificacion_Test
*/
public with sharing class SAC_Interaccion_AI_TRHan extends CC_TriggerHandlerBase{
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<SAC_Interaccion__c>)tp.newList, (Map<Id, SAC_Interaccion__c>)tp.newMap);
	}

    private void process(List<SAC_Interaccion__c> listNewObj, Map<Id, SAC_Interaccion__c> mapNewObj) {
        //Obtener record Type
        Id recTypeEscaladoNv2 =Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Escalado').getRecordTypeId();
        Id recTypeEscaladoNv3 =Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_EscaladoNV3').getRecordTypeId();
        Id recTypeConsulta =Schema.SObjectType.SAC_Interaccion__c.getRecordTypeInfosByDeveloperName().get('SAC_Consulta').getRecordTypeId();
        Id recTypeReclamacion =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension =Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

        //Listas
        List<SAC_Interaccion__c> listaEscalados = new List<SAC_Interaccion__c>();
        //List<Case> listaCasosSelect = new List<Case>();
        //List<Id> listaIdsRecConsultas = new List<Id>();
        List<SAC_Interaccion__c> listaConsultas = new List<SAC_Interaccion__c>();

        //Recorrer la lista del trigger new y asignar las interacciones que tengan el record type deseado a la lista con la que queremos trabajar.
        for (SAC_Interaccion__c interaccion : listNewObj) {
            if (interaccion.recordTypeId == recTypeEscaladoNv2 || interaccion.recordTypeId == recTypeEscaladoNv3) {
                listaEscalados.add(interaccion);
            }
            if (interaccion.recordTypeId == recTypeConsulta) {
                //listaIdsRecConsultas.add(interaccion.SAC_Reclamacion__c);
                listaConsultas.add(interaccion);
            }
        }

        /*
        US458927 eliminar notificaciones de creación de una consulta
        if (!listaIdsRecConsultas.isEmpty()) {
            //Select para traer las reclamaciones y las pretensiones de las consultas que se han creado
            listaCasosSelect = [SELECT Id, CaseNumber, OwnerId, RecordTypeId, SAC_Reclamacion__c FROM Case WHERE (RecordTypeId = :recTypeReclamacion OR RecordTypeId = :recTypePretension)
                            AND (Id IN :listaIdsRecConsultas
                            OR SAC_Reclamacion__c IN :listaIdsRecConsultas)];

            //Métodos a lanzar para consultas
            SAC_Notificacion.notificarConsulta(listaCasosSelect, listaConsultas);
        }
        */
    
        //Si la lista listaEscalados no está vacía, trabajamos con nuestros metodos
        if (!listaEscalados.isEmpty()) {
            SAC_Interaccion.crearTaskNuevoEscalado(listaEscalados);
            SAC_Interaccion.insertarTME(listaEscalados);
        }
    }
}