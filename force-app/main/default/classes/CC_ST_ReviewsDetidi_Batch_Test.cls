@istest
public with sharing class CC_ST_ReviewsDetidi_Batch_Test {
	@istest
    public static void test() {       
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
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
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
        
        /*CC_ST_AppReviews__c st = new CC_ST_AppReviews__c();
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
        insert st;*/
        
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        caso.CC_MCC_Motivo__c = motiv.Id;
		caso.CC_MCC_ProdServ__c = prod.Id;
        caso.CC_MCC_Tematica__c = tem.Id;
        insert caso;
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'Prueba' LIMIT 1];
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
        //st.Case__c = c.Id;
        insert st;        
               
        Test.StartTest();
        CC_ST_ReviewsDetidi_Batch batch = new CC_ST_ReviewsDetidi_Batch();
		Database.executeBatch(batch);
        Test.stopTest();
    }
    
}