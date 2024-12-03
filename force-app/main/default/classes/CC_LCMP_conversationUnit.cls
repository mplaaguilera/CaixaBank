public with sharing class CC_LCMP_conversationUnit {

    private static final Id RTDETALLE = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_ConversationUnit__c', 'CC_ConversationDetail');
    private static final Id RTUNIDAD = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_ConversationUnit__c', 'CC_ConversationUnit');
    
    @AuraEnabled
    public static List<ObjIniWrapper> comprobarDatos(String llamadaId) {
        Set<Id> idsRT = new Set<Id>();
        List<String> lstThreads = new List<String>();
        CC_Llamada__c llamada = [SELECT Id, CC_ConnId__c, CC_Cuenta__c FROM CC_Llamada__c WHERE Id =: llamadaId WITH SECURITY_ENFORCED LIMIT 1];
        
        CC_WS_Intents.ResponseConversation llamadaWs = null;
        
        if(!String.isBlank(llamada.CC_ConnId__c)) {
            llamadaWs = CC_WS_Intents.getConversationId(llamada);
        } else {
            return null;
        }

        idsRT.add(RTDETALLE);
        idsRT.add(RTUNIDAD);

        if(llamadaWs != null && llamadaWs.statusCode != null && llamadaWs.statusCode.equalsIgnoreCase('200')) {
            if(llamadaWs.lstConversationId != null && !llamadaWs.lstConversationId.isEmpty()) {
                List<CC_ConversationUnit__c> conversacionesLlamada = [SELECT Id, Name, CreatedDate, CC_FechaFin__c, CC_FechaInicio__c, RecordTypeId, CC_Texto__c, RecordType.Name, CC_Feedback__c, CC_Idioma__c, CC_ThreadId__c, CC_TimeStamp__c, CC_Tipo__c, CC_Intent__c 
                    FROM CC_ConversationUnit__c 
                    WHERE RecordTypeId IN : idsRT AND CC_Llamada__c =: llamadaId AND CC_ThreadId__c IN: llamadaWs.lstConversationId WITH SECURITY_ENFORCED Order By CC_TimeStamp__c Desc];

                if(!conversacionesLlamada.isEmpty()){
                    for (CC_ConversationUnit__c convLlamada : conversacionesLlamada) {
                        if(convLlamada.RecordTypeId == RTDETALLE && !llamadaWs.lstConversationId.contains(convLlamada.CC_ThreadId__c)){
                            lstThreads.add(convLlamada.CC_ThreadId__c);
                        }
                    }
                }
                
                if(conversacionesLlamada.isEmpty() && lstThreads.isEmpty()){ //no hay datos en salesforce, hay que llamar al WS
                    lstThreads = llamadaWs.lstConversationId;
                    Map<Id, CC_ConversationUnit__c> mapFamilia = recuperarDatos(lstThreads, llamadaId);
                    return montarEstructura(mapFamilia);
                } else if(!conversacionesLlamada.isEmpty() && lstThreads.isEmpty()){//hay datos en salesforce, y los threads coinciden con los del WS
                    Map<Id, CC_ConversationUnit__c> mapFamilia = new Map<Id, CC_ConversationUnit__c>(conversacionesLlamada);
                    return montarEstructura(mapFamilia);
                } else if(!conversacionesLlamada.isEmpty() && !lstThreads.isEmpty()){//hay datos en salesforce, y hay que introducir nuevos registros del WS
                    Map<Id, CC_ConversationUnit__c> mapFamilia = recuperarDatos(lstThreads, llamadaId);
                    for (CC_ConversationUnit__c conversacionQuery : conversacionesLlamada) {
                        mapFamilia.put(conversacionQuery.Id, conversacionQuery);
                    }
                    return montarEstructura(mapFamilia);
                } else{
                    throw new AuraHandledException('Sin datos');
                }
            }
        } else {
            throw new AuraHandledException('Resultado de la llamada a Cognitivo diferente de OK o no existen valores.');
        }
        return null;
        
    }

    private static Map<Id,CC_ConversationUnit__c> recuperarDatos(List<String> lstThreads, String llamadaId){

        List<CC_ConversationUnit__c> padresInsertar = new List<CC_ConversationUnit__c>();
        List<CC_ConversationUnit__c> hijosInsertar = new List<CC_ConversationUnit__c>();
        List<CC_ConversationUnit__c> listaFamilia = new List<CC_ConversationUnit__c>();
        Map<Id,CC_ConversationUnit__c> mapFamilia = new Map<Id,CC_ConversationUnit__c>();
        Map<String, List<CC_WS_Intents.ConversationUnits>> mapFamiliaCU = new Map<String, List<CC_WS_Intents.ConversationUnits>>();

        for(String idConv : lstThreads){
            CC_WS_Intents.ResponseDetailConversation llamadaWsDetail = CC_WS_Intents.getConversationDetail(idConv);
            
            
            if(llamadaWsDetail != null && llamadaWsDetail.statusCode !=null && llamadaWsDetail.statusCode.equalsIgnoreCase('200')){
                if(llamadaWsDetail.conversationDetail != null && llamadaWsDetail.conversationDetail.Hits != null ){
                    List<CC_WS_Intents.Hits> subHits = llamadaWsDetail.conversationDetail.hits.hits;
                    if(!subHits.isEmpty()){
                        for(CC_WS_Intents.Hits hit : subHits){
                            CC_ConversationUnit__c elementoDetalle = new CC_ConversationUnit__c(
                                CC_ThreadId__c = hit.source.conversationID,
                                RecordTypeId = RTDETALLE,
                                CC_Feedback__c = hit.source.result,
                                CC_FechaFin__c = Datetime.valueOf(hit.source.endTime.replace('T', ' ').replace('Z','')),
                                CC_FechaInicio__c = Datetime.valueOf(hit.source.startTime.replace('T', ' ').replace('Z','')),
                                CC_Llamada__c = llamadaId
                            );
    
                            padresInsertar.add(elementoDetalle);
                            mapFamiliaCU.put(hit.source.conversationID, hit.source.conversationUnits);
                        }
                    }
                    
                }
                else{
                    throw new AuraHandledException('Contenido en la respuesta de cognitivo vacío, o datos recibidos invalidos.');
                }
            }
            else{
                throw new AuraHandledException('Respuesta por parte de Cognitivo nula, o error en la respuesta.');
            }
        }

        if (!padresInsertar.isEmpty() && Schema.sObjectType.CC_ConversationUnit__c.isCreateable()) {
            Database.SaveResult[] srListPadres = Database.insert(padresInsertar, false);
            for (Database.SaveResult sr : srListPadres) {
                if (!sr.isSuccess()) {
                    String errorMessage;
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage = String.valueOf(err.getStatusCode());
                    }
                    throw new AuraHandledException(errorMessage);
                }
            }

            List<CC_ConversationUnit__c> lstWithNames = [SELECT Id, Name, CreatedDate, CC_FechaFin__c, CC_FechaInicio__c, RecordTypeId, CC_Texto__c, RecordType.Name, CC_Feedback__c, CC_Idioma__c, CC_ThreadId__c, CC_Tipo__c, CC_Intent__c
                                                            FROM CC_ConversationUnit__c
                                                            WHERE Id IN: padresInsertar WITH SECURITY_ENFORCED Order By CC_TimeStamp__c Desc];



            listaFamilia.addAll(lstWithNames);

            for (CC_ConversationUnit__c padreCU : lstWithNames) {
                if(mapFamiliaCU.containsKey(padreCU.CC_ThreadId__c)){
                    for(CC_WS_Intents.ConversationUnits hijoCU : mapFamiliaCU.get(padreCU.CC_ThreadId__c)){
                        if(String.ValueOf(hijoCU.type)!='18'){
                            CC_ConversationUnit__c hijoSalesforceCU = new CC_ConversationUnit__c(
                            CC_ThreadId__c = padreCU.CC_ThreadId__c,
                            RecordTypeId = RTUNIDAD,
                            CC_Feedback__c = padreCU.CC_Feedback__c,
                            CC_FechaFin__c = padreCU.CC_FechaFin__c,
                            CC_FechaInicio__c = padreCU.CC_FechaInicio__c,
                            CC_Llamada__c = llamadaId,
                            CC_Tipo__c = String.valueOf(hijoCU.type),
                            CC_Intent__c = padreCU.Id,
                            CC_TimeStamp__c = Datetime.valueOf(hijoCU.timestamp.replace('T', ' ').replace('Z','')),
                            CC_Texto__c = hijoCU.text
                            );
                            hijosInsertar.add(hijoSalesforceCU);
                        }
                    }
                }    
            }

            if (!hijosInsertar.isEmpty() && Schema.sObjectType.CC_ConversationUnit__c.isCreateable()) { 
                Database.SaveResult[] srListHijos = Database.insert(hijosInsertar, false);
                for (Database.SaveResult sr : srListHijos) {
                    if (!sr.isSuccess()) {
                        String errorMessage;
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage = String.valueOf(err.getStatusCode());
                        }
                        throw new AuraHandledException(errorMessage);
                    }
                }

                listaFamilia.addAll(hijosInsertar);
            }
            else{
                throw new AuraHandledException('Sin permisos para visualizar los datos provenientes de cognitivo.');
            }

            if(!listaFamilia.isEmpty()){
                for (CC_ConversationUnit__c miembro : listaFamilia) {
                    mapFamilia.put(miembro.Id, miembro);
                }
            }
        }
        else{
            throw new AuraHandledException('Sin permisos para visualizar los datos provenientes de cognitivo.');
        }
        return mapFamilia;
    }

    private static List<ObjIniWrapper> montarEstructura(Map<Id, CC_ConversationUnit__c> mapFamilia){
        List<ObjIniWrapper> resultadoLista = new List<ObjIniWrapper>();
        Map<Id, List<CC_ConversationUnit__c>> mapPadreHijos = new Map<Id, List<CC_ConversationUnit__c>>();
        for(String idConv : mapFamilia.keyset()){
            if(mapFamilia.get(idConv).RecordTypeId != RTDETALLE){
                if(!mapPadreHijos.containsKey(mapFamilia.get(idConv).CC_Intent__c)){
                    List<CC_ConversationUnit__c> listHijos = new List<CC_ConversationUnit__c>();
                    listHijos.add(mapFamilia.get(idConv));
                    mapPadreHijos.put(mapFamilia.get(idConv).CC_Intent__c, listHijos);
                } else{
                    List<CC_ConversationUnit__c> listHijos = mapPadreHijos.get(mapFamilia.get(idConv).CC_Intent__c);
                    listHijos.add(mapFamilia.get(idConv));
                    mapPadreHijos.put(mapFamilia.get(idConv).CC_Intent__c, listHijos);
                }
            }
        }

        for(String idConv : mapPadreHijos.keyset()){
            if(mapFamilia.get(idConv).RecordTypeId == RTDETALLE){
                ObjIniWrapper registraAux = new ObjIniWrapper(mapFamilia.get(idConv), mapPadreHijos.get(idConv));
                resultadoLista.add(registraAux);
            }
        }

        //Doble bucle for para acceder a los hijos, y modificar su CC_Tipo__c a la hora de devolverlo a JS, para que sea legible por el user
        for (ObjIniWrapper elemento : resultadoLista) {
            if(!elemento.listHijos.isEmpty()){
                for(CC_ConversationUnit__c hijo : elemento.listHijos){
                    hijo.CC_tipo__c = getPicklistHijo(hijo.CC_Tipo__c);
                }
            }
        }
        return resultadoLista;
    }

    private static String getPicklistPadre(String picklistEntry){
        
        Map<String, String> mapaInfo = new Map<String, String>();
        for(Schema.PicklistEntry ple : Schema.SObjectType.CC_ConversationUnit__c.fields.CC_Feedback__c.getPicklistValues()){
            mapaInfo.put(String.valueOf(ple.getValue()), ple.getLabel());
        }
        String result = '';
        if(mapaInfo.containsKey(picklistEntry)){
            result = mapaInfo.get(picklistEntry);
        }
        return result;
    }

    private static String getPicklistHijo(String picklistEntry){
        
        Map<String, String> mapaInfo = new Map<String, String>();
        for(Schema.PicklistEntry ple : Schema.SObjectType.CC_ConversationUnit__c.fields.CC_Tipo__c.getPicklistValues()){
            mapaInfo.put(String.valueOf(ple.getValue()), ple.getLabel());
        }
        String result = '';
        if(mapaInfo.containsKey(picklistEntry)){
            result = mapaInfo.get(picklistEntry);
        }
        return result;
    }
        

    public class ObjIniWrapper{
        @AuraEnabled public CC_ConversationUnit__c padreConver {get; set;}
        @AuraEnabled public List<CC_ConversationUnit__c> listHijos {get; set;}
        @AuraEnabled public String picklistFeedback {get; set;}

        public ObjIniWrapper(CC_ConversationUnit__c padreConverC, List<CC_ConversationUnit__c> listHijosC){
            this.padreConver = padreConverC;
            this.listHijos = listHijosC;
            this.picklistFeedback = getPicklistPadre(padreConver.CC_Feedback__c);
        }
    }
}