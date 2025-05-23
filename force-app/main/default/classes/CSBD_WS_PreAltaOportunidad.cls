@RestResource(urlMapping='/PreAltaOportunidad/*')
global with sharing class CSBD_WS_PreAltaOportunidad extends CBK_HttpServiceIntegration_Abstract {

    global class Output {
        public String referenciaUsuario {get;set;}
        public String codigoError {get;set;}
        public String detalleError {get;set;}
        public String usuario {get;set;}
        public String opportunityId {get;set;}
        public String opportunityNumero {get;set;}
    }

    @HttpGet
    global static CSBD_WS_PreAltaOportunidad.Output preAltaOportunidad() {

		RestRequest req = RestContext.request;
		String requestString = req.requestBody.toString();
		Map<String, Object> input = (Map<String, Object>)JSON.deserializeUntyped(requestString);

        Output output = new Output();
        output.referenciaUsuario = UUID.randomUUID().toString();
        output.codigoError = '0';
        output.detalleError = null;

		Opportunity oportunidad = calcularOportunidad(input.get('ani').toString());
		if (oportunidad?.Owner.EmployeeNumber != null) {
			output.usuario = oportunidad.Owner.EmployeeNumber;
			output.opportunityId = oportunidad.Id;
			output.opportunityNumero = oportunidad.CSBD_Identificador__c;
		} else {
			output.codigoError = '1';
			output.detalleError = 'No se ha encontrado ninguna oportunidad';
		}
        return output;
    }

    public static Opportunity calcularOportunidad(String ani) {
        List<Opportunity> oportunidades = [SELECT CSBD_Identificador__c, Owner.EmployeeNumber, IsClosed FROM Opportunity
											WHERE CSBD_Telefono_Solicitud_Normalizado__c = :ani.replace('+34', '').replaceAll('\\s+', '')
											AND LastModifiedDate = LAST_N_DAYS:180
											ORDER BY LastModifiedDate DESC LIMIT 30];
		if (oportunidades.isEmpty()) {
			return null;
		} else {
			for (Opportunity oportunidad : oportunidades) {
				if (!oportunidad.IsClosed) {
					return oportunidad;
				}
			}
			return oportunidades[0];
		}
    }
}