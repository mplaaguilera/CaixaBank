@istest
public with sharing class CC_CierreCasos_AutomatedProcess_Test {
	@istest
    public static void test() {   
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User usr = new User(LastName = 'Process',
                     FirstName='Automated',
                     Alias = 'jliv',
                     Email = 'prueba@asdf.com',
                     Username = 'prueb1a@asdf.com',
                     ProfileId = profileId.id,
                     TimeZoneSidKey = 'GMT',
                     LanguageLocaleKey = 'en_US',
                     EmailEncodingKey = 'UTF-8',
                     LocaleSidKey = 'en_US'
                     );
        insert usr;
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'Sin canal';
        insert mcc;
        CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = tem.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];

        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Chat';
        caso.CC_Canal_Operativo__c = 'Sin canal';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'App';
		caso.CC_MCC_ProdServ__c = prod.Id;
        caso.CC_MCC_Tematica__c = tem.Id;
        caso.CC_Tipo_ChatTranscript__c = 'Hidden';
        caso.OwnerId = usr.Id;
        insert caso;
        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta 999';        
        insert cuenta;
        
        Id accountId = cuenta.Id;
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '999';      	
        contacto.AccountId = cuenta.Id;
        insert contacto;
        
        Test.StartTest();
        CC_Cierre_Casos_Hidden_Batch batch = new CC_Cierre_Casos_Hidden_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
        Case casoTest = [SELECT Status FROM Case WHERE Origin = 'Chat' LIMIT 1];
        System.assertEquals('Rechazado', casoTest.Status);
    }
    
}