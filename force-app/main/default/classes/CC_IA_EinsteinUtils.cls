/* Name: CC_IA_EinsteinUtils
 * Copyright © 2024  CaixaBank
 * 
 * @description: Clase Utils para funciones auxiliares del proyecto de IA Generativa en CC 
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US1065178        Borja Lavesiera   14/11/24     Creación
*****************************************************************/
public with sharing class CC_IA_EinsteinUtils {
/* @description Método que obtiene los artículos de conocimiento relacionados con el canal de procedencia
     * @param canalProcedencia    canal de Procedencia del caso
     * @Autor: Borja Lavesiera Muñoz
     */

    private static final String VALIDATION_STATUS = 'Validated';
    private static final String PUBLISH_STATUS = 'Online';
    private static final String TIPO_CLIENTE = 'Cliente';
    private static final String LANGUAGE = 'es';
    private static final List<String> RECORD_TYPES = new List<String>{'CC_Ficha_Producto', 'CC_Informacion_General', 'CC_Pregunta_Respuesta', 'CC_Procedimiento'};
    
    public static List<Knowledge__kav> getKnowledgeArticles(String canalProcedencia) {
    //Parámetro dinámicos
    Map<String, Object> params = new Map<String, Object> {
        'canalProcedencia' => canalProcedencia,
        'tipoCliente' => TIPO_CLIENTE,
        'validationStatus' => VALIDATION_STATUS,
        'publishStatus' => PUBLISH_STATUS,
        'language' => LANGUAGE,
        'recordTypes' => RECORD_TYPES
    };
    // Construir consulta SOQL dinámica con parámetros
    String query = 'SELECT Id, Title, Answer__c, CC_IA_EtiquetadoGPT__c, CC_Canal_Resolucion__c ' +
        'FROM Knowledge__kav ' +
        'WHERE CC_Canal_Resolucion__c = :canalProcedencia ' +
        'AND CC_Tipo__c = :tipoCliente ' +
        'AND ValidationStatus = :validationStatus ' +
        'AND PublishStatus = :publishStatus ' +
        'AND IsLatestVersion = true ' +
        'AND IsVisibleInApp = true ' +
        'AND Language = :language ' +
        'AND RecordType.DeveloperName IN :recordTypes ';

    List<Knowledge__kav> articles = Database.queryWithBinds(query, params, AccessLevel.USER_MODE);

    Integer count = articles.size();

        return articles;
    }

    /**
     * @description         Genera la URL completa de un registro basado en su Id.
     * @param recordId Id del registro para el cual se desea generar la URL.
     * @return String URL completa hacia el registro.
     */
    @AuraEnabled
    public static String getRecordUrl(Id recordId) {
        // Obtener la URL base del dominio de la organización
        String fullRecordURL = URL.getOrgDomainURL().toExternalForm() + '/' + recordId;
 
        return fullRecordURL;
    }
    /**
     * @description Filtra los artículos obtenidos en función de las palabras en negrita extraídas del campo CC_Resumen_AI__c del caso.
     * @param resumenAI Resumen del caso que contiene palabras en negrita.
     * @param articles Lista de artículos de Knowledge__kav.
     * @return Lista de Knowledge__kav que cumplen con los criterios de filtro.
     * @Autor: Borja Lavesiera Muñoz
     */
    public static List<Knowledge__kav> filterArticles(String resumenAI, List<Knowledge__kav> articles) {
        if (String.isEmpty(resumenAI) || articles.isEmpty()) {
            return new List<Knowledge__kav>();
        }
        // Extraer palabras en negrita del resumen AI
        List<String> boldWordsList = extractBoldWords(resumenAI);

        if (boldWordsList.isEmpty()) {
            return new List<Knowledge__kav>();
        }

        // Normalizar las palabras a sus formas raíz
        List<String> normalizedBoldWords = normalizeWords(boldWordsList);

        List<Knowledge__kav> filteredArticles = new List<Knowledge__kav>();
        for (Knowledge__kav article : articles) {
            if (String.isEmpty(article.CC_IA_EtiquetadoGPT__c)) {
                continue;
            }

            // Normalizar las etiquetas de los artículos
            List<String> etiquetasGPT = normalizeWords(article.CC_IA_EtiquetadoGPT__c.split(';'));
            Boolean matchFound = false;

            for (String boldWord : normalizedBoldWords) {
                if (etiquetasGPT.contains(boldWord)) {
                    matchFound = true;
                    break;
                }
            }

            if (matchFound) {
                filteredArticles.add(article);
            }
        }

        return filteredArticles;
    }
    /**
     * @description         Extraer las etiquetas marcadas en negritas en campo Resumen_IA
     * @param resumenAI Resumen del caso que contiene palabras en negrita.
     * @return Lista de strings que cumplen con los criterios de filtro en lowercase.
     * @Autor: Borja Lavesiera Muñoz
     */
    private static List<String> extractBoldWords(String text) {
        List<String> boldWords = new List<String>();
        if (String.isEmpty(text)) {
            return boldWords;
        }

        Pattern boldPattern = Pattern.compile('<b>(.*?)</b>');
        Matcher matcher = boldPattern.matcher(text);
        while (matcher.find()) {
            boldWords.add(matcher.group(1).toLowerCase());
        }

        return boldWords;
    }
    /**
     * @description  Normalizamos las etiquetas a singular y lowercase para que funcione el contains.
     * @param Lista de Strings extraidas en negrita.
     * @return Lista de strings en singular y lowercase.
     * @Autor: Borja Lavesiera Muñoz
     */
    private static List<String> normalizeWords(List<String> words) {
        List<String> normalizedWords = new List<String>();
        for (String word : words) {
            if (word.endsWith('es')) {
                // Reemplazar "es" por "e"
                word = word.replaceAll('es$', 'e');
            } else if (word.endsWith('as')) {
                // Reemplazar "as" por "a"
                word = word.replaceAll('as$', 'a');
            } else if (word.endsWith('s')) {
                // Eliminar la "s" al final
                word = word.replaceAll('s$', '');
            }
            normalizedWords.add(word.toLowerCase());
        }
        return normalizedWords;
    }
    /**
     * @description         funcion para marcar el check de si cumple las condiciones para usar prompts IA,
     *                      que se usará durante la integración y el reporting del proyecto de IA Generativa en CC
     *                      Se llamará desde CC_Case_BI_TRHan
     *                      US1093307    26/11/2024    Borja Lavesiera
     * @param listNewObj    case que se va a insertar
     */
    public static void marcarCheckPromptSiCumple(Id caseExtensionId, String canalProcedencia, Id recordTypeId) {
        // Obtener configuraciones desde el Custom Setting
        List<CC_IA_Einstein_Config__c> configList = CC_IA_Einstein_Config__c.getAll().values();
        Set<String> canalesPermitidos = new Set<String>();

        for (CC_IA_Einstein_Config__c config : configList) {
            if (config.CC_IA_ON_OFF__c) {
                canalesPermitidos.add(config.CC_IA_Canal_de_Procedencia__c);
            }
        }

        Id caseClienteRT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                            .get('CC_Cliente').getRecordTypeId();

        if (recordTypeId == caseClienteRT && canalProcedencia != null && canalesPermitidos.contains(canalProcedencia)) {
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c(
                Id = caseExtensionId,
                CC_IA_Cumple_Condiciones_Prompts__c = true
            );
            saveRecords(new List<SObject>{ caseExtension }, false);
        }
    }
    /**
     * @description         Crea un registro en CBK_Case_Extension__c y devuelve su ID.
     * @return Id           ID del registro de CBK_Case_Extension__c creado.
     * @Autor: Borja Lavesiera Muñoz
     */
    public static Id createCaseExtensionRecord() {
        CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
        List<CBK_Case_Extension__c> caseExtensionInsert = new List<CBK_Case_Extension__c>{ caseExtension };

        if (!caseExtensionInsert.isEmpty()) {
            saveRecords(caseExtensionInsert, true);

            if (caseExtensionInsert[0].Id != null) {
                return caseExtensionInsert[0].Id;
            } else {
                return Id.valueOf('');
            }
        } else {
            // Devolver un Id vacío si la lista está vacía
            return Id.valueOf('');
        }
    }
    /**
     * @description Método para realizar operaciones de inserción o actualización de registros
     *              con manejo explícito de resultados y errores.
     * @param records Lista de registros a guardar.
     * @param isInsert Booleano que indica si la operación es INSERT (true) o UPDATE (false).
     * Notas: Duplicidad SaveResult to avoid QualityClouds issue.
     * @Autor: Borja Lavesiera Muñoz
     */
    public static void saveRecords(List<SObject> records, Boolean isInsert) {
        if (records == null || records.isEmpty()) {
            throw new IllegalArgumentException('La lista de registros no puede estar vacía o ser nula.');
        }
        try {
            if (isInsert) {
                // Operación de inserción con allOrNone configurado como false
                Database.SaveResult[] saveResults = Database.insert(records, false);

                // Manejar los resultados de la operación de inserción
                for (Database.SaveResult sr : saveResults) {
                    if (sr.isSuccess()) {
                        System.debug('Registro insertado correctamente: ' + sr.getId());
                    } else {
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('Error al insertar el registro: ' + err.getMessage());
                        }
                    }
                }
            } else {
                // Operación de actualización con allOrNone configurado como false
                Database.SaveResult[] saveResults = Database.update(records, false);

                // Manejar los resultados de la operación de actualización
                for (Database.SaveResult sr : saveResults) {
                    if (sr.isSuccess()) {
                        System.debug('Registro actualizado correctamente: ' + sr.getId());
                    } else {
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('Error al actualizar el registro: ' + err.getMessage());
                        }
                    }
                }
            }
        } catch (DmlException e) {
            System.debug('Error en la operación de DML: ' + e.getMessage());
            throw new AuraHandledException('Error al guardar los registros: ' + e.getMessage());
        }
    }      
}