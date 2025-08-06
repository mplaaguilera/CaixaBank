/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 11-15-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06-14-2022   Adrian Mariscal   Initial Version
**/
@isTest
public class CC_FacturarCasosCerrados_Batch_Test {
    @TestSetup
    static void makeData(){
        //TEMATICAS
        List<CC_MCC__c> listaTematicas = new List<CC_MCC__c>();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        listaTematicas.add(mccTematica);
        insert listaTematicas;

        //PRODUCTOS
        List<CC_MCC__c> listaProductos = new List<CC_MCC__c>();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'Cuenta corriente';
        mccProducto.CC_Tipo_Cliente__c = 'Empleado';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        listaProductos.add(mccProducto);
        insert listaProductos;

        //CATALOGOS
        CBK_CatalogoFacturacion__c catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.getGlobalDescribe().get('CBK_CatalogoFacturacion__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addDays(-10);
        catalogo.CC_Fecha_Fin_Vigencia__c = Datetime.now().addDays(5);
        catalogo.CC_Tematica__c = mccTematica.Id;
        catalogo.CC_Canal_de_Procedencia__c  = 'Bloqueos';
        catalogo.CC_Canal_Operativo__c = 'Cajero';
        catalogo.CC_Producto__c = mccProducto.Id;
        catalogo.CC_Area_Negocio__c = 'Cajeros'; 
        catalogo.CC_Tipo_Cliente__c  = 'Empleado';
        insert catalogo;

        //PRECIOS
        CBK_Precio_Facturacion__c precio = new CBK_Precio_Facturacion__c();
        precio.CC_Fecha_Inicio_Vigencia__c =  Date.today().addDays(-1);
        precio.CC_Fecha_Fin_Vigencia__c = Date.today().addDays(15);
        precio.CC_Canal_Entrada__c  = 'Phone';
        precio.CC_Precio_Contacto__c = 15.0;
        precio.CC_Nombre_Empresa__c = 'DXC';
        precio.CC_Area_Negocio__c = 'Cajeros';
        insert precio;

        //MARGENES
        CBK_Margen_Facturacion__c margen = new CBK_Margen_Facturacion__c();
        margen.CC_Fecha_Inicio__c = Date.today().addDays(-1);
        margen.CC_Fecha_Fin__c = Date.today().addDays(10);
        margen.CC_Margen__c = 2.0;
        insert margen;

        //Casos
        List<Case> casos = new List<Case>();
        Case caso1 = new Case(
            Subject = 'Caso 1',
            Status = 'Cerrado',
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'Cajero',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id,
            CC_Area_Negocio__c = 'Cajeros',
            CC_Catalogo_Facturacion__c =  catalogo.Id,
            CC_Precio_Facturacion__c = precio.Id,
            CC_Precio_Facturar__c = 15.0
        );
        casos.add(caso1);

        Case caso2 = new Case(
            Subject = 'Caso 2',
            Status = 'Cerrado',
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'Cajero',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id,
            CC_Area_Negocio__c = 'Cajeros',
            CC_Catalogo_Facturacion__c =  catalogo.Id,
            CC_Precio_Facturacion__c = precio.Id,
            CC_Precio_Facturar__c = 15.0
        );
        casos.add(caso2);
        
        Case caso3 = new Case(
            Subject = 'Caso 3',
            Status = 'Cerrado',
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'Cajero',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id,
            CC_Area_Negocio__c = 'Cajeros',
            CC_Catalogo_Facturacion__c =  catalogo.Id,
            CC_Precio_Facturacion__c = precio.Id,
            CC_Precio_Facturar__c = 15.0,
            CC_Margen_Facturacion__c = margen.Id
        );
        casos.add(caso3);
        
        Case caso4 = new Case(
            Subject = 'Caso 4',
            Status = 'Cerrado',
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'Cajero',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id,
            CC_Area_Negocio__c = 'Cajeros'
        );
        casos.add(caso4);

        insert casos;

    }

    @IsTest
    static void methodName(){

       List<Case> casos = [SELECT Id,CC_Catalogo_Facturacion__c,CC_Facturado__c, Status,CC_Precio_Facturar__c FROM Case];
        Test.startTest();
            CBK_BatchJob.executeBatch('CC_FacturarCasosCerrados_Batch',0);        
        Test.stopTest();

        List<Case> casosActualizados = [SELECT Id,CC_Catalogo_Facturacion__c,CC_Facturado__c FROM Case];

        for(Case c:casosActualizados){
            if(c.CC_Catalogo_Facturacion__c != null){
                System.assertEquals(true, c.CC_Facturado__c);
            }else{
                System.assertEquals(false, c.CC_Facturado__c);
            }
        }
    }
}