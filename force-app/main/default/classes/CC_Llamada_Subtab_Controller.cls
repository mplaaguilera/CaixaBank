public with sharing class CC_Llamada_Subtab_Controller {

    @AuraEnabled
    public static Map<String, List<Id>> getCuentasContactosCasos(Id idLlamada) {
        CC_Llamada__c llamada = [SELECT CC_Cuenta__c, CC_Contacto__c FROM CC_Llamada__c WHERE Id = :idLlamada];

        Set<Id> idCasos = new Set<Id>();
        for (Task tarea : [SELECT WhatId FROM Task WHERE CC_Llamada_Id__c = :idLlamada 
                            AND RecordType.DeveloperName IN ('CC_Task', 'SACH_Task')]) {
            idCasos.add(tarea.WhatId);
        }

        return new Map<String, List<Id>>{
            'idCuenta' => new List<Id>{llamada.CC_Cuenta__c},
            'idContacto' => new List<Id>{llamada.CC_Contacto__c},
            'idCasos' =>  new List<Id>(idCasos)
        };
    }
}