@IsTest
private class CSBD_WS_LegoDisponibilidadTest {

    @TestSetup
    static void setup() {
        // Crear el Integration Setting
        CBK_IntegrationSetting__c integrationSetting = new CBK_IntegrationSetting__c();
        integrationSetting.Name = 'CSBD_Lego_DisponibilidadCitas';
        integrationSetting.NamedCredential__c = 'callout:CSBD_Lego_Named_Credentials/disponibilidad';
        insert integrationSetting;

        // Custom Setting necesario
        CSBD_CitaGestorSetting__c setting = new CSBD_CitaGestorSetting__c();
        setting.Name = 'Default';
        setting.CSBD_Device_LEGO__c = 'CC';
        setting.CSBD_ReservationType_LEGO__c = 'RESERVA';
        setting.CSBD_Header_LEGO__c = false;
        insert setting;
    }

    @IsTest
    static void testObtenerDisponibilidadesSuccess() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Map<String, Object> params = new Map<String, Object>{
                'numOficina' => '001',
                'fecha' => '2024-06-01'
            };

            // Mock de respuesta HTTP exitosa
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 200,
                'status' => 'OK',
                'tipoIntegracion' => 'CSBD_Lego_Disponibilidad',
                'tipoRespuesta' => 'OK',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));

            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_LegoDisponibilidad.obtenerDisponibilidadesOficina(params);
            Test.stopTest();

            System.assertEquals('OK', resultado.get('result'), 'El resultado debería ser OK');
            System.assertNotEquals(null, resultado.get('horariosDisponibles'), 'Debería haber horarios disponibles');
            
            // Verificar los datos de disponibilidad
            List<CSBD_WS_LegoDisponibilidad.DisponibilidadWrapper> disponibilidades = 
                (List<CSBD_WS_LegoDisponibilidad.DisponibilidadWrapper>)resultado.get('horariosDisponibles');
            System.assertEquals(disponibilidades.isEmpty(), false, 'Debería existir una disponibilidad');
        }
    }

    @IsTest
    static void testObtenerDisponibilidadesErrorDatos() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Map<String, Object> params = new Map<String, Object>{
                'numOficina' => '', // numOficina vacío
                'fecha' => '2024-06-01'
            };

            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_LegoDisponibilidad.obtenerDisponibilidadesOficina(params);
            Test.stopTest();

            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assertEquals('Número de oficina no informado', resultado.get('errorMessage'), 'Mensaje de error esperado');
        }
    }


    @IsTest
    static void testObtenerDisponibilidadesErrorSetting() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Map<String, Object> params = new Map<String, Object>{
                'numOficina' => '001', 
                'fecha' => '2024-06-01'
            };

            CSBD_CitaGestorSetting__c setting = [SELECT Id FROM CSBD_CitaGestorSetting__c WHERE Name = 'Default'];              
            setting.CSBD_Device_LEGO__c = '';
            setting.CSBD_ReservationType_LEGO__c = '';
            update setting;

            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_LegoDisponibilidad.obtenerDisponibilidadesOficina(params);
            Test.stopTest();

            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');         
        }
    }


    @IsTest
    static void testObtenerDisponibilidadesHttpError() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(usuarioGestor) {
            Map<String, Object> params = new Map<String, Object>{
                'numOficina' => '001',
                'fecha' => '2024-06-01'
            };

            // Mock de respuesta HTTP con error
            Map<String, Object> mockParams = new Map<String, Object>{
                'statusCode' => 500,
                'status' => 'Error',
                'tipoIntegracion' => 'CSBD_Lego_Disponibilidad',
                'tipoRespuesta' => 'KO',
                'multipleCallout' => false
            };
            Test.setMock(HttpCalloutMock.class, new CSBD_HttpMockWSCita(mockParams));

            Test.startTest();
            Map<String, Object> resultado = CSBD_WS_LegoDisponibilidad.obtenerDisponibilidadesOficina(params);
            Test.stopTest();

            System.assertEquals('KO', resultado.get('result'), 'El resultado debería ser KO');
            System.assertEquals('El servidor de Agendar Citas ha devuelto un error', resultado.get('errorMessage'), 'Mensaje de error esperado');
        }
    }
}