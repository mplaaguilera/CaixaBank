@isTest
public with sharing class TMS_Usuarios_Test {

    @isTest
    public static void crearUsuarioLetrado() {
        User usuarioOperador = TMS_Usuarios.usuarioLetrado();

        System.runAs (usuarioOperador) {
            Test.startTest();
            User usuarioOperadorCreado = [SELECT Id, Alias, FirstName, IsActive FROM User WHERE FirstName = 'LetradoTMS' AND Profile.Name = 'TMS_UsuarioCaixabank' AND IsActive = true LIMIT 1];
            Test.stopTest();

            System.assertEquals('LetTMS', usuarioOperadorCreado.Alias);
            System.assertEquals('LetradoTMS', usuarioOperadorCreado.FirstName);
            System.assertEquals(true, usuarioOperadorCreado.IsActive);
        }
    }

    @isTest
    public static void crearUsuarioSupervisor() {
        User usuarioResponsable = TMS_Usuarios.usuarioSupervisor();

        System.runAs (usuarioResponsable) {
            Test.startTest();
            User usuarioResponsableCreado = [SELECT Id, Alias, FirstName, IsActive FROM User WHERE FirstName = 'SupervisorTMS' AND Profile.Name = 'TMS_UsuarioCaixabank' LIMIT 1];
            Test.stopTest();

            System.assertEquals('Superv1', usuarioResponsableCreado.Alias);
            System.assertEquals('SupervisorTMS', usuarioResponsableCreado.FirstName);
            System.assertEquals(true, usuarioResponsableCreado.IsActive);
        }
    }

    @isTest
    public static void crearUsuarioAdmin() {
        User usuarioAdmin = TMS_Usuarios.usuarioAdmin();

        System.runAs (usuarioAdmin) {
            Test.startTest();
                System.assertEquals('admin', usuarioAdmin.Alias);
                System.assertEquals('AdministradorOS', usuarioAdmin.FirstName);
                System.assertEquals(true, usuarioAdmin.IsActive);
            Test.stopTest();
        }
    }
    @isTest
    public static void crearUsuarioAdminTMS() {
        User usuarioAdmin = TMS_Usuarios.usuarioAdminTMS();

        System.runAs (usuarioAdmin) {
            Test.startTest();
                System.assertEquals('adminTMS', usuarioAdmin.Alias);
                System.assertEquals('AdministradorTMS', usuarioAdmin.FirstName);
                System.assertEquals(true, usuarioAdmin.IsActive);
            Test.stopTest();
        }
    }
    @isTest
    public static void crearUsuarioAPI() {
        User usuarioAPI = TMS_Usuarios.usuarioAPI();

        System.runAs (usuarioAPI) {
            Test.startTest();
                System.assertEquals('API_tms', usuarioAPI.Alias);
                System.assertEquals('TMSApi', usuarioAPI.FirstName);
                System.assertEquals(true, usuarioAPI.IsActive);
            Test.stopTest();
        }
    }
}