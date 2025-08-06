public class CC_ContentDocumentLink_AI_TRHan extends CC_TriggerHandlerBase {
    public override void mainEntry(CC_TriggerParameters tp) {
        process((List<ContentDocumentLink>)tp.newList, (Map<Id, ContentDocumentLink>)tp.newMap);
    }
    private List<ContentDocumentLink> filtrarNoOS(List<ContentDocumentLink> listNewObj) {
        List<ContentDocumentLink> newList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> newListContentDocument = new List<ContentDocumentLink>();
        Set<Id> idCasos = new Set<Id>();
        
        for (ContentDocumentLink cDocumentLink : listNewObj) {
            if (cDocumentLink.LinkedEntityId != null && String.valueOf(cDocumentLink.LinkedEntityId.getSobjectType()) == 'Case') {
                idCasos.add(cDocumentLink.LinkedEntityId);
                newListContentDocument.add(cDocumentLink);
            }
        }
        if (!idCasos.isEmpty()) {
            List<Case> listaCasos = [SELECT Id, RecordType.developername FROM Case WHERE Id IN :idCasos];
            Map<Id,String> mapRescordtypeIds = new Map<Id,String>();
            for (Case caso : listaCasos) {
                mapRescordtypeIds.put(caso.Id, caso.RecordType.DeveloperName);
            }
            if (!mapRescordtypeIds.isEmpty()) {
                for (ContentDocumentLink cDocumentLink : newListContentDocument) {
                    if (mapRescordtypeIds.get(cDocumentLink.LinkedEntityId).startsWith('OS_')) {
                        newList.add(cDocumentLink);
                    }
                }
            }
        }  
        return newList;
    }

    private void process(List<ContentDocumentLink> listNewObj, Map<Id, ContentDocumentLink> mapNewObj) {
        List<ContentDocumentLink> newList = filtrarNoOS(listNewObj);
        validarEnvioCorreo(newList);
    }

    private static void validarEnvioCorreo(List<ContentDocumentLink> listNewObj) {
        if (!listNewObj.isEmpty()) {
            Set<Id> idCasos = new Set<Id>();
            Set<Id> setIdContentDocumentLink = new Set<Id>();

            for (ContentDocumentLink cdl : listNewObj) {
                if (String.valueOf(cdl.LinkedEntityId.getSobjectType()) == 'Case') {
                    idCasos.add(cdl.LinkedEntityId);
                }
            }
            if (!idCasos.isEmpty()) {
                List<Case> casos = [SELECT Id, Status, CC_Fecha_Traslado_Colaborador__c, CC_Grupo_Colaborador__c, OS_Nombre_Proceso_Valija__c, OS_Adjuntos_Valija__c, CC_Referencia_Correo_Saliente__c FROM Case WHERE Id IN :idCasos LIMIT 1];
                //contar los adjutnos que tiene el caso
                List<ContentDocumentLink> listaContentDocumentLink = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN :idCasos];
                System.debug(listaContentDocumentLink.size());
                if (!casos.isEmpty()) {
                    if (casos[0].OS_Adjuntos_Valija__c == listaContentDocumentLink.size()) {
                        for(ContentDocumentLink contentDocuementUnit: listaContentDocumentLink){
                            setIdContentDocumentLink.add(contentDocuementUnit.Id);
                        }
                        System.debug('HA LLEGADO AL NÚMERO DE ADJUNTOS QUE TIENE EL CASO');
                        List<OS_TrasladoColaborador_Valija__mdt> trasladosColabAutomaticos = [SELECT OS_Grupo_Colaborador__c, OS_Plantilla__c
                                                                                            FROM OS_TrasladoColaborador_Valija__mdt WHERE OS_Nombre_Proceso__c = :casos[0].OS_Nombre_Proceso_Valija__c LIMIT 1];
                        if (!trasladosColabAutomaticos.isEmpty()) {
                            //Traslado a colaborador automático definido para el proceso de valija recibido
                            CC_Grupo_Colaborador__c grupoColaborador = [SELECT Name FROM CC_Grupo_Colaborador__c WHERE Name = :trasladosColabAutomaticos[0].OS_Grupo_Colaborador__c LIMIT 1];
                            EmailTemplate plantilla = [SELECT Id, HtmlValue, Subject FROM EmailTemplate WHERE DeveloperName = :trasladosColabAutomaticos[0].OS_Plantilla__c LIMIT 1];
                            OS_Case.trasladoColaboradorAutomatico(casos[0].Id, grupoColaborador.Id, plantilla.Id, plantilla.HtmlValue, plantilla.Subject, setIdContentDocumentLink);
                        }    
                    }    
                }
            }
        }
    }
}