/*****************************************************************
 * Name: SAC_LCMP_DesmarcarNotificacion
 * Copyright © 2021  CaixaBank
 * ============================================================
 * Proposito: Desmarcar el check de Notificación sin leer del caso
 *            Cuando el usuario que entre en el caso sea el propietario
 *            y el check este marcado anteriormente
 * ============================================================
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR           DATE         Description
 * 1.0            US219258         Marcela Neira   15/06/21      Creación Clase
*****************************************************************/
public without sharing class SAC_LCMP_DesmarcarNotificacion {
    public class ApplicationException extends Exception {}
    @AuraEnabled
    public static Boolean desmarcarNotificacion(String idUsuario, String idCasoDisparador){   
        Boolean seDesmarco = true;

        try{
            Case caso = [SELECT id, OwnerId,  SAC_NotificacionSinLeer__c 
                        FROM case 
                        WHERE id=:idCasoDisparador and OwnerId=:idUsuario and SAC_NotificacionSinLeer__c = true];
            caso.SAC_NotificacionSinLeer__c =false;
            update caso; 
        }catch(Exception e){
            seDesmarco = false;
        }          
        
        return seDesmarco;
    }
}