@IsTest
public with sharing class CC_SocialPost_Methods_Test {
    
    static testMethod void CC_SocialPost_MethodsSalidaTest() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        
        CC_Lista_Valores__c valores = new CC_Lista_Valores__c();
        valores.name = 'Plazo Genérico';
        valores.CC_Valor__c = '74';
        insert valores;
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'Ahorro';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
        //CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='Ahorro' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'Cuentas';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='Cuentas' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Conjunta';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;
        
		CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Conjunta' LIMIT 1];
        
        Case caso1 = new Case();
        caso1.CC_Motivo__c = 'Twitter';
        caso1.Subject = 'Prueba1';
        caso1.Status = 'Pendiente Cliente';
		caso1.CC_Idioma__c = 'es';
        caso1.CC_Tipo_Cliente__c = 'Cliente';
        caso1.Origin = 'Twitter';
		caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Procedencia__c = 'ImaginBank';
        caso1.CC_MCC_Motivo__c = mcc2.Id;
        caso1.CC_MCC_ProdServ__c = mcc1.Id;
        caso1.CC_MCC_Tematica__c = mcc.Id;
        insert caso1;
        
        Case caso = [SELECT Id FROM CASE LIMIT 1];
        
		List<SocialPost> sp = new List<SocialPost>{
            new SocialPost(name='SP1', ParentId=caso.Id)
            };                                        
        insert sp;
    
        // Queries to get the inserted accounts 
        SocialPost masterSP = [SELECT Id, Name FROM SocialPost WHERE Name = 'SP1' LIMIT 1];
        DateTime fecha = Datetime.now();
        List<SocialPost> sp2 = new List<SocialPost>{
            new SocialPost(name='SP2', IsOutbound=true, Posted=fecha, ReplyToId=masterSP.Id, ParentId=caso.Id)
            };                                        
        insert sp2;
                
        SocialPost childSP = [SELECT Id, Name FROM SocialPost WHERE Name = 'SP2' LIMIT 1];
        List<ID> ListSP = new List<ID>();
        ListSP.add(childSP.Id);
        
        CC_SocialPost_Methods.CC_SocialPost_Methods(ListSP);
		
        Case masterSPAssert = [SELECT Id, CC_Fecha_1a_Respuesta_Twitter__c FROM Case WHERE Subject = 'Prueba1' LIMIT 1];
        System.assertEquals(fecha, masterSPAssert.CC_Fecha_1a_Respuesta_Twitter__c);
    }

    static testMethod void CC_SocialPost_MethodsSalidaTest2() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        
        CC_Lista_Valores__c valores = new CC_Lista_Valores__c();
        valores.name = 'Plazo Genérico';
        valores.CC_Valor__c = '74';
        insert valores;
        
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'Ahorro';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
        //CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='Ahorro' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'Cuentas';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
        insert mcc1;
        //CC_MCC__c prod = [SELECT Id FROM CC_MCC__c WHERE Name='Cuentas' LIMIT 1];
        CC_MCC__c mcc2 = new CC_MCC__c();
        mcc2.RecordTypeId = recordMot;
        mcc2.Name = 'Conjunta';
        mcc2.CC_Tipo_Cliente__c = 'Cliente';
        mcc2.CC_Producto_Servicio__c = mcc1.Id;
        mcc2.CC_Codigo_Externo__c = 'MO-000001';
        insert mcc2;
        
		CC_MCC__c motiv = [SELECT Id FROM CC_MCC__c WHERE Name='Conjunta' LIMIT 1];
        
        Case caso1 = new Case();
        caso1.CC_Motivo__c = 'Twitter';
        caso1.Subject = 'Prueba1';
        caso1.Status = 'Pendiente Cliente';
		caso1.CC_Idioma__c = 'es';
        caso1.CC_Tipo_Cliente__c = 'Cliente';
        caso1.Origin = 'Twitter';
		caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Procedencia__c = 'ImaginBank';
        caso1.CC_MCC_Motivo__c = mcc2.Id;
        caso1.CC_MCC_ProdServ__c = mcc1.Id;
        caso1.CC_MCC_Tematica__c = mcc.Id;
        insert caso1;
        
        Case caso = [SELECT Id FROM CASE LIMIT 1];
        
		List<SocialPost> sp = new List<SocialPost>{
            new SocialPost(name='SP1', ParentId=caso.Id, CC_Solicitud_Informacion__c = true)
            };                                        
        insert sp;
    
        // Queries to get the inserted accounts 
        SocialPost masterSP = [SELECT Id, Name, CC_Solicitud_Informacion__c FROM SocialPost WHERE Name = 'SP1' LIMIT 1];
        DateTime fecha = Datetime.now();
        List<SocialPost> sp2 = new List<SocialPost>{
            new SocialPost(name='SP2', IsOutbound=true, Posted=fecha, ReplyToId=masterSP.Id, ParentId=caso.Id, CC_Solicitud_Informacion__c = true)
            };                                        
        insert sp2;
                
        SocialPost childSP = [SELECT Id, Name FROM SocialPost WHERE Name = 'SP2' LIMIT 1];
        List<ID> ListSP = new List<ID>();
        ListSP.add(childSP.Id);
        
        CC_SocialPost_Methods.CC_SocialPost_Methods(ListSP);
		
        Case masterSPAssert = [SELECT Id, CC_Fecha_1a_Respuesta_Twitter__c FROM Case WHERE Subject = 'Prueba1' LIMIT 1];
        System.assertEquals(fecha, masterSPAssert.CC_Fecha_1a_Respuesta_Twitter__c);
    }
    
    static testMethod void CC_SocialPost_MethodsEntranteTest() {
        Id recordTem = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        Id recordProd = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        Id recordMot = Schema.SObjectType.CC_MCC__c.getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
                
        CC_MCC__c mcc = new CC_MCC__c();
        mcc.RecordTypeId = recordTem;
        mcc.Name = 'Ahorro';
        mcc.CC_Tipo_Cliente__c = 'Cliente';
        mcc.CC_Codigo_Externo__c = 'TE-000001';
        mcc.CC_Canal_Operativo__c = 'App BrokerNow';
        insert mcc;
        //CC_MCC__c tem = [SELECT Id FROM CC_MCC__c WHERE Name='Ahorro' LIMIT 1];
        CC_MCC__c mcc1 = new CC_MCC__c();
        mcc1.RecordTypeId = recordProd;
        mcc1.Name = 'Cuentas';
        mcc1.CC_Tipo_Cliente__c = 'Cliente';
        mcc1.CC_Tematica__c = mcc.Id;
        mcc1.CC_Codigo_Externo__c = 'PR-000001';
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
        
        Case caso1 = new Case();
        caso1.CC_Motivo__c = 'Twitter';
        caso1.Subject = 'Prueba1';
        caso1.Status = 'Pendiente Cliente';
		caso1.CC_Idioma__c = 'es';
        caso1.CC_Tipo_Cliente__c = 'Cliente';
        caso1.Origin = 'Twitter';
		caso1.CC_Tipo_Contacto__c = 'Consulta';
        caso1.CC_Canal_Procedencia__c = 'ImaginBank';
        caso1.CC_MCC_Motivo__c = mcc2.Id;
        caso1.CC_MCC_ProdServ__c = mcc1.Id;
        caso1.CC_MCC_Tematica__c = mcc.Id;
        insert caso1;
        Case caso = [SELECT Id FROM CASE LIMIT 1];
        
		List<SocialPost> sp = new List<SocialPost>{
            new SocialPost(name='SP1', ParentId=caso.Id, ReplyToId = null, HarvestDate = Datetime.valueOf(System.now()))
            };                                        
        insert sp;
                
        SocialPost childSP = [SELECT Id, Name FROM SocialPost WHERE Name = 'SP1' LIMIT 1];
        List<ID> ListSP = new List<ID>();
        ListSP.add(childSP.Id);
        
        CC_SocialPost_Methods.CC_SocialPost_Methods(ListSP);
		
        Case masterSPAssert = [SELECT Id, CC_Fecha_Twitter_Entrante__c FROM Case WHERE Subject = 'Prueba1' LIMIT 1];
        System.assertNotEquals(null, masterSPAssert.CC_Fecha_Twitter_Entrante__c);
    }
}