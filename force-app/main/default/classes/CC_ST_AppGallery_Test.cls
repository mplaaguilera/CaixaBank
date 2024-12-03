@isTest
public class CC_ST_AppGallery_Test {
    @testSetup
    static void test(){
	
    	Google_SA_Token__c tokenSA = new Google_SA_Token__c();
        tokenSA.Name = 'Huawei_Store';
        tokenSA.Timestamp__c = null; 
        tokenSA.Value__c = '';
        insert tokenSA;
        
        CBK_IntegrationSetting__c getComSetting = new CBK_IntegrationSetting__c();
        getComSetting.Name = 'getComments';
        getComSetting.NamedCredential__c = 'https://connect-api-dre.cloud.huawei.com/api/reviews/v1/manage/dev/reviews?appId={appId}&beginTime={beginTime}&endTime={endTime}&countries={country}';
        insert getComSetting;
        
        CBK_IntegrationSetting__c replyComSetting = new CBK_IntegrationSetting__c();
        replyComSetting.Name = 'replyComments';
        replyComSetting.NamedCredential__c = 'https://connect-api-dre.cloud.huawei.com/api/reviews/v1/manage/dev/reviews';
        insert replyComSetting;
    }
    
    
    @isTest
    static void getCommentsTest(){
    	
        CC_ST_AppGallery.Response response = CC_ST_AppGallery.sendRequest('11111111', 'ES', 'Huawei_Store', '2341314242342344');

        system.assert(response.endpoint.contains('https://connect-api-dre.cloud.huawei.com/api/reviews/v1/manage/dev/reviews'), 'Comprobamos llama al endpoint correcto.');
        system.assert(response.review != null, 'Comprobamos se recibe comentarios.');
        system.assert(response.errorCode == null, 'Comprobamos no hay código de error.');
        system.assert(response.errorMessage == null, 'Comprobamos no hay mensaje de error.');
        
    }
    
    @isTest
    static void replyCommentsTest(){
    	
        CC_ST_AppReviews__c comentario = new CC_ST_AppReviews__c();
        comentario.Review_ID__c = '89c5a05cf28d4c6f93aea2badb24fddb';
        comentario.App_ID__c 	= '11111111';
        comentario.Source__c 	= 'Huawei App Store	';
        comentario.Content__c 	= 'Comentario de prueba';
        comentario.Rating__c 	= '3';
        comentario.CC_Idioma__c = 'es';
        insert comentario;        
        
        CC_ST_AppGallery.ResponseReply response = CC_ST_AppGallery.sendRequestReply('11111111', '89c5a05cf28d4c6f93aea2badb24fddb', 'Comentario respuesta', comentario);

        system.assert(response.endpoint.contains('https://connect-api-dre.cloud.huawei.com/api/reviews/v1/manage/dev/reviews'), 'Comprobamos llama al endpoint correcto.');
        system.assertEquals('success', response.estado, 'Comprobamos se recibe comentarios.');
        system.assert(response.statusCode == '200', 'Comprobamos el estado de la petición.');
        system.assert(response.errorCode == null, 'Comprobamos no hay código de error');
        system.assert(response.errorMessage == null, 'Comprobamos no hay mensaje de error.');
        
    }
}