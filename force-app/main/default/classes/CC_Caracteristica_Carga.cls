public with sharing class CC_Caracteristica_Carga {

    private static Id empleadoCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(); 
    private static Id clienteContactoCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Contacto').getRecordTypeId(); 
    private static Id clienteCuentaCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente_Cuenta').getRecordTypeId(); 
    private static Id centroCaracteristicaRecordTypeId = Schema.getGlobalDescribe().get('CC_Caracteristica__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Centro_CaixaBank').getRecordTypeId(); 

    private static Id empleadoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(); 
    private static Id clienteContactoRecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(); 
    private static Id clienteCuentaRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(); 
    private static Id clienteCuentaRecordTypePAId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
    private static Id centroRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId(); 

    @AuraEnabled
    public static void deleteFile(String contentDocumentId) {
        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];
        delete contentDocumentList;
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

        // Eliminamos identificadores duplicados
        // Adaptamos código debido a que tras la encriptacion no se permite buscar por el campo formula
        /*List<CC_Caracteristica_Detalle__c> oCarDetail = [SELECT CC_Identificador_Formula__c, CC_Cuenta__c, CC_Cliente__c, CC_Centro_CaixaBank__c, CC_Empleado__c 
                                                         FROM CC_Caracteristica_Detalle__c 
                                                         WHERE CC_Caracteristica__c = :caracteristicaId];
        if(!oCarDetail.isEmpty()){
            for (CC_Caracteristica_Detalle__c oCdetalle : oCarDetail) {
                if(oCdetalle.CC_Cuenta__c != null){
            		for (CC_Caracteristica_Detalle__c detalle : [SELECT CC_Identificador_Formula__c 
                                                     FROM CC_Caracteristica_Detalle__c 
                                                     WHERE CC_Caracteristica__c = :caracteristicaId AND CC_Cuenta__r.CC_Numero_Documento__c IN :identificadores]) {
                        log.add(detalle.CC_Identificador_Formula__c + '\tNOK\tEl identificador ya está registrado');
                        identificadores.remove(detalle.CC_Identificador_Formula__c);
                    }
                }else if(oCdetalle.CC_Cliente__c != null){
                    for (CC_Caracteristica_Detalle__c detalle : [SELECT CC_Identificador_Formula__c 
                                                     FROM CC_Caracteristica_Detalle__c 
                                                     WHERE CC_Caracteristica__c = :caracteristicaId AND CC_Cliente__r.CC_Numero_Documento__c IN :identificadores]) {
                        log.add(detalle.CC_Identificador_Formula__c + '\tNOK\tEl identificador ya está registrado');
                        identificadores.remove(detalle.CC_Identificador_Formula__c);
                    }
                }else if(oCdetalle.CC_Centro_CaixaBank__c != null){
                    for (CC_Caracteristica_Detalle__c detalle : [SELECT CC_Identificador_Formula__c 
                                                     FROM CC_Caracteristica_Detalle__c 
                                                     WHERE CC_Caracteristica__c = :caracteristicaId 
                                                     AND CC_Centro_CaixaBank__r.CC_Numero_Oficina_Empresa__c IN :identificadores]) {
                        log.add(detalle.CC_Identificador_Formula__c + '\tNOK\tEl identificador ya está registrado');
                        identificadores.remove(detalle.CC_Identificador_Formula__c);
                    }
                }else if(oCdetalle.CC_Empleado__c != null){
                    for (CC_Caracteristica_Detalle__c detalle : [SELECT CC_Identificador_Formula__c 
                                                     FROM CC_Caracteristica_Detalle__c 
                                                     WHERE CC_Caracteristica__c = :caracteristicaId AND CC_Empleado__r.CC_Matricula__c IN :identificadores]) {
                        log.add(detalle.CC_Identificador_Formula__c + '\tNOK\tEl identificador ya está registrado');
                        identificadores.remove(detalle.CC_Identificador_Formula__c);
                    }
                }else{
                    for (CC_Caracteristica_Detalle__c detalle : [SELECT CC_Identificador_Formula__c 
                                                     FROM CC_Caracteristica_Detalle__c 
                                                     WHERE CC_Caracteristica__c = :caracteristicaId AND CC_Identificador__c  IN :identificadores]) {
                        log.add(detalle.CC_Identificador_Formula__c + '\tNOK\tEl identificador ya está registrado');
                        identificadores.remove(detalle.CC_Identificador_Formula__c);
                    }
                }
       		}
        }*/
        
        for (CC_Caracteristica_Detalle__c detalle : [SELECT CC_Identificador_Formula__c, CC_Identificador__c 
                                                     FROM CC_Caracteristica_Detalle__c 
                                                     WHERE CC_Caracteristica__c = :caracteristicaId AND CC_Identificador__c IN :identificadores]) {
            log.add(detalle.CC_Identificador__c + '\tNOK\tEl identificador ya está registrado');
            identificadores.remove(detalle.CC_Identificador__c);
        }

        // Depuramos los identificadores
        if (caracteristica.RecordTypeId == empleadoCaracteristicaRecordTypeId) {
                mapaIdentificadorDetalle = depurarEmpleados(identificadores, caracteristica.Id, log);
        } 
        else if (caracteristica.RecordTypeId == clienteContactoCaracteristicaRecordTypeId) {
                mapaIdentificadorDetalle = depurarClientesContactos(identificadores, caracteristica.Id, log);
        } 
        else if (caracteristica.RecordTypeId == clienteCuentaCaracteristicaRecordTypeId) {
                mapaIdentificadorDetalle = depurarClientesCuentas(identificadores, caracteristica.Id, log);
        } 
        else if (caracteristica.RecordTypeId == centroCaracteristicaRecordTypeId) {
                mapaIdentificadorDetalle = depurarCentros(identificadores, caracteristica.Id, log);
        }

        // Insertamos en Característica Detalle
        if (mapaIdentificadorDetalle.values().size()>0) {
            insert mapaIdentificadorDetalle.values();
        }
        
        // Obtenemos la lista de ids de detalle insertados
        Set<Id> detalleIds = new Set<Id>();
        for(CC_Caracteristica_Detalle__c detalle : mapaIdentificadorDetalle.values()) {
            detalleIds.add(detalle.Id);
        }
        
        deleteFile(contentDocumentId);

        // Subimos el fichero de log y obtenemos su enlace
        String logUrl = uploadLog(log);

        return logUrl;
    }
    
    /** Nos quedamos sólo con los identificadores de empleado que existan en Salesforce
        Ya de paso nos guardamos el id del empleado */
    private static Map<String, CC_Caracteristica_Detalle__c> depurarEmpleados(Set<String> identificadores, Id caracteristicaId, List<String> log) {
        Map<String, CC_Caracteristica_Detalle__c> resultado = new Map<String, CC_Caracteristica_Detalle__c>();
        List<Contact> empleados = [SELECT Id, CC_Matricula__c FROM Contact WHERE RecordTypeId = :empleadoRecordTypeId AND CC_Matricula__c IN :identificadores];
        for (Contact empleado : empleados) {
            CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c();
            detalle.CC_Caracteristica__c = caracteristicaId;
            detalle.CC_Empleado__c = empleado.Id;
            resultado.put(empleado.CC_Matricula__c, detalle);           
        }

        for (String identificador : identificadores) {
            if (resultado.get(identificador) != null) {
                log.add(identificador + '\tOK');
            }
            else {
                if (validarMatricula(identificador)) {
                    log.add(identificador + '\tNOK\tLa matrícula no tiene ningún empleado asociado');
                }
                else {
                    log.add(identificador + '\tNOK\tLa matrícula no tiene un formato válido');
                }
            }
        }

        return resultado;
    }
    
    /** Nos quedamos sólo con los identificadores con formato de NIF */
    private static Map<String, CC_Caracteristica_Detalle__c> depurarClientesContactos(Set<String> identificadores, Id caracteristicaId, List<String> log) {
        Map<String, CC_Caracteristica_Detalle__c> resultado = new Map<String, CC_Caracteristica_Detalle__c>();
        
        Map<String, Id> mapaIdentificadorContacto = new Map<String, Id>();
        List<Contact> clientes = [SELECT Id, CC_Numero_Documento__c, CC_Identificador__c 
                                  FROM Contact 
                                  WHERE (RecordTypeId = :clienteContactoRecordTypeId OR (RecordTypeId = null AND AccountId <> null AND Account.RecordTypeId = :clienteCuentaRecordTypePAId))
                                  AND CC_Numero_Documento__c IN :identificadores];
        for (Contact cliente : clientes) {
            mapaIdentificadorContacto.put(cliente.CC_Numero_Documento__c, cliente.Id);
        }
        
        for (String identificador : identificadores) {
            if (validarDocumento(identificador)) {
                CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c();
                detalle.CC_Caracteristica__c = caracteristicaId;
                if (mapaIdentificadorContacto.get(identificador) != null) {
                    detalle.CC_Cliente__c = mapaIdentificadorContacto.get(identificador);
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
    
    /** Nos quedamos sólo con los identificadores de empleado que existan en Salesforce, ya de paso nos guardamos el id del centro */
    private static Map<String, CC_Caracteristica_Detalle__c> depurarCentros(Set<String> identificadores, Id caracteristicaId, List<String> log) {
        Map<String, CC_Caracteristica_Detalle__c> resultado = new Map<String, CC_Caracteristica_Detalle__c>();
        List<Account> centros = [SELECT Id, CC_Numero_Oficina_Empresa__c, CC_Identificador__c
                                 FROM Account WHERE RecordTypeId = :centroRecordTypeId AND CC_Numero_Oficina_Empresa__c IN :identificadores];
        for (Account centro : centros) {
            CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c();
            detalle.CC_Caracteristica__c = caracteristicaId;
            detalle.CC_Centro_CaixaBank__c = centro.Id;
            resultado.put(centro.CC_Numero_Oficina_Empresa__c, detalle);           
        }

        for (String identificador : identificadores) {
            if (resultado.get(identificador) != null) {
                log.add(identificador + '\tOK');
            }
            else {
                if (validarNumeroOficinaEmpresa(identificador)) {
                    log.add(identificador + '\tNOK\tEl número de oficina-empresa no tiene ningún centro asociado');
                }
                else {
                    log.add(identificador + '\tNOK\tEl número de oficina-empresa no tiene un formato válido');
                }
            }
        }

        return resultado;
    }
    
    /** Nos quedamos sólo con los identificadores con formato de NIF */
    private static Map<String, CC_Caracteristica_Detalle__c> depurarClientesCuentas(Set<String> identificadores, Id caracteristicaId, List<String> log) {
        Map<String, CC_Caracteristica_Detalle__c> resultado = new Map<String, CC_Caracteristica_Detalle__c>();
        
        Map<String, Id> mapaIdentificadorCuenta = new Map<String, Id>();
        List<Account> clientes = [SELECT Id, CC_Numero_Documento__c FROM Account 
                                  WHERE (RecordTypeId = :clienteCuentaRecordTypeId OR RecordTypeId = :clienteCuentaRecordTypePAId)
                                  AND CC_Numero_Documento__c IN :identificadores];
        for (Account cliente : clientes) {
            mapaIdentificadorCuenta.put(cliente.CC_Numero_Documento__c, cliente.Id);
        }

        for (String identificador : identificadores) {
            if (validarDocumento(identificador)) {
                CC_Caracteristica_Detalle__c detalle = new CC_Caracteristica_Detalle__c();
                detalle.CC_Caracteristica__c = caracteristicaId;
                if (mapaIdentificadorCuenta.get(identificador) != null) {
                    detalle.CC_Cuenta__c = mapaIdentificadorCuenta.get(identificador);
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
    
    /** Validamos que el identificador tenga formato NIF/NIE/Pasaporte */
    private static Boolean validarDocumento(String documento) {
        return ((documento.length() == 9 || documento.length() == 10) && documento.isAlphanumeric());
    }
    
    private static Boolean validarNumeroOficinaEmpresa(String numero) {
        return (numero.length() == 9) && (numero.substring(0, 5).isNumeric()) && (numero.substring(5,6) == '-') && (numero.substring(6,9).isNumeric());
    }
    
    private static Boolean validarMatricula(String matricula) {
        return (matricula.length() == 8) && (matricula.substring(0, 3) == 'U01') && (matricula.substring(3, 8).isNumeric());
    }

    private static String uploadLog (List<String> log) {
        String logString = '';
        for (String line : log) {
            logString += line + '\r\n';
        }
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Informe Carga Características '+Datetime.now().format('yyyy-MM-dd HH:mm:ss'),
            PathOnClient = '/informe_carga_caracteristicas_'+Datetime.now().format('yyyy-MM-dd HH:mm:ss')+'.txt',
            VersionData = Blob.valueOf(logString),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionInsert.Id].ContentDocumentId;
        
        String logUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/document/download/' + contentDocumentId;
        return logUrl;
    }
    
}