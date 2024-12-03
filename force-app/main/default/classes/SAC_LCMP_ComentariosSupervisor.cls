/*****************************************************************
 * Name: SAC_LCMP_ComentariosSupervisor
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Controller del componente SAC_ComentariosDeElevacionSupervisor
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US453685      Marcela Neira   20/09/22      Creación
*****************************************************************/

public with sharing class SAC_LCMP_ComentariosSupervisor {

    public class MyException extends Exception {}

    @AuraEnabled
    public static String cargarComentarios(Id caseId){
        try {

            Case caso = [SELECT id, SAC_ObservacionesSupervisor__c, OwnerId, SAC_UserElevoASupervisor__c, SEG_Grupo__c  FROM Case WHERE Id =: caseId];

            String userId = UserInfo.getUserId();

            if(esPropietario(caso.OwnerId, userId) || 
               esQuienElevo(caso.SAC_UserElevoASupervisor__c, userId) || 
               esCopsAJ(userId) || 
               esSupervisorDelGrupo(caso.SEG_Grupo__c, userId)){
                return caso.SAC_ObservacionesSupervisor__c;
            }else{
                throw new MyException('No tienes permisos para ver los comentarios');
            }            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static Boolean esPropietario(Id ownerCaso, Id usuarioActual) {
        return ownerCaso == usuarioActual;
    }

    public static Boolean esCopsAJ(Id userId) {
        User usuarioActual = [SELECT Id, SAC_PerteneceCOPSAJ__c  FROM User WHERE Id =: userId];
        return usuarioActual.SAC_PerteneceCOPSAJ__c;
    }

    public static Boolean esQuienElevo(Id userElevador, Id usuarioActual) {
        return userElevador == usuarioActual;
    }

    /*****************************************************************
     * Proposito: Retorna true si encuentra que el usuario actual es supervisor o
     *              administrador del grupo del caso que se esta tratando
     * 
     * Historial
     * -------
     * VERSION        USER_STORY       AUTHOR         DATE         Description
     * 1.0            US453685      Marcela Neira   20/09/22      Creación
    *****************************************************************/

    public static Boolean esSupervisorDelGrupo(Id grupoDelCaso, Id usuarioActual) {
        Boolean respuesta = false;
        List<CC_Grupo_Colaborador_Contact__c> gcc= [SELECT id, SAC_Supervisor__c, SAC_Administrador__c 
                                              FROM CC_Grupo_Colaborador_Contact__c 
                                              WHERE CC_Grupo_Colaborador__c =:grupoDelCaso and CC_Usuario__c =:usuarioActual];

        if(!gcc.isEmpty()){
            for (CC_Grupo_Colaborador_Contact__c gccAux : gcc) {
                respuesta = (gccAux.SAC_Supervisor__c || gccAux.SAC_Administrador__c);
            }
        }

        return respuesta;
    }    
}