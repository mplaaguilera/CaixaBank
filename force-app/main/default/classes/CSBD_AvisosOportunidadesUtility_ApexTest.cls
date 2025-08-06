@isTest
public class CSBD_AvisosOportunidadesUtility_ApexTest {

    @isTest
    private static void getFrecuenciaAvisosAutoTest() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            CSBD_IdentificarOppsPHDSetting__c customSetting = new CSBD_IdentificarOppsPHDSetting__c();
            customSetting.CSBD_FrecuenciaAvisosAuto__c = 5;
            insert customSetting;
        }
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            Integer frecuenciaAvisosAuto = CSBD_AvisosOportunidadesUtility_Apex.getFrecuenciaAvisosAuto();
            Test.stopTest();

            System.assertEquals(5, frecuenciaAvisosAuto, 'La frecuencia de avisos automáticos recuperada no coincide con el valor del custom setting');
        }
    }

    @isTest
    private static void getNuevasSolicitudesPhdTest() {
        User gestor = CSBD_TestDataFactory.usuarioGestor();
        System.runAs(gestor) {
            CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new Map<String, Object>{
                'CSBD_MostrarAviso__c' => 'Nueva búsqueda en facilitea casa',
                'CSBD_Now_Origen__c' => 'faciliteacasa',
                'CSBD_FechaEntradaUltimoLead__c' => Date.today()
            });
            CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', new Map<String, Object>{
                'CSBD_MostrarAviso__c' => 'Nueva búsqueda en facilitea casa',
                'CSBD_Now_Origen__c' => 'faciliteacasa',
                'CSBD_FechaEntradaUltimoLead__c' => null
            });

            Test.startTest();
            List<Opportunity> nuevasSolicitudesPhd = CSBD_AvisosOportunidadesUtility_Apex.getNuevasSolicitudesPhd();
            Test.stopTest();

            System.assert(nuevasSolicitudesPhd.size() == 1, 'Solo debería retornar 1 oportunidad');
        }
    }
}