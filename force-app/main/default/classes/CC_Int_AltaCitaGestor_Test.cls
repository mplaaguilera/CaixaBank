@isTest
public class CC_Int_AltaCitaGestor_Test {
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

            //Lista de valores
            Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            Id recordTypeValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            
            List<CC_Lista_Valores__c> listas = new List<CC_Lista_Valores__c>();
        
            CC_Lista_Valores__c listaDerivar = new CC_Lista_Valores__c();
            listaDerivar.Name = 'Textos operativa Derivar';
            listaDerivar.RecordTypeId = recordTypeLista;
            listas.add(listaDerivar);
            insert listas;
    
            List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();
            CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
            valor.Name = 'Texto cita o tarea existe';
            valor.RecordTypeId = recordTypeValor;
            valor.CC_Lista__c = listaDerivar.Id;
            valor.CC_Mensajes_Mostrar__c = 'No es posible crear una nueva cita o tarea porque ya existe una cita o tarea creada';
            valores.add(valor);
    
            insert valores;

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

            CC_Settings__c  customSetting = new CC_Settings__c ();
            customSetting.Name = 'CC_OperativaOficina';
            customSetting.CC_Activa__c = true;
            customSetting.CC_Configuracion_12__c = 'test';
            customSetting.CC_Configuracion_14__c = 'test';
            insert customSetting;
        }
       
    }

    private class MockHttpResponseExito implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            CC_Int_AltaCitaGestor.RespuestaAltaContacto respuestaAltaCita = new CC_Int_AltaCitaGestor.RespuestaAltaContacto();
            respuestaAltaCita.resultat = 'OK';
            respuestaAltaCita.empleCont = '56530';
            respuestaAltaCita.numCont = '1';
            respuestaAltaCita.txtError = 'OK';
            String respuestaAltaCitaString = JSON.serialize(respuestaAltaCita);
            
            HttpResponse res = new HttpResponse();
            res.setHeader('x-absis-customerInternalId', '0000012');
            res.setBody(respuestaAltaCitaString);
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
                Map<String, String> respuesta = CC_EmailSendController.altaCitaGestor(caso.Id, '56530', 'Gestor A', '00615', 'asunto', '2022-06-23', '09:30', 'Entrevista');
                System.assertEquals('OK', respuesta.get('resultat'));      
            Test.stopTest();          
        }
    }

    @isTest
    private static void getAvaibilitiesGestorDerivar(){
        System.runAs(CC_TestDataFactory.getUserAdmin()){
            Case caso = [SELECT Id FROM Case WHERE Subject = 'Caso de Contact Center'];
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
                Map<String, String> respuesta = CC_Operativa_Oficina_Controller.altaCitaGestor(caso.Id, '56530', 'Gestor A', '00615', 'asunto', '2022-06-23', '09:30', 'Entrevista'); 
                System.assertEquals('OK', respuesta.get('resultat'));     
            Test.stopTest();           
        }       
    }
}