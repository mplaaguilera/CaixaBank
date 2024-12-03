public with sharing class CSBD_Lista_Casos_Cola_Controller {

    @AuraEnabled
    public static List<Case> casos3n(Boolean sinCache) {

        List<Case> listaCasos3NdeCSBD =  new List<Case>();

        // Se mira la caché, si tiene datos guardados los recoge, sino, se lanza la query
        if (!sinCache && Cache.Org.contains('local.CSBD.Casos3NCSBD')) {
            listaCasos3NdeCSBD = (List<Case>)Cache.Org.get('local.CSBD.Casos3NCSBD');
        } else {
            Id recordTypeCasoCliente = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            listaCasos3NdeCSBD = [SELECT Id FROM Case WHERE RecordTypeId =: recordTypeCasoCliente
                                    AND Owner.Name = '3N de CSBD' AND CC_Canal_Procedencia__c != 'Soporte PSU'
                                    AND Status != 'Cerrado' AND Status != 'Rechazado'];
            Cache.Org.put('local.CSBD.Casos3NCSBD', listaCasos3NdeCSBD, 300);
        }

        return listaCasos3NdeCSBD;
    }

    @AuraEnabled(cacheable=true)
    public static Id getListviewCasos3nId() {
        List<ListView> listViews = [SELECT Id FROM ListView WHERE SobjectType = 'Case' AND DeveloperName = 'Cola_3N_CSBD_Case'];
        if (listViews.isEmpty()) {
            return null;
        } else {
            return listViews[0].Id;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Boolean> checkIsMember() {
        return new Map<String, Boolean>{
            'esMiembroCola3n' => ![SELECT Id FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId() AND Group.DeveloperName = 'Cola_3N_CSBD' LIMIT 1].isEmpty(),
            'esAdmin' => [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name == 'System Administrator'
        };
    }
}