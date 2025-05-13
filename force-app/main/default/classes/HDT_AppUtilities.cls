public with sharing class HDT_AppUtilities {

    private static final String BRACKET_LEFT        = '(';
    private static final String BRACKET_RIGHT       = ') ';
    private static final String BRACKET_RIGHT_ERROR = ') Error: ';
    
    /**
     * Display the errors from database Result: operation save
     */
    public static void displayErrors(String methodName, List<Database.SaveResult> listUpdateResult){
        if (listUpdateResult!=null && !listUpdateResult.isEmpty()){
            
            for (Database.SaveResult sr : listUpdateResult) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        print(LoggingLevel.ERROR, methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage(), true);
                        print(LoggingLevel.ERROR, methodName, '----ERR fields: ' + err.getFields(), true);
                    }
                }
            }
            print(LoggingLevel.ERROR, methodName, '***************************', true);
        }
    }

        /**
     * Display the errors from database Result: operation save
     */
    public static void displayErrorsDelete(String methodName, List<Database.DeleteResult> listDeleteResult){
        if (listDeleteResult!=null && !listDeleteResult.isEmpty()){
            
            for (Database.DeleteResult sr : listDeleteResult) {
                if (!sr.isSuccess()) {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        print(LoggingLevel.ERROR, methodName, '----ERR status: ' + err.getStatusCode() + ': ' + err.getMessage(), true);
                        print(LoggingLevel.ERROR, methodName, '----ERR fields: ' + err.getFields(), true);
                    }
                }
            }
            print(LoggingLevel.ERROR, methodName, '***************************', true);
        }
    }

    private static void print(LoggingLevel level, String methodName, String msg, boolean isError){
        if (msg!=null && msg.length()<6000000) {
            String msgError = BRACKET_LEFT + methodName + (isError ? BRACKET_RIGHT_ERROR : BRACKET_RIGHT) + msg;
            CBK_Log.error(msgError);
        }
    }

    /** Añadido el 03/04/2025 para nueva funcionalidad de CAIXA */
    // Codificamos los ficheros adjuntos de un caso
    /************************************************************ */
    public static Map<Id, List<Map<String, String>>> obtenerAdjuntosBase64PorCasos(List<Id> casoIds) {
        Map<Id, List<Map<String, String>>> casosConAdjuntos = new Map<Id, List<Map<String, String>>>();

        if (casoIds == null || casoIds.isEmpty()) {
            return casosConAdjuntos; // Retorna un mapa vacío si no hay casos
        }

        // Obtener los adjuntos relacionados con los casos
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :casoIds
        ];
        
        Map<Id, Id> contentDocumentMap = new Map<Id, Id>();
        for (ContentDocumentLink link : links) {
            contentDocumentMap.put(link.ContentDocumentId, link.LinkedEntityId);
        }
        
        if (!contentDocumentMap.isEmpty()) {
            List<ContentVersion> versiones = [
                SELECT Id, Title, VersionData,ContentDocumentId 
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentMap.keySet()
            ];
            
            for (ContentVersion version : versiones) {
                Id casoId = contentDocumentMap.get(version.ContentDocumentId);
                if (!casosConAdjuntos.containsKey(casoId)) {
                    casosConAdjuntos.put(casoId, new List<Map<String, String>>());
                }
                
                Map<String, String> adjunto = new Map<String, String>();
                adjunto.put('DOCUMENT', version.Title);
                adjunto.put('DOCUMENTDATA', EncodingUtil.base64Encode(version.VersionData));
                adjunto.put('URLNAME', version.Title);
                
                casosConAdjuntos.get(casoId).add(adjunto);
            }
        }
        
        return casosConAdjuntos;
    }

    /***************************************************************** */
    //Esta funcion no es necesaria subirla solamente es para ver si devuelve el valor correctamente 
    /******************************************************************* */
    /*
    public static void agregarAdjuntoDesdeBase64(Id casoId, String base64Data, String fileName, String fileExtension) {
        try {
            // Validaciones básicas
            if (String.isEmpty(base64Data) || casoId == null || String.isEmpty(fileName) || String.isEmpty(fileExtension)) {
                System.debug('Error: Parámetros inválidos.');
                return;
            }

            // Decodificar Base64 a Blob
            Blob fileBlob = EncodingUtil.base64Decode(base64Data);

            // Crear un nuevo ContentVersion (Salesforce Files)
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName + '.' + fileExtension;
            cv.VersionData = fileBlob;
            cv.IsMajorVersion = true;
            insert cv;

            // Obtener el ContentDocumentId para relacionarlo con el caso
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = casoId;
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            cdl.ShareType = 'V'; // Visualización
            cdl.Visibility = 'AllUsers'; // Visible para todos los usuarios
            insert cdl;

            System.debug('Archivo adjuntado correctamente al Caso con ID: ' + casoId);
        } catch (Exception e) {
            System.debug('Error al agregar el adjunto: ' + e.getMessage());
        }
    }*/

	
}