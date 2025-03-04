@isTest
public class CSBD_BatchIdentificarCliente_Test {

    @testSetup
    public static void altaDatosPrueba() {
        User usuarioGestor = CSBD_Usuarios.usuarioGestor();
        
        Map<String, SObject> mapa = CSBD_TestDataFactory.crearCuentaContacto('46979396X');

        Contact contacto = (Contact) mapa.get('contacto');
        contacto.CC_Numero_Documento__c = '46979396X';
        contacto.AV_NumPerso__c = '12196607';
        update contacto;
    }

    @isTest
    public static void batchAnonimar() {
        User usuarioGestor = [SELECT Id FROM User WHERE FirstName = 'GestorCSBD' AND Profile.Name = 'CSBD Gestor' LIMIT 1];

        System.runAs(usuarioGestor) {
            Map<String, Object> campos = new Map<String, Object>();
            campos.put('CSBD_Now_NIF__c', '46979396X');

            CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', campos);

            Test.startTest();
            Database.executeBatch(new CSBD_BatchIdentificarCliente());
            Test.stopTest();

            Opportunity hipoteca = [SELECT AccountId, CSBD_Contact__c, CSBD_Now_NIF__c
                                            FROM Opportunity WHERE CSBD_Now_NIF__c != null];

            Contact contacto = [select CC_Numero_Documento__c, AV_NumPerso__c from contact limit 1];

            Task[] tareaIdentificacion = [SELECT Id FROM Task WHERE Type =: 'Identificación del cliente'];

            System.assertNotEquals(null, hipoteca.AccountId, 'No se ha identificado correctamente la cuenta');
            System.assertNotEquals(null, hipoteca.CSBD_Contact__c, 'No se ha identificado correctamente el contacto');
            System.assert(!tareaIdentificacion.isEmpty());
        }
    }
}