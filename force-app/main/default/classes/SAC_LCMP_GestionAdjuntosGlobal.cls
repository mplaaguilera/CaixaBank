public without sharing class SAC_LCMP_GestionAdjuntosGlobal {

    private static Set<String> objetos = new Set<String>{'Case', 'SAC_MaestroTemas__c'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    final static Id RECTYPERECLAMACION =  mapRTsObjects.get('Case').get('SAC_Reclamacion').getRecordTypeId();
    final static Id RECTYPERECLAMACIONSPV =  mapRTsObjects.get('Case').get('SPV_Reclamacion').getRecordTypeId();
    final static Id RECTYPECONSULTA =  mapRTsObjects.get('Case').get('SAC_Consulta').getRecordTypeId();
    final static Id RECTYPEADJUNTOS = mapRTsObjects.get('SAC_MaestroTemas__c').get('SAC_TipoAdjuntos').getRecordTypeId();
    final static Id RECTYPEADJUNTOSSPV = mapRTsObjects.get('SAC_MaestroTemas__c').get('SPV_TipoAdjuntos').getRecordTypeId();
    
    @AuraEnabled
    public static oficinaWrapper recuperarDatos(String idRegistro, String fieldApiName, String objectApiName){

        fieldApiName = fieldApiName + ', RecordType.DeveloperName';
    
        String globalObject = 'SELECT ' + String.escapeSingleQuotes(fieldApiName) + ' FROM ' + String.escapeSingleQuotes(objectApiName) + ' WHERE  id = :idRegistro';
        Boolean esGeneral = false;
    
        Set<Id> psAsignados = new Map<Id, PermissionSet>([
            SELECT Id FROM PermissionSet
            WHERE Id IN (
                SELECT PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
            )
        ]).keySet();
    
        if(!psAsignados.isEmpty()){
            List<CustomPermission> customPermisos = [
                SELECT DeveloperName FROM CustomPermission
                WHERE Id IN (
                    SELECT SetupEntityId
                    FROM SetupEntityAccess
                    WHERE SetupEntityType = 'CustomPermission'
                    AND ParentId IN :psAsignados
                    // AND Parent.Name LIKE 'SAC%'
                )
            ];
    
            if (!customPermisos.isEmpty()) {
                for (CustomPermission customPermiso : customPermisos) {
                    String customPermisoNombre = customPermiso.DeveloperName;
                    if(customPermisoNombre == 'SAC_HabilitarFuncFicheros' || customPermisoNombre == 'SPV_HabilitarFuncFicheros'){
                        esGeneral = true;
                    }
                }
            }
        }

        List<SObject> globalObjectResults = Database.query(globalObject);

        if(!globalObjectResults.isEmpty()) {
            oficinaWrapper wpp = new oficinaWrapper(Database.query(globalObject)[0], esGeneral, '');
    
            if (objectApiName == 'Case') {
                wpp.sacBloquePicklistValues = getPicklistValues('ContentVersion', 'SAC_Bloque__c');
                List<Case> recla = [SELECT Id, CC_CasoRelacionado__c FROM Case WHERE (RecordTypeId = :RECTYPERECLAMACION OR RecordTypeId = :RECTYPERECLAMACIONSPV) AND Id = :idRegistro LIMIT 1];
                if (!recla.isEmpty()) {
                    wpp.mostrarBloques = true;
                    wpp.idCasoRelacionado = recla[0].CC_CasoRelacionado__c;
                }
            }
        
            return wpp;
        }else{
            return null;
        }
    }
    
    public static Map<String, String> getPicklistValues(String objectName, String fieldName) {
        Map<String, String> picklistValues = new Map<String, String>();
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType == null) {
            return picklistValues;
        }
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        Schema.SObjectField field = describeResult.fields.getMap().get(fieldName);
        if (field == null) {
            return picklistValues;
        }
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry entry : picklistEntries) {
            picklistValues.put(entry.getValue(), entry.getLabel());
        }

        return picklistValues;
    }

        @AuraEnabled
        public static Boolean replicarAdjuntosCase(String idDocument, String id, Boolean soloActual, Boolean ponerTramitacion){
            
            Boolean alertaDocumentosGestorSPV = false;
            List<Case> caso = [SELECT id, SAC_UltimaModificacionFichero__c, OwnerId, RecordTypeId, Status, SAC_GrupoLetrado__r.SAC_Email__c, CaseNumber, SAC_GrupoLetrado__c, SAC_PretensionPrincipal__r.OwnerId, 
                                        SAC_PretensionPrincipal__r.Owner.Email 
                                FROM CASE WHERE id =: id LIMIT 1];

            if(!caso.isEmpty()){
                caso[0].SAC_UltimaModificacionFichero__c = DateTime.now();

                try{
                    update caso[0];
                } catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }

            // Añadido para updatear el campo SAC_Bloque__c del contentVersion con el valor SAC_Tramitacion
            if (ponerTramitacion) {
                List<ContentVersion> listaCV = [
                    SELECT Id, ContentDocumentId, Title, SAC_Bloque__c
                    FROM ContentVersion
                    WHERE ContentDocumentId = :idDocument
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];
                if (!listaCV.isEmpty()) {

                    Id idUserActual = UserInfo.getUserId();

                    //En las reclamaciones de supervisores
                    if(caso[0].RecordTypeId == RECTYPERECLAMACIONSPV){
                        //Si quien adjunta es el gestor, el fichero se mete en la sección de 'Entrada'
                        if(caso[0].OwnerId == idUserActual){
                            listaCV[0].SAC_Bloque__c = 'SAC_Entrada';

                            //Si el gestor añade documentación en estado análisis, debemos lanzar una alerta
                            if(caso[0].Status == 'SAC_002'){
                                alertaDocumentosGestorSPV = true;
                            }

                        }else{ //Si lo mete el letrado, se mete en la seccion de 'Tramitacion'
                            listaCV[0].SAC_Bloque__c = 'SAC_Tramitacion';
                        }
                    }else{
                        listaCV[0].SAC_Bloque__c = 'SAC_Tramitacion';
                    }
                    SAC_DatabaseDML.updateListDML(listaCV, false);
                }
            }
            // Fin añadido

            if(alertaDocumentosGestorSPV){

                List<SAC_WrapperAlerta> listaWrapperAlerta = new List<SAC_WrapperAlerta>();
                List<String> listaEmails = new List<String>();

                if(String.isNotBlank(caso[0].SAC_GrupoLetrado__r.SAC_Email__c)) {
                    listaEmails.add(caso[0].SAC_GrupoLetrado__r.SAC_Email__c);
                }
                //Añadir el email del letrado
                if(String.isNotBlank(caso[0].SAC_PretensionPrincipal__r.Owner.Email)) {
                    listaEmails.add(caso[0].SAC_PretensionPrincipal__r.Owner.Email);
                }
            
                //Se envia alerta el owner de las pretensiones y al grupo letrado
                SAC_WrapperAlerta wrapAlerta = new SAC_WrapperAlerta(caso[0].Id,
                                                'SPV_017',
                                                'Se ha añadido documentación complementaria en la reclamación ' + caso[0].CaseNumber + '. Debe volver a revisarla.',
                                                caso[0].SAC_PretensionPrincipal__r.OwnerId,
                                                '',
                                                '', 
                                                '');
                                                wrapAlerta.enlaceParaEmail = URL.getSalesforceBaseUrl().toExternalForm() + '/' + caso[0].Id;
                                                wrapAlerta.listaEmailsGrupo = listaEmails;
                                                wrapAlerta.idGrupoColaborador = caso[0].SAC_GrupoLetrado__c;
                                                wrapAlerta.proyecto = 'SPV';
                //Añadirla a la lista para posteriormente llamar al método
                listaWrapperAlerta.add(wrapAlerta);

                //Si tenemos alertas que enviar, se llama al método que las envía
                if (!listaWrapperAlerta.isEmpty()) {
                    SAC_Alertas.generarAlertas(listaWrapperAlerta);
                }
            }

            if(!soloActual){
                ContentVersion cv = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE ContentDocumentId =: idDocument AND SAC_BloqueoTotalVisibilidad__c = false LIMIT 1]; 
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cv.ContentDocumentId;
                cdl.LinkedEntityId = id;
                cdl.ShareType = 'I';
                try{
                // Database.insert(cdl);
                SAC_DatabaseDML.insertDML(cdl, true);
                } catch (Exception e) {
                    return true; 
                }
                return false;
            }
            return false;
        }
    
        @AuraEnabled
        public static ContentVersion[] obtieneAdjuntos(String id){
            try {
                List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title FROM ContentVersion WHERE FirstPublishLocationId =: id AND SAC_BloqueoTotalVisibilidad__c = false];
    
                ContentVersion[] resultado =  new List<ContentVersion>();

                for(ContentVersion record : cv){
                    resultado.add(record);
                }
                return resultado;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }
    
        @AuraEnabled
        public static ContentVersion[] recuperaAdjuntos(String id){

            Map<Id, Boolean> contentOculto = new Map<Id, Boolean>();
            List<Id> idsDocumentLink = new List<Id>();

            try {
            List<ContentDocumentLink> cdL = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId =: id AND ContentDocument.FileType != 'SNOTE'];  
            

                for(ContentDocumentLink recordCdL : cdL){

                    idsDocumentLink.add(recordCdL.ContentDocumentId);
                }
    
                List<ContentVersion> cv = [SELECT Id, ContentDocumentId, Title, SAC_Oculto__c, CreatedDate, SAC_TipoAdjunto__c, SAC_TipoAdjunto__r.Name, SAC_Bloque__c, SAC_ValidadoCV__c, SAC_Numero_Prestamo__c, SAC_Enviado__c FROM ContentVersion WHERE ContentDocumentId IN: idsDocumentLink AND SAC_BloqueoTotalVisibilidad__c = false ORDER BY CreatedDate ASC];

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
        }

        @AuraEnabled
        public static void desvincularAdjunto(String idDocument, String id){
            try {
                ContentDocumentLink cd = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =: idDocument AND LinkedEntityId =: id LIMIT 1];
                // Database.delete(cd);
                SAC_DatabaseDML.deleteDML(cd, true);
    
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        @AuraEnabled
        public static void eliminarAdjunto(String idDocument){
            try {
                ContentDocument cd = [SELECT Id, FileExtension FROM ContentDocument WHERE id =: idDocument LIMIT 1];
                // Database.delete(cd);
                SAC_DatabaseDML.deleteDML(cd, true);
    
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        @AuraEnabled
        public static void ocultarContentVersion(Id id){
            ContentVersion cv = [SELECT Id, ContentDocumentId, Title, SAC_Oculto__c FROM ContentVersion WHERE Id =: id];
            cv.SAC_Oculto__c=true;
            // Database.update(cv);
            SAC_DatabaseDML.updateDML(cv, true);
        }
        @AuraEnabled
        public static void desocultarContentVersion(Id id){
            ContentVersion cv = [SELECT Id, ContentDocumentId, Title, SAC_Oculto__c FROM ContentVersion WHERE Id =: id];
            cv.SAC_Oculto__c=false;
            // Database.update(cv);
            SAC_DatabaseDML.updateDML(cv, true);
        }

        @AuraEnabled
        public static List<SAC_MaestroTemas__c> recuperaTipoAdjuntos(String id, String rtCaso){

            try {
                List<SAC_MaestroTemas__c> maestroAdjuntos = new List<SAC_MaestroTemas__c>();
                if(rtCaso == 'SPV_Reclamacion'){
                    maestroAdjuntos = [SELECT Id, Name, SAC_DocumentoVisible__c FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEADJUNTOSSPV AND SAC_Activo__c = true];
                }else{
                    maestroAdjuntos = [SELECT Id, Name, SAC_DocumentoVisible__c FROM SAC_MaestroTemas__c WHERE RecordTypeId = :RECTYPEADJUNTOS AND SAC_Activo__c = true];
                }

                
                if(!maestroAdjuntos.isEmpty()){
                    return maestroAdjuntos;
                }else{
                    return null;
                }
                
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        @AuraEnabled
        public static void asignarTipoAdjunto(Id idAdjunto, List<ContentVersion> ficherosAdjuntos, SAC_MaestroTemas__c maestroAdjuntos){

            List<ContentVersion> adjuntos = new List<ContentVersion>();

            if(!ficherosAdjuntos.isEmpty()){
                for(ContentVersion cv : ficherosAdjuntos){
                    if(cv.Id == idAdjunto){
                        cv.SAC_TipoAdjunto__c = maestroAdjuntos.Id;
                        cv.SAC_Oculto__c = !(maestroAdjuntos.SAC_DocumentoVisible__c);
                        adjuntos.add(cv);
                    }
                }
            }

            if(!adjuntos.isEmpty()){
                // Database.update(adjuntos);
                SAC_DatabaseDML.updateListDML(adjuntos, true);
            }
        }

        @AuraEnabled
        public static void cambiarClasificacion(List<String> listIdAdjuntos, List<String> listaValoresBloque, String caseId){
            try {
                List<ContentDocumentLink> cdL = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: caseId AND ContentDocumentId IN :listIdAdjuntos AND ContentDocument.FileType != 'SNOTE']; 

                if(!cdL.isEmpty()){
                    Set<Id> idsDocumentLink = new Set<Id>();

                    for(ContentDocumentLink recordCdL : cdL){
                        idsDocumentLink.add(recordCdL.ContentDocumentId);
                    }

                    List<ContentVersion> listaCV = [SELECT Id FROM ContentVersion WHERE ContentDocumentId IN: idsDocumentLink AND SAC_BloqueoTotalVisibilidad__c = false];

                    if (!listaCV.isEmpty()) {
                        String valoresBloque = String.join(listaValoresBloque, ';');

                        for(ContentVersion cv : listaCV){
                            cv.SAC_Bloque__c = valoresBloque;
                        }
                       
                        SAC_DatabaseDML.updateListDML(listaCV, true);
                    }
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        @AuraEnabled
        public static void cambiarTituloFichero(Id idAdjunto, String titulo, String prefijo, Boolean validadoCV){
            try {
            ContentVersion fichero = [SELECT Id, Title, SAC_ValidadoCV__c, SAC_StringRedaccion_fileupload__c FROM ContentVersion WHERE id = :idAdjunto];
            if(validadoCV == true){
                if (!fichero.Title.startsWith(prefijo)) {
                    fichero.Title = prefijo + ' ' + fichero.Title;
                    // fichero.SAC_StringRedaccion_fileupload__c = 'ResolucionRedaccion';
                }            
            }else{
                if (fichero.Title.startsWith(prefijo)) {
                    fichero.Title = fichero.Title.replaceFirst(prefijo + ' ', '');
                    fichero.SAC_StringRedaccion_fileupload__c = ' ';

                }
            }
            fichero.SAC_ValidadoCV__c = validadoCV;
            SAC_DatabaseDML.updateDML(fichero, true);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        public class oficinaWrapper{

            @AuraEnabled public SObject objeto{get; set;}
            @AuraEnabled public Boolean usuarioGeneral{get; set;}
            @AuraEnabled public Map<String, String> sacBloquePicklistValues {get;set;}
            @AuraEnabled public Boolean mostrarBloques {get;set;}
            @AuraEnabled public String idCasoRelacionado {get;set;}
            
            public oficinaWrapper(SObject objecto, Boolean userGeneral, String idCasoRelacionadoActual){
                objeto = objecto;
                usuarioGeneral = userGeneral;
                mostrarBloques = false;
                idCasoRelacionado = idCasoRelacionadoActual;
            }
        }
}