/*****************************************************************
 * Name: SAC_LCMP_ReenvioCartaPostal
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Hacer el reenvio de la redacción de la reclamacion de tipo 
 *            Carta Postal
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US330921     Marcela Neira     14/02/22      Creación
*****************************************************************/
public without sharing class SAC_LCMP_ReenvioCartaPostal {

    @AuraEnabled
    public static void reenvioRedaccionCartaPostal(String idCaso){
        try {    
            SAC_DocumentoEnvio__c documentoEnvio = [SELECT Id, SAC_version__c, SAC_Documento__c, SAC_TipoDocumento__c, CreatedDate , SAC_Direccion__c, 
                                                     SAC_Provincia__c, SAC_caso__c
                                                     FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :idCaso AND SAC_TipoDocumento__c = 'redacción' 
                                                     Order By CreatedDate desc  LIMIT 1];

            SAC_DocumentoEnvio__c documentoReenvio = documentoEnvio.clone(false, false, false, false);
            documentoReenvio.SAC_TipoDocumento__c = 'reenvioRedaccion';

            insert documentoReenvio;
            
            FeedItem post = new FeedItem(ParentId = idCaso, Body = 'Reenvío de la redacción final carta postal',Title = 'Fin Redacción');
            insert post;          
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}