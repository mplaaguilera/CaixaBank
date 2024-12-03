@isTest
public class CC_Opportunity_Update_Test {

    @testSetup
	static void testSetup() {
        //Alta de parametrización necesaria
        //Productos
        Product2 productoHipoteca = new Product2();
        productoHipoteca.Name = 'Hipoteca';
        productoHipoteca.IsActive = true;
        insert productoHipoteca;

        //Lista de precios estándar
        //Test.getStandardPricebookId() permite recuperar el Id de la lista de
        //precios estándar de la org sin tener que habilitar @isTest(SeeAllData=true)
        Pricebook2 listaPrecios = new Pricebook2(Id = Test.getStandardPricebookId());
        listaPrecios.Name = 'Standard Price Book';
        listaPrecios.IsActive = true;
        update listaPrecios;

        //Precios de la lista para cada producto
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

        PricebookEntry precioHipotecaCsbd = new PricebookEntry();
        precioHipotecaCsbd.Pricebook2Id = listaPreciosCsbd.Id;
        precioHipotecaCsbd.Product2Id = productoHipoteca.Id;
        precioHipotecaCsbd.UnitPrice = 0;
        precioHipotecaCsbd.UseStandardPrice = false;
        precioHipotecaCsbd.IsActive = true;
        insert precioHipotecaCsbd;

        //Lista de valores de productos iniciales de la oportunidad
        CC_Lista_Valores__c lovProductosIniciales = new CC_Lista_Valores__c();
        lovProductosIniciales.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovProductosIniciales.Name = 'CSBD: Productos iniciales oportunidad';
        lovProductosIniciales.CC_Activa__c = true;
        insert lovProductosIniciales;

        CC_Lista_Valores__c lovProductoInicialHipoteca = new CC_Lista_Valores__c();
        lovProductoInicialHipoteca.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Valor');
        lovProductoInicialHipoteca.CC_Lista__c = lovProductosIniciales.Id;
        lovProductoInicialHipoteca.Name = CC_MetodosUtiles.getRecordTypeNameFromDeveloperName('Opportunity', 'CSBD_Hipoteca');
        lovProductoInicialHipoteca.CC_Activa__c = true;
        lovProductoInicialHipoteca.CC_Valor__c = 'Hipoteca';
        lovProductoInicialHipoteca.CC_Orden__c = 1;
        insert lovProductoInicialHipoteca;

        //Lista de valores de días de cierre por defecto de la oportunidad
        CC_Lista_Valores__c lovDiasCierre = new CC_Lista_Valores__c();
        lovDiasCierre.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_Lista_Valores__c', 'CC_Lista_Valores');
        lovDiasCierre.Name = 'CSBD: Días cierre oportunidad por defecto';
        lovDiasCierre.CC_Activa__c = true;
        insert lovDiasCierre;

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
        //Creación de usuarios necesarios para las pruebas
        User usuarioOld = altaUsuarioPrueba('old@prueba.test');
        User usuarioNew = altaUsuarioPrueba('new@prueba.test');

        //Creación de cuentas necesarias para las pruebas
        Account cuentaOld = new Account();
        cuentaOld.Name = 'cuenta test old';
        insert cuentaOld;
        
        Account cuentaNew = new Account();
        cuentaNew.Name = 'cuenta test new';
        insert cuentaNew;

        //Etapas de ventas
        String etapaVentasOld = 'Solicitud';

        //Creación de oportunidades
        //Hipoteca
        Map<String, Object> camposHipoteca = new Map<String, Object>();
        camposHipoteca.put('StageName', etapaVentasOld);
        camposHipoteca.put('AccountId', cuentaOld.Id);
        camposHipoteca.put('OwnerId', usuarioOld.Id);
        Opportunity oportunidadHipoteca = CSBD_Opportunity.crearOportunidad('CSBD_Hipoteca', camposHipoteca);
        
        //Ejecución de los updates
        Test.startTest();
        oportunidadHipoteca.StageName = 'Documentación';
        oportunidadHipoteca.AccountId = cuentaNew.Id;
        oportunidadHipoteca.CSBD_Propietario_Aux__c = usuarioNew.Id;
        update oportunidadHipoteca;

        //Evaluar resultados, se refrescan las oportunidades para poder evaluar sus datos
        oportunidadHipoteca = [SELECT CSBD_Identificador__c, Name, RecordType.Name, OwnerId, CSBD_Ultima_Etapa_Ventas__c, CreatedDate FROM Opportunity WHERE Id = :oportunidadHipoteca.Id];
        
        //Before Update: actualizar campo estándar de propietario al cambiar el custom
        System.assertEquals(usuarioNew.Id, oportunidadHipoteca.OwnerId);

        //Before Update: actualizar campo "Última etapa de ventas"
        System.assertEquals(etapaVentasOld, oportunidadHipoteca.CSBD_Ultima_Etapa_Ventas__c);

        //Before Update: actualizar nombre de la oportunidad
        String fechaCreacionHipoteca = oportunidadHipoteca.CreatedDate.day() + '/' + oportunidadHipoteca.CreatedDate.month() + '/' + oportunidadHipoteca.CreatedDate.year();
        System.assertEquals(oportunidadHipoteca.CSBD_Identificador__c + ' - ' + oportunidadHipoteca.RecordType.Name + ' - ' + cuentaNew.Name + ' - ' + fechaCreacionHipoteca, oportunidadHipoteca.Name);

        //After Update: crear actividad de reasignación
        System.assertEquals(1, [SELECT Count() FROM Task WHERE WhatId = :oportunidadHipoteca.Id AND Type = 'Reasignación' AND Status = 'Completed']);
    }

    private static User altaUsuarioPrueba(String emailAddress) {
        //Cálculo de userName aleatorio
        String userName = UserInfo.getOrganizationId();
        userName += String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        userName += Integer.valueOf(Math.rint(Math.random() * 1000000)); 
        userName += '@prueba.test';

        User nuevoUsuario = new User();
        nuevoUsuario.UserName = userName;
        nuevoUsuario.LastName = userName;
        nuevoUsuario.Alias = userName.substring(0, 7);
        nuevoUsuario.Email = emailAddress;
        nuevoUsuario.EmailEncodingKey = 'ISO-8859-1';
        nuevoUsuario.LanguageLocaleKey = 'es';
        nuevoUsuario.LocaleSidKey = 'es_ES';
        nuevoUsuario.TimeZoneSidKey = 'Europe/Paris';
        nuevoUsuario.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id;
        insert nuevoUsuario;

        return nuevoUsuario;
    }
}