@isTest
private class CSBD_ServicioGenesysFuncionApexTest {

    @TestSetup
    static void setupTestData() {
        // Crear el RecordType per "Lista de valores"
        RecordType rtLista = [SELECT Id FROM RecordType
                              WHERE SObjectType = 'CC_Lista_Valores__c'
                              AND Name = 'Lista de valores'
                              LIMIT 1];

        // Crear el RecordType per "Valor"
        RecordType rtValor = [SELECT Id FROM RecordType
                              WHERE SObjectType = 'CC_Lista_Valores__c'
                              AND Name = 'Valor'
                              LIMIT 1];

        // Crear la llista principal (RecordType "Lista de valores")
        CC_Lista_Valores__c lista = new CC_Lista_Valores__c(
            RecordTypeId = rtLista.Id,
            Name = 'CSBD: Configuración de rellamadas'
        );
        insert lista;

        // Crear els valors de la llista (RecordType "Valor")
        List<CC_Lista_Valores__c> valores = new List<CC_Lista_Valores__c>();

        valores.add(new CC_Lista_Valores__c(
            RecordTypeId = rtValor.Id,
            CC_Lista__c = lista.Id,
            CC_Activa__c = true,
            Name = 'Opción para el campo Función de Servicio Genesys',
            CC_Valor__c = 'Función 1',
            CC_Orden__c = 1
        ));

        valores.add(new CC_Lista_Valores__c(
            RecordTypeId = rtValor.Id,
            CC_Lista__c = lista.Id,
            CC_Activa__c = true,
            Name = 'Opción para el campo Función de Servicio Genesys',
            CC_Valor__c = 'Función 2',
            CC_Orden__c = 2
        ));

        valores.add(new CC_Lista_Valores__c(
            RecordTypeId = rtValor.Id,
            CC_Lista__c = lista.Id,
            CC_Activa__c = false, // Inactiva
            Name = 'Opción para el campo Función de Servicio Genesys',
            CC_Valor__c = 'Función 3',
            CC_Orden__c = 3
        ));

        insert valores;
    }

    @isTest
    static void testGetServicioGenesysFuncionOptions() {
        System.runAs(CSBD_TestDataFactory.usuarioGestor()) {

            Test.startTest();

            List<String> resultado = CSBD_ServicioGenesysFuncionApex.getServicioGenesysFuncionOptions();

            Test.stopTest();

            // Verificar que retorna només els valors actius i ordenats
            System.assertEquals(2, resultado.size(), 'Debería retornar solo 2 valores activos');
            System.assertEquals('Función 1', resultado[0], 'El primer valor debería ser Función 1');
            System.assertEquals('Función 2', resultado[1], 'El segundo valor debería ser Función 2');

        }
    }
}