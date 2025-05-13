/* Name: CC_IA_KnowledgeArticlesChatGpt
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Clase que controla los artículos filtrados para su uso en el Chat Interactivo.
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US1065178        Borja Lavesiera   14/11/24     Creación
*****************************************************************/
public with sharing class CC_IA_KnowledgeArticlesChatGpt {
    public static final String NO_ARTICLES_FOUND_MESSAGE = 'No se han encontrado artículos relacionados.';

    @InvocableMethod(label='Buscar articulos Knowledge Chat GPT'
      description='Buscar los articulos relacionados con el canal de procedencia y el Resumen IA del caso.'
      CapabilityType='PromptTemplateType://einstein_gpt__recordSummary')
    public static List<Response> buscarArticulos(List<Request> requests) {

        if (requests.size() != 1){
            throw new ListException('La petición debe contener un solo elemento');
        }

        Case caso = requests[0].objectToSummarize;
        String responseData = '';
        String canalProcedencia = caso.CC_Canal_Procedencia__c;
        String resumenAI = caso.CC_Resumen_AI__c;

        if (canalProcedencia != null && resumenAI != null) {
            try {
                // Obtener artículos de conocimiento
                List<Knowledge__kav> articulosCaso = CC_IA_EinsteinUtils.getKnowledgeArticles(canalProcedencia);

                if (articulosCaso.isEmpty()) {
                    responseData = NO_ARTICLES_FOUND_MESSAGE;
                } else {
                    // Filtrar los artículos usando palabras en negrita Resumen IA
                    List<Knowledge__kav> filteredArticles = CC_IA_EinsteinUtils.filterArticles(resumenAI, articulosCaso);
                    if (filteredArticles.isEmpty()) {
                        responseData = NO_ARTICLES_FOUND_MESSAGE;
                    } else {
                        // Serializar los artículos filtrados en formato JSON
                        responseData = JSON.serialize(filteredArticles);
                    }
                }
            } catch (Exception e) {
                throw new AuraHandledException('Error al obtener artículos de conocimiento: ' + e.getMessage());
            }
        } else {
            responseData = NO_ARTICLES_FOUND_MESSAGE;
        }

        // Crear la respuesta
        List<Response> responses = new List<Response>();
        Response res = new Response();
        res.Prompt = responseData;
        responses.add(res);

        return responses;
    }

    public class Request {
        @InvocableVariable(required=true)
        public Case objectToSummarize;
    }

    public class Response {
        @InvocableVariable
        public String Prompt;
    }
}