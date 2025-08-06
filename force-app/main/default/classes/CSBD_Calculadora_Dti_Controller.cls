public with sharing class CSBD_Calculadora_Dti_Controller {

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Map<String, Object>>> tiposBonificados() {
        List<CC_Lista_Valores__c> lovs = [SELECT Name, CC_Valor__c FROM CC_Lista_Valores__c WHERE RecordType.DeveloperName = 'CC_Valor'
                                            AND CC_Activa__c = TRUE AND CC_Lista__r.Name = 'CSBD: Fondos propios - Tipos impositivos'];

        Map<String, List<Map<String, Object>>> retorno = new Map<String, List<Map<String, Object>>>();

        for (CC_Lista_Valores__c lov : lovs) {
            if (retorno.containsKey(lov.Name)) {
                List<Map<String, Object>> tipos = retorno.get(lov.Name);
                Decimal valor = Decimal.valueOf(lov.CC_Valor__c);
                tipos.add(new Map<String, Object>{
                    'valor' => valor,
                    'importe' => null
                });
                retorno.put(lov.Name, tipos);
            } else {
                Decimal valor = Decimal.valueOf(lov.CC_Valor__c);
                retorno.put(lov.Name, new List<Map<String, Object>>{new Map<String, Object>{
                    'valor' => valor,
                    'importe' => null
                }});
            }
        }
        return retorno;
    }
}