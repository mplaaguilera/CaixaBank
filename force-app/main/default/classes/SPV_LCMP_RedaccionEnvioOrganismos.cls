public with sharing class SPV_LCMP_RedaccionEnvioOrganismos {
    private static Set<String> objetos = new Set<String>{'Case', 'SAC_Accion__c', 'SAC_MaestroAccionesReclamacion__c'};

    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SPV_Utils.getRecordTypesObjects(objetos);

    private static final Id RECTYPERECLAMACION = mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    private static final Id RECTYPEPRETENSION = mapRTsObjects.get('Case').get('SPV_Pretension').getRecordTypeId();
    private static final Id RECTYPEMAESTROTAREAS = mapRTsObjects.get('SAC_Accion__c').get('SPV_MaestroDeTareas').getRecordTypeId();
    private static final Id RECTYPEMAESTROACCIONESREC = mapRTsObjects.get('SAC_MaestroAccionesReclamacion__c').get('SPV_MaestroAcciones').getRecordTypeId();

    /*****************************************************************************
    * Proposito: Realiza el envío y tareas necesarias en la fase de "Envio organismos"
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR          DATE         Description
    * 1.0            US1013702     Sergio Martín    11/09/24        Creación
    *****************************************************************************/
    @AuraEnabled
    public static void enviarDocOrganismos(String caseId, Boolean enviarReclamante, Boolean enviarOrganismos, String organismo, string estado, string subestado, List<string> listaSeleccionados) {
        List<ContentVersion> listaAdjuntos = obtieneAdjuntosEnvio(caseId, listaSeleccionados);
        if(enviarReclamante) {
            generarTareaReclamante(caseId, listaAdjuntos);
        }

        if(enviarOrganismos) {
            // if(organismo == 'SPV_BDE') {
            //     //generarBatchEnvioBDE(caseId, listaAdjuntos);
            // } else{
                generarTareaAutomaticaOrganismo(caseId, organismo, listaAdjuntos);
            //}
        }
        if(caseId != null && Schema.sObjectType.Case.isUpdateable()) {
            Case caso = new Case();
            caso.Id = caseId;
            if(estado ==  'SPV_EnvioOrganismos' && subestado == 'SPV_SubRectificacion'){
                caso.Status = 'Cerrado';
                caso.SEG_Subestado__c = 'Cerrada y en Ejecucion';
            }else{
                caso.Status = 'SPV_PendienteRespuestaOrganismos';
                caso.SPV_ComplementariaOrganismo__c = false;
                caso.SPV_Complementaria_Entidad__c = false;

                List<SAC_Accion__c> tareas = [SELECT Id, OwnerId, SAC_Estado__c FROM SAC_Accion__c WHERE SAC_Reclamacion__c =: caseId 
                                                AND (SAC_Estado__c != 'SAC_Finalizada' AND SAC_Estado__c != 'SAC_FinalizadaIncompleta' AND SAC_Estado__c != 'SAC_Descartada')];
                 
                // Si hay alguna tarea del expediente pendiente de finalización, el subestado será el de “Ejecución y pendiente respuesta Organismo”.
                if(!tareas.isEmpty()){
                    caso.SEG_Subestado__c = 'Ejecucion y Pendiente Respuesta Organismo';
                }
                else{
                    caso.SEG_Subestado__c = 'Pendiente respuesta Organismos';
                }
            }
            SPV_DatabaseDML.updateDML(caso, true);
        }
    }

    /*****************************************************************************
    * Proposito: Genera una tarea para el envío de la documentación marcada para el reclamante
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1013702     Sergio Martín    11/09/24        Creación
    *****************************************************************************/
    public static void generarTareaReclamante(String caseId, List<ContentVersion> listaAdjuntos) {
        SAC_MaestroAccionesReclamacion__c maestroTareaAutomatica = [SELECT Id, Name FROM SAC_MaestroAccionesReclamacion__c WHERE RecordTypeId = :RECTYPEMAESTROACCIONESREC AND SAC_Activo__c = true AND SAC_DeveloperName__c = 'SPV_TareaEnvioReclamante' LIMIT 1];  

        if(maestroTareaAutomatica != null) {
            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_MaestroAccionesReclamacion__c = maestroTareaAutomatica.Id;

            tarea.RecordTypeId = RECTYPEMAESTROTAREAS;
            tarea.SAC_Reclamacion__c = caseId;
            
            try {
                if (!Schema.sObjectType.SAC_Accion__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realizar esta accion.' ); }
                SPV_DatabaseDML.insertDML(tarea, true);
            } catch (Exception e) {
                CBK_log.error(e);
            }
    
            List<ContentDocumentLink> listaAdjuntosTarea = new List<ContentDocumentLink>();
            List<SAC_DocumentoEnvio__c> listaDocs = new List<SAC_DocumentoEnvio__c>();
            for(ContentVersion cv : listaAdjuntos) {

                ContentDocumentLink cdl = new ContentDocumentLink();
                SAC_DocumentoEnvio__c docEnvio = new SAC_DocumentoEnvio__c();

                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = tarea.Id;
                cdl.ShareType = 'I';
                listaAdjuntosTarea.add(cdl);

                // Se crea un registro en SAC_DocumentoEnvio__c para controlar los elementos que hemos enviado en el caso
                docEnvio.SAC_Documento__c = 'Reclamante';
                docEnvio.SAC_TipoDocumento__c = cv.SAC_TipoAdjunto__r.Name;
                docEnvio.Name = cv.Title;
                docEnvio.SAC_Caso__c = caseId;
                listaDocs.add(docEnvio);
            }
            SPV_DatabaseDML.insertListDML(listaAdjuntosTarea, true);
            SPV_DatabaseDML.insertListDML(listaDocs, true);

        }
    }


    /*****************************************************************************
    * Proposito: Genera un batch nocturno para el envío a BDE
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1013702     Sergio Martín    11/09/24        Creación
    *****************************************************************************/
    // public static void generarBatchEnvioBDE(String caseId, List<ContentVersion> listaAdjuntos) {
    //     System.debug('Entra en generarBatchEnvioBDE');
        
    // }


    /*****************************************************************************
    * Proposito: Genera otra tarea automática con los adjuntos necesarios para 
    *            el envío por parte de COPS de la documentación correspondiente
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1013702     Sergio Martín    11/09/24        Creación
    *****************************************************************************/
    public static void generarTareaAutomaticaOrganismo(String caseId, String organismo, List<ContentVersion> listaAdjuntos) {
        SAC_MaestroAccionesReclamacion__c maestroTareaAutomatica = [SELECT Id, Name FROM SAC_MaestroAccionesReclamacion__c WHERE RecordTypeId = :RECTYPEMAESTROACCIONESREC AND SAC_Activo__c = true AND SAC_DeveloperName__c = 'SPV_TareaEnvioOrganismo' LIMIT 1];  
        if(maestroTareaAutomatica != null) {
            SAC_Accion__c tarea = new SAC_Accion__c();
            tarea.SAC_MaestroAccionesReclamacion__c = maestroTareaAutomatica.Id;

            tarea.RecordTypeId = RECTYPEMAESTROTAREAS;
            tarea.SAC_Reclamacion__c = caseId;
            
            try {
                if (!Schema.sObjectType.SAC_Accion__c.isCreateable()) { throw new AuraHandledException( 'No tienes permisos para realizar esta accion.' ); }
                SPV_DatabaseDML.insertDML(tarea, true);
            } catch (Exception e) {
                CBK_log.error(e);
            }
            List<ContentDocumentLink> listaAdjuntosTarea = new List<ContentDocumentLink>();
            List<SAC_DocumentoEnvio__c> listaDocs = new List<SAC_DocumentoEnvio__c>();
            String organismoLabel = organismo.replace('SPV_', '');

            for(ContentVersion cv : listaAdjuntos) {

                ContentDocumentLink cdl = new ContentDocumentLink();
                SAC_DocumentoEnvio__c docEnvio = new SAC_DocumentoEnvio__c();

                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = tarea.Id;
                cdl.ShareType = 'I';
                listaAdjuntosTarea.add(cdl);

                docEnvio.SAC_Documento__c = organismoLabel;
                docEnvio.SAC_TipoDocumento__c = cv.SAC_TipoAdjunto__r.Name;
                docEnvio.Name = cv.Title;
                docEnvio.SAC_Caso__c = caseId;
                listaDocs.add(docEnvio);
            }
            SPV_DatabaseDML.insertListDML(listaAdjuntosTarea, true);
            SPV_DatabaseDML.insertListDML(listaDocs, true);
        }
    }


    /*****************************************************************************
    * Proposito: Obtiene los adjuntos necesarios en el envío
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0            US1013702     Sergio Martín    11/09/24        Creación
    *****************************************************************************/
    public static ContentVersion[] obtieneAdjuntosEnvio(String caseId, List<string> listaSeleccionados){
        ContentVersion[] resultado =  new List<ContentVersion>();
        List<Id> idsDocumentLink = new List<Id>();
        List<Id> idsSeleccionados = new List<Id>();

        for(String idDoc: listaSeleccionados){
            idsSeleccionados.add(idDoc);
        }
        
        List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: caseId];  

        for(ContentDocumentLink recordCdL : cdL){
            idsDocumentLink.add(recordCdL.ContentDocumentId);
        }

        List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title, CreatedDate, SAC_TipoAdjunto__c, SAC_TipoAdjunto__r.Name, SAC_Bloque__c, SAC_ValidadoCV__c, SAC_TipoAdjunto__r.SAC_DeveloperName__c FROM ContentVersion WHERE ContentDocumentId IN: idsDocumentLink AND Id IN: idsSeleccionados ORDER BY CreatedDate ASC];
        for(ContentVersion record : cv){
            if(record.SAC_Bloque__c.contains('SAC_Respuesta') && record.SAC_ValidadoCV__c == true) {
                resultado.add(record);
            }
        }
        return resultado;
    }

    
    /*****************************************************************************
    * Proposito: Obtiene los adjuntos validados 
    * 
    * Historial
    * -------
    * VERSION        USER_STORY       AUTHOR         DATE         Description
    * 1.0                             Carlos Gómez     25/10/25        Creación
    *****************************************************************************/

    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getDocumentosValidados(String caseId){
        Map<Id, Boolean> contentOculto = new Map<Id, Boolean>();
        List<Id> idsDocumentLink = new List<Id>();

        try {
        List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: caseId AND ContentDocument.FileType != 'SNOTE'];  
        

            for(ContentDocumentLink recordCdL : cdL){

                idsDocumentLink.add(recordCdL.ContentDocumentId);
            }

            List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title, SAC_Oculto__c, CreatedDate, SAC_TipoAdjunto__c, SAC_TipoAdjunto__r.Name, SAC_Bloque__c, SAC_ValidadoCV__c, SAC_Numero_Prestamo__c FROM ContentVersion WHERE SAC_ValidadoCV__c = true AND ContentDocumentId IN: idsDocumentLink ORDER BY CreatedDate ASC];

            for(ContentVersion recordCv : cv){
                contentOculto.put(recordCv.id, recordCv.SAC_Oculto__c);
            }

            ContentVersion[] resultado =  new List<ContentVersion>();
            for(ContentDocumentLink record : cdL){

                if(contentOculto.get(record.id) != null){

                    resultado.add(new ContentVersion (ContentDocumentId=record.ContentDocumentId, Title=record.ContentDocument.Title, SAC_Oculto__c=contentOculto.get(record.id)));

                }else{resultado.add(new ContentVersion (ContentDocumentId=record.ContentDocumentId, Title=record.ContentDocument.Title, SAC_Oculto__c=false));}
            }

            return cv;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }        
    }}