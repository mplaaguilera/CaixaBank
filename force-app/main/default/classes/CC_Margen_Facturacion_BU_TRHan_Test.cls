/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 07-04-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   07-01-2022   Adrian Mariscal   Initial Version
**/
@isTest
public with sharing class CC_Margen_Facturacion_BU_TRHan_Test {
    /*@TestSetup
    static void makeData(){

        CC_MCC__c tematica = new CC_MCC__c();
        tematica.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        tematica.Name = 'App\'s';
        tematica.CC_Tipo_Cliente__c = 'Cliente';
        tematica.CC_Codigo_Externo__c = 'TE-000001';
        tematica.CC_Canal_Operativo__c = 'Oficina';
        insert tematica;

        CC_MCC__c productoServicio = new CC_MCC__c();
        productoServicio.RecordTypeId = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        productoServicio.Name = 'APP CaixaBank';
        productoServicio.CC_Detalle__c = 'CaixaBank';
        productoServicio.CC_Tipo_Cliente__c = 'Cliente';
        productoServicio.CC_Tematica__c = tematica.Id;
        productoServicio.CC_Codigo_Externo__c = 'PR-000001';
        insert productoServicio;
        
        CBK_CatalogoFacturacion__c cf = new CBK_CatalogoFacturacion__c();
        cf.CC_Fecha_Inicio_Vigencia__c = Datetime.now().addDays(-30);
        cf.CC_Fecha_Fin_Vigencia__c  = Datetime.now().addDays(30);
        cf.CC_Tematica__c = tematica.Id;
        cf.CC_Producto__c = productoServicio.Id;
        cf.CC_Canal_de_Procedencia__c = 'App';
        cf.CC_Canal_Operativo__c = 'Oficina';
        cf.CC_Negocio__c = 'CC';
        cf.CC_Area_Negocio__c ='Cajeros';
        cf.CC_Tipo_Cliente__c  = 'Cliente';
        insert cf;

        CBK_Margen_Facturacion__c mf = new CBK_Margen_Facturacion__c();
        //mf.CC_Catalogo_Facturacion__c = cf.Id;
        mf.CC_Fecha_Inicio__c = Date.today().addDays(-3);
        mf.CC_Fecha_Fin__c = Date.today().addDays(3);
        mf.CC_Margen__c = 23.0;
        insert mf;
    }

    @isTest
    public static void todosCorrectos(){
        CBK_CatalogoFacturacion__c cf = [SELECT Id FROM CBK_CatalogoFacturacion__c LIMIT 1];

        List<CBK_Margen_Facturacion__c> mfList = new List<CBK_Margen_Facturacion__c>();
        CBK_Margen_Facturacion__c mf1 = new CBK_Margen_Facturacion__c();
        //mf1.CC_Catalogo_Facturacion__c = cf.Id;
        mf1.CC_Fecha_Inicio__c = Date.today().addDays(-10);
        mf1.CC_Fecha_Fin__c = Date.today().addDays(-4);
        mf1.CC_Margen__c = 23.0;
        mfList.add(mf1);

        CBK_Margen_Facturacion__c mf2 = new CBK_Margen_Facturacion__c();
        //mf2.CC_Catalogo_Facturacion__c = cf.Id;
        mf2.CC_Fecha_Inicio__c = Date.today().addDays(4);
        mf2.CC_Margen__c = 23.0;
        mfList.add(mf2);
        Database.insert(mfList, false);

        Test.startTest();
            mfList = new List<CBK_Margen_Facturacion__c>();
            mf1.CC_Fecha_Fin__c = Date.today().addDays(-5);
            mfList.add(mf1);
            mf2.CC_Fecha_Fin__c = Date.today().addDays(10);
            mfList.add(mf2);
            Database.update(mfList, false);
        Test.stopTest();

        CBK_Margen_Facturacion__c mf = [SELECT Id,CC_Fecha_Fin__c FROM CBK_Margen_Facturacion__c where id = :mf1.Id];
        System.assertEquals(Date.today().addDays(-5), mf.CC_Fecha_Fin__c);
        mf = [SELECT Id,CC_Fecha_Fin__c FROM CBK_Margen_Facturacion__c where id = :mf2.Id];
        System.assertEquals(Date.today().addDays(10), mf.CC_Fecha_Fin__c);             
    }

    @isTest
    public static void todosIncorrectos(){
        CBK_CatalogoFacturacion__c cf = [SELECT Id FROM CBK_CatalogoFacturacion__c LIMIT 1];

        List<CBK_Margen_Facturacion__c> mfList = new List<CBK_Margen_Facturacion__c>();
        
        CBK_Margen_Facturacion__c mf1 = new CBK_Margen_Facturacion__c();
        //mf1.CC_Catalogo_Facturacion__c = cf.Id;
        mf1.CC_Fecha_Inicio__c = Date.today().addDays(-10);
        mf1.CC_Fecha_Fin__c = Date.today().addDays(-4);
        mf1.CC_Margen__c = 23.0;
        mfList.add(mf1);

        CBK_Margen_Facturacion__c mf2 = new CBK_Margen_Facturacion__c();
        //mf2.CC_Catalogo_Facturacion__c = cf.Id;
        mf2.CC_Fecha_Inicio__c = Date.today().addDays(4);
        mf2.CC_Fecha_Fin__c = Date.today().addDays(10);
        mf2.CC_Margen__c = 23.0;
        mfList.add(mf2);

        Database.insert(mfList, false);

        Test.startTest();
            mfList = new List<CBK_Margen_Facturacion__c>();
            mf1.CC_Fecha_Fin__c = Date.today().addDays(-3);
            mfList.add(mf1);
            mf2.CC_Fecha_Fin__c = Date.today().addDays(3);
            mfList.add(mf2);
        Database.update(mfList, false);
        Test.stopTest();

        CBK_Margen_Facturacion__c mf = [SELECT Id,CC_Fecha_Fin__c FROM CBK_Margen_Facturacion__c where id = :mf1.Id];
        System.assertEquals(Date.today().addDays(-4), mf.CC_Fecha_Fin__c);
        mf = [SELECT Id,CC_Fecha_Fin__c FROM CBK_Margen_Facturacion__c where id = :mf2.Id];
        System.assertEquals(Date.today().addDays(10), mf.CC_Fecha_Fin__c);        
    }

    @isTest
    public static void correctosEincorrecto(){
        CBK_CatalogoFacturacion__c cf = [SELECT Id FROM CBK_CatalogoFacturacion__c LIMIT 1];

        Test.startTest();
        List<CBK_Margen_Facturacion__c> mfList = new List<CBK_Margen_Facturacion__c>();
        
        CBK_Margen_Facturacion__c mf = new CBK_Margen_Facturacion__c();
        //mf.CC_Catalogo_Facturacion__c = cf.Id;
        mf.CC_Fecha_Inicio__c = Date.today().addDays(-10);
        mf.CC_Fecha_Fin__c = Date.today().addDays(-4);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        mf = new CBK_Margen_Facturacion__c();
        //mf.CC_Catalogo_Facturacion__c = cf.Id;
        mf.CC_Fecha_Inicio__c = Date.today().addDays(-2);
        mf.CC_Fecha_Fin__c = Date.today().addDays(2);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        mf = new CBK_Margen_Facturacion__c();
        //mf.CC_Catalogo_Facturacion__c = cf.Id;
        mf.CC_Fecha_Inicio__c = Date.today().addDays(4);
        mf.CC_Fecha_Fin__c = Date.today().addDays(10);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        Database.insert(mfList, false);

        Test.stopTest();

        List<CBK_Margen_Facturacion__c> registros = [SELECT Id FROM CBK_Margen_Facturacion__c];
        System.assertEquals(3, registros.size());        
    }

    @isTest
    public static void sinFechaFin(){
        CBK_CatalogoFacturacion__c cf = [SELECT Id FROM CBK_CatalogoFacturacion__c LIMIT 1];

        Test.startTest();
        List<CBK_Margen_Facturacion__c> mfList = new List<CBK_Margen_Facturacion__c>();
        
        CBK_Margen_Facturacion__c mf = new CBK_Margen_Facturacion__c();
        //mf.CC_Catalogo_Facturacion__c = cf.Id;
        mf.CC_Fecha_Inicio__c = Date.today().addDays(4);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        mf = new CBK_Margen_Facturacion__c();
        //mf.CC_Catalogo_Facturacion__c = cf.Id;
        mf.CC_Fecha_Inicio__c = Date.today().addDays(10);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        Database.insert(mfList, false);

        Test.stopTest();

        List<CBK_Margen_Facturacion__c> registros = [SELECT Id FROM CBK_Margen_Facturacion__c];
        System.assertEquals(3, registros.size());

    }*/
}