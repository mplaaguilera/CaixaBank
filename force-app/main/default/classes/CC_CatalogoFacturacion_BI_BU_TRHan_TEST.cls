/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 06-23-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06-23-2022   Adrian Mariscal   Initial Version
**/
@IsTest
public class CC_CatalogoFacturacion_BI_BU_TRHan_TEST {

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

        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();

        CBK_CatalogoFacturacion__c catalogo1 = new CBK_CatalogoFacturacion__c();
        catalogo1.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo1.CC_Negocio__c = 'CC';
        catalogo1.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo1.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 5);
        catalogo1.CC_Area_Negocio__c ='WIVAI';

        //catalogo1.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo1.CC_Precio_Unitario__c = 11;
        catalogo1.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo1.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo1.CC_Tipo_Cliente__c = mccTematica.CC_Tipo_Cliente__c;
        catalogo1.CC_Tematica__c = mccTematica.id;
        catalogo1.CC_Producto__c = mccProducto.id;
        listaCatalogo.add(catalogo1);

        //insert catalogo1;

        
        CBK_CatalogoFacturacion__c catalogo3 = new CBK_CatalogoFacturacion__c();
        catalogo3.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo3.CC_Negocio__c = 'CC';
        catalogo3.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2022, 1, 1);
        catalogo3.CC_Area_Negocio__c ='WIVAI';

        //catalogo3.CC_Grupo_Facturacion__c = 'MST';
        //catalogo3.CC_Precio_Unitario__c = 11;
        catalogo3.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo3.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo3.CC_Tipo_Cliente__c = mccTematica.CC_Tipo_Cliente__c;
        catalogo3.CC_Tematica__c = mccTematica.id;
        catalogo3.CC_Producto__c = mccProducto.id;
        listaCatalogo.add(catalogo3);

        insert listaCatalogo;


    }
    /*
    @IsTest
    static void pruebaCarga(){
        CC_MCC__c apps = new CC_MCC__c();
        apps.Name = 'Apps';
        apps.CC_Tipo_Cliente__c = 'Empleado';
        apps.CC_Fecha_Vigencia_Inicio__c = Date.today();
        apps.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        apps.CC_Codigo_Externo__c = 'TE-000001';
        insert apps;
        CC_MCC__c imaginBank = new CC_MCC__c();
        imaginBank.Name = 'Imagin Bank';
        imaginBank.CC_Tipo_Cliente__c = 'Empleado';
        imaginBank.CC_Fecha_Vigencia_Inicio__c = Date.today();
        imaginBank.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        imaginBank.CC_Codigo_Externo__c = 'TE-000002';
        insert imaginBank;
        CC_MCC__c testImaginBank = new CC_MCC__c();
        testImaginBank.Name = 'Test Imagin Bank';
        testImaginBank.CC_Tipo_Cliente__c = 'Empleado';
        testImaginBank.CC_Fecha_Vigencia_Inicio__c = Date.today();
        testImaginBank.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        testImaginBank.CC_Codigo_Externo__c = 'TE-000003';
        insert testImaginBank;

        CC_MCC__c brokerNow = new CC_MCC__c();
        brokerNow.Name = 'Broker Now';
        brokerNow.CC_Tipo_Cliente__c = 'Empleado';
        brokerNow.CC_Fecha_Vigencia_Inicio__c = Date.today();
        brokerNow.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        brokerNow.CC_Tematica__c = apps.Id;
        brokerNow.CC_Codigo_Externo__c = 'PR-000001';
        insert brokerNow;
        CC_MCC__c caixaBank = new CC_MCC__c();
        caixaBank.Name = 'Caixa Bank';
        caixaBank.CC_Tipo_Cliente__c = 'Empleado';
        caixaBank.CC_Fecha_Vigencia_Inicio__c = Date.today();
        caixaBank.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        caixaBank.CC_Tematica__c = apps.Id;
        caixaBank.CC_Codigo_Externo__c = 'PR-000002';
        insert caixaBank;
        CC_MCC__c migracion = new CC_MCC__c();
        migracion.Name = 'Migracion';
        migracion.CC_Tipo_Cliente__c = 'Empleado';
        migracion.CC_Fecha_Vigencia_Inicio__c = Date.today();
        migracion.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        migracion.CC_Tematica__c = imaginBank.Id;
        migracion.CC_Codigo_Externo__c = 'PR-000003';
        insert migracion;
        CC_MCC__c otrasApps = new CC_MCC__c();
        otrasApps.Name = 'Otras Apps';
        otrasApps.CC_Tipo_Cliente__c = 'Empleado';
        otrasApps.CC_Fecha_Vigencia_Inicio__c = Date.today();
        otrasApps.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        otrasApps.CC_Tematica__c = apps.Id;
        otrasApps.CC_Codigo_Externo__c = 'PR-000004';
        insert otrasApps;
        CC_MCC__c samsungPay = new CC_MCC__c();
        samsungPay.Name = 'Otras Apps';
        samsungPay.CC_Tipo_Cliente__c = 'Empleado';
        samsungPay.CC_Fecha_Vigencia_Inicio__c = Date.today();
        samsungPay.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        samsungPay.CC_Tematica__c = apps.Id;
        samsungPay.CC_Codigo_Externo__c = 'PR-000005';
        insert samsungPay;

        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        //SI
        CBK_CatalogoFacturacion__c catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = null;
        catalogo.CC_Canal_Operativo__c = null;
        catalogo.CC_Tematica__c = apps.id;
        catalogo.CC_Producto__c = brokerNow.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //NO
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = null;
        catalogo.CC_Canal_Operativo__c = null;
        catalogo.CC_Tematica__c = apps.id;
        catalogo.CC_Producto__c = brokerNow.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //SI
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = null;
        catalogo.CC_Canal_Operativo__c = null;
        catalogo.CC_Tematica__c = apps.id;
        catalogo.CC_Producto__c = caixaBank.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //si
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = null;
        catalogo.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo.CC_Tematica__c = imaginBank.id;
        catalogo.CC_Producto__c = migracion.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //NO
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = null;
        catalogo.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo.CC_Tematica__c = imaginBank.id;
        catalogo.CC_Producto__c = migracion.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //SI

        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = null;
        catalogo.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo.CC_Tematica__c = imaginBank.id;
        catalogo.CC_Producto__c = testImaginBank.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //SI
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo.CC_Canal_Operativo__c = null;
        catalogo.CC_Tematica__c = apps.id;
        catalogo.CC_Producto__c = brokerNow.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //NO
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo.CC_Canal_Operativo__c = null;
        catalogo.CC_Tematica__c = apps.id;
        catalogo.CC_Producto__c = brokerNow.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //SI
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo.CC_Canal_Operativo__c = null;
        catalogo.CC_Tematica__c = apps.id;
        catalogo.CC_Producto__c = caixaBank.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //SI
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo.CC_Tematica__c = apps.id;
        catalogo.CC_Producto__c = otrasApps.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //NO
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo.CC_Tematica__c = apps.id;
        catalogo.CC_Producto__c = otrasApps.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);
        //SI
        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo.CC_Tematica__c = apps.id;
        catalogo.CC_Producto__c = samsungPay.id;
        catalogo.CC_Area_Negocio__c ='COPS';
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 05, 01);
        listaCatalogo.add(catalogo);        
        
        Database.insert(listaCatalogo,false);
        List<CBK_CatalogoFacturacion__c> lista = [select id, CC_Canal_Operativo__c FROM CBK_CatalogoFacturacion__c];
        System.assertEquals(7, lista.size());
        for (Integer i = 0; i < lista.size(); i++) {
            System.debug('Id nº '+i+':'+ lista[i].CC_Canal_Operativo__c);
            
        }
        Database.insert(listaCatalogo,false);
        lista = [select id, CC_Canal_Operativo__c FROM CBK_CatalogoFacturacion__c];
        for (Integer i = 0; i < lista.size(); i++) {
            System.debug('Id nº '+i+':'+ lista[i].CC_Canal_Operativo__c);
            
        }
        System.assertEquals(7, lista.size());
    }

*/
    //Se van a testear las clases

    //Test BI 1: Creacion sin problemas de un registro delante de otro ya creado (Correcto)

    @isTest
    public static void fechasSinErrorTest()
    {

        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 2);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        Test.startTest();
            try{
            insert catalogo2;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
			System.AssertEquals(expectedExceptionThrown, false);
            }
        Test.stopTest();
    }

    //Test BI 1.2: Creacion sin problemas de lista de registros delante y detras de otro ya creado (Correcto)
    @isTest
    public static void listasFechasSinErrorTest()
    {
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();

        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 2);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 6);
        catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 7);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);

        Test.startTest();
            try{
            insert listaCatalogo;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
			System.AssertEquals(expectedExceptionThrown, false);
            }
        Test.stopTest();
    }

    //Test BI 2: Crear un registro con la fecha inicial en medio de otro registro (Error)
    @isTest
    public static void fechaInicioError()
    {

        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 6);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        Test.startTest();
            try{
            insert catalogo2;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BI 2.2: Crear lista de registros con la fecha inicial en medio de otro registro (Error)
    @isTest
    public static void listaFechaInicioError()
    {

        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();

        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 6);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 6);
        catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 7);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);

        Test.startTest();
            try{
            insert listaCatalogo;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }
    //Test BI 3: Crear un registro con la fecha fin en medio de otro registro (Error)
    @isTest
    public static void fechaFinError()
    {
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 4);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        Test.startTest();
            try{
            insert catalogo2;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BI 3.2: Crear una lista de registros con la fecha fin en medio de otro registro (Error)
    @isTest
    public static void listaFechaFinError()
        {
            List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
            CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
            catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
            catalogo2.CC_Negocio__c = 'CC';
            catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 6);
            catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 7);
            catalogo2.CC_Area_Negocio__c ='WIVAI';

            //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
            //catalogo2.CC_Precio_Unitario__c = 11;
            catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
            catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
            catalogo2.CC_Tipo_Cliente__c='Empleado';
            catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
            catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

            //Registro erroneo
            CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
            catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
            catalogo4.CC_Negocio__c = 'CC';
            catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
            catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 4);
            catalogo4.CC_Area_Negocio__c ='WIVAI';

            //catalogo4.CC_Grupo_Facturacion__c = 'DXC';
            //catalogo4.CC_Precio_Unitario__c = 11;
            catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
            catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
            catalogo4.CC_Tipo_Cliente__c='Empleado';
            catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
            catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
    
            listaCatalogo.add(catalogo2);
            listaCatalogo.add(catalogo4);
    
            Test.startTest();
                try{
                insert catalogo2;
                }catch(Exception e){
                Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
                System.AssertEquals(expectedExceptionThrown, true);
                }
            Test.stopTest();
        }

    //Test BI 4: Crear un registro que el inicio y el fin estén dentro de otro registro (Error)
    @isTest
    public static void fechaRegistroError()
    {
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        Test.startTest();
            try{
            insert catalogo2;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BI 4.2: Crear un registro que el inicio y el fin estén dentro de otro registro (Error)
    @isTest
    public static void listaFechaRegistroError()
    {
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 2);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);

        Test.startTest();
            try{
            insert listaCatalogo;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BI 5: Crear un registro que que inicio y el fin ocupe por completro uno o mas registros (Error)

    @isTest
    public static void fechaRegistroOcupadoError()
    {
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 10);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        Test.startTest();
            try{
            insert catalogo2;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

     //Test BI 5.2: Crear una lista de registros que que inicio y el fin ocupe por completro uno o mas registros (Error)

     @isTest
     public static void listaFechaRegistroOcupadoError()
     {
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 10);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 1);
        catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 11, 2);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);

        Test.startTest();
            try{
            insert listaCatalogo;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
     }

    //Test BI 6: Crear un registro que la fecha fin esté en medio de un registro sin fecha fin determinada (Error)

    @isTest
    public static void fechaRegistroSinFinError()
    {
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'MST';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        Test.startTest();
            try{
            insert catalogo2;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BI 6.2: Crear una lista de registros que la fecha fin esté en medio de un registro sin fecha fin determinada (Error)

    @isTest
    public static void listaFechaRegistroSinFinError()
    {
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 3);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'MST';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 1);
        catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 11, 2);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'MST';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);

        Test.startTest();
            try{
            insert listaCatalogo;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BI 7 Crear un registro sin fecha fin que tenga delante suya un registro (Error)

    @isTest
    public static void fechaSinFinRegistroError()
    {
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        Test.startTest();
            try{
            insert catalogo2;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

     //Test BI 7.2 Crear una  lista de registros sin fecha fin que tenga delante suya un registro (Error)

    @isTest
    public static void listaFechaSinFinRegistroError()
    {
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 1);
        catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 11, 2);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'MST';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);

        Test.startTest();
            try{
            insert listaCatalogo;
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BI 8. Insertar el mismo registro exacto dos veces seguidas (Error)
    @isTest
    public static void listaInsertarRegistroIgualError()
    {

        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();

        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 5, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = '';
        catalogo2.CC_Canal_Operativo__c = '';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 5, 1);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = '';
        catalogo4.CC_Canal_Operativo__c = '';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);

        Test.startTest();
            try{
            insert listaCatalogo;
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
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 29);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        insert catalogo2;

        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 2);

        Test.startTest();
            try{
                update catalogo2;
            
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, false);
            }
        Test.stopTest();
    }

    //Test BU 1.2: Actualizar una lista fecha fin que no ocupe otro registro (Correcto)

    @isTest
    public static void listaActualizarRegistro()
    {
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 29);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        

        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 6);
        catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 7);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        
        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);
        insert listaCatalogo;

        listaCatalogo.get(0).CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 2);
        listaCatalogo.get(1).CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 8);

        Test.startTest();
            try{
                update listaCatalogo;
            
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, false);
            }
        Test.stopTest();
    }

    //Test BU 2: Actualizar una fecha fin que ocupe otro registro (Error)
    @isTest
    public static void actualizarFechaFinRegistroError()
    {
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 29);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'MST';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        insert catalogo2;

        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 6);

        Test.startTest();
            try{
                update catalogo2;
            
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

     //Test BU 2.2: Actualizar una lista fecha fin que ocupe otro registro (Error)
     @isTest
     public static void listaActualizarFechaFinRegistroError()
     {
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
         CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
         catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
         catalogo2.CC_Negocio__c = 'CC';
         catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 29);
         catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 1);
         catalogo2.CC_Area_Negocio__c ='WIVAI';

         //catalogo2.CC_Grupo_Facturacion__c = 'MST';
         //catalogo2.CC_Precio_Unitario__c = 11;
         catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
         catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
         catalogo2.CC_Tipo_Cliente__c='Empleado';
         catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
         catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;

         CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
         catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
         catalogo4.CC_Negocio__c = 'CC';
         catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 6);
         catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 11, 7);
         catalogo4.CC_Area_Negocio__c ='WIVAI';

         //catalogo4.CC_Grupo_Facturacion__c = 'MST';
         //catalogo4.CC_Precio_Unitario__c = 11;
         catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
         catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
         catalogo4.CC_Tipo_Cliente__c='Empleado';
         catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
         catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
         
         listaCatalogo.add(catalogo2);
         listaCatalogo.add(catalogo4);
         insert listaCatalogo;
 
 
         listaCatalogo.get(0).CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 6);
 
         Test.startTest();
             try{
                 update listaCatalogo;
             
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
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 29);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        insert catalogo2;

        catalogo2.CC_Fecha_Fin_Vigencia__c = null;

        Test.startTest();
            try{
                update catalogo2;
            
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
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 29);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'DXC';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        
        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
         catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
         catalogo4.CC_Negocio__c = 'CC';
         catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 6);
         catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 11, 7);
         catalogo4.CC_Area_Negocio__c ='WIVAI';

         //catalogo4.CC_Grupo_Facturacion__c = 'DXC';
         //catalogo4.CC_Precio_Unitario__c = 11;
         catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
         catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
         catalogo4.CC_Tipo_Cliente__c='Empleado';
         catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
         catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
         
         listaCatalogo.add(catalogo2);
         listaCatalogo.add(catalogo4);
         insert listaCatalogo;

        listaCatalogo.get(1).CC_Fecha_Fin_Vigencia__c = null;

        Test.startTest();
            try{
                update listaCatalogo;
            
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
     }

    //Test BU 4: Actuarlizar una fecha fin que ocupe un registro sin fecha fin limitada (Error)
    @isTest
    public static void actualizarFechaSinFinRegistroSinFinError()
    {
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 29);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'MST';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        insert catalogo2;

        catalogo2.CC_Fecha_Fin_Vigencia__c = null;

        Test.startTest();
            try{
                update catalogo2;
            
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

    //Test BU 4.2: Actuarlizar una fecha fin que ocupe un registro sin fecha fin limitada (Error)
    @isTest
    public static void listaActualizarFechaSinFinRegistroSinFinError()
    {
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 29);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'MST';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        
        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 11, 6);
        catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 11, 7);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'MST';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        
        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);
        insert listaCatalogo;

        listaCatalogo.get(0).CC_Fecha_Fin_Vigencia__c = null;

        Test.startTest();
            try{
                update listaCatalogo;
            
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }
    @isTest
    public static void listaActualizarMultipleFechaSinFinError()
    {
        List<CBK_CatalogoFacturacion__c> listaCatalogo = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo2 = new CBK_CatalogoFacturacion__c();
        catalogo2.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo2.CC_Negocio__c = 'CC';
        catalogo2.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 1);
        catalogo2.CC_Area_Negocio__c ='WIVAI';

        //catalogo2.CC_Grupo_Facturacion__c = 'MST';
        //catalogo2.CC_Precio_Unitario__c = 11;
        catalogo2.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo2.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo2.CC_Tipo_Cliente__c='Empleado';
        catalogo2.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo2.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        
        CBK_CatalogoFacturacion__c catalogo4 = new CBK_CatalogoFacturacion__c();
        catalogo4.RecordTypeId = Schema.SObjectType.CBK_CatalogoFacturacion__c.getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo4.CC_Negocio__c = 'CC';
        catalogo4.CC_Fecha_Inicio_Vigencia__c = Datetime.newInstance(2021, 12, 17);
        catalogo4.CC_Fecha_Fin_Vigencia__c = Datetime.newInstance(2021, 12, 18);
        catalogo4.CC_Area_Negocio__c ='WIVAI';

        //catalogo4.CC_Grupo_Facturacion__c = 'MST';
        //catalogo4.CC_Precio_Unitario__c = 11;
        catalogo4.CC_Canal_de_Procedencia__c = 'Accionista';
        catalogo4.CC_Canal_Operativo__c = 'App BrokerNow';
        catalogo4.CC_Tipo_Cliente__c='Empleado';
        catalogo4.CC_Tematica__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Tematica'].Id;
        catalogo4.CC_Producto__c = [SELECT Id FROM CC_MCC__c WHERE Name = 'MCC Producto'].Id;
        
        listaCatalogo.add(catalogo2);
        listaCatalogo.add(catalogo4);
        insert listaCatalogo;

        listaCatalogo.get(0).CC_Fecha_Fin_Vigencia__c = null;
        listaCatalogo.get(1).CC_Fecha_Fin_Vigencia__c = null;

        Test.startTest();
            try{
                update listaCatalogo;
            
            }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Ya existe un registro con fechas similares')?true:false;
            System.AssertEquals(expectedExceptionThrown, true);
            }
        Test.stopTest();
    }

}