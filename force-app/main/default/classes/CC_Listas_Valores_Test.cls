@isTest
public class CC_Listas_Valores_Test {
    
    @isTest
    public static void test() {

        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.Name = 'LISTA';
        lista.CC_Activa__c = true;
        insert lista;

        CC_Lista_Valores__c lov1 = new CC_Lista_Valores__c();
        lov1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        lov1.CC_Lista__c = lista.Id;
        lov1.Name = 'NOMBRE1';
        lov1.CC_Valor__c = 'VALOR1';
        lov1.CC_Activa__c = true;
        insert lov1;

        CC_Lista_Valores__c lov2 = new CC_Lista_Valores__c();
        lov2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        lov2.CC_Lista__c = lista.Id;
        lov2.Name = 'NOMBRE2';
        lov2.CC_Valor__c = 'VALOR2';
        lov2.CC_Activa__c = true;
        insert lov2;

        Test.startTest();

        //lookupValue
        System.assertEquals(CC_Listas_Valores.lookupValue('LISTA', 'NOMBRE1'), 'VALOR1');
        System.assertEquals(CC_Listas_Valores.lookupValue('LISTA', 'NOMBRE2'), 'VALOR2');
        System.assertEquals(CC_Listas_Valores.lookupValue(null, 'NOMBRE2'), 'VALOR2');
        System.assertEquals(CC_Listas_Valores.lookupValue('LISTA', null), 'VALOR1');

        //lookupValues
        List<CC_Lista_Valores__c> resultados = CC_Listas_Valores.lookupValues('LISTA', null);
        List<String> valores = valores(resultados);
        System.assertEquals(resultados.size(), 2);
        System.assert(valores.contains('VALOR1'));
        System.assert(valores.contains('VALOR2'));
        
        resultados = CC_Listas_Valores.lookupValues(null, 'NOMBRE2');
        valores.clear();
        valores = valores(resultados);
        System.assertEquals(resultados.size(), 1);
        System.assert(valores.contains('VALOR2'));
        
        resultados = CC_Listas_Valores.lookupValues('LISTA', 'NOMBRE1');
        System.assertEquals(resultados.size(), 1);
        valores.clear();
        valores = valores(resultados);
        System.assert(valores.contains('VALOR1'));
        
        resultados = CC_Listas_Valores.lookupValues('LÍSTA', 'NÓMBRE1'); //con acentos
        System.assertEquals(resultados, null);
    }

    private static List<String> valores(List<CC_Lista_Valores__c> listasValores) {
        List<String> valores = new List<String>();
        for (CC_Lista_Valores__c listaValores : listasValores) {
            valores.add(listaValores.CC_Valor__c);
        }
        return valores;
    }

    @isTest
    public static void lookupValueSet() {
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.Name = 'LISTA';
        lista.CC_Activa__c = true;
        insert lista;

        CC_Lista_Valores__c lov1 = new CC_Lista_Valores__c();
        lov1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        lov1.CC_Lista__c = lista.Id;
        lov1.Name = 'NOMBRE1';
        lov1.CC_Valor__c = 'VALOR1';
        lov1.CC_Activa__c = true;
        insert lov1;

        CC_Lista_Valores__c lov2 = new CC_Lista_Valores__c();
        lov2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        lov2.CC_Lista__c = lista.Id;
        lov2.Name = 'NOMBRE2';
        lov2.CC_Valor__c = 'VALOR2';
        lov2.CC_Activa__c = true;
        insert lov2;

        Test.startTest();

        CC_Listas_Valores.LookupValuesSet('LISTA', new Set<String>{'NOMBRE1', 'NOMBRE2'});
    }
}