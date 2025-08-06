@isTest
public with sharing class CC_SocialPost_Respuestas_Test {
    @isTest
 	static void CC_SocialPost_Reclamacion_RespuestaAct() {
        List<Id> tweetList1 = new List<Id>();
        List<Id> tweetList2 = new List<Id>();
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'Ahorro';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        insert mcc;
        //CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='Ahorro' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'Cuentas';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        mcc1.CC_Tematica__c = mcc.Id;
        insert mcc1;
        //CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='Cuentas' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Conjunta';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;
		//CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Conjunta' LIMIT 1];
        
        Account cuenta = new Account();
        cuenta.Name = 'Cuenta01';
        insert cuenta;        
        
        Id accountId = cuenta.Id;
        
        Id RecordTypeCliente = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Contacto';
        contacto.LastName = '01';
        contacto.CC_NumPerso__c = '12345569';
        contacto.AccountId = cuenta.Id;
        contacto.CC_Idioma__c = 'Es';
        contacto.RecordTypeId = RecordTypeCliente;
        insert contacto;        
        Id cId = contacto.Id;
        
        Case caso1 = new Case(
            Status = 'Pendiente Cliente',
            CC_Idioma__c = 'es',
        	CC_Tipo_Cliente__c = 'Cliente',
            ContactId = cId,
        	Origin = 'Twitter',
			CC_Tipo_Contacto__c = 'Consulta',
        	CC_Canal_Procedencia__c = 'CaixaBank',
        	CC_MCC_Motivo__c = mcc2.Id,
        	CC_MCC_ProdServ__c = mcc1.Id,
            CC_MCC_Tematica__c = mcc.Id,
         	CC_Detalles_Consulta__c = 'Detalle consulta');
        insert caso1;
        SocialPost socialPost1 = new SocialPost(
            Name = 'Name',
            ParentId = caso1.Id,
            Provider = 'Twitter');
        insert socialPost1;
        SocialPost socialPostReply1 = new SocialPost(
            Name = 'Name',
            ReplyToId = socialPost1.Id,
            ParentId = caso1.Id,
            Provider = 'Twitter',
            MessageType = 'Reply',
            CC_Respuesta_Reclamada__c = true,
            Handle = 'companydemo001');
        insert socialPostReply1;
        SocialPersona persona = New SocialPersona();
        persona.Name = 'oscar';
        persona.RealName = 'Oscar';
        persona.Provider='Other';
        persona.ParentId = socialPost1.Id;
        insert persona;
              
        Case casoSelect1 = [select status from case where id = :caso1.id];
        casoSelect1.status = 'Pendiente Cliente';
        casoSelect1.CC_Social_Persona__c = persona.Id;
        update casoSelect1;

        tweetList1.add(socialPostReply1.Id);
        
        Test.StartTest();
        CC_SocialPost_Respuestas.CC_SocialPost_Reclamacion_Respuesta(tweetList1);
        Case casoResult1 = [select status from case where id = :caso1.id];
        System.assertEquals('Cerrado', casoResult1.status);
        
        SocialPost socialPostResult = [select CC_Respuesta_Reclamada__c from SocialPost where id = :socialPostReply1.id];
        System.assert(socialPostResult.CC_Respuesta_Reclamada__c == true);
        Test.stopTest();
    }
    @isTest
    static void CC_SocialPost_Reclamacion_RespuestaCerr() {
        List<Id> tweetList1 = new List<Id>();
        List<Id> tweetList2 = new List<Id>();
        
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'Ahorro';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        insert mcc;
        //CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='Ahorro' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'Cuentas';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        mcc1.CC_Tematica__c = mcc.Id;
        insert mcc1;
        //CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='Cuentas' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Conjunta';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;
		//CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Conjunta' LIMIT 1];
        
        Case caso2 = new Case(
            Status = 'Pendiente Cliente',
            CC_Idioma__c = 'es',
        	CC_Tipo_Cliente__c = 'Cliente',
        	Origin = 'Twitter',
			CC_Tipo_Contacto__c = 'Consulta',
        	CC_Canal_Procedencia__c = 'ImaginBank',
        	CC_MCC_Motivo__c = mcc2.Id,
        	CC_MCC_ProdServ__c = mcc1.Id,
            CC_MCC_Tematica__c = mcc.Id);
        insert caso2;
        SocialPost socialPost2 = new SocialPost(
            Name = 'Name',
            ParentId = caso2.Id,
            Provider = 'Twitter');
        insert socialPost2;
        SocialPost socialPostReply2 = new SocialPost(
            Name = 'Name',
            ReplyToId = socialPost2.Id,
            ParentId = caso2.Id,
            Provider = 'Twitter',
            MessageType = 'Reply',
            CC_Respuesta_Reclamada__c = false,
            Handle = 'companydemo001');
        insert socialPostReply2;
        
        Case casoSelect2 = [select status from case where id = :caso2.id];
        casoSelect2.status = 'Pendiente Cliente';
        update casoSelect2;

        tweetList2.add(socialPostReply2.Id);

        Test.StartTest();
        CC_SocialPost_Respuestas.CC_SocialPost_Reclamacion_Respuesta(tweetList2);
        Case casoResult2 = [select status from case where id = :caso2.id];
        System.assert(casoResult2.status == 'Activo');
        SocialPost socialPostResult = [select CC_Respuesta_Reclamada__c from SocialPost where id = :socialPostReply2.id];
        System.assert(socialPostResult.CC_Respuesta_Reclamada__c == true);
        Test.stopTest();
    }
}