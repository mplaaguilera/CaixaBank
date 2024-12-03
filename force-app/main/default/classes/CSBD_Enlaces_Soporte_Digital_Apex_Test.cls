@isTest
public with sharing class CSBD_Enlaces_Soporte_Digital_Apex_Test {

    @isTest
    public static void getEnlaces() {

        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
		update usuarioGestor; 

        CC_Lista_Valores__c lista = new CC_Lista_Valores__c();
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.Name = 'CSBD: Enlaces de soporte digital';
        insert lista;

        CC_Lista_Valores__c valor = new CC_Lista_Valores__c();
        lista.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        valor.CC_Lista__c = lista.Id;
        valor.Name = 'Hipoteca Click My Home';
        valor.CSBD_Soporte_Digital_Ficha_Producto__c = '1';
        valor.CSBD_Soporte_Digital_Argumentario__c = '2';
        // valor.CSBD_Soporte_Digital_Campanyas__c = '3';
        valor.CSBD_Soporte_Digital_Material_Apoyo__c = '4';
        valor.CSBD_Soporte_Digital_Origen__c = '5';
        insert valor;
        System.runAs (usuarioGestor) {
        Test.startTest();
        List<CSBD_Enlaces_Soporte_Digital_Controller.Enlace> enlaces = CSBD_Enlaces_Soporte_Digital_Controller.getEnlaces('Hipoteca Click My Home', '5');
        Test.stopTest();

        System.assertEquals(4, enlaces.size());
        }
    }
}