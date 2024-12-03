@isTest
public class CC_OpportunityLineItem_Insert_Test {
    @testSetup
    private static void altaDatosPrueba() {
        Product2 nuevoProducto = new Product2();
        nuevoProducto.Name = 'Producto Prueba de Oliver';
        nuevoProducto.IsActive = true;
        insert nuevoProducto;

        id standardPBID = Test.getStandardPricebookId(); 
        PricebookEntry preciosAlta = new PricebookEntry();
        preciosAlta.Pricebook2Id = standardPBID;
        preciosAlta.Product2Id = nuevoProducto.Id;
        preciosAlta.UnitPrice = 0;
        preciosAlta.IsActive = true;
        insert preciosAlta;

        Account nuevaCuenta = new Account();
        nuevaCuenta.Name = 'Oliver';
        insert nuevaCuenta;
        
        Contact nuevoContacto = new Contact();
        nuevoContacto.Email = 'test@test.com';
        nuevoContacto.FirstName = 'Oliver';
        nuevoContacto.LastName = 'Bocanegra Pérez';
        nuevoContacto.AccountId = nuevaCuenta.Id;
        insert nuevoContacto;
    }
    @isTest
    public static void testDatosPrueba() {        
       	Product2 productoExiste = [SELECT Id FROM Product2 WHERE Name = 'Producto Prueba de Oliver'];
        PricebookEntry preciosAltaExiste = [SELECT Id FROM PricebookEntry WHERE Product2Id = :productoExiste.Id];
        Account cuentaExiste = [SELECT Id FROM Account WHERE Name = 'Oliver'];

        Opportunity nuevaOportunidad = new Opportunity();
        nuevaOportunidad.Name = 'olivertest';
        nuevaOportunidad.StageName = 'Formalizada';
        nuevaOportunidad.CSBD_Estado__c = 'Cerrada';
        nuevaOportunidad.AccountId = cuentaExiste.Id;
        insert nuevaOportunidad;

        OpportunityLineItem nuevoLineItem = new OpportunityLineItem();
        nuevoLineItem.OpportunityId = nuevaOportunidad.Id;
        nuevoLineItem.PricebookEntryId = preciosAltaExiste.Id;
        nuevoLineItem.Product2Id = productoExiste.Id;
        Test.startTest();
        insert nuevoLineItem;
        Test.stopTest();
        OpportunityLineItem elLineItemInsertado = [SELECT Id, ServiceDate FROM OpportunityLineItem WHERE PricebookEntryId = :preciosAltaExiste.Id AND Product2Id = :productoExiste.Id AND OpportunityId = :nuevaOportunidad.Id];
        System.assertEquals(System.today(), elLineItemInsertado.ServiceDate, 'El campo ServiceDate no es la fecha del dia de hoy');
    }
}