@isTest
public with sharing class OB_Llamada_Test {

    @TestSetup
    static void testSetup() {

        OB_Parametrizacion__c campanya = new OB_Parametrizacion__c();
        campanya.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Campanya');
        campanya.Name = 'campaña test';
        campanya.OB_Codigo_Externo__c = '1234';
        insert campanya;

        OB_Parametrizacion__c familiaProducto = new OB_Parametrizacion__c();
        familiaProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Familia_Producto');
        familiaProducto.Name = 'familia producto test';
        familiaProducto.OB_Envio_GDD__c = true;
        familiaProducto.OB_Codigo_GDD__c = 'TAV0';
        familiaProducto.OB_Area_ALF__c = '13';
        familiaProducto.OB_Accion_Alta__c = 'CONT';
        familiaProducto.OB_Formato_Codigo_Contrato__c = '9999.999.999999999';
        insert familiaProducto;

        OB_Parametrizacion__c producto = new OB_Parametrizacion__c();
        producto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Producto');
        producto.Name = 'producto test';
        producto.OB_Parametrizacion_Padre__c = familiaProducto.Id;
        producto.OB_Codigo_Externo__c = '5678';
        insert producto;

        OB_Parametrizacion__c relacionCampanyaProducto = new OB_Parametrizacion__c();
        relacionCampanyaProducto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('OB_Parametrizacion__c', 'OB_Relacion_Campanya_Producto');
        relacionCampanyaProducto.Name = 'temp';
        relacionCampanyaProducto.OB_Parametrizacion_Padre__c = campanya.Id;
        relacionCampanyaProducto.OB_Parametrizacion_Relacionada__c = producto.Id;
        relacionCampanyaProducto.OB_Tipo_Validacion__c = 'BackOffice';
        relacionCampanyaProducto.OB_Envio_GDD__c = true;
        insert relacionCampanyaProducto;

        EmailTemplate plantilla = new EmailTemplate();
        plantilla.isActive = true;
        plantilla.Name = 'plantilla test outbound 1';
        plantilla.DeveloperName = 'OB_Plantilla_Test_' + System.now().getTime();
        plantilla.TemplateType = 'text';
        plantilla.FolderId = UserInfo.getUserId();
        plantilla.HtmlValue = 'cuerpo plantilla';

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert plantilla;
        }
    }
    

    @isTest
    public static void crearLlamada() {
        CC_Llamada__c llamada = OB_Llamada.crearLlamada(
            'OB_Cliente',
            new Map<String, Object>{'OB_Datos_Adicionales__c' => 'test'}
        );

        System.assertEquals(
            'test',
            [SELECT OB_Datos_Adicionales__c FROM CC_Llamada__c WHERE Id = :llamada.Id].OB_Datos_Adicionales__c,
            'La llamada no se ha creado correctamente'
        );
    }

    @isTest
    public static void accionesCambioPropietario() {
        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', null);
        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', null);
        List<Id> idLlamadas = new List<Id>{llamada1.Id, llamada2.Id};

        Test.startTest();
        OB_Llamada.accionesCambioPropietario(idLlamadas);
        Test.stopTest();

        System.assertEquals(
            [SELECT Count() FROM Task WHERE WhatId IN :idLlamadas AND Type = 'Cambio de propietario' AND Status = 'Completed'], 
            2, 
            'No se han creado las tareas correspondientes al cambio de propietario'
        );
    }

    @isTest
    public static void accionesValidar() {
        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', null);
        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', null);
        List<Id> idLlamadas = new List<Id>{llamada1.Id, llamada2.Id};

        Test.startTest();
        OB_Llamada.accionesValidar(idLlamadas);
        Test.stopTest();

        System.assertEquals(
            [SELECT Count() FROM Task WHERE WhatId IN :idLlamadas AND Type = 'Validada' AND Status = 'Completed'], 
            2, 
            'No se han creado las tareas correspondientes a la validación'
        );
    }

    @isTest
    public static void accionesRechazar() {
        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', null);
        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', null);
        List<Id> idLlamadas = new List<Id>{llamada1.Id, llamada2.Id};

        Test.startTest();
        OB_Llamada.accionesRechazar(idLlamadas);
        Test.stopTest();

        System.assertEquals(
            [SELECT Count() FROM Task WHERE WhatId IN :idLlamadas AND Type = 'Rechazada' AND Status = 'Completed'], 
            2, 
            'No se han creado las tareas correspondientes al rechazo'
        );
    }

    @isTest
    public static void envioGdd() {
        Map<String, Object> camposLlamada = new Map<String, Object>();
        camposLlamada.put('OB_Campanya_Id__c', [SELECT Id FROM OB_Parametrizacion__c WHERE Name = 'campaña test'].Id);
        camposLlamada.put('OB_Producto_Id__c', [SELECT Id FROM OB_Parametrizacion__c WHERE Name = 'producto test'].Id);

        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', camposLlamada);
        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', camposLlamada);
        List<Id> idLlamadas = new List<Id>{llamada1.Id, llamada2.Id};

        Test.startTest();
        OB_Llamada.envioGdd(idLlamadas);
        Test.stopTest();

        System.assertEquals(
            [SELECT Count() FROM Task WHERE WhatId IN :idLlamadas AND Type = 'Envío a GDD' AND Status = 'Completed'], 
            2,
            'No se han creado las tareas correspondientes al envío a GDD'
        );
    }

    @isTest
    public static void enviarCorreo() {
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.LastName = 'Contacto Test 1';
        contacto.Email = 'test@test.com';
        insert contacto;

        Map<String, Object> camposLlamadas = new Map<String, Object>{'OB_Direccion_Correo__c' => 'test@test.com'};
        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', camposLlamadas);
        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', camposLlamadas);
        List<Id> idLlamadas = new List<Id>{llamada1.Id, llamada2.Id};

        Test.startTest();
        OB_Llamada.enviarCorreo(idLlamadas, 'plantilla test outbound 1');
        Test.stopTest();

        System.assertEquals(
            [SELECT Count() FROM EmailMessage WHERE RelatedToId IN :idLlamadas AND Status = '3'], //3: Sent
            2,
            'No se han enviado los correos.'
        );
    }

    @isTest
    public static void enviarSms() {
        Contact contacto = new Contact();
        contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
        contacto.LastName = 'Contacto Test 1';
        contacto.Email = 'test@test.com';
        insert contacto;

        Map<String, Object> camposLlamadas = new Map<String, Object>{'OB_Telefono__c' => '666777888'};
        CC_Llamada__c llamada1 = OB_Llamada.crearLlamada('OB_Cliente', camposLlamadas);
        CC_Llamada__c llamada2 = OB_Llamada.crearLlamada('OB_Cliente', camposLlamadas);
        List<Id> idLlamadas = new List<Id>{llamada1.Id, llamada2.Id};

        Test.startTest();
        OB_Llamada.enviarSms(idLlamadas, 'plantilla test outbound 1');
        Test.stopTest();

        System.assertEquals(
            [SELECT Count() FROM Task WHERE WhatId IN :idLlamadas AND Type = 'Envío de SMS'], //3: Sent
            2,
            'No se han enviado los SMS.'
        );
    }

    @isTest
    public static void datosUrlGrabacion() {
        Map<String, Object> camposLlamadas = new Map<String, Object>{'CBK_Ticket_OCP__c' => '1234567890123456789'};
        CC_Llamada__c llamada = OB_Llamada.crearLlamada('OB_Cliente', camposLlamadas);
        
        Test.startTest();
        Map<String, String> datos = OB_Llamada.datosUrlGrabacion(llamada.Id);
        Test.stopTest();

        System.assert(
            datos.containsKey('tiquet')
            && datos.containsKey('appid')
            && datos.containsKey('username')
            && datos.containsKey('canal')
            && datos.containsKey('publicKey')
            && datos.containsKey('baseUrl')
            && datos.containsKey('timestamp'),
            'No se han podido recuperar los datos necesarios para generar la URL de la grabación'
        );
    }

    @isTest
    public static void erroresLlamada() {
        CC_Llamada__c llamada = OB_Llamada.crearLlamada('OB_Cliente', null);

        Map<String, Object> camposTareaError1 = new Map<String, Object>();
        camposTareaError1.put('Type', 'Error');
        camposTareaError1.put('Subject', 'Error en Alta');
        camposTareaError1.put('Status', 'Completed');
        camposTareaError1.put('Description', 'desc1');
        OB_Activity.crearActividad(llamada.Id, camposTareaError1);
        
        Map<String, Object> camposTareaError2 = new Map<String, Object>();
        camposTareaError2.put('Type', 'Error');
        camposTareaError2.put('Subject', 'Error en Alta');
        camposTareaError2.put('Status', 'Completed');
        camposTareaError2.put('Description', 'desc2');
        OB_Activity.crearActividad(llamada.Id, camposTareaError2);

        Test.startTest();
        Map<Id, Map<String, Object>> erroresLlamada = OB_Llamada.erroresLlamada(llamada.Id);
        Test.stopTest();

        System.assertEquals(2, erroresLlamada.size(), 'El número de errores no coincide');
    }
}