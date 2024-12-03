@RestResource(urlMapping='/CC_GetAgentWorkInfo/*')
global with sharing class CC_WS_AgentWork {
    
    global class CC_AgentWork_Output {
        global Id id {get;set;}
        global String entidad {get;set;}
        global String status {get;set;}
        global String interactionId {get;set;}
        global String place {get;set;}
        global String workItemId {get;set;}
        global String agentLogin {get;set;}
        global String ticketId {get;set;}
        global String proxyClientId {get;set;}
        global DateTime requestDateTime {get;set;}
        global DateTime acceptDateTime {get;set;}
        global DateTime declineDateTime {get;set;}
        global DateTime closeDateTime {get;set;}
        global DateTime assignedDateTime {get;set;}
        global Integer pushTimeout {get;set;}
        global Boolean chatAceptado {get;set;}
        global String motivoStop {get;set;}
    }
    
    @HttpGet
    global static void getData() {
        RestRequest request = RestContext.request;
        CC_AgentWork_Output output= new CC_AgentWork_Output();
        String recordId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        
        if (String.isNotBlank(recordId) && !recordId.equalsIgnoreCase('null'))
        {
            String tipo = String.valueOf(Id.valueOf(recordId).getsobjecttype()); 
            output.entidad=tipo;
            output = agentWorkInfo(recordId);

            if (output.id!=null){
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(output)); 
            } else {
                RestContext.response.responseBody = Blob.valueOf('No existe registro');
                RestContext.response.statusCode=400;
            }
        }
        else {
            RestContext.response.responseBody = Blob.valueOf('No existe registro');
            RestContext.response.statusCode=400;
        }
    }
    
    //LiveChatTranscript
    global static CC_AgentWork_Output agentWorkInfo(Id recordId){
        Map<String, String> relacionEstadoMotivoMap = new Map<String, String>();
        
        CC_AgentWork_Output output= new CC_AgentWork_Output();
        output.motivoStop = 'UNKNOWN'; //se actualiza dependiendo del Status del agentWork; si no existe ninguna relación, se mantiene UNKNOWN
        
        if (recordId != null)
        {
            //Obtenemos la lista de valores para enviar a Genesys el valor del campo CC_Valor__c, dependiendo del Status del AgentWork definido en CC_Valor_SFDC__c
            List<CC_Lista_Valores__c> relacionEstadoMotivo = [SELECT Id, CC_Activa__c, Name, CC_Valor__c, CC_Valor_SFDC__c 
                                        FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Valor' AND CC_Lista__r.Name = 'Widget: Relación Estado - Motivo' 
                                        AND CC_Lista__r.CC_Activa__c = true AND CC_Activa__c = true];

            if (!relacionEstadoMotivo.isEmpty())
            {
                for(CC_Lista_Valores__c relacion : relacionEstadoMotivo)
                {
                    relacionEstadoMotivoMap.put(relacion.CC_Valor_SFDC__c, relacion.CC_Valor__c);
                }
            }

            List<AgentWork> result =  [SELECT Id, Name, CreatedDate, LastModifiedDate, UserId, WorkItemId, Status, RequestDateTime, AcceptDateTime, DeclineDateTime, 
                                            CloseDateTime, PushTimeout, AssignedDateTime, CC_InteractionId__c, CC_Place__c, CC_AgentLogin__c, CC_TicketId__c, CC_ProxyClientId__c 
                                        FROM AgentWork WHERE WorkItemId = :recordId ORDER BY CreatedDate DESC];

            if (!result.isEmpty())
            {
                output.id = result[0].Id;
                output.status = result[0].Status;
                output.interactionId = result[0].CC_InteractionId__c;
                output.place = result[0].CC_Place__c;
                output.workItemId = result[0].WorkItemId;
                output.agentLogin = result[0].CC_AgentLogin__c;
                output.ticketId = result[0].CC_TicketId__c;
                output.proxyClientId = result[0].CC_ProxyClientId__c;
                output.requestDateTime = result[0].RequestDateTime;
                output.acceptDateTime = result[0].AcceptDateTime;
                output.declineDateTime = result[0].DeclineDateTime;
                output.closeDateTime = result[0].CloseDateTime;
                output.assignedDateTime = result[0].AssignedDateTime;
                output.pushTimeout = result[0].PushTimeout;
                output.chatAceptado = false; //Inicializamos a false, ya que luego vamos a cambiarlo a true si el campo AcceptDateTime tiene fecha

                for (AgentWork resultado : result)
                {
                    //ChatAceptado true si el campo AcceptDateTime tiene fecha
                    if (resultado.AcceptDateTime != null)
                    {
                        output.chatAceptado = true;
                    }
                }
                
                if (!relacionEstadoMotivoMap.isEmpty() && result[0].Status != null && result[0].Status != '')
                {
                    output.motivoStop = relacionEstadoMotivoMap.get(result[0].Status); 
                }

            } else {
                //Si no se encuentra AgentWork, es que todavía no se ha asignado el WorkItem a ningún agente 
                output.id = recordId;
                output.workItemId = recordId;
                output.chatAceptado = false;
                output.interactionId = null;

                if (!relacionEstadoMotivoMap.isEmpty())
                {
                    output.motivoStop = relacionEstadoMotivoMap.get('Default'); //Default value
                }
            }
        }

        return output;
    }

    global class AgentWorkNoExiste_Exception extends Exception {}
    global class NoExisteMotivoStopActivo_Exception extends Exception {}

}