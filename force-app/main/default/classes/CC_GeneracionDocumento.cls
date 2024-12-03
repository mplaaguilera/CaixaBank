public with sharing class CC_GeneracionDocumento {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    //private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();


        
    
    @AuraEnabled
    public static SAC_DocumentoEnvio__c compruebaDocumentoRedaccion(String id){
        try{
        SAC_DocumentoEnvio__c docGuardado = [SELECT Id, SAC_Cuerpo__c, SAC_Header__c, SAC_Footer__c
                                                FROM SAC_DocumentoEnvio__c
                                                WHERE SAC_Caso__c = :id
                                                AND SAC_TipoDocumento__c = 'redaccion' ORDER by createdDate desc limit 1];

        return docGuardado;
        
        }catch(Exception e){ 
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void generarDocumentoRedaccion(String id){
        try {
            SAC_DocumentoEnvio__c docEnvio = [SELECT SAC_Caso__c, SAC_Documento__c, SAC_Cuerpo__c, SAC_Version__c, Id
                                                FROM SAC_DocumentoEnvio__c 
                                                WHERE Id =: id and SAC_Documento__c = null  limit 1];

            
        String vfHostname = DomainCreator.getVisualforceHostname(null);
        String urlVF =  vfHostname + '/apex/SAC_DocumentoRedaccionPDF?id=' + docEnvio.Id;
 
        adjuntarPDFaCaso(urlVF, docEnvio.SAC_Caso__c , 'redaccion');

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void adjuntarPDFaCaso(String url, Id parentId, String procedencia){

        String contador = '';
            String numCaso = [SELECT CaseNumber FROM Case WHERE id =: parentId].CaseNumber;
            PageReference pageRef = new PageReference('https://' + url);          
            Blob body;
            if(Test.isRunningTest()){
                body = blob.valueOf('Unit.Test');
            }
            else{              
                body = pageRef.getContentAsPDF();                
            }
    
            List<ContentVersion> cvs = new List<ContentVersion>();
            cvs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: parentId];
            //cvs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: parentId AND SAC_StringRedaccion_fileupload__c =: 'ResolucionRedaccion'];
    
        //SAC_MaestroTemas__c maestro = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'RESOLUCION' LIMIT 1];

            
            Set<Id> idsCD = new Set<Id>(); 
            if(!cvs.isEmpty()){
                for(ContentVersion cv : cvs){
                    idsCD.add(cv.ContentDocumentId);
                }
                List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE Id IN: idsCD];
                CC_DatabaseDML.deleteListDML(cds, false);
            }
            ContentVersion cv = new ContentVersion(
                Title = numCaso + ' Documento Redacción', 
                PathOnClient ='SampleTitle.pdf',
                VersionData = body,
                FirstPublishLocationId = parentId
                //SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion',
                //SAC_TipoAdjunto__c = maestro.Id,
                //SAC_Bloque__c = 'SAC_Respuesta'
            );
            CC_DatabaseDML.insertDML(cv, false);
    
            /*SAC_DocumentoEnvio__c documento = [SELECT id FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:parentId AND SAC_Documento__c = null AND SAC_TipoDocumento__c =:procedencia LIMIT 1];
    
            documento.SAC_Version__c = cv.Id;
            documento.SAC_Documento__c = cv.ContentDocumentId;
            documento.SAC_URL__c = url;
    
            CC_DatabaseDML.updateDML(documento, false);   */
                        
    }
    @AuraEnabled
    public static string getRuta(){
        try {
            String vfHostname = DomainCreator.getVisualforceHostname(null);
            return vfHostname;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}