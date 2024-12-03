@isTest public class CC_WS_Routing_Test {

    @isTest
    public static void getDataTest()
    {
        // Preparacion para las distintas request que vamos a realizar
        RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        RestContext.request = request;
        RestResponse response = new RestResponse();
        RestContext.response = response;
        CC_WS_Routing.CC_WS_Routing_Output output;

        // Comprobar que podemos recuperar los datos de un caso
        Case caso = new Case(Description='Test Description', Status='Activo');
        insert caso;
        request.requestUri = '/services/apexrest/CC_Routing/' + caso.Id;

        CC_WS_Routing.getData();
        System.assertNotEquals(null, response.responseBody);
        output = (CC_WS_Routing.CC_WS_Routing_Output)Json.deserialize(response.responseBody.toString(), CC_WS_Routing.CC_WS_Routing_Output.class);
        System.assertEquals(caso.Id, output.Id);
        System.assertEquals(caso.Description, output.Subject);
        System.assertEquals(caso.Status, output.Estado);

        // Comprobar que podemos recuperar un chat transcript
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Subject__c = 'Test Subject',
            LiveChatVisitorId = liveChatVisitor.Id
        );
        insert liveChatTranscript;
        request.requestUri = '/services/apexrest/CC_Routing/' + liveChatTranscript.Id;

        CC_WS_Routing.getData();
        System.assertNotEquals(null, response.responseBody);
        output = (CC_WS_Routing.CC_WS_Routing_Output)Json.deserialize(response.responseBody.toString(), CC_WS_Routing.CC_WS_Routing_Output.class);
        System.assertEquals(liveChatTranscript.Id, output.Id);
        System.assertEquals(liveChatTranscript.CC_Subject__c, output.Subject);
        System.assertEquals(liveChatTranscript.Status, output.Estado);

        // Comprobar que devuelve correctamente el mensaje de error si no soporta el objeto que se le pide
        request.requestUri = '/services/apexrest/CC_Routing/' + liveChatVisitor.Id;

        CC_WS_Routing.getData();
        System.assertNotEquals(null, response.responseBody);
        System.assertEquals('No existe registro', response.responseBody.toString());
    }

    @isTest
    public static void AgentWorkTest() {
        try {
            String workId = CC_WS_Routing.CC_AgentWork('');
            System.assert(false);
        }
        catch (Exception excepcion) {
            System.assertEquals('CC_WS_Routing.PendingServiceRoutingNoExiste_Exception', excepcion.getTypeName());
        }

        /*
        // NOTE: El siguiente código es un intento para probar la parte de CC_AgentWork. El código no
        // funciona ya que hay un problema al hacer el insert del PendingServiceRouting.
        // Una solución a probar sería añadir un caso a la cola CC_External_Routing y esto debería crear el objeto
        // que queremos insertar de forma automática
        
        ServiceChannel serviceChannel = [SELECT Id FROM ServiceChannel WHERE DeveloperName = 'sfdc_liveagent'];
        Case caso = new Case();
        insert caso;

        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Subject__c = 'Test Subject',
            LiveChatVisitorId = liveChatVisitor.Id,
            CaseId = caso.Id
        );
        insert liveChatTranscript;

        PendingServiceRouting PSR = new PendingServiceRouting(
            RoutingType='QueueBased',
            ServiceChannelId=serviceChannel.Id,
            WorkItemId = liveChatTranscript.Id
        );
        insert PSR;

        CC_WS_Routing.CC_AgentWork(PSR.Id);*/
    }
}