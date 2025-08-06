@isTest
public class CC_MCC_Knowledge_AD_TRHan_Test {
    @isTest
    public static void testAD(){
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
        mccTematica.Name = 'Tematica Test AD';
        mccTematica.CC_Tipo_Cliente__c = 'Cliente';
        mccTematica.CC_Codigo_Externo__c = 'TE-000789';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = fecha;
        mccTematica.CC_Canal_Operativo__c = 'Sin canal';
        insert mccTematica;

        Test.startTest();
        List<CBK_MCC_Knowledge__c> relaciones = new List<CBK_MCC_Knowledge__c>();
        CBK_MCC_Knowledge__c relacionTematica = new CBK_MCC_Knowledge__c();
        insert relacionTematica;
        CC_MCC_Knowledge_AI_TRHan.publishArticle((String)obtenidoIdQuery.get(idArticulo).KnowledgeArticleId);
        relacionTematica.OwnerId = usuario.Id;
        relacionTematica.CBK_MCC__c = mccTematica.Id;
        relacionTematica.CBK_Knowledge__c = articulo.Id;
        relaciones.add(relacionTematica);
        CC_MCC_Knowledge_AI_TRHan.process(relaciones);
        delete relacionTematica;
        CC_MCC_Knowledge_AD_TRHan.process(relaciones);

        Test.stopTest();

        articulo = [SELECT Id, CBK_Codigo_Externo_Causa__c, CBK_Codigo_Externo_Motivo__c, CBK_Codigo_Externo_Producto__c, CBK_Codigo_Externo_Tematica__c, PublishStatus 
        FROM Knowledge__kav WHERE Title = 'Articulo test cris'];

        //Comprobaciones para saber si se ha creado bien
        System.assertEquals(null, articulo.CBK_Codigo_Externo_Tematica__c, 'No se ha borrado bien');
        //System.assertEquals('Online', articulo.PublishStatus, 'El artículo no queda publicado por lo que no se podrá borrar el objeto');
        
    }
}