/**********************************************************************************************************************
Name:	  CIBE_IntegracionRiesgo_Test
Copyright © 2022  CaixaBank
-----------------------------------------------------------------------------------------------------------------------
Proposito: 
-----------------------------------------------------------------------------------------------------------------------
Historial
---------------------
    VERSION		USER_STORY                                          AUTHOR                  DATE            COMMENTS  
    1.0         SF - Integración con API's de Divisas              Jose Maria Fernandez    
    1.1         US470406                                           Alexandre Perez          6/2/2023       Adaptación con los cambios de la integracion y tratamiento de errores
***********************************************************************************************************************/




@isTest
public with sharing class CIBE_IntegracionRiesgo_Test {

    @TestSetup
    static void makeData(){
        User usrTest = CIBE_TestHelper.createUser('CIBE_Gestor');
        Account accTest = CIBE_TestHelper.createCustomer();
        RecordType rt = CIBE_AppUtilities.getRecordType(CIBE_AppConstants.OBJECT_NAME_ACCOUNT, CIBE_AppConstants.ACCOUNT_CLIENTE_RT);
		Account acc = new Account(
                Name = 'Test Name 2',
				RecordTypeId = rt.Id,
				AV_NumPerso__c = '456',
				AV_Negocio__c = 'BPA',
                CIBE_FechaRefrescoRiesgoAgrupado__c = date.today(),
                CIBE_FechaRefrescoRiesgoDetallado__c = date.today(),
                CIBE_JsonRiesgoAgrupado__c = '{"totalBalance":[{"balance":{},"productType":"S","products":[{"productLevel":35,"productId":10214,"productDescription":"Tarjeta prepago","balance":[]}]},{"balance":{"balance":[{"type":"Balance","amount":144202.65,"ccy":"EUR"}]},"productType":"R","products":[{"productLevel":35,"productId":15890,"productDescription":"Renta variable","balance":[{"type":"Balance","amount":8534.61,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":6700,"ccy":"EUR"},{"type":"Withheld","amount":5600,"ccy":"EUR"}]},{"productLevel":35,"productId":10158,"productDescription":"Cuentas a la vista","balance":[{"type":"Balance","amount":107493.92,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":1900,"ccy":"EUR"},{"type":"Withheld","amount":3500,"ccy":"EUR"}]},{"productLevel":35,"productId":10063,"productDescription":"Planes Pensiones","balance":[{"type":"Balance","amount":28174.12,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":5635,"ccy":"EUR"},{"type":"Withheld","amount":300,"ccy":"EUR"}]}]},{"balance":{"balance":[{"type":"Disposed","amount":938.9,"ccy":"EUR"},{"type":"Risk","amount":8608.66,"ccy":"EUR"},{"type":"Unpaid","amount":0,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":165024.1,"ccy":"EUR"}]},"productType":"I","products":[{"productLevel":35,"productId":10012,"productDescription":"Descubierto","balance":[{"type":"Disposed","amount":0,"ccy":"EUR"},{"type":"Risk","amount":500,"ccy":"EUR"},{"type":"Unpaid","amount":0,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":0,"ccy":"EUR"}]},{"productLevel":35,"productId":10010,"productDescription":"Tarjetas","balance":[{"type":"Disposed","amount":938.9,"ccy":"EUR"},{"type":"Risk","amount":8108.66,"ccy":"EUR"},{"type":"Unpaid","amount":0,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":165024.1,"ccy":"EUR"}]}]}],"operativeServices":[{"id":11448,"serviceDescription":"Tributos","detail":"Una transferencia en los últimos dos meses"}]}',
                CIBE_JsonRiesgoDetallado__c = '{"passiveBalance":144202.65,"activeBalance":938.9,"Products":[{"productId":15890,"productDescription":"Renta variable","productBalance":8534.61,"Contracts":[{"contractId":2561582,"area":2,"modality":1,"office":9610,"aplication":"2","descriptionId":6388,"ccy":"200","dueDate":"2023-06-05","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"0"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":2301.36,"ccy":"200"},{"type":"Disposed","amount":535,"ccy":"EUR"},{"type":"Withheld","amount":2200,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":1200,"ccy":"EUR"}]},{"contractId":2764139,"area":2,"modality":1,"office":9610,"aplication":"2","descriptionId":6388,"ccy":"200","dueDate":"2023-12-14","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"0"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":3297.24,"ccy":"200"},{"type":"Disposed","amount":8000,"ccy":"EUR"},{"type":"Withheld","amount":3400,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":5500,"ccy":"EUR"}]}]},{"productId":10214,"productDescription":"Tarjeta prepago","productBalance":2.85,"Contracts":[{"contractId":2064723,"area":17,"modality":13,"office":9612,"aplication":"121","descriptionId":3050,"ccy":"200","openingDate":"2008-05-01","dueDate":"2027-12-14","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"N"},{"key":"MBK","value":"548"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":0,"ccy":"200"}]},{"contractId":2384354,"area":17,"modality":39,"office":9612,"aplication":"121","descriptionId":3050,"ccy":"200","openingDate":"2005-04-16","dueDate":"2025-10-14","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"N"},{"key":"MBK","value":"548"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":0,"ccy":"200"}]}]},{"productId":10158,"productDescription":"Cuentas a la vista","productBalance":107493.92,"Contracts":[{"contractId":2993,"area":1,"modality":22,"office":3022,"aplication":"1","descriptionId":10673,"ccy":"200","openingDate":"1984-03-26","dueDate":"2026-11-23","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"0"}],"Balance":[{"type":"Limit","amount":2050,"ccy":"200"},{"type":"Granted","amount":2050,"ccy":"200"},{"type":"Available","amount":165024.1,"ccy":"200"},{"type":"Disposed","amount":7000,"ccy":"EUR"},{"type":"Withheld","amount":1100,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":200,"ccy":"EUR"}]},{"contractId":5891,"area":1,"modality":22,"office":3022,"aplication":"1","descriptionId":11024,"ccy":"200","openingDate":"2014-10-01","dueDate":"2026-04-11","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"0"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Disposed","amount":100494,"ccy":"EUR"},{"type":"Withheld","amount":2400,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":1700,"ccy":"EUR"}]}]},{"productId":10063,"productDescription":"Planes Pensiones","productBalance":28174.12,"Contracts":[{"contractId":2001928,"area":54,"modality":30,"office":9690,"aplication":"226","descriptionId":98,"ccy":"200","openingDate":"1994-03-03","dueDate":"2026-04-11","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"S"},{"key":"MBK","value":"0"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":34943.69,"ccy":"200"},{"type":"Disposed","amount":28174,"ccy":"EUR"},{"type":"Withheld","amount":300,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":5635,"ccy":"EUR"}]}]},{"productId":10012,"productDescription":"Descubierto","productBalance":0,"Contracts":[]},{"productId":10010,"productDescription":"Tarjetas","productBalance":938.9,"Contracts":[{"contractId":1505456,"area":17,"modality":32,"office":9612,"aplication":"121","descriptionId":2374,"ccy":"200","openingDate":"2005-03-17","dueDate":"2024-03-12","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"N"},{"key":"MBK","value":"30"}],"Balance":[{"type":"Limit","amount":0,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Available","amount":3.4,"ccy":"200"},{"type":"Disposed","amount":39,"ccy":"EUR"},{"type":"Risk","amount":109,"ccy":"EUR"},{"type":"Unpaid","amount":0,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":100000,"ccy":"EUR"}]},{"contractId":2006144,"area":17,"modality":46,"office":9612,"aplication":"121","descriptionId":3676,"ccy":"200","openingDate":"2005-01-11","dueDate":"2025-01-11","Indicators":[{"key":"CAN","value":"N"},{"key":"SCF","value":"N"},{"key":"VIN","value":"N"},{"key":"MBK","value":"30"}],"Balance":[{"type":"Limit","amount":600,"ccy":"200"},{"type":"Granted","amount":0,"ccy":"200"},{"type":"Disposed","amount":900,"ccy":"EUR"},{"type":"Risk","amount":8000,"ccy":"EUR"},{"type":"Unpaid","amount":0,"ccy":"EUR"},{"type":"Last12MonthsBalanceVariation","amount":65024,"ccy":"EUR"}]}]}]}'
			);
		insert acc;
        Product2 prodPF = AV_TestHelper.createProduct(null,null);
		Product2 prodN20 = AV_TestHelper.createProduct(prodPF,'20');
		Product2 prodN10 = AV_TestHelper.createProduct(prodN20,'10');
        AV_Sales__c sales = new AV_Sales__c();
        sales.AV_Cliente__c = accTest.Id;
        sales.AV_Producto__c = prodN10.Id;
        sales.AV_ClaseVenta__c = 'V';
        sales.AV_TipoVenta__c = '010';
        sales.AV_FechaVenta__c = system.today();
        sales.AV_NumeroContrato__c = '1505456';
        insert sales;

    }

    @isTest
    private static void TestSendRequestTodosOK() {     

        integer productos=0;
        User usrTest = [SELECT ID FROM USER LIMIT 1];  
        CIBE_IntegracionRiesgo.Response eventResponse = new CIBE_IntegracionRiesgo.Response();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RIESGO','OK'));
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        list<CBK_IntegrationSetting__c> listEndpointConf = new list<CBK_IntegrationSetting__c>();
        System.runAs(usrTest) {
            CBK_IntegrationSetting__c endpointConf = new CBK_IntegrationSetting__c(Name=CIBE_IntegracionRiesgo.PARAM_RIESGO_AGRUPADO, NamedCredential__c = 'grouped');
            listEndpointConf.add(endpointConf);
            
            CBK_IntegrationSetting__c endpointConf2 = new CBK_IntegrationSetting__c(Name=CIBE_IntegracionRiesgo.PARAM_RIESGO_DETALLADO, NamedCredential__c = 'detail');
            listEndpointConf.add(endpointConf2);
            insert listEndpointConf;
            for(CBK_IntegrationSetting__c config : listEndpointConf){
                test.setCreatedDate(config.id, dateTime.newInstance(2023, 5, 1));
            }
            update listEndpointConf;
            CBK_IntegrationSetting__c wsc = CBK_IntegrationSetting__c.getValues('getProductsAgrupado');
            system.debug(wsc);
            Test.StartTest();
            eventResponse= CIBE_IntegracionRiesgo.getRiesgoProducts(accTest.Id, CIBE_IntegracionRiesgo.PARAM_RIESGO_TODOS);
            Test.StopTest();
        }
        
        for(CIBE_IntegracionRiesgo.TotalBalanceWrapper balance : eventResponse.responseAcumulado.totalBalance){
            for(CIBE_IntegracionRiesgo.ProductWrapperAcumulado product : balance.products) {
                productos++;
            }
        }

        system.assertEquals(3,  eventResponse.responseAcumulado.totalBalance.size(), 'La cantidad de agrupaciones de productos no es la esperada');
        system.assertEquals(6, productos, 'La cantidad de productos no es la esperada');

    }

    @isTest
    private static void TestSendRequestTodosOK24Horas() {     

        integer productos=0;
        User usrTest = [SELECT ID FROM USER LIMIT 1];   
        CIBE_IntegracionRiesgo.Response eventResponse = new CIBE_IntegracionRiesgo.Response();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RIESGO','OK'));
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Test Name 2' LIMIT 1];
        System.runAs(usrTest) {
            CBK_IntegrationSetting__c endpointConf = new CBK_IntegrationSetting__c(Name=CIBE_IntegracionRiesgo.PARAM_RIESGO_AGRUPADO, NamedCredential__c = 'grouped');

            insert endpointConf;
            
            Test.StartTest();
            //segunda llamada en menos de 24 horas
            eventResponse= CIBE_IntegracionRiesgo.getRiesgoProducts(accTest.Id, CIBE_IntegracionRiesgo.PARAM_RIESGO_TODOS);
            Test.StopTest();
        }
        
        for(CIBE_IntegracionRiesgo.TotalBalanceWrapper balance : eventResponse.responseAcumulado.totalBalance){
            for(CIBE_IntegracionRiesgo.ProductWrapperAcumulado product : balance.products) {
                productos++;
            }
        }

        system.assertEquals(3,  eventResponse.responseAcumulado.totalBalance.size(), 'La cantidad de agrupaciones de productos no es la esperada');
        system.assertEquals(6, productos, 'La cantidad de productos no es la esperada');

    }

    @isTest
    private static void TestSendRequestHttpKO() {     

        User usrTest = [SELECT ID FROM USER LIMIT 1]; 
        string error = '';
        CIBE_IntegracionRiesgo.Response eventResponse = new CIBE_IntegracionRiesgo.Response();
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('HTTP','KO'));
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        System.runAs(usrTest) {
            Test.StartTest();
            try {
                eventResponse= CIBE_IntegracionRiesgo.getRiesgoProducts(accTest.Id, CIBE_IntegracionRiesgo.PARAM_RIESGO_TODOS);
            } catch(Exception e) {
                error = e.getMessage();
            }
            Test.StopTest();
        }

        system.assertNotEquals('',  error, 'Se esperaba un error APEX en el sendRequest');

    }

    @isTest
    private static void TestJSONKO() {     

        User usrTest = [SELECT ID FROM USER LIMIT 1]; 
        string error = '';
        CIBE_IntegracionRiesgo.Response eventResponse = new CIBE_IntegracionRiesgo.Response();
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('JSON','KO'));
        System.runAs(usrTest) {
            Test.StartTest();
            try {
                eventResponse= CIBE_IntegracionRiesgo.getRiesgoProducts(accTest.Id, CIBE_IntegracionRiesgo.PARAM_RIESGO_TODOS);
            } catch(Exception e) {
                error = e.getMessage();
            }
            Test.StopTest();
        }

        system.assertNotEquals('',  error, 'Se esperaba un error JSON en el deserealize del response');

    }

    @isTest
    private static void TestNumpersoKO() {     

        User usrTest = [SELECT ID FROM USER LIMIT 1]; 
        string error = '';
        CIBE_IntegracionRiesgo.Response eventResponse = new CIBE_IntegracionRiesgo.Response();
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        accTest.AV_NumPerso__c = '';
        update accTest;
        System.runAs(usrTest) {
            Test.StartTest();
            try {
                eventResponse= CIBE_IntegracionRiesgo.getRiesgoProducts(accTest.Id, CIBE_IntegracionRiesgo.PARAM_RIESGO_TODOS);
            } catch(Exception e) {
                error = e.getMessage();
            }
            Test.StopTest();
        }

        system.assertNotEquals('',  error, 'Se esperaba error por falta de NumPerso');

    }

    @isTest
    private static void TestCodeStatusKO() {     

        User usrTest = [SELECT ID FROM USER LIMIT 1]; 
        string error = '';
        CIBE_IntegracionRiesgo.Response eventResponse = new CIBE_IntegracionRiesgo.Response();
        Account accTest = [SELECT Id FROM Account WHERE Name = 'Name' LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CIBE_MockCallout_Test('RIESGO','KO'));
        System.runAs(usrTest) {
            Test.StartTest();
            try {
                eventResponse= CIBE_IntegracionRiesgo.getRiesgoProducts(accTest.Id, CIBE_IntegracionRiesgo.PARAM_RIESGO_TODOS);
            } catch(Exception e) {
                error = e.getMessage();
            }
            Test.StopTest();
        }

        system.assertNotEquals('',  error, 'Se esperaba error por codeStatus < 200 o > 299');

    }
   
}