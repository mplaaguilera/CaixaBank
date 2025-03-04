/*****************************************************************
 * Name: SAC_LCMP_ProductosPretensionWOSharing
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Clase controlador del componente sac_ProductosPretension
 * Clase test: SAC_LCMP_ProductosPretensionWOSharing_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            --              Iria ANPC     23/12/24        Creación
*****************************************************************/

public without sharing class SAC_LCMP_ProductosPretensionWOSharing {
    
    @AuraEnabled
    public static void createRecordWithoutSharing(String descripcion, String contrato, String tipo, Date fechaApertura, Date fechaCancelacion, Id pretensionId, Decimal taeInicial, Decimal taeMaximo, String negociar, String disponemosContrato) {
        // Get Pretensión
        Case pretension = [SELECT Id, SAC_Reclamacion__r.CC_Grupo_Colaborador__c, SAC_GrupoLetrado__c, SAC_Reclamacion__r.OwnerId FROM Case WHERE Id =: pretensionId];
        List<CC_Grupo_Colaborador_Contact__c> colaboradores = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: UserInfo.getUserId() AND (CC_Colaborador__c =: pretension.SAC_Reclamacion__r.CC_Grupo_Colaborador__c OR CC_Colaborador__c =: pretension.SAC_GrupoLetrado__c) LIMIT 1];
        if(colaboradores.isEmpty() || UserInfo.getUserId() != pretension.SAC_Reclamacion__r.OwnerId){
            throw new AuraHandledException('No tienes permisos para crear el registro');
        }else{
            SAC_ProductCase__c productCase = new SAC_ProductCase__c(
                SAC_Descripcion__c = descripcion,
                N_Contrato__c = contrato,
                SAC_Tipo__c = tipo,
                SAC_FechaApertura__c = fechaApertura,
                SAC_FechaCancelacion__c = fechaCancelacion,
                SAC_Pretension__c = pretensionId,
                SAC_TaeInicialContrato__c = taeInicial,
                SAC_TaeMaximoAplicado__c = taeMaximo,
                SAC_Negociar__c = negociar,
                SAC_DisponemosDeContrato__c = disponemosContrato
            );
            try {
                insert productCase;
            } catch (Exception e) {
                throw new AuraHandledException('Error al crear el registro: ' + e.getMessage());
            }
        }
    }
    
    @AuraEnabled
    public static void editRecordWithoutSharing(String productId, String descripcion, String contrato, String tipo, Date fechaApertura, Date fechaCancelacion, Id pretensionId, Decimal taeInicial, Decimal taeMaximo, String negociar, String disponemosContrato) {
        // Get Pretensión
        Case pretension = [SELECT Id, SAC_Reclamacion__r.CC_Grupo_Colaborador__c, SAC_GrupoLetrado__c, SAC_Reclamacion__r.OwnerId FROM Case WHERE Id =: pretensionId];
        List<CC_Grupo_Colaborador_Contact__c> colaboradores = [SELECT Id FROM CC_Grupo_Colaborador_Contact__c WHERE CC_Usuario__c =: UserInfo.getUserId() AND (CC_Colaborador__c =: pretension.SAC_Reclamacion__r.CC_Grupo_Colaborador__c OR CC_Colaborador__c =: pretension.SAC_GrupoLetrado__c) LIMIT 1];
        if(colaboradores.isEmpty() || UserInfo.getUserId() != pretension.SAC_Reclamacion__r.OwnerId){
            throw new AuraHandledException('No tienes permisos para editar el registro');
        }else{
            SAC_ProductCase__c productCase = [SELECT Id, SAC_Descripcion__c, N_Contrato__c, SAC_Tipo__c, SAC_FechaApertura__c, SAC_FechaCancelacion__c,
                                              SAC_TaeInicialContrato__c, SAC_TaeMaximoAplicado__c, SAC_Negociar__c, SAC_DisponemosDeContrato__c
                                              FROM SAC_ProductCase__c WHERE Id =: productId LIMIT 1];
            productCase.SAC_Descripcion__c = descripcion;
            productCase.N_Contrato__c = contrato;
            productCase.SAC_Tipo__c = tipo;
            productCase.SAC_FechaApertura__c = fechaApertura;
            productCase.SAC_FechaCancelacion__c = fechaCancelacion;
            productCase.SAC_TaeInicialContrato__c = taeInicial;
            productCase.SAC_TaeMaximoAplicado__c = taeMaximo;
            productCase.SAC_Negociar__c = negociar;
            productCase.SAC_DisponemosDeContrato__c = disponemosContrato;
            
            try {
                update productCase;
            } catch (Exception e) {
                throw new AuraHandledException('Error al actualizar el registro: ' + e.getMessage());
            }
        }
    }
}