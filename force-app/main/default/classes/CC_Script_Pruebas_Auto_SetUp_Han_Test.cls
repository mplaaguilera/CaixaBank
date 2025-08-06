@isTest
public class CC_Script_Pruebas_Auto_SetUp_Han_Test
{

    /*@isTest
    public static void insercionUsersTest()
    {
		Id rolCC = [SELECT Id, Name, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        Id profileCC = [SELECT Id FROM Profile WHERE Name = 'CC_Operador básico RRHH'].Id;

        User usuario1 = new user();
        usuario1.FirstName = 'Usuario test';
        usuario1.LastName = 'Usuario test';
        usuario1.UserRoleId = rolCC;//
        usuario1.ProfileId = profileCC;//
        usuario1.Email = 'pruebatest@ibm.com';
        usuario1.Username = 'pruebatest@ibm.com';
        usuario1.Alias = 'ugene';
        usuario1.TimeZoneSidKey = 'Europe/Paris';
        usuario1.EmailEncodingKey = 'UTF-8';
        usuario1.LanguageLocaleKey = 'es';
        usuario1.LocaleSidKey = 'es_ES';
        usuario1.FederationIdentifier = 'U0100000@caixabankpre.com';
        usuario1.EmployeeNumber = 'U0100000';
        insert usuario1;
        Test.startTest();
        CC_Script_Pruebas_Auto_SetUp_Han.insercionDatos();
        Test.stopTest();

        List<User> listaComprobacionUsuario = [SELECT Id, EmployeeNumber FROM User WHERE ((FirstName like 'U0190044 % ROBOT' AND LastName = 'GENERICO NTTDATA') OR (FirstName like 'U01A1526 % ROBOT' AND LastName= 'EVERIS SELENIUM') OR (FirstName = 'Usuario test' AND LastName= 'Usuario test')) AND IsActive = TRUE];
        System.assertEquals(3, listaComprobacionUsuario.size());
    }*/
    
    @isTest
    public static void insercionPlantillaTest()
    {
        List<EmailTemplate> listaPlantilla;
        Test.startTest();
        CC_Script_Pruebas_Auto_SetUp_Han.insercionDatos();
        Test.stopTest();
        
        List<EmailTemplate> listaComprobacionPlantilla = [SELECT Id FROM EmailTemplate WHERE Developername IN ('CSBD_3N', 'Desistimiento_Moratoria_Adjuntar_modelo_1589988526320', 'Primera_comunicaci_n_Castellano_formal_1563465938755', 'Remitido_Generico_Telefono_Clientes', 'Traslado_Generico_Telefono_Clientes')];
        System.assertEquals(5, listaComprobacionPlantilla.size());
    }
}