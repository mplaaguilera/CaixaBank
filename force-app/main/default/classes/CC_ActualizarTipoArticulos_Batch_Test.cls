@isTest
public class CC_ActualizarTipoArticulos_Batch_Test {
	@TestSetup
    static void makeData() {
        Id profileAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
        Id roleCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center'].Id;
        Id roleDirectorioCC = [SELECT Id FROM UserRole WHERE DeveloperName = 'Contact_Center_sin_acceso_a_Directorio'].Id;
        PermissionSet psOperadorCliente = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Operador_Cliente'];
        PermissionSet psSupervisor = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Supervisor_PS'];
        PermissionSet psClasses = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Classes'];
        List<User> userList = new List<User>();
        List<PermissionSetAssignment> insertPSAssOperadores = new List<PermissionSetAssignment>();
        List<CC_MCC__c> mccCreado = new List<CC_MCC__c>();
        List<CC_MCC__Share> totalPermisosMCC = new List<CC_MCC__Share>();

        User usuarioAdmin = new User();
        usuarioAdmin.profileId = profileAdmin;
        usuarioAdmin.UserRoleId = roleCC;        
        usuarioAdmin.FirstName = '';
        usuarioAdmin.LastName = 'Administrador de sistema';
        usuarioAdmin.Email = 'tuser000@amamama.com';
        usuarioAdmin.Username = 'tuser000@amama.com' + System.currentTimeMillis();
        usuarioAdmin.CompanyName = 'MST';
        usuarioAdmin.Title = 'title';
        usuarioAdmin.Alias = 'alias';
        usuarioAdmin.TimeZoneSidKey = 'Europe/Paris';
        usuarioAdmin.EmailEncodingKey = 'UTF-8';
        usuarioAdmin.LanguageLocaleKey = 'es';
        usuarioAdmin.LocaleSidKey = 'es_ES';
        usuarioAdmin.UserPermissionsKnowledgeUser = true;
        userList.add(usuarioAdmin);

        User operadorCliente = new User();
        operadorCliente.profileId = profileId;
        operadorCliente.UserRoleId = roleDirectorioCC;
        operadorCliente.AV_ExternalID__c = 'U0124112';
        operadorCliente.FirstName = 'Operador';
        operadorCliente.LastName = 'Operador Cliente';
        operadorCliente.Email = 'tuser000@amamama.com';
        operadorCliente.Username = 'tuser000@amamama.com' + System.currentTimeMillis();
        operadorCliente.CompanyName = 'MST';
        operadorCliente.Title = 'title';
        operadorCliente.Alias = 'alias';
        operadorCliente.TimeZoneSidKey = 'Europe/Paris';
        operadorCliente.EmailEncodingKey = 'UTF-8';
        operadorCliente.LanguageLocaleKey = 'es';
        operadorCliente.LocaleSidKey = 'es_ES';
        operadorCliente.UserPermissionsKnowledgeUser = true;
        userList.add(operadorCliente);
        insert userList;

        PermissionSetAssignment psaOperadorCliente = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psOperadorCliente.Id);
        insertPSAssOperadores.add(psaOperadorCliente);

        PermissionSetAssignment psaSupervisor = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psSupervisor.Id);
        insertPSAssOperadores.add(psaSupervisor);
        
        PermissionSetAssignment psaOperadorClasses = new PermissionSetAssignment(AssigneeId = operadorCliente.Id, PermissionSetId = psClasses.Id);
        insertPSAssOperadores.add(psaOperadorClasses);

        Database.insert(insertPSAssOperadores);

        System.runAs(usuarioAdmin) {
            Knowledge__kav articuloDraft = new Knowledge__kav();
            articuloDraft.title = 'Test-Draft';
            articuloDraft.UrlName = 'Test';
            articuloDraft.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Knowledge__kav', 'CC_Video');
            articuloDraft.CC_Tipo__c = null;
            insert articuloDraft;

            Knowledge__kav articuloOnline = new Knowledge__kav();
            articuloOnline.title = 'CL-Test Online';
            articuloOnline.UrlName = 'TestOnline';
            articuloOnline.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Knowledge__kav', 'CC_Arbol_Decision');
            articuloOnline.CC_Tipo__c = null;
            insert articuloOnline;

            List<Knowledge__kav> articulos = [SELECT id, KnowledgeArticleId FROM Knowledge__kav WHERE Id =: articuloOnline.Id];
            KbManagement.PublishingService.scheduleForPublication(articulos[0].KnowledgeArticleId, null);

            //Create article Online and create a Draft version
            Knowledge__kav articuloOnlineDraft = new Knowledge__kav();
            articuloOnlineDraft.title = 'Test Online With Draft';
            articuloOnlineDraft.UrlName = 'TestOnlineDraft';
            articuloOnlineDraft.RecordTypeId = CC_MetodosUtiles.getRecordTypeIdFromDeveloperName('Knowledge__kav', 'CC_Arbol_Decision');
            articuloOnlineDraft.CC_Tipo__c = null;
            insert articuloOnlineDraft;

            List<Knowledge__kav> articuloOnlineDraftList = [SELECT id, KnowledgeArticleId FROM Knowledge__kav WHERE Id =: articuloOnlineDraft.Id];
            KbManagement.PublishingService.scheduleForPublication(articuloOnlineDraftList[0].KnowledgeArticleId, null);
            KbManagement.PublishingService.editOnlineArticle(articuloOnlineDraftList[0].KnowledgeArticleId, false);

        }
    }

    @isTest
    public static void executeBatchTest() {
        System.runAs(new User(Id = [SELECT Id FROM User WHERE LastName = 'Operador Cliente' LIMIT 1].Id)) {
            //CC_ActualizarTipoArticulos_Batch batch = new CC_ActualizarTipoArticulos_Batch();
            List<Knowledge__kav> articulos = [SELECT Id FROM Knowledge__kav];

            CC_ActualizarTipoArticulos_Batch batch = new CC_ActualizarTipoArticulos_Batch();

            Test.startTest();
			DataBase.executeBatch(batch);
            Test.stopTest();

            List<Knowledge__kav> articulosCreated = [SELECT Id, CC_Tipo__c FROM Knowledge__kav WHERE title = 'CL-Test Online'];
            System.assertEquals(articulosCreated[0].CC_Tipo__c , 'Cliente', 'Error');
        }
       
    }
}