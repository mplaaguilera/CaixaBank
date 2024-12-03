@isTest
public class CC_ST_AppGalleryReview_Test {
    
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
    static void insertCommentTest(){
    	
        CC_ST_AppGalleryReview.ResponseData dataReviews = CC_ST_AppGalleryReview.insertReviews('103163995', 'ES', false,'23413341423434324234');
        List<CC_ST_AppReviews__c> lstReviews = dataReviews.lstReview;
        for(CC_ST_AppReviews__c review :lstReviews){
        	system.assertEquals('Huawei App Store', review.Source__c, 'Comprobamos el Source.'); 
            system.assertEquals('103163995', review.App_ID__c, 'Comprobamos el appId.'); 
        }
        
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
        comentario.App__c 	= 'BrokerNow';
        insert comentario;  
        
        Case caso = new Case();
        caso.Subject = 'Comentario de prueba';
        caso.Description = 'Comentario de prueba';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Contacto__c = 'Consulta';
		caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.App_Reviews__c = comentario.Id;
        caso.CC_Canal_Procedencia__c = 'Huawei App Store';
		caso.CC_Canal_Operativo__c = 'App BrokerNow';
		insert caso;
        
        comentario.Case__c = caso.Id;
        update comentario;
        
        CC_ST_AppGalleryReview.replyReviewAux('11111111', '89c5a05cf28d4c6f93aea2badb24fddb', 'Comentario respuesta');
  
        CC_ST_AppReviews__c comentarioUpd = [Select Developer_Comment__c, CC_Error_Publicacion__c from CC_ST_AppReviews__c where id = :comentario.Id limit 1];
        
        system.assertEquals('Comentario respuesta', comentarioUpd.Developer_Comment__c, 'Comprobamos se actualiza el campo de comentario.');
        system.assertEquals(false, comentarioUpd.CC_Error_Publicacion__c, 'Comprobamos no hubo error en la publicación');

    }
    
    @isTest
    static void replyAutoCommentsBrokerTest(){

        CC_ST_AppReviews__c comentario = new CC_ST_AppReviews__c();
        comentario.Review_ID__c = '89c5a05cf28d4c6f93aea2badb24fddb';
        comentario.App_ID__c 	= '11111111';
        comentario.Source__c 	= 'Huawei App Store	';
        comentario.Content__c 	= 'Comentario de prueba';
        comentario.Rating__c 	= '3';
        comentario.CC_Idioma__c = 'es';
        comentario.App__c 	= 'BrokerNow';
        insert comentario;  
        
        Case caso = new Case();
        caso.Subject = 'Comentario de prueba';
        caso.Description = 'Comentario de prueba';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Contacto__c = 'Consulta';
		caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.App_Reviews__c = comentario.Id;
        caso.CC_Canal_Procedencia__c = 'Huawei App Store';
		caso.CC_Canal_Operativo__c = 'App BrokerNow';
		insert caso;
        
        comentario.Case__c = caso.Id;
        update comentario;
        
        SocialPost socialPost = CC_ST_AppGalleryReview.respuetaAutomatica(comentario.App__c, comentario.Review_ID__c, comentario.case__c, null, null, comentario.App_Id__c, comentario.CC_Idioma__c);
  
        system.assertEquals(caso.Id, socialPost.ParentId, 'Comprobamos se crea el post relacionado al caso.');

    }
    
    @isTest
    static void replyAutoCommentsImaginTest(){

        CC_ST_AppReviews__c comentario = new CC_ST_AppReviews__c();
        comentario.Review_ID__c = '89c5a05cf28d4c6f93aea2badb24fddb';
        comentario.App_ID__c 	= '11111111';
        comentario.Source__c 	= 'Huawei App Store	';
        comentario.Content__c 	= 'Comentario de prueba';
        comentario.Rating__c 	= '3';
        comentario.CC_Idioma__c = 'es';
        comentario.App__c 	= 'ImaginBank';
        insert comentario;  
        
        Case caso = new Case();
        caso.Subject = 'Comentario de prueba';
        caso.Description = 'Comentario de prueba';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Contacto__c = 'Consulta';
		caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.App_Reviews__c = comentario.Id;
        caso.CC_Canal_Procedencia__c = 'Huawei App Store';
		caso.CC_Canal_Operativo__c = 'App Imagin';
		insert caso;
        
        comentario.Case__c = caso.Id;
        update comentario;
        
        SocialPost socialPost = CC_ST_AppGalleryReview.respuetaAutomatica(comentario.App__c, comentario.Review_ID__c, comentario.case__c, null, null, comentario.App_Id__c, comentario.CC_Idioma__c);
  
        system.assertEquals(caso.Id, socialPost.ParentId, 'Comprobamos se crea el post relacionado al caso.');

    }
    
    @isTest
    static void insertTareaTest(){

        CC_ST_AppReviews__c comentario = new CC_ST_AppReviews__c();
        comentario.Review_ID__c = '89c5a05cf28d4c6f93aea2badb24fddb';
        comentario.App_ID__c 	= '11111111';
        comentario.Source__c 	= 'Huawei App Store	';
        comentario.Content__c 	= 'Comentario de prueba';
        comentario.Rating__c 	= '3';
        comentario.CC_Idioma__c = 'es';
        comentario.App__c 		= 'BrokerNow';
        insert comentario;  
        
        Case caso = new Case();
        caso.Subject = 'Comentario de prueba';
        caso.Description = 'Comentario de prueba';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Contacto__c = 'Consulta';
		caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.App_Reviews__c = comentario.Id;
        caso.CC_Canal_Procedencia__c = 'Huawei App Store';
		caso.CC_Canal_Operativo__c = 'App BrokerNow';
		insert caso;
        
        comentario.Case__c = caso.Id;
        update comentario;
        
        CC_ST_AppGalleryReview.insertTask(comentario, 'ERROR');
  
        Task tarea = [Select Type, TaskSubtype, Subject, Status from Task where whatId = :caso.Id limit 1];
        
        system.assertEquals('Automática', tarea.Type, 'Comprobamos se crea el post relacionado al caso.');
        system.assertEquals('Task', tarea.TaskSubtype, 'Comprobamos se crea el post relacionado al caso.');
        system.assertEquals('Fallo Publicación en Huawei', tarea.Subject, 'Comprobamos se crea el post relacionado al caso.');
        system.assertEquals('Completed', tarea.Status, 'Comprobamos se crea el post relacionado al caso.');
        

    }
}