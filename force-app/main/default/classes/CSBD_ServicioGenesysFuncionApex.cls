public with sharing class CSBD_ServicioGenesysFuncionApex {

    @AuraEnabled(cacheable=true)
    public static List<String> getServicioGenesysFuncionOptions() {
        return CSBD_Utils.listaCampo(
            [SELECT CC_Valor__c FROM CC_Lista_Valores__c
                WHERE RecordType.DeveloperName = 'CC_Valor'
                AND CC_Lista__r.Name = 'CSBD: Configuración de rellamadas'
                AND CC_Activa__c = true
                AND Name = 'Opción para el campo Función de Servicio Genesys'
                ORDER BY CC_Orden__c ASC],
            'CC_Valor__c'
        );
    }
}