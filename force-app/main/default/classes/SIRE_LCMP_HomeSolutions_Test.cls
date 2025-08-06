@isTest
public with sharing class SIRE_LCMP_HomeSolutions_Test {
    
    @isTest
    public static void  getDataTest() {
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator','U0111111','09999');
        Map<String, Integer> lstProcesosFlujo = new Map<String, Integer>();
        Map<String, Integer> lstProcesosPreventivo = new Map<String, Integer>();
        System.runAs(usuario) {  
        Test.startTest();
        lstProcesosFlujo = SIRE_LCMP_HomeSolutions.getData(SIR_Constantes.TIPOPROCESO_FLUJO);
        lstProcesosPreventivo = SIRE_LCMP_HomeSolutions.getData(SIR_Constantes.TIPOPROCESO_PREVENTIVO);
        Test.stopTest();
        }
        System.assertNotEquals(null, lstProcesosFlujo, 'No se ha devuelto correctamente el tipo de proceso');
        System.assertNotEquals(null, lstProcesosPreventivo, 'No se ha devuelto correctamente el tipo de proceso');
    }

    @isTest
    public static void getURLTest(){
        UserRole rol = new UserRole(DeveloperName = 'testRole', Name = 'testRole');
        insert rol;
        User usuario = SIR_TestDataFactory.createTestUser('usuarioTest',rol,'System Administrator','U0111111','09999');
        String urlFLUJO;
        String urlPREVENTIVO;
        System.runAs(usuario) {  
        Test.startTest();
        urlFLUJO = SIRE_LCMP_HomeSolutions.getURL(SIR_Constantes.TIPOPROCESO_FLUJO);
        urlPREVENTIVO = SIRE_LCMP_HomeSolutions.getURL(SIR_Constantes.TIPOPROCESO_PREVENTIVO);
        Test.stopTest();
        }
        System.assertEquals('/lightning/n/SIRE_Inicio_FLUJO', urlFLUJO);
        System.assertEquals('/lightning/n/SIRE_Inicio_Preventivo', urlPREVENTIVO);
        System.assertEquals(null, SIRE_LCMP_HomeSolutions.getURL(' '));
    }
}