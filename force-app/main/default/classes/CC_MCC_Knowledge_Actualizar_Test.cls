@isTest
public class CC_MCC_Knowledge_Actualizar_Test {
    @isTest
    static void actualizaMCCKnowledge() {   
        Account cuenta = new Account();
        cuenta.Name = 'PRUEBA TEST';
        cuenta.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        insert cuenta;
        	
        Contact contacto = new Contact();
        contacto.FirstName = 'Maria';
        contacto.LastName = 'Pérez';
        contacto.Email = 'mp@test.com';
        contacto.RecordTypeId = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
        contacto.AccountId = cuenta.Id;
		insert contacto;
        
        Datetime fecha = Datetime.now();
        Datetime fechaInicio = fecha.addHours(2);
        Datetime fechaCaducidad = fecha.addHours(10);

        Knowledge__kav articulo = new Knowledge__kav(); 
        articulo.URLName = 'Apex-Test' + System.now().getTime();
        articulo.Title = 'Articulo test';
        articulo.ValidationStatus = 'Validated';
        articulo.CBK_Codigo_Externo_Tematica__c = 'TE-000002';
        articulo.CBK_Codigo_Externo_Causa__c = 'CA-000002';
        articulo.CBK_Codigo_Externo_Motivo__c = 'MO-000002';
        articulo.CBK_Codigo_Externo_Producto__c = 'PR-000002';
        articulo.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
        articulo.CC_Fecha_Caducidad__c = fechaCaducidad;
        articulo.CC_Responsable_Externo__c = contacto.Id;
        Insert articulo; 
        Map<Id, KnowledgeArticleVersion> obtenidoIdQuery = new Map<Id, KnowledgeArticleVersion>([SELECT Id, KnowledgeArticleId 
        FROM KnowledgeArticleVersion WHERE Id =: articulo.Id]);

        CC_MCC__c mccTematica = new CC_MCC__c();
		mccTematica.Name = 'MCC Tematica';
        mccTematica.CC_Tipo_Cliente__c = 'Empleado';
        mccTematica.CC_Fecha_Vigencia_Inicio__c = Date.today();
        mccTematica.RecordTypeId = Schema.getGlobalDescribe().get('CC_MCC__c').getDescribe().getRecordTypeInfosByDeveloperName().get('CC_Tematica').getRecordTypeId();
        mccTematica.CC_Codigo_Externo__c = 'TE-000001';
        Insert mccTematica;

       

        Test.startTest();
        CC_MCC_Knowledge_AI_TRHan.publishArticle((String)obtenidoIdQuery.get(articulo.Id).KnowledgeArticleId);
        CBK_MCC_Knowledge__c relacionTematica = new CBK_MCC_Knowledge__c();
        relacionTematica.CBK_MCC__c = mccTematica.Id;
        relacionTematica.CBK_Knowledge__c = articulo.Id;
        Insert relacionTematica;
        CC_Knowledge_Publicar.EstadoKnowledge articuloPublicar = new CC_Knowledge_Publicar.EstadoKnowledge();
        articuloPublicar.estadoArticulo = 'publicar';
        articuloPublicar.idArticulo = articulo.Id;
        CC_Knowledge_Publicar.actualizarEstadoPublicacion(
            new List<CC_Knowledge_Publicar.EstadoKnowledge>{articuloPublicar}
        );
        CC_MCC_Knowledge_Actualizar.EstadoKnowledge prueba = new CC_MCC_Knowledge_Actualizar.EstadoKnowledge();
        prueba.estadoArticulo = 'Online';
        prueba.idArticulo = articulo.Id;
        List<CC_MCC_Knowledge_Actualizar.EstadoKnowledge> pruebaList = new List<CC_MCC_Knowledge_Actualizar.EstadoKnowledge>();
        pruebaList.add(prueba);
        CC_MCC_Knowledge_Actualizar.actualizarMCCKnowledge(pruebaList);
        Test.stopTest();
    }
}