@isTest
public with sharing class CC_Alertas_Volumen_Test {
    @TestSetup
    static void makeData() {
        EmailTemplate template1 = new EmailTemplate();
        template1.FolderId = UserInfo.getUserId();
        template1.Name = 'Comunicacion a Oficina por Cierre de Caso CAS - Informal';
        template1.Subject = '[num_casos]';
        template1.HtmlValue = '[num_casos] , [nombre_activo] , [nombre_oficina], [datos_casos]';
        template1.DeveloperName = 'CC_Aviso_sobre_Activo';
        template1.TemplateType = 'Text';
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert template1;
        }

    	//lista de valores
        List<CC_Lista_Valores__c> lista = new List <CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> val = new List <CC_Lista_Valores__c>();
        
        CC_Lista_Valores__c avisosActivos = new CC_Lista_Valores__c();
        avisosActivos.Name = 'Avisos sobre Activos';
        avisosActivos.CC_Activa__c = true;
        avisosActivos.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();
        lista.add(avisosActivos);
        insert lista;

        CC_Lista_Valores__c val1 = new CC_Lista_Valores__c();
        val1.Name = 'CAIX-12 - Reiteraciones';
        val1.CC_Activa__c = true;
        val1.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        val1.CC_Lista__c = avisosActivos.Id;
        val1.CC_Valor__c = '2';
        val.add(val1);
        
        CC_Lista_Valores__c val2 = new CC_Lista_Valores__c();
        val2.Name = 'CAIX-12 - Periodo de evaluacion';
        val2.CC_Activa__c = true;
        val2.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        val2.CC_Lista__c = avisosActivos.Id;
        val2.CC_Valor__c = '12';
        val.add(val2);
        
       	CC_Lista_Valores__c val3 = new CC_Lista_Valores__c();
        val3.Name = 'CAIX-12 - Destinatarios';
        val3.CC_Activa__c = true;
        val3.RecordTypeId = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();
        val3.CC_Lista__c = avisosActivos.Id;
        val3.CC_Valor__c = 'manuel.albacete.krenn@ibm.com';
        val.add(val3);
        insert val;

        Id recordTypeCentroCaixaBank = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
        
        Account centro = new Account();
        centro.Name = 'Cuenta Test Gestora';
        centro.CC_Email__c = 'cuentasolinfoemp@test.com';
        centro.RecordTypeId = recordTypeCentroCaixaBank;
        centro.CC_Tipo_Centro__c='OF';
        centro.CC_Email__c='test@gmail.com';
        insert centro;
        
        Asset asset= new Asset();
		asset.Name='Asset de Prueba';
        asset.CC_Numero_Maquina__c='1110001';
        asset.CC_Modelo_Activo__c='2222';
        asset.AccountId=centro.Id;
        asset.CC_Familia_Activo__c='CAIX';
        asset.CC_Tipo_Activo__c='12';
        insert asset;
        
        Id recordTypeCasoCliente = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();

        Case caso = new Case();
        caso.CC_Idioma__c = 'es';
        caso.RecordTypeId = recordTypeCasoCliente;
        caso.Subject = 'Prueba';
        caso.CC_Oficina__c = centro.Id;
        caso.AssetId=asset.Id;
        caso.Status = 'Activo';
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Caixabank Talks';
        caso.CC_Canal_Resolucion__c = 'Cajeros';
        caso.CC_Tipo_Contacto__c = 'Consulta';
        insert caso;
        
        Case caso2 = new Case();
        caso2.CC_Idioma__c = 'es';
        caso2.RecordTypeId = recordTypeCasoCliente;
        caso2.Subject = 'Prueba 2';
        caso2.CC_Oficina__c = centro.Id;
        caso2.AssetId=asset.Id;
        caso2.Status = 'Activo';
        caso2.Origin = 'Email';
        caso2.CC_Canal_Procedencia__c = 'Caixabank Talks';
        caso2.CC_Canal_Resolucion__c = 'Cajeros';
        caso2.CC_Tipo_Contacto__c = 'Consulta';
        insert caso2;
    }

    @isTest
    static void contadorAssetTest() {
     
        List<Case> casos = [SELECT Id FROM Case LIMIT 1];
        List<Id> idsCaso = new List<Id>();

        for (Case caso : casos) {
            idsCaso.add(caso.Id);
        }

        Test.startTest();
        CC_Alertas_Volumen.contadorAsset(idsCaso);
        Test.stopTest();
    }
}