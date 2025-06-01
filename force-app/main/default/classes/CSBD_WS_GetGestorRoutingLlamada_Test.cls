@isTest
private class CSBD_WS_GetGestorRoutingLlamada_Test {

    @isTest
	private static void getGestorRoutingLlamadaConOppActiva() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{"ani": "600123456"}');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;

        User usuarioAdmin = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(usuarioAdmin) {
            Opportunity oportunidadActiva;

            User gestor = CSBD_TestDataFactory.usuarioGestor(new Map<String, Object>{'EmployeeNumber' => '12345'});
            System.runAs(gestor) {
                Map<String, Object> campos = new Map<String, Object>{
                    'CSBD_Estado__c' => 'Activa',
                    'CSBD_Telefono_Solicitud__c' => '+34600123456'
                };

                //Oportunidad activa
                oportunidadActiva = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
                //Oportunidad cerrada
                Opportunity oportunidadCerrada = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
                CSBD_Opportunity.cerrarOportunidad(oportunidadCerrada.Id, 'Perdida', 'Resolución test');
            }

            System.runAs(usuarioAdmin) {
                Test.startTest();
                CSBD_WS_GetGestorRoutingLlamada.Output output = CSBD_WS_GetGestorRoutingLlamada.getGestorRoutingLlamada();
                Test.stopTest();

                System.assertEquals(oportunidadActiva.Id, output.opportunityId, 'La oportunidad no coincide');
                System.assertEquals(gestor.EmployeeNumber, output.usuario, 'El gestor no coincide');
            }
        }
	}

    @isTest
	private static void getGestorRoutingLlamadaSinOpp() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{"ani":"999999999"}');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            Test.startTest();
            CSBD_WS_GetGestorRoutingLlamada.Output output = CSBD_WS_GetGestorRoutingLlamada.getGestorRoutingLlamada();
            Test.stopTest();

            System.assertEquals('1', output.codigoError, 'El código de error no coincide');
            System.assertEquals('No se ha encontrado ninguna oportunidad', output.detalleError, 'El detalle del error no coincide');
        }
	}

    @isTest
	private static void getGestorRoutingLlamadaConOppCerrada() {
        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestBody = Blob.valueOf('{"ani":"600654321"}');
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

        User usuarioAdmin = CSBD_TestDataFactory.usuarioAdministrador();
        System.runAs(usuarioAdmin) {
            Opportunity oportunidad;

            User gestor = CSBD_TestDataFactory.usuarioGestor(new Map<String, Object>{'EmployeeNumber' => '12345'});
            System.runAs(gestor) {
                Map<String, Object> campos = new Map<String, Object>{
                    'CSBD_Estado__c' => 'Activa',
                    'CSBD_Telefono_Solicitud__c' => '+34 600 65 43 21'
                };
                oportunidad = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo', campos);
                CSBD_Opportunity.cerrarOportunidad(oportunidad.Id, 'Perdida', 'Resolución test');
            }

            System.runAs(usuarioAdmin) {
                Test.startTest();
                CSBD_WS_GetGestorRoutingLlamada.Output output = CSBD_WS_GetGestorRoutingLlamada.getGestorRoutingLlamada();
                Test.stopTest();

                System.assertEquals(oportunidad.Id, output.opportunityId, 'La oportunidad no coincide');
                System.assertEquals(gestor.EmployeeNumber, output.usuario, 'El gestor no coincide');
            }
        }
	}
}