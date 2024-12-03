/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   10-31-2022   Adrian Mariscal   Initial Version
**/
@IsTest
public class CC_PrecioFacturacion_BI_BU_TRHan_Test{

    @TestSetup
    static void crearRegistros()
    {

        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';

        insert mccTematica;

        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'MCC Producto';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';

        insert mccProducto;


        CBK_CatalogoFacturacion__c catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 5);
        catalogo.CC_Area_Negocio__c ='WIVAI';
        catalogo.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo.CC_Tipo_Cliente__c = mccTematica.CC_Tipo_Cliente__c;
        catalogo.CC_Tematica__c = mccTematica.id;
        catalogo.CC_Producto__c = mccProducto.id;

        insert catalogo;


        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precio1 = new CBK_Precio_Facturacion__c();
        precio1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precio1.CC_Nombre_Empresa__c = 'MST';
        precio1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 2);
        precio1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 4);
        precio1.CC_Area_Negocio__c ='WIVAI';
        precio1.CC_Canal_Entrada__c = 'Backoffice';
        precio1.CC_Precio_Contacto__c = 1.25;
        listaPrecio.add(precio1);

        CBK_Precio_Facturacion__c precio2 = new CBK_Precio_Facturacion__c();
        precio2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precio2.CC_Nombre_Empresa__c = 'MST';
        precio2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2022, 1, 1);
        precio2.CC_Area_Negocio__c ='WIVAI';
        precio2.CC_Canal_Entrada__c = 'Backoffice';
        precio2.CC_Precio_Contacto__c = 1.25;
        listaPrecio.add(precio2);

        
        insert listaPrecio;
    }


    //Se van a testear las clases

    //Test BI 1: Creacion sin problemas de un registro delante de otro ya creado (Correcto)

    @isTest
    public static void fechasSinError()
    {

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 5);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 6);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        

        Test.startTest();
            insert precioTest1;
        Test.stopTest();

        List<CBK_Precio_Facturacion__c> precioResultado = [SELECT Name, CC_Fecha_Inicio_Vigencia__c, CC_Fecha_Fin_Vigencia__c FROM CBK_Precio_Facturacion__c WHERE CC_Fecha_Inicio_Vigencia__c = 2021-12-05 ];
        System.assertEquals(1, precioResultado.size(), 'No existe un registro con fechas similares');
        System.assertEquals(Date.newInstance(2021, 12, 5), precioResultado[0].CC_Fecha_Inicio_Vigencia__c, 'Se ha creado el registro con fecha de inicio 2021-12-05');
        System.assertEquals(Date.newInstance(2021, 12, 6), precioResultado[0].CC_Fecha_Fin_Vigencia__c, 'Se ha creado el registro con fecha de fin 2021-12-06');
    }
    //Test BI 1.2: Creacion sin problemas de lista de registros delante y detras de otro ya creado (Correcto)
    @isTest
    public static void listasFechasSinError()
    {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 5);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 6);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 7);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 8);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);
        
        Test.startTest();
            insert listaPrecio;
        Test.stopTest();

        List<CBK_Precio_Facturacion__c> precioResultado = [SELECT Name, CC_Fecha_Inicio_Vigencia__c, CC_Fecha_Fin_Vigencia__c FROM CBK_Precio_Facturacion__c WHERE 
        CC_Fecha_Inicio_Vigencia__c = 2021-12-05 
        OR CC_Fecha_Inicio_Vigencia__c =2021-12-07  ORDER BY CC_Fecha_Inicio_Vigencia__c];
        System.assertEquals(2, precioResultado.size(), 'No existen registros con fechas similares');
        System.assertEquals(Date.newInstance(2021, 12, 5), precioResultado[0].CC_Fecha_Inicio_Vigencia__c, 'Se ha creado el registro con fecha de inicio 2021-12-05');
        System.assertEquals(Date.newInstance(2021, 12, 6), precioResultado[0].CC_Fecha_Fin_Vigencia__c, 'Se ha creado el registro con fecha de fin 2021-12-06');
        System.assertEquals(Date.newInstance(2021, 12, 7), precioResultado[1].CC_Fecha_Inicio_Vigencia__c, 'Se ha creado el registro con fecha de inicio 2021-12-07');
        System.assertEquals(Date.newInstance(2021, 12, 8), precioResultado[1].CC_Fecha_Fin_Vigencia__c, 'Se ha creado el registro con fecha de fin 2021-12-08');
    }
    
    //Test BI 2: Crear un registro con la fecha inicial en medio de otro registro (Error)
    @isTest
    public static void ErrorFechaInicio()
    {
        
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2022, 12, 3);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2022, 12, 5);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;

        Test.startTest();
        try{
            insert precioTest1;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true, 'Ya existe un registro con fechas similares');
        }
        Test.stopTest();
    }
    
    //Test BI 2.2: Crear lista de registros con la fecha inicial en medio de otro registro (Error)
    @isTest
    public static void ErrorListaFechaInicio()
    {
        
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 3);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 4);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 6);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 7);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);
        
        Test.startTest();
        try{
            insert listaPrecio;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    //Test BI 3: Crear un registro con la fecha fin en medio de otro registro (Error)
    @isTest
    public static void ErrorFechaFin()
    {
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2022, 12, 3);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        Test.startTest();
        try{
            insert precioTest1;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Test BI 3.2: Crear una lista de registros con la fecha fin en medio de otro registro (Error)
    @isTest
    public static void ErrorListaFechaFin()
    {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 3);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 6);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 7);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);
            
        Test.startTest();
        try{
            insert precioTest1;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
        
    //Test BI 4: Crear un registro que el inicio y el fin estén dentro de otro registro (Error)
    @isTest
    public static void ErrorFechaCompletaRegistro()
    {
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2022, 12, 3);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2022, 12, 3);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;

        Test.startTest();
        try{
            insert precioTest1;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Test BI 4.2: Crear un registro que el inicio y el fin estén dentro de otro registro (Error)
    @isTest
    public static void ErrorListaFechaCompletaRegistro()
    {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 3);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 3);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 6);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 7);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);
        
        Test.startTest();
        try{
            insert listaPrecio;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Test BI 5: Crear un registro que inicio y el fin ocupe por completo uno o mas registros (Error)
    
    @isTest
    public static void ErrorFechaRegistroOcupado()
    {
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2022, 12, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2022, 12, 5);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        Test.startTest();
        try{
            insert precioTest1;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Test BI 5.2: Crear una lista de registros que inicio y el fin ocupe por completo uno o mas registros (Error)

    @isTest
    public static void ErrorListaFechaRegistroOcupado()
    {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 5);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 6);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 7);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);
        
        Test.startTest();
        try{
            insert listaPrecio;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    
    //Test BI 6: Crear un registro que la fecha fin esté en medio de un registro sin fecha fin determinada (Error)

    @isTest
    public static void ErrorRegistroFechaSinFin()
    {
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2022, 12, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2022, 12, 3);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;

        Test.startTest();
            try{
            insert precioTest1;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BI 6.2: Crear una lista de registros que la fecha fin esté en medio de un registro sin fecha fin determinada (Error)

    @isTest
    public static void ErrorListaRegistroFechaSinFin()
    {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 3);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 4);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2022, 12, 6);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2022, 12, 7);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);

        Test.startTest();
            try{
            insert listaPrecio;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BI 7 Crear un registro sin fecha fin que tenga delante suya un registro (Error)

    @isTest
    public static void ErrorFechaSinFinRegistro()
    {
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 30);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;

        Test.startTest();
            try{
            insert precioTest1;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

     //Test BI 7.2 Crear una  lista de registros sin fecha fin que tenga delante suya un registro (Error)

    @isTest
    public static void ErrorListaFechaSinFinRegistro()
    {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 5);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 6);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 7);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);

        Test.startTest();
            try{
            insert listaPrecio;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }


    //Test BU 1: Actualizar una fecha fin que no ocupe otro registro (Correcto)
    
    @isTest
    public static void actualizarRegistro()
    {
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 5);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 6);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;

        insert precioTest1;
        
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 7);
        
        Test.startTest();
            update precioTest1;
        Test.stopTest();

        List<CBK_Precio_Facturacion__c> precioResultado = [SELECT Name, CC_Fecha_Inicio_Vigencia__c, CC_Fecha_Fin_Vigencia__c FROM CBK_Precio_Facturacion__c WHERE CC_Fecha_Fin_Vigencia__c = 2021-12-07 ];
        System.assertEquals(1, precioResultado.size(), 'No existe un registro con fechas similares');
        System.assertEquals(Date.newInstance(2021, 12, 5), precioResultado[0].CC_Fecha_Inicio_Vigencia__c, 'Se ha actualizado el registro con fecha de inicio 2021-12-05');
        System.assertEquals(Date.newInstance(2021, 12, 7), precioResultado[0].CC_Fecha_Fin_Vigencia__c, 'Se ha actualizado el registro con fecha de fin 2021-12-07');
    }
    
    //Test BU 1.2: Actualizar una lista fecha fin que no ocupe otro registro (Correcto)
    
    @isTest
    public static void listaActualizarRegistro()
    {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 11, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 11, 10);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 11, 17);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 11, 18);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);
        insert listaPrecio;
        
        listaPrecio.get(0).CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 11, 11);
        listaPrecio.get(1).CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 11, 19);
        
        Test.startTest();
      
            update listaPrecio;
        
        Test.stopTest();

        List<CBK_Precio_Facturacion__c> precioResultado = [SELECT Name, CC_Fecha_Inicio_Vigencia__c, CC_Fecha_Fin_Vigencia__c FROM CBK_Precio_Facturacion__c WHERE 
        CC_Fecha_Fin_Vigencia__c = 2021-11-11 
        OR CC_Fecha_Fin_Vigencia__c =2021-11-19  ORDER BY CC_Fecha_Inicio_Vigencia__c];
        System.assertEquals(2, precioResultado.size(), 'No existen registros con fechas similares');
        System.assertEquals(Date.newInstance(2021, 11, 1), precioResultado[0].CC_Fecha_Inicio_Vigencia__c, 'Se ha creado el registro con fecha de inicio 2021-12-05');
        System.assertEquals(Date.newInstance(2021, 11, 11), precioResultado[0].CC_Fecha_Fin_Vigencia__c, 'Se ha creado el registro con fecha de fin 2021-12-06');
        System.assertEquals(Date.newInstance(2021, 11, 17), precioResultado[1].CC_Fecha_Inicio_Vigencia__c, 'Se ha creado el registro con fecha de inicio 2021-11-17');
        System.assertEquals(Date.newInstance(2021, 11, 19), precioResultado[1].CC_Fecha_Fin_Vigencia__c, 'Se ha creado el registro con fecha de fin 2021-11-19');
    }
    
    //Test BU 2: Actualizar una fecha fin que ocupe otro registro (Error)
    @isTest
    public static void ErrorActualizarFechaFinRegistro()
    {
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;

        insert precioTest1;
        
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 3);
        
        
        Test.startTest();
        try{
            update precioTest1;
            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Test BU 2.2: Actualizar una lista fecha fin que ocupe otro registro (Error)
     @isTest
     public static void ErrorListaActualizarFechaFinRegistro()
     {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 11, 17);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 11, 18);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);
        insert listaPrecio;
         
         
         listaPrecio.get(0).CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 3);
         
         Test.startTest();
         try{
             update listaPrecio;
             
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
        
        //Test BU 3: Actualizar una fecha fin a fecha fin sin limite que hayan registros por delante (Error)
        
        @isTest
        public static void actualizarFechaSinFinRegistroError()
        {
            CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
            precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
            precioTest1.CC_Nombre_Empresa__c = 'MST';
            precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
            precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 1);
            precioTest1.CC_Area_Negocio__c = 'WIVAI';
            precioTest1.CC_Canal_Entrada__c = 'Backoffice';
            precioTest1.CC_Precio_Contacto__c = 1.25;

            insert precioTest1;
                
            precioTest1.CC_Fecha_Fin_Vigencia__c = null;
            
            Test.startTest();
            try{
                update precioTest1;
                
            }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
            Test.stopTest();
        }
        
        //Test BU 3.2: Actualizar una lista fecha fin a fecha fin sin limite que hayan registros por delante (Error)
        
        @isTest
        public static void listaActualizarFechaSinFinRegistroError()
        {
            List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

            CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
            precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
            precioTest1.CC_Nombre_Empresa__c = 'MST';
            precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
            precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 1);
            precioTest1.CC_Area_Negocio__c = 'WIVAI';
            precioTest1.CC_Canal_Entrada__c = 'Backoffice';
            precioTest1.CC_Precio_Contacto__c = 1.25;
            
            CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
            precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
            precioTest2.CC_Nombre_Empresa__c = 'MST';
            precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 11, 17);
            precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 11, 18);
            precioTest2.CC_Area_Negocio__c = 'WIVAI';
            precioTest2.CC_Canal_Entrada__c = 'Backoffice';
            precioTest2.CC_Precio_Contacto__c = 1.25;
            
            listaPrecio.add(precioTest1);
            listaPrecio.add(precioTest2);
            insert listaPrecio;
                
                listaPrecio.get(1).CC_Fecha_Fin_Vigencia__c = null;
                
            Test.startTest();
                try{
                    update listaPrecio;
                    
                }catch(Exception e){
                    Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
                    System.AssertEquals(expectedExceptionThrown, true);
                }
            Test.stopTest();
        }
        
        //Test BU 4: Actuarlizar una fecha fin que ocupe un registro sin fecha fin limitada (Error)
    @isTest
    public static void ErrorActualizarFechaSinFinRegistroSinFin()
    {
        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
            precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
            precioTest1.CC_Nombre_Empresa__c = 'MST';
            precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
            precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 1);
            precioTest1.CC_Area_Negocio__c = 'WIVAI';
            precioTest1.CC_Canal_Entrada__c = 'Backoffice';
            precioTest1.CC_Precio_Contacto__c = 1.25;

            insert precioTest1;
        
        precioTest1.CC_Fecha_Fin_Vigencia__c = null;
        
        Test.startTest();
        try{
            update precioTest1;
            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Test BU 4.2: Actuarlizar una fecha fin que ocupe un registro sin fecha fin limitada (Error)
    @isTest
    public static void ErrorListaActualizarFechaSinFinRegistroSinFin()
    {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 11, 17);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 11, 18);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);
        insert listaPrecio;
        
        listaPrecio.get(0).CC_Fecha_Fin_Vigencia__c = null;
        
        Test.startTest();
        try{
            update listaPrecio;
            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    //Test BU 5: Actualizar simultáneamente dos registros a fecha fin ilimitada teniendo registros delante  (Error)
    @isTest
    public static void actualizarMultipleFecha()
    {
        List<CBK_Precio_Facturacion__c> listaPrecio = new List<CBK_Precio_Facturacion__c>();

        CBK_Precio_Facturacion__c precioTest1 = new CBK_Precio_Facturacion__c();
        precioTest1.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest1.CC_Nombre_Empresa__c = 'MST';
        precioTest1.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 12, 1);
        precioTest1.CC_Area_Negocio__c = 'WIVAI';
        precioTest1.CC_Canal_Entrada__c = 'Backoffice';
        precioTest1.CC_Precio_Contacto__c = 1.25;
        
        CBK_Precio_Facturacion__c precioTest2 = new CBK_Precio_Facturacion__c();
        precioTest2.RecordTypeId = Schema.SObjectType.CBK_Precio_Facturacion__c.getRecordTypeInfosByDeveloperName().get('CC_PrecioFacturacion').getRecordTypeId();
        precioTest2.CC_Nombre_Empresa__c = 'MST';
        precioTest2.CC_Fecha_Inicio_Vigencia__c = Date.newInstance(2021, 11, 17);
        precioTest2.CC_Fecha_Fin_Vigencia__c = Date.newInstance(2021, 11, 18);
        precioTest2.CC_Area_Negocio__c = 'WIVAI';
        precioTest2.CC_Canal_Entrada__c = 'Backoffice';
        precioTest2.CC_Precio_Contacto__c = 1.25;
        
        listaPrecio.add(precioTest1);
        listaPrecio.add(precioTest2);
        insert listaPrecio;
    
        listaPrecio.get(0).CC_Fecha_Fin_Vigencia__c = null;
        listaPrecio.get(1).CC_Fecha_Fin_Vigencia__c = null;
    
        Test.startTest();
        try{
            update listaPrecio;
            
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
   

}