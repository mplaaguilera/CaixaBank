@isTest
public class CSBD_Utils_Test {

    @isTest
    private static void listaCampo() {
        Account cuenta1 = new Account(Name = 'Cuenta 1');
        Account cuenta2 = new Account(Name = 'Cuenta 2');
        Account cuenta3 = new Account(Name = 'Cuenta 3');
        List<Account> cuentas = new List<Account>{cuenta1, cuenta2, cuenta3};

        List<String> nombres = CSBD_Utils.listaCampo(cuentas, 'Name');
        System.assertEquals('Cuenta 1', nombres[0], 'El primer elemento de la lista no es el correcto');
        System.assertEquals('Cuenta 2', nombres[1], 'El segundo elemento de la lista no es el correcto');
        System.assertEquals('Cuenta 3', nombres[2], 'El tercer elemento de la lista no es el correcto');
    }
}