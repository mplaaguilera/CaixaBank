@isTest
public with sharing class CC_WS_PushSMS_Test {
    @TestSetup
    static void makeData(){
        User admin = CC_TestDataFactory.insertUserAdmin();//CC_Administrador_Test

        System.runAs(admin) {
            List<CC_Lista_Valores__c> valoresInsertar = new List<CC_Lista_Valores__c>();
            List<CC_Lista_Valores__c> listasInsertar = new List <CC_Lista_Valores__c>();
            Id recordTypeLista = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
            Id rtValor = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
            CC_Lista_Valores__c horario = new CC_Lista_Valores__c();
            horario.RecordTypeId = recordTypeLista;
            horario.Name = 'Calendario_servicios';
            horario.CC_Activa__c = true;
            listasInsertar.add(horario);

            CC_Lista_Valores__c listaDerivar = new CC_Lista_Valores__c();
            listaDerivar.Name = 'Textos operativa Derivar';
            listaDerivar.RecordTypeId = recordTypeLista;
            listasInsertar.add(listaDerivar);

            CC_Lista_Valores__c listaPlazo = new CC_Lista_Valores__c();
            listaPlazo.Name = 'Plazo Cierre Solicitud Información';
            listaPlazo.CC_Activa__c = true;
            listaPlazo.RecordTypeId = recordTypeLista;
            listasInsertar.add(listaPlazo);

            insert listasInsertar;
            
            CC_Lista_Valores__c horarioAccionista = new CC_Lista_Valores__c();
            horarioAccionista.Name = 'Atención al Cliente';
            horarioAccionista.RecordTypeId = rtValor;
            horarioAccionista.CC_Valor__c = '9';
            horarioAccionista.CC_Valor2__c = '23';
            horarioAccionista.CC_Valor_SFDC__c = 'L-J';
            horarioAccionista.CC_Lista__c = horario.Id;
            valoresInsertar.add(horarioAccionista);
            
            CC_Lista_Valores__c horarioAccionista2 = new CC_Lista_Valores__c();
            horarioAccionista2.Name = 'Atención al Cliente';
            horarioAccionista2.RecordTypeId = rtValor;
            horarioAccionista2.CC_Valor__c = '9:30';
            horarioAccionista2.CC_Valor2__c = '19';
            horarioAccionista2.CC_Valor_SFDC__c = 'V';
            horarioAccionista2.CC_Lista__c = horario.Id;
            valoresInsertar.add(horarioAccionista2);
            
            CC_Lista_Valores__c horarioServiciosCentrales = new CC_Lista_Valores__c();
            horarioServiciosCentrales.Name = 'Servicios Centrales';
            horarioServiciosCentrales.RecordTypeId = rtValor;
            horarioServiciosCentrales.CC_Valor__c = '9:30';
            horarioServiciosCentrales.CC_Valor2__c = '19';
            horarioServiciosCentrales.CC_Valor_SFDC__c = 'L-J';
            horarioServiciosCentrales.CC_Lista__c = horario.Id;
            valoresInsertar.add(horarioServiciosCentrales);
            
            CC_Lista_Valores__c horarioServiciosCentrales2 = new CC_Lista_Valores__c();
            horarioServiciosCentrales2.Name = 'Servicios Centrales';
            horarioServiciosCentrales2.RecordTypeId = rtValor;
            horarioServiciosCentrales2.CC_Valor__c = '9:30';
            horarioServiciosCentrales2.CC_Valor2__c = '19';
            horarioServiciosCentrales2.CC_Valor_SFDC__c = 'V';
            horarioServiciosCentrales2.CC_Lista__c = horario.Id;
            valoresInsertar.add(horarioServiciosCentrales2);

            CC_Lista_Valores__c horarioGenerico = new CC_Lista_Valores__c();
            horarioGenerico.Name = 'Generico';
            horarioGenerico.RecordTypeId = rtValor;
            horarioGenerico.CC_Valor__c = '9:30';
            horarioGenerico.CC_Valor2__c = '19';
            horarioGenerico.CC_Valor_SFDC__c = 'L-J';
            horarioGenerico.CC_Lista__c = horario.Id;
            valoresInsertar.add(horarioGenerico);

            CC_Lista_Valores__c horarioGenerico2 = new CC_Lista_Valores__c();
            horarioGenerico2.Name = 'Generico';
            horarioGenerico2.RecordTypeId = rtValor;
            horarioGenerico2.CC_Valor__c = '9:30';
            horarioGenerico2.CC_Valor2__c = '19';
            horarioGenerico2.CC_Valor_SFDC__c = 'V';
            horarioGenerico2.CC_Lista__c = horario.Id;
            valoresInsertar.add(horarioGenerico2);

            CC_Lista_Valores__c valorPlazo = new CC_Lista_Valores__c();
            valorPlazo.Name = 'Plazo Genérico';
            valorPlazo.RecordTypeId = rtValor;
            valorPlazo.CC_Valor__c = '1';
            valoresInsertar.add(valorPlazo);

            
            CC_Lista_Valores__c valorCSBD = new CC_Lista_Valores__c();
            valorCSBD.Name = 'Texto oportunidad tarea existente';
            valorCSBD.RecordTypeId = rtValor;
            valorCSBD.CC_Mensajes_Mostrar__c = 'pruebatest';
            valorCSBD.CC_Activa__c = true;
            valoresInsertar.add(valorCSBD);

            insert valoresInsertar;

            Account cuenta = new Account();
            cuenta.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Account', 'CC_ClientePA');
            cuenta.FirstName = 'Cuenta Prueba';
            cuenta.LastName = 'Cuenta Prueba';
            cuenta.CC_Numero_Oficina__c = '222';
            cuenta.AV_IndicadoresClientes__c = '1';
            cuenta.AV_NumPerso__c = '222';
            cuenta.PersonMobilePhone = '666666666';
            insert cuenta;

            // Contact contacto = new Contact();
            // contacto.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Contact', 'CC_Cliente');
            // contacto.AccountId = cuenta.Id;
            // contacto.FirstName = 'Test';
            // contacto.LastName = 'Contacto Prueba';
            // contacto.CC_NumPerso__c = '25345569';
            // contacto.CC_Idioma__c = 'ca';
            // contacto.Email = 'correo@gmail.com';
            // contacto.Phone = '973242323';
            // contacto.MobilePhone = '666';
            // insert contacto;

            Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
            Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
            Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
            Id recordCau = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
            Id recordSol = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Solucion').getRecordTypeId();

            //MCCs argos
            CC_MCC__c mcc3 = new CC_MCC__c();
            mcc3.RecordTypeId = recordTem;
            mcc3.Name = 'App\'s';
            mcc3.CC_Tipo_Cliente__c = 'Cliente';
            mcc3.CC_Codigo_Externo__c = 'TE-000002';
            mcc3.CC_Canal_Operativo__c = 'App BrokerNow';
            insert mcc3;
            CC_MCC__c mcc4 = new CC_MCC__c();
            mcc4.RecordTypeId = recordProd;
            mcc4.Name = 'APP CaixaBank';
            mcc4.CC_Detalle__c = 'CaixaBank';
            mcc4.CC_Tipo_Cliente__c = 'Cliente';
            mcc4.CC_Tematica__c = mcc3.Id;
            mcc4.CC_Codigo_Externo__c = 'PR-000002';
            insert mcc4;
            CC_MCC__c mcc5 = new CC_MCC__c();
            mcc5.RecordTypeId = recordMot;
            mcc5.Name = 'Valoración positiva';
            mcc5.CC_Tipo_Cliente__c = 'Cliente';
            mcc5.CC_Producto_Servicio__c = mcc4.Id;
            mcc5.CC_Codigo_Externo__c = 'MO-000002';
            mcc5.CC_Ambito_Tareas_Imagin__c = 'Argos General';
            mcc5.CC_Ambito_Tareas_Caixa__c = 'Argos General';
            insert mcc5;

            CC_Settings__c configuracion = new CC_Settings__c(
                Name = 'CC_RespuestaArgosPushSMS',
                CC_Configuracion_1__c = 'Respuesta negativa Argos'
            );
            insert configuracion;

            List<Case> casos = new List<Case>();

            Case caso3 = new Case();
            caso3.AccountId = cuenta.Id;
            //caso3.ContactId = contacto.Id;
            caso3.Subject = 'Caso Cliente 3';
            caso3.Status = 'Activo';
            caso3.Origin = 'Email';
            caso3.CC_Tipo_Cliente__c = 'Cliente';
            caso3.CC_Tipo_Contacto__c = 'Consulta';
            caso3.CC_MCC_Tematica__c = mcc3.Id;
            caso3.CC_MCC_ProdServ__c = mcc4.Id;
            caso3.CC_MCC_Motivo__c = mcc5.Id;
            caso3.CC_Canal_Procedencia__c = 'Formulario Consultas Operativas';
            caso3.CC_Detalles_Consulta__c = 'Test';
            caso3.CC_Detalles_Solucion__c = 'Test';
            caso3.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
            caso3.CC_Idioma__c = 'es';
            casos.add(caso3);

            insert casos;

            List<EmailTemplate> plantillasAInsertar = new List<EmailTemplate>();
            EmailTemplate plantilla1CAS= new EmailTemplate();
            plantilla1CAS.Developername = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAS';
            plantilla1CAS.HTMLValue= 'hola prueba 2';
            plantilla1CAS.Subject = 'plantilla1CAS';
            plantilla1CAS.FolderId = UserInfo.getUserId();
            plantilla1CAS.TemplateType = 'Text';        
            plantilla1CAS.name = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAS';
            plantilla1CAS.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAS);

            
            EmailTemplate plantilla1CAT= new EmailTemplate();
            plantilla1CAT.Developername = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAT';
            plantilla1CAT.HTMLValue= 'hola prueba 2';
            plantilla1CAT.Subject = 'plantilla1CAT';
            plantilla1CAT.FolderId = UserInfo.getUserId();
            plantilla1CAT.TemplateType = 'Text';        
            plantilla1CAT.name = 'CC_ConsultasOperativasCanalFormulario_Traslado_CAT';
            plantilla1CAT.IsActive = true;
            plantillasAInsertar.Add(plantilla1CAT);

            insert plantillasAInsertar;

            CBK_IntegrationSetting__c customSetting = new CBK_IntegrationSetting__c();
            customSetting.Name = 'CC_Envio_SMS';
            customSetting.NamedCredential__c = 'callout:API_GWT_PRO_CCSF/distribution/messages/applicationAlerts/send';
            customSetting.RegistroTrazaIntegracion__c = true;
            insert customSetting;
        }
    }

    private class MockHttpResponseExito implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            // res.setBody('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ns2:ProcesarEventoResponse xmlns:ns2="http://servicioexternoenviosws.alertasfinancenvios.mca.si.absis.lacaixa.es/"><return><datosError/><listaMensajes><canalEnvio>SMS</canalEnvio><destinatario>34-650XXXXXX</destinatario><texto>Test Salesforce.</texto><tipoEnvio>Online</tipoEnvio></listaMensajes></return></ns2:ProcesarEventoResponse></soap:Body></soap:Envelope>');
            res.setBody('{"messageList":[{"addressee":"34-666555444","text":"TextoPrueba","channel":"SMS","sendType":"Online"}],"infoBean":{}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    private static void sendSMSExito() {
        User admin = CC_TestDataFactory.getUserAdmin();
        Id idCaso = [SELECT Id FROM Case WHERE Subject = 'Caso Cliente 3' LIMIT 1].Id;
        System.runAs(admin)
        {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
            String mensaje = 'TextoPrueba';
            String result = CC_WS_PushSMS.enviarNotificacionPush(idCaso, 'Respuesta negativa Argos');
            Test.stopTest();
            System.assertEquals('OK', result);
        }
    }
}