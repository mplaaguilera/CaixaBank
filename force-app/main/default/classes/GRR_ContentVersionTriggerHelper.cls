public with sharing class GRR_ContentVersionTriggerHelper {

    public static List<ContentVersion> filtrarDocumentosGRR(List<ContentVersion> lstDocumentos){
        List<ContentVersion> documentosGRR = new List<ContentVersion>();
        Boolean hasCustomPermission = FeatureManagement.checkPermission('GRR_Archivos_Privados');
        if (hasCustomPermission) {
                for (ContentVersion doc : lstDocumentos){
                    if(!String.isBlank(doc.FirstPublishLocationId)){
                        String sObjectName = doc.FirstPublishLocationId.getSObjectType().getDescribe().getName();
                        
                        if (sObjectName == 'Account'){
                            documentosGRR.add(doc);
                        }
                    }
                }
            }

        return documentosGRR;
    } 

    public static void modificarSharingContentVersion(List<ContentVersion> lstDocumentos){
        for(ContentVersion doc : lstDocumentos){
            doc.SharingOption = 'R'; //Restricted (new shares are prevented without affecting existing shares)
            doc.SharingPrivacy = 'P'; //Private (the file is private on records but can be shared selectively with others)
        }
    }
	
    public static void crearContentDocumentLink(List<ContentVersion> lstDocumentos){
        List<ContentDocumentLink> lstContentDocumentsLink = new List<ContentDocumentLink>();
        List<CollaborationGroup> grupo = new List<CollaborationGroup>();
        
        if (Test.isRunningTest()) {                    
            grupo = [SELECT Id FROM CollaborationGroup WHERE Name = 'GRR Grupo Archivos Test' WITH SECURITY_ENFORCED LIMIT 1];
        } else {
            GRR_Parametros__c params = GRR_Parametros__c.getInstance('GRR_CollaborationGroup');
            String nombreGrupo = params.GRR_Valor__c;
    
            grupo = [SELECT Id FROM CollaborationGroup WHERE Name = :nombreGrupo WITH SECURITY_ENFORCED LIMIT 1];
        }
        

        if(!grupo.isEmpty()){
            for(ContentVersion cont : lstDocumentos){
                ContentDocumentLink contentlink = new ContentDocumentLink();
                contentlink.LinkedEntityId = grupo[0].Id; 
                contentlink.contentdocumentid = cont.ContentDocumentId; 
                contentlink.ShareType = 'C'; // Collaborator
                contentlink.Visibility = 'AllUsers'; // Available to all users who have permission to see the file
                lstContentDocumentsLink.add(contentlink);
            }
        }
        
        if (!lstContentDocumentsLink.isEmpty()){
            insert lstContentDocumentsLink;
        }
    }

}