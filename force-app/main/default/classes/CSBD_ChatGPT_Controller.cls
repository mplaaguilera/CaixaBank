public with sharing class CSBD_ChatGPT_Controller {

    @AuraEnabled
    public static string einsteinGPT(string pregunta, Id oppId){
        try {
            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.csbd_pregunta__c = pregunta;
            //opp.csbd_GptPreguntas__c = historico;
            if (Schema.sObjectType.Opportunity.isUpdateable() && Schema.sObjectType.Opportunity.fields.csbd_pregunta__c.isUpdateable()) {
                update opp;
            }
            return resolverPrompt(oppId, 'CSBD_ChatGPTOportunidad');

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //realizar el update despues de mostrar la respuesta
    @AuraEnabled
    public static void updateHistorico(Id oppId, string historico){
        try {
            Opportunity opp = new Opportunity();
            opp.Id = oppId;
            opp.CSBD_GptHistorico__c = historico;
            if (Schema.sObjectType.Opportunity.isUpdateable() && Schema.sObjectType.Opportunity.fields.CSBD_GptHistorico__c.isUpdateable()) {
                update opp;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //realizar el update despues de mostrar la respuesta
    @AuraEnabled
    public static string obtenerHistorico(Id oppId){
        try {
            return [SELECT Id, CSBD_GptHistorico__c FROM Opportunity WHERE Id = :oppId].CSBD_GptHistorico__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string resolverPrompt(string oppId, string apiPrompt) {
        try {
        //create input
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptGenerationsInput.isPreview = false;

            // Build input map
            Map<String,ConnectApi.WrappedValue> valueMap = new Map<String,ConnectApi.WrappedValue>();

            Map<String, String> opportunityRecordIdMap = new Map<String, String>();
            opportunityRecordIdMap.put('id', oppId);

            ConnectApi.WrappedValue recipientEntityWrappedValue = new ConnectApi.WrappedValue();
            recipientEntityWrappedValue.value = opportunityRecordIdMap;

            /*Map<String, String> senderEntityRecordIdMap = new Map<String, String>();
            senderEntityRecordIdMap.put('id', '005xx000001XiWLAA0');

            ConnectApi.WrappedValue recipientEntityWrappedValue = new ConnectApi.WrappedValue();
            recipientEntityWrappedValue.value = recipientEntityRecordIdMap;*/
            valueMap.put('Input:Opportunity', recipientEntityWrappedValue);

            promptGenerationsInput.inputParams = valueMap;

            promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

            // Call the service
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = 
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(apiPrompt, promptGenerationsInput);

            //Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = : oppId];
            //Opportunity opp = new opportunity();

            //puede devolver más de una response
            //opp.Id = oppId;
            //opp.CSBD_GptPreguntas__c = generationsProductOutput.generations[0].text;
            //update opp; aligerar la respuesta
            return generationsOutput.generations[0].text;
        } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string resolverPromptDinamico(string recordId, string apiPrompt, string valueKey) {
        try {
        //create input
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptGenerationsInput.isPreview = false;

            // Build input map
            Map<String,ConnectApi.WrappedValue> valueMap = new Map<String,ConnectApi.WrappedValue>();

            Map<String, String> opportunityRecordIdMap = new Map<String, String>();
            opportunityRecordIdMap.put('id', recordId);

            ConnectApi.WrappedValue recipientEntityWrappedValue = new ConnectApi.WrappedValue();
            recipientEntityWrappedValue.value = opportunityRecordIdMap;

            /*Map<String, String> senderEntityRecordIdMap = new Map<String, String>();
            senderEntityRecordIdMap.put('id', '005xx000001XiWLAA0');

            ConnectApi.WrappedValue recipientEntityWrappedValue = new ConnectApi.WrappedValue();
            recipientEntityWrappedValue.value = recipientEntityRecordIdMap;*/
            valueMap.put(valueKey, recipientEntityWrappedValue);

            promptGenerationsInput.inputParams = valueMap;

            promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

            // Call the service
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = 
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(apiPrompt, promptGenerationsInput);

            //Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = : oppId];
            //Opportunity opp = new opportunity();

            //puede devolver más de una response
            //opp.Id = oppId;
            //opp.CSBD_GptPreguntas__c = generationsProductOutput.generations[0].text;
            //update opp; aligerar la respuesta
            return generationsOutput.generations[0].text;
        } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
        }
    }

    //funcion para obtener metadata de configuración de prompts
    @AuraEnabled(cacheable=true)
    public static list<CSBD_AdministracionPromptsProductos__mdt> obtenerMetadataPrompts(string producto) {
        try {
            return [SELECT CSBD_EnviarAIA__c, CSBD_PromptArgumentarioAUtilizar__c, CSBD_PromptOportunidadAUtilizar__c, 
                    CSBD_PromptProductoAUtilizar__c, CSBD_PromptAmpliadaAUtilizar__c
                    FROM CSBD_AdministracionPromptsProductos__mdt WHERE MasterLabel = :producto WITH SECURITY_ENFORCED];
            
        } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
        }
    }

    //funcion para obtener el producto de la oportunidad para un lwc
    @AuraEnabled
    public static string obtenerProductoOportunidad(Id oppId) {
        try {
            return [SELECT Id, CSBD_Producto__c FROM Opportunity WHERE Id = :oppId].CSBD_Producto__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}