public with sharing class CSBD_CerrarOportunidad_Apex {

    @AuraEnabled(cacheable=true)
	public static Map<String, List<String>> obtenerResoluciones(String producto, String nombreRecordType) {
		Map<String, List<String>> retorno = new Map<String, List<String>>{
			'Formalizada' => new List<String>(), 'Perdida' => new List<String>(), 'Rechazada' => new List<String>()
		};

		for (CC_Lista_Valores__c resolucion : [SELECT CC_Lista__r.Name, CC_Lista__r.CSBD_Etapa_Resolucion__c
												FROM CC_Lista_Valores__c WHERE CC_Activa__c = TRUE
												AND RecordType.Name = 'Valor' AND Name = :producto
												AND CC_Lista__r.CSBD_Etapa_Resolucion__c != NULL
												AND CC_Lista__r.CSBD_Tipo_de_oportunidad__c INCLUDES (:nombreRecordType)
												ORDER BY CC_Lista__r.Name]) {

			String resolucionName = resolucion.CC_Lista__r.Name;
			for (String etapa : resolucion.CC_Lista__r.CSBD_Etapa_Resolucion__c.split(',')) {
				if (retorno.containsKey(etapa)) {
					List<String> resolucionesEtapa = retorno.get(etapa);
					if (!resolucionesEtapa.contains(resolucionName)) {
						resolucionesEtapa.add(resolucionName);
						retorno.put(etapa, resolucionesEtapa);
					}
				} else {
					retorno.put(etapa, new List<String>{resolucionName});
				}
			}
		}
		return retorno;
	}
}