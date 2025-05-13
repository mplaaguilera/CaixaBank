public with sharing class SAC_LCMP_GeneracionCartaPostal {

    private static Set<String> objetos = new Set<String>{'Case','SAC_Interaccion__c','SAC_TMECaso__c','SAC_MaestroTemas__c','SAC_ImagenDocumento__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();
    private static final Id RECTYPEIMAGENES = mapRTsObjects.get('SAC_ImagenDocumento__c').get('SAC_ImagenDocumento').getRecordTypeId();
    private static final Id RECTYPERECLAMACIONSPV = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();

    @AuraEnabled
    public static WrappedInfoCartas compruebaCartaPrevia(Id caseId, String tipoCarta) {
        Id idCarta;

        List<SAC_DocumentoEnvio__c> carta = [SELECT id, SAC_CP__c, SAC_Direccion__c, SAC_Pais__c, SAC_Poblacion__c, SAC_Provincia__c, SAC_Cuerpo__c, SAC_DocPDF__c, SAC_Header__c, SAC_Footer__c FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:caseId  AND SAC_TipoDocumento__c =:tipoCarta AND SAC_Documento__c = null LIMIT 1];
        String vfHostname = DomainCreator.getVisualforceHostname(null);
        String urlVF = 'https://' + vfHostname + '/apex/SAC_CartaPDF?id=';

        List<plantillasWrapper> paises = getPickListValuesIntoList();

        if(carta.isEmpty()){//No existe aun la carta

            System.debug('caso id: ' + caseId);
            Case caso = [SELECT SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, RecordTypeId, SAC_Reclamacion__c FROM Case WHERE Id =: caseId LIMIT 1];
            
            if(caso.RecordTypeId == RECTYPEPRETENSION ){ //Se recupera la información del padre si estamos en una pretension
                Case reclamacion = [SELECT Id, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, RecordTypeId FROM Case WHERE Id =: caso.SAC_Reclamacion__c LIMIT 1]; 
                WrappedInfoCartas myInfo = new WrappedInfoCartas(urlVF, '', reclamacion.SAC_DireccionContacto__c, reclamacion.SAC_CodigoPostalContacto__c, reclamacion.SAC_PoblacionContacto__c, reclamacion.SAC_ProvinciaContacto__c, reclamacion.SAC_PaisContacto__c, '', paises, '', '', '');
                return myInfo;
            }
            else{//Se usa la información del propio registro
                WrappedInfoCartas myInfo = new WrappedInfoCartas(urlVF, '', caso.SAC_DireccionContacto__c, caso.SAC_CodigoPostalContacto__c, caso.SAC_PoblacionContacto__c, caso.SAC_ProvinciaContacto__c, caso.SAC_PaisContacto__c, '', paises, '', '', '');
                return myInfo;
            }

       }
        
        else{
            WrappedInfoCartas myInfo = new WrappedInfoCartas(urlVF, carta[0].Id, carta[0].SAC_Direccion__c, carta[0].SAC_CP__c, carta[0].SAC_Poblacion__c, carta[0].SAC_Provincia__c, carta[0].SAC_Pais__c, carta[0].SAC_Cuerpo__c, paises, carta[0].SAC_DocPDF__c, carta[0].SAC_Header__c, carta[0].SAC_Footer__c);
            return myInfo;
        }
    }

    @AuraEnabled
    public static List<plantillasWrapper> getPickListValuesIntoList(){
        List<plantillasWrapper> pickListValuesList= new List<plantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = SAC_DocumentoEnvio__c.SAC_Pais__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            plantillasWrapper wrapper = new plantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
     }

     
    public class WrappedInfoCartas{
        @AuraEnabled public String urlVF {get; set;}
        @AuraEnabled public String idCarta {get; set;}
        @AuraEnabled public String direccion {get; set;}
        @AuraEnabled public String cp {get; set;}
        @AuraEnabled public String poblacion {get; set;}
        @AuraEnabled public String provincia {get; set;}
        @AuraEnabled public String pais {get; set;}
        @AuraEnabled public String cuerpo {get; set;}  
        @AuraEnabled public List<plantillasWrapper> opcionesPais{get; set;}    
        @AuraEnabled public String docPDF {get; set;}
        @AuraEnabled public String header {get; set;}
        @AuraEnabled public String footer {get; set;}  

        public WrappedInfoCartas(String urlM, String idM, String direccionM, String cpM, String poblacionM, String provinciaM, String paisM, String cuerpoM, List<plantillasWrapper> opcionesM, String docPDFM, String headerM, String footerM){
            urlVF = urlM;
            idCarta = idM;
            direccion = direccionM;
            cp = cpM;
            poblacion = poblacionM;
            provincia = provinciaM;
            pais = paisM;
            cuerpo = cuerpoM;
            this.opcionesPais = opcionesM;
            docPDF = docPDFM;
            header = headerM;
            footer = footerM;
        }
    }

    public class plantillasWrapper{

        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
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
            String ruta = 'https://' + vfHostname + '/apex/SAC_EditorHTMLPlantillasCarta?id=';
            return ruta;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    public string lexOrigin {get{ return URL.getOrgDomainUrl().toExternalForm().split('.my.')[0]+'.lightning.force.com';} set;} 
    public string idCaso {get{ return ApexPages.currentPage().getParameters().get('id').escapeHtml4();} set;}
    public string cuerpoCarta{ get{ String procedencia = ApexPages.currentPage().getParameters().get('procedencia'); if(ApexPages.currentPage().getParameters().get('id') != null) {List<SAC_DocumentoEnvio__c> docGuardado = [SELECT Id, SAC_DocPDF__c FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c =: ApexPages.currentPage().getParameters().get('id') AND SAC_TipoDocumento__c =: procedencia ORDER by createdDate desc limit 1];if (docGuardado.size() > 0) {return docGuardado[0].SAC_DocPDF__c;}}return '';} set;}


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
                if(plantillaHeader != null && plantillaFooter != null) {                datosTemplate = new WrapperTemplate(plantillaHeader.HtmlValue, plantillaFooter.HtmlValue);
                } else if(plantillaHeader == null && plantillaFooter == null) { datosTemplate = new WrapperTemplate('', '');
                } else if(plantillaHeader == null && plantillaFooter != null) {datosTemplate = new WrapperTemplate('', plantillaFooter.HtmlValue);
                } else if(plantillaHeader != null && plantillaFooter == null) {datosTemplate = new WrapperTemplate(plantillaHeader.HtmlValue, '');
                }
            } else {     datosTemplate = new WrapperTemplate('Header', 'Footer');
            }
            return datosTemplate;
        } catch (Exception e) {
            throw new AuraHandledException('La plantilla seleccionada no puede aplicarse debido a que no tiene relación con el objeto actual.');
        }
    }

}