/*****************************************************************
 * Name: SAC_LCMP_ReenvioCartaPostal
 * Copyright © 2021  CaixaBank
 * 
 * Proposito: Hacer el reenvio de la redacción de la reclamacion de tipo 
 *            Carta Postal
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR         DATE         Description
 * 1.0            US330921     Marcela Neira     14/02/22      Creación
*****************************************************************/
public without sharing class SAC_LCMP_ReenvioCartaPostal {

    @AuraEnabled
    public static string reenvioRedaccionCartaPostal(String idCaso, String newDireccion, String newPoblacion, String newProvincia, String newCodigoPostal, String newPais, String idAdjuntos){
        try {    
            SAC_DocumentoEnvio__c documentoEnvio = [SELECT Id, SAC_version__c, SAC_Documento__c, SAC_TipoDocumento__c, CreatedDate , SAC_Direccion__c, SAC_Poblacion__c, SAC_Pais__c, SAC_CP__c,
                                                     SAC_Provincia__c, SAC_caso__c
                                                     FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :idCaso AND SAC_TipoDocumento__c = 'redacción' 
                                                     Order By CreatedDate desc  LIMIT 1];
                                            
    //Recuperar el ContentDocumentLink
    List<ContentDocumentLink> cdL = [SELECT Id, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: idCaso AND ContentDocument.FileType != 'SNOTE']; 

    Set<Id> idsDocumentLink = new Set<Id>();
    for(ContentDocumentLink recordCdL : cdL){
        idsDocumentLink.add(recordCdL.ContentDocumentId);
    }

    if(!Schema.sObjectType.ContentVersion.isAccessible()){ throw new AuraHandledException( 'Fallo al recuperar el content version.' ); }
    ContentVersion cv = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE SAC_StringRedaccion_fileupload__c IN ('ResolucionRedaccion', 'ReenvioNuevoRedaccion') AND ContentDocumentId IN: idsDocumentLink order by CreatedDate desc LIMIT 1];

            SAC_DocumentoEnvio__c documentoReenvio = documentoEnvio.clone(false, false, false, false);
            documentoReenvio.SAC_TipoDocumento__c = 'reenvioRedaccion';
            documentoReenvio.SAC_Direccion__c = newDireccion;
            documentoReenvio.SAC_Poblacion__c = newPoblacion;
            documentoReenvio.SAC_Provincia__c = newProvincia;
            documentoReenvio.SAC_CP__c = newCodigoPostal;
            documentoReenvio.SAC_Pais__c = newPais;
            if(cv.ContentDocumentId != null){
                documentoReenvio.SAC_Documento__c = cv.ContentDocumentId;
            }
            
            SAC_DatabaseDML.insertDML(documentoReenvio, true);


            //Añadido US1194593 -------------
            List<ContentVersion> listCvAct = new List<ContentVersion>();
            List<ContentVersion> lstCV = new List<ContentVersion>();
            if(String.isNotBlank(idAdjuntos) && idAdjuntos != '[]'){
                Set<Id> idsAdjuntos = (Set<Id>)JSON.deserialize(idAdjuntos, Set<Id>.class);
                Set<Id> idsAdjuntosFinal = new Set<Id>();
                for (Id adj : idsAdjuntos) {
                    if (adj != null) {
                        idsAdjuntosFinal.add(adj);
                    }
                }
                
                if(!idsAdjuntosFinal.isEmpty()){
                    lstCV = [SELECT Id, ContentDocumentId, VersionData, SAC_Enviado__c FROM ContentVersion WHERE ContentDocumentId IN: idsAdjuntosFinal AND SAC_BloqueoTotalVisibilidad__c = false];  
                }
        
                if(!lstCV.isEmpty()){
                    for(ContentVersion contentVersion : lstCV){
                        if(!contentVersion.SAC_Enviado__c){
                            listCvAct.add(new ContentVersion(Id=contentVersion.Id,SAC_Enviado__c=true));
                        }
                    }
                }
                
                if(!listCvAct.isEmpty()){
                    SAC_DatabaseDML.updateListDML(listCvAct, true);
                }

                
            }
            //-------------------


            // SAC_DocumentoEnvio__c test = [SELECT Id FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :idCaso 
            // AND SAC_TipoDocumento__c = 'reenvioRedaccion' ];

            FeedItem post = new FeedItem(ParentId = idCaso, Body = 'Reenvío de la redacción final carta postal',Title = 'Fin Redacción');
            SAC_DatabaseDML.insertDML(post, false);
            SAC_LCMP_EnvioResolucionCorreoPostal.generarTareaAutomaticaRedaccionPostal(idCaso, idAdjuntos);
            String tareaId;
            SAC_Accion__c tarea = [SELECT Id FROM SAC_Accion__c WHERE SAC_Reclamacion__c = :idCaso order by CreatedDate desc LIMIT 1];
            if(tarea != null){
                tareaId = tarea.Id;
            }

            return tareaId;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static DatosDireccionWrapper obtenerDatosDireccion (String idCaso){
        SAC_DocumentoEnvio__c documentoEnvio = [SELECT Id, SAC_version__c, SAC_Documento__c, SAC_TipoDocumento__c, CreatedDate , SAC_Direccion__c, SAC_Poblacion__c, SAC_Pais__c, SAC_CP__c,
        SAC_Provincia__c, SAC_caso__c
        FROM SAC_DocumentoEnvio__c WHERE SAC_Caso__c = :idCaso AND SAC_TipoDocumento__c = 'redacción' 
        Order By CreatedDate desc  LIMIT 1];

        List<plantillasWrapper> paises = getPickListValuesIntoList();


        return new DatosDireccionWrapper(documentoEnvio.SAC_Direccion__c, documentoEnvio.SAC_Poblacion__c, documentoEnvio.SAC_CP__c, documentoEnvio.SAC_Provincia__c, documentoEnvio.SAC_Pais__c, paises);

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


    public class plantillasWrapper{

        @AuraEnabled public String idPlantilla{get; set;}
        @AuraEnabled public String nombrePlantilla{get; set;}   
        
        public plantillasWrapper(String id, String nombre){
            idPlantilla = id;
            nombrePlantilla = nombre;
        }
    }

    public class DatosDireccionWrapper{
    
        @AuraEnabled public String direccion {get; set;}
        @AuraEnabled public String poblacion {get; set;}
        @AuraEnabled public String codigoPostal {get; set;}
        @AuraEnabled public String provincia {get; set;}
        @AuraEnabled public String pais {get; set;}
        @AuraEnabled public List<plantillasWrapper> opcionesPais{get; set;}



        
        public DatosDireccionWrapper(String direccionM, String poblacionM, String codigoPostalM, String provinciaM, String paisM, List<plantillasWrapper> opcionesM  )
        {
            direccion = direccionM;
            poblacion = poblacionM;   
            codigoPostal = codigoPostalM;
            provincia = provinciaM;
            pais = paisM;
            this.opcionesPais = opcionesM;


        }
        
    }
    
}