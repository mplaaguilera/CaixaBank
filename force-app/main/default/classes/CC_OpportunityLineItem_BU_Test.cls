@isTest
public class CC_OpportunityLineItem_BU_Test {
    @testSetup
    private static void altaDatosPrueba() {
        Product2 nuevoProducto = new Product2();
        nuevoProducto.Name = 'Producto Prueba de Oliver';
        nuevoProducto.IsActive = true;
        insert nuevoProducto;
    
        Pricebook2 nuevaListaPrecios = new Pricebook2();
        nuevaListaPrecios.Name = 'CSBD Precios de Oliver';
        nuevaListaPrecios.Description = 'CSBD Precios de Oliver';
        nuevaListaPrecios.IsActive = true;
        insert nuevaListaPrecios;

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
    public static void testActualizarDatosPrueba() {        
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
        nuevoLineItem.CSBD_Producto_Principal__c = true;
        insert nuevoLineItem;
        
        Test.startTest();
        nuevoLineItem.Quantity = 15;
        nuevoLineItem.UnitPrice = 10;
        update nuevoLineItem;
        Test.stopTest();

        Opportunity laOportunidadInsertada = [SELECT CSBD_Importe_Producto_Principal__c FROM Opportunity WHERE AccountId = :cuentaExiste.Id AND Id = :nuevaOportunidad.Id];  
        OpportunityLineItem elLineItemInsertado = [SELECT Subtotal FROM OpportunityLineItem WHERE PricebookEntryId = :preciosAltaExiste.Id AND Product2Id = :productoExiste.Id AND OpportunityId = :nuevaOportunidad.Id];  
        System.assertEquals(laOportunidadInsertada.CSBD_Importe_Producto_Principal__c, elLineItemInsertado.Subtotal, 'El campo no es correcto ');
    }
}