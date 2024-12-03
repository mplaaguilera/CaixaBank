@isTest
public with sharing class CC_Agrupador_Numero_Casos_Test {
    @isTest
    public static void test() {

        CC_Lista_Valores__c listaPrincipal = new CC_Lista_Valores__c();
        listaPrincipal.Name = 'Avisos sobre agrupadores';
        listaPrincipal.RecordTypeId = [SELECT Id from RecordType where SobjectType = 'CC_Lista_Valores__c' and Name = 'Lista de valores' LIMIT 1].Id;
        insert listaPrincipal;
        
		List<CC_Lista_Valores__c> lstValores = new List<CC_Lista_Valores__c>();
            
        CC_Lista_Valores__c valor1 = new CC_Lista_Valores__c();
        valor1.Name = 'Comunicación Informativa - Umbral primer aviso';
        valor1.CC_Valor__c = '47';
        valor1.CC_Lista__c = listaPrincipal.Id;
        valor1.RecordTypeId = [SELECT Id from RecordType where SobjectType = 'CC_Lista_Valores__c' and Name = 'Valor' LIMIT 1].Id;
        lstValores.add(valor1);
        
        CC_Lista_Valores__c valor2 = new CC_Lista_Valores__c();
        valor2.Name = 'Comunicación Informativa - Umbral siguientes avisos';
        valor2.CC_Valor__c = '100';
        valor2.CC_Lista__c = listaPrincipal.Id;
        valor2.RecordTypeId = [SELECT Id from RecordType where SobjectType = 'CC_Lista_Valores__c' and Name = 'Valor' LIMIT 1].Id;
        lstValores.add(valor2);
        
        insert(lstValores);
        
        CC_Agrupador__c agrupador = new CC_Agrupador__c();
        agrupador.CC_Titulo__c = 'Agrupador Test';
        insert agrupador;

        Case caso1 = new Case();
        caso1.Subject = 'Caso Test';
        caso1.Status = 'Cerrado';
        caso1.CC_Agrupador_Id__c = agrupador.Id;
        insert caso1;

        Case caso2 = new Case();
        caso2.Subject = 'Caso Test';
        caso2.Status = 'Cerrado';
        caso2.CC_Agrupador_Id__c = agrupador.Id;
        insert caso2;

        Test.startTest();
        List<Id> idsAgrupador = new List<Id>();
        idsAgrupador.add(agrupador.Id);
        CC_Agrupador_Numero_Casos.CC_Agrupador_Numero_Casos(idsAgrupador);
        Test.stopTest();


        System.assertEquals(2, [SELECT CC_Numero_Casos__c FROM CC_Agrupador__c WHERE Id = :agrupador.Id].CC_Numero_Casos__c);
    }
}