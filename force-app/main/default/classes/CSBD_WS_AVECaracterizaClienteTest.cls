@IsTest
private class CSBD_WS_AVECaracterizaClienteTest {
    
    @TestSetup
    static void setup() {
        User usuarioAdministrador = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(usuarioAdministrador) {
            CBK_IntegrationSetting__c integrationSetting = new CBK_IntegrationSetting__c();
            integrationSetting.Name = 'CSBD_AVE_CaracterizaCliente';
            integrationSetting.NamedCredential__c = 'callout:CSBD_AVE_Named_Credentials/caracteriza';
            insert integrationSetting;
        }

    }
    
    @IsTest
    static void testCaracterizaClienteSuccess() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            // Preparar datos de prueba
            Map<String, Object> params = new Map<String, Object>();
            params.put('numperso', '123456');
            
            // Configurar el mock de la respuesta HTTP
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 200,
                'status' => 'OK',
                'tipoIntegracion' => 'CSBD_AVE_Caracteriza',
                'tipoRespuesta' => 'OK',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));
            
            // Ejecutar el método
            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_AVECaracterizaCliente.caracterizaCliente(params);
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals('OK', resultado.get('result'), 'El resultado debería ser OK');
            System.assertNotEquals(null, resultado.get('datosCliente'), 'Debería existir datos del cliente');
            
            // Verificar los datos del cliente
            CSBD_WS_AVECaracterizaCliente.RespuestaClienteDigital datosCliente = 
                (CSBD_WS_AVECaracterizaCliente.RespuestaClienteDigital)resultado.get('datosCliente');
            System.assertEquals('57434', datosCliente.empleado1, 'El empleado1 debería ser 57434');
            System.assertEquals('E', datosCliente.gestorOEAP1, 'El gestorOEAP1 debería ser E');
            System.assertEquals('2371', datosCliente.oficina1, 'La oficina1 debería ser 2371');
        }
    }
    
    @IsTest
    static void testCaracterizaClienteError() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            // Preparar datos de prueba con número de persona inválido
            Map<String, Object> params = new Map<String, Object>();
            params.put('numperso', '');
            
            // Ejecutar el método
            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_AVECaracterizaCliente.caracterizaCliente(params);
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assertEquals('El número de persona no está informado', resultado.get('errorMessage'), 
                'El mensaje de error debería indicar que el número de persona no está informado');
        }
    }
    
    @IsTest
    static void testCaracterizaClienteHttpError() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
            // Preparar datos de prueba
            Map<String, Object> params = new Map<String, Object>();
            params.put('numperso', '123456');
            
            // Configurar el mock de la respuesta HTTP con error
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 500,
                'status' => 'Error',
                'tipoIntegracion' => 'CSBD_AVE_Caracteriza',
                'tipoRespuesta' => 'KO',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));
            
            // Ejecutar el método
            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_AVECaracterizaCliente.caracterizaCliente(params);
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assertNotEquals(null, resultado.get('errorMessage'), 'Debería existir un mensaje de error');
        }
    }
}