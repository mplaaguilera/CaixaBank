@isTest
public class CSBD_AlertaTelefoniaController_Test {

    @isTest
    private static void obtenerOppTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Opportunity oppHip = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new Map<String, Object>{'CSBD_Producto_MIFID__c' => true});
            Opportunity oppAcc = CSBD_Opportunity.crearOportunidad('CSBD_Accion_Comercial', new Map<String, Object>{'CSBD_Producto_MIFID__c' => false});

            Test.startTest();
            oppHip = CSBD_AlertaTelefoniaController.obtenerOpp(oppHip.Id);
            oppAcc = CSBD_AlertaTelefoniaController.obtenerOpp(oppAcc.Id);
            Test.stopTest();

            System.assertEquals(true, oppHip.CSBD_Producto_MIFID__c, 'No se ha recuperado el valor del campo CSBD_Producto_MIFID__c correctamente');
            System.assertEquals(false, oppAcc.CSBD_Producto_MIFID__c, 'No se ha recuperado el valor del campo CSBD_Producto_MIFID__c correctamente');
        }
    }
}