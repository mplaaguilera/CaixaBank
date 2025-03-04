/*****************************************************************
 * Name: SAC_LCMP_EnvioReclamante
 * Copyright © 2019  CaixaBank
 * 
 * Proposito: Controlador del LWC sac_EnvioReclamante, que se encarga de comprobar si hay acciones
 * asociadas al caso y cerrar la reclamación y sus pretensiones.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US204755         Carlos Solis   31/05/21      Creación
*****************************************************************/
public with sharing class SAC_LCMP_EnvioReclamante {
    /*****************************************************************
     * Proposito: Comprueba si existen acciones asociadas a la reclamación
     * y devuelve la lista de acciones para ser tratada en el .js
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204755         Carlos Solis   31/05/21      Creación
     * 1.1            US204745         Marcela Neira  20/07/21      Modficación: Creación de TME de las tareas
    *****************************************************************/
    @auraEnabled
    public static List<SAC_Accion__c> envioReclamante(Id caseId) {
        Id recTypeMaestroTareas = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_MaestroDeTareas').getRecordTypeId();
        Id recTypeOtrasTareas = Schema.SObjectType.SAC_Accion__c.getRecordTypeInfosByDeveloperName().get('SAC_OtrasTareas').getRecordTypeId();
        Id recTypeTMETarea = Schema.SObjectType.SAC_TMECaso__c.getRecordTypeInfosByDeveloperName().get('SAC_TMETarea').getRecordTypeId();
        List<SAC_Accion__c> listaTareas = new List<SAC_Accion__c>();
        List<SAC_TMECaso__c> tmesTareas = new List<SAC_TMECaso__c>();
        
        if (Schema.sObjectType.SAC_Accion__c.isAccessible()) {
            listaTareas = [select id, SAC_Reclamacion__c from SAC_Accion__c
                        where SAC_Reclamacion__c = :caseId
                        and (RecordTypeId = :recTypeMaestroTareas or RecordTypeId = :recTypeOtrasTareas)];
        }

        if(!listaTareas.isEmpty()){
            tmesTareas=[SELECT id, SAC_Accion__c, name FROM SAC_TMECaso__c WHERE SAC_Accion__c IN: listaTareas AND RecordTypeId =:recTypeTMETarea AND name = 'Resolución de la tarea'];

            if(tmesTareas.isEmpty()){
                for(SAC_Accion__c tarea : listaTareas){
                    SAC_TMECaso__c tme = new SAC_TMECaso__c();
                    tme.name = 'Resolución de la tarea'; // TME de resolución: se inicia cuando se hace el envío al reclamante
                    tme.RecordTypeId = recTypeTMETarea;
                    tme.SAC_Accion__c= tarea.id;
                    tmesTareas.add(tme);
    
                    //tarea.SAC_FechaVencimiento__c = Date.today();
                } 
                update listaTareas;
                upsert tmesTareas;
            }
            
        }

        return listaTareas;
    }

    /*****************************************************************
     * Proposito: Cambia el estatus de la reclamación y sus pretensiones asociadas a 'cerrado'
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204755         Carlos Solis   31/05/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static void cerrarCasos(Id caseId) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        List<Case> listaCasosaCerrar = new List<Case>();
        List<Case> listaPretensiones = new List<Case>();

        if (Schema.sObjectType.Case.isAccessible()) {
            listaCasosaCerrar = [select id, Status from Case where id = :caseId and recordTypeId = :recTypeReclamacion];
            listaPretensiones = [select id, Status from Case where SAC_Reclamacion__c = :caseId and recordTypeId = :recTypePretension];
        }

        for (Case caso : listaPretensiones) {
            listaCasosaCerrar.add(caso);
        }

        for (Case caso : listaCasosaCerrar) {
            caso.Status = 'Cerrado';
            caso.SAC_StatusAuxiliar__c = 'Cerrado';
        }

        if (Schema.sObjectType.Case.isUpdateable()) {
            try {
                update listaCasosaCerrar;
            } catch (Exception e) {
                String errorMsg = e.getMessage();
                throw new AuraHandledException(ErrorMsg);
            }
        }
    }

    /*****************************************************************
     * Proposito: Cambia el estatus de la reclamación a ejecución y sus pretensiones asociadas a 'cerrado'
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US204755         Carlos Solis   1/06/21      Creación
    *****************************************************************/
    @AuraEnabled
    public static void reclamacionEjecucion(Id caseId) {
        Id recTypeReclamacion = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Id recTypePretension = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();
        List<Case> listaReclamacion = new List<Case>();
        List<Case> listaPretensiones = new List<Case>();

        if (Schema.sObjectType.Case.isAccessible()) {
            listaReclamacion = [select id, Status from Case where id = :caseId and recordTypeId = :recTypeReclamacion];
            listaPretensiones = [select id, Status from Case where SAC_Reclamacion__c = :caseId and recordTypeId = :recTypePretension];
        }

        //Paso la reclamación a ejecución
        for (Case caso : listaReclamacion) {
            caso.Status = 'SAC_004';
            caso.SAC_StatusAuxiliar__c = 'SAC_004';
        }
        // Paso las pretensiones a cerrado
        for (Case caso : listaPretensiones) {
            caso.Status = 'Cerrado';
            caso.SAC_StatusAuxiliar__c = 'Cerrado';
        }

        if (Schema.sObjectType.Case.isUpdateable()) {
            try {
                //Hago los updates de las pretensiones y la reclamación por separado para que el trigger no me pise la reclamación
                update listaPretensiones;
                update listaReclamacion;
            } catch (Exception e) {
                String errorMsg = e.getMessage();
                throw new AuraHandledException(ErrorMsg);
            }
        }
    }
}