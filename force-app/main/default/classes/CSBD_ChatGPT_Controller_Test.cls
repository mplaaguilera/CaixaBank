/*****************************************************************
 * Name: CSBD_ChatGPT_Controller_Test
 * Copyright © 2024  CaixaBank
 * 
 * Proposito: Testear el componente CSBD_ChatGPT_Controller_Test
 * 
 * Historial
 * -------
 * VERSION        USER_STORY       AUTHOR            DATE         Description
 * 1.0            US967512         David Ramos       08/08/24     Creación
*****************************************************************/
/**
 * @description     clase de test para el componente CSBD_ChatGPT_Controller_Test
 */
@isTest
public with sharing class CSBD_ChatGPT_Controller_Test {
    @TestSetup
    static void makeData(){
        User usuarioGeneral = CSBD_Usuarios.usuarioGestor(); //la funcion ya hace el insert

        List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name IN ('CSBD_PromptUser')];
        PermissionSet permiSet1 = permiSets[0];
        PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
        permiSetAssi.AssigneeId = usuarioGeneral.Id;
        permiSetAssi.PermissionSetId = permiSet1.Id;
        Database.insert(permiSetAssi);

        System.runAs(usuarioGeneral){
            //opportunity 1
            Map<String, Object> camposOppl = new Map<String, Object>();
            camposOppl.put('CSBD_Pregunta__c', 'pregunta');
            camposOppl.put('CSBD_GptHistorico__c', 'Historico original');
            camposOppl.put('CSBD_Producto__c', 'Producto test');
            CSBD_Opportunity.crearOportunidad('CSBD_CMB', camposOppl); //la funcion ya hace el insert
            
        }
    }

    @isTest
    static void einsteinGPTTest() {
        Opportunity opp = [SELECT Id, csbd_pregunta__c FROM Opportunity limit 1]; 
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        // //mock de ConnectApi 
        // String apiPrompt = 'CSBD_ChatGPTOportunidad';
        // ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        // promptGenerationsInput.isPreview = false;

        // // Build input map
        // Map<String,ConnectApi.WrappedValue> valueMap = new Map<String,ConnectApi.WrappedValue>();
        // Map<String, String> opportunityRecordIdMap = new Map<String, String>();
        // opportunityRecordIdMap.put('id', opp.id);

        // ConnectApi.WrappedValue recipientEntityWrappedValue = new ConnectApi.WrappedValue();
        // recipientEntityWrappedValue.value = opportunityRecordIdMap;
        // valueMap.put('Input:Opportunity', recipientEntityWrappedValue);

        // promptGenerationsInput.inputParams = valueMap;

        // promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        // promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

        // // Call the service
        // ConnectApi.EinsteinPromptTemplateGenerationsRepresentation mockGenerationsOutput = 
        // new ConnectApi.EinsteinPromptTemplateGenerationsRepresentation();
        // //ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(apiPrompt, promptGenerationsInput);

        // //Mock response
        // mockGenerationsOutput.generations = new List<ConnectApi.EinsteinLLMGenerationItemOutput>();
        // ConnectApi.EinsteinLLMGenerationItemOutput output = new ConnectApi.EinsteinLLMGenerationItemOutput();
        // output.text = 'response';
        // mockGenerationsOutput.generations.add(output);

        // ConnectApi.EinsteinLLM.setTestGenerateMessagesForPromptTemplate(apiPrompt, promptGenerationsInput, mockGenerationsOutput);

        STring respuesta = 'no ha respondido';
        //ConnectApi.EinsteinLLM no tiene setTest 
        AuraHandledException exc;
        System.runAs(usuario){
            Test.startTest();
            try{
                respuesta = CSBD_ChatGPT_Controller.einsteinGPT(opp.csbd_pregunta__c, opp.Id);
            }
            catch(AuraHandledException auraExc){
                exc = auraExc;
            }
            Test.stopTest();
        }
        System.assertEquals('Script-thrown exception', exc.getMessage(),'La respuesta no se obtiene correctamente');
    }

    @isTest
    static void updateHistoricoTest() {
        Opportunity opp = [SELECT Id, CSBD_GptHistorico__c FROM Opportunity limit 1]; 
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        STring nuevoValor = 'Nuevo Historico';

        System.runAs(usuario){
            Test.startTest();
            CSBD_ChatGPT_Controller.updateHistorico(opp.Id, nuevoValor);
            Test.stopTest();
        }
        Opportunity oppRefrescada = [SELECT Id, CSBD_GptHistorico__c FROM Opportunity limit 1];
        System.assertEquals(nuevoValor, (String)oppRefrescada.CSBD_GptHistorico__c,'El update no se hace correctamente');
    }

    @isTest
    static void obtenerHistoricoTest() {
        Opportunity opp = [SELECT Id, CSBD_GptHistorico__c FROM Opportunity limit 1]; 
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        STring resultado = '';

        System.runAs(usuario){
            Test.startTest();
            resultado = CSBD_ChatGPT_Controller.obtenerHistorico(opp.Id);
            Test.stopTest();
        }
        String resultadoEsperado = 'Historico original';
        System.assertEquals(resultadoEsperado, resultado, 'El Historico no se obtiene correctamente');
    }

    @isTest
    static void resolverPromptDinamicoTest() {
        Opportunity opp = [SELECT Id, csbd_pregunta__c FROM Opportunity limit 1]; 
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];
        string apiPrompt = 'CSBD_Analisis_Sentimiento';
        string valueKey = 'input:LiveChatTranscript';

        STring respuesta = 'no ha respondido';
        //ConnectApi.EinsteinLLM no tiene setTest  
        AuraHandledException exc;
        System.runAs(usuario){
            Test.startTest();
            try{
                respuesta = CSBD_ChatGPT_Controller.resolverPromptDinamico(opp.Id, apiPrompt, valueKey);
            }
            catch(AuraHandledException auraExc){
                exc = auraExc;
            }
            Test.stopTest();
        }
        System.assertEquals('Script-thrown exception', exc.getMessage(),'La respuesta no se obtiene correctamente');
    }

    @isTest
    static void obtenerMetadataPromptsTest() {
        String producto = 'MyBox Auto';
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        list<CSBD_AdministracionPromptsProductos__mdt> resultado = new list<CSBD_AdministracionPromptsProductos__mdt>();

        System.runAs(usuario){
            Test.startTest();
            resultado = CSBD_ChatGPT_Controller.obtenerMetadataPrompts(producto);
            Test.stopTest();
        }
        String resultadoEsperado = 'CSBD_ResumenOportunidad';
        System.assertEquals(resultadoEsperado, resultado[0].CSBD_PromptOportunidadAUtilizar__c, 'El metadato no se obtiene correctamente');
    }

    @isTest
    static void obtenerProductoOportunidadTest() {
        Opportunity opp = [SELECT Id, csbd_pregunta__c, CSBD_Producto__c FROM Opportunity limit 1]; 
        
        User usuario = [SELECT id FROM User WHERE FirstName = 'GestorCSBD' AND isActive = true Limit 1];

        String resultado = '';

        System.runAs(usuario){
            Test.startTest();
            resultado = CSBD_ChatGPT_Controller.obtenerProductoOportunidad(opp.Id);
            Test.stopTest();
        }
        String resultadoEsperado = opp.CSBD_Producto__c;
        System.assertEquals(resultadoEsperado, resultado, 'El producto no se obtiene correctamente');
    }
}