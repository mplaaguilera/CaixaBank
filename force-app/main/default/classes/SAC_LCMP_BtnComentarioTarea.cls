/***********************************************************************
 * Name: SAC_LCMP_ResponderConsulta
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Clase para operaciones de LWC sAC_ResponderConsulta
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US361683       Marcela Neira  21/06/2022      Creación
*************************************************************************/
public with sharing class SAC_LCMP_BtnComentarioTarea {
    @AuraEnabled
    public static String getComentarios1(Id idTarea) {
        SAC_Accion__C tarea = [SELECT Id, SAC_Comentarios__c FROM SAC_Accion__C WHERE Id =: idTarea];
        return tarea.SAC_Comentarios__c;
    }

    @AuraEnabled
    public static String getComentarios2(Id idTarea) {
        SAC_Accion__C tarea = [SELECT Id, SAC_Comentarios2__c FROM SAC_Accion__C WHERE Id =: idTarea];
        return tarea.SAC_Comentarios2__c;
    }

    @AuraEnabled
    public static void guardarComentario1Apex(Id idTarea, String comentario) {
        SAC_Accion__C  tarea = new SAC_Accion__C(Id = idTarea, SAC_Comentarios__c = comentario);
        update tarea;
    }

    @AuraEnabled
    public static void guardarComentario2Apex(Id idTarea, String comentario) {
        SAC_Accion__C  tarea = new SAC_Accion__C(Id = idTarea, SAC_Comentarios2__c = comentario);
        update tarea;
    }
}