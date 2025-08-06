@isTest
public with sharing class CC_TrazaInt_Test {

    @isTest
    public static void test() {

        Test.startTest();

        CC_TrazaInt__c traza1 = CC_TrazaInt.inicioTraza(
            'masvoz',
            'registrarLlamadaEntrante',
            'identificador01',
            'mensajeEntrada'
        );
        traza1 = CC_TrazaInt.finTraza(traza1, 'mensajeSalida');

        CC_TrazaInt__c traza2 = CC_TrazaInt.inicioTraza(
            'masvoz',
            'registrarLlamadaEntrante',
            'identificador02',
            'mensajeEntrada'
        );
        traza2 = CC_TrazaInt.finTraza(traza2, 'mensajeSalida', 'codigoError', 'mensajeError');

        CC_TrazaInt__c traza3 = new CC_TrazaInt__c();
        traza3.Name = 'masvoz';
        traza3.CC_IdOrigen__c = 'registrarLlamadaEntrante';
        traza3.CC_Identificador__c = 'identificador03';
        traza3.CC_MensajeEntrada__c = 'mensajeEntrada';
        traza3.CC_FinOK__c = false;
        traza3.CC_MensajeSalida__c = 'mensajeSalida';
        traza3.CC_TipoError__c = 'codigoError';
        traza3.CC_DetalleError__c = 'mensajeError';
        CC_TrazaInt.traza(traza3);

        Test.stopTest();

        System.assertEquals(true, traza1.CC_FinOK__c, 'traza1 debería tener fin OK');
        System.assertEquals(false, traza2.CC_FinOK__c, 'traza2 debería tener fin KO');
        System.assert(traza3 != null, 'traza3 no debería ser null');
    }

    @isTest
    public static void generarTrazaTest() {
        CC_TrazaInt__c traza = new CC_TrazaInt__c();

        System.runAs (CSBD_TestDataFactory.usuarioGestor()) {
        Test.startTest();
        traza = CC_TrazaInt.generarTraza('nombreTrazaTest', 'identificadorTest', 'estadoTest', 'mensajeEntradaTest', 'detalleErrorTest', 'requestStringTest', true);
        Test.stopTest();
        }
        System.assertEquals(true, traza.Name == 'nombreTrazaTest' , 'No se han introducido los datos en la traza correctamente');
        System.assertEquals(true, traza.CC_Identificador__c == 'identificadorTest' , 'No se han introducido los datos en la traza correctamente');
        System.assertEquals(true, traza.CC_EstadoInt__c == 'estadoTest' , 'No se han introducido los datos en la traza correctamente');
        System.assertEquals(true, traza.CC_MensajeEntrada__c == 'mensajeEntradaTest' , 'No se han introducido los datos en la traza correctamente');
        System.assertEquals(true, traza.CC_DetalleError__c == 'detalleErrorTest' , 'No se han introducido los datos en la traza correctamente');
        System.assertEquals(true, traza.CC_MensajeSalida__c == 'requestStringTest' , 'No se han introducido los datos en la traza correctamente');

    }


}