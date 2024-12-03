@RestResource(urlMapping='/v1/snActualizarCaso/*')
global with sharing class SEG_WS_AORActualizarCaso extends CBK_HttpServiceIntegration_Abstract{

    private static CC_TrazaInt__c oTraza = new CC_TrazaInt__c();

    @HttpPut
    global static SEG_WS_AORActualizarCaso.Output snActualizarCaso() {

        oTraza.Name = 'SEG_AOR_ActualizarCaso';
        oTraza.CC_FechaInicio__c = datetime.now();
        oTraza.CC_Identificador__c = '';

        SEG_WS_AORActualizarCaso.Input input = new SEG_WS_AORActualizarCaso.Input();
        input = (SEG_WS_AORActualizarCaso.Input)JSON.deserializeStrict(
            RestContext.request.requestBody.toString(), SEG_WS_AORActualizarCaso.Input.class
        );

        SEG_WS_AORActualizarCaso.Output output = new SEG_WS_AORActualizarCaso.Output();

        List<Case> listCasos = new List<Case>();
        listCasos = [SELECT id, CaseNumber, SEG_N_operaciones_del_caso__c,Status,SEG_Subestado__c,CC_MCC_Tematica__c,CC_MCC_ProdServ__c,CC_MCC_Motivo__c,SEG_Detalle__c,Account.CC_Numero_Documento__c,SEG_Email_Buzon_Entrada__c,SEG_Organizacion__c,SEG_Zona__c,SEG_Grupo__c  
                    FROM Case WHERE id=:input.caseId];
        if(listCasos.size()==0){
            output.resultado='KO';
            output.mensaje='No se encuentra el Caso';
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = false;
        } else{
            if(input.tipoProceso=='SN1'){
                oTraza.Name = oTraza.Name + '_actualizarCaso';
                actualizarCaso(input, listCasos);
            } else if(input.tipoProceso=='SN2'){
                oTraza.Name = oTraza.Name + '_cerrarCaso';
                cerrarCaso(input, listCasos);
            }
            oTraza.CC_FechaFin__c = datetime.now();
            oTraza.CC_FinOK__c = true;
            output.resultado='OK';
            output.mensaje='Operación registrada correctamente';
        }
        insert oTraza;
        return output;
    }

    private static void actualizarCaso(SEG_WS_AORActualizarCaso.Input entrada, List<Case> listCasos){
        List<FeedItem> lstFeedsInsert = new List<FeedItem>();
        List<Case> casosUpdatear = new List<Case>();
        Group colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' LIMIT 1];
        //Añadir propietario SEG_BO
        for (Case caso : listCasos){
            Case casoUpdt = new Case();
            oTraza.CC_Identificador__c = oTraza.CC_Identificador__c + ' ' + caso.CaseNumber;
            String texto = 'Comentarios añadidos desde ServiceNow: ' + entrada.textoEmail;
            FeedItem feed = new FeedItem();
            feed.ParentId = caso.Id;
            feed.Body = texto;
            lstFeedsInsert.add(feed);
            casoUpdt.Id = caso.Id;
            casoUpdt.Status = 'Activo';
            casoUpdt.OwnerId = colasBO?.Id;
            casoUpdt.SEG_Subestado__c = 'Recibida respuesta jurídica';
            casosUpdatear.add(casoUpdt);
        }
        insert lstFeedsInsert;
        update casosUpdatear;
    }

    //Se limpia el campo RITM para que se realice una nueva conexión con SN si se necesita más información del caso.
    private static void cerrarCaso(SEG_WS_AORActualizarCaso.Input entrada,  List<Case> listCasos){
        List<FeedItem> lstFeedsInsert = new List<FeedItem>();
        List<Case> casosUpdatear = new List<Case>();
        for (Case caso : listCasos){
            Case casoUpdt = new Case();
            oTraza.CC_Identificador__c = oTraza.CC_Identificador__c + ' ' + caso.CaseNumber;
            casoUpdt.Id = caso.Id;
            casoUpdt.SEG_Identificador_AOR__c  = null;
            casosUpdatear.add(casoUpdt);

            String texto = 'Comentarios añadidos desde ServiceNow: ' + entrada?.textoEmail;
            FeedItem feed = new FeedItem();
            feed.ParentId = caso.Id;
            feed.Body = texto;
            lstFeedsInsert.add(feed);
        }
        insert lstFeedsInsert;
        update casosUpdatear;
    }

    @TestVisible
    private class Input {
        public String tipoProceso {get;set;}
        public String origen {get;set;}
        public String caseId {get;set;}
        public String fechaEvento {get;set;}
        public String textoEmail {get;set;}
        public String caseNumber {get;set;}
        public List<ContenidoAdicional> contenidoAdicional{get;set;}
        //tambien se envian docAdjuntos pero esto deberá tratarse por otro canal
        //SN1 - Actualización del caso a través de la API.
        //SN2 - Cierre del caso a través de la API.
    }

    @TestVisible
    private class ContenidoAdicional{
        public String key {get;set;}
        public String value {get;set;}
    }
    
    global class Output {
        public String resultado {get;set;}
        public String mensaje {get;set;}
    }
}