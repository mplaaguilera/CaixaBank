public with sharing class SAC_LCMP_GeneracionDocumento {

    private static Set<String> objetos = new Set<String>{'Case','SAC_Interaccion__c','SAC_TMECaso__c','SAC_MaestroTemas__c','SAC_ImagenDocumento__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();
    private static final Id RECTYPEIMAGENES = mapRTsObjects.get('SAC_ImagenDocumento__c').get('SAC_ImagenDocumento').getRecordTypeId();
    private static final Id RECTYPERECLAMACIONSPV = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    final static Id RECTYPEADJUNTOSSPV = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_TipoAdjuntos').getRecordTypeId();

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
    public static void generarDocumentoRedaccion(String id, Boolean reenvio){
        try {
            SAC_DocumentoEnvio__c docEnvio = [SELECT SAC_Caso__c, SAC_Documento__c, SAC_DocPDF__c, SAC_Version__c, Id
                                                FROM SAC_DocumentoEnvio__c 
                                                WHERE Id =: id and SAC_Documento__c = null  limit 1];

        String vfHostname = DomainCreator.getVisualforceHostname(null);
        String urlVF =  vfHostname + '/apex/SAC_DocumentoRedaccionPDF?id=' + docEnvio.Id;
 
        adjuntarPDFaCaso(urlVF, docEnvio.SAC_Caso__c , 'redaccion', reenvio);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void adjuntarPDFaCaso(String url, Id parentId, String procedencia, Boolean reenvio){
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
        cvs = [SELECT Id, Title, ContentDocumentId, SAC_StringRedaccion_fileupload__c FROM ContentVersion WHERE FirstPublishLocationId =: parentId AND SAC_StringRedaccion_fileupload__c IN ('ResolucionRedaccion', 'ReenvioNuevoRedaccion')];
        SAC_MaestroTemas__c maestro = new SAC_MaestroTemas__c();
        if(caso.recordType.DeveloperName == 'SPV_Reclamacion') {
            //maestro = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'RESOLUCIONSPV' LIMIT 1];
            maestro = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEADJUNTOSSPV AND SAC_DeveloperName__c = 'RESOLUCIONSPV' LIMIT 1];
        } else {
            maestro = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'RESOLUCION' LIMIT 1];
        }
        ContentVersion cv;
        if(!reenvio){
            Set<Id> idsCD = new Set<Id>(); 
            if(!cvs.isEmpty()){
                for(ContentVersion tempCv : cvs){
                    if(tempCv.SAC_StringRedaccion_fileupload__c == 'ResolucionRedaccion'){
                    idsCD.add(tempCv.ContentDocumentId);
                    }
                }
                List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE Id IN: idsCD];
                SAC_DatabaseDML.deleteListDML(cds, false);
            }
                cv = new ContentVersion(
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
        }else{
            if(!cvs.isEmpty()){
                for(ContentVersion tempCv : cvs){
                    tempCv.SAC_StringRedaccion_fileupload__c = 'ReenvioAntiguoRedaccion';
                    tempCv.Title = tempCv.Title + ' (enviado)';
                }
                SAC_DatabaseDML.updateListDML(cvs, false);
            }

                cv = new ContentVersion(
                Title = numCaso + nombreDocumento, 
                PathOnClient ='SampleTitle.pdf',
                VersionData = body,
                FirstPublishLocationId = parentId,
                SAC_StringRedaccion_fileupload__c = 'ReenvioNuevoRedaccion',
                SAC_TipoAdjunto__c = maestro.Id,
                SAC_Bloque__c = 'SAC_Respuesta',
                SAC_ValidadoCV__c = true
            );
            SAC_DatabaseDML.insertDML(cv, false);
        }

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
            imagenNueva.recordTypeId = RECTYPEIMAGENES;
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
    /**
    Wrapper para retornar datos de la email template
    */
    public class WrapperTemplate{
        @AuraEnabled public String header{get;set;}
        @AuraEnabled public String footer{get;set;}
        
        public WrapperTemplate(String miHeader, String miFooter){
            this.header = miHeader;
            this.footer = miFooter;
        }  
    }
    /*
     * @description: método que asigna headers y footers en función del idioma y entidad afectada
     * @author: iria.alvarez.novoa@ibm.com
     * @date: diciembre 2024
     * @param idioma
     * @param entidad afectada
     * @param recordType
     */
    @AuraEnabled
    public static WrapperTemplate getHeaderAndFooterMTP(String idioma, String entidadAfectada, String recordType){
        
        EmailTemplate plantillaSeleccionada = new EmailTemplate();
        EmailTemplate plantillaHeader = new EmailTemplate();
        EmailTemplate plantillaFooter = new EmailTemplate();
        List<EmailTemplate> lstPlantillas = new List<EmailTemplate>();
        Boolean esReclamacionSPV = false;
        String headerSPV;
        String footerSPV;

        if(RECTYPERECLAMACIONSPV == recordType) {
            esReclamacionSPV = true;
            // Añadir logica si el header debe ser diferente según campo
            headerSPV = 'SPV_Header';
            footerSPV = 'SPV_Footer_' + idioma;
        }

        if (Schema.sObjectType.EmailTemplate.isAccessible()){
            lstPlantillas = [SELECT Id, Name, HtmlValue, DeveloperName, Folder.DeveloperName FROM EmailTemplate 
            WHERE Developername IN ('SAC_Header','SAC_Footer', 'SAC_Footer_ENG', 'SAC_FOOTER_CAT', 'SAC_FOOTER_Valenciano', 'SAC_FOOTER_Gallego', 'SAC_FOOTER_Euskera', 'SAC_FOOTER_ES_MTP', 'SAC_FOOTER_ENG_MTP', 'SAC_FOOTER_CAT_MTP', 'SAC_FOOTER_VAL_MTP', 'SAC_FOOTER_GAL_MTP', 'SAC_FOOTER_EUSK_MTP', 'SAC_HEADER_MTP', :footerSPV, :headerSPV)];
        }   

        if(lstPlantillas != null && !lstPlantillas.isEmpty()) {
            for(EmailTemplate em : lstPlantillas) {
                if(esReclamacionSPV) {
                    if(em.DeveloperName.contains('SPV_Header')) { plantillaHeader = em; } 
                    else if(em.DeveloperName.contains('SPV_Footer')) { plantillaFooter = em; }
                }
               if((em.DeveloperName == 'SAC_HEADER_MTP' && entidadAfectada == 'SAC_010') || (em.DeveloperName == 'SAC_Header' && entidadAfectada != 'SAC_010')) {
                plantillaHeader = em;
                }else if((em.DeveloperName == 'SAC_FOOTER_ES_MTP' && idioma == 'es' && entidadAfectada == 'SAC_010') || (em.DeveloperName == 'SAC_FOOTER_ENG_MTP' && idioma == 'en' && entidadAfectada == 'SAC_010') || (em.DeveloperName == 'SAC_FOOTER_CAT_MTP' && idioma == 'ca' && entidadAfectada == 'SAC_010') || 
                (em.DeveloperName == 'SAC_FOOTER_VAL_MTP' && idioma == 'va' && entidadAfectada == 'SAC_010') || (em.DeveloperName == 'SAC_FOOTER_GAL_MTP' && idioma == 'ga' && entidadAfectada == 'SAC_010') || (em.DeveloperName == 'SAC_FOOTER_EUSK_MTP' && idioma == 'eu' && entidadAfectada == 'SAC_010') ||
                (em.DeveloperName == 'SAC_Footer' && idioma == 'es' && entidadAfectada != 'SAC_010') || (em.DeveloperName == 'SAC_Footer_ENG' && idioma == 'en' && entidadAfectada != 'SAC_010') || (em.DeveloperName == 'SAC_Footer_CAT' && idioma == 'ca' && entidadAfectada != 'SAC_010') || 
                (em.DeveloperName == 'SAC_FOOTER_Valenciano' && idioma == 'va' && entidadAfectada != 'SAC_010') || (em.DeveloperName == 'SAC_FOOTER_Gallego' && idioma == 'ga' && entidadAfectada != 'SAC_010') || (em.DeveloperName == 'SAC_FOOTER_Euskera' && idioma == 'eu' && entidadAfectada != 'SAC_010')) {
                    plantillaFooter = em;
                }
            }
        }
        try{
            WrapperTemplate datosTemplate;
            if(!Test.isRunningTest()) {
                if(plantillaHeader != null && plantillaFooter != null) {
                    datosTemplate = new WrapperTemplate(plantillaHeader.HtmlValue, plantillaFooter.HtmlValue);
                } else if(plantillaHeader == null && plantillaFooter == null) {
                    datosTemplate = new WrapperTemplate('', '');
                } else if(plantillaHeader == null && plantillaFooter != null) {
                    datosTemplate = new WrapperTemplate('', plantillaFooter.HtmlValue);
                } else if(plantillaHeader != null && plantillaFooter == null) {
                    datosTemplate = new WrapperTemplate(plantillaHeader.HtmlValue, '');
                }
            } else {
                datosTemplate = new WrapperTemplate('Header', 'Footer');
            }
            System.debug('datosTemplate ' + datosTemplate);
            return datosTemplate;
        } catch (Exception e) {
            throw new AuraHandledException('La plantilla seleccionada no puede aplicarse debido a que no tiene relación con el objeto actual.');
        }
    }
}