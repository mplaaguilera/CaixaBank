/**
 * @description       : 
 * @author            : Adrian Mariscal
 * @group             : 
 * @last modified on  : 11-21-2022
 * @last modified by  : Adrian Mariscal
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06-08-2022   Adrian Mariscal   Initial Version
**/
@isTest
public with sharing class CC_Margen_Facturacion_BI_TRHan_Test {

    @TestSetup
    static void makeData(){

        CBK_Margen_Facturacion__c mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(-3);
        mf.CC_Fecha_Fin__c = Date.today().addDays(3);
        mf.CC_Margen__c = 23.0;
        insert mf;
    }

    @isTest
    public static void todosCorrectos(){
        Test.startTest();
        List<CBK_Margen_Facturacion__c> mfList = new List<CBK_Margen_Facturacion__c>();
        
        CBK_Margen_Facturacion__c mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(-10);
        mf.CC_Fecha_Fin__c = Date.today().addDays(-4);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(4);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        Database.insert(mfList, false);

        Test.stopTest();

        List<CBK_Margen_Facturacion__c> registros = [SELECT Id FROM CBK_Margen_Facturacion__c];
        System.assertEquals(3, registros.size());        
    }

    @isTest
    public static void todosIncorrectos(){
        Test.startTest();
        List<CBK_Margen_Facturacion__c> mfList = new List<CBK_Margen_Facturacion__c>();
        
        CBK_Margen_Facturacion__c mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(-10);
        mf.CC_Fecha_Fin__c = Date.today().addDays(-3);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(-2);
        mf.CC_Fecha_Fin__c = Date.today().addDays(2);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(3);
        mf.CC_Fecha_Fin__c = Date.today().addDays(10);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        Database.insert(mfList, false);

        Test.stopTest();

        List<CBK_Margen_Facturacion__c> registros = [SELECT Id FROM CBK_Margen_Facturacion__c];
        System.assert(registros.size() > 0);        
    }

    @isTest
    public static void correctosEincorrecto(){
        Test.startTest();
        List<CBK_Margen_Facturacion__c> mfList = new List<CBK_Margen_Facturacion__c>();
        
        CBK_Margen_Facturacion__c mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(-10);
        mf.CC_Fecha_Fin__c = Date.today().addDays(-4);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(-2);
        mf.CC_Fecha_Fin__c = Date.today().addDays(2);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(4);
        mf.CC_Fecha_Fin__c = Date.today().addDays(10);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        Database.insert(mfList, false);

        Test.stopTest();

        List<CBK_Margen_Facturacion__c> registros = [SELECT Id FROM CBK_Margen_Facturacion__c];
        System.assert(registros.size() > 0);       
    }

    @isTest
    public static void sinFechaFin(){
        Test.startTest();
        List<CBK_Margen_Facturacion__c> mfList = new List<CBK_Margen_Facturacion__c>();
        
        CBK_Margen_Facturacion__c mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(4);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        mf = new CBK_Margen_Facturacion__c();
        mf.CC_Area_de_Negocio__c = 'ACCIONISTAS';
        mf.CC_Fecha_Inicio__c = Date.today().addDays(10);
        mf.CC_Margen__c = 23.0;
        mfList.add(mf);

        Database.insert(mfList, false);

        Test.stopTest();

        List<CBK_Margen_Facturacion__c> registros = [SELECT Id FROM CBK_Margen_Facturacion__c];
        System.assertEquals(3, registros.size());    

    }
}