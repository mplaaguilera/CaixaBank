@isTest
public class CC_Opportunity_Insert_Test {
    
    @testSetup
	static void testSetup() {
        //Alta de productos
        Product2 productoPrestamo = new Product2();
        productoPrestamo.Name = 'Préstamo';
        productoPrestamo.IsActive = true;
        insert productoPrestamo;

        Product2 productoSeviam = new Product2();
        productoSeviam.Name = 'Seguro SEVIAM';
        productoSeviam.IsActive = true;
        insert productoSeviam;

        Product2 productoHipoteca = new Product2();
        productoHipoteca.Name = 'Hipoteca';
        productoHipoteca.IsActive = true;
        insert productoHipoteca;
        
        //Alta de lista de precios estándar
        //Test.getStandardPricebookId() permite recuperar el Id de la lista de
        //precios estándar de la org sin tener que habilitar @isTest(SeeAllData=true)
        Pricebook2 listaPrecios = new Pricebook2(Id = Test.getStandardPricebookId());
        listaPrecios.Name = 'Standard Price Book';
        listaPrecios.IsActive = true;
        update listaPrecios;
        
        //Alta de los precios de la lista para cada producto
        PricebookEntry precioPrestamo = new PricebookEntry();
        precioPrestamo.Pricebook2Id = listaPrecios.Id;
        precioPrestamo.Product2Id = productoPrestamo.Id;
        precioPrestamo.UseStandardPrice = false;
        precioPrestamo.UnitPrice = 0;
        precioPrestamo.IsActive = true;
        insert precioPrestamo;
        
        PricebookEntry precioSeviam = new PricebookEntry();
        precioSeviam.Pricebook2Id = listaPrecios.Id;
        precioSeviam.Product2Id = productoSeviam.Id;
        precioSeviam.UseStandardPrice = false;
        precioSeviam.UnitPrice = 0;
        precioSeviam.IsActive = true;
        insert precioSeviam;

        PricebookEntry precioHipoteca = new PricebookEntry();
        precioHipoteca.Pricebook2Id = listaPrecios.Id;
        precioHipoteca.Product2Id = productoHipoteca.Id;
        precioHipoteca.UnitPrice = 0;
        precioHipoteca.UseStandardPrice = false;
        precioHipoteca.IsActive = true;
        insert precioHipoteca;

        Pricebook2 listaPreciosCsbd = new Pricebook2();
        listaPreciosCsbd.Name = 'CSBD Price Book';
        listaPreciosCsbd.Description = 'CSBD Price Book';
        listaPreciosCsbd.IsActive = true;
        insert listaPreciosCsbd;
        
        //Alta de los precios de la lista para cada producto
        PricebookEntry precioPrestamoCsbd = new PricebookEntry();
        precioPrestamoCsbd.Pricebook2Id = listaPreciosCsbd.Id;
        precioPrestamoCsbd.Product2Id = productoPrestamo.Id;
        precioPrestamoCsbd.UseStandardPrice = false;
        precioPrestamoCsbd.UnitPrice = 0;
        precioPrestamoCsbd.IsActive = true;
        insert precioPrestamoCsbd;
        
        PricebookEntry precioSeviamCsbd = new PricebookEntry();
        precioSeviamCsbd.Pricebook2Id = listaPreciosCsbd.Id;
        precioSeviamCsbd.Product2Id = productoSeviam.Id;
        precioSeviamCsbd.UseStandardPrice = false;
        precioSeviamCsbd.UnitPrice = 0;
        precioSeviamCsbd.IsActive = true;
        insert precioSeviamCsbd;

        PricebookEntry precioHipotecaCsbd = new PricebookEntry();
        precioHipotecaCsbd.Pricebook2Id = listaPreciosCsbd.Id;
        precioHipotecaCsbd.Product2Id = productoHipoteca.Id;
        precioHipotecaCsbd.UnitPrice = 0;
        precioHipotecaCsbd.UseStandardPrice = false;
        precioHipotecaCsbd.IsActive = true;
        insert precioHipotecaCsbd;

        //Alta de lista de valores de productos iniciales de la oportunidad
        CC_Lista_Valores__c lovProductosIniciales = new CC_Lista_Valores__c();
        lovProductosIniciales.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovProductosIniciales.Name = 'CSBD: Productos iniciales oportunidad';
        lovProductosIniciales.CC_Activa__c = true;
        insert lovProductosIniciales;
        
        CC_Lista_Valores__c lovProductoInicialPrestamo1 = new CC_Lista_Valores__c();
        lovProductoInicialPrestamo1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        lovProductoInicialPrestamo1.CC_Lista__c = lovProductosIniciales.Id;
        lovProductoInicialPrestamo1.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Opportunity', 'CSBD_Prestamo');
        lovProductoInicialPrestamo1.CC_Activa__c = true;
        lovProductoInicialPrestamo1.CC_Valor__c = 'Préstamo';
        lovProductoInicialPrestamo1.CC_Orden__c = 1;
        insert lovProductoInicialPrestamo1;
        
        CC_Lista_Valores__c lovProductoInicialPrestamo2 = new CC_Lista_Valores__c();
        lovProductoInicialPrestamo2.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        lovProductoInicialPrestamo2.CC_Lista__c = lovProductosIniciales.Id;
        lovProductoInicialPrestamo2.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Opportunity', 'CSBD_Prestamo');
        lovProductoInicialPrestamo2.CC_Activa__c = true;
        lovProductoInicialPrestamo2.CC_Valor__c = 'Seguro SEVIAM';
        lovProductoInicialPrestamo2.CC_Orden__c = 2;
        insert lovProductoInicialPrestamo2;
        
        CC_Lista_Valores__c lovProductoInicialHipoteca = new CC_Lista_Valores__c();
        lovProductoInicialHipoteca.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        lovProductoInicialHipoteca.CC_Lista__c = lovProductosIniciales.Id;
        lovProductoInicialHipoteca.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Opportunity', 'CSBD_Hipoteca');
        lovProductoInicialHipoteca.CC_Activa__c = true;
        lovProductoInicialHipoteca.CC_Valor__c = 'Hipoteca';
        lovProductoInicialHipoteca.CC_Orden__c = 1;
        insert lovProductoInicialHipoteca;
        
        //Alta de lista de valores de días de cierre por defecto de la oportunidad
        CC_Lista_Valores__c lovDiasCierre = new CC_Lista_Valores__c();
        lovDiasCierre.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovDiasCierre.Name = 'CSBD: Días cierre oportunidad por defecto';
        lovDiasCierre.CC_Activa__c = true;
        insert lovDiasCierre;
        
        CC_Lista_Valores__c lovDiasCierrePrestamo = new CC_Lista_Valores__c();
        lovDiasCierrePrestamo.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        lovDiasCierrePrestamo.CC_Lista__c = lovDiasCierre.Id;
        lovDiasCierrePrestamo.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Opportunity', 'CSBD_Prestamo');
        lovDiasCierrePrestamo.CC_Activa__c = true;
        lovDiasCierrePrestamo.CC_Valor__c = '7';
        insert lovDiasCierrePrestamo;
        
        CC_Lista_Valores__c lovDiasCierreHipoteca = new CC_Lista_Valores__c();
        lovDiasCierreHipoteca.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        lovDiasCierreHipoteca.CC_Lista__c = lovDiasCierre.Id;
        lovDiasCierreHipoteca.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Opportunity', 'CSBD_Hipoteca');
        lovDiasCierreHipoteca.CC_Activa__c = true;
        lovDiasCierreHipoteca.CC_Valor__c = '30';
        insert lovDiasCierreHipoteca;
    }

    @isTest
    public static void test() {

        Test.startTest();
        //Creación de préstamo
        Opportunity nuevaOportunidadPrestamo = CSBD_Opportunity.crearOportunidad('CSBD_Prestamo');

        //Creación de hipoteca
        Account cuenta = new Account();
        cuenta.Name = 'cuentaPrueba';
        insert cuenta;

        Opportunity nuevaOportunidadHipoteca = CSBD_Opportunity.crearOportunidad(
            'CSBD_Hipoteca',
            new Map<String, Object>{'AccountId' => cuenta.Id}
        );

        //Validaciones
        Opportunity prestamo = [SELECT CSBD_Identificador__c, Name, RecordType.Name, CloseDate, CreatedDate FROM Opportunity WHERE Id = :nuevaOportunidadPrestamo.Id];
        Opportunity hipoteca = [SELECT CSBD_Identificador__c, Name, RecordType.Name, CloseDate, CreatedDate FROM Opportunity WHERE Id = :nuevaOportunidadHipoteca.Id];
        
        //Before Insert: inicializar campos oportunidad
        String diasFechaCierreHipoteca = [SELECT CC_Valor__c FROM CC_Lista_Valores__c
                                            WHERE CC_Activa__c = true AND CC_Lista__r.Name = 'CSBD: Días cierre oportunidad por defecto'
                                            AND Name = :hipoteca.RecordType.Name LIMIT 1].CC_Valor__c;
        System.assertEquals(System.today().addDays(Integer.valueOf(diasFechaCierreHipoteca)), hipoteca.CloseDate);

        //Before Insert: actualizar nombre de la oportunidad
        System.assertEquals(prestamo.CSBD_Identificador__c + ' - ' + prestamo.RecordType.Name, prestamo.Name);
        System.assertEquals(hipoteca.CSBD_Identificador__c + ' - ' + hipoteca.RecordType.Name, hipoteca.Name);

        //After Insert: productos iniciales de la oportunidad
        System.assertEquals(2, [SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :nuevaOportunidadPrestamo.Id]);
        System.assertEquals(1, [SELECT Count() FROM OpportunityLineItem WHERE OpportunityId = :nuevaOportunidadHipoteca.Id]);
    }
}