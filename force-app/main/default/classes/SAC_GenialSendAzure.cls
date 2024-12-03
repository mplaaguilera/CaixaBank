/*****************************************************************
* Name: SAC_GenialSendAzure
* Copyright © 2023  CaixaBank
* 
* Proposito: Enviar la informacion necesaria de un caso a la IA de Azure
* 
* Historial
* -------
* VERSION        USER_STORY       AUTHOR                 DATE         Description
* 1.0            US727970         David Ramos            15/11/23       Creación     
*****************************************************************/
public with sharing class SAC_GenialSendAzure{
    /**
    * Identificador de un CBK_IntegrationSetting__c con los datos para conectarse a Azure
    * CBK_Method__c = 'POST'
    * CBK_ContentType__c = application/json
    */
    private static final String SAC_GENIAL_AZURE = 'SAC_GenialAzureAI';
    
    //devuelve si el caso se ha enviado correctamente
    @Future(callout=true)
    public static void sendToIA(String idCasoAEnviar, String description){
        Case casoAEnviar = [SELECT Id, Subject, Description, SAC_GenialEstado__c, caseNumber FROM Case WHERE Id = :idCasoAEnviar];
        MensajeAIA messageBody = new MensajeAIA();
        ReclamacionMensaje recCaso = new ReclamacionMensaje();
        recCaso.Id = casoAEnviar.Id;
        recCaso.Subject = casoAEnviar.Subject;
        recCaso.Description = description.left(32000); //casoAEnviar.Description;
        recCaso.caseNumber = integer.valueOf(casoAEnviar.caseNumber);
        messageBody.reclamacion = recCaso;

        List<ContentDocumentLink> doculink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :casoAEnviar.Id];

        List<String> idsAttachments = new List<String>();
        
        for (ContentDocumentLink d : doculink){
            idsAttachments.add(d.ContentDocumentId );
            //system.debug(d.ContentDocumentId);
        }

        //usar ContentVersion para coger las versiones mas recientes de los documentos
        List<ContentVersion> docuversions = [SELECT Id, ContentDocumentId, IsLatest FROM ContentVersion WHERE ContentDocumentId  IN :idsAttachments AND IsLatest = true];

        List<String> idsAttachmentsLatest = new List<String>();
        for (ContentVersion d : docuversions){
            idsAttachmentsLatest.add(d.Id );
            //system.debug(d.Id);
        }

        //system.debug(idsAttachments);
        messageBody.adjuntos = idsAttachmentsLatest;


        String jSONBody = JSON.serialize(messageBody);
        jSONBody = jSONBody.replace('"id":', '"Id":');
        jSONBody = jSONBody.replace('"subject":', '"Subject":');
        jSONBody = jSONBody.replace('"description":', '"Description":');
        jSONBody = jSONBody.replace('"caseNumber":', '"CaseNumber":');

        system.debug(jSONBody);
        try{
            // system.debug('inicio del try');  
            Integer intrandomNumber = Integer.valueof((Math.random() * 1000));
            String integrationId = String.valueOf(intrandomNumber);
            HttpRequest request = CBK_HttpServiceIntegration.getRequest(jSONBody, SAC_GENIAL_AZURE, '', new  Map<String, string>());
            HttpResponse response = CBK_HttpServiceIntegration.callHttpService(request, integrationId, SAC_GENIAL_AZURE);
            
            //system.debug(response);
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300){
                //si funciona pasa a estar en estado Enviado
                casoAEnviar.SAC_GenialEstado__c = 'SAC_001';
                //actualizamos el tipo de integración
            }
            else{
                //poner estado a error envio
                casoAEnviar.SAC_GenialEstado__c = 'SAC_004';
                //ponerlo a pdte Asignar
                string nombreCola = 'SAC_PendienteAsignar';
                QueueSobject cola = null;
                List<QueueSobject> colas = [SELECT QueueId FROM QueueSobject WHERE queue.DeveloperName = : nombreCola AND SobjectType = 'Case' LIMIT 1];
                if(!colas.isEmpty()){
                    cola = colas[0];
                }
                casoAEnviar.OwnerId = cola.QueueId;
            }
            //Acutalizamos el campo tipo de integración independientemente del resultado de la misma
            casoAEnviar.SAC_Tipo_integracion_IA__c = 'Azure';
            Database.SaveResult resRec = Database.update(casoAEnviar);
            system.debug(casoAEnviar.SAC_GenialEstado__c);
            system.debug(casoAEnviar.SAC_Tipo_integracion_IA__c);
            system.debug(casoAEnviar.Subject);
            // system.debug('fin del try');
        }
        catch(Exception ex){            
            // system.debug('inicio del catch');            
            CBK_Log.error('The following exception has occurred: ' + ex.getMessage());
            system.debug(ex.getMessage() + ' ' + ex.getLineNumber());

            // system.debug('fin del catch');
        }

    }

    

    public class MensajeAIA {
        public ReclamacionMensaje reclamacion;
        List<string> adjuntos;
    }

    public class ReclamacionMensaje {
        string id;
        string subject;
        string description;
        integer caseNumber;
    }
}