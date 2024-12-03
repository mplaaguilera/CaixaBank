/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-29-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-29-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class SEG_Contratos_Operativas_Controller {
    @AuraEnabled
    static public String recuperarUser(){
            
    return UserInfo.getUserId();  
    }

    //JAV Método para recuperar los emails del caso, para después elegir uno y crear un caso a partir de este

    @AuraEnabled
    public static Map<id,String> fetchEmailsCaso(String caseId){
        
        List<EmailMessage> listEmail = new List<EmailMessage>([SELECT Id, FromName, Subject, HtmlBody,TextBody,Incoming,HasAttachment,SEG_HasAnexo__c,MessageDate FROM EmailMessage WHERE ParentId = :caseId and Incoming = true ORDER BY MessageDate DESC]);
        Map<Id,String> mapEmail = new Map<Id,String>();
        for(EmailMessage emailCas:listEmail)
        {
            mapEmail.put(emailCas.Id,emailCas.Subject +' | '+ emailCas.MessageDate);
        }
        return mapEmail;
    }

    @AuraEnabled
    public static Map<id,String> fetchContratoCaso(String contratoId){
        Set<String> casesCont = new Set<String>();

        for(SEG_Contratos__c contrSeg : [SELECT Id, Name, SEG_SR_Seguimiento__r.CaseNumber, SEG_SROriginal__c from SEG_Contratos__c WHERE Id =: contratoId]){
            casesCont.add(contrSeg.SEG_SR_Seguimiento__r.CaseNumber);
            casesCont.add(contrSeg.SEG_SROriginal__c);
        }
        
        List<Case> listcase = new List<Case>([SELECT id, Origin, Subject, CaseNumber,Description,AccountId, ContactId, SEG_N_case_y_subject__c,
        SEG_Organizacion__c, SEG_Zona__c,OwnerId,Status, SEG_Subestado__c, SEG_Grupo__c,ContactEmail from Case where CaseNumber in :casesCont]);
        Map<Id,String> mapCases = new Map<Id,String>();
        for(Case caseSR:listcase)
        {
            if(listcase.size()>0){
                mapCases.put(caseSR.Id,caseSR.SEG_N_case_y_subject__c);
            }
            else{
                mapCases.put(caseSR.Id,'No existen SRs relacionadas con este contrato');
            }
            
        }
        return mapCases;
    }

    @AuraEnabled
    static public SEG_Contratos__c recuperarContrato(Id contratoId){
        
        SEG_Contratos__c contratoSeg = [SELECT Id, Name, SEG_SR_Seguimiento__r.CaseNumber, SEG_SROriginal__c from SEG_Contratos__c WHERE Id =: contratoId];
        return contratoSeg; 
    }

@AuraEnabled
    public static List<ContentVersion> getFilesCase(Id casoId)
    {      
        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>([SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in ( SELECT Id FROM Case where id=: casoId) and LinkedEntity.Type='Case']);
        Set<Id> contentDocLinkIds = new Set<Id>();
        for (ContentDocumentLink contentLink:contentDocLinkList)
        {
            contentDocLinkIds.add(contentLink.ContentDocumentId);
        }
        List<ContentVersion> listFiles = new List<ContentVersion>();
        listFiles = [select ContentDocumentId,Title,FileExtension from ContentVersion where ContentDocumentId in:contentDocLinkIds and FileExtension<>'snote'];
        return listFiles;
    }

    
//JAV Método para importar emails y anexos de otra SR

@AuraEnabled
    public static List<String> importarAnexosSR(Id contratoID, String listFiles){
        List<String> contratoUpdat = new List<String>();
        System.debug('listFiles:'+listFiles);
        String resultado='OK';
        String statusOld;
        String substatusOld;
        List<Id> wrapperSet = new List<Id>();
        if(listFiles!='["0"]')
        {
            Type idTypeListId = Type.forName('List<Id>');
            wrapperSet = (List<Id>) JSON.deserialize(listFiles, idTypeListId);
            System.debug(wrapperSet);
        }
        
        //realizamos query sobre el caso Original
        SEG_Contratos__c contratoSeg = new SEG_Contratos__c();
        contratoSeg = [SELECT Id, Name, SEG_SR_Seguimiento__r.CaseNumber, SEG_SROriginal__c from SEG_Contratos__c WHERE Id =: contratoId];


        /*List<ContentDocumentLink> listDocumentosInsert = new List<ContentDocumentLink>();
        for(Id idContentDocumentId:wrapperSet)
        {
            ContentDocumentLink objCntDocLink = new ContentDocumentLink();
            objCntDocLink.LinkedEntityId = contratoSeg.id; 
            objCntDocLink.ContentDocumentId = idContentDocumentId;
            objCntDocLink.shareType = 'V';
            listDocumentosInsert.add(objCntDocLink);
        }
        
        if(listDocumentosInsert.size()>0)
        {
            insert(listDocumentosInsert);
        }*/

        //Insertar registros ContentDocumentLink asociados al caso
        List<ContentDocumentLink> listaContentDocumentLink = new List<ContentDocumentLink>();
        list<ContentVersion> listaContentVersionWrapper = new List<ContentVersion>([
          SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId,PathOnClient, FileExtension
          FROM ContentVersion
          WHERE isLatest = true AND ContentDocumentId IN :wrapperSet]);

        //Insertar registros Content Version
        List<ContentVersion> listaContentVersion = new List<ContentVersion>();
        for (ContentVersion textAttachment : listaContentVersionWrapper) {
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.PathOnClient = textAttachment.PathOnClient;
            cv.Origin = 'C';
            cv.Title = textAttachment.Title;
            cv.VersionData = textAttachment.VersionData;
            listaContentVersion.add(cv);
        }
        insert listaContentVersion;
        
        //Recuperar ContentDocumentId de los registros Content Version insertados
        List<Id> listaContentVersionId = new List<Id>();
        for (ContentVersion cv : listaContentVersion) {
            listaContentVersionId.add(cv.Id);
        }
        listaContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :listaContentVersionId];

        for (ContentVersion cv : listaContentVersion) {
            ContentDocumentLink cdLink = new ContentDocumentLink();
            cdLink.LinkedEntityId = contratoSeg.id;
            cdLink.ContentDocumentId = cv.ContentDocumentId;
            cdLink.ShareType = 'V';
            listaContentDocumentLink.add(cdLink);
        }
        if(listaContentDocumentLink.size()>0){
            insert(listaContentDocumentLink);
        }
             
        
        //Creamos una nota en observaciones
        /*FeedItem feed = new FeedItem();
        feed.ParentId = casoID; 
        feed.Body = 'Anexos copiados de caso a contrato: ' + listDocumentosInsert; 
        insert feed;*/ 

            
        return contratoUpdat;
    }
}