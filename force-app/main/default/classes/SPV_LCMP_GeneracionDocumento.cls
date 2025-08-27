public with sharing class SPV_LCMP_GeneracionDocumento {

    private static Set<String> objetos = new Set<String>{'SAC_ImagenDocumento__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPEIMAGENES = mapRTsObjects.get('SAC_ImagenDocumento__c').get('SAC_ImagenDocumento').getRecordTypeId();

    
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
            String ruta = 'https://' + vfHostname + '/apex/SPV_EditorHTMLPlantillas?id=';
            return ruta;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string insertarimagen(String id, String imagen){
        try {
            SAC_ImagenDocumento__c imagenNueva = new SAC_ImagenDocumento__c();
            imagenNueva.SAC_Caso__c = id;
            imagenNueva.SAC_Imagen__c = imagen;
            imagenNueva.recordTypeId = RECTYPEIMAGENES;
            SPV_DatabaseDML.insertDML(imagenNueva,false);

            SAC_ImagenDocumento__c imagenInsertada = [SELECT Id, SAC_Imagen__c FROM SAC_ImagenDocumento__c WHERE RecordTypeId = :RECTYPEIMAGENES AND Id =: imagenNueva.id AND SAC_Caso__c = :id LIMIT 1];
            return imagenInsertada.SAC_Imagen__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void generarDocumento(String id, String nombreDocumento){
        try {
            String procedencia = 'generacionDocSPV';
            
            SAC_DocumentoEnvio__c docEnvio = [SELECT SAC_Caso__c, SAC_Documento__c, SAC_DocPDF__c, SAC_Version__c, Id
                                                FROM SAC_DocumentoEnvio__c 
                                                WHERE Id =: id and SAC_Documento__c = null AND SAC_TipoDocumento__c =:procedencia ORDER BY CreatedDate DESC LIMIT 1];

            String vfHostname = DomainCreator.getVisualforceHostname(null);
            String urlVF =  vfHostname + '/apex/SAC_DocumentoRedaccionPDF?id=' + docEnvio.Id;
    
            adjuntarPDFaCaso(urlVF, docEnvio.SAC_Caso__c , procedencia, nombreDocumento);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    //metodo que extrae el numero de caso y el idioma en el que se va a generar el documento
    @AuraEnabled
    public static Map<String, Object> informacionCaso(String id) {
        try {
            String procedencia = 'generacionDocSPV';

            SAC_DocumentoEnvio__c docEnvio = [SELECT SAC_Caso__c, SAC_Documento__c, SAC_DocPDF__c, SAC_Version__c, Id
                                            FROM SAC_DocumentoEnvio__c 
                                            WHERE Id =: id 
                                            AND SAC_Documento__c = null 
                                            AND SAC_TipoDocumento__c =: procedencia 
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];

            Case caso = [SELECT CaseNumber, CC_Idioma__c, RecordType.DeveloperName 
                        FROM Case 
                        WHERE Id = :docEnvio.SAC_Caso__c 
                        LIMIT 1];

            Map<String, Object> resultado = new Map<String, Object>();
            resultado.put('numeroCaso', caso.CaseNumber);
            resultado.put('idioma', caso.CC_Idioma__c);
            return resultado;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void adjuntarPDFaCaso(String url, Id parentId, String procedencia, String nombreDocumentoParametro){
        Case caso = [SELECT CaseNumber, CC_Idioma__c, recordType.DeveloperName FROM Case WHERE id =: parentId LIMIT 1];
        //String numCaso = caso.CaseNumber;
        //String numCaso = nombreDocumentoParametro;
        //String nombreDocumento;

        /*if(caso.CC_Idioma__c == 'es') { nombreDocumento = '  documento generado ESP'; }
        else if(caso.CC_Idioma__c == 'ca') { nombreDocumento = '  documento generado CAT '; }
        else if(caso.CC_Idioma__c == 'en') { nombreDocumento = '  documento generado ENG'; }
        else if(caso.CC_Idioma__c == 'va') { nombreDocumento = '  documento generado VAL'; }
        else if(caso.CC_Idioma__c == 'ga') { nombreDocumento = '  documento generado GAL'; }
        else if(caso.CC_Idioma__c == 'eu') { nombreDocumento = '  documento generado EUSK'; }
        else { nombreDocumento = ' documento generado DEFAULT'; }*/

        PageReference pageRef = new PageReference('https://' + url);          
        Blob body;
        if(Test.isRunningTest()){
            body = blob.valueOf('Unit.Test');
        }
        else{              
            body = pageRef.getContentAsPDF();                
        }

        List<ContentVersion> cvs = new List<ContentVersion>();
        // cvs = [SELECT Id, Title, ContentDocumentId, SAC_StringRedaccion_fileupload__c FROM ContentVersion WHERE FirstPublishLocationId =: parentId AND SAC_StringRedaccion_fileupload__c IN ('ResolucionRedaccion', 'ReenvioNuevoRedaccion')];

        // SAC_MaestroTemas__c maestro = new SAC_MaestroTemas__c();
        // if(caso.recordType.DeveloperName == 'SPV_Reclamacion') {
        //     maestro = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'RESOLUCIONSPV' LIMIT 1];
        // }

        ContentVersion cv;
        Set<Id> idsCD = new Set<Id>(); 
        // if(!cvs.isEmpty()){
        //     for(ContentVersion tempCv : cvs){
        //         if(tempCv.SAC_StringRedaccion_fileupload__c == 'ResolucionRedaccion'){
        //         idsCD.add(tempCv.ContentDocumentId);
        //         }
        //     }
        //     List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE Id IN: idsCD];
        //     SAC_DatabaseDML.deleteListDML(cds, false);
        // }
        cv = new ContentVersion(
            Title = nombreDocumentoParametro, 
            PathOnClient ='SampleTitle.pdf',
            VersionData = body,
            FirstPublishLocationId = parentId,
            SAC_Bloque__c = 'SAC_Tramitacion',
            SAC_ValidadoCV__c = false
        ); //SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion', SAC_TipoAdjunto__c = maestro.Id,

        SPV_DatabaseDML.insertDML(cv, false);
        

        SAC_DocumentoEnvio__c documento = [SELECT id FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c =:parentId AND SAC_Documento__c = null AND SAC_TipoDocumento__c =:procedencia ORDER BY CreatedDate DESC LIMIT 1]; 

        //Comentado para que al generar el documento no salga en docs
        // documento.SAC_Version__c = cv.Id;
        documento.SAC_Documento__c = cv.ContentDocumentId;
        documento.SAC_URL__c = url;

        SPV_DatabaseDML.updateDML(documento, false);   
                        
    }

    public string lexOrigin {get{ return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';} set;}

    public string idCaso {get{ return ApexPages.currentPage().getParameters().get('id').escapeHtml4();} set;}

    public string cuerpoDocumento { get{ if(ApexPages.currentPage().getParameters().get('id') != null) {List<SAC_DocumentoEnvio__c> docGuardado = [SELECT Id, SAC_DocPDF__c, SAC_URL__c FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c =: ApexPages.currentPage().getParameters().get('id') AND SAC_TipoDocumento__c = 'generacionDocSPV' ORDER BY createdDate DESC LIMIT 1];if (docGuardado.size() > 0 && docGuardado[0].SAC_URL__c == null) {return docGuardado[0].SAC_DocPDF__c;}}return '';} set;}

    @AuraEnabled(cacheable=true)
    public static SAC_DocumentoEnvio__c comprobarDocumentoGuardado(String id){
        String procedencia = 'generacionDocSPV';
        
        List<SAC_DocumentoEnvio__c> docEnvio = [SELECT Id, SAC_URL__c, SAC_Header__c, SAC_Footer__c FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c  =: id AND SAC_TipoDocumento__c =:procedencia ORDER BY CreatedDate DESC LIMIT 1];

        if(!docEnvio.isEmpty()){
            return docEnvio[0];
        }else{
            return null;
        }
    }
}