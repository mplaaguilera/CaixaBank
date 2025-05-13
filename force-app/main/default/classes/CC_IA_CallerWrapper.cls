/*****************************************************************
 * Name: CC_IA_CallerWrapper
 * Copyright © 2024  CaixaBank
 * 
 * @description: Wrapper para centralizar las llamadas al LLM
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0                             Borja Lavesiera                Creación
*****************************************************************/
public with sharing class CC_IA_CallerWrapper {
    /**
     * @description     Ejecuta un prompt de IA para un registro de Caso específico.
     * @param objectIdsMap - Mapa de nombres de objetos y sus respectivos IDs.
     * @param promptTemplate - La plantilla de prompt que se utilizará.
     * @param freeText - Texto libre adicional para el prompt (opcional).
     * @return string generado como respuesta, o un string vacío si no hay respuesta disponible.
     */
    @TestVisible
    private static Exception testException;

    public String llmCaseCallerWrapper(Map<String, String> objectIdsMap, String promptTemplate, String freeText) {
        try {
            // Validar que los valores en objectIdsMap no sean null
            for (String key : objectIdsMap.keySet()) {
                if (objectIdsMap.get(key) == null) {
                    throw new IllegalArgumentException('El valor para ' + key + ' es null.');
                }
            }

            // Preparar la entrada para la generación del prompt
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput = createPromptInput(objectIdsMap, freeText);
            
            // Configuración adicional
            promptInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();

            // Llamar al servicio LLM
            
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = 
                ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(promptTemplate, promptInput);

            // Retornar el texto generado si está disponible, o vacío
            String result = (generationsOutput.generations.isEmpty()) ? '' : generationsOutput.generations.get(0).text;
            return result;

        } catch (Exception e) {
            testException = e;
            return '';
        }
    }

    /**
     * @description  Método auxiliar para crear la entrada del prompt con los nombres de objetos y sus respectivos IDs, y texto libre opcional.
     * @param freeText - Texto libre adicional para el prompt (opcional).
     * @return EinsteinPromptTemplateGenerationsInput.
     */
    private ConnectApi.EinsteinPromptTemplateGenerationsInput createPromptInput(Map<String, String> objectIdsMap, String freeText) {
        ConnectApi.EinsteinPromptTemplateGenerationsInput promptInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        promptInput.isPreview = false;

        // Configuración del mapa con los nombres de objetos y sus respectivos IDs
        Map<String, ConnectApi.WrappedValue> valueMap = new Map<String, ConnectApi.WrappedValue>();
        for (String objectName : objectIdsMap.keySet()) {
            ConnectApi.WrappedValue wrappedObjectId = new ConnectApi.WrappedValue();
            wrappedObjectId.value = new Map<String, String>{ 'id' => objectIdsMap.get(objectName) };
            valueMap.put('Input:' + objectName, wrappedObjectId);
        }

        // Agregar texto libre si no está vacío
        if (!String.isEmpty(freeText)) {
            ConnectApi.WrappedValue freeTextWrappedValue = new ConnectApi.WrappedValue();
            freeTextWrappedValue.value = freeText;
            valueMap.put('Input:My_Free_Text', freeTextWrappedValue);
        }

        promptInput.inputParams = valueMap;

        return promptInput;
    }
}