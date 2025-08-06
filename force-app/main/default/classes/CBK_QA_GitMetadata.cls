/**
 * @description Procesamiento de ficheros de metadaros de las USer Stories para obtener los developers involucrados
 */
public class CBK_QA_GitMetadata implements Database.Batchable<sObject>, Database.Stateful {


    /**
    * @description QueryLocator
    * @param bc 
    * @return Database.getQueryLocator(query)
    */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'select id from copado__User_Story__c';
        return Database.getQueryLocator(query);
    }

    /**
    * @description QueryLocator
    * @param bc
    * @param scope
    */
    public void execute(Database.BatchableContext bc, List<copado__User_Story__c> scope) {
        List<Id> lstId = New List<Id>(); 
        for(copado__User_Story__c item : scope)
        {        
               lstId.add(item.id);
        }
        procesar(lstId);

        
    }   

    /**
    * @description finish
    * @param bc
    */
    public void finish(Database.BatchableContext bc) {
    } 

    /**
     * @description Procesamiento unitario
     * @param userStoryId 
     */
    public static void procesar(list<Id> userStoryId) {
        list<CBK_UserStory_Meta__c> items = [Select Id from CBK_UserStory_Meta__c where User_Story__c  in :userStoryId];
        delete items;

        list<CBK_UserStory_Meta__c> newitems = New list<CBK_UserStory_Meta__c>();
        
        list<Attachment> lstGitAtt = [Select Id,Name,Body,ParentId from Attachment where ParentId  in :userStoryId and Name='Git MetaData'];
        
        for (Attachment gitAtt:lstGitAtt){
            String s = EncodingUtil.base64Decode(EncodingUtil.base64Encode(gitAtt.Body)).toString();
        
            List<Object> lstJsonParse = (List<Object>)Json.deserializeUntyped(s);
            for(Object obj : lstJsonParse)
            {
                Map<String,Object> mpStrObj = (Map<string,Object>)obj;
                CBK_UserStory_Meta__c meta =New CBK_UserStory_Meta__c();
                meta.User_Story__c	  = gitAtt.ParentId;
                meta.tipo__c          = (string)mpStrObj.get('t');
                meta.Objeto__c        = (string)mpStrObj.get('n');
                meta.Desarrollador__c = (string)mpStrObj.get('b');
                if ((string)mpStrObj.get('d')!=null) {
                    meta.Fecha__c         = Date.valueOf((string)mpStrObj.get('d'));
                }
                newitems.add(meta);
            }
        }
        insert newitems;
    }
}