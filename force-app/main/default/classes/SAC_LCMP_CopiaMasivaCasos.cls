public with sharing class SAC_LCMP_CopiaMasivaCasos {

    private static Set<String> objetos = new Set<String>{'Case'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);
    private static final Id RECORDTYPERECLAMACION = mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    private static final Id RECORDTYPEPRETENSION = mapRTsObjects.get('Case').get('SAC_Pretension').getRecordTypeId();

    @AuraEnabled
    public static void cargarCopias(String recordId, Integer numeroCopias){

        //Query de la reclamación y sus pretensiones hijas a copiar
        List<Case> listaCasosOriginales = [SELECT Id, RecordTypeId, SAC_TipoDeRepresentante__c, SAC_TipoDeDocumento__c, SAC_NumeroDelDocumento__c, SAC_NombreRepresentante__c, SAC_DespachoRepresentante__c, 
                                            SAC_EmailRepresentante__c, SAC_TelefonoRepresentante__c, SAC_DireccionPostal__c, Subject, SAC_Reclamacion__c, CC_CasoRelacionado__c, Origin, SAC_Quebranto__c,
                                            CC_Canal_Procedencia__c, CC_Canal_Respuesta__c, SuppliedEmail, SAC_Importe_Tipo__c, CC_Importe_Reclamado__c, SAC_Importe_Resuelto__c, CC_Importe_Abonado__c,
                                            SAC_Prorrogado__c, SAC_ProrrogaCounter__c, SAC_FechaProrroga__c, SAC_TipoSubsanacion__c, CC_SuppliedFiles__c, SAC_CasoEspecial__c, SAC_Naturaleza__c,
                                            Status, SAC_StatusAuxiliar__c, CC_Idioma__c, Priority, SEG_Grupo__c, OwnerId, SAC_Entidad_Afectada__c, CC_Oficina_Afectada_Lookup__c,
                                            CC_Oficina__c, SAC_FechaRecepcion__c, SAC_FechaVencimientoSLA__c, OS_Fecha_Resolucion__c, IsStopped, SAC_CASE_esPSD2__c, SAC_EnvioParcial__c,
                                            SAC_RedaccionFinal__c, SAC_NoAplicaTareas__c, SAC_ReclamanteConformeNegociacion__c, SAC_ResultadoNegociacion__c, SAC_DetalleResultadoNegociacion__c,
                                            CC_SuppliedEntidad__c, CC_Numero_Contrato__c, CC_Observaciones__c, CC_SuppliedProductoDesc__c, SAC_Redaccion__c, Description, SourceId,
                                            CC_MCC_Tematica__c, CC_MCC_ProdServ__c, CC_MCC_Motivo__c, SEG_Detalle__c, SAC_SentidoResolucion__c, SAC_MotivoInadmision__c,SAC_MotivoSentidoResolucion__c,
                                            SAC_MotivoRechazo__c, SAC_Importe_ResultadoNegociacion__c, SAC_CasoRelacionado__c, SAC_DireccionRepresentante__c, SAC_CodigoPostalRepresentante__c,
                                            SAC_PoblacionRepresentante__c, SAC_ProvinciaRepresentante__c, SAC_PaisRepresentante__c, CC_Detalles_Solucion__c, SAC_PretensionPrincipal__c, CaseNumber,
                                            SAC_NPretensionesActivas__c, SAC_EntidadProductora__c
                                            FROM Case
                                            WHERE (recordTypeId = :RECORDTYPERECLAMACION AND Id = :recordId)
                                            OR (recordTypeId = :RECORDTYPEPRETENSION AND SAC_Reclamacion__c = :recordId AND Status <> 'SAC_009')];

        //Cola pendiente asignar
        Group cola = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SAC_PendienteAsignar' LIMIT 1];

        //Ids de los casos a copiar para buscar los adjuntos
        List<Id> listaIds = new List<Id>();
        for (Case caso : listaCasosOriginales) {
            listaIds.add(caso.Id);
        }

        //Seleccionar los ContentDocumentLink de los casos que queremos copiar
        List<ContentDocumentLink> listaConDocLink = [SELECT Id, LinkedEntityId, ContentDocumentId, Visibility, IsDeleted, ShareType,
                                                    ContentDocument.Title, ContentDocument.createdDate, ContentDocument.FileType
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId IN :listaIds];

        //Rellenar mapa con ContentDocumentLink para saber que documentos tiene cada caso y añadirlos a cada uno de ellos
        Map<Id, List<ContentDocumentLink>> mapaConDocLink = new Map<Id, List<ContentDocumentLink>>();
        if (!listaConDocLink.isEmpty()) {
            for (ContentDocumentLink cdl : listaConDocLink) {
                if (mapaConDocLink.containsKey(cdl.LinkedEntityId)) {
                    mapaConDocLink.get(cdl.LinkedEntityId).add(cdl);
                } else {
                    List<ContentDocumentLink> listaCDL = new List<ContentDocumentLink>();
                    listaCDL.add(cdl);
                    mapaConDocLink.put(cdl.LinkedEntityId, listaCDL);
                }
            }
        }

        //Caso reclamación padre que updatearemos para almacenar las ids de los jobs en un campo textArea
        Case reclamacion = new Case();
        reclamacion.Id = recordId;
        //Se harán las copias de la reclamación y todas sus pretensiones y adjuntos de 6 en 6
        Integer copiasAHacer = 6;
        //Si las copias que ha introducido el usuario son menos de 6, se harán las introducidas
        if (numeroCopias < 6) {
            copiasAHacer = numeroCopias;
        }
        
        //Llamada a la clase para que encole un Job con los casos a copiar, la cola a la que pertenece, los documentos a copiar, las copias a hacer (6 o menos) y el numero de copias total que quedan
        DateTime dt = DateTime.now();
        Long dateInMilliseconds = dt.getTime();
        AsyncOptions options = new AsyncOptions();
        options.DuplicateSignature = QueueableDuplicateSignature.Builder().addId(UserInfo.getUserId()).addString(String.valueOf(dateInMilliseconds)).build();
        ID jobID;
        try {
            jobID = System.enqueueJob(new SAC_CargaMasiva(listaCasosOriginales, cola, mapaConDocLink, copiasAHacer, numeroCopias), options);    
        } catch (DuplicateMessageException ex) {  CBK_Log.error(ex);                 } 
        //Almacenamiento de la Id del Job en el campo de la reclamación
        if (String.isNotBlank(reclamacion.CC_Detalles_Solucion__c)) {
            reclamacion.CC_Detalles_Solucion__c = reclamacion.CC_Detalles_Solucion__c + jobID + ';';
        } else {
            reclamacion.CC_Detalles_Solucion__c = jobID + ';';
        }

        SAC_DatabaseDML.updateDML(reclamacion, true);
    }

    @AuraEnabled(cacheable = true)
    public static boolean comprobarCOPS(){
        try {
            Boolean esCOPS = false;
            Id idUser = UserInfo.getUserId();
            List<CC_Grupo_Colaborador_Contact__c> colabContact = [SELECT Id, CC_Grupo_Colaborador__c 
                                                                    FROM CC_Grupo_Colaborador_Contact__c 
                                                                    WHERE CC_Usuario__c=:idUser
                                                                    AND CC_Grupo_Colaborador__r.SAC_DeveloperName__c = 'COPS'];
            if (!colabContact.isEmpty()) {
                esCOPS = true;
            }
            return esCOPS;
        } catch (Exception e) {
            CBK_Log.error(e);
            throw new AuraHandledException(e.getMessage());
        }
    }
}