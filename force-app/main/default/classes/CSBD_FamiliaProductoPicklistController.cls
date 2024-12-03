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
    public static List<CC_Lista_Valores__c> getProductos(String familia, String nombreRecordType) {
        return [SELECT Name FROM CC_Lista_Valores__c WHERE CC_Activa__c = TRUE
                AND RecordType.DeveloperName = 'CC_Valor'
                AND CC_Lista__r.Name != NULL AND CC_Lista__r.Name = :familia AND CC_Lista__r.CSBD_Tipo_de_oportunidad__c INCLUDES (:nombreRecordType)
                ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static List<CC_Lista_Valores__c> getMotivosMac() {
        return [SELECT Name FROM CC_Lista_Valores__c WHERE CC_Activa__c = TRUE
                AND RecordType.DeveloperName = 'CC_Valor'
                AND CC_Lista__r.Name = 'CSBD: Motivos MAC'
                ORDER BY Name];
    }
}