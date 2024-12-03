/**
 * @description       : 
 * @group             : 
 * @last modified on  : 03-10-2022
 * @last modified by  : SF
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.1   03-10-2022   Segmentos                            Vision update
**/
public with sharing class SEG_FileController {
    @AuraEnabled(cacheable=true)
    public static FilesWrapper[] getFilesList(Id recordId) {
        FilesWrapper[] filesList = new List<FilesWrapper>{};
        Set<Id> idscontentDocs = new set<Id>();
        Boolean anadirAdjunto = true;
        List<EmailMessage> mensajesRelacionados = [SELECT id, ParentId FROM EmailMessage WHERE ParentId =: recordId];
        for (ContentDocumentLink link : [
            SELECT
            ContentDocumentId,
            ContentDocument.LatestPublishedVersion.Title,
            ContentDocument.LatestPublishedVersion.CreatedDate,
            ContentDocument.LatestPublishedVersion.CreatedBy.Name,
            ContentDocument.Description,
            ContentDocument.LatestPublishedVersion.SEG_Firmado__c,
            ContentDocument.LatestPublishedVersion.SEG_GDD__c,
            ContentDocument.LatestPublishedVersion.ContentSize
            FROM ContentDocumentLink
            WHERE (LinkedEntityId = :recordId OR LinkedEntityId IN: mensajesRelacionados)
            AND ContentDocument.FileType != 'SNOTE'
            ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate DESC
        ]) {
            anadirAdjunto = true; 
            FilesWrapper archivo = new FilesWrapper(
            link.ContentDocumentId,
            link.ContentDocument.LatestPublishedVersion.Title,
            link.ContentDocument.LatestPublishedVersion.CreatedBy.Name,
            link.ContentDocument.LatestPublishedVersion.CreatedDate,
            link.ContentDocument.Description,
            link.ContentDocument.LatestPublishedVersion.SEG_Firmado__c,
            link.ContentDocument.LatestPublishedVersionId,
            link.ContentDocument.LatestPublishedVersion.SEG_GDD__c,
            String.valueOf(link.ContentDocument.LatestPublishedVersion.ContentSize));
            
            if(!filesList.isEmpty()){
                for (FilesWrapper archivoAnadido : filesList) {
                    if (archivoAnadido.Id == archivo.Id) {
                        anadirAdjunto = false;
                    }
                }
            }

            if(anadirAdjunto){
                filesList.add(archivo);
            }
        }

        for (FilesWrapper file : filesList){
            String size = file.contentSize;
            if (integer.valueof(size) < 1024){
                file.contentSize = size + ' Bytes';
            }   
            else if (integer.valueof(size) >= 1024 && integer.valueof(size) < (1024*1024)){
                //KB
                Decimal kb = Decimal.valueOf(size);
                kb = kb.divide(1024,2);
                file.contentSize =  string.valueOf(kb) + ' KB';
            }
            else if (integer.valueof(size) >= (1024*1024) && integer.valueof(size) < (1024*1024*1024)){
                //MB
                Decimal mb = Decimal.valueOf(size);
                mb = mb.divide((1024*1024),2);
                file.contentSize = string.valueOf(mb) + ' MB';
            }
            else{
                //GB
                Decimal gb = Decimal.valueOf(size);
                gb = gb.divide((1024*1024*1024),2);
            
                file.contentSize = string.valueOf(gb) + ' GB';
            }
        }
        return filesList;
    } 
    
    @AuraEnabled
    public static FileVersionWrapper[] getFileVersionDetails(Id fileId) {
        FileVersionWrapper[] contentversions = new List<FileVersionWrapper>{};
        for (ContentVersion cv : [SELECT id,title,contenturl,createddate, createdby.name, ReasonForChange,Description,SEG_Firmado__c, SEG_GDD__c, contentSize  FROM ContentVersion WHERE ContentDocumentId = :fileId]) {
            contentVersions.add(new FileVersionWrapper(cv.id, cv.title, cv.createdby.name, cv.createddate,cv.Description,cv.SEG_Firmado__c,cv.SEG_GDD__c,cv.ReasonForChange,cv.contenturl, String.valueOf(cv.contentSize)));
        }
        return contentVersions;
    } 
    
     public virtual class File{
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String createdBy { get; set; }
        @AuraEnabled
        public Datetime createdDate { get; set; }
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public Boolean firmado { get; set; }
        @AuraEnabled
        public String gdd { get; set; }
        @AuraEnabled
        public String contentSize { get; set; }

        public File(String id, String title, String createdBy, Datetime createdDate, String description, Boolean firmado, String gdd, String contentSize) {
            this.id = id;
            this.title = title;
            this.createdBy = createdBy;
            this.createdDate = createdDate;
            this.description = description;
            this.firmado = firmado;
            this.gdd = gdd;
            this.contentSize = contentSize;
        }
    }
    
    public class FilesWrapper extends File{
        @AuraEnabled
        public String latestVersionId { get; set; }
        
        public FilesWrapper(String id, String title, String createdBy, Datetime createdDate,String description, Boolean firmado, String latestVersionId, String gdd, String contentSize) {
           	super(id, title, createdBy, createdDate,description,firmado, gdd, contentSize);
            this.latestVersionId = latestVersionId;
        }
    }
    
    public class FileVersionWrapper extends File{
       	@AuraEnabled
        public String reasonForChange { get; set; }
        @AuraEnabled
        public String contentUrl { get; set; }
        public FileVersionWrapper(String id, String title, String createdBy, Datetime createdDate,String description,Boolean firmado, String gdd, String reasonForChange,string contentUrl, String contentSize) {
           	super(id, title, createdBy, createdDate,description,firmado, gdd, contentSize);
            this.reasonForChange = reasonForChange;
            this.contentUrl=contentUrl;
        }
    } 
    
    @AuraEnabled
    public static Id createContentDocLink(Id contentVersionId, Id recordId, String description) {
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId].ContentDocumentId;
        insert new ContentDocumentLink(ContentDocumentId = docId, LinkedEntityId = recordId, ShareType = 'V',Visibility = 'AllUsers');
        return docId;
    }

    //actualizar fichero
    @AuraEnabled
    public static Id updateContentDocLink(Id contentVersionId, Id recordId, String description, Boolean firmado, String gdd) {
        Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId].ContentDocumentId;
        insert new ContentDocumentLink(ContentDocumentId = docId, LinkedEntityId = recordId);
        return docId;
    }

    @AuraEnabled
    public static void uploadFileModify(Id versionArchivo, String titulo, String descripcion, Boolean firma, String gdd){
        List<ContentDocumentLink> cdLink = new List<ContentDocumentLink>();

        ContentVersion file = [SELECT Checksum,ContentDocumentId,ContentLocation,
        ContentSize,ContentUrl,Description,FileExtension,FileType,FirstPublishLocationId,Id,
        IsAssetEnabled,IsDeleted,Origin,OwnerId,PathOnClient,PublishStatus,RatingCount,ReasonForChange, 
        SharingOption,Title,VersionData,VersionNumber FROM ContentVersion WHERE ContentDocumentId =: versionArchivo LIMIT 1];
        List<ContentDocumentLink> contenDocLink1 = [SELECT Id, ContentDocument.LatestPublishedVersion.IsLatest,ContentDocument.LatestPublishedVersionId , ContentDocument.LatestPublishedVersion.CreatedDate, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: file.ContentDocumentId];
        //delete contenDocLink1;
        for( ContentDocumentLink doc : contenDocLink1){
            if (String.valueOf(doc.LinkedEntityId.getSObjectType()) != 'User'){
                cdLink.add(doc);
            }
        }

        ContentVersion  documentoNuevo = new ContentVersion();
        documentoNuevo.PathOnClient  = file.PathOnClient;
        documentoNuevo.VersionData = file.VersionData;
        documentoNuevo.FirstPublishLocationId  = file.FirstPublishLocationId;
        documentoNuevo.SEG_GDD__c  = (gdd != null ? gdd : '');
        documentoNuevo.SEG_Firmado__c = (firma != null ? firma : false);
        documentoNuevo.Description = (descripcion != null ? descripcion : '');
        documentoNuevo.Title = (titulo != null ? titulo : '') ;
        insert documentoNuevo;

        delete cdLink;

        List<ContentVersion> file2 = [SELECT Checksum,ContentDocumentId,ContentLocation, 
        ContentSize,ContentUrl,Description,FileExtension,FileType,FirstPublishLocationId,Id,
        IsAssetEnabled,IsDeleted,Origin,OwnerId,PathOnClient,PublishStatus,RatingCount,ReasonForChange, 
        SharingOption,Title,VersionData,VersionNumber FROM ContentVersion WHERE ID =: documentoNuevo.id];
        List<ContentDocumentLink> contenDocLink = [SELECT Id, ContentDocument.LatestPublishedVersion.CreatedDate, LinkedEntityId,
        ContentDocument.LatestPublishedVersion.VersionNumber, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.IsLatest 
                FROM ContentDocumentLink WHERE ContentDocumentId =: file2[0].ContentDocumentId
                                                    ORDER BY ContentDocument.LatestPublishedVersion.CreatedDate DESC ];
    }


    @AuraEnabled
    public static void deleteUploadedFile(Id versionArchivo){
        List<ContentDocumentLink> cdLink = new List<ContentDocumentLink>();
        ContentVersion file = [SELECT Checksum,ContentDocumentId,ContentLocation,
        ContentSize,ContentUrl,Description,FileExtension,FileType,FirstPublishLocationId,Id,
        IsAssetEnabled,IsDeleted,Origin,OwnerId,PathOnClient,PublishStatus,RatingCount,ReasonForChange, 
        SharingOption,Title,VersionData,VersionNumber FROM ContentVersion WHERE ContentDocumentId =: versionArchivo LIMIT 1];
        List<ContentDocumentLink> contenDocLink1 = [SELECT Id, ContentDocument.LatestPublishedVersion.IsLatest,ContentDocument.LatestPublishedVersionId , ContentDocument.LatestPublishedVersion.CreatedDate, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: file.ContentDocumentId];
        for( ContentDocumentLink doc : contenDocLink1){
            if (String.valueOf(doc.LinkedEntityId.getSObjectType()) != 'User'){
                cdLink.add(doc);
            }
        }
        delete cdLink;
    }

    @AuraEnabled
    public static void deleteFiles(List<Id> versionArchivo){
        List<ContentDocumentLink> cdLink = new List<ContentDocumentLink>();
        List<ContentVersion> file = [SELECT Checksum,ContentDocumentId,ContentLocation,
        ContentSize,ContentUrl,Description,FileExtension,FileType,FirstPublishLocationId,Id,
        IsAssetEnabled,IsDeleted,Origin,OwnerId,PathOnClient,PublishStatus,RatingCount,ReasonForChange, 
        SharingOption,Title,VersionData,VersionNumber FROM ContentVersion WHERE ContentDocumentId IN: versionArchivo];
        List<Id> contentDocuments = new List<Id>();
        for (ContentVersion archivo : file) {
            contentDocuments.add(archivo.ContentDocumentId);
        }
        List<ContentDocumentLink> contenDocLink1 = [SELECT Id, ContentDocument.LatestPublishedVersion.IsLatest,ContentDocument.LatestPublishedVersionId , ContentDocument.LatestPublishedVersion.CreatedDate, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN: contentDocuments];
        for( ContentDocumentLink doc : contenDocLink1){
            if (String.valueOf(doc.LinkedEntityId.getSObjectType()) != 'User'){
                cdLink.add(doc);
            }
        }
        CBK_DMLUtility.deleteRecords(cdLink);
    }

    public static Boolean listContains(Object[] source, Object target) {
        return (new Set<Object>(source)).contains(target);
    }
}