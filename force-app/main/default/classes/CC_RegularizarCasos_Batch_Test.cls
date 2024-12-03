/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 12-23-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   10-25-2022   Adrian Mariscal   Initial Version
**/
@isTest
public with sharing class CC_RegularizarCasos_Batch_Test {
    @TestSetup
    static void makeData(){
        //TEMATICAS
        List<CC_MCC__c> listaTematicas = new List<CC_MCC__c>();
        CC_MCC__c mccTematica = new CC_MCC__c();
        mccTematica.Name = 'MCC Tematica 1';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Canal_Operativo__c = 'Cajero';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        listaTematicas.add(mccTematica);
        insert listaTematicas;

        //PRODUCTOS
        List<CC_MCC__c> listaProductos = new List<CC_MCC__c>();
        CC_MCC__c mccProducto = new CC_MCC__c();
        mccProducto.Name = 'MCC Producto 1';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccProducto.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.CC_Tematica__c = mccTematica.Id;
        mccProducto.CC_Codigo_Externo__c = 'PR-000001';
        listaProductos.add(mccProducto);
        insert listaProductos;

        //CATALOGOS
        List<CBK_CatalogoFacturacion__c> listaCatalogos = new List<CBK_CatalogoFacturacion__c>();
        CBK_CatalogoFacturacion__c catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.getGlobalDescribe().get('CBK_CatalogoFacturacion__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addDays(-10);
        catalogo.CC_Fecha_Fin_Vigencia__c = Datetime.now().addDays(5);
        catalogo.CC_Tematica__c = mccTematica.Id;
        catalogo.CC_Canal_de_Procedencia__c  = 'Bloqueos';
        catalogo.CC_Canal_Operativo__c = 'Cajero';
        catalogo.CC_Producto__c = mccProducto.Id;
        catalogo.CC_Area_Negocio__c = 'CAJEROS'; 
        catalogo.CC_Tipo_Cliente__c  = 'Cliente';
        listaCatalogos.add(catalogo);

        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.getGlobalDescribe().get('CBK_CatalogoFacturacion__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addDays(-10);
        catalogo.CC_Fecha_Fin_Vigencia__c = Datetime.now().addDays(5);
        catalogo.CC_Tematica__c = mccTematica.Id;
        catalogo.CC_Canal_de_Procedencia__c  = 'Bloqueos';
        catalogo.CC_Canal_Operativo__c = 'Portal CBK';
        catalogo.CC_Producto__c = mccProducto.Id;
        catalogo.CC_Area_Negocio__c = 'ATENCION AL CLIENTE'; 
        catalogo.CC_Tipo_Cliente__c  = 'Cliente';
        listaCatalogos.add(catalogo);

        catalogo = new CBK_CatalogoFacturacion__c();
        catalogo.RecordTypeId = Schema.getGlobalDescribe().get('CBK_CatalogoFacturacion__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CatalogoFacturacion').getRecordTypeId();
        catalogo.CC_Negocio__c = 'CC';
        catalogo.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addDays(-10);
        catalogo.CC_Fecha_Fin_Vigencia__c = Datetime.now().addDays(5);
        catalogo.CC_Tematica__c = mccTematica.Id;
        catalogo.CC_Canal_de_Procedencia__c  = 'Bloqueos';
        catalogo.CC_Canal_Operativo__c = 'Servicios Centrales';
        catalogo.CC_Producto__c = mccProducto.Id;
        catalogo.CC_Area_Negocio__c = 'ACCIONISTAS'; 
        catalogo.CC_Tipo_Cliente__c  = 'Cliente';
        listaCatalogos.add(catalogo);
        insert listaCatalogos;

        //PRECIOS
        List<CBK_Precio_Facturacion__c> listaPrecios = new List<CBK_Precio_Facturacion__c>();
        CBK_Precio_Facturacion__c precio = new CBK_Precio_Facturacion__c();
        precio.CC_Fecha_Inicio_Vigencia__c =  Date.today().addDays(-1);
        precio.CC_Fecha_Fin_Vigencia__c = Date.today().addDays(15);
        precio.CC_Canal_Entrada__c  = 'Phone';
        precio.CC_Precio_Contacto__c = 15.0;
        precio.CC_Nombre_Empresa__c = 'DXC';
        precio.CC_Area_Negocio__c = 'CAJEROS';
        listaPrecios.add(precio);

        precio = new CBK_Precio_Facturacion__c();
        precio.CC_Fecha_Inicio_Vigencia__c =  Date.today().addDays(-1);
        precio.CC_Fecha_Fin_Vigencia__c = Date.today().addDays(15);
        precio.CC_Canal_Entrada__c  = 'Phone';
        precio.CC_Precio_Contacto__c = 17.0;
        precio.CC_Nombre_Empresa__c = 'MST';
        precio.CC_Area_Negocio__c = 'CAJEROS';
        listaPrecios.add(precio);

        precio = new CBK_Precio_Facturacion__c();
        precio.CC_Fecha_Inicio_Vigencia__c =  Date.today().addDays(-1);
        precio.CC_Fecha_Fin_Vigencia__c = Date.today().addDays(15);
        precio.CC_Canal_Entrada__c  = 'Phone';
        precio.CC_Precio_Contacto__c = 13.0;
        precio.CC_Nombre_Empresa__c = 'DXC';
        precio.CC_Area_Negocio__c = 'ATENCION AL CLIENTE';
        listaPrecios.add(precio);
        insert listaPrecios;

        //MARGENES
        CBK_Margen_Facturacion__c margen = new CBK_Margen_Facturacion__c();
        margen.CC_Fecha_Inicio__c = Date.today().addDays(-1);
        margen.CC_Fecha_Fin__c = Date.today().addDays(10);
        margen.CC_Area_de_Negocio__c = 'CAJEROS';
        margen.CC_Margen__c = 2.0;
        insert margen;


        //Perfil
        ID perfilId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;

        //Usuarios
        List<User> listaUsuarios = new List<User>();
        User usuario = new User();
        usuario.FirstName = 'Agente';
        usuario.LastName = 'DXC';
        usuario.CompanyName = 'DXC';
        usuario.Username = 'agente.dxc@test.com';
        usuario.Email = 'agente.dxc@test.com';
        usuario.Alias = 'DXC';
        usuario.TimeZoneSidKey = 'Europe/Berlin';
        usuario.LocaleSidKey = 'es_ES';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.ProfileId = perfilId;
        listaUsuarios.add(usuario);

        usuario = new User();
        usuario.FirstName = 'Agente';
        usuario.LastName = 'MST';
        usuario.CompanyName = 'MST';
        usuario.Username = 'agente.mst@test.com';
        usuario.Email = 'agente.mst@test.com';
        usuario.Alias = 'MST';
        usuario.TimeZoneSidKey = 'Europe/Berlin';
        usuario.LocaleSidKey = 'es_ES';
        usuario.EmailEncodingKey = 'UTF-8';
        usuario.LanguageLocaleKey = 'es';
        usuario.ProfileId = perfilId;
        listaUsuarios.add(usuario);
        insert listaUsuarios;

        //Casos
        List<Case> casos = new List<Case>();
        Case caso1 = new Case(
            Subject = 'Caso 1',
            Status = 'Cerrado',
            OwnerId = listaUsuarios.get(0).Id,
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'Cajero',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id
        );
        casos.add(caso1);

        Case caso2 = new Case(
            Subject = 'Caso 2',
            Status = 'Cerrado',
            OwnerId = listaUsuarios.get(1).Id,
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'Cajero',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id
        );
        casos.add(caso2);
        
        Case caso3 = new Case(
            Subject = 'Caso 3',
            Status = 'Cerrado',
            OwnerId = listaUsuarios.get(0).Id,
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'Portal CBK',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id
        );
        casos.add(caso3);
        
        Case caso4 = new Case(
            Subject = 'Caso 4',
            Status = 'Cerrado',
            OwnerId = listaUsuarios.get(0).Id,
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'Servicios Centrales',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id
        );
        casos.add(caso4);

        Case caso5 = new Case(
            Subject = 'Caso 5',
            Status = 'Cerrado',
            OwnerId = listaUsuarios.get(0).Id,
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'App Imagin',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id
        );
        casos.add(caso5);

        Case caso6 = new Case(
            Subject = 'Caso 6',
            Status = 'Cerrado',
            OwnerId = listaUsuarios.get(0).Id,
            CC_Trasladado_Tercer_Nivel__c  = true,
            CC_Owner_Anterior__c = listaUsuarios.get(1).Id,
            recordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId(),
            Origin = 'Phone',
            CC_Canal_Procedencia__c = 'Bloqueos',
            CC_Canal_Operativo__c = 'Cajero',
            CC_MCC_Tematica__c = mccTematica.Id,
            CC_MCC_ProdServ__c = mccProducto.Id
        );
        casos.add(caso6);

        insert casos;

    }

    @IsTest
    static void methodName(){

        Test.startTest();
            CBK_BatchJob.executeBatch('CC_RegularizarCasos_Batch',0);        
        Test.stopTest();

        List<Case> casos = [SELECT Subject,CC_Catalogo_Facturacion__c,CC_Area_Negocio__c,CC_Precio_Facturacion__c,CC_Precio_Facturar__c,CC_Fecha_Facturacion__c,CC_Facturado__c,CC_Margen_Facturacion__c FROM Case];

        for(Case caso:casos){
            if(caso.Subject == 'Caso 1'){
                System.assertNotEquals(null, caso.CC_Catalogo_Facturacion__c);
                System.assertEquals('CAJEROS', caso.CC_Area_Negocio__c);
                System.assertNotEquals(null, caso.CC_Precio_Facturacion__c);
                System.assertEquals(15.0, caso.CC_Precio_Facturar__c);
                System.assertEquals(Date.today(), caso.CC_Fecha_Facturacion__c);
                System.assertEquals(true, caso.CC_Facturado__c);
                System.assertNotEquals(null, caso.CC_Margen_Facturacion__c);
            }else if(caso.Subject == 'Caso 2'){
                System.assertNotEquals(null, caso.CC_Catalogo_Facturacion__c);
                System.assertEquals('CAJEROS', caso.CC_Area_Negocio__c);
                System.assertNotEquals(null, caso.CC_Precio_Facturacion__c);
                System.assertEquals(17.0, caso.CC_Precio_Facturar__c);
                System.assertEquals(Date.today(), caso.CC_Fecha_Facturacion__c);
                System.assertEquals(true, caso.CC_Facturado__c);
                System.assertNotEquals(null, caso.CC_Margen_Facturacion__c);
            }else if(caso.Subject == 'Caso 3'){
                System.assertNotEquals(null, caso.CC_Catalogo_Facturacion__c);
                System.assertEquals('ATENCION AL CLIENTE', caso.CC_Area_Negocio__c);
                System.assertNotEquals(null, caso.CC_Precio_Facturacion__c);
                System.assertEquals(13.0, caso.CC_Precio_Facturar__c);
                System.assertEquals(Date.today(), caso.CC_Fecha_Facturacion__c);
                System.assertEquals(true, caso.CC_Facturado__c);
                System.assertEquals(null, caso.CC_Margen_Facturacion__c);
            }else if(caso.Subject == 'Caso 4'){
                System.assertNotEquals(null, caso.CC_Catalogo_Facturacion__c);
                System.assertEquals('ACCIONISTAS', caso.CC_Area_Negocio__c);
                System.assertEquals(null, caso.CC_Precio_Facturacion__c);
                System.assertEquals(null, caso.CC_Precio_Facturar__c);
                System.assertEquals(null, caso.CC_Fecha_Facturacion__c);
                System.assertEquals(false, caso.CC_Facturado__c);
                System.assertEquals(null, caso.CC_Margen_Facturacion__c);
            }
            else if(caso.Subject == 'Caso 5'){
                System.assertEquals(null, caso.CC_Catalogo_Facturacion__c);
                System.assertEquals(null, caso.CC_Area_Negocio__c);
                System.assertEquals(null, caso.CC_Precio_Facturacion__c);
                System.assertEquals(null, caso.CC_Precio_Facturar__c);
                System.assertEquals(null, caso.CC_Fecha_Facturacion__c);
                System.assertEquals(false, caso.CC_Facturado__c);
                System.assertEquals(null, caso.CC_Margen_Facturacion__c);
            }
            else if(caso.Subject == 'Caso 6'){
                System.assertNotEquals(null, caso.CC_Catalogo_Facturacion__c);
                System.assertEquals('CAJEROS', caso.CC_Area_Negocio__c);
                System.assertNotEquals(null, caso.CC_Precio_Facturacion__c);
                System.assertEquals(17.0, caso.CC_Precio_Facturar__c);
                System.assertEquals(Date.today(), caso.CC_Fecha_Facturacion__c);
                System.assertEquals(true, caso.CC_Facturado__c);
                System.assertNotEquals(null, caso.CC_Margen_Facturacion__c);
            }
        }
    }
}