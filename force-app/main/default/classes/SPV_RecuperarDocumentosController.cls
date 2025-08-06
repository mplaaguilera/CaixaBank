public with sharing class SPV_RecuperarDocumentosController {

    private static Set<String> objetos = new Set<String>{'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPETIPOADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();


    /*****************************************************************
    * Proposito: Al tomar en propiedad el caso, se llama a la integración de ATR para obtener
    * el ticketERR y obtener los documentos relacionados con el caso desde l aintegración ERR
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --              Álex Polo      01/10/24        Creacion
    *****************************************************************/
    @AuraEnabled
    public static void recuperarTicketERR(Id caseId){
        List<Case> casesToUpdate = new List<Case>();
        SPV_Documentos_Integration_ATR.TicketGetDocumentoResponse responseATR = new SPV_Documentos_Integration_ATR.TicketGetDocumentoResponse ();
        List <SPV_Documentos_Integration_ATR.Documento> listaTicketERR = new List<SPV_Documentos_Integration_ATR.Documento>();
        List<ContentVersion> listaContentVersions = new List<ContentVersion>();


        //Se obtiene el ticketERR de la reclamación a través de la integración ATR, devuelve una lista de documentos entre otras cosas
        responseATR = SPV_Documentos_Integration_ATR.getTicketEER(caseId);
        //Si el código de retorno es 200, se llama a la integración de ERR para obtener los documentos
        if(responseATR.statusCode == '200' || responseATR.statusCode.equalsIgnoreCase('200')){
        
            if(responseATR.lstDocumentos != null){
                listaTicketERR = responseATR.lstDocumentos;     //Lista de los documentos recuperados de ATR
            }
			//Recuperar los adjunto cargados en el casoActual,y los que tengan el campo SAC_IdEER__c en la listaTicketERR quitarlos de esta lista (estos no se insertarán)
			//
            //Para cada ticketERR de la reclamación, se generará su documento asociado
            //ESTE IF ESTABA DESCOMENTADO
           // if(!listaTicketERR.isEmpty()){  //Sustituir esta lista listaTicketERR, por la nueva sin duplicados
				/*String ticketEERConcat = '';
                for(SPV_Documentos_Integration_ATR.Documento documento : listaTicketERR){ //Sustituir esta lista listaTicketERR, por la nueva sin duplicados
                    ticketEERConcat += documento.ticketEER + ';';
                }
                for(Case rec: [SELECT Id, SPV_TicketEERList__c FROM Case WHERE Id =: caseId]){
                    rec.SPV_TicketEERList__c = ticketEERConcat;
                    casesToUpdate.add(rec);
                }
                if(!casesToUpdate.isEmpty()){
                    update casesToUpdate;
                }*/
                /*
                List<SAC_MaestroTemas__c> documentoOrganismo = [SELECT Id FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPETIPOADJUNTOS AND SAC_DeveloperName__c = 'SPV_DocumentacionOrganismo' LIMIT 1];
                
                for(SPV_Documentos_Integration_ATR.Documento documento : listaTicketERR){ //Sustituir esta lista listaTicketERR, por la nueva sin duplicados
                
                    SPV_Documentos_Integration_EER.GetDocumentoResponse documentResponse = SPV_Documentos_Integration_EER.getDocument(documento.ticketEER, caseId); //A cada ticketERR, se llama a la integración
           
                    //Si el status del resultado es 200, se opera
                    if(documentResponse != null && documentResponse.statusCode.equalsIgnoreCase('200')){
                        
                        //Se crea un contentVersion que representa al adjunto obtenido para este ticketERR
                        ContentVersion cv = new ContentVersion();
                        cv.VersionData = EncodingUtil.base64Decode(documentResponse.documento.file); //De ERR
                        cv.PathOnClient = documento.nombreDocumento + '.' + documentResponse.documento.metadata.format; //Formato viene de ERR
                        cv.Title = documento.nombreDocumento;       //De ATR
						cv.SAC_TipoAdjunto__c = documentoOrganismo[0].Id;
                        cv.SAC_IdEER__c = documento.ticketEER;              //Almacena el ticketERR del documento en su Content Version

                        //crearYAniadirCV(documentResponse.documento.file, documento.nombreDocumento, documentResponse.documento.metadata.format, listaContentVersions);
                        listaContentVersions.add(cv);

                    }else{  //Si la respuesta de la integración ERR no es 200
                        throw new AuraHandledException('No se han podido recuperar los documentos: ' + documentResponse.errorMessage);
                    }
                }*/

           // }
            
            //En caso de haber recuperado documentos, se llama al método para crear los adjuntos
            /*if(!listaContentVersions.isEmpty()){
                generarAdjuntoDocument(listaContentVersions, caseId);
            }*/

        }else{  //Si la respuesta de la integración ATR no es 200
            throw new AuraHandledException('No se han podido recuperar los documentos: ' + responseATR.errorMessage);
        }

    }


    /*****************************************************************
    * Proposito: Método que recibe los documentos a generar de las integraciones, 
    * y crea los adjuntos
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            --              Álex Polo      01/10/24        Creacion
    *****************************************************************/
    
    @AuraEnabled
    public static void generarAdjuntoDocument(List<ContentVersion> listaContentVersions, Id caseId){

       //List<ContentVersion> listaContentVersions = new List<ContentVersion>();
       Set<Id> listaIdsCV = new Set<Id>();      //Se almacenarán Ids de los content version
       List<ContentDocumentLink> listaDocumentLink = new List<ContentDocumentLink>();


       //Si hay CVs, se insertan
       if(!listaContentVersions.isEmpty()){
        
          //Database.insert(listaContentVersions);
          SPV_DatabaseDML.insertListDML(listaContentVersions, true);

          //Tras insertarlos, recojo el id de los cv insertados
          for(ContentVersion cvNuevo: listaContentVersions){
             listaIdsCV.add(cvNuevo.Id);
          }

          //Recoger el ContentDocumentId de los cv insertados
          List<ContentVersion> listaCvInsertados = new List<ContentVersion>();
          listaCvInsertados = [SELECT Id, ContentDocumentId, SAC_IdEER__c FROM ContentVersion WHERE Id IN :listaIdsCV];

          //Tras ello, se crea el document link para cada content version que se ha insertado
          if(!ListaCvInsertados.isEmpty()){
            for(ContentVersion cver : ListaCvInsertados){
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cver.ContentDocumentId;
                cdl.LinkedEntityId = caseId;  //id del caso al que le pertenecen los documentos adjuntos
                cdl.ShareType = 'V';

                listaDocumentLink.add(cdl);
              }

             //Una vez creados todos los document links, se insertan
             if(!listaDocumentLink.isEmpty()){
                //Database.insert(listaDocumentLink);
                SPV_DatabaseDML.insertListDML(listaDocumentLink, true);
             }
          }

       }

    }


    @AuraEnabled
    public static void crearYAniadirCV(String file, String nombreDocumento, String formato, List<ContentVersion> listaContentVersions){
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(file);
        cv.PathOnClient = nombreDocumento + '.' + formato;
        cv.Title = nombreDocumento;
        listaContentVersions.add(cv);

    }

}