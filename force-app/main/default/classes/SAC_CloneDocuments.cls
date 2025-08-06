/*****************************************************************
 * Name: SAC_CloneDocuments
 * Copyright © 2022  CaixaBank
 * 
 * Proposito: Clonar los documentos
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US478280       Marcela Neira   10/11/22    Creación Clase
*****************************************************************/
public with sharing class SAC_CloneDocuments {   
    @InvocableVariable(
        Label='Source Record Id' 
        Description='Record Id of an object with related Documents'
        Required=false)
    public String sourceRecordId;
    @InvocableVariable(
        Label='Destination Record Id' 
        Description='Record Id of an object that receive copies of the Source record\'s Documents'
        Required=false)
    public String destinationRecordId;

    /**
    * all instantiation of class with no parameters or source/destination record Ids
    */
    //public SAC_CloneDocuments(){}
    public SAC_CloneDocuments(String sourceRecordId, String destinationRecordId){
        this.sourceRecordId = sourceRecordId;
        this.destinationRecordId = destinationRecordId;
    }
    
    /**
    * clone related files from a source record to a destination record
    */
    @InvocableMethod(Label='Clone Documents' Description='Clone Documents related to the Source record onto the Destination record')
    public static void cloneDocuments(list<SAC_CloneDocuments> pfCloneDocumentsList) {
        
        // get set of To IDs by the From Id
        map<Id, set<Id>> fromToMap = formatFromToMap(pfCloneDocumentsList); 
        if (fromToMap.isEmpty()) {
            return;
        }

        map<Id, ContentDocumentLink> cdlMap = new map<Id, ContentDocumentLink>();
        map<Id, list<contentLinkCls>> docIdCdlListMap = new map<Id, list<contentLinkCls>>();

        // create Content Document Link records for each To ID
        set<Id> fromIdSet = fromToMap.keySet();
        system.debug('*** '+fromIdSet);
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId,LinkedEntityId,ShareType,Visibility  
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId IN :fromIdSet]) {
            // by Link Id
            cdlMap.put(cdl.Id, cdl);
			system.debug('*** '+cdlMap);
            // by Document Id
            list<contentLinkCls> cdlList = docIdCdlListMap.get(cdl.ContentDocumentId);
            if (null == cdlList) {
                cdlList = new list<contentLinkCls>();
                docIdCdlListMap.put(cdl.ContentDocumentId, cdlList);
            }
            set<Id> toSet = fromToMap.get(cdl.LinkedEntityId);
            if (null != toSet) {
                for (Id toId : toSet) {
                    ContentDocumentLink newCdl = cdl.clone();
                    newCdl.LinkedEntityId = toId;
                    cdlList.add(new contentLinkCls(newCdl));
                }
            }
        }

        if (docIdCdlListMap.isEmpty()) {
            return;
        }

        // create a new Content Version NOT linked to a Content Document for each Content Document Link for each Destination Id
        set<Id> cvIdSet = getNewContentVersionIdMap(docIdCdlListMap);

        // get new Content Document that was auto-created
        map<Id, Id> cvIdDocIdMap = new map<Id, Id>();
        for (ContentDocument cd : [SELECT Id, LatestPublishedVersionId 
                                   FROM ContentDocument
                                   WHERE LatestPublishedVersionId IN :cvIdSet]) {
            cvIdDocIdMap.put(cd.LatestPublishedVersionId, cd.Id);
        }

        // set ContentDocument Id on the ContentDocumentLink
        list<ContentDocumentLink> cdlInsertList = new list<ContentDocumentLink>();
        for (list<contentLinkCls> cLinkList : docIdCdlListMap.values()) {
            for (contentLinkCls cLink : cLinkList) {
                Id cdId = cvIdDocIdMap.get(cLink.cvId); 
                if (null != cdId) {
                    cLink.cdl.ContentDocumentId = cdId;
                    cdlInsertList.add(cLink.cdl);
                } else {
                    system.debug(LoggingLevel.ERROR, 'Not Found ' + cLink);
                }
            }            
        }
        System.debug('CGR Lista de documentos clonados: ' + cdlInsertList);

        if (!cdlInsertList.isEmpty()) {
            system.debug('*** ' + cdlInsertList[0].ContentDocumentId);
            system.debug('*** ' + cdlInsertList[0].LinkedEntityId);
            insert cdlInsertList;
        }
    }

    /**
    * create a new Content Version NOT linked to a Content Document for each Content Document Link
    */
    private static set<Id> getNewContentVersionIdMap(map<Id, list<contentLinkCls>> docIdCdlListMap) {
        set<Id> cvIdSet = new set<Id>();
        list<ContentVersion> cvInsertList = new list<ContentVersion>();

        for (ContentVersion cv : [SELECT ContentDocumentId, ContentLocation, Description, pathOnClient, TagCsv, Title, VersionData, SAC_Bloque__c
                                    FROM ContentVersion
                                    WHERE ContentDocumentId IN :docIdCdlListMap.keySet()
                                            AND ContentLocation = 'S']) { // S=Document is located within Salesforce
            
            list<contentLinkCls> cdlList = docIdCdlListMap.get(cv.ContentDocumentId);
            if (null != cdlList) {
                for (contentLinkCls cdl : cdlList) {
                    ContentVersion newCv = new ContentVersion(
                                                              Description=cv.Description, 
                                                              TagCsv=cv.TagCsv, 
                                                              pathOnClient=cv.pathOnClient,
                                                              Title=cv.Title, 
                                                              VersionData=cv.VersionData,
                                                              SAC_Bloque__c=cv.SAC_Bloque__c);
                    cdl.cv = newCv;

                    cvInsertList.add(newCv);
                }
            }
        }
        if (!cvInsertList.isEmpty()) {
            insert cvInsertList;

            for (list<ContentLinkCls> clList : docIdCdlListMap.values()) {
                for (ContentLinkCls cl : clList) {
                    cl.clearCv();
                    cvIdSet.add(cl.cvId);
                }
            }
        }
        return cvIdSet;
    }

    /**
    * return a map of the from and to record ids
    */
    private static map<Id, set<Id>> formatFromToMap(list<SAC_CloneDocuments> pfCloneDocumentsList) {
        map<Id, set<Id>> fromToMap = new map<Id, set<Id>>();
        for (SAC_CloneDocuments cd : pfCloneDocumentsList) {
            // skip if blank 
            if (String.isBlank(cd.sourceRecordId) || String.isBlank(cd.destinationRecordId)) continue;
            
            // convert to Id types, and skip if either is invalid
            Id fromId;
            Id toId;
            try {
                fromId = cd.sourceRecordId;
                toId = cd.destinationRecordId;
            } catch (exception e) {
                system.debug(LoggingLevel.ERROR, 'Id exception: ' + e.getMessage());
                continue;
            }

            // put in cross-reference map
            set<Id> toSet = fromToMap.get(fromId);
            if (null == toSet) {
                toSet = new set<Id>();
                fromToMap.put(fromId, toSet);
            }
            toSet.add(toId);
        }
        return fromToMap;
    }

    /**
    * subclass to help associate the contentdocumentlink to the contentversion
    */
    private class contentLinkCls {
        ContentDocumentLink cdl {get; set;}
        ContentVersion cv {get; set;}
        Id cvId {get; set;}
        public contentLinkCls(ContentDocumentLink cdl) {
            this.cdl = cdl;
        }

        public void clearCv() {
            cvId = cv.Id;
            cv = null;
        }
    }
}