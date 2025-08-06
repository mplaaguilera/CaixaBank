@IsTest
private class CSBD_WS_AVEAltaCitaTest {
    
    @TestSetup
    static void setup() {       
        // Crear el Integration Setting
        CBK_IntegrationSetting__c integrationSetting = new CBK_IntegrationSetting__c();
        integrationSetting.Name = 'CSBD_AVE_AltaCita';
        integrationSetting.NamedCredential__c = 'callout:CSBD_AVE_Named_Credentials/altaCita';
        insert integrationSetting;  
        
        // Crear el Custom Setting de Cita Gestor
        CSBD_CitaGestorSetting__c citaGestorSetting = new CSBD_CitaGestorSetting__c();
        citaGestorSetting.Name = 'Default';
        citaGestorSetting.CSBD_Origen_AVE__c = 'P';
        citaGestorSetting.CSBD_Estado_AVE__c = 'A';
        citaGestorSetting.CSBD_DispGestor_AVE__c = 'S';
        insert citaGestorSetting;
    }
    
    @IsTest
    static void testAltaCitaGestorSuccess() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            // Preparar datos de prueba
            Map<String, Object> params = new Map<String, Object>();
            params.put('empleadoEx', '29197');
            params.put('centroEx', '001');
            params.put('asunto', 'Consulta de prueba');
            params.put('fecContacto', '2024-03-20');
            params.put('horaIni', '10:00');
            params.put('medio', 'PRESENCIAL');
            params.put('numperso', '123456');
            params.put('accName', 'Cliente Test');
            
            // Configurar el mock de la respuesta HTTP
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 200,
                'status' => 'OK',
                'tipoIntegracion' => 'CSBD_AVE_AltaCita',
                'tipoRespuesta' => 'OK',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));
            
            // Ejecutar el método
            Test.startTest();
                Map<String, Object> resultado = CSBD_WS_AVEAltaCita.altaCitaGestor(params);
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals('OK', resultado.get('result'), 'El resultado debería ser OK');
            System.assertNotEquals(null, resultado.get('body'), 'Debería existir un cuerpo en la respuesta');
            
            // Verificar los datos de la respuesta
            CSBD_WS_AVEAltaCita.RespuestaAltaContacto respuesta = 
                (CSBD_WS_AVEAltaCita.RespuestaAltaContacto)resultado.get('body');
            System.assertEquals('OK', respuesta.resultat, 'El resultado debería ser OK');
        }
    }
    
    @IsTest
    static void testAltaCitaGestorError() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {    
            // Preparar datos de prueba con datos inválidos
            Map<String, Object> params = new Map<String, Object>();
            params.put('empleadoEx', '');
            params.put('centroEx', '001');
            params.put('asunto', 'Consulta de prueba');
            params.put('fecContacto', '2024-03-20');
            params.put('horaIni', '10:00');
            params.put('medio', 'PRESENCIAL');
            params.put('numperso', '123456');
            params.put('accName', 'Cliente Test');
            
            // Ejecutar el método
            Test.startTest();
                Map<String, Object> resultado = CSBD_WS_AVEAltaCita.altaCitaGestor(params);
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assertNotEquals(null, resultado.get('errorMessage'), 'Debería existir un mensaje de error');
        }
    }
    
    @IsTest
    static void testAltaCitaGestorHttpError() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            // Preparar datos de prueba
            Map<String, Object> params = new Map<String, Object>();
            params.put('empleadoEx', '29197');
            params.put('centroEx', '001');
            params.put('asunto', 'Consulta de prueba');
            params.put('fecContacto', '2024-03-20');
            params.put('horaIni', '10:00');
            params.put('medio', 'PRESENCIAL');
            params.put('numperso', '123456');
            params.put('accName', 'Cliente Test');
            
            // Configurar el mock de la respuesta HTTP con error
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 500,
                'status' => 'Error',
                'tipoIntegracion' => 'CSBD_AVE_AltaCita',
                'tipoRespuesta' => 'KO',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));
            
            // Ejecutar el método
            Test.startTest();
                Map<String, Object> resultado = CSBD_WS_AVEAltaCita.altaCitaGestor(params);
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assertNotEquals(null, resultado.get('errorMessage'), 'Debería existir un mensaje de error');
        }
    }
}