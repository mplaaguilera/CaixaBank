public with sharing class CSBD_FamiliaProductoPicklistController {

    @AuraEnabled(cacheable=true)
    public static List<CC_Lista_Valores__c> getEmpresas(String nombreRecordType) {
        return [SELECT Name FROM CC_Lista_Valores__c WHERE CC_Activa__c = TRUE
                AND RecordType.DeveloperName = 'CSBD_Empresas'
                AND CSBD_Tipo_de_oportunidad__c INCLUDES (:nombreRecordType)
                ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Lista_Valores__c> getFamilias(String nombreRecordType, String empresaProveedora) {
        return [SELECT Name FROM CC_Lista_Valores__c WHERE CC_Activa__c = TRUE
                AND RecordType.DeveloperName = 'CSBD_Familias'
                AND CSBD_Tipo_de_oportunidad__c INCLUDES (:nombreRecordType)
                AND CSBD_Empresa_Proveedora_Multi__c INCLUDES (:empresaProveedora)
                ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Lista_Valores__c> getProductos(String familia) {
        return [SELECT Name FROM CC_Lista_Valores__c WHERE CC_Activa__c = TRUE
                AND RecordType.DeveloperName = 'CC_Valor'
                AND CC_Lista__r.Name != NULL AND CC_Lista__r.Name = :familia
                ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Lista_Valores__c> getMotivosMac(String producto) {
        return [SELECT CC_Lista__r.Name FROM CC_Lista_Valores__c WHERE CC_Activa__c = TRUE
                AND CC_Lista__r.RecordType.DeveloperName = 'CSBD_Motivos_CSCC'
                AND RecordType.DeveloperName = 'CC_Valor' AND Name = :producto
                ORDER BY CC_Lista__r.Name];
    }
}