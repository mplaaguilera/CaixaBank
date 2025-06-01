@isTest
public class CSBD_Utils_Test {

    @isTest
    private static void listaCampo() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Account cuenta1 = new Account(Name = 'Cuenta 1');
            Account cuenta2 = new Account(Name = 'Cuenta 2');
            Account cuenta3 = new Account(Name = 'Cuenta 3');
            List<Account> cuentas = new List<Account>{cuenta1, cuenta2, cuenta3};

            Test.startTest();
            List<String> nombres = CSBD_Utils.listaCampo(cuentas, 'Name');
            System.assertEquals('Cuenta 1', nombres[0], 'El primer elemento de la lista no es el correcto');
            System.assertEquals('Cuenta 2', nombres[1], 'El segundo elemento de la lista no es el correcto');
            System.assertEquals('Cuenta 3', nombres[2], 'El tercer elemento de la lista no es el correcto');

            List<Contact> contactos = [SELECT Account.RecordType.Name FROM Contact WHERE AccountId IN :CSBD_Utils.listaCampo(cuentas, 'Id')];
            List<String> nombreRecordTypes = CSBD_Utils.listaCampo(contactos, 'Account.RecordType.Name');
            Test.stopTest();

        }
    }

    @isTest
    private static void mapaCampo() {
        System.runAs(CSBD_TestDataFactory.usuarioAdministrador()) {
            CSBD_TestDataFactory.crearCuentaContacto('99999999R');
            System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
                Test.startTest();
                Map<String, SObject> mapaCampo= CSBD_Utils.mapaCampo([SELECT Account.Name FROM Contact LIMIT 3], 'Account.Name');
                Test.stopTest();

                System.assertNotEquals(null, mapaCampo);
            }
        }
    }

    @isTest
    private static void descartarDuplicadosLista() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            List<String> lista = new List<String>{'c', 'b', 'c', 'z', 'f', 'f'};
            List<String> listaSinDuplicados = new List<String>{'c', 'b', 'z', 'f'};

            Test.startTest();
            lista = CSBD_Utils.descartarDuplicadosLista(lista);
            Test.stopTest();

            System.assert(lista.equals(listaSinDuplicados), 'La lista debería mantener el orden y no tener elementos duplicados.');
        }
    }

    @isTest
    private static void excelPago() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            Decimal d = CSBD_Utils.excelPago(0.01, 12, 1000);
            Test.stopTest();

            System.debug(d);
            System.assertEquals(-88, d.intValue(), 'La parte entera del valor devuelto no es la esperada');
        }
    }

    @isTest
    private static void excelSumaProducto() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            Decimal d = CSBD_Utils.excelSumaProducto(new List<Decimal>{1, 2, 3}, new List<Decimal>{4, 5, 6});
            Test.stopTest();

            System.assert(Math.abs(d - 32) < 0.01, 'El valor devuelto no es el esperado');
        }
    }

    @isTest
    private static void sumarListas() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            List<Decimal> lista = CSBD_Utils.sumarListas(new List<List<Decimal>>{new List<Decimal>{1, 2, 3}, new List<Decimal>{4, 5, 6}});
            Test.stopTest();

            System.assertEquals(3, lista.size(), 'La lista devuelta no tiene el tamaño esperado');
            System.assertEquals(5, lista[0], 'El primer elemento de la lista no es el esperado');
            System.assertEquals(7, lista[1], 'El segundo elemento de la lista no es el esperado');
            System.assertEquals(9, lista[2], 'El tercer elemento de la lista no es el esperado');
        }
    }

    @isTest
    private static void hexToDec() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {
            Test.startTest();
            String dec = CSBD_Utils.hexToDec('1A');
            Test.stopTest();

            System.assertEquals('26', dec, 'El valor devuelto no es el esperado');
        }
    }
}