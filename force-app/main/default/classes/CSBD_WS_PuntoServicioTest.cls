@IsTest
private class CSBD_WS_PuntoServicioTest {
    
    @TestSetup
    static void setup() {
        // Configuración inicial si es necesaria
        User usuarioAdministrador = CSBD_Usuarios.usuarioAdministrador();
    }
    
    @IsTest
    static void testHandlePuntoServicioSuccess() {
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
        System.runAs(usuarioAdministrador) {
        // Preparar datos de prueba
            CSBD_WS_PuntoServicio.ContactInfo contactInfo = new CSBD_WS_PuntoServicio.ContactInfo();
            contactInfo.name = 'Test';
            contactInfo.lastname = 'User';
            contactInfo.documentType = 1;
            contactInfo.documentId = '12345678';
            contactInfo.requestPrescriberId = 'PRESCRIBER123';
            
            String jsonBody = JSON.serialize(contactInfo);
            
            // Configurar el contexto REST
            RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf(jsonBody);
            RestResponse res = new RestResponse();
            RestContext.request = req;
            RestContext.response = res;
            
            // Ejecutar el método
            Test.startTest();
                CSBD_WS_PuntoServicio.handlePuntoServicio();
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals(200, res.statusCode, 'El código de estado debería ser 200 para una solicitud exitosa');
        }
    }
    
    @IsTest
    static void testHandlePuntoServicioError() {
        // Preparar datos de prueba inválidos
        User usuarioAdministrador = [SELECT Id FROM User WHERE FirstName = 'AdminCSBD' LIMIT 1];
            System.runAs(usuarioAdministrador) {
                String invalidJson = '{"invalid": "json"';
                
            // Configurar el contexto REST
            RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf(invalidJson);
            RestResponse res = new RestResponse();
            RestContext.request = req;
            RestContext.response = res;
            
            // Ejecutar el método
            Test.startTest();
            CSBD_WS_PuntoServicio.handlePuntoServicio();
            Test.stopTest();
            
            // Verificar resultados
            System.assertEquals(400, res.statusCode, 'El código de estado debería ser 400 para una solicitud con error');
        }
    }    
   
}