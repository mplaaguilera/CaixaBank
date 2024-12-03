public with sharing class CSBD_Llamada_Oportunidad_Controller {

    @AuraEnabled(cacheable=true)
    public static String getIdOportunidad(Id idLlamada) {
        return [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :idLlamada ORDER BY CreatedDate DESC LIMIT 1]?.WhatId;
    }
}