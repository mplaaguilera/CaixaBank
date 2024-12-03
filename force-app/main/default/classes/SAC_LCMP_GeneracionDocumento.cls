public with sharing class SAC_LCMP_GeneracionDocumento {

    private static Set<String> objetos = new Set<String>{'Case','SAC_Interaccion__c','SAC_TMECaso__c','SAC_MaestroTemas__c','SAC_ImagenDocumento__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();
    private static final Id RECTYPEIMAGENES = mapRTsObjects.get('SAC_ImagenDocumento__c').get('SAC_ImagenDocumento').getRecordTypeId();

    @AuraEnabled
    public static SAC_DocumentoEnvio__c compruebaDocumentoRedaccion(String id){
        try{
        if(!String.isBlank(id)) {
            SAC_DocumentoEnvio__c docGuardado = [SELECT Id, SAC_DocPDF__c, SAC_Header__c, SAC_Footer__c
                                                    FROM SAC_DocumentoEnvio__c
                                                    WHERE SAC_Caso__c = :id
                                                    AND SAC_TipoDocumento__c = 'redaccion' ORDER by createdDate desc limit 1];
            
            return docGuardado;
            
        } else {
            return null;
        }
        
        }catch(Exception e){ 
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void generarDocumentoRedaccion(String id){
        try {
            SAC_DocumentoEnvio__c docEnvio = [SELECT SAC_Caso__c, SAC_Documento__c, SAC_DocPDF__c, SAC_Version__c, Id
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
        Case caso = [SELECT CaseNumber, CC_Idioma__c, recordType.DeveloperName FROM Case WHERE id =: parentId LIMIT 1];
        String numCaso = caso.CaseNumber;
        String nombreDocumento;
        String proyecto;
        if(caso.recordType.DeveloperName == 'SPV_Reclamacion') {
            proyecto = ' SPV';
        } else {
            proyecto = ' SAC';
        }
        if(caso.CC_Idioma__c == 'es') { nombreDocumento = ' carta respuesta' + proyecto; }
        else if(caso.CC_Idioma__c == 'ca') { nombreDocumento = ' carta resposta' + proyecto; }
        else if(caso.CC_Idioma__c == 'en') { nombreDocumento = proyecto + ' response letter'; }
        else if(caso.CC_Idioma__c == 'va') { nombreDocumento = ' carta resposta' + proyecto; }
        else if(caso.CC_Idioma__c == 'ga') { nombreDocumento = ' carta de resposta' + proyecto; }
        else if(caso.CC_Idioma__c == 'eu') { nombreDocumento = proyecto + ' erantzun gutuna'; }
        else { nombreDocumento = ' carta respuesta' + proyecto; }

        PageReference pageRef = new PageReference('https://' + url);          
        Blob body;
        if(Test.isRunningTest()){
            body = blob.valueOf('Unit.Test');
        }
        else{              
            body = pageRef.getContentAsPDF();                
        }

        List<ContentVersion> cvs = new List<ContentVersion>();
        cvs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: parentId AND SAC_StringRedaccion_fileupload__c =: 'ResolucionRedaccion'];
        SAC_MaestroTemas__c maestro = new SAC_MaestroTemas__c();
        if(caso.recordType.DeveloperName == 'SPV_Reclamacion') {
            maestro = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'RESOLUCIONSPV' LIMIT 1];
        } else {
            maestro = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'RESOLUCION' LIMIT 1];
        }
        
        Set<Id> idsCD = new Set<Id>(); 
        if(!cvs.isEmpty()){
            for(ContentVersion cv : cvs){
                idsCD.add(cv.ContentDocumentId);
            }
            List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE Id IN: idsCD];
            SAC_DatabaseDML.deleteListDML(cds, false);
        }
        ContentVersion cv = new ContentVersion(
            Title = numCaso + nombreDocumento, 
            PathOnClient ='SampleTitle.pdf',
            VersionData = body,
            FirstPublishLocationId = parentId,
            SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion',
            SAC_TipoAdjunto__c = maestro.Id,
            SAC_Bloque__c = 'SAC_Respuesta',
            SAC_ValidadoCV__c = true
        );
        SAC_DatabaseDML.insertDML(cv, false);

        SAC_DocumentoEnvio__c documento = [SELECT id FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:parentId AND SAC_Documento__c = null AND SAC_TipoDocumento__c =:procedencia LIMIT 1];

        //Comentado para que al generar el documento no salga en docs
        // documento.SAC_Version__c = cv.Id;
        documento.SAC_Documento__c = cv.ContentDocumentId;
        documento.SAC_URL__c = url;

        SAC_DatabaseDML.updateDML(documento, false);   
                        
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


    @AuraEnabled
    public static string getRutaVS(){
        try {
            String vfHostname = DomainCreator.getVisualforceHostname(null);
            String ruta = 'https://' + vfHostname + '/apex/SAC_EditorHTMLPlantillas?id=';
            return ruta;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public string lexOrigin {get{ return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';} set;}

    public string idCaso {get{ return ApexPages.currentPage().getParameters().get('id').escapeHtml4();} set;}

    public string cuerpoDocumento { get{ if(ApexPages.currentPage().getParameters().get('id') != null) {List<SAC_DocumentoEnvio__c> docGuardado = [SELECT Id, SAC_DocPDF__c FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c =: ApexPages.currentPage().getParameters().get('id') AND SAC_TipoDocumento__c = 'redaccion' ORDER by createdDate desc limit 1];if (docGuardado.size() > 0) {return docGuardado[0].SAC_DocPDF__c;}}return '';} set;}


    @AuraEnabled
    public static string insertarimagen(String id, String imagen){
        try {
            SAC_ImagenDocumento__c imagenNueva = new SAC_ImagenDocumento__c();
            imagenNueva.SAC_Caso__c = id;
            imagenNueva.SAC_Imagen__c = imagen;
            SAC_DatabaseDML.insertDML(imagenNueva,false);

            SAC_ImagenDocumento__c imagenInsertada = [SELECT Id, SAC_Imagen__c FROM SAC_ImagenDocumento__c WHERE RecordTypeId = :RECTYPEIMAGENES AND Id =: imagenNueva.id AND SAC_Caso__c = :id LIMIT 1];
            return imagenInsertada.SAC_Imagen__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*

     * @description: método que genera un Documento Envío específico de Inadmisión de Préstamos
     * @author: iria.alvarez.novoa@ibm.com
     * @date: septiembre 2024
     * @param caseId: id reclamación
     */
    @AuraEnabled
    public static void generarDocumentoInadmision(String caseId){
        try {
            SAC_DocumentoEnvio__c docEnvio = [SELECT SAC_Caso__c, SAC_Documento__c, SAC_DocPDF__c, SAC_Version__c, Id
                                              FROM SAC_DocumentoEnvio__c 
                                              WHERE SAC_Caso__c =: caseId and SAC_Documento__c = null ORDER BY CreatedDate DESC limit 1];

            String vfHostname = DomainCreator.getVisualforceHostname(null);
            String urlVF =  vfHostname + '/apex/SAC_DocumentoRedaccionPDF?id=' + docEnvio.Id;
            adjuntarPDFaCasoFuture(urlVF, caseId , 'inadmision - prestamo');

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * @description: método que genera un documento pdf de Inadmisión de Préstamos
     * @author: iria.alvarez.novoa@ibm.com
     * @date: septiembre 2024
     * @param url: url del doc
     * @param parentId: id reclamación
     * @param procedencia: inadmisión - préstamo
     */
    @AuraEnabled
    @future(callout=true)
    public static void adjuntarPDFaCasoFuture(String url, Id parentId, String procedencia){
        Case caso = [SELECT CaseNumber, CC_Idioma__c FROM Case WHERE id =: parentId LIMIT 1];
        String numCaso = caso.CaseNumber;
        String nombreDocumento;
        if(caso.CC_Idioma__c == 'es') { nombreDocumento = ' carta respuesta SAC'; }
        else if(caso.CC_Idioma__c == 'ca') { nombreDocumento = ' carta resposta SAC'; }
        else if(caso.CC_Idioma__c == 'en') { nombreDocumento = ' SAC response letter'; }
        else if(caso.CC_Idioma__c == 'va') { nombreDocumento = ' carta resposta SAC'; }
        else if(caso.CC_Idioma__c == 'ga') { nombreDocumento = ' carta de resposta SAC'; }
        else if(caso.CC_Idioma__c == 'eu') { nombreDocumento = ' SAC erantzun gutuna'; }
        else { nombreDocumento = ' carta respuesta SAC'; }
        PageReference pageRef = new PageReference('https://' + url);  
        Blob body;
        if(Test.isRunningTest()){
            body = blob.valueOf('Unit.Test');
        }
        else{   
            body = pageRef.getContentAsPDF(); 
        }
        List<ContentVersion> cvs = new List<ContentVersion>();
        cvs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: parentId AND SAC_StringRedaccion_fileupload__c =: 'ResolucionRedaccion'];
        SAC_MaestroTemas__c maestro = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'RESOLUCION' LIMIT 1];
        Set<Id> idsCD = new Set<Id>(); 
        if(!cvs.isEmpty()){
            for(ContentVersion cv : cvs){
                idsCD.add(cv.ContentDocumentId);
            }
            List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE Id IN: idsCD];
            SAC_DatabaseDML.deleteListDML(cds, false);
        }

        ContentVersion cv = new ContentVersion(
            Title = numCaso + nombreDocumento, 
            PathOnClient ='SampleTitle.pdf',
            VersionData = body,
            FirstPublishLocationId = parentId,
            SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion',
            SAC_TipoAdjunto__c = maestro.Id,
            SAC_Bloque__c = 'SAC_Respuesta',
            SAC_ValidadoCV__c = true
        );

        SAC_DatabaseDML.insertDML(cv, false);
        SAC_DocumentoEnvio__c documento = [SELECT id FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:parentId AND SAC_Documento__c = null AND SAC_TipoDocumento__c =:procedencia LIMIT 1];
        //Comentado para que al generar el documento no salga en docs
        // documento.SAC_Version__c = cv.Id;
        documento.SAC_Documento__c = cv.ContentDocumentId;
        documento.SAC_URL__c = url;
        SAC_DatabaseDML.updateDML(documento, false);   
    }
}