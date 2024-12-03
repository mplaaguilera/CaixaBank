public with sharing class SAC_LCMP_AcuseReciboCartaPostal {
    
    @AuraEnabled
    public static ObjWrapper getInfoInit(Id recordId){
        if(!Schema.sObjectType.Case.isAccessible()){
            throw new AuraHandledException( 'Fallo al obtener información para el acuse de recibo mediante carta postal.' ); 
        }
        Id rt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SAC_Reclamacion').getRecordTypeId();
        Case registroActual = [SELECT Id, CaseNumber, CreatedDate, Status, SAC_RedaccionFinal__c, SAC_DireccionContacto__c, SAC_CodigoPostalContacto__c, SuppliedEmail, 
                               SAC_PoblacionContacto__c, SAC_ProvinciaContacto__c, SAC_PaisContacto__c, SAC_NombreContacto__c, Origin, OS_Email__c, CC_AcuseRecibo__c, CC_Idioma__c, SAC_M2P__c
                                 FROM Case WHERE RecordTypeId =: rt AND Id =: recordId];
                            
        String asunto = 'Reclamación abierta - ' + registroActual.CaseNumber;

        List<PlantillasWrapper> paises = getPickListValuesIntoList();
        ObjWrapper result = new ObjWrapper(registroActual, paises, registroActual.OS_Email__c, 'Reclamación abierta - ' + registroActual.CaseNumber);
        return result;
    }

    @AuraEnabled
    public static List<PlantillasWrapper> getPickListValuesIntoList(){
        List<PlantillasWrapper> pickListValuesList= new List<PlantillasWrapper>();
         Schema.DescribeFieldResult fieldResult = SAC_DocumentoEnvio__c.SAC_Pais__c.getDescribe();
         List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
         for( Schema.PicklistEntry pickListVal : ple){
            PlantillasWrapper wrapper = new PlantillasWrapper(pickListVal.getValue(), pickListVal.getLabel());
            pickListValuesList.add(wrapper);
         }
         return pickListValuesList;
     }

    
    /*****************************************************************
    * @description envío del acuse de recibo via carta postal
    * VERSION        USER_STORY       AUTHOR            DATE         Description
    * 1.1             US994116      Raúl Santos       12/09/24       Modificación: modificación para la generación de la carta y posterior creación del content version
    *****************************************************************/
    @AuraEnabled
    public static void envioCartaPostal(Case caso, String direccion, String codigoPostal, String poblacion, String provincia, String pais){
        
        String cuerpo = '<html><body><p>'
            + 'Asunto    CaixaBank – Acuse de recibo de formulario.' + /*'\n' +*/ '</p><br /><p>' //+ '<br />'
            + 'Cuerpo    Distinguido Sr./Sra. ' + caso.SAC_NombreContacto__c  + '</p><br /><p>'
            + 'Le informamos que su escrito, recibido con fecha ' + caso.CreatedDate.format() +', ha sido registrado con el número ' + caso.CaseNumber  + '</p><br /><p>'
            + 'En breve le notificaremos la correspondiente resolución.' + '</p><br /><p>'
            + 'Reciba un cordial saludo.</p>';

        List<Case> casos = new List<Case>();
        casos.add(caso);
        Map<Id, Case> mapa = new Map<Id, Case>();
        List<SAC_AcuseRecibo_Email.TemplateWrapper> plantilla = SAC_AcuseRecibo_Email.getPlantillaAcuseRecibo(casos, mapa);
        
        if(!plantilla.isEmpty()){
            cuerpo = plantilla[0].htmlValueTemplate;
        }
        
        SAC_DocumentoEnvio__c carta = new SAC_DocumentoEnvio__c();
        carta.SAC_Caso__c = caso.Id;
        carta.SAC_Cuerpo__c = cuerpo;
        carta.SAC_Direccion__c = direccion;
        carta.SAC_CP__c = codigoPostal;
        carta.SAC_Poblacion__c = poblacion;
        carta.SAC_Provincia__c = provincia;
        carta.SAC_Pais__c = pais;
        carta.SAC_TipoDocumento__c = 'acuse recibo';
    
        SAC_DatabaseDML.insertDML(carta, true);

        SAC_FutureMethods.generarCartaPostal(carta.id, caso.Id);
    }

    @AuraEnabled
    public static void envioEmail(Case casoApex){ 

       // updateRecordStatus(record, newStatus);
        /*Case casoPorActualizar = [SELECT Id, Status, SAC_MotivoInadmision__c
                                    FROM Case 
                                    WHERE Id =: record];*/
        /*casoPorActualizar.Status = newStatus;
        casoPorActualizar.SAC_StatusAuxiliar__c = newStatus;
        casoPorActualizar.SAC_TipoSubsanacion__c = motivo;
        update casoPorActualizar;
        
        casoApex.CC_AcuseRecibo__c = '2';
        update casoApex;*/

        casoApex.CC_AcuseRecibo__c = '2';
        List<Case> casos = new List<Case>();
        casos.add(casoApex);
        Map<Id, Case> mapa = new Map<Id, Case>();
        SAC_AcuseRecibo_Email.envioAcuseRecibo(casos, mapa);
        SAC_DatabaseDML.updateListDML(casos, true); 
    }
    
    @AuraEnabled
    public static void envioEmailManual(Case casoApex){

        if(casoApex.CC_AcuseRecibo__c != '2'){
            casoApex.CC_AcuseRecibo__c = '2';
        }
        List<Case> casos = new List<Case>();
        casos.add(casoApex);
        Map<Id, Case> mapa = new Map<Id, Case>();
        SAC_AcuseRecibo_Email.envioAcuseReciboManual(casos, mapa);

        SAC_DatabaseDML.updateListDML(casos, true); 
    }


    public class ObjWrapper{

        @AuraEnabled public Case caso{get; set;}
        @AuraEnabled public List<PlantillasWrapper> opcionesPais{get; set;}
        @AuraEnabled public String para{get;set;}
        @AuraEnabled public String asunto{get;set;}
        
        public ObjWrapper(Case casoM, List<PlantillasWrapper> opcionesM, String paraM, String asuntoM){
            this.caso = casoM;
            this.opcionesPais = opcionesM;
            this.para = paraM;
            this.asunto = asuntoM;
        }
    }

    public class PlantillasWrapper{

        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
    }
}