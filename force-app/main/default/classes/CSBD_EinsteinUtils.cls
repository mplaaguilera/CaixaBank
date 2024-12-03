/*****************************************************************
 * Name: CSBD_EinsteinUtils
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Funciones para el proyecto de IA Generativa en CSBD que se llamarán desde triggers
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US977987         David Ramos       19/08/24     Creación
*****************************************************************/
/**
 * @description     Funciones para el proyecto de IA Generativa en CSBD que se llamarán desde triggers
 */
public with sharing class CSBD_EinsteinUtils {
    /**
     * @description         funcion para marcar el check de si cumple las condiciones para usar prompts IA,
     *                      que se usará durante la integración y el reporting del proyecto de IA Generativa en CSBD
     *                      Se llamará desde CC_Opportunity_BI_TRHan
     *                      US967512    07/08/2024    David Ramos
     * @param listNewObj    oportunidades que se van a insertar
     */
    public static void marcarCheckPromptSiCumple(List<Opportunity> listNewObj) {
        //obtener los metadatos primero para no hacer la query dentro del bucle
        Map<String,ContenidoMetadata> mapMetadataPermiteIA = new Map<String,ContenidoMetadata>();
        CSBD_AdministracionPromptsProductos__mdt[] listaMetadata = [SELECT MasterLabel, CSBD_EnviarAIA__c, CSBD_PromptArgumentarioAUtilizar__c ,CSBD_PromptOportunidadAUtilizar__c, CSBD_PromptProductoAUtilizar__c FROM CSBD_AdministracionPromptsProductos__mdt WITH SECURITY_ENFORCED];
        for (CSBD_AdministracionPromptsProductos__mdt  metadataProd : listaMetadata) {
            //si no se puede utilizar para envia a IA no se van a utilizar los demas campos del metadato,
            //por lo que actuaría igual que si no estuviese en el map
            if(metadataProd.CSBD_EnviarAIA__c){
                ContenidoMetadata contenido = new ContenidoMetadata();
                contenido.promptOportunidadAUtilizar = metadataProd.CSBD_PromptOportunidadAUtilizar__c;
                contenido.promptProductoAUtilizar = metadataProd.CSBD_PromptProductoAUtilizar__c;
                contenido.promptArgumentarioAUtilizar = metadataProd.CSBD_PromptArgumentarioAUtilizar__c;

                mapMetadataPermiteIA.put(metadataProd.MasterLabel, contenido);
            }
        }
        //recorrer cada oportunidad para ver si cumple las condiciones
        Id cmbRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_CMB').getRecordTypeId();
        Id cmnRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_CMN').getRecordTypeId();
        //para que tambien se pueda en los chatTranscripts se añade el recordType 
        //que usan sus oportunidades al crearlas con el otp
        Id chatRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_Chat').getRecordTypeId();
        //para que tambien se pueda en los cdp se añade el recordType 
        Id cdpRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('CSBD_PROAutomatica').getRecordTypeId();
        for (Opportunity opo : listNewObj){
            if((opo.recordTypeId == cmbRT || opo.recordTypeId == cmnRT || opo.recordTypeId == chatRT || opo.recordTypeId == cdpRT) 
                && opo.CSBD_Producto__c != null
                && mapMetadataPermiteIA.get(opo.CSBD_Producto__c) != null){
                //cumple las condiciones para lanzar prompts
                opo.CSBD_CumpleCondicionesPrompts__c = true;
            }
        }
    }

    /**
     * @description         funcion para marcar el check de si ha usado los prompts de IA
     *                      que se usará durante la integración y el reporting del proyecto de IA Generativa en CSBD
     *                      y para lanzar el prompt del resumen de cierre si se está cerrando la oportunidad.
     *                      Se llamará desde CC_Opportunity_AU_TRHan
     *                      US977987    07/08/2024    David Ramos
     * @param listNewObj    oportunidades con las modificaciones que se van a hacer
     * @param mapOldObj     oportunidades antes de las modificaciones que se van a hacer
     */
    //funcion que se utilizará en CC_Opportunity_AU_TRHan
    public static void comprobarUsoPromptsYResumenCierre(List<Opportunity> listNewObj, Map<Id, Opportunity> mapOldObj) {
        List<Opportunity> oportunidadesActualizar = new List<Opportunity>();
        for (Opportunity oportunidad : listNewObj) {
            Opportunity oldOportunidad = mapOldObj.get(oportunidad.Id);
            Opportunity oportunidadNueva = new Opportunity();
            oportunidadNueva.Id = oportunidad.Id;
            //si ha entrado en la funcion es que el usuario tiene permiso para lanzar prompts, comprobar las otras condiciones
            if(oportunidad.CSBD_CumpleCondicionesPrompts__c
                && oportunidad.StageName != oldOportunidad.StageName && (oportunidad.StageName == 'Formalizada' || oportunidad.StageName == 'Perdida' )){
                
                Map<String, String> property = new Map<String, String>();
                property.put('id', oportunidad.Id); // Don't need to pass other field values even if referenced in the template, just the Id
                ConnectApi.WrappedValue propertyValue = new ConnectApi.WrappedValue();
                propertyValue.value = property;
                Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
                inputParams.put('Input:Opportunity', propertyValue); // Property is the API Name we gave to the input
               
                ConnectApi.EinsteinPromptTemplateGenerationsInput executeTemplateInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
                executeTemplateInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
                executeTemplateInput.additionalConfig.applicationName = 'PromptBuilderPreview';
                executeTemplateInput.isPreview = false;
                executeTemplateInput.inputParams = inputParams;
               
                ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(
                   'CSBD_ResumenOportunidadCierre',
                   executeTemplateInput
                );
                //Respuesta: createOpportunityAndLineItems(generationsOutput.generations[0].text)

                oportunidadNueva.CSBD_ResumenCierre__c = generationsOutput.generations[0].text;

                //añadir la comprobación de si ha utilizado prompts
                if(!oportunidad.CSBD_HaUsadoIA__c
                    && (oportunidad.CSBD_GptResumenInicialRich__c != null 
                        || oportunidad.CSBD_GptResumenProducto__c != null
                        || oportunidad.CSBD_CondicionesPromos__c != null)){
                        oportunidadNueva.CSBD_HaUsadoIA__c = true;
                }

                oportunidadesActualizar.add(oportunidadNueva);
           }
           //para ver si antes del momento de cierre se habia usado los resumenes generados por IA en algun momento,
           //aprovechando que el usuario actual tiene permisos
           else if (!oportunidad.CSBD_HaUsadoIA__c
                && (oportunidad.CSBD_GptResumenInicialRich__c != null 
                    || oportunidad.CSBD_GptResumenProducto__c != null
                    || oportunidad.CSBD_CondicionesPromos__c != null)){
                        
                oportunidadNueva.CSBD_HaUsadoIA__c = true;
                oportunidadesActualizar.add(oportunidadNueva);
           }
       }
       if(!oportunidadesActualizar.isEmpty() && Schema.sObjectType.Opportunity.isUpdateable()){
            update oportunidadesActualizar;
       }  
    }
    
    public class ContenidoMetadata{
        String promptOportunidadAUtilizar;
        String promptProductoAUtilizar;
        String promptArgumentarioAUtilizar;
    }
}