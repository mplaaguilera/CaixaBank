@IsTest
private class CSBD_WS_LegoAltaCitaTest {

    @TestSetup
    static void setup() {
        // Crear el Integration Setting
        CBK_IntegrationSetting__c integrationSetting = new CBK_IntegrationSetting__c();
        integrationSetting.Name = 'CSBD_Lego_AltaCita';
        integrationSetting.NamedCredential__c = 'callout:CSBD_Lego_Named_Credentials/altaCita';
        insert integrationSetting;

        // Custom Setting necesario
        CSBD_CitaGestorSetting__c setting = new CSBD_CitaGestorSetting__c();
        setting.Name = 'Default';
        setting.CSBD_Device_LEGO__c = 'CC';
        setting.CSBD_ReservationType_LEGO__c = 'RESERVA';
        setting.CSBD_Header_LEGO__c = false;
        setting.CSBD_VersionAPI_Lego__c = 'v2';
        insert setting;
    }

    @IsTest
    static void testAltaCitaSuccess() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Map<String, Object> params = new Map<String, Object>{
                'numOficina' => '001',
                'numPer' => '123456',
                'fechaSeleccionada' => '2024-06-01',
                'franjaSeleccionada' => '10:30',
                'asunto' => 'Consulta',
                'tipoCita' => '42'
            };

            // Mock de respuesta HTTP exitosa
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 201,
                'status' => 'OK',
                'tipoIntegracion' => 'CSBD_Lego_AltaCita',
                'tipoRespuesta' => 'OK',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));

            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_LegoAltaCita.altaCita(params);
            Test.stopTest();

            System.assertEquals('OK', resultado.get('result'), 'El resultado debería ser OK');
            System.assertNotEquals(null, resultado.get('appointmentId'), 'Debería existir un appointmentId');
        }
    }

    @IsTest
    static void testAltaCitaErrorDatos() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Map<String, Object> params = new Map<String, Object>{
                'numOficina' => '001',
                'numPer' => '', // numPer vacío
                'fechaSeleccionada' => '2024-06-01',
                'franjaSeleccionada' => '10:30',
                'asunto' => 'Consulta',
                'tipoCita' => '42'
            };

            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_LegoAltaCita.altaCita(params);
            Test.stopTest();

            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assertEquals('Numperso no informado', resultado.get('errorMessage'), 'Mensaje de error esperado');
        }
    }

    @IsTest
    static void testAltaCitaHttpError() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Map<String, Object> params = new Map<String, Object>{
                'numOficina' => '001',
                'numPer' => '123456',
                'fechaSeleccionada' => '2024-06-01',
                'franjaSeleccionada' => '10:30',
                'asunto' => 'Consulta',
                'tipoCita' => '42'
            };

            // Mock de respuesta HTTP con error
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 500,
                'status' => 'Error',
                'tipoIntegracion' => 'CSBD_Lego_AltaCita',
                'tipoRespuesta' => 'KO',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));

            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_LegoAltaCita.altaCita(params);
            Test.stopTest();

            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assert(resultado.get('errorMessage') != null && ((String)resultado.get('errorMessage')).contains('servidor LEGO'), 'Mensaje de error esperado');
        }
    }
}