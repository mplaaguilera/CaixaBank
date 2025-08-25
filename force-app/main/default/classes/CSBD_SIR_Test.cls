@isTest
public class CSBD_SIR_Test {

    private class CSBD_SIR_Mock_test implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String sFakeRespuesta = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><ns2:CalcLimResponse xmlns:ns2="http://sircalclimites.riesgocalclimites.mca.si.absis.lacaixa.es/"><return><datosCalculo><estadoRiesgo>N</estadoRiesgo><fechaCalculo>20250812</fechaCalculo><horaCalculo>12371986</horaCalculo><mediaNomPensUlt7m>0.0</mediaNomPensUlt7m><mediaPasivoUlt3m>3163.42</mediaPasivoUlt3m><nivelRiesgo>A</nivelRiesgo><pdPrincipal>0.18005</pdPrincipal><riesgoPrincipal>29</riesgoPrincipal><saldoPasivoTotal>386289.09</saldoPasivoTotal><segmentoHijo>12</segmentoHijo><segmentoPadre>9</segmentoPadre><ticketSIR>0050915884020250812012371986</ticketSIR><tipoPersona>F</tipoPersona></datosCalculo><datosError><codigoError></codigoError><textoError></textoError></datosError><limites><compraEstOfiDisp>0.0</compraEstOfiDisp><compraEstPromoCx>0.0</compraEstPromoCx><estimuloInverMedDisp>0</estimuloInverMedDisp><estimuloInverMicroDisp>0</estimuloInverMicroDisp><estimuloInverPeqDisp>0</estimuloInverPeqDisp><finEmpresDisp>30000.0</finEmpresDisp><importeSimuladoTCR>0</importeSimuladoTCR><indBloqCanal></indBloqCanal><modlim></modlim><modlim2>                        2</modlim2><modlim3>                         1</modlim3><preconcedidoDisp>0</preconcedidoDisp><prestamoOfiDisp>59400.0</prestamoOfiDisp><prestamoOfiPric></prestamoOfiPric><prestamoOnlDisp>29400.0</prestamoOnlDisp><prestamoOnlPric>OK</prestamoOnlPric><tarjetasOfiDisp>10000.0</tarjetasOfiDisp><tarjetasOnlDisp>4000.0</tarjetasOnlDisp><tpvDisp>0.0</tpvDisp><tpvPric></tpvPric></limites></return></ns2:CalcLimResponse></soap:Body></soap:Envelope>';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(sFakeRespuesta);
            res.setStatusCode(200);
            return res;
        }
    }

    // public HTTPResponse respond(HTTPRequest req) {   
        
    //     String sFakeRespuesta = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sir="http://sircalclimites.riesgocalclimites.mca.si.absis.lacaixa.es/"><soapenv:Header/><soapenv:Body><sir:CalcLim><externalInputTO><aplicacionInvocante>OCE</aplicacionInvocante><canalInvocante>P</canalInvocante><indicadorBureaus>N</indicadorBureaus><numeroPersona>67302397</numeroPersona><numeroSolicitud>12345</numeroSolicitud><tipoConsulta>A</tipoConsulta><tipoLimite>1</tipoLimite></externalInputTO></sir:CalcLim></soapenv:Body></soapenv:Envelope>';

    //     HttpResponse res = new HttpResponse();
    //     res.setHeader('Content-Type', 'application/json');
    //     res.setBody(sFakeRespuesta);
    //     res.setStatusCode(200);
    //     return res; 
    // }

    @TestSetup
    private static void altaDatosPrueba() {

        //Alta de las parametrizaciones que necesita el trigger BI de oportunidades
        CC_Lista_Valores__c listaValores = new CC_Lista_Valores__c();
        listaValores.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        listaValores.Name = 'CSBD: Días cierre oportunidad por defecto';
        listaValores.CC_Activa__c = true;
        insert listaValores;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        valor.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = listaValores.Id;
        valor.Name = 'Préstamo';
        valor.CC_Valor__c = '1';
        listaValores.CC_Activa__c = true;
        insert valor;

        Pricebook2 listaPrecios = new Pricebook2();
        listaPrecios.Name = 'CSBD Price Book';
        listaPrecios.Description = 'CSBD Price Book';
        listaPrecios.IsActive = true;
        insert listaPrecios;

        CBK_IntegrationSetting__c csbdSIR = new CBK_IntegrationSetting__c();
        csbdSIR.Name = 'CSBD_SIR';
        csbdSIR.NamedCredential__c = 'callout:CSBD_API_GWT_TST_2/RiesgoCalcLimites/SIRCalcLimites';
        insert csbdSIR;

    }

    @isTest
    public static void actualizarDatosRiesgoClientesOportunidades() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Map<String, Object> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('46979396X', new Map<String, Object>{'AV_NumPerso__c' => '21444982'});
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Contact contacto1 = (Contact)cuentaContacto.get('contacto');
            Contact contacto2 = CSBD_TestDataFactory.crearContacto(new Map<String, Object>{'AccountId' => cuenta.Id, 'AV_NumPerso__c' => '21444983'});

            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {

            Test.setMock(HttpCalloutMock.class, new CSBD_SIR_Mock_test());

                Opportunity prestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', new Map<String, Object>{
                    'AccountId' => cuenta.Id,
                    'CSBD_Contact__c' => contacto1.Id,
                    'CSBD_Contact_2__c' => contacto2.Id,
                    'CSBD_Now_NIF__c' => cuenta.CC_Numero_Documento__c
                });

                Test.startTest();
                CSBD_SIR.actualizarDatosRiesgoClientesOportunidades(new List<Id>{prestamo.Id}, true);
                Test.stopTest();

                Opportunity oportunidadCreada = [SELECT CSBD_Limite_Prestamos_Oficinas__c, CSBD_Limite_Prestamos_Canales__c, CSBD_Limite_Tarjetas_Oficinas__c, CSBD_Limite_Tarjetas_Canales__c, CSBD_Limite_Compra_Estrella__c
                                                    FROM Opportunity WHERE Id = :prestamo.Id];
                Contact contactoCreado = [SELECT CSBD_Actualizacion_Datos_Riesgo__c FROM Contact WHERE Id = :prestamo.CSBD_Contact__c];

                System.assertEquals(false, contactoCreado.CSBD_Actualizacion_Datos_Riesgo__c, 'El bypass de la VR de bloqueo de ALF no se ha desmarcado');
                System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Prestamos_Oficinas__c, 'El límite de préstamos de oficinas no se ha actualizado');
                System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Prestamos_Canales__c, 'El límite de préstamos de canales no se ha actualizado');
                System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Tarjetas_Oficinas__c, 'El límite de tarjetas de oficinas no se ha actualizado');
                System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Tarjetas_Canales__c, 'El límite de tarjetas de canales no se ha actualizado');
                System.assertNotEquals(null, oportunidadCreada.CSBD_Limite_Compra_Estrella__c, 'El límite de compra de estrella no se ha actualizado');
            }
        }
    }
}