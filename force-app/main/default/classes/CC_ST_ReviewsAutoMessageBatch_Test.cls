@isTest
public class CC_ST_ReviewsAutoMessageBatch_Test {
	 
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
             
        Case c1 = new Case();
        c1.Subject = 'Prueba';
        c1.CC_Idioma__c = 'es';
        c1.CC_NumPerso__c = '123456';
        c1.CC_Tipo_Cliente__c = 'Cliente';
        c1.Status = 'Activo';
        c1.CC_Cierre_Automatico__c = true;
        c1.CC_Control_ComApps__c = false;
        c1.CC_Primer_DM_Enviado__c = false;
        c1.Origin = 'Comentarios Stores';
		c1.CC_Tipo_Contacto__c = 'Consulta';
        c1.CC_Canal_Procedencia__c = 'Google Play Store';
        c1.CC_MCC_Motivo__c = motiv.Id;
		c1.CC_MCC_ProdServ__c = prod.Id;
        c1.CC_MCC_Tematica__c = tem.Id;
        insert c1;
        
        Case c2 = [SELECT Id FROM Case WHERE Subject = 'Prueba' LIMIT 1];
        
        CC_ST_AppReviews__c AppRev = new CC_ST_AppReviews__c();
        //AppRev.Name = 'A-01157';
        AppRev.Author_Name__c = 'kiona sanchez';
        AppRev.Title__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder';
        AppRev.Content__c = 'la he descargado y no es muy intuitiva , no salía ninguna targeta predeterminada con la que poder pagar y no estaba segura de hacer otra targeta, así que mi valoración es de 1 estrella por que no es práctica.';
        AppRev.Case__c = c2.Id;
        AppRev.Rating__c = '1';
        AppRev.App__c = 'Caixabank Pay';
        AppRev.Source__c = 'Google Play Store';
        AppRev.Review_ID__c = 'gp:AOqpTOG_KD8CPLfOgLbq_L4YkcH4WWJA5mnl8CTNy-8VldkSgKEU-NJQKv-aCS4Y3C00f4VsvAvDRZ4ZMFRAN';
        AppRev.Developer_Comment__c = '';
        AppRev.App_Id__c = 'es.lacaixa.hceicon2';
        AppRev.App_Image__c = 'https://lh3.googleusercontent.com/_X2aK6fswJhaHZmsGCsR5-a5kh2NT7SQWnCCTs__eQswXlvilZqha8b-HVnuo7_Df6YA=s60-rw';
        insert AppRev;
        
        Test.StartTest();
        CC_ST_ReviewsAutoMessageBatch batch = new CC_ST_ReviewsAutoMessageBatch();
		Database.executeBatch(batch);
        Test.stopTest();
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
        caso.CC_Cierre_Automatico__c = true;
		insert caso;
        
        comentario.Case__c = caso.Id;
        update comentario;
        
        Test.StartTest();
        CC_ST_ReviewsAutoMessageBatch batch = new CC_ST_ReviewsAutoMessageBatch();
		Database.executeBatch(batch);
        Test.stopTest();
        
        Case casoUpdate = [Select CC_Admin__c, CC_Primer_DM_Enviado__c from Case where Id = :caso.Id limit 1];
 
        system.assertEquals(true, casoUpdate.CC_Admin__c, 'Comprobamos el valor del caso actualizado.');
        system.assertEquals(true, casoUpdate.CC_Primer_DM_Enviado__c, 'Comprobamos el valor del caso actualizado.');

    }
    
}