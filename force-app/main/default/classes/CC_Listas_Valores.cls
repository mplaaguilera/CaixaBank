public with sharing class CC_Listas_Valores {

    public static List<CC_Lista_Valores__c> lookupValues(String lista, String nombre) {
        List<CC_Lista_Valores__c> lovs = new List<CC_Lista_Valores__c>();
        
        if (String.isNotBlank(lista) && String.isNotBlank(nombre)) {
            lovs = [SELECT CC_Lista__c, Name, CC_Valor__c FROM CC_Lista_Valores__c
                    WHERE RecordType.Name = 'Valor' AND CC_Activa__c = TRUE
                    AND CC_Lista__r.Name = :lista AND Name = :nombre];
            
        } else if (String.isBlank(lista)) {
            lovs = [SELECT CC_Lista__c, Name, CC_Valor__c FROM CC_Lista_Valores__c
                    WHERE RecordType.Name = 'Valor' AND CC_Activa__c = TRUE
                    AND Name = :nombre];
            
        } else {
            lovs = [SELECT CC_Lista__c, Name, CC_Valor__c FROM CC_Lista_Valores__c
                    WHERE RecordType.Name = 'Valor' AND CC_Activa__c = TRUE
                    AND CC_Lista__r.Name = :lista];
        }
        
        if (!lovs.isEmpty()) {
            return lovs;
        } else {
            return null;
        }
    }

    public static List<CC_Lista_Valores__c> lookupValuesSet(String lista, Set<String> nombre) {
        List<CC_Lista_Valores__c> lovs = new List<CC_Lista_Valores__c>();
        
        if (lista != null && nombre != null) {
            lovs = [SELECT Id, CC_Lista__c, Name, CC_Valor__c
                    FROM CC_Lista_Valores__c
                    WHERE RecordType.Name = 'Valor' AND CC_Activa__c = true
                    AND CC_Lista__r.Name = :lista AND Name = :nombre];
            
        } else if (lista == null) {
            lovs = [SELECT Id, CC_Lista__c, Name, CC_Valor__c
                    FROM CC_Lista_Valores__c
                    WHERE RecordType.Name = 'Valor' AND CC_Activa__c = true
                    AND Name = :nombre];
            
        } else {
            lovs = [SELECT Id, CC_Lista__c, Name, CC_Valor__c
                    FROM CC_Lista_Valores__c
                    WHERE RecordType.Name = 'Valor' AND CC_Activa__c = true
                    AND CC_Lista__r.Name = :lista];
        }
        return lovs;
    }
    
    public static String lookupValue(String lista, String nombre) {
        return lookupValue(lista, nombre, 'CC_Valor__c');
    }

    public static String lookupValue(String lista, String nombre, String campo) {

        List<CC_Lista_Valores__c> lovs = new List<CC_Lista_Valores__c>();

        if (String.isNotBlank(lista) && String.isNotBlank(nombre)) {
            lovs = [SELECT CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c
                    WHERE RecordType.Name = 'Valor' AND CC_Activa__c = TRUE
                    AND CC_Lista__r.Name = :lista AND Name = :nombre LIMIT 1];
        } else if (String.isBlank(lista)) {
            lovs = [SELECT CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c
                    WHERE RecordType.Name = 'Valor' AND CC_Activa__c = TRUE
                    AND Name = :nombre LIMIT 1];
        } else {
            lovs = [SELECT CC_Valor__c, CC_Valor2__c, CC_Valor_SFDC__c FROM CC_Lista_Valores__c
                    WHERE RecordType.Name = 'Valor' AND CC_Activa__c = TRUE
                    AND CC_Lista__r.Name = :lista LIMIT 1];
        }

        if (!lovs.isEmpty()) {
            return lovs[0].get(campo).toString();
        } else {
            return null;
        }
    }
}