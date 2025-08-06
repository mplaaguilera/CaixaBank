public with sharing class SAC_CaracteristicaCarga {

    private static Set<String> objetos = new Set<String>{'CC_Caracteristica__c','Account'};
    private static Map<String, Map<String,Schema.RecordTypeInfo>> mapRTsObjects = SAC_Utils.getRecordTypesObjects(objetos);

    private final static Id RTREPRESENTANTECARACTERISTICA = mapRTsObjects.get('CC_Caracteristica__c').get('SAC_CaracteristicaRepresentante').getRecordTypeId();
    private final static Id RTCUENTACARACTERISTICA = mapRTsObjects.get('CC_Caracteristica__c').get('SAC_CaracteristicaClienteCuenta').getRecordTypeId();
    private final static Id RTCLIENTE = mapRTsObjects.get('Account').get('CC_Cliente').getRecordTypeId();
    private final static Id RTCLIENTE_PA = mapRTsObjects.get('Account').get('CC_ClientePA').getRecordTypeId();
    private final static Id RTNOCLIENTE_PA = mapRTsObjects.get('Account').get('SAC_NoCliente_PA').getRecordTypeId();
    

    @AuraEnabled
    public static CC_Caracteristica__c recuperarCaracteristica(Id caracteristicaId){  

        CC_Caracteristica__c caracteristica = new CC_Caracteristica__c();

        if (Schema.sObjectType.CC_Caracteristica__c.isAccessible()) {
            caracteristica = [SELECT Id, RecordType.DeveloperName FROM CC_Caracteristica__c WHERE (RecordTypeId = : RTREPRESENTANTECARACTERISTICA OR RecordTypeId = : RTCUENTACARACTERISTICA) AND Id = :caracteristicaId LIMIT 1];
        }
        
        return caracteristica;       
    }

    @AuraEnabled
    public static void deleteFile(String contentDocumentId) {
        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
        // Database.delete(contentDocumentList);
        SAC_DatabaseDML.deleteListDML(contentDocumentList, true);
    }

    @AuraEnabled
    public static String loadFile(String caracteristicaId, String contentDocumentId) {
        Set<String> identificadores = new Set<String>();
        Map<String, CC_Caracteristica_Detalle__c> mapaIdentificadorDetalle = new Map<String, CC_Caracteristica_Detalle__c>();
        List<String> log = new List<String>();
        log.add('\t\tINFORME DE SUBIDA EN CARACTERÍSTICA');

        CC_Caracteristica__c caracteristica = [SELECT Id, RecordTypeId FROM CC_Caracteristica__c WHERE Id = :caracteristicaId];

        // Leemos el fichero
        List<ContentVersion> contentVersionList = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true];
        String fileBody = contentVersionList[0].VersionData.toString();
        
        // Nos creamos una lista de identificadores validados
        for (String line : fileBody.split('\n')) {
            String lineTrimmed = line.trim();
            if (String.isNotBlank(lineTrimmed)) {
                identificadores.add(lineTrimmed);  
            }
        }                                       

        // Depuramos los identificadores
        if (caracteristica.RecordTypeId == RTCUENTACARACTERISTICA) {
            identificarDuplicados(identificadores, caracteristicaId, log);
            mapaIdentificadorDetalle = depurarClientesCuentas(identificadores, caracteristica.Id, log);
        }else if(caracteristica.RecordTypeId == RTREPRESENTANTECARACTERISTICA){
            identificarDuplicados(identificadores, caracteristicaId, log);
            mapaIdentificadorDetalle = depurarRepresentantes(identificadores, caracteristica.Id, log);
        } 

        // Insertamos en Característica Detalle
        if (mapaIdentificadorDetalle.values().size()>0) {
            // Database.insert(mapaIdentificadorDetalle.values());
            SAC_DatabaseDML.insertListDML(mapaIdentificadorDetalle.values(), true);
        }

        deleteFile(contentDocumentId);

        // Subimos el fichero de log y obtenemos su enlace
        String logUrl = uploadLog(log);

        return logUrl;
    }

    private static void identificarDuplicados(Set<String> identificadores, Id caracteristicaId, List<String> log) {

        List<CC_Caracteristica_Detalle__c> listDetalles = [SELECT Id, CC_Identificador__c, SAC_Identificador__c, CC_Caracteristica__r.RecordTypeId FROM CC_Caracteristica_Detalle__c 
                                                            WHERE (CC_Caracteristica__r.RecordTypeId = :RTCUENTACARACTERISTICA AND CC_Caracteristica__c = :caracteristicaId AND CC_Identificador__c IN :identificadores)
                                                               OR (CC_Caracteristica__r.RecordTypeId = :RTREPRESENTANTECARACTERISTICA AND CC_Caracteristica__c = :caracteristicaId AND SAC_Identificador__c IN :identificadores)];

        if(!listDetalles.isEmpty()){
            for(CC_Caracteristica_Detalle__c detalle : listDetalles){
                if(detalle.CC_Caracteristica__r.RecordTypeId == RTCUENTACARACTERISTICA){
                    log.add(detalle.CC_Identificador__c + '\tNOK\tEl identificador ya está registrado');
                    identificadores.remove(detalle.CC_Identificador__c);
                }else if(detalle.CC_Caracteristica__r.RecordTypeId == RTREPRESENTANTECARACTERISTICA){
                    log.add(detalle.SAC_Identificador__c + '\tNOK\tEl identificador ya está registrado');
                    identificadores.remove(detalle.SAC_Identificador__c);
                }
            }
        }
    }

    /** Nos quedamos sólo con los identificadores con formato de NIF */
    private static Map<String, CC_Caracteristica_Detalle__c> depurarClientesCuentas(Set<String> identificadores, Id caracteristicaId, List<String> log) {
        Map<String, CC_Caracteristica_Detalle__c> resultado = new Map<String, CC_Caracteristica_Detalle__c>();
        
        Map<String, Id> mapaIdentificadorCuenta = new Map<String, Id>();
        List<Account> clientes = [SELECT Id, CC_Numero_Documento__c FROM Account 
                                  WHERE (RecordTypeId = :RTCLIENTE OR RecordTypeId = :RTCLIENTE_PA OR RecordTypeId = :RTNOCLIENTE_PA)
                                  AND CC_Numero_Documento__c IN :identificadores];

        for (Account cliente : clientes) {
            mapaIdentificadorCuenta.put(cliente.CC_Numero_Documento__c, cliente.Id);
        }

        for (String identificador : identificadores) {
            if (validarDocumento(identificador)) {
                CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c();
                detalle.CC_Caracteristica__c = caracteristicaId;
                if (mapaIdentificadorCuenta.get(identificador) != null) {
                    detalle.SAC_Cuenta__c = mapaIdentificadorCuenta.get(identificador);
                    detalle.CC_Identificador__c = identificador;
                }
                else {
                    detalle.CC_Identificador__c = identificador;
                }
                resultado.put(identificador, detalle);
                log.add(identificador + '\tOK');
            }
            else {
                log.add(identificador + '\tNOK\tEl número de documento no tiene formato válido');
            }
        }

        return resultado;
    }

    /** Nos quedamos sólo con los identificadores no repetidos */
    private static Map<String, CC_Caracteristica_Detalle__c> depurarRepresentantes(Set<String> identificadores, Id caracteristicaId, List<String> log) {
        Map<String, CC_Caracteristica_Detalle__c> resultado = new Map<String, CC_Caracteristica_Detalle__c>();        

        for (String identificador : identificadores) {
            CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c();
            detalle.CC_Caracteristica__c = caracteristicaId;
            detalle.SAC_Identificador__c = identificador;
            
            resultado.put(identificador, detalle);
            log.add(identificador + '\tOK');
        }

        return resultado;
    }

    /** Validamos que el identificador tenga formato NIF/NIE/Pasaporte */
    private static Boolean validarDocumento(String documento) {
        return ((documento.length() == 9 || documento.length() == 10) && documento.isAlphanumeric());
    }

    private static String uploadLog (List<String> log) {
        String logString = '';
        for (String line : log) {
            logString += line + '\r\n';
        }
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Informe Carga Características ' + Datetime.now().format('dd-MM-yyyy HH:mm:ss'),
            PathOnClient = '/informe_carga_caracteristicas_' + Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.txt',
            VersionData = Blob.valueOf(logString),
            IsMajorVersion = true
        );
        // Database.insert(contentVersionInsert);
        SAC_DatabaseDML.insertDML(contentVersionInsert, true);

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionInsert.Id].ContentDocumentId;
        
        String logUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentId;
        return logUrl;
    }
}