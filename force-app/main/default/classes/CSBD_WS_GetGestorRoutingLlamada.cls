@RestResource(urlMapping='/GetGestorRoutingLlamada/*')
global with sharing class CSBD_WS_GetGestorRoutingLlamada extends CBK_HttpServiceIntegration_Abstract {

    global class Output {
        public String referenciaUsuario {get;set;}
        public String codigoError {get;set;}
        public String detalleError {get;set;}
        public String usuario {get;set;}
        public String opportunityId {get;set;}
        public String opportunityNumero {get;set;}
    }

    @HttpGet
    global static CSBD_WS_GetGestorRoutingLlamada.Output getGestorRoutingLlamada() {
		RestRequest req = RestContext.request;
		String requestString = req.requestBody.toString();
		Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(requestString);

        Output output = new Output();
        output.referenciaUsuario = UUID.randomUUID().toString();
        output.codigoError = '0';
        output.detalleError = null;

		Opportunity oportunidad = calcularOportunidad(input.get('ani').toString());
		if (oportunidad == null) {
			output.codigoError = '1';
			output.detalleError = 'No se ha encontrado ninguna oportunidad';
		} else {
			output.usuario = oportunidad.Owner.EmployeeNumber;
			output.opportunityId = oportunidad.Id;
			output.opportunityNumero = oportunidad.CSBD_Identificador__c;
		}
        return output;
    }

    public static Opportunity calcularOportunidad(String ani) {
        List<Opportunity> oportunidades = [SELECT CSBD_Identificador__c, CSBD_Estado__c, Owner.EmployeeNumber FROM Opportunity
											WHERE CSBD_Telefono_Solicitud_Normalizado__c = :CSBD_Utils.normalizarNumeroTelefono(ani)
											AND CSBD_Estado__c IN ('Activa', 'Cerrada') AND LastModifiedDate = LAST_N_DAYS:30
											AND Owner.EmployeeNumber != NULL ORDER BY LastModifiedDate DESC LIMIT 20];
		if (oportunidades.isEmpty()) {
			return null;
		} else {
			for (Opportunity oportunidad : oportunidades) {
				if (oportunidad.CSBD_Estado__c == 'Activa') {
					return oportunidad;
				}
			}
			return oportunidades[0];
		}
    }


}