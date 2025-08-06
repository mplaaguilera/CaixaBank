@IsTest
public with sharing class CC_ST_ReviewsCaseBatch_Test {
	@isTest
    static void CC_ST_ReviewsCaseBatch() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
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
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = prod.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;
        
        CC_ST_AppReviews__c st = new CC_ST_AppReviews__c();
        st.Source__c = 'Google Play Store';
        st.App__c = 'CaixaBank';
        st.App_ID__c = 'es.lacaixa.mobile.android.newwapicon';
        st.Author_Name__c = 'ST';
        st.Rating__c='5';
        st.Review_ID__c = 'rev123';
        st.CC_Actualizacion_Review__c = false;
        st.Title__c = 'Prueba1';
        st.Content__c = 'Contenido1';
        st.Procesado__c = false;
        insert st;
        
        CC_ST_AppReviews__c st1 = new CC_ST_AppReviews__c();
        st1.Source__c = 'Google Play Store';
        st1.App__c = 'CaixaBank';
        st1.App_ID__c = 'es.lacaixa.mobile.android.newwapicon';
        st1.Author_Name__c = 'ST';
        st1.Rating__c='2';
        st1.Review_ID__c = 'rev456';
        st1.CC_Actualizacion_Review__c = true;
        st1.Title__c = 'Prueba2';
        st1.Content__c = 'Contenido2';
        st1.Procesado__c = false;
        insert st1;
        
        CC_ST_AppReviews__c st2 = new CC_ST_AppReviews__c();
        st2.Source__c = 'Google Play Store';
        st2.App__c = 'CaixaBank';
        st2.App_ID__c = 'es.lacaixa.mobile.android.newwapicon';
        st2.Author_Name__c = 'ST';
        st2.Rating__c='4';
        st2.Review_ID__c = 'rev789';
        st2.CC_Actualizacion_Review__c = false;
        st2.Title__c = 'Prueba2';
        st2.Content__c = 'Contenido2';
        st2.CC_Idioma__c = 'es';
        st2.Procesado__c = false;
        insert st2;
		
        Test.startTest();
    	CC_ST_ReviewsCaseBatch batch = new CC_ST_ReviewsCaseBatch();
		Database.executeBatch(batch);
        Test.stopTest();
    }
}