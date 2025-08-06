public without sharing class SAC_GeneracionCartas {

    private static final Id RECTYPEPRETENSION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Pretension').getRecordTypeId();


    @AuraEnabled
    public static WrappedInfoCartas SAC_BuscaCartaPrevia(Id caseId, String tipoCarta) {
        Id idCarta;

        List<SAC_DocumentoEnvio__c> carta = [SELECT id, SAC_CP__c, SAC_Direccion__c, SAC_Pais__c, SAC_Poblacion__c, SAC_Provincia__c, SAC_Cuerpo__c FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:caseId  AND SAC_TipoDocumento__c =:tipoCarta AND SAC_Documento__c = null LIMIT 1];

        //Case caso = [SELECT SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c FROM Case WHERE Id =: caseId LIMIT 1];
        
        /*
        Ya no se utiliza, ahora sacamos la URL de visualforce directamente con la nueva clase DomainCreator
        String hostname = System.Url.getSalesforceBaseUrl().getHost();
        String myDomain = hostname.split('\\.')[0];
        */

        String vfHostname = DomainCreator.getVisualforceHostname(null);
        String urlVF = 'https://' + vfHostname + '/apex/SAC_CartaPDF?id=';

        List<plantillasWrapper> paises = getPickListValuesIntoList();

        if(carta.isEmpty()){//No existe aun la carta
            Case caso = [SELECT SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, RecordTypeId, SAC_Reclamacion__c FROM Case WHERE Id =: caseId LIMIT 1];
            
            if(caso.RecordTypeId == RECTYPEPRETENSION ){ //Se recupera la información del padre si estamos en una pretension
                Case reclamacion = [SELECT Id, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, RecordTypeId FROM Case WHERE Id =: caso.SAC_Reclamacion__c LIMIT 1];
                WrappedInfoCartas myInfo = new WrappedInfoCartas(urlVF, '', reclamacion.SAC_DireccionContacto__c, reclamacion.SAC_CodigoPostalContacto__c, reclamacion.SAC_PoblacionContacto__c, reclamacion.SAC_ProvinciaContacto__c, '', '', paises);
                return myInfo;
            }
            else{//Se usa la información del propio registro
                WrappedInfoCartas myInfo = new WrappedInfoCartas(urlVF, '', caso.SAC_DireccionContacto__c, caso.SAC_CodigoPostalContacto__c, caso.SAC_PoblacionContacto__c, caso.SAC_ProvinciaContacto__c, '', '', paises);
                return myInfo;
            }

       }
        
        else{
            WrappedInfoCartas myInfo = new WrappedInfoCartas(urlVF, carta[0].Id, carta[0].SAC_Direccion__c, carta[0].SAC_CP__c, carta[0].SAC_Poblacion__c, carta[0].SAC_Provincia__c, '', carta[0].SAC_Cuerpo__c, paises);
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

    @AuraEnabled
    public static void adjuntarPDFaCaso2(String url, Id parentId, String procedencia){
   
        String contador = '';
        String numCaso = [SELECT CaseNumber FROM Case WHERE id =: parentId].CaseNumber;
        PageReference pageRef = new PageReference(url);
        
        Blob body;
        if(Test.isRunningTest()){
            body = blob.valueOf('Unit.Test');
        }
        else{
            
            body = pageRef.getContentAsPDF();            
        }

        String redaccion = 'carta postal ' + procedencia;
        List<ContentVersion> cvs = new List<ContentVersion>();
            cvs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: parentId AND SAC_StringRedaccion_fileupload__c =: 'ResolucionRedaccion'];
            cvs = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE FirstPublishLocationId =: parentId AND SAC_StringRedaccion_fileupload__c =: redaccion];
        
        Set<Id> idsCD = new Set<Id>(); 
        if(!cvs.isEmpty()){
            for(ContentVersion cv : cvs){
                idsCD.add(cv.ContentDocumentId);
            }
            List<ContentDocument> cds = [SELECT Id FROM ContentDocument WHERE Id IN: idsCD];
            List<ContentDocument> cdsCnt = cds;
            //delete cds;
            contador = String.valueOf(cdsCnt.size() + 1);
        }
        ContentVersion cv = new ContentVersion(
            Title = numCaso + ' Carta postal ' + procedencia + ' (' + contador + ')', 
            PathOnClient ='SampleTitle.pdf',
            VersionData = body,
            FirstPublishLocationId = parentId,
            SAC_StringRedaccion_fileupload__c = redaccion
        );
        if(contador == ''){
            cv.Title = numCaso + ' Carta postal ' + procedencia;
        }
        
        //Añadido en US1194593
        cv.SAC_Enviado__c = true;

        insert cv;

        ContentVersion content = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id AND FirstPublishLocationId =: parentId AND SAC_StringRedaccion_fileupload__c =: redaccion LIMIT 1];
        SAC_DocumentoEnvio__c carta = [SELECT id FROM SAC_DocumentoEnvio__c WHERE  SAC_Caso__c =:parentId AND SAC_Documento__c = null AND SAC_TipoDocumento__c =:procedencia LIMIT 1];

        carta.SAC_Version__c = content.Id;
        carta.SAC_Documento__c = content.ContentDocumentId;
        carta.SAC_URL__c = url;


        update carta;        
    }

    @AuraEnabled
    public static void actualizarDatosEnvio(String idCarta, String direccion, String cp, String poblacion, String provincia, String pais){
        SAC_DocumentoEnvio__c carta = [SELECT id, SAC_Direccion__c, SAC_CP__c, SAC_Poblacion__c, SAC_Provincia__c, SAC_Pais__c FROM SAC_DocumentoEnvio__c WHERE  id =: idCarta LIMIT 1];

        carta.SAC_Direccion__c = direccion;
        carta.SAC_CP__c = cp;
        carta.SAC_Poblacion__c = poblacion;
        carta.SAC_provincia__c = provincia;
        carta.SAC_Pais__c = pais;
        
        update carta;
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

        public WrappedInfoCartas(String urlM, String idM, String direccionM, String cpM, String poblacionM, String provinciaM, String paisM, String cuerpoM, List<plantillasWrapper> opcionesM){
            urlVF = urlM;
            idCarta = idM;
            direccion = direccionM;
            cp = cpM;
            poblacion = poblacionM;
            provincia = provinciaM;
            pais = paisM;
            cuerpo = cuerpoM;
            this.opcionesPais = opcionesM;
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
}