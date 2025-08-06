public with sharing class CSBD_TiposOferta_Controller {

    @AuraEnabled(cacheable=true)
    public static String getTablaMaestra(String producto, Integer plazo, String categoriaTitular) {
        return [SELECT CSBD_TiposOfertaJson__c FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CSBD_TablaPrecios' AND CC_Activa__c = TRUE
                AND CSBD_TablaPrecios_Producto2__c = :producto AND CSBD_TablaPrecios_CategoriaTitular__c = :categoriaTitular
                AND CSBD_TablaPrecios_Plazo__c = :(plazo <= 240 ? 'Corto' : 'Largo') LIMIT 1]?.CSBD_TiposOfertaJson__c;
    }
}