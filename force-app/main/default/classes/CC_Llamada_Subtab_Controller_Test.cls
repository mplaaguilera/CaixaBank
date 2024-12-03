@isTest
public with sharing class CC_Llamada_Subtab_Controller_Test {

    @isTest
    public static void getCuentasContactosCasos() {
        Account cuenta = new Account(Name = 'Prueba');
        insert cuenta;
        
        CC_Servicio_Genesys__c s1 = CC_Llamada_Test.crearServicio1();
        String jsonLlamadaEntrante = CC_Llamada_Test.obtenerJsonLlamada(s1.CC_Codigo__c, '', '', '12345678');
        Id idLlamada = CC_OpenCTI.registrarLlamadaEntrante(jsonLlamadaEntrante);
        CC_Llamada__c llamada = CC_Llamada_Test.obtenerLlamada(idLlamada);
        llamada.CC_Cuenta__c = cuenta.Id;
        update llamada;
        
        Test.startTest();
        Map<String, List<Id>> retorno = CC_Llamada_Subtab_Controller.getCuentasContactosCasos(idLlamada);
        Test.stopTest();

        System.assert(retorno.get('idCuenta') != null);
        System.assert(retorno.get('idContacto') != null);
        System.assert(retorno.get('idCasos').isEmpty());
    }
}