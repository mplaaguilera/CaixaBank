@isTest
public class CC_KnowledgeVencimientoBatch_Test {
    
    @TestSetup
    static void setupTestData() {
        // Crear usuarios usando CC_TestDataFactory
        Map<String, User> usuarios = CC_TestDataFactory.insertUserAdminOperador('TEST001');
        User admin = usuarios.get('admin');
        User operador = usuarios.get('operador');
        
        // Dar permisos de Knowledge al operador
        operador.UserPermissionsKnowledgeUser = true;
        update operador;
        
        // Asignar Permission Set de Knowledge
        PermissionSet permiso = [SELECT Id FROM PermissionSet WHERE Name = 'CC_Knowledge_Publish' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = operador.Id, PermissionSetId = permiso.Id);
        
        // Crear cola para Knowledge
        Group queue = new Group(
            Name = 'QueueKnowledgeTest',
            DeveloperName = 'QueueKnowledgeTest',
            Type = 'Queue'
        );
        insert queue;
        
        QueueSObject queueSObject = new QueueSObject(
            QueueId = queue.Id,
            SobjectType = 'Case'
        );
        insert queueSObject;
        
        // Agregar operador a la cola
        GroupMember gm = new GroupMember(
            GroupId = queue.Id,
            UserOrGroupId = operador.Id
        );
        insert gm;
        
        // Agregar operador al grupo de supervisores de Knowledge
        Group groupKnowledgeSupervisores = [SELECT Id FROM Group WHERE DeveloperName = 'CC_Knowledge_Supervisores' LIMIT 1];
        GroupMember gmKnowledgeSupervisores = new GroupMember(
            GroupId = groupKnowledgeSupervisores.Id,
            UserOrGroupId = operador.Id
        );
        insert gmKnowledgeSupervisores;

        System.runAs(admin) {
            //Usar OWA buzon de empleados
            String defaultFromAddressEmpleados = [SELECT CC_Direccion_Correo__c FROM CC_Buzones_Por_Defecto__mdt WHERE DeveloperName = 'CC_Buzon_Defecto_Empleados'].CC_Direccion_Correo__c;
           
            // Crear configuración de settings
            CC_Settings__c knowledgeSettings = new CC_Settings__c(
                Name = 'CC_Knowledge_Settings',
                CC_Activa__c = true,
                CC_Configuracion_1__c = '30;15;7',
                CC_Configuracion_2__c = '7',
                CC_Configuracion_3__c = 'true',
                CC_Configuracion_4__c = defaultFromAddressEmpleados,
                CC_Configuracion_6__c = 'PlantillaPorVencerTest',
                CC_Configuracion_7__c = 'PlantillaVencidoTest',
                CC_Configuracion_8__c = 'QueueKnowledgeTest',
                CC_Configuracion_9__c = 'Archivar artículo',
                CC_Configuracion_10__c = 'Actualizar artículo',
                CC_Configuracion_11__c = 'Renovar artículo',
                CC_Configuracion_12__c = 'Cliente'
            );
            insert knowledgeSettings;
            
            // Crear plantilla de email
            EmailTemplate template = new EmailTemplate(
                Name = 'PlantillaPorVencerTest',
                DeveloperName = 'PlantillaPorVencerTest',
                TemplateType = 'custom',
                Subject = 'Artículo próximo a vencer: [Knowledge.Title]',
                HtmlValue = '<p>El artículo [Knowledge.Title] vence el [Knowledge.CC_Fecha_Caducidad__c]</p>[Knowledge_Cuerpo_Articulo]',
                FolderId = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1].Id
            );
            insert template;

            EmailTemplate template2 = new EmailTemplate(
                Name = 'PlantillaVencidoTest',
                DeveloperName = 'PlantillaVencidoTest',
                TemplateType = 'custom',
                Subject = 'Artículo vencido: [Knowledge.Title]',
                HtmlValue = '<p>El artículo [Knowledge.Title] ha vencido</p>[Knowledge_Cuerpo_Articulo]',
                FolderId = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1].Id
            );
            insert template2;
    
        } 
    }
    
    
    
    @isTest
    static void testBatchConConfiguracionInvalida() {
        // Obtener usuarios
        User operador = CC_TestDataFactory.getUserOperadorCliente();
        
        // Desactivar la configuración
        CC_Settings__c settings = [SELECT Id FROM CC_Settings__c WHERE Name = 'CC_Knowledge_Settings' LIMIT 1];
        settings.CC_Activa__c = false;
        update settings;
        
        Test.startTest();
        
        System.runAs(operador) {
            CC_KnowledgeVencimientoBatch batch = new CC_KnowledgeVencimientoBatch();
            Database.executeBatch(batch);           
        }
        
        Test.stopTest();

        List<Case> casos = [SELECT Id FROM Case WHERE RecordType.DeveloperName = 'CC_Knowledge_Case'];
        System.assertEquals(true, casos.isEmpty(), 'No debe haberse creado un caso para el artículo vencido');
    }
    
    @isTest
    static void testBatchConArticulosPorVencer() {
        User operador = CC_TestDataFactory.getUserOperadorCliente(); 
        User admin = CC_TestDataFactory.getUserAdmin();
        Account account;      
        System.runAs(admin) {
            // Crear Account para el área responsable
            Id rtCentroCaixaBancario = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_CentroCaixaBank').getRecordTypeId();
            account = new Account(
                Name = 'Área Responsable Test',
                RecordTypeId = rtCentroCaixaBancario
            );
            insert account;

            // Crear Contact colaborador
            Contact contacto = new Contact(
                FirstName = 'Colaborador',
                LastName = 'Test',
                Email = 'colaborador@test.com',
                AccountId = account.Id,
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId(),
                CC_ResponsableKnowledge__c = 'Primer contacto'
            );
            insert contacto;

            AccountShare accShare = new AccountShare(
                AccountId = account.Id,
                UserOrGroupId = operador.Id,
                AccountAccessLevel = 'Edit',
                OpportunityAccessLevel = 'Edit',
                CaseAccessLevel = 'Edit'
            );

            ContactShare contactShare = new ContactShare(
                ContactId = contacto.Id,
                UserOrGroupId = operador.Id,
                ContactAccessLevel = 'Edit'
            );

            insert contactShare;
            insert accShare;
        }
        
       
        System.runAs(operador) {           
            // Crear artículo de Knowledge con fecha de vencimiento próxima usando KnowledgeArticleVersion
            Knowledge__kav kav = new Knowledge__kav(
                Title = 'Artículo Próximo a Vencer',
                URLName = 'articulo-proximo-a-vencer',
                CC_Area_Responsable__c = account.Id,
                CC_Fecha_Caducidad__c = CBK_UtilsDate.todayDT().addDays(30),
                Answer__c = 'Contenido del artículo de prueba',
                CC_Tipo__c = 'Cliente'
            );
            insert kav;

            Id knowledgeArticleId = [SELECT KnowledgeArticleId FROM Knowledge__kav WHERE Id = :kav.Id].KnowledgeArticleId;
            
            // Publicar el artículo usando el servicio de publicación
            KbManagement.PublishingService.publishArticle(knowledgeArticleId, true);
            
                     
            Test.startTest();
                CC_KnowledgeVencimientoBatch batch = new CC_KnowledgeVencimientoBatch();
                Database.executeBatch(batch);
            Test.stopTest();
            // Verificar que se creó un caso
            List<Case> casosCreados = [SELECT Id FROM Case WHERE CBK_Case_Extension_Id__r.CC_Articulo_Relacionado__c = :kav.Id];
            System.assertEquals(false, casosCreados.isEmpty(), 'Debe haberse creado un caso');
      
        }
 
    }
     
   
}