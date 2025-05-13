@isTest
public with sharing class CC_Int_AvailabilitiesGestor_Test {
    @TestSetup
    static void testSetup() {
        User adminUser = CC_TestDataFactory.insertUserAdmin();
        User usuarioOperador = CC_TestDataFactory.insertUserOperadorCliente('U0123456');
        System.runAs(adminUser){
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

            //TODO: hacer el share del account y el caso con el usuario operador para cambiar el runAs de los metodos
        }
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
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
                Map<String, Object> maparespuesta = CC_Int_AvailabilitiesGestor.obtenerDisponibilidadesGestor(caso.Id, '23456', '23456','43');
                Map<Date,Set<Time>> respuesta = (Map<Date,Set<Time>>)maparespuesta.get('fechasHorasMap');  
                String fechaRespuesta;
                for(Date fecha: respuesta.keySet()) {
                    fechaRespuesta = String.valueOf(fecha);
                }
                System.assertEquals('2022-06-20', fechaRespuesta, 'Fecha incorrecta');    
            Test.stopTest();           
        }
    }

    @isTest
    private static void getFechas() {    
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
                List<OT_Picklist.Item> respuesta = CC_EmailSendController.obtenerFechasDisponiblidadGestor(caso.Id, '23456', '23456','43');   
                System.assertEquals('2022-06-20', respuesta[0].value);   
            Test.stopTest();
        }
    }

    @isTest
    private static void getHoras() {
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
                List<OT_Picklist.Item> respuesta = CC_EmailSendController.obtenerHorasDisponiblidadGestor(caso.Id, '23456', '23456', '43', '2022-06-20'); 
                System.assertEquals('15:30', respuesta[0].value);     
            Test.stopTest();
        }
    }

    @isTest
    private static void obtenerGestoresBackup() {
     
        System.runAs(CC_TestDataFactory.getUserAdmin()){     
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
                List<OT_Picklist.Item> respuesta = CC_EmailSendController.obtenerGestoresBackup(caso.Id, '23456', '23456', '43');   
                System.assert(respuesta.isEmpty());   
            Test.stopTest();            
        }
    }


    @isTest
    private static void obtenerGestoresBackupDerivar() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
        System.runAs(CC_TestDataFactory.getUserAdmin()){     
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
                List<OT_Picklist.Item> respuesta = CC_Operativa_Oficina_Controller.obtenerGestoresBackup(caso.Id, '23456', '23456', '43'); 
                System.assert(respuesta.isEmpty());   
            Test.stopTest();           
        }       
    }

    @isTest
    private static void obtenerHorasDisponiblidadGestorDerivar() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
                List<OT_Picklist.Item> respuesta = CC_Operativa_Oficina_Controller.obtenerHorasDisponiblidadGestor(caso.Id, '23456', '23456', '43', '2022-06-20');
                System.assertEquals('15:30', respuesta[0].value);   
            Test.stopTest();        
        }    
    }

    @isTest
    private static void obtenerFechasDisponiblidadGestorDerivar() {
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
                List<OT_Picklist.Item> respuesta = CC_Operativa_Oficina_Controller.obtenerFechasDisponiblidadGestor(caso.Id, '23456', '23456','43');      
                System.assertEquals('2022-06-20', respuesta[0].value);
            Test.stopTest();           
        }
    }
   
}