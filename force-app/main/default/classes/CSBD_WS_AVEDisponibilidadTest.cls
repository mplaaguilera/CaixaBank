@IsTest
private class CSBD_WS_AVEDisponibilidadTest {
    
    @TestSetup
    static void setup() {       
        // Crear el Integration Setting
        CBK_IntegrationSetting__c integrationSetting = new CBK_IntegrationSetting__c();
        integrationSetting.Name = 'CSBD_AVE_DisponibilidadCita';
        integrationSetting.NamedCredential__c = 'callout:CSBD_AVE_Named_Credentials/disponibilidad';
        insert integrationSetting;  
        
        // Crear el Custom Setting de Cita Gestor
        CSBD_CitaGestorSetting__c citaGestorSetting = new CSBD_CitaGestorSetting__c();
        citaGestorSetting.Name = 'Default';
        citaGestorSetting.CSBD_Device_AVE__c = 'CC';
        insert citaGestorSetting;
    }
    
    @IsTest
    static void testObtenerDisponibilidadesGestorSuccess() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            // Preparar datos de prueba
            Map<String, Object> params = new Map<String, Object>();
            params.put('numperso', '123456');
            params.put('employeeId', '29197');
            params.put('daysFrom', 0);
            params.put('daysTo', 1);
            params.put('eventType', 'CONSULTA');
            
            // Configurar el mock de la respuesta HTTP
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 200,
                'status' => 'OK',
                'tipoIntegracion' => 'CSBD_AVE_Disponibilidad',
                'tipoRespuesta' => 'OK',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));
            
            // Ejecutar el método
            Test.startTest();
                Map<String, Object> resultado = CSBD_WS_AVEDisponibilidad.obtenerDisponibilidadesGestor(params);
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals('OK', resultado.get('result'), 'El resultado debería ser OK');
            System.assertNotEquals(null, resultado.get('horariosDisponibles'), 'Debería existir horarios disponibles');
            
            // Verificar los datos de disponibilidad
            CSBD_WS_AVEDisponibilidad.RespuestaAvailabilitiesGestor disponibilidades = 
                (CSBD_WS_AVEDisponibilidad.RespuestaAvailabilitiesGestor)resultado.get('horariosDisponibles');
            System.assertEquals(2, disponibilidades.availabilities.size(), 'Deberían existir 2 disponibilidades');
            System.assertEquals('OK', disponibilidades.StatusResponse.statusMessage, 'El status message debería ser OK');
        }
    }
    
    @IsTest
    static void testObtenerDisponibilidadesGestorError() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {    

            // Preparar datos de prueba con número de persona inválido
            Map<String, Object> params = new Map<String, Object>();
            params.put('numperso', '');
            params.put('employeeId', '29197');
            params.put('daysFrom', 0);
            params.put('daysTo', 1);
            params.put('eventType', 'CONSULTA');
            
            // Ejecutar el método
            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_AVEDisponibilidad.obtenerDisponibilidadesGestor(params);
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assertEquals('No se ha encontrado el número de persona para el cliente', resultado.get('errorMessage'), 
                'El mensaje de error debería indicar que no se encontró el número de persona');
        }
    }
    
    @IsTest
    static void testObtenerDisponibilidadesGestorHttpError() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            // Preparar datos de prueba
            Map<String, Object> params = new Map<String, Object>();
            params.put('numperso', '123456');
            params.put('employeeId', '29197');
            params.put('daysFrom', 0);
            params.put('daysTo', 1);
            params.put('eventType', 'CONSULTA');
            
            // Configurar el mock de la respuesta HTTP con error
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 500,
                'status' => 'Error',
                'tipoIntegracion' => 'CSBD_AVE_Disponibilidad',
                'tipoRespuesta' => 'KO',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));
            
            // Ejecutar el método
            Test.startTest();
                Map<String, Object> resultado = CSBD_WS_AVEDisponibilidad.obtenerDisponibilidadesGestor(params);
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assertEquals('El sistema AVE ha devuelto un status de error', resultado.get('errorMessage'), 
                'El mensaje de error debería indicar un error del sistema AVE');
        }
    }
}