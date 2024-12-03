@isTest
public with sharing class CC_Int_AvailabilitiesGestor_Test {
    @TestSetup
    static void testSetup() {
        //Cuentas cliente
        List<Account> accountsInsert = new List<Account>();
        Account cuentaCliente = new Account();
        cuentaCliente.LastName = 'Cliente Senior'; 
        cuentaCliente.CC_NumPerso__c = '0000012';
        cuentaCliente.RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClientePA').getRecordTypeId();
        accountsInsert.add(cuentaCliente);
        insert accountsInsert;

        //Casos
        List<Case> casosInsert = new List<Case>();
        Case casoCC = new Case();
        casoCC.Subject = 'Caso de Contact Center';
        casoCC.Description = 'Caso de Contact Center';
        casoCC.CC_Idioma__c = 'es';
        casoCC.Origin = 'Email';
        casoCC.CC_Tipo_Contacto__c = 'Consulta';
        casoCC.CC_Canal_Procedencia__c = 'Formulario web';
        casoCC.CC_Detalles_Consulta__c = 'Caso de Contact Center';
        casoCC.Status = 'Activo';
        casoCC.AccountId = cuentaCliente.Id;
        casoCC.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        casosInsert.add(casoCC);
        insert casosInsert;
    }
    
    private class MockHttpResponseExito implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            CC_Int_AvailabilitiesGestor.Availability disponibilidad = new CC_Int_AvailabilitiesGestor.Availability();
            disponibilidad.employeeId = '23456';
            disponibilidad.dateAvailable = '2022-06-20';
            disponibilidad.startTime = '15:30';
            disponibilidad.endTime ='18:00';
            disponibilidad.branchId = '9945';
            disponibilidad.isManager = 'true';
            disponibilidad.isBackup = 'false';
            disponibilidad.name = 'GESTOR';
            disponibilidad.surname = 'APELLIDO';
            disponibilidad.secondSurname = 'APELLIDO2';
            disponibilidad.branchName ='CAIXA';
            disponibilidad.telework = 'N';
            
            CC_Int_AvailabilitiesGestor.StatusResp respuestaEstado = new CC_Int_AvailabilitiesGestor.StatusResp();
            respuestaEstado.statusCode = '200';
            respuestaEstado.statusMessage = 'OK';
            
            CC_Int_AvailabilitiesGestor.RespuestaAvailabilitiesGestor respuestaAvailabilities = new CC_Int_AvailabilitiesGestor.RespuestaAvailabilitiesGestor();
            respuestaAvailabilities.availabilities.add(disponibilidad);
            respuestaAvailabilities.StatusResponse = respuestaEstado;

            String bodyRequestAvailabilities = JSON.serialize(respuestaAvailabilities);
            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000012');
            res.setBody(bodyRequestAvailabilities);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    private static void getAvaibilitiesGestor(){
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        Map<String, Object> maparespuesta = CC_Int_AvailabilitiesGestor.obtenerDisponibilidadesGestor(caso.Id, '23456', '23456','43');
        Map<Date,Set<Time>> respuesta = (Map<Date,Set<Time>>)maparespuesta.get('fechasHorasMap');      
        Test.stopTest();
        String fechaRespuesta;
        for(Date fecha: respuesta.keySet()) {
            fechaRespuesta = String.valueOf(fecha);
        }
        System.assertEquals('2022-06-20', fechaRespuesta);
    }

    @isTest
    private static void getFechas() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        List<OT_Picklist.Item> respuesta = CC_EmailSendController.obtenerFechasDisponiblidadGestor(caso.Id, '23456', '23456','43');      
        Test.stopTest();
        System.assertEquals('2022-06-20', respuesta[0].value);
    }

    @isTest
    private static void getHoras() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        List<OT_Picklist.Item> respuesta = CC_EmailSendController.obtenerHorasDisponiblidadGestor(caso.Id, '23456', '23456', '43', '2022-06-20');      
        Test.stopTest();
        System.assertEquals('15:30', respuesta[0].value);
    }

    @isTest
    private static void obtenerGestoresBackup() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        List<OT_Picklist.Item> respuesta = CC_EmailSendController.obtenerGestoresBackup(caso.Id, '23456', '23456', '43');      
        Test.stopTest();
        System.assert(respuesta.isEmpty());
    }
}