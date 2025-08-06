@isTest
private with sharing class CSBD_TiposOferta_ControllerTest {

    @isTest
    public static void getTablaMaestra() {
        CC_Lista_Valores__c tablaPrecios = new CC_Lista_Valores__c();
        tablaPrecios.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CSBD_TablaPrecios').getRecordTypeId();
        tablaPrecios.CC_Activa__c = true;
        tablaPrecios.CSBD_TablaPrecios_Producto2__c = 'Convenios';
        tablaPrecios.CSBD_TablaPrecios_CategoriaTitular__c = 'Alto valor';
        tablaPrecios.CSBD_TablaPrecios_Plazo__c = 'Corto';
        tablaPrecios.CSBD_TiposOfertaJson__c = System.JSON.serialize(new Map<String, Object>{
            'fijoNoBonificado' => 2,
            'fijoBonificado' => 3,
            'variableNoBonificado' => 4,
            'variableBonificado' => 5,
            'mixtoAñosTramoFijo' => 99,
            'mixtoTramoFijoNoBonificado' => 6,
            'mixtoTramoFijoBonificado' => 7,
            'mixtoTramoVariableNoBonificado' => 8,
            'mixtoTramoVariableBonificado' => 9
        });
        insert tablaPrecios;

        System.runAs(CSBD_Usuarios.usuarioGestor()) {
            Test.startTest();
            String jsonRetorno = CSBD_TiposOferta_Controller.getTablaMaestra('Convenios', 24, 'Alto valor');
            Test.stopTest();

            Map<String, Object> retorno = (Map<String, Object>)System.JSON.deserializeUntyped(jsonRetorno);
            System.assertEquals(99, retorno.get('mixtoAñosTramoFijo'), 'El valor retornado no coincide con el de la lista de precios');
        }
    }
}