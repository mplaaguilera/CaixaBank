public with sharing class CC_BuscadorClasificaciones_Controller {

    @AuraEnabled(cacheable=true)
    public static List<CC_MCC__c> buscar(String tipoBusqueda, String valorBusqueda) {
        Map<String, Object> queryBinds = new Map<String, Object>{
            'rtDevName' => 'CC_Motivo', 'valorBusqueda' => '%' + valorBusqueda + '%'
        };
        String query = 'SELECT CC_Producto_Servicio__r.CC_Tematica__c, CC_Producto_Servicio__r.CC_Tematica__r.Name, CC_Producto_Servicio__r.CC_Tematica__r.CC_Color_En_Buscador__c, ';
        query += 'CC_Producto_Servicio__c, CC_Producto_Servicio__r.Name, CC_Producto_Servicio__r.CC_Color_En_Buscador__c, ';
        query += 'Name, CC_Detalle__c, CC_Color_En_Buscador__c ';
        query += 'FROM CC_MCC__c WHERE RecordType.DeveloperName = :rtDevName AND CC_Activo__c = TRUE ';

        if (tipoBusqueda == 'Temáticas') {
            query += 'AND CC_Producto_Servicio__r.CC_Tematica__r.Name ';
        } else if (tipoBusqueda == 'Productos/Servicios') {
            query += 'AND CC_Producto_Servicio__r.Name ';
        } else if (tipoBusqueda == 'Motivos') {
            query += 'AND Name ';
        } else {
            query += 'AND CC_Clasif_Completa_Visible_Formula__c ';
        }
        query += 'LIKE :valorBusqueda ORDER BY CC_Clasif_Completa_Visible_Formula__c LIMIT 20';
		return Database.queryWithBinds(query, queryBinds, AccessLevel.USER_MODE);
    }

    @AuraEnabled
	public static List<CC_MCC__c> clasificacionesRecientes() {
        Map<String, Object> queryBinds = new Map<String, Object>{
            'rtDevName' => 'CC_Motivo', 'ownerId' => UserInfo.getUserId()
        };
        String queryString = 'SELECT CC_Producto_Servicio__r.CC_Tematica__c, CC_Producto_Servicio__r.CC_Tematica__r.Name, ';
        queryString += 'CC_Producto_Servicio__c, CC_Producto_Servicio__r.Name, Name, CC_Detalle__c ';
		queryString += 'FROM CC_MCC__c WHERE RecordType.DeveloperName = :rtDevName ';
        queryString += 'AND Id IN (SELECT CC_MCC_Motivo__c FROM Case WHERE OwnerId = :ownerId AND LastModifiedDate = LAST_N_DAYS:10) ';
        queryString += 'AND CC_Activo__c = TRUE ORDER BY CC_Producto_Servicio__r.CC_Tematica__r.Name, CC_Producto_Servicio__r.Name, Name LIMIT 6';
		return Database.queryWithBinds(queryString, queryBinds, AccessLevel.USER_MODE);
	}
}