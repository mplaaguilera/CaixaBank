public with sharing class CSBD_BuscadorProducto_Apex {

	@AuraEnabled(cacheable=true)
	public static List<CC_Lista_Valores__c> getEmpresasProveedoras(String recordTypeName) {
		return [SELECT Name, CSBD_Empresa_Proveedora_Multi__c FROM CC_Lista_Valores__c
				WHERE RecordType.DeveloperName = 'CSBD_Empresas' AND CC_Activa__c = TRUE
				AND CSBD_Tipo_de_oportunidad__c INCLUDES (:recordTypeName)];
	}

    @AuraEnabled(cacheable=true)
    public static List<CC_Lista_Valores__c> getProductos(String recordTypeName, String busqueda) {
		busqueda = '%' + busqueda + '%';
        return [SELECT CC_Lista__r.CSBD_Empresa_Proveedora_Multi__c, CC_Lista__c, CC_Lista__r.Name, Name
				FROM CC_Lista_Valores__c
				WHERE CC_Lista__r.RecordType.DeveloperName = 'CSBD_Familias' AND CC_Lista__r.CC_Activa__c = TRUE
				AND CC_Lista__r.CSBD_Tipo_de_oportunidad__c INCLUDES (:recordTypeName)
				AND RecordType.DeveloperName = 'CC_Valor' AND CC_Activa__c = TRUE
				AND (CC_Lista__r.Name LIKE :busqueda OR Name LIKE :busqueda) LIMIT 20];
    }

}