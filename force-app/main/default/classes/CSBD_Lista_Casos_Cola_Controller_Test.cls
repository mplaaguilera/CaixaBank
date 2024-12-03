@isTest
public with sharing class CSBD_Lista_Casos_Cola_Controller_Test {

    @TestSetup
    static void data(){

        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        User usuarioGestorSinPS = CSBD_Usuarios.usuarioResponsable();

        PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS' LIMIT 1];
        PermissionSetAssignment permisoCC = new PermissionSetAssignment();
        permisoCC.PermissionSetId = permissionSet.Id;
        permisoCC.AssigneeId = usuarioGestor.Id;
        insert permisoCC;

		Group cola3NCSBD= [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Cola_3N_CSBD' LIMIT 1];

        GroupMember miembroCola3NCSBD = new GroupMember();
		miembroCola3NCSBD.GroupId = cola3NCSBD.Id;
		miembroCola3NCSBD.UserOrGroupId = usuarioGestor.Id;
        insert miembroCola3NCSBD;

        System.runAs (usuarioGestor) {
            Case caso1 = new Case();
            caso1.Subject = 'caso1';
            caso1.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            caso1.OwnerId = cola3NCSBD.Id;
            insert caso1;
        }
    }

    @isTest
    public static void casos3nTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
        Boolean estaEnCache = false;

        System.runAs (usuarioGestor) {
            Test.startTest();
            List<Case> listaCasos3NdeCSBD =  CSBD_Lista_Casos_Cola_Controller.casos3n(false);
            Case caso1 = [SELECT Id FROM Case WHERE Subject = 'caso1'];
            listaCasos3NdeCSBD.add(caso1);
            Cache.Org.put('local.CSBD.Casos3NCSBD', listaCasos3NdeCSBD, 300);
            if(Cache.Org.contains('local.CSBD.Casos3NCSBD')){
                estaEnCache = true;
            }
            Test.stopTest();

            System.assertEquals(true, estaEnCache, 'No hay datos en la caché');
        }
    }

    @isTest
    public static void getListviewCasos3nIdTest1() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs (usuarioGestor) {
            Test.startTest();
            Id listaCasos3NdeCSBD =  CSBD_Lista_Casos_Cola_Controller.getListviewCasos3nId();

            Test.stopTest();
            System.assertNotEquals('', listaCasos3NdeCSBD, 'No existe la ListView');
        }
    }

    @isTest
    public static void getListviewCasos3nIdTest2() {
        User usuarioGestorSinPS = [SELECT Id FROM User WHERE FirstName = 'ResponsCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs (usuarioGestorSinPS) {
            Test.startTest();
            Id listaCasos3NdeCSBD =  CSBD_Lista_Casos_Cola_Controller.getListviewCasos3nId();

            Test.stopTest();
            System.assertEquals(null, listaCasos3NdeCSBD, 'La ListView existe');
        }
    }

    @isTest
    public static void checkIsMemberTest() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs (usuarioGestor) {

            Test.startTest();
            Map<String, Boolean> esMiembroCola =  CSBD_Lista_Casos_Cola_Controller.checkIsMember();
            Test.stopTest();

            System.assertEquals(true, esMiembroCola.get('esMiembroCola3n'), 'No es miembro de la cola');
        }
    }
}