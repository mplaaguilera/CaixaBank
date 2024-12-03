@isTest
public class CC_ST_AppStoreController_Test {
    @TestSetup
    static void makeData(){
        CC_ST_AppReviews__c appReviews = new CC_ST_AppReviews__c();
        appReviews.Review_ID__c = '1069665204';
        appReviews.App_ID__c = '1069665204';
        insert appReviews;
    }

	@istest
    public static void testSinRespuesta() {
        List<CC_ST_AppReviews__c> lstReviews = [SELECT Id, App_Id__c, Review_ID__c, Author_Name__c 
                                      FROM CC_ST_AppReviews__c];
        Test.StartTest();
        CC_ST_AppStoreController.insertReviews('438886197', 'es', false);
        Test.stopTest();
        List<CC_ST_AppReviews__c> lstReviews2 = [SELECT Id, App_Id__c, Review_ID__c, Author_Name__c 
                                      FROM CC_ST_AppReviews__c];
        System.assertEquals(lstReviews.size(), lstReviews2.size(), 'La inserción de la review ha fallado.');
    }

    private class MockHttpResponseExito implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getEndpoint().endsWith('1069665204')) {
                res.setBody('{"results": [{"artworkUrl60": "https://www.fake.img"}]}');
            }
            else {
                res.setBody('{"feed":{"entry":[{"author":{"name":{"label":"authorNameLabel"}},"im:rating":{"label":"imRatingLabel"},"im:version":{"label":"imVersionLabel"},"id":{"label":"idLabel"},"title":{"label":"titleLabel"},"content":{"label":"contentLabel"}}]}}');
            }
            
            return res;
        }
    }

    @istest
    public static void testExito() {
        List<CC_ST_AppReviews__c> lstReviews = [SELECT Id, App_Id__c, Review_ID__c, Author_Name__c 
                                    FROM CC_ST_AppReviews__c];
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        CC_ST_AppStoreController.insertReviews('438886197', 'es', false);
        Test.stopTest();
        List<CC_ST_AppReviews__c> lstReviews2 = [SELECT Id, App_Id__c, Review_ID__c, Author_Name__c 
                                    FROM CC_ST_AppReviews__c];
        System.assertEquals(lstReviews.size(), lstReviews2.size(), 'La inserción de la review ha fallado.');
    }

    @istest
    public static void format_fecha_Appstore() {
        Test.StartTest();
        DateTime fecha = CC_ST_AppStoreController.format_fecha_Appstore('Useless function');
        Test.stopTest();

        System.assertEquals(fecha, System.today(), 'Las fechas no coinciden.');
    }
}