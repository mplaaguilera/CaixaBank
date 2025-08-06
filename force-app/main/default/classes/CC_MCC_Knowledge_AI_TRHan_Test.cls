@isTest
public class CC_MCC_Knowledge_AI_TRHan_Test {

    @isTest
    public static void testAI(){
        Account cuenta = new Account();
        cuenta.Name = 'PRUEBA TEST Cristina';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        insert cuenta;

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        User usuario = new User(
            Alias = 'TEST',
            Email = 'testpruebamcc@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'testLastName',
            LanguageLocaleKey = 'es',
            LocaleSidKey = 'es',
            TimeZoneSidKey = 'Europe/Berlin',
            UserName = 'Testpruebamcc@test.com',
            ProfileId = profileId
        );
        insert usuario;
        
        Contact contacto = new Contact();
        contacto.FirstName = 'Cris';
        contacto.LastName = 'Prueba';
        contacto.Email = 'mp@test.com';
        contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contacto.AccountId = cuenta.Id;
		insert contacto;
        
        Datetime fecha = Datetime.now();
        Datetime fechaInicio = fecha.addHours(2);
        Datetime fechaCaducidad = fecha.addHours(10);

        Knowledge__kav articulo = new Knowledge__kav(); 
        articulo.URLName = 'Apex-Test' + System.now().getTime();
        articulo.Title = 'Articulo test cris';
        articulo.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
        articulo.CC_Fecha_Caducidad__c = fechaCaducidad;
        articulo.CC_Responsable_Externo__c = contacto.Id;
        articulo.ValidationStatus = 'Validado';
        insert articulo; 
        articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c 
                    FROM Knowledge__kav WHERE Title = 'Articulo test cris'];
        Id idArticulo = articulo.Id;
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
                                            FROM KnowledgeArticleVersion WHERE Id =: idArticulo]);

        CC_MCC__c mccTematica = new CC_MCC__c();
        Id recordTypeIdTematica = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.RecordTypeId = recordTypeIdTematica;
        mccTematica.Name = 'Tematica Test AI';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Codigo_Externo__c = 'TE-000789';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = fecha;
        mccTematica.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica;
        
        CC_MCC__c mccProducto = new CC_MCC__c();
        Id recordTypeIdProducto = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Producto_Servicio').getRecordTypeId();
        mccProducto.RecordTypeId = recordTypeIdProducto;
        mccProducto.Name = 'Producto Test AI';
        mccProducto.CC_Tipo_Cliente__c = 'Cliente';
        mccProducto.CC_Codigo_Externo__c = 'PR-000789';
        mccProducto.CC_Fecha_Vigencia_Inicio__c = fecha;
        insert mccProducto;

        CC_MCC__c mccMotivo = new CC_MCC__c();
        Id recordTypeIdMotivo = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Motivo').getRecordTypeId();
        mccMotivo.RecordTypeId = recordTypeIdMotivo;
        mccMotivo.Name = 'Motivo Test AI';
        mccMotivo.CC_Tipo_Cliente__c = 'Cliente';
        mccMotivo.CC_Codigo_Externo__c = 'MO-000789';
        mccMotivo.CC_Fecha_Vigencia_Inicio__c = fecha;
        insert mccMotivo;

        CC_MCC__c mccCausa = new CC_MCC__c();
        Id recordTypeIdCausa = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Causa').getRecordTypeId();
        mccCausa.RecordTypeId = recordTypeIdCausa;
        mccCausa.Name = 'Causa Test AI';
        mccCausa.CC_Tipo_Cliente__c = 'Cliente';
        mccCausa.CC_Codigo_Externo__c = 'CA-000789';
        mccCausa.CC_Fecha_Vigencia_Inicio__c = fecha;
        insert mccCausa;

        Test.startTest();
        List<CBK_MCC_Knowledge__c> relaciones = new List<CBK_MCC_Knowledge__c>();
        CBK_MCC_Knowledge__c relacionTematica = new CBK_MCC_Knowledge__c();
        CBK_MCC_Knowledge__c relacionProducto = new CBK_MCC_Knowledge__c();
        CBK_MCC_Knowledge__c relacionMotivo = new CBK_MCC_Knowledge__c();
        CBK_MCC_Knowledge__c relacionCausa = new CBK_MCC_Knowledge__c();
        insert relacionTematica;
        insert relacionProducto;
        insert relacionMotivo;
        insert relacionCausa;
        CC_MCC_Knowledge_AI_TRHan.publishArticle((String)obtenidoIdQuery.get(idArticulo).KnowledgeArticleId);
        relacionTematica.OwnerId = usuario.Id;
        relacionTematica.CBK_MCC__c = mccTematica.Id;
        relacionTematica.CBK_Knowledge__c = articulo.Id;      
        relaciones.add(relacionTematica);
        CC_MCC_Knowledge_AI_TRHan.process(relaciones);

        relaciones.clear();
        relacionProducto.OwnerId = usuario.Id;
        relacionProducto.CBK_MCC__c = mccProducto.Id;
        relacionProducto.CBK_Knowledge__c = articulo.Id;
        relaciones.add(relacionProducto);
        CC_MCC_Knowledge_AI_TRHan.process(relaciones);

        relaciones.clear();
        relacionMotivo.OwnerId = usuario.Id;
        relacionMotivo.CBK_MCC__c = mccMotivo.Id;
        relacionMotivo.CBK_Knowledge__c = articulo.Id;
        relaciones.add(relacionMotivo);
        CC_MCC_Knowledge_AI_TRHan.process(relaciones);


        relacionMotivo.OwnerId = usuario.Id;
        relacionMotivo.CBK_MCC__c = mccMotivo.Id;
        relacionMotivo.CBK_Knowledge__c = articulo.Id;
        relaciones.add(relacionMotivo);
        CC_MCC_Knowledge_AI_TRHan.process(relaciones);

        relaciones.clear();
        relacionCausa.OwnerId = usuario.Id;
        relacionCausa.CBK_MCC__c = mccCausa.Id;
        relacionCausa.CBK_Knowledge__c = articulo.Id;
        relaciones.add(relacionCausa);
        CC_MCC_Knowledge_AI_TRHan.process(relaciones);
        Test.stopTest();


        articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c, PublishStatus 
        FROM Knowledge__kav WHERE Title = 'Articulo test cris'];

        //Comprobaciones para saber si se ha creado bien
        System.assertEquals('TE-000789 -', articulo.CBK_Codigo_Externo_Tematica__c, 'El código externo de temática no se ha guardado correctamente');
        System.assertEquals('Online', articulo.PublishStatus, 'El artículo no se publica');
        
    }
}