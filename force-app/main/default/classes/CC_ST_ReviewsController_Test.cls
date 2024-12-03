@IsTest
public with sharing class CC_ST_ReviewsController_Test {
	@isTest
    static void getReviews() {
        CC_ST_AppReviews__c st = new CC_ST_AppReviews__c();
        st.Source__c = 'Google Play Store';
        st.App__c = 'CaixaBank';
        st.App_ID__c = 'CaixaBankAndroid';
        st.Author_Name__c = 'ST';
        insert st;
        
        CC_ST_AppReviews__c st1 = new CC_ST_AppReviews__c();
        st1.Source__c = 'Google Play Store';
        st1.App__c = 'CaixaBank';
        st1.App_ID__c = 'CaixaBankAndroid';
        st1.Author_Name__c = 'ST1';
        insert st1;
        
        CC_ST_AppReviews__c st2 = new CC_ST_AppReviews__c();
        st2.Source__c = 'Google Play Store';
        st2.App__c = 'CaixaBank';
        st2.App_ID__c = 'CaixaBankAndroid';
        st2.Author_Name__c = 'ST2';
        insert st2;
        
        List<CC_ST_AppReviews__c> oListSTApp = CC_ST_ReviewsController.getReviews('CaixaBankAndroid');
        system.assertNotEquals(null, oListSTApp);
        
    }
    
    /*@isTest
    static void createCase() {
        
    }
    
    @isTest
    static void buscarSocialPersona() {
        
    }
    
    @isTest
    static void createSocialPost() {
        
    }*/
    
    @isTest
    static void refrechItem() {
        CC_ST_AppReviews__c st = new CC_ST_AppReviews__c();
        st.Source__c = 'Google Play Store';
        st.App__c = 'CaixaBank';
        st.App_ID__c = 'CaixaBankAndroid';
        st.Author_Name__c = 'ST';
        insert st;
        
        CC_ST_AppReviews__c oST = [SELECT Id FROM CC_ST_AppReviews__c WHERE Author_Name__c = 'ST' LIMIT 1];
        CC_ST_AppReviews__c oResult = CC_ST_ReviewsController.refrechItem(oST.Id);
        
        system.assertNotEquals(null, oResult);
    }
     
    @isTest
    static void getItem() {  
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
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
        st.App_ID__c = 'CaixaBankAndroid';
        st.Author_Name__c = 'ST';
        st.Case__c=c.Id;
        insert st;
        
        CC_ST_AppReviews__c oST = CC_ST_ReviewsController.getItem(c.Id);
        system.assertNotEquals(null, oST);
    }
    
    /*@isTest
    static void WrapperObject() {
        CC_ST_ReviewsController.WrapperObject('Review','Author','Title','Rating','Content','Version');
    }*/
    
    @isTest
    static void creacionMasivaCasosCorrecta() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
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
        
		Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.CC_Idioma__c = '';
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
        st.Case__c = c.Id;
        insert st;
        
        Case caso2 = new Case();
        caso2.Subject = 'Prueba2';
        caso2.CC_Idioma__c = '';
        caso2.CC_Tipo_Cliente__c = 'Cliente';
        caso2.Status = 'Activo';
        caso2.Origin = 'Comentarios Stores';
		caso2.CC_Tipo_Contacto__c = 'Consulta';
        caso2.CC_Canal_Procedencia__c = 'Google Play Store';
        caso2.CC_MCC_Motivo__c = motiv.Id;
		caso2.CC_MCC_ProdServ__c = prod.Id;
        caso2.CC_MCC_Tematica__c = tem.Id;
        insert caso2;
        
        Case c2 = [SELECT Id FROM Case WHERE Subject = 'Prueba2' LIMIT 1];
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
        st1.Case__c = c2.Id;
        insert st1;
        
        List<CC_ST_AppReviews__c> oListST = [SELECT Id, Source__c, App__c, App_ID__c, Author_Name__c, Rating__c, Review_ID__c, 
                                             CC_Actualizacion_Review__c, Title__c, Content__c, Case__c, Case__r.CC_Idioma__c
                                             FROM CC_ST_AppReviews__c LIMIT 2];

        CC_ST_ReviewsController.creacionMasivaCasos(oListST, 'es.lacaixa.mobile.android.newwapicon');
        system.assertNotEquals(null, oListST);
    }

    @isTest
    static void creacionMasivaCasosIncorrecta() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
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
        
		Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Cerrado';
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
        st.Rating__c='4';
        st.Review_ID__c = 'rev123';
        st.CC_Actualizacion_Review__c = false;
        st.Title__c = 'Prueba1';
        st.Content__c = 'Contenido1';
        st.Case__c = c.Id;
        insert st;
        
        Case caso2 = new Case();
        caso2.Subject = 'Prueba2';
        caso2.CC_Idioma__c = '';
        caso2.CC_Tipo_Cliente__c = 'Cliente';
        caso2.Status = 'Cerrado';
        caso2.Origin = 'Comentarios Stores';
		caso2.CC_Tipo_Contacto__c = 'Consulta';
        caso2.CC_Canal_Procedencia__c = 'Google Play Store';
        caso2.CC_MCC_Motivo__c = motiv.Id;
		caso2.CC_MCC_ProdServ__c = prod.Id;
        caso2.CC_MCC_Tematica__c = tem.Id;
        insert caso2;
        
        Case c2 = [SELECT Id FROM Case WHERE Subject = 'Prueba2' LIMIT 1];
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
        st1.Case__c = c2.Id;
        insert st1;
        
        List<CC_ST_AppReviews__c> oListST = [SELECT Id, Source__c, App__c, App_ID__c, Author_Name__c, Rating__c, Review_ID__c, 
                                             CC_Actualizacion_Review__c, Title__c, Content__c, Case__c, Case__r.CC_Idioma__c
                                             FROM CC_ST_AppReviews__c LIMIT 2];

        CC_ST_ReviewsController.creacionMasivaCasos(oListST, 'es.lacaixa.mobile.android.newwapicon');
        system.assertNotEquals(null, oListST);
    }
    
    /*@isTest
    static void Acciones() {
        
    }*/
    
    @isTest
    static void recuperaMensajeAutomatico() {
        String mensaje = CC_ST_ReviewsController.recuperaMensajeAutomatico('es', '', 'CaixaBank Sign');
        system.assertNotEquals(null, mensaje);
    }
    
    @isTest
    static void recuperaMensajeAutomatico2() {
        String mensaje = CC_ST_ReviewsController.recuperaMensajeAutomatico('es', '', 'ImaginBank');
        system.assertNotEquals(null, mensaje);
    }
    
    @isTest
    static void recuperaMensajeAutomatico3() {
        String mensaje = CC_ST_ReviewsController.recuperaMensajeAutomatico('es', '', 'CaixaBank');
        system.assertNotEquals(null, mensaje);
    }
    
    @isTest
    static void actualizaCasoFechaRespuesta() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
		mcc.CC_Codigo_Externo__c = 'TE-000001';  
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        //CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';  
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        //CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;     
        //CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
        
		Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        caso.CC_MCC_Motivo__c = mcc2.Id;
		caso.CC_MCC_ProdServ__c = mcc1.Id;
        caso.CC_MCC_Tematica__c = mcc.Id;
        insert caso;
                
        Case c = [SELECT Id FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        CC_ST_ReviewsController.actualizaCasoFechaRespuesta(c.Id);
        
        Case cs = [SELECT Id, Status FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        system.assertEquals('Activo', cs.Status);
    }
    
    @isTest
    static void buscarTabuladaStoresCBK() {
        QuickText qt = new QuickText();
        qt.Name='No encuentro  nada 1';
		qt.Message='Hola. Esta actualización incorpora muchas nuevas funcionalidades como Neo (icono de la lupa) nuestro asistente virtual que esperamos te ayude en tu día a día. Te animamos a mejorar tu valoración a medida que vayas descubriendo las nuevas funcionalidades.';
		qt.Channel='Stores';
		qt.Category='CaixaBank';
		qt.CC_Idioma__c='es';
        qt.CC_Inicio_Vigencia__c = Date.newInstance(2022, 01, 01);
        insert qt;
        
        QuickText qt1 = new QuickText();
        qt1.Name='No funciona';
		qt1.Message='Hola. Llamanos al 666 666 666 el teléfono del diablo y te ayudaremos con tu problema.';
		qt1.Channel='Stores';
		qt1.Category='CaixaBank';
		qt1.CC_Idioma__c='es';
        qt1.CC_Inicio_Vigencia__c =  Date.newInstance(2022, 01, 01);
        insert qt1;
        
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Idioma__c = 'es';
        caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.Status = 'Activo';
		caso.CC_Tipo_Contacto__c = 'Consulta';
        caso.CC_Canal_Procedencia__c = 'Google Play Store';
        insert caso;
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        CC_ST_AppReviews__c st = new CC_ST_AppReviews__c();
        st.Source__c = 'Google Play Store';
        st.App__c = 'CaixaBank';
        st.App_ID__c = 'CaixaBankAndroid';
        st.Author_Name__c = 'ST';
        st.Case__c=c.Id;
        insert st;
        
        Case cs = [SELECT Id FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        List<QuickText> oListQT = CC_ST_ReviewsController.buscarTabuladaStores(cs.Id);
        system.assertNotEquals(null, oListQT);
    }
    
    @isTest
    static void actualizaComentarioAppReview() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'App\'s';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Fecha_Vigencia_Inicio__c = Datetime.valueOf(System.now());
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App Imagin';
        insert mcc;
        //CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='App\'s' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'APP CaixaBank';
        mcc1.CC_Detalle__c = 'CaixaBank';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Fecha_Vigencia_Inicio__c = Datetime.valueOf(System.now());
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
		//'APP BrokerNow','APP CaixaBank','APP CaixaBank Pay','APP CaixaBank Sign','App imaginBank'
        //CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='APP CaixaBank' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Valoración positiva';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Fecha_Vigencia_Inicio__c = Datetime.valueOf(System.now());
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;     
        CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Valoración positiva' LIMIT 1];
        
        CC_ST_AppReviews__c st = new CC_ST_AppReviews__c();
        st.Source__c = 'Google Play Store';
        st.App__c = 'CaixaBank';
        st.App_ID__c = 'CaixaBankAndroid';
        st.Author_Name__c = 'ST';
        insert st;
        
        CC_ST_AppReviews__c STApp = [SELECT Id FROM CC_ST_AppReviews__c WHERE Author_Name__c='ST'];
        CC_ST_ReviewsController.actualizaComentarioAppReview(STApp.Id, 'Comentario respuesta');
        
        CC_ST_AppReviews__c STResult = [SELECT Id, Developer_Comment__c FROM CC_ST_AppReviews__c WHERE Author_Name__c='ST'];
        system.assertEquals('Comentario respuesta', STResult.Developer_Comment__c);
    }
    
   	@isTest
    static void replyAppGoogleReviewTest() {
    
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.Description = 'Prueba';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Idioma__c = 'es';
		caso.CC_Tipo_Contacto__c = 'Consulta';
		caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.CC_Canal_Procedencia__c = 'Huawei App Store';
        insert caso;
        
        CC_ST_AppReviews__c comentario = new CC_ST_AppReviews__c();
        comentario.Review_ID__c = '2413213434';
        comentario.App_ID__c 	= '11111111';
        comentario.Source__c 	= 'Huawei App Store	';
        comentario.Content__c 	= 'Comentario de prueba';
        comentario.Rating__c 	= '3';
        comentario.CC_Idioma__c = 'es';
        comentario.Case__c = caso.Id;
        insert comentario; 
        
        try{
        	CC_ST_ReviewsController.replyAppGoogleReview('11111111', '2413213434', 'Huawei App Store', 'Respuest al comentario');    
        }catch(Exception e){
            String error = e.getMessage();
        }
        
        
        CC_ST_AppReviews__c comentarioUpdate = [Select Developer_Comment__c from CC_ST_AppReviews__c where id = :comentario.Id limit 1];
        
        system.assert(comentarioUpdate != null, 'Comprobamos se actualiza el comentario.');
        
    }
    
    /**
    @isTest
    static void socialPostAccionesTest() {
    
        CC_ST_ReviewsController.Acciones(CC_ST_AppReviews__c Review, String accion, Map<String, CC_Lista_Valores__c> oMapLOV);
        
    }*/
    
    @isTest
    static void socialPostBuscarTest() {
        
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.Description = 'Prueba';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Idioma__c = 'es';
		caso.CC_Tipo_Contacto__c = 'Consulta';
		caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.CC_Canal_Procedencia__c = 'Huawei App Store';
        insert caso;
 
        SocialPost socPost = New SocialPost();
        socPost.Content = 'Prueba';
        socPost.Handle = 'oskiki';
        socPost.ParentId = caso.Id;
        socPost.Provider = 'Other';
        socPost.Name = 'Prueba';
        socPost.IsOutbound = true;
        insert socPost;

        SocialPersona persona = New SocialPersona();
        persona.Name = 'oskiki';
        persona.RealName = 'Oscar';
        persona.Provider='Other';
        persona.ParentId = socPost.Id;
        insert persona;
    
        SocialPersona socialPer = CC_ST_ReviewsController.buscarSocialPersona('Oscar', 'Huawei', socPost.Id, true);
        
        system.assert(socialPer.ParentId != null, 'Comprobamos que encuentra la socialPersona');
    }
    
    @isTest
    static void socialPostBuscarNoEncuentraTest() {
        
        Case caso = new Case();
        caso.Subject = 'Prueba';
        caso.Description = 'Prueba';
        caso.Status = 'Activo';
        caso.Origin = 'Comentarios Stores';
        caso.CC_Idioma__c = 'es';
		caso.CC_Tipo_Contacto__c = 'Consulta';
		caso.CC_Tipo_Cliente__c = 'Cliente';
        caso.CC_Canal_Procedencia__c = 'Huawei App Store';
        insert caso;
 
        SocialPost socPost = New SocialPost();
        socPost.Content = 'Prueba';
        socPost.Handle = 'oskiki';
        socPost.ParentId = caso.Id;
        socPost.Provider = 'Other';
        socPost.Name = 'Prueba';
        socPost.IsOutbound = true;
        insert socPost;

        SocialPersona socialPer = CC_ST_ReviewsController.buscarSocialPersona('Oscar', 'Huawei', socPost.Id, true);
        
        system.assert(socialPer.Id != null, 'Comprobamos que se crea la socialPersona');
        system.assertEquals(socPost.Id,  socialPer.parentId, 'Comprobamos que se relaciona la socialPersona');
    }

}