@isTest
public with sharing class CSBD_Usuarios_Test {

    @isTest
    public static void crearUsuarioGestor() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();

        System.runAs (usuarioGestor) {
            Test.startTest();
            User usuarioGestorCreado = [SELECT Id, Alias, FirstName, IsActive FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
            Test.stopTest();

            System.assertEquals('Gestor', usuarioGestorCreado.Alias);
            System.assertEquals('GestorCSBD', usuarioGestorCreado.FirstName);
            System.assertEquals(true, usuarioGestorCreado.IsActive);
        }
    }

    @isTest
    public static void crearUsuarioResponsable() {
        User usuarioResponsable = CSBD_Usuarios.usuarioResponsable();

        System.runAs (usuarioResponsable) {
            Test.startTest();
            User usuarioResponsableCreado = [SELECT Id, Alias, FirstName, IsActive FROM User WHERE FirstName = 'ResponsCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];
            Test.stopTest();

            System.assertEquals('Respons', usuarioResponsableCreado.Alias);
            System.assertEquals('ResponsCSBD', usuarioResponsableCreado.FirstName);
            System.assertEquals(true, usuarioResponsableCreado.IsActive);
        }
    }

    @isTest
    public static void crearUsuarioAdministrador() {
        User usuarioAdministrador = CSBD_Usuarios.usuarioAdministrador();

        System.runAs (usuarioAdministrador) {
            Test.startTest();
                System.assertEquals('Admin', usuarioAdministrador.Alias);
                System.assertEquals('AdminCSBD', usuarioAdministrador.FirstName);
                System.assertEquals(true, usuarioAdministrador.IsActive);
            Test.stopTest();
        }
    }
    
    
     @isTest
    public static void crearUsuarioDerivarGestor() {
        User usuarioAdministrador = CSBD_Usuarios.usuarioDerivarGestor();

        System.runAs (usuarioAdministrador) {
            Test.startTest();
                System.assertEquals('GestDer', usuarioAdministrador.Alias);
                System.assertEquals('GestorDerivar', usuarioAdministrador.FirstName);
                System.assertEquals(true, usuarioAdministrador.IsActive);
            Test.stopTest();
        }
    }
}