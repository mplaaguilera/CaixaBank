@isTest
public class CSBD_Lista_Casos_Cola_Controller_Test {

    @isTest
    private static void casos3nTest() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Case caso = new Case();
            caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caso.Subject = 'caso';
            caso.OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Cola_3N_CSBD' LIMIT 1].Id;
            insert caso;

            Test.startTest();
            List<Case> casos3n = CSBD_Lista_Casos_Cola_Controller.casos3n(false).get('casos3n');

            casos3n.add(caso);
            Cache.Org.put('local.CSBD.Casos3NCSBD', casos3n, 300);

            Boolean enCache = Cache.Org.contains('local.CSBD.Casos3NCSBD');
            Test.stopTest();

            System.assertEquals(true, enCache, 'No hay datos en la caché');
        }
    }

    @isTest
    public static void getListviewCasos3nIdTest1() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            Id listaCasos3NdeCSBD =  CSBD_Lista_Casos_Cola_Controller.getListviewCasos3nId();
            Test.stopTest();

            System.assertNotEquals('', listaCasos3NdeCSBD, 'No existe la ListView');
        }
    }

    @isTest
    private static void getListviewCasos3nIdTest2() {
        User usuarioGestorSinPS = CSBD_TestDataFactory.usuarioResponsable();

        System.runAs(usuarioGestorSinPS) {
            Test.startTest();
            Id listaCasos3NdeCSBD =  CSBD_Lista_Casos_Cola_Controller.getListviewCasos3nId();
            Test.stopTest();

            System.assertEquals(null, listaCasos3NdeCSBD, 'La ListView existe');
        }
    }

    @isTest
    private static void checkIsMemberTest() {
        User usuarioGestor = CSBD_TestDataFactory.usuarioGestor();
        GroupMember miembroCola = new GroupMember();
		miembroCola.GroupId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Cola_3N_CSBD' LIMIT 1].Id;
		miembroCola.UserOrGroupId = usuarioGestor.Id;
        insert miembroCola;

        System.runAs(usuarioGestor) {
            Test.startTest();
            Map<String, Boolean> esMiembroCola = CSBD_Lista_Casos_Cola_Controller.checkIsMember();
            Test.stopTest();

            System.assertEquals(true, esMiembroCola.get('esMiembroCola3n'), 'No es miembro de la cola');
        }
    }
}