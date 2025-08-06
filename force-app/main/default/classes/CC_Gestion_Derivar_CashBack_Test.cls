@isTest
public with sharing class CC_Gestion_Derivar_CashBack_Test {

    @TestSetup
    static void makeData() {
        Map<String, Id> profilesCC = CC_TestDataFactory.getProfiles();
        Map<String, Id> rolesCC = CC_TestDataFactory.getRoles();
        Map<String, Id> psCC = CC_TestDataFactory.getPermissionSet();

        User usuarioAdmin = CC_TestDataFactory.createUserAdmin(profilesCC.get('System Administrator'), rolesCC.get('Contact_Center'));
        User operadorCliente = CC_TestDataFactory.createtUserOperador(profilesCC.get('CC_Usuario_CaixaBank'), rolesCC.get('Contact_Center_sin_acceso_a_Directorio'), 'U0124112');
        List<User> usuarios = new List<User>{usuarioAdmin, operadorCliente};
        insert usuarios;

        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId =  psCC.get('CC_Operador_Cliente'));
        insert psaOperadorCliente;

        Id recordTypeCaso = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
    } 
    
    @isTest
    public static void actualizarDatosCashBackTest() {
        Test.startTest();
        System.runAs(CC_TestDataFactory.getUserOperadorCliente()) {    
            Case caso = new Case(
                Subject = 'Test CashBack',
                Origin = 'Email',
                Status = 'Activo',
                RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente')
            );
            insert caso;

            // Caso sin CBK_Case_Extension_Id__c
            String detallesConsulta = 'Detalles de la consulta';
            String idCliente = 'idCliente';
            String nombreComercio = 'nombreComercio';
            Date fechaCompra = Date.newInstance(2022, 1, 1);
            CC_Gestion_Derivar_CashBack.actualizarDatosCashBack(caso.Id, detallesConsulta, idCliente, nombreComercio, fechaCompra);
            Case casoUpd = [SELECT CBK_Case_Extension_Id__c, CC_Detalles_Consulta__c FROM Case WHERE Id =: caso.Id];
            System.assert(casoUpd.CBK_Case_Extension_Id__c != null, 'No se ha creado el registro CBK_Case_Extension__c');
            System.assertEquals(detallesConsulta, casoUpd.CC_Detalles_Consulta__c, 'No se ha actualizado el campo CC_Detalles_Consulta__c');

            // Caso con CBK_Case_Extension_Id__c
            CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c(
                Case_Id__c = caso.Id,
                CC_ID_cliente__c = 'idClienteAntiguo',
                CC_Nombre_Comercio__c = 'nombreComercioAntiguo',
                CC_Fecha_De_Compra__c = Date.newInstance(2021, 12, 31)
            );
            insert caseExtension;
            caso.CBK_Case_Extension_Id__c = caseExtension.Id;
            update caso;

            detallesConsulta = 'Detalles de la consulta actualizados';
            idCliente = 'idClienteNuevo';
            nombreComercio = 'nombreComercioNuevo';
            fechaCompra = Date.newInstance(2022, 1, 2);
            CC_Gestion_Derivar_CashBack.actualizarDatosCashBack(caso.Id, detallesConsulta, idCliente, nombreComercio, fechaCompra);
            caseExtension = [SELECT CC_ID_cliente__c, CC_Nombre_Comercio__c, CC_Fecha_De_Compra__c FROM CBK_Case_Extension__c WHERE Id =: caseExtension.Id];
            System.assertEquals(idCliente, caseExtension.CC_ID_cliente__c, 'No se ha actualizado el campo CC_ID_cliente__c');
            System.assertEquals(nombreComercio, caseExtension.CC_Nombre_Comercio__c, 'No se ha actualizado el campo CC_Nombre_Comercio__c');
            System.assertEquals(fechaCompra, caseExtension.CC_Fecha_De_Compra__c, 'No se ha actualizado el campo CC_Fecha_De_Compra__c');
            casoUpd = [SELECT CC_Detalles_Consulta__c FROM Case WHERE Id =: caso.Id];
            System.assertEquals(detallesConsulta, casoUpd.CC_Detalles_Consulta__c, 'No se ha actualizado el campo CC_Detalles_Consulta__c');
        }
        Test.stopTest();
    }
}