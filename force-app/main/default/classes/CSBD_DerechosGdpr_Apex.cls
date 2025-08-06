public with sharing class CSBD_DerechosGdpr_Apex {

    @AuraEnabled(cacheable=true)
    public static List<CC_Derecho__c> getDerechosGdpr(Id recordId, Id accountId) {
        return [SELECT Name, RecordType.Name, CC_Estado__c, CreatedDate, CC_FechaEnvioCierre__c, CC_DocumentoCliente__c,
                CC_Cliente__c, CSBD_Opportunity__c, CSBD_Opportunity__r.CSBD_Identificador__c
                FROM CC_Derecho__c
                WHERE (CSBD_Opportunity__c = :recordId OR CC_Cliente__c = :accountId)
				ORDER BY CreatedDate DESC];
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getTiposDerecho() {
        List<String> recordTypesExcluidos = new List<String>{
            'Master', 'Principal', 'Revocación uso biometria',
            'Revocación consentimiento aplicación condiciones personales ctos cotitularidad'
        };
        List<Map<String, String>> tiposDerecho = new List<Map<String, String>>();
        for (RecordTypeInfo recordTypeInfo : Schema.SObjectType.CC_Derecho__c.getRecordTypeInfos()) {
            if (!recordTypesExcluidos.contains(recordTypeInfo.getName())) {
                tiposDerecho.add(new Map<String, String>{
                    'value' => recordTypeInfo.getRecordTypeId(), 'label' => recordTypeInfo.getName()
                });
            }
        }
        return tiposDerecho;
    }
}