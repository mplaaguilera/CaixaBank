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
            List<CSBD_AdministracionPromptsProductos__mdt> promptProductosList = new List<CSBD_AdministracionPromptsProductos__mdt>();
            promptProductosList = [SELECT CSBD_EnviarAIA__c, CSBD_PromptArgumentarioAUtilizar__c, CSBD_PromptOportunidadAUtilizar__c, 
                                    CSBD_PromptProductoAUtilizar__c, CSBD_PromptAmpliadaAUtilizar__c, CSBD_ArticulosPorPrompt__c,
                                    CSBD_BusquedaEnDosPasos__c, CSBD_PromptAsistenteAUtilizar__c, CSBD_PromptComparadorAUtilizar__c
                                    FROM CSBD_AdministracionPromptsProductos__mdt WHERE MasterLabel = :producto WITH SECURITY_ENFORCED];
            if(!promptProductosList.isEmpty()){
                return promptProductosList;
            }else{
                return null;
            }
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


    @AuraEnabled
    public static string flexPromptInfoAdicional(string oppId, string pregunta, integer numero) {
        try {
            //extraer inputs, combinados para evitar tener mas de 3 parametros en una funcion.
            //el prompt y la cantidad por prompt se podria poner en el metadato
            string apiPrompt = 'CSBD_GPTchatTextoLibre2';

        //create input
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptGenerationsInput.isPreview = false;

            opportunity opp = [SELECT Id, CSBD_Producto__c FROM Opportunity WHERE Id = : oppId LIMIT 1];
            //aqui tendria que hacer una division por 10 para obtener el numero de articulos por prompt y restar para añadir el resto
            //divido por ejemplo 16 entre 10 y me da 1,6, quiere decir que 6 envios iran con un articulo mas. si el "numero" de input
            // lo divido entre 10, le sumo el entero sin decimales de la division, si el número es menor que la division le añado 1 articulo
            list<CSBD_AdministracionPromptsProductos__mdt> metadato = obtenerMetadataPrompts(opp.CSBD_Producto__c);
            integer articulosPorPrompt = Integer.ValueOf(metadato[0].CSBD_ArticulosPorPrompt__c);
            integer primerArticulo = numero*articulosPorPrompt;


            Id infoAdicionalProductoRT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CSBD_Informacion_adicional_de_producto').getRecordTypeId();
            //hacer que coja solo los articulos que se van a utilizar con limit y offset
            //descartar las fichas producto porque se cogeran en la otra funcion.
            //List<Knowledge__kav> articulosProducto =
                // [SELECT Id, Title, Question__c, Answer__c, CSBD_NombresProductos__c
                //     FROM Knowledge__kav
                //     WHERE CSBD_NombresProductos__c INCLUDES (:opp.CSBD_Producto__c) AND PublishStatus = 'Online' AND RecordTypeId != :fichaProductoRT WITH SECURITY_ENFORCED ORDER BY ID ASC LIMIT :articulosPorPrompt OFFSET :primerArticulo];
                List<Knowledge__kav> articulosProducto =
                [SELECT Id, Title, Question__c, Answer__c, CSBD_NombresProductos__c
                    FROM Knowledge__kav
                    WHERE CSBD_NombresProductos__c INCLUDES (:opp.CSBD_Producto__c) AND PublishStatus = 'Online' AND RecordTypeId = :infoAdicionalProductoRT WITH SECURITY_ENFORCED ORDER BY ID ASC LIMIT :articulosPorPrompt OFFSET :primerArticulo];
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

            ConnectApi.WrappedValue strWrappedValue = new ConnectApi.WrappedValue();
            // List<Knowledge__kav> sublistaArticulosProducto = new List<Knowledge__kav>();
            // for (integer i = 0; i<articulosPorPrompt; i++){
            //     if (numero*articulosPorPrompt+i < articulosProducto.size()){
            //         sublistaArticulosProducto.add(articulosProducto.get(numero*articulosPorPrompt+i));
            //     }
            // }
            if (articulosProducto.isEmpty()){
                //si no coge ningun articulo porque el iterador que recibe como input se pasa de la cantidad que hay, no lanzar prompts
                //devolver directamente un mensaje de que no está
                
                return '{"encontrado": false,"irrelevante": false,"respuesta": "No hay mas documentos. Esta información no está específicamente informada en la documentación."}';
            }
            //montar un for que concatene answers dependiendo del numero de pages que tenga que ir
            string textoConcatenado = '';
            // for (integer i = 0; i<articulosProducto.size(); i++){
            //     textoConcatenado += articulosProducto.get(i).Answer__c;
            // }
            for (Knowledge__kav articulo : articulosProducto){
                textoConcatenado += articulo.Answer__c;
            }
            strWrappedValue.value = JSON.serialize(textoConcatenado);
            valueMap.put('Input:InfoProducto', strWrappedValue);

            ConnectApi.WrappedValue strWrappedValue2 = new ConnectApi.WrappedValue();
            strWrappedValue2.value = pregunta;

            valueMap.put('Input:preguntaGTP', strWrappedValue2);
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
            return generationsOutput.generations[0].text; //generationsOutput.prompt;
        } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string flexPromptFichas(string oppId, string pregunta) {
        try {
            //extraer inputs, combinados para evitar tener mas de 3 parametros en una funcion.
            //el prompt y la cantidad por prompt se podria poner en el metadato
            string apiPrompt = 'CSBD_GPTchatTextoLibre2';

        //create input
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptGenerationsInput.isPreview = false;

            opportunity opp = [SELECT Id, CSBD_Producto__c FROM Opportunity WHERE Id = : oppId LIMIT 1];

            list<CSBD_AdministracionPromptsProductos__mdt> metadato = obtenerMetadataPrompts(opp.CSBD_Producto__c);
            integer articulosPorPrompt = Integer.ValueOf(metadato[0].CSBD_ArticulosPorPrompt__c);

            Id fichaProductoRT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CSBD_Ficha_de_producto').getRecordTypeId();
            //hacer que coja solo los articulos que se van a utilizar con limit
            List<Knowledge__kav> articulosProducto =
                [SELECT Id, Title, Question__c, Answer__c, CSBD_NombresProductos__c
                    FROM Knowledge__kav
                    WHERE CSBD_NombresProductos__c INCLUDES (:opp.CSBD_Producto__c) AND PublishStatus = 'Online' AND RecordTypeId = :fichaProductoRT  WITH SECURITY_ENFORCED ORDER BY ID ASC LIMIT :articulosPorPrompt];
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

            ConnectApi.WrappedValue strWrappedValue = new ConnectApi.WrappedValue();
            // List<Knowledge__kav> sublistaArticulosProducto = new List<Knowledge__kav>();
            // for (integer i = 0; i<articulosPorPrompt; i++){
            //     if (numero*articulosPorPrompt+i < articulosProducto.size()){
            //         sublistaArticulosProducto.add(articulosProducto.get(numero*articulosPorPrompt+i));
            //     }
            // }
            if (articulosProducto.isEmpty()){
                //si no coge ningun articulo porque el iterador que recibe como input se pasa de la cantidad que hay, no lanzar prompts
                //devolver directamente un mensaje de que no está
                
                //por ahora uso el campo irrelevante para que no haga el segundo paso, a futuro habria que crearle un campo propio
                return '{"encontrado": false,"irrelevante": true,"respuesta": "No hay ficha del producto. No puedo responder a la pregunta"}';
            }
            strWrappedValue.value = JSON.serialize(articulosProducto);
            valueMap.put('Input:InfoProducto', strWrappedValue);

            ConnectApi.WrappedValue strWrappedValue2 = new ConnectApi.WrappedValue();
            strWrappedValue2.value = pregunta;

            valueMap.put('Input:preguntaGTP', strWrappedValue2);
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
            return generationsOutput.generations[0].text; //generationsOutput.prompt;
        } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
        }
    }

    //obtener la cantidad de artículos asignados a un producto
    @AuraEnabled(cacheable=true)
    public static integer obtenerCantidadArticulosProducto(string producto) {
        try {
            /*opportunity opp = new opportunity();
            opp.CSBD_Producto__c = producto;
            Id fichaProductoRT = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Ficha_Producto').getRecordTypeId();*/
            return [SELECT count() FROM Knowledge__kav WHERE CSBD_NombresProductos__c INCLUDES (:producto) AND PublishStatus = 'Online' WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //obtener los productos que se pueden comparar con el proporcionado
    //como se tiene que recorrer la lista igualmente devuelvo el objeto en si en vez de extraer el campo en otra lista
    @AuraEnabled(cacheable=true)
    public static list<CBK_Relacion_Producto__c> obtenerProductosComparables(string producto) {
        try {
            return [SELECT CSBD_Nombre_producto_2__c FROM CBK_Relacion_Producto__c WHERE RecordType.DeveloperName = 'CSBD_GPT_Productos_Comparables' AND CSBD_Nombre_producto_1__c = :producto WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //llamar a un prompt de tipo flex con variables, para poder llamar a multiples prompts con la misma funcion aunque tengan variables diferentes
    @AuraEnabled
    public static string resolverPromptFlex(string apiPrompt, List<List<string>> nombreValorTipoVariables) {
        try {
            //create input
            ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
            promptGenerationsInput.isPreview = false;
            
            // Build input map
            Map<String,ConnectApi.WrappedValue> valueMap = new Map<String,ConnectApi.WrappedValue>();

            // for(Integer i=0; i+3<=nombreValorTipoVariables.size(); i=i+3){
            //     String nombre = nombreValorTipoVariables[i];
            //     String valor = nombreValorTipoVariables[i+1];
            //     String tipo = nombreValorTipoVariables[i+2];
            for(Integer i=0; i<nombreValorTipoVariables.size(); i++){
                List<string> input = nombreValorTipoVariables[i];
                if (input.size() != 3){
                    //si uno de los inputs no es correcto salir de la funcion para evitar error al intentar ejecutar el prompt
                    return 'Error: los inputs del prompt no tienen el formato correcto';
                }
                //si es ok seguir
                String nombre = input[0];
                String valor = input[1];
                String tipo = input[2];
                //las variables de tipo objeto se introducen de manera diferente
                //comprobar el tipo con el tercer valor del tripleto de la lista
                if (tipo == 'Opportunity'){
                    Map<String, String> opportunityRecordIdMap = new Map<String, String>();
                    opportunityRecordIdMap.put('id', valor);
        
                    ConnectApi.WrappedValue recipientEntityWrappedValue = new ConnectApi.WrappedValue();
                    recipientEntityWrappedValue.value = opportunityRecordIdMap;

                    valueMap.put('Input:'+nombre, recipientEntityWrappedValue);
                }
                else{
                    ConnectApi.WrappedValue strWrappedValue = new ConnectApi.WrappedValue();

                    strWrappedValue.value = valor;
                    valueMap.put('Input:'+nombre, strWrappedValue);
                }
            }
            
            promptGenerationsInput.inputParams = valueMap;

            promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
            promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';

            // Call the service
            ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = 
            ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(apiPrompt, promptGenerationsInput);

            return generationsOutput.generations[0].text; //generationsOutput.prompt;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //funcion para obtener metadata de configuración de prompts de multiples productos
    @AuraEnabled(cacheable=true)
    public static list<CSBD_AdministracionPromptsProductos__mdt> obtenerMetadataPromptsMultiple(list<string> productos) {
        try {
            List<CSBD_AdministracionPromptsProductos__mdt> promptProductosList = new List<CSBD_AdministracionPromptsProductos__mdt>();
            promptProductosList = [SELECT MasterLabel, CSBD_EnviarAIA__c, CSBD_PromptArgumentarioAUtilizar__c, CSBD_PromptOportunidadAUtilizar__c, 
                                    CSBD_PromptProductoAUtilizar__c, CSBD_PromptAmpliadaAUtilizar__c, CSBD_ArticulosPorPrompt__c,
                                    CSBD_BusquedaEnDosPasos__c, CSBD_PromptAsistenteAUtilizar__c, CSBD_PromptComparadorAUtilizar__c
                                    FROM CSBD_AdministracionPromptsProductos__mdt WHERE MasterLabel IN :productos WITH SECURITY_ENFORCED];
            if(!promptProductosList.isEmpty()){
                return promptProductosList;
            }else{
                return null;
            }
        } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
        }
    }

    // //para debug, eliminar
    // @AuraEnabled
    // public static string obtenerArticulos(string oppId, string pregunta, integer numero) {
    //     try {
    //         integer articulosPorPrompt = 3;
    //         integer primerArticulo = numero*articulosPorPrompt;
    //         opportunity opp = [SELECT Id, CSBD_Producto__c FROM Opportunity WHERE Id = : oppId LIMIT 1];
    //         //hacer que coja solo los articulos que se van a utilizar con limit y offset
    //         List<Knowledge__kav> articulosProducto =
    //             [SELECT Id, Title, Question__c, Answer__c, CSBD_NombresProductos__c
    //                 FROM Knowledge__kav
    //                 WHERE CSBD_NombresProductos__c INCLUDES (:opp.CSBD_Producto__c) AND PublishStatus = 'Online' WITH SECURITY_ENFORCED ORDER BY ID ASC LIMIT :articulosPorPrompt OFFSET :primerArticulo];

    //         return JSON.serialize(articulosProducto);
    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }
}