@istest
public with sharing class CC_Detector_Idioma_Test {
	
    @istest
    public static void getIdioma() {   
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
        
        List<Id> oListRevApp = new List<Id>();
        List<CC_ST_AppReviews__c> OListApp = [SELECT Id FROM CC_ST_AppReviews__c LIMIT 2];
        for (CC_ST_AppReviews__c app : OListApp){
            oListRevApp.add(app.Id);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        CC_Detector_Idioma.getIdioma(oListRevApp, 'App Review');
		Test.stopTest();
        system.assertNotEquals(null, oListRevApp);
	}
    
    private class MockHttpResponseExito implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('lastEdited');
            
            return res;
        }
    }
    
}