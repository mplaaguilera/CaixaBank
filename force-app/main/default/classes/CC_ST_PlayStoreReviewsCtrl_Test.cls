@IsTest
public class CC_ST_PlayStoreReviewsCtrl_Test {
    
	@isTest
    static void getReviews() {
        Id recordTem = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id recordProd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        Id recordMot = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c =  'TE-'+ String.valueOf(System.currentTimeMillis());
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;

        //// CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-' + String.valueOf(System.currentTimeMillis());
        mcc1.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        // CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-' + String.valueOf(System.currentTimeMillis());
        mcc2.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc2;  
		// //CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
       Case c1 = new Case();
        c1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = mcc2.Id;
		c1.CC_MCC_ProdServ__c = mcc1.Id;
        c1.CC_MCC_Tematica__c = mcc.Id;
        insert c1;
        
        //Case c2 = [SELECT Id FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
        List<CC_ST_AppReviews__c> ListAppRevc = new List<CC_ST_AppReviews__c>();
        CC_ST_AppReviews__c AppRev = new CC_ST_AppReviews__c();
        //AppRev.Name = 'A-01157';
        AppRev.Author_Name__c = 'kiona sanchez';
        AppRev.Title__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder';
        AppRev.Content__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder pagar y no estaba segura de hacer otra targeta, así que mi valoración es de 1 estrella por que no es práctica.';
        AppRev.Case__c = c1.Id;
        AppRev.Rating__c = '1';
        AppRev.App__c = 'Caixabank Pay';
        AppRev.Source__c = 'Google Play Store';
        AppRev.Review_ID__c = 'gp:AOqpTOG_KD8CPLfOgLbq_L4YkcH4WWJA5mnl8CTNy-8VldkSgKEU-NJQKv-aCS4Y3C00f4VsvAvDRZ4ZMFRAN';
        AppRev.Developer_Comment__c = '';
        AppRev.App_Id__c = 'es.lacaixa.hceicon2';
        AppRev.App_Image__c = 'https://lh3.googleusercontent.com/_X2aK6fswJhaHZmsGCsR5-a5kh2NT7SQWnCCTs__eQswXlvilZqha8b-HVnuo7_Df6YA=s60-rw';
        insert AppRev;
        ListAppRevc.add(AppRev);
        
        String packageName = 'es.lacaixa.hceicon2';
        List<CC_ST_AppReviews__c> LReview = new List<CC_ST_AppReviews__c>();
        LReview = CC_ST_PlayStoreReviewsCtrl.getReviews(packageName);
        System.assertNotEquals(null, LReview, 'La recepción de comentarios ha fallado.');
    }
    @isTest(seeAllData=true)  
    static void replyReview() {
        Id recordTem = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id recordProd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        Id recordMot = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-'+  String.valueOf(System.currentTimeMillis());
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
        //// CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-' + + String.valueOf(System.currentTimeMillis());
        mcc1.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        // CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-' + String.valueOf(System.currentTimeMillis());
        mcc2.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc2;  
		// //CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
       Case c1 = new Case();
        c1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = mcc2.Id;
		c1.CC_MCC_ProdServ__c = mcc1.Id;
        c1.CC_MCC_Tematica__c = mcc.Id;
        insert c1;
        
        //Case c2 = [SELECT Id FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
        CC_ST_AppReviews__c AppRev = new CC_ST_AppReviews__c();
        //AppRev.Name = 'A-01157';
        AppRev.Author_Name__c = 'kiona sanchez';
        AppRev.Title__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder';
        AppRev.Content__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder pagar y no estaba segura de hacer otra targeta, así que mi valoración es de 1 estrella por que no es práctica.';
        AppRev.Case__c = c1.Id;
        AppRev.Rating__c = '1';
        AppRev.App__c = 'Caixabank Pay';
        AppRev.Source__c = 'Google Play Store';
        AppRev.Review_ID__c = 'gp:AOqpTOG_KD8CPLfOgLbq_L4YkcH4WWJA5mnl8CTNy-8VldkSgKEU-NJQKv-aCS4Y3C00f4VsvAvDRZ4ZMFRAN';
        AppRev.Developer_Comment__c = '';
        AppRev.App_Id__c = 'es.lacaixa.hceicon2';
        AppRev.App_Image__c = 'https://lh3.googleusercontent.com/_X2aK6fswJhaHZmsGCsR5-a5kh2NT7SQWnCCTs__eQswXlvilZqha8b-HVnuo7_Df6YA=s60-rw';
        insert AppRev;
        
        CC_ST_AppReviews__c appReview = [SELECT Id, App_Id__c, Review_ID__c, Developer_Comment__c, CC_Error_Publicacion__c
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        String replyText = 'Respuesta prueba';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        CC_ST_PlayStoreReviewsCtrl.replyReview(appReview.App_Id__c, appReview.Review_ID__c, replyText);
        Test.stopTest();
        CC_ST_AppReviews__c appReviewv2 = [SELECT Id, App_Id__c, Review_ID__c, Developer_Comment__c, CC_Error_Publicacion__c
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        
        System.assertNotEquals(appReview, appReviewv2, 'La respuesta al comentario ha fallado.');
    }


    private class MockHttpResponseExito implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"replyText": "Hola.","lastEdited": {"seconds": "1","nanos": "1"}}}');
            
            return res;
        }
    }


@isTest(seeAllData=true)
    static void replyReviewAuto() {
        Id recordTem = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id recordProd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        Id recordMot = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-'+ String.valueOf(System.currentTimeMillis());
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
       // CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-' + String.valueOf(System.currentTimeMillis());
        mcc1.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-' + String.valueOf(System.currentTimeMillis());
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc2;  
		//CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
       Case c1 = new Case();
        c1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = mcc2.Id;
		c1.CC_MCC_ProdServ__c = mcc1.Id;
        c1.CC_MCC_Tematica__c = mcc.Id;
        insert c1;
        
        //Case c2 = [SELECT Id FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
        CC_ST_AppReviews__c AppRev = new CC_ST_AppReviews__c();
        //AppRev.Name = 'A-01157';
        AppRev.Author_Name__c = 'kiona sanchez';
        AppRev.Title__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder';
        AppRev.Content__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder pagar y no estaba segura de hacer otra targeta, así que mi valoración es de 1 estrella por que no es práctica.';
        AppRev.Case__c = c1.Id;
        AppRev.Rating__c = '1';
        AppRev.App__c = 'Caixabank Pay';
        AppRev.Source__c = 'Google Play Store';
        AppRev.Review_ID__c = 'gp:AOqpTOG_KD8CPLfOgLbq_L4YkcH4WWJA5mnl8CTNy-8VldkSgKEU-NJQKv-aCS4Y3C00f4VsvAvDRZ4ZMFRAN';
        AppRev.Developer_Comment__c = '';
        AppRev.App_Id__c = 'es.lacaixa.hceicon2';
        AppRev.App_Image__c = 'https://lh3.googleusercontent.com/_X2aK6fswJhaHZmsGCsR5-a5kh2NT7SQWnCCTs__eQswXlvilZqha8b-HVnuo7_Df6YA=s60-rw';
        insert AppRev;
        
        CC_ST_AppReviews__c appReview = [SELECT Id, App_Id__c, Review_ID__c, Developer_Comment__c, CC_Error_Publicacion__c
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        String replyText = 'Respuesta prueba para probar las "dobles comillas"';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        CC_ST_PlayStoreReviewsCtrl.replyReviewAuto(appReview.App_Id__c, appReview.Review_ID__c, replyText);
        Test.stopTest();
        CC_ST_AppReviews__c appReviewv2 = [SELECT Id, App_Id__c, Review_ID__c, Developer_Comment__c, CC_Error_Publicacion__c
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        
        System.assertNotEquals(appReview, appReviewv2, 'La respuesta al comentario ha fallado.');
        //system.assertNotEquals(null, LReview);
    }
    @isTest(seeAllData=true)
    static void Respuesta_automatica() {
        Id recordTem = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id recordProd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        Id recordMot = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c =  'TE-'+ + String.valueOf(System.currentTimeMillis());
        mcc.CC_Canal_Operativo__c = '	App BrokerNow';
        insert mcc;
       // CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-' + String.valueOf(System.currentTimeMillis());
        mcc1.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-' + String.valueOf(System.currentTimeMillis());
        mcc2.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc2;  
		//CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
       Case c1 = new Case();
        c1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = mcc2.Id;
		c1.CC_MCC_ProdServ__c = mcc1.Id;
        c1.CC_MCC_Tematica__c = mcc.Id;
        insert c1;
        
        Case c2 = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
        SocialPost post = new SocialPost();
       	post.Name = 'Mejorable';
        post.Content = 'Se echan de menos los menús más sencillos e inmediatos de la web.Se tarda más en repetir una transferencia vía app que via web. Lento y confuso. Si vuelves a entrar al poco te recuerda que ha caducado la sesión y debes iniciarla manualmente. Lento. Y esto ya no es cosa de la app, es cosa de La Caixa, que oferta alojamientos, vehículos y toda clase de paja. Esto es un banco o El Corte Inglés?';
        post.Posted = system.now();
        post.Provider = 'Other';
        post.MessageType = 'Comment';
        post.Handle = 'DeCe79';
        post.IsOutBound = false;
        post.ParentId = c2.Id;
        insert post;
        
        SocialPost sp = [SELECT Id FROM SocialPost WHERE Name = 'Mejorable' LIMIT 1];
        
        CC_ST_AppReviews__c AppRev = new CC_ST_AppReviews__c();
        //AppRev.Name = 'A-01157';
        AppRev.Author_Name__c = 'kiona sanchez';
        AppRev.Title__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder';
        AppRev.Content__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder pagar y no estaba segura de hacer otra targeta, así que mi valoración es de 1 estrella por que no es práctica.';
        AppRev.Case__c = c1.Id;
        AppRev.Rating__c = '1';
        AppRev.App__c = 'Caixabank Pay';
        AppRev.Source__c = 'Google Play Store';
        AppRev.Review_ID__c = 'gp:AOqpTOG_KD8CPLfOgLbq_L4YkcH4WWJA5mnl8CTNy-8VldkSgKEU-NJQKv-aCS4Y3C00f4VsvAvDRZ4ZMFRAN';
        AppRev.Developer_Comment__c = '';
        AppRev.App_Id__c = 'es.lacaixa.hceicon2';
        AppRev.SocialPost__c = sp.Id;
        AppRev.App_Image__c = 'https://lh3.googleusercontent.com/_X2aK6fswJhaHZmsGCsR5-a5kh2NT7SQWnCCTs__eQswXlvilZqha8b-HVnuo7_Df6YA=s60-rw';
        insert AppRev;
        
        //Respuesta_automatica(String Store, String ReviewId, Id CaseId,Id SocialPostId, String NombreCliente, String packageName, String idioma){        
        CC_ST_AppReviews__c appReview = [SELECT Id, App_Id__c, Review_ID__c, Author_Name__c, Developer_Comment__c, CC_Error_Publicacion__c
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        String replyText = 'Respuesta prueba';
        String Store = 'CaixaBank Sign';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        CC_ST_PlayStoreReviewsCtrl.Respuesta_automatica(Store, appReview.Review_ID__c, c2.Id, sp.Id,appReview.Author_Name__c, appReview.App_Id__c, c2.CC_Idioma__c);
        Test.stopTest();
        CC_ST_AppReviews__c appReviewv2 = [SELECT Id, App_Id__c, Review_ID__c, Developer_Comment__c, CC_Error_Publicacion__c
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        
        System.assertNotEquals(appReview, appReviewv2, 'La respuesta al comentario ha fallado.');
        //system.assertNotEquals(null, LReview);
    }
    @isTest(seeAllData=true)
    static void Respuesta_automaticaBKN() {
        Id recordTem = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id recordProd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        Id recordMot = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c =  'TE-' + String.valueOf(System.currentTimeMillis());
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
       // CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-' + String.valueOf(System.currentTimeMillis());
        mcc1.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-' + String.valueOf(System.currentTimeMillis());
        mcc2.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc2;  
		//CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
       Case c1 = new Case();
        c1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = mcc2.Id;
		c1.CC_MCC_ProdServ__c = mcc1.Id;
        c1.CC_MCC_Tematica__c = mcc.Id;
        insert c1;
        
        Case c2 = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
        SocialPost post = new SocialPost();
       	post.Name = 'Mejorable';
        post.Content = 'Se echan de menos los menús más sencillos e inmediatos de la web.Se tarda más en repetir una transferencia vía app que via web. Lento y confuso. Si vuelves a entrar al poco te recuerda que ha caducado la sesión y debes iniciarla manualmente. Lento. Y esto ya no es cosa de la app, es cosa de La Caixa, que oferta alojamientos, vehículos y toda clase de paja. Esto es un banco o El Corte Inglés?';
        post.Posted = system.now();
        post.Provider = 'Other';
        post.MessageType = 'Comment';
        post.Handle = 'DeCe79';
        post.IsOutBound = false;
        post.ParentId = c2.Id;
        insert post;
        
        SocialPost sp = [SELECT Id FROM SocialPost WHERE Name = 'Mejorable' LIMIT 1];
        
        CC_ST_AppReviews__c AppRev = new CC_ST_AppReviews__c();
        //AppRev.Name = 'A-01157';
        AppRev.Author_Name__c = 'kiona sanchez';
        AppRev.Title__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder';
        AppRev.Content__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder pagar y no estaba segura de hacer otra targeta, así que mi valoración es de 1 estrella por que no es práctica.';
        AppRev.Case__c = c1.Id;
        AppRev.Rating__c = '1';
        AppRev.App__c = 'Caixabank Pay';
        AppRev.Source__c = 'Google Play Store';
        AppRev.Review_ID__c = 'gp:AOqpTOG_KD8CPLfOgLbq_L4YkcH4WWJA5mnl8CTNy-8VldkSgKEU-NJQKv-aCS4Y3C00f4VsvAvDRZ4ZMFRAN';
        AppRev.Developer_Comment__c = '';
        AppRev.App_Id__c = 'es.lacaixa.hceicon2';
        AppRev.SocialPost__c = sp.Id;
        AppRev.App_Image__c = 'https://lh3.googleusercontent.com/_X2aK6fswJhaHZmsGCsR5-a5kh2NT7SQWnCCTs__eQswXlvilZqha8b-HVnuo7_Df6YA=s60-rw';
        insert AppRev;
        
        CC_ST_AppReviews__c appReview = [SELECT Id, App_Id__c, Review_ID__c, Author_Name__c, Developer_Comment__c, CC_Error_Publicacion__c 
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        String replyText = 'Respuesta prueba';
        String Store = 'BrokerNow';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        CC_ST_PlayStoreReviewsCtrl.Respuesta_automatica(Store, appReview.Review_ID__c, c2.Id, sp.Id,appReview.Author_Name__c, appReview.App_Id__c, c2.CC_Idioma__c);
        Test.stopTest();
        CC_ST_AppReviews__c appReviewv2 = [SELECT Id, App_Id__c, Review_ID__c, Developer_Comment__c, CC_Error_Publicacion__c
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        
        System.assertNotEquals(appReview, appReviewv2, 'La respuesta al comentario ha fallado.');
        //system.assertNotEquals(null, LReview);
    }
    @isTest
    static void insertReviews() {
        Id recordTem = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id recordProd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        Id recordMot = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c =  'TE-'+ String.valueOf(System.currentTimeMillis());
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
        //// CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c ='PR-' + String.valueOf(System.currentTimeMillis());
        mcc1.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-' + String.valueOf(System.currentTimeMillis());
        mcc2.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc2;  
		//CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
       Case c1 = new Case();
        c1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = mcc2.Id;
		c1.CC_MCC_ProdServ__c = mcc1.Id;
        c1.CC_MCC_Tematica__c = mcc.Id;
        insert c1;
        
        Case c2 = [SELECT Id, CC_Idioma__c FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
        SocialPost post = new SocialPost();
       	post.Name = 'Mejorable';
        post.Content = 'Se echan de menos los menús más sencillos e inmediatos de la web.Se tarda más en repetir una transferencia vía app que via web. Lento y confuso. Si vuelves a entrar al poco te recuerda que ha caducado la sesión y debes iniciarla manualmente. Lento. Y esto ya no es cosa de la app, es cosa de La Caixa, que oferta alojamientos, vehículos y toda clase de paja. Esto es un banco o El Corte Inglés?';
        post.Posted = system.now();
        post.Provider = 'Other';
        post.MessageType = 'Comment';
        post.Handle = 'DeCe79';
        post.IsOutBound = false;
        post.ParentId = c2.Id;
        insert post;
        
        SocialPost sp = [SELECT Id FROM SocialPost WHERE Name = 'Mejorable' LIMIT 1];
        
        CC_ST_AppReviews__c AppRev = new CC_ST_AppReviews__c();
        //AppRev.Name = 'A-01157';
        AppRev.Author_Name__c = 'kiona sanchez';
        AppRev.Title__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder';
        AppRev.Content__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder pagar y no estaba segura de hacer otra targeta, así que mi valoración es de 1 estrella por que no es práctica.';
        AppRev.Case__c = c1.Id;
        AppRev.Rating__c = '1';
        AppRev.App__c = 'Caixabank Pay';
        AppRev.Source__c = 'Google Play Store';
        AppRev.Review_ID__c = 'gp:AOqpTOG_KD8CPLfOgLbq_L4YkcH4WWJA5mnl8CTNy-8VldkSgKEU-NJQKv-aCS4Y3C00f4VsvAvDRZ4ZMFRAN';
        AppRev.Developer_Comment__c = '';
        AppRev.App_Id__c = 'es.lacaixa.hceicon2';
        AppRev.SocialPost__c = sp.Id;
        AppRev.App_Image__c = 'https://lh3.googleusercontent.com/_X2aK6fswJhaHZmsGCsR5-a5kh2NT7SQWnCCTs__eQswXlvilZqha8b-HVnuo7_Df6YA=s60-rw';
        insert AppRev;

        CC_ST_AppReviews__c appReview = [SELECT Id, App_Id__c, Review_ID__c, Author_Name__c 
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        
        List<CC_ST_AppReviews__c> ListAppRev = new List<CC_ST_AppReviews__c>();
        List<CC_ST_AppReviews__c> lstReviews = [SELECT Id, App_Id__c, Review_ID__c, Author_Name__c 
                                      FROM CC_ST_AppReviews__c ORDER BY CreatedDate DESC LIMIT 10];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseExito());
        ListAppRev = CC_ST_PlayStoreReviewsCtrl.insertReviews(appReview.App_Id__c, 'es', true);
        Test.stopTest();
        
        
        System.assertNotEquals(lstReviews.size(), 0, 'La inserción de comentarios ha fallado.');
    }
    @isTest
    static void replyReviewAutoDos() {
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];

        List<User> userList = new List<User>();
        User usuario2 = new User();
        usuario2.ProfileId = profileId;
        usuario2.UserRoleId = rolId.Id;
        usuario2.FirstName = 'first2';
        usuario2.LastName = 'last2';
        usuario2.Email = 'tuser000@amamama.com';
        usuario2.Username = 'tuser002@amamama.com' + System.currentTimeMillis();
        usuario2.CompanyName = 'DXC';
        usuario2.Title = 'title';
        usuario2.Alias = 'alias';
        usuario2.TimeZoneSidKey = 'Europe/Paris';
        usuario2.EmailEncodingKey = 'UTF-8';
        usuario2.LanguageLocaleKey = 'es';
        usuario2.LocaleSidKey = 'es_ES';
        userList.add(usuario2);
        insert userList;

        insert new PermissionSetAssignment(AssigneeId = usuario2.Id, PermissionSetId = ps.Id);
        
        System.runAs(usuario2){
            
        Id recordTem = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Tematica');
        Id recordProd = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Producto_Servicio');
        Id recordMot = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('CC_MCC__c', 'CC_Motivo');
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-'+ String.valueOf(System.currentTimeMillis());
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
       // CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-' + String.valueOf(System.currentTimeMillis());
        mcc1.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-' + String.valueOf(System.currentTimeMillis());
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc2;  
		//CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
             
       Case c1 = new Case();
        c1.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Case', 'CC_Cliente');
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = mcc2.Id;
		c1.CC_MCC_ProdServ__c = mcc1.Id;
        c1.CC_MCC_Tematica__c = mcc.Id;
        insert c1;
        
        //Case c2 = [SELECT Id FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
        CC_ST_AppReviews__c AppRev = new CC_ST_AppReviews__c();
        //AppRev.Name = 'A-01157';
        AppRev.Author_Name__c = 'kiona sanchez';
        AppRev.Title__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder';
        AppRev.Content__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder pagar y no estaba segura de hacer otra targeta, así que mi valoración es de 1 estrella por que no es práctica.';
        AppRev.Case__c = c1.Id;
        AppRev.Rating__c = '1';
        AppRev.App__c = 'Caixabank Pay';
        AppRev.Source__c = 'Google Play Store';
        AppRev.Review_ID__c = 'gp:AOqpTOG_KD8CPLfOgLbq_L4YkcH4WWJA5mnl8CTNy-8VldkSgKEU-NJQKv-aCS4Y3C00f4VsvAvDRZ4ZMFRAN';
        AppRev.Developer_Comment__c = '';
        AppRev.App_Id__c = 'es.lacaixa.hceicon2';
        AppRev.App_Image__c = 'https://lh3.googleusercontent.com/_X2aK6fswJhaHZmsGCsR5-a5kh2NT7SQWnCCTs__eQswXlvilZqha8b-HVnuo7_Df6YA=s60-rw';
        insert AppRev;
        
        CC_ST_AppReviews__c appReview = [SELECT Id, App_Id__c, Review_ID__c, Developer_Comment__c, CC_Error_Publicacion__c
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        String replyText = 'Respuesta prueba para probar las "dobles comillas"';

        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseExitoDos());
        CC_ST_PlayStoreReviewsCtrl.replyReview(appReview.App_Id__c, appReview.Review_ID__c, replyText);
		CC_ST_PlayStoreReviewsCtrl.replyReviewAuto(appReview.App_Id__c, appReview.Review_ID__c, replyText);
        Test.stopTest();
        
        CC_ST_AppReviews__c appReviewv2 = [SELECT Id, App_Id__c, Review_ID__c, Developer_Comment__c, CC_Error_Publicacion__c
                                      FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'kiona sanchez' LIMIT 1];
        
        System.assertNotEquals(appReview, appReviewv2, 'La respuesta al comentario ha fallado.');
        //system.assertNotEquals(null, LReview);
            }
    }
}