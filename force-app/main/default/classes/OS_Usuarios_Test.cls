@isTest
public with sharing class OS_Usuarios_Test {

    @isTest
    public static void crearUsuarioOperador() {
        User usuarioOperador = OS_Usuarios.usuarioOperador();

        System.runAs (usuarioOperador) {
            Test.startTest();
            User usuarioOperadorCreado = [SELECT Id, Alias, FirstName, IsActive FROM User WHERE FirstName = 'OperadorOS' AND Profile.Name = 'OS_Operador' LIMIT 1];
            Test.stopTest();

            System.assertEquals('Operador', usuarioOperadorCreado.Alias);
            System.assertEquals('OperadorOS', usuarioOperadorCreado.FirstName);
            System.assertEquals(true, usuarioOperadorCreado.IsActive);
        }
    }

    @isTest
    public static void crearUsuarioResponsable() {
        User usuarioResponsable = OS_Usuarios.usuarioResponsable();

        System.runAs (usuarioResponsable) {
            Test.startTest();
            User usuarioResponsableCreado = [SELECT Id, Alias, FirstName, IsActive FROM User WHERE FirstName = 'ResponsableOS' AND Profile.Name = 'OS_Responsable' LIMIT 1];
            Test.stopTest();

            System.assertEquals('Resp1', usuarioResponsableCreado.Alias);
            System.assertEquals('ResponsableOS', usuarioResponsableCreado.FirstName);
            System.assertEquals(true, usuarioResponsableCreado.IsActive);
        }
    }

    @isTest
    public static void crearUsuarioAdmin() {
        User usuarioAdmin = OS_Usuarios.usuarioAdmin();

        System.runAs (usuarioAdmin) {
            Test.startTest();
                System.assertEquals('admin', usuarioAdmin.Alias);
                System.assertEquals('AdministradorOS', usuarioAdmin.FirstName);
                System.assertEquals(true, usuarioAdmin.IsActive);
            Test.stopTest();
        }
    }
}