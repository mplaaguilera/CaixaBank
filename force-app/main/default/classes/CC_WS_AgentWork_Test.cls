@isTest
public class CC_WS_AgentWork_Test {
 
    @isTest(SeeAllData=True)
    public static void getAgentWorkInfo()
    {
        //Se configuran los valores de la lista de
        configurarRelacionEstadoMotivo();

        //Crea el trabajo
        ServiceChannel servChannel = [SELECT FIELDS(STANDARD) FROM ServiceChannel WHERE MasterLabel = 'casesChannel' LIMIT 1];
        
        // Comprobar que podemos recuperar los datos de un caso
        User usuario = [SELECT Id FROM User WHERE isActive = true LIMIT 1];
          try {
            Case caso = new Case(Description='Test Description', Status='Activo');
            insert caso;

            //Crea el trabajo
            AgentWork work = new AgentWork();
            work.ServiceChannelId = servChannel.Id;
            work.WorkItemId = caso.Id;
            work.UserId = usuario.Id;
            work.CC_TicketId__c = '27672';
            work.CC_ProxyClientId__c = '4899';
            work.CC_InteractionId__c = 'IN00001';
            work.CC_Place__c = '1242';
            work.CC_AgentLogin__c = '1142';
            insert work;
        }catch(Exception e) {
            System.debug(LoggingLevel.INFO, 'Service channel with id '+servChannel.Id+' is invalid');
        }
 
        AgentWork agentWrk = [SELECT Id, WorkItemId, CC_TicketId__c, CC_ProxyClientId__c, CC_InteractionId__c, CC_Place__c, CC_AgentLogin__c FROM AgentWork WHERE AcceptDateTime = null ORDER BY CreatedDate DESC LIMIT 1];
        
        // Preparacion para las distintas request que vamos a realizar
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        RestContext.request = request;
        request.requestUri = '/services/apexrest/CC_GetAgentWorkInfo/' + agentWrk.WorkItemId;

        RestResponse response = new RestResponse();
        RestContext.response = response;
        CC_WS_AgentWork.CC_AgentWork_Output output;

        Test.startTest();
        CC_WS_AgentWork.getData();
        System.assertNotEquals(null, response.responseBody);
        output = (CC_WS_AgentWork.CC_AgentWork_Output)Json.deserialize(response.responseBody.toString(), CC_WS_AgentWork.CC_AgentWork_Output.class);
        Test.stopTest();

        System.debug('output status ' + output.status);
        System.debug('output motivoStop ' + output.motivoStop);
        /*System.assertEquals(agentWrk.Id, output.Id);
        System.assertEquals(agentWrk.WorkItemId, output.WorkItemId);
        System.assertEquals(agentWrk.CC_TicketId__c, output.ticketId);
        System.assertEquals(agentWrk.CC_ProxyClientId__c, output.proxyClientId);
        System.assertEquals(agentWrk.CC_InteractionId__c, output.interactionId);
        System.assertEquals(agentWrk.CC_Place__c, output.place);
        System.assertEquals(agentWrk.CC_AgentLogin__c, output.agentLogin);
        System.assert(!output.chatAceptado); //No aceptado
        System.assertNotEquals('UNKNOWN', output.motivoStop);*/
    }

    @isTest
    public static void getAgentWorkInfoAgentWorkNoEncontrado() 
    {
        //Se configuran los valores de la lista de
        configurarRelacionEstadoMotivo();

        // Preparacion para las distintas request que vamos a realizar
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        RestContext.request = request;
        request.requestUri = '/services/apexrest/CC_GetAgentWorkInfo/' + '5007a00000FqWTmAAN';

        RestResponse response = new RestResponse();
        RestContext.response = response;
        CC_WS_AgentWork.CC_AgentWork_Output output;

        Test.startTest();
            CC_WS_AgentWork.getData();
            System.assertNotEquals(null, response.responseBody);
            output = (CC_WS_AgentWork.CC_AgentWork_Output)Json.deserialize(response.responseBody.toString(), CC_WS_AgentWork.CC_AgentWork_Output.class);
        Test.stopTest();

        System.assertEquals('5007a00000FqWTmAAN', output.Id);
        System.assertEquals('5007a00000FqWTmAAN', output.WorkItemId);
        System.assert(!output.chatAceptado); //No aceptado
        System.assertEquals('CANCELED_BEFORE_ASSIGN', output.motivoStop); //Default
    }

    @isTest
    public static void getAgentWorkNoExisteRegistro()
    {
        // Preparacion para las distintas request que vamos a realizar
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        RestContext.request = request;
        request.requestUri = '/services/apexrest/CC_GetAgentWorkInfo/'+null;

        RestResponse response = new RestResponse();
        RestContext.response = response;
        CC_WS_AgentWork.CC_AgentWork_Output output;

        Test.startTest();
            CC_WS_AgentWork.getData();
        Test.stopTest();

        System.assertNotEquals(null, response.responseBody);
        System.assertEquals('No existe registro', response.responseBody.toString());
    }

    @isTest(SeeAllData=True)
    public static void getAgentWorkMotivoStopUnknown()
    {
        //Desactivamos la configuración de la lista
        List<CC_Lista_Valores__c> relacionEstadoMotivo = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'Widget: Relación Estado - Motivo' AND CC_Activa__c = true];
        if (!relacionEstadoMotivo.isEmpty())
        {
            relacionEstadoMotivo[0].CC_Activa__c = false;

            update relacionEstadoMotivo;
        }

        //Crea el trabajo
        ServiceChannel servChannel = [SELECT FIELDS(STANDARD) FROM ServiceChannel WHERE MasterLabel = 'casesChannel' LIMIT 1];
        System.debug(servChannel);
        // Comprobar que podemos recuperar los datos de un caso
        User usuario = [SELECT Id FROM User WHERE isActive = true LIMIT 1];
          try {
            Case caso = new Case(Description='Test Description', Status='Activo');
            insert caso;

            //Crea el trabajo
            AgentWork work = new AgentWork();
            work.ServiceChannelId = servChannel.Id;
            work.WorkItemId = caso.Id;
            work.UserId = usuario.Id;
            work.CC_TicketId__c = '27672';
            work.CC_ProxyClientId__c = '4899';
            work.CC_InteractionId__c = 'IN00001';
            work.CC_Place__c = '1242';
            work.CC_AgentLogin__c = '1142';
            insert work;
        }catch(Exception e) {
            System.debug(LoggingLevel.INFO, 'Service channel with id '+servChannel.Id+' is invalid');
        }
 
        AgentWork agentWrk = [SELECT Id, WorkItemId, CC_TicketId__c, CC_ProxyClientId__c, CC_InteractionId__c, CC_Place__c, CC_AgentLogin__c FROM AgentWork WHERE AcceptDateTime = null ORDER BY CreatedDate DESC LIMIT 1];
        
        // Preparacion para las distintas request que vamos a realizar
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        RestContext.request = request;
        request.requestUri = '/services/apexrest/CC_GetAgentWorkInfo/' + agentWrk.WorkItemId;

        RestResponse response = new RestResponse();
        RestContext.response = response;
        CC_WS_AgentWork.CC_AgentWork_Output output;

        Test.startTest();
        CC_WS_AgentWork.getData();
        System.assertNotEquals(null, response.responseBody);
        output = (CC_WS_AgentWork.CC_AgentWork_Output)Json.deserialize(response.responseBody.toString(), CC_WS_AgentWork.CC_AgentWork_Output.class);
        Test.stopTest();

        /*System.assertEquals(agentWrk.Id, output.Id);
        System.assertEquals(agentWrk.WorkItemId, output.WorkItemId);
        System.assertEquals(agentWrk.CC_TicketId__c, output.ticketId);
        System.assertEquals(agentWrk.CC_ProxyClientId__c, output.proxyClientId);
        System.assertEquals(agentWrk.CC_InteractionId__c, output.interactionId);
        System.assertEquals(agentWrk.CC_Place__c, output.place);
        System.assertEquals(agentWrk.CC_AgentLogin__c, output.agentLogin);
        System.assert(!output.chatAceptado); //No aceptado
        System.assertEquals('UNKNOWN', output.motivoStop);*/
    }

    private static void configurarRelacionEstadoMotivo()
    {
        List<CC_Lista_Valores__c> relacionEstadoMotivo = [SELECT Id, CC_Activa__c, Name, CC_Valor__c, CC_Valor_SFDC__c 
                                                            FROM CC_Lista_Valores__c WHERE Name = 'Widget: Relación Estado - Motivo' AND CC_Activa__c = true];

        if (relacionEstadoMotivo.isEmpty())
        {
            //Obtenemos los RecordTypes de la lista de valores
            Id listaRelacionRT = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
            Id listaValorRT = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
            
            //Creamos los registros que relacionan el Estado con el Motivo a enviar a Genesys
            relacionEstadoMotivo = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c listaRelacionEstadoMotivo = new CC_Lista_Valores__c();
            listaRelacionEstadoMotivo.RecordTypeId = listaRelacionRT;
            listaRelacionEstadoMotivo.Name = 'Widget: Relación Estado - Motivo';
            listaRelacionEstadoMotivo.CC_Activa__c = true;
            insert listaRelacionEstadoMotivo;

            CC_Lista_Valores__c estadoMotivo = new CC_Lista_Valores__c();
            estadoMotivo.RecordTypeId = listaValorRT;
            estadoMotivo.Name = 'Default';
            estadoMotivo.CC_Activa__c = true;
            estadoMotivo.CC_Valor__c = 'CANCELED_BEFORE_ASSIGN';
            estadoMotivo.CC_Valor_SFDC__c = 'Default';
            estadoMotivo.CC_Lista__c = listaRelacionEstadoMotivo.Id;
            relacionEstadoMotivo.add(estadoMotivo);

            CC_Lista_Valores__c estadoMotivo2 = new CC_Lista_Valores__c();
            estadoMotivo2.RecordTypeId = listaValorRT;
            estadoMotivo2.Name = 'Unavailable';
            estadoMotivo2.CC_Activa__c = true;
            estadoMotivo2.CC_Valor__c = 'AGENT_UNAVAILABLE';
            estadoMotivo2.CC_Valor_SFDC__c = 'Unavailable';
            estadoMotivo2.CC_Lista__c = listaRelacionEstadoMotivo.Id;
            relacionEstadoMotivo.add(estadoMotivo2);

            CC_Lista_Valores__c estadoMotivo3 = new CC_Lista_Valores__c();
            estadoMotivo3.RecordTypeId = listaValorRT;
            estadoMotivo3.Name = 'Assigned';
            estadoMotivo3.CC_Activa__c = true;
            estadoMotivo3.CC_Valor__c = 'ASSIGNED';
            estadoMotivo3.CC_Valor_SFDC__c = 'Assigned';
            estadoMotivo3.CC_Lista__c = listaRelacionEstadoMotivo.Id;
            relacionEstadoMotivo.add(estadoMotivo3);
            
            CC_Lista_Valores__c estadoMotivo4 = new CC_Lista_Valores__c();
            estadoMotivo4.RecordTypeId = listaValorRT;
            estadoMotivo4.Name = 'Canceled';
            estadoMotivo4.CC_Activa__c = true;
            estadoMotivo4.CC_Valor__c = 'CLIENT_CANCELED';
            estadoMotivo4.CC_Valor_SFDC__c = 'Canceled';
            estadoMotivo4.CC_Lista__c = listaRelacionEstadoMotivo.Id;
            relacionEstadoMotivo.add(estadoMotivo4);
            
            CC_Lista_Valores__c estadoMotivo5 = new CC_Lista_Valores__c();
            estadoMotivo5.RecordTypeId = listaValorRT;
            estadoMotivo5.Name = 'Closed';
            estadoMotivo5.CC_Activa__c = true;
            estadoMotivo5.CC_Valor__c = 'CLOSED';
            estadoMotivo5.CC_Valor_SFDC__c = 'Closed';
            estadoMotivo5.CC_Lista__c = listaRelacionEstadoMotivo.Id;
            relacionEstadoMotivo.add(estadoMotivo5);
            
            CC_Lista_Valores__c estadoMotivo6 = new CC_Lista_Valores__c();
            estadoMotivo6.RecordTypeId = listaValorRT;
            estadoMotivo6.Name = 'Declined';
            estadoMotivo6.CC_Activa__c = true;
            estadoMotivo6.CC_Valor__c = 'AGENT_DECLINED';
            estadoMotivo6.CC_Valor_SFDC__c = 'Declined';
            estadoMotivo6.CC_Lista__c = listaRelacionEstadoMotivo.Id;
            relacionEstadoMotivo.add(estadoMotivo6);
            
            CC_Lista_Valores__c estadoMotivo7 = new CC_Lista_Valores__c();
            estadoMotivo7.RecordTypeId = listaValorRT;
            estadoMotivo7.Name = 'DeclinedOnPushTimeout';
            estadoMotivo7.CC_Activa__c = true;
            estadoMotivo7.CC_Valor__c = 'REQUEST_TIMEOUT';
            estadoMotivo7.CC_Valor_SFDC__c = 'DeclinedOnPushTimeout';
            estadoMotivo7.CC_Lista__c = listaRelacionEstadoMotivo.Id;
            relacionEstadoMotivo.add(estadoMotivo7);
            
            CC_Lista_Valores__c estadoMotivo8 = new CC_Lista_Valores__c();
            estadoMotivo8.RecordTypeId = listaValorRT;
            estadoMotivo8.Name = 'Opened';
            estadoMotivo8.CC_Activa__c = true;
            estadoMotivo8.CC_Valor__c = 'OPENED';
            estadoMotivo8.CC_Valor_SFDC__c = 'Opened';
            estadoMotivo8.CC_Lista__c = listaRelacionEstadoMotivo.Id;
            relacionEstadoMotivo.add(estadoMotivo8);

            insert relacionEstadoMotivo;   
        }
    }
}