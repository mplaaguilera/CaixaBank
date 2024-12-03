@isTest
public with sharing class CC_Administracion_Lista_TRHan_Test {
    @isTest
    public static void validarRegistrosCOPS_Test() {

        Id recordTypeListaValores = Schema.getGlobalDescribe().get('CC_Lista_Valores__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        Id recordTypeValor = Schema.getGlobalDescribe().get('CC_Lista_Valores__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();

        List<CC_Lista_Valores__c> listasInsertar = new List<CC_Lista_Valores__c>();

        CC_Lista_Valores__c listaDepartamentosRestringidos = new CC_Lista_Valores__c();
        listaDepartamentosRestringidos.Name = 'COPS: dominios correos salientes restringidos';
        listaDepartamentosRestringidos.RecordTypeId = recordTypeListaValores;
        listaDepartamentosRestringidos.CC_Activa__c = true;
        listasInsertar.add(listaDepartamentosRestringidos);
        Insert listasInsertar;

        List<CC_Lista_Valores__c> valoresInsertar = new List<CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c valorDominio = new CC_Lista_Valores__c();
        valorDominio.Name = '@domino1.com';
        valorDominio.CC_Lista__c = listaDepartamentosRestringidos.Id;
        valorDominio.RecordTypeId = recordTypeValor;
        valorDominio.CC_Activa__c = true;
        valoresInsertar.add(valorDominio);
        Insert valoresInsertar;

        List<CC_Administracion_Lista_Blanca__c> registrosAdministracionListaInsert = new List<CC_Administracion_Lista_Blanca__c>();
        CC_Administracion_Lista_Blanca__c dominio1 = new CC_Administracion_Lista_Blanca__c();
        dominio1.CC_Activo__c = true;
        dominio1.CC_Canal_Contacto__c = 'Email';
        dominio1.CBK_Negocio__c = 'COPS';
        dominio1.Name = '@domino1.com';
        dominio1.CC_Prioridad__c = 'Medium';
        registrosAdministracionListaInsert.add(dominio1);

        CC_Administracion_Lista_Blanca__c dominio2 = new CC_Administracion_Lista_Blanca__c();
        dominio2.CC_Activo__c = true;
        dominio2.CC_Canal_Contacto__c = 'Email';
        dominio2.CBK_Negocio__c = 'COPS';
        dominio2.Name = '@domino2.com';
        dominio2.CC_Prioridad__c = 'Medium';
        registrosAdministracionListaInsert.add(dominio2);

        test.startTest();
        List<CC_Administracion_Lista_Blanca__c> dominiosCreados = new List<CC_Administracion_Lista_Blanca__c>();
        for(CC_Administracion_Lista_Blanca__c dominio: registrosAdministracionListaInsert) {
            try {
                insert dominio;
                dominiosCreados = [SELECT Id FROM CC_Administracion_Lista_Blanca__c WHERE Name = '@domino2.com'];
                System.assert(!dominiosCreados.isEmpty());
            }
            catch(Exception e) {
                Boolean expectedExceptionThrown = e.getMessage().contains('El dominio indicado no está permitido para la Lista Blanca del negocio COPS.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
        dominiosCreados = [SELECT Id FROM CC_Administracion_Lista_Blanca__c WHERE Name = '@domino2.com'];
        dominiosCreados[0].Name = '@domino1.com';
        try {
            Update dominiosCreados;
        }
        catch(Exception e) {
            Boolean expectedExceptionThrown = e.getMessage().contains('El dominio indicado no está permitido para la Lista Blanca del negocio COPS.') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
            dominiosCreados = [SELECT Id FROM CC_Administracion_Lista_Blanca__c WHERE Name = '@domino2.com'];
            System.assert(!dominiosCreados.isEmpty());
        }
        test.stopTest();
    }
}