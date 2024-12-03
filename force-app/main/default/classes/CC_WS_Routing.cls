@RestResource(urlMapping='/CC_Routing/*')
global with sharing class CC_WS_Routing {
    
    global class CC_WS_Routing_Output {
        global Id Id {get;set;}
        global String Entidad {get;set;}
        global String Canal {get;set;}
        global String Tipo {get;set;}
        global String Subject {get;set;}
        global String Aplicacion {get;set;}
        global String Espacio {get;set;}
        global String Categoria {get;set;}
        global String Estado {get;set;}
        global String Idioma {get;set;}
        global String CognitiveId {get;set;}
        global String AgentChatAtendido {get;set;}
        global Boolean VisitorDesconectado {get;set;}
    }
    
    @HttpGet
    //global static CC_WS_Routing_Output getData() {
    global static void getData() {
        RestRequest request = RestContext.request;
        
        CC_WS_Routing_Output output= new CC_WS_Routing_Output();
       
        String recordId = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
        String Tipo = String.valueOf(Id.valueOf(recordId).getsobjecttype()); 
        
        switch on Tipo {
            when 'LiveChatTranscript' {
                output=CC_LiveChatTranscript(recordId);
            }
            when 'Case' {
                output=CC_Case(recordId);
            }
        }
        output.Entidad=Tipo;
        
//        return output;
        if (output.Id!=null){
			RestContext.response.responseBody = Blob.valueOf(JSON.serialize(output)); 
        }  else {
			RestContext.response.responseBody = Blob.valueOf('No existe registro');
            RestContext.response.statusCode=400;
        }

    }
    
    //LiveChatTranscript
    global static CC_WS_Routing_Output CC_LiveChatTranscript(Id recordId){
        CC_WS_Routing_Output output= new CC_WS_Routing_Output();
        List<LiveChatTranscript> result =  [SELECT Id, Status,CC_Idioma__c,CC_Espacio__c, CC_Tipo__c, CC_Aplicacion__c, CC_Categoria__c, CC_Subject__c, CC_Canal_Procedencia__c,CC_Id_Cognitive__c,CC_Login_Agente_Chat_Atendido__c, CC_Transferir__c, CC_Espacio_Transfer__c, CC_Categoria_Transfer__c, (SELECT Id FROM LiveChatTranscriptEvents WHERE Type = 'LeaveVisitor')
                                             FROM LiveChatTranscript
                                             WHERE Id = :recordId];
        
        if (result.size()>0){
            output.Id=result[0].Id;
            output.Canal = result[0].CC_Canal_Procedencia__c;
            output.Subject = result[0].CC_Subject__c;
            output.Tipo = result[0].CC_Tipo__c;
            output.Aplicacion = result[0].CC_Aplicacion__c;
            
            if(result[0].CC_Transferir__c == true){
                output.Espacio = result[0].CC_Espacio_Transfer__c;
                output.Categoria = result[0].CC_Categoria_Transfer__c;    
            }else{
                output.Espacio = result[0].CC_Espacio__c;
                output.Categoria = result[0].CC_Categoria__c;    
            }
            
            output.Idioma = result[0].CC_Idioma__c;
            output.Estado = result[0].Status;
            output.CognitiveId = result[0].CC_Id_Cognitive__c;
            output.AgentChatAtendido = result[0].CC_Login_Agente_Chat_Atendido__c;
            output.VisitorDesconectado = (result[0].LiveChatTranscriptEvents.size() > 0);
            
        }     
        return output;
    }
        
    //Case    
    global static CC_WS_Routing_Output CC_Case(Id recordId){
        CC_WS_Routing_Output output= new CC_WS_Routing_Output();
        List<Case> result =  [SELECT Id, Description, CC_Canal_Procedencia__c,Status,CC_Idioma__c
                                 FROM Case
                                WHERE Id = :recordId];
        
        if (result.size()>0){
            output.Id=result[0].Id;
            output.Canal = result[0].CC_Canal_Procedencia__c;
            output.Subject = result[0].Description;
            output.Tipo = '';
            output.Aplicacion ='';
            output.Espacio = '';
            output.Categoria = '';
            output.Idioma = result[0].CC_Idioma__c;
            output.Estado = result[0].Status;
        }     
        return output;
    }        
    
    global class PendingServiceRoutingNoExiste_Exception extends Exception {}
    global class UsuarioNoDisponible_Exception extends Exception {}
    global class WorkItemIdAsignado_Exception extends Exception {}
    global static String CC_AgentWork(String pendingId) {
        return CC_AgentWork(pendingId, null, null, null, null, null);
    }
    global static String CC_AgentWork(String pendingServiceRoutingId, String ticketId, String proxyClientId, String interactionId, String usuario, String place) {
        //Comprueba que existe un trabajo en la cola pendiente de asignar
        List<PendingServiceRouting> pendingRouting = [SELECT Id, WorkItemId, ServiceChannelId FROM PendingServiceRouting
                                                       WHERE Id = :pendingServiceRoutingId];
        if (pendingRouting.size() == 0) {
            throw new PendingServiceRoutingNoExiste_Exception('No existe PendingServiceRouting');
        }
        
        //Comprueba que el usuario esté disponible en omnichannel
        String userId = UserInfo.getUserId();
        List<UserServicePresence> presencia = [SELECT Id, IsAway, IsCurrentState, ServicePresenceStatusId FROM UserServicePresence
                                                WHERE UserId = :userId AND IsCurrentState = true];
        if (presencia.size() == 0 || presencia[0].IsAway) {
            throw new UsuarioNoDisponible_Exception('Usuario no disponible');
        }
        
        //Comprueba que no exista ya un trabajo asignado
        List<AgentWork> enCurso = [SELECT Id FROM AgentWork
                                    WHERE WorkItemId = :pendingRouting[0].WorkItemId AND Status IN ('Assigned','Opened')];
        if (enCurso.size() > 0) {
            throw new WorkItemIdAsignado_Exception('WorkItemId ya asignado');
        } 
        
        //Crea el trabajo
        AgentWork work = new AgentWork();
        work.ServiceChannelId = pendingRouting[0].ServiceChannelId;
        work.WorkItemId = pendingRouting[0].WorkItemId;
        work.UserId = userId;
        work.PendingServiceRoutingId = pendingServiceRoutingId;
        work.CC_TicketId__c = ticketId;
        work.CC_ProxyClientId__c = proxyClientId;
        work.CC_InteractionId__c = interactionId;
        work.CC_Place__c = place;
        work.CC_AgentLogin__c = usuario;
        insert work;

        return work.Id;
    }
}