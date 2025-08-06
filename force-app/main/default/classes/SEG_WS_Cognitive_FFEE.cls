@RestResource(urlMapping='/clasificarCasoFFEE')

global with sharing class SEG_WS_Cognitive_FFEE extends CBK_HttpServiceIntegration_Abstract{

    @HttpPut
    global static SEG_WS_Cognitive_FFEE.Output clasificarCaso() {

        //Registramos el inicio del poceso
        Datetime dtStart = Datetime.now();

        RestRequest peticionREST = RestContext.request;
        RestResponse responseREST = RestContext.response; 
        responseREST.headers.put('Content-Type', 'application/json');
		responseREST.responsebody = Blob.valueOf('Finalizado correctamente');
        responseREST.statusCode = 200;

        Boolean bOk = true;

        Input input = new Input();
        Output output = new Output();
        String caseNumber = null;

        try {
            input = (Input)JSON.deserializeStrict(
                peticionREST.requestBody.toString(), SEG_WS_Cognitive_FFEE.Input.class
            );

            Map<String, String> resultadoValidacion = validarDatosEntrada(input);

            if (resultadoValidacion.get('resultado') != 'OK') {
                bOk = false;
                output.resultado = 'KO';
                output.mensaje = resultadoValidacion.get('errorProducido');
                responseREST.responsebody = Blob.valueOf(resultadoValidacion.get('errorProducido'));
                responseREST.statusCode = 400;
            }
        } catch (Exception ex) {
            bOk = false;
            output.resultado = 'KO';
            output.mensaje = JSON.serialize(ex);
            responseREST.responsebody = Blob.valueOf(JSON.serialize(ex));
            responseREST.statusCode = 400;
        }

        if(bOk){
            
            caseNumber = input.pkCodSr;
            output = logicaWS(input, output);

            if (output.resultado.equalsIgnoreCase('KO')) {
                responseREST.responsebody = Blob.valueOf(output.mensaje);
                responseREST.statusCode = 400;
            }
        }

        //Registramos el fin del poceso
        Datetime dtStop = Datetime.now();

        register(peticionREST, responseREST, dtStart, dtStop, caseNumber, null);
        return output;
    }

    public static Map<String,String> validarDatosEntrada (Input input){
        Map<String,String> mapResultadoValidacion = new Map<String,String>();
        mapResultadoValidacion.put('resultado','OK');

        if (input.pkIdSalesforce == null || input.category == null) {
            mapResultadoValidacion.put('resultado','KO');
            mapResultadoValidacion.put('resultado','Los parámetros obligatorios para la actualización del caso no se han informado. Datos obtenidos: pkIdSalesforce - ' + input.pkIdSalesforce + ' | category - ' + input.category);
        }

        return mapResultadoValidacion;
    }

    public static Output logicaWS (Input input, Output output){
        List<Case> listCasos = new List<Case>();
        listCasos = [SELECT id, CaseNumber, SEG_ClasificacionRapida__c, SEG_Case_Owner__c, SEG_Organizacion__c FROM Case WHERE id=:input.pkIdSalesforce];

        if(listCasos.isEmpty()){
            output.resultado='KO';
            output.mensaje='No se encuentra el Caso indicado en Salesforce';
         } else if(listCasos[0].SEG_ClasificacionRapida__c == null && listCasos[0].SEG_Case_Owner__c == 'SEG_BO'){          
            Case casoSeg = listCasos[0];

            if(String.isNotBlank(input.category)) {
                Boolean crEncontrada = false;
                if(input.category=='Robot No Clasificado') { //Cognitive indica que no ha encontrado ninguna clasificacción en base a los datos indicados.
                    output.resultado='OK';
                    casoSeg.SEG_TipoClasificacion__c = 'Robot no clasificado';
                } else {
                    FeedItem feed = new FeedItem();
                    feed.Type = 'TextPost';
                    feed.ParentId = casoSeg.id;
                    List<SEG_ClasificacionRapida__c> crCognitive = new List<SEG_ClasificacionRapida__c>([SELECT id,name,SEG_Nombre_CR_Cognitive__c,SEG_Canaldeentrada__c, SEG_Tematica__c,SEG_Producto__c,SEG_Motivo__c,SEG_Detalle__c,SEG_Prioridad__c, SEG_CRAuditoria__c FROM SEG_ClasificacionRapida__c WHERE SEG_Nombre_CR_Cognitive__c =:input.category AND SEG_Inactiva__c=false AND SEG_Organizacion__c INCLUDES(:casoSeg.SEG_Organizacion__c)]);
                    if(crCognitive != null && !crCognitive.isEmpty()){
                        crEncontrada = true;

                        casoSeg.SEG_ClasificacionRapida__c=crCognitive[0].id;
                        casoSeg.CC_MCC_Tematica__c = crCognitive[0].SEG_Tematica__c;
                        casoSeg.CC_MCC_ProdServ__c = crCognitive[0].SEG_Producto__c;
                        casoSeg.CC_MCC_Motivo__c = crCognitive[0].SEG_Motivo__c;
                        casoSeg.SEG_Detalle__c = crCognitive[0].SEG_Detalle__c;
                        casoSeg.Priority = crCognitive[0].SEG_Prioridad__c;
                        casoSeg.SEG_N_operaciones_del_caso__c = 1;
                        casoSeg.SEG_TipoClasificacion__c='Cognitive sin adjuntos';
                        // Revisar
                        if(input.hasAttachments){
                            casoSeg.SEG_TipoClasificacion__c='Cognitive con adjuntos';
                        }

                        feed.Body = 'CognitiveFFEE: ' + input.Category; 
                    } else {

                        feed.Body = 'Cognitive: No existe CR en Salesforce activa con Nombre Cognitive: ' + input.category +  '  y Organización: ' + casoSeg.SEG_Organizacion__c; 
                    }
                    insert feed;
                }
                //Update caso
                Database.SaveResult sr = Database.update(casoSeg);
                
                output.resultado='OK';
                output.mensaje='Caso clasificado correctamente en Salesforce.';
                
                if(crEncontrada && sr.isSuccess()){
                    SEG_Case_Operativas_Controller.autoAsignarGrupo(casoSeg.Id);                                                                             
                }else{
                    FeedItem feed = new FeedItem();
                    feed.ParentId = input.pkIdSalesforce; 
                    feed.Type = 'TextPost';
                    feed.Body = 'Cognitive: No se ha podido realizar la actualización correcta del caso';
                    for(Database.Error err : sr.getErrors()) {
                        feed.Body += ' Error: ' + err.getMessage();	 
                    }
                }
            } else {
                output.resultado='KO';
                output.mensaje='No se ha indicado una categoría';}
        } else{
            FeedItem feed = new FeedItem();
            feed.ParentId = input.pkIdSalesforce; 
            feed.Type = 'TextPost';
            output.resultado='OK';
            if(listCasos[0].SEG_Case_Owner__c != 'SEG_BO'){
                feed.Body = 'Cognitive: Se ha asignado un propietario previa consulta a Cognitive con lo que no se ha aplicado la CR indicada.'; 
            } else {
                feed.Body = 'Cognitive: El caso ya se encontraba clasificado manualmente por lo que no se ha podido aplicar Cognitive.'; 
            }

            insert feed;
		}

        return output;
    }

    @TestVisible
    private class Input {
        public String pkCodSr {get;set;}
        public String pkIdSalesforce {get;set;}
        public String model {get;set;}
        public Boolean hasAttachments {get;set;}
        public String category {get;set;}
        public List<Categorias> categories{get;set;}
    }

    @TestVisible
    private class Categorias{
        public String category {get;set;}
        public String prob {get;set;}
    }

    global class Output {
        public String resultado {get;set;}
        public String mensaje {get;set;}
    }
}