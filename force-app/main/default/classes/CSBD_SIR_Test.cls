@isTest
public class CSBD_SIR_Test {

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
    }

    @isTest
    public static void actualizarDatosRiesgoClientesOportunidades() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Map<String, Object> cuentaContacto = CSBD_TestDataFactory.crearCuentaContacto('46979396X', new Map<String, Object>{'AV_NumPerso__c' => '21444982'});
            Account cuenta = (Account)cuentaContacto.get('cuenta');
            Contact contacto1 = (Contact)cuentaContacto.get('contacto');
            Contact contacto2 = CSBD_TestDataFactory.crearContacto(new Map<String, Object>{'AccountId' => cuenta.Id, 'AV_NumPerso__c' => '21444983'});

            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                //Preparación de respuestas de prueba de los servicios web guardadas como static resources
                MultiStaticResourceCalloutMock multiMock = new MultiStaticResourceCalloutMock();
                String endpointSirCalcLimites = obtenerParametrosIntegracion('CSBD_SIR_CalcLimites')?.CC_EndPoint__c;
                if (String.isNotBlank(endpointSirCalcLimites)) {
                    multiMock.setStaticResource(endpointSirCalcLimites, 'CSBD_SIR_Respuesta_sirCalcLimites');
                }
                String endpointSirConsultaScorings = obtenerParametrosIntegracion('CSBD_SIR_ConsultaScorings')?.CC_EndPoint__c;
                if (String.isNotBlank(endpointSirConsultaScorings)) {
                    multiMock.setStaticResource(endpointSirConsultaScorings, 'CSBD_SIR_Respuesta_sirCalcLimites');
                }
                multiMock.setStatusCode(200);
                multiMock.setHeader('Content-Type', 'text/xml');
                Test.setMock(HttpCalloutMock.class, multiMock);

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

    private static CC_InterfaceSettings__mdt obtenerParametrosIntegracion(String interfazDevName) {
        List<CC_InterfaceSettings__mdt> parametrosInterfaz = [SELECT DeveloperName, CC_Certificado__c, CC_Endpoint__c, CC_TipoPeticion__c, CC_ContentType__c
                                                                FROM CC_InterfaceSettings__mdt WHERE DeveloperName = :interfazDevName AND CC_Activa__c = true LIMIT 1];
        if (!parametrosInterfaz.isEmpty()) {
            return parametrosInterfaz[0];
        } else {
            return null;
        }
    }
}