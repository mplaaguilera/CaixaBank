@isTest
public with sharing class CBK_WS_RegistrarTicketOcp_Test {

    @isTest
    public static void testTipoLlamadaIdName() {

        OB_Parametrizacion__c campanya = new OB_Parametrizacion__c();
        campanya.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Campanya');
        campanya.Name = 'campaña test';
        campanya.OB_Codigo_Externo__c = 'campaña test';
        campanya.OB_Activo__c = true;
        insert campanya;

        OB_Parametrizacion__c familiaProducto = new OB_Parametrizacion__c();
        familiaProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
        familiaProducto.Name = 'familia producto test';
        insert familiaProducto;

        OB_Parametrizacion__c producto = new OB_Parametrizacion__c();
        producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
        producto.Name = 'producto test';
        producto.OB_Codigo_Externo__c = 'producto test';
        producto.OB_Parametrizacion_Padre__c = familiaProducto.Id;
        producto.OB_Activo__c = true;
        insert producto;

        OB_Parametrizacion__c relCampanyaProducto = new OB_Parametrizacion__c();
        relCampanyaProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Relacion_Campanya_Producto');
        relCampanyaProducto.OB_Parametrizacion_Padre__c = campanya.Id;
        relCampanyaProducto.OB_Parametrizacion_Relacionada__c = producto.Id;
        relCampanyaProducto.OB_Tipo_Validacion__c = 'BackOffice';
        insert relCampanyaProducto;

        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', new Map<String, Object>{
            'CC_ConnId__c' => 'connId1', 'OB_Estado__c' => 'OB_Pendiente_Grabacion_Negativa', 'OB_Campanya_Id__c' => campanya.Id, 'OB_Producto_Id__c' => producto.Id
        });
        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', new Map<String, Object>{
            'CC_ConnId__c' => 'connId2', 'OB_Estado__c' => 'OB_Pendiente_Grabacion', 'OB_Campanya_Id__c' => campanya.Id, 'OB_Producto_Id__c' => producto.Id
        });

        Map<Id, CC_Llamada__c> llamadas = new Map<Id, CC_Llamada__c>(
            [SELECT Name FROM CC_Llamada__c WHERE Id IN :new List<Id>{llamada1.Id, llamada2.Id}]
        );

        CBK_WS_RegistrarTicketOcp.TicketOcp ticket1 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket1.llamadaId = llamadas.get(llamada1.Id).Name;
        ticket1.ticketOcp = 'idOcp1';

        CBK_WS_RegistrarTicketOcp.TicketOcp ticket2 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket2.llamadaId = llamadas.get(llamada2.Id).Name;
        ticket2.ticketOcp = 'idOcp2';

        CBK_WS_RegistrarTicketOcp.Input entrada = new CBK_WS_RegistrarTicketOcp.Input();
        entrada.referencia = 'ref1';
        entrada.tipoLlamadaId = 'Name';
        entrada.ticketsOcp = new List<CBK_WS_RegistrarTicketOcp.TicketOcp>{ticket1, ticket2};

        //Petición
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/RegistrarTicketOcp';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(JSON.serialize(entrada));
        RestContext.request = request;

        Test.startTest();
        CBK_WS_RegistrarTicketOcp.Output salida = CBK_WS_RegistrarTicketOcp.registrarTicketOcp();
        Test.stopTest();

        System.assertEquals('OK', salida.resultado, 'La respuesta debería tener resultado = "OK"');
    }

    @isTest
    public static void testTipoLlamadaIdConnId() {

        OB_Parametrizacion__c campanya = new OB_Parametrizacion__c();
        campanya.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Campanya');
        campanya.Name = 'campaña test';
        campanya.OB_Codigo_Externo__c = 'campaña test';
        campanya.OB_Activo__c = true;
        insert campanya;

        OB_Parametrizacion__c familiaProducto = new OB_Parametrizacion__c();
        familiaProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
        familiaProducto.Name = 'familia producto test';
        insert familiaProducto;

        OB_Parametrizacion__c producto = new OB_Parametrizacion__c();
        producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
        producto.Name = 'producto test';
        producto.OB_Codigo_Externo__c = 'producto test';
        producto.OB_Parametrizacion_Padre__c = familiaProducto.Id;
        producto.OB_Activo__c = true;
        insert producto;

        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', new Map<String, Object>{
            'CC_ConnId__c' => 'connId1', 'OB_Campanya_Id__c' => campanya.Id, 'OB_Producto_Id__c' => producto.Id
        });
        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', new Map<String, Object>{
            'CC_ConnId__c' => 'connId2', 'OB_Campanya_Id__c' => campanya.Id, 'OB_Producto_Id__c' => producto.Id
        });

        Map<Id, CC_Llamada__c> llamadas = new Map<Id, CC_Llamada__c>(
            [SELECT CC_ConnId__c FROM CC_Llamada__c WHERE Id IN :new List<Id>{llamada1.Id, llamada2.Id}]
        );

        CBK_WS_RegistrarTicketOcp.TicketOcp ticket1 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket1.llamadaId = llamadas.get(llamada1.Id).CC_ConnId__c;
        ticket1.ticketOcp = 'idOcp1';

        CBK_WS_RegistrarTicketOcp.TicketOcp ticket2 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket2.llamadaId = llamadas.get(llamada2.Id).CC_ConnId__c;
        ticket2.ticketOcp = 'idOcp2';

        CBK_WS_RegistrarTicketOcp.Input entrada = new CBK_WS_RegistrarTicketOcp.Input();
        entrada.referencia = 'ref1';
        entrada.tipoLlamadaId = 'ConnId';
        entrada.ticketsOcp = new List<CBK_WS_RegistrarTicketOcp.TicketOcp>{ticket1, ticket2};

        //Petición
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/RegistrarTicketOcp';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(JSON.serialize(entrada));
        RestContext.request = request;

        Test.startTest();
        CBK_WS_RegistrarTicketOcp.Output salida = CBK_WS_RegistrarTicketOcp.registrarTicketOcp();
        Test.stopTest();

        System.assertEquals('OK', salida.resultado, 'La respuesta debería tener resultado = "OK"');
    }

    @isTest
    public static void testKoSinReferencia() {

        //Sin referencia
        CBK_WS_RegistrarTicketOcp.TicketOcp ticket1 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket1.llamadaId = 'llamada1';
        ticket1.ticketOcp = 'idOcp1';

        CBK_WS_RegistrarTicketOcp.TicketOcp ticket2 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket2.llamadaId = 'llamada2';
        ticket2.ticketOcp = 'idOcp2';

        CBK_WS_RegistrarTicketOcp.Input entrada = new CBK_WS_RegistrarTicketOcp.Input();
        entrada.referencia = '';
        entrada.tipoLlamadaId = 'Name';
        entrada.ticketsOcp = new List<CBK_WS_RegistrarTicketOcp.TicketOcp>{ticket1, ticket2};

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/RegistrarTicketOcp';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(JSON.serialize(entrada));
        RestContext.request = request;

        Test.startTest();
        CBK_WS_RegistrarTicketOcp.Output salida = CBK_WS_RegistrarTicketOcp.registrarTicketOcp();
        Test.stopTest();

        System.assertEquals('KO', salida.resultado, 'La respuesta debería tener resultado = "KO"');
    }

    @isTest
    public static void testKoSinTipoIdLlamada() {

        //Sin referencia
        CBK_WS_RegistrarTicketOcp.TicketOcp ticket1 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket1.llamadaId = 'llamada1';
        ticket1.ticketOcp = 'idOcp1';

        CBK_WS_RegistrarTicketOcp.TicketOcp ticket2 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket2.llamadaId = 'llamada2';
        ticket2.ticketOcp = 'idOcp2';

        CBK_WS_RegistrarTicketOcp.Input entrada = new CBK_WS_RegistrarTicketOcp.Input();
        entrada.referencia = 'ref1';
        entrada.tipoLlamadaId = '';
        entrada.ticketsOcp = new List<CBK_WS_RegistrarTicketOcp.TicketOcp>{ticket1, ticket2};

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/RegistrarTicketOcp';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(JSON.serialize(entrada));
        RestContext.request = request;

        Test.startTest();
        CBK_WS_RegistrarTicketOcp.Output salida = CBK_WS_RegistrarTicketOcp.registrarTicketOcp();
        Test.stopTest();

        System.assertEquals('KO', salida.resultado, 'La respuesta debería tener resultado = "KO"');
    }

    @isTest
    public static void testOkConErrores() {

        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', new Map<String, Object>{
            'CC_ConnId__c' => 'connId1', 'OB_Estado__c' => 'OB_Pendiente_Grabacion_Negativa'
        });
        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', new Map<String, Object>{
            'CC_ConnId__c' => 'connId2', 'OB_Estado__c' => 'OB_Pendiente_Grabacion'
        });

        Map<Id, CC_Llamada__c> llamadas = new Map<Id, CC_Llamada__c>(
            [SELECT Name FROM CC_Llamada__c WHERE Id IN :new List<Id>{llamada1.Id, llamada2.Id}]
        );

        CBK_WS_RegistrarTicketOcp.TicketOcp ticket1 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket1.llamadaId = llamadas.get(llamada1.Id).Name;
        ticket1.ticketOcp = 'idOcp1';

        CBK_WS_RegistrarTicketOcp.TicketOcp ticket2 = new CBK_WS_RegistrarTicketOcp.TicketOcp();
        ticket2.llamadaId = '';
        ticket2.ticketOcp = 'idOcp2';

        CBK_WS_RegistrarTicketOcp.Input entrada = new CBK_WS_RegistrarTicketOcp.Input();
        entrada.referencia = 'ref1';
        entrada.tipoLlamadaId = 'Name';
        entrada.ticketsOcp = new List<CBK_WS_RegistrarTicketOcp.TicketOcp>{ticket1, ticket2};

        //Petición
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/RegistrarTicketOcp';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf(JSON.serialize(entrada));
        RestContext.request = request;

        Test.startTest();
        CBK_WS_RegistrarTicketOcp.Output salida = CBK_WS_RegistrarTicketOcp.registrarTicketOcp();
        Test.stopTest();

        System.assertEquals('OK con errores', salida.resultado, 'La respuesta debería tener resultado = "OK con errores"');
    }
}