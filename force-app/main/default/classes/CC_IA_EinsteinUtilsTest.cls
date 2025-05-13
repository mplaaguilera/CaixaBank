@isTest
public with sharing class CC_IA_EinsteinUtilsTest {
        @TestSetup
        static void makeData(){
            Id profileId = [SELECT Id FROM Profile WHERE Name = 'CC_Usuario_CaixaBank'].Id;
            UserRole rolId = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'Contact_Center'];

            User usuarioGestor = new User();
            usuarioGestor.ProfileId = profileId;
            usuarioGestor.FirstName = 'Gestor CC';
            usuarioGestor.LastName = 'last1';
            usuarioGestor.Email = 'tuser0004@amamama.com';
            usuarioGestor.Username = 'tuser0004@amamama.com' + System.currentTimeMillis();
            usuarioGestor.CompanyName = 'MST';
            usuarioGestor.Title = 'title';
            usuarioGestor.Alias = 'alias';
            usuarioGestor.TimeZoneSidKey = 'Europe/Paris';
            usuarioGestor.EmailEncodingKey = 'UTF-8';
            usuarioGestor.LanguageLocaleKey = 'es';
            usuarioGestor.LocaleSidKey = 'es_ES';
            usuarioGestor.UserRoleId = rolId.Id;
            insert(usuarioGestor);

            // Obtenemos los PS Necesarios
            List<PermissionSet> permiSets = [SELECT Id FROM PermissionSet WHERE Name IN ('CC_IA_Prompt_User', 'Knowledge_LSF_Permission_Set')];

            // Asignamos PS CC_IA_UsuarioPromptsIA
            PermissionSet permiSet1 = permiSets[0];
            PermissionSetAssignment permiSetAssi = new PermissionSetAssignment();
            permiSetAssi.AssigneeId = usuarioGestor.Id;
            permiSetAssi.PermissionSetId = permiSet1.Id;
            insert(permiSetAssi);

            // Asignamos PS Knowledge_LSF_Permission_Set
            PermissionSet permiSet2 = permiSets[1];
            PermissionSetAssignment permiSetAssi2 = new PermissionSetAssignment();
            permiSetAssi2.AssigneeId = usuarioGestor.Id;
            permiSetAssi2.PermissionSetId = permiSet2.Id;
            insert(permiSetAssi2);

            System.runAs(usuarioGestor){
                Account cuenta = new Account();
                cuenta.Name = 'PRUEBA TEST';
                cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
                insert(cuenta);
        
                Contact contacto = new Contact();
                contacto.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Colaborador').getRecordTypeId();
                contacto.FirstName = 'Test';
                contacto.LastName = 'Prueba';
                contacto.Email = 'mp@test.com';
                contacto.AccountId = cuenta.Id;
                insert(contacto);

                //Control Tiempos
                Datetime fecha = Datetime.now();
                Datetime fechaInicio = fecha.addHours(2);
                Datetime fechaCaducidad = fecha.addHours(10);

                Id recordTypeKav = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Informacion_General').getRecordTypeId();
                // Insertar datos de prueba
                Knowledge__kav testArticle = new Knowledge__kav();
                testArticle.RecordTypeId = recordTypeKav;
                testArticle.URLName = 'Apex-Test' + System.now().getTime();
                testArticle.Title = 'Articulo test de prueba';
                testArticle.Answer__c = 'Contenido Articulo test de prueba';
                testArticle.CC_IA_EtiquetadoGPT__c = 'producto;información;procedimiento';
                testArticle.CC_Responsable_Externo__c = contacto.Id;
                testArticle.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
                testArticle.CC_Fecha_Caducidad__c = fechaCaducidad;
                testArticle.CC_Canal_Resolucion__c = 'CaixaBankNow';
                testArticle.CC_Tipo__c = 'Cliente';
                testArticle.ValidationStatus = 'Validated';
                testArticle.Language = 'es';
                insert(testArticle);

                Id casoClienteRt = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
                Case casoCliente = new Case();
                casoCliente.RecordTypeId = casoClienteRt;
                casoCliente.Subject = 'Caso cliente MCC Test';
                casoCliente.Origin = 'Phone';
                casoCliente.CC_Canal_Respuesta__c = 'Phone';
                casoCliente.CC_Tipo_Cliente__c = 'Cliente';
                casoCliente.CC_No_Identificado__c = true;
                casoCliente.CC_Canal_Procedencia__c = 'CaixaBankNow';
                casoCliente.AccountId = cuenta.id;
                insert(casoCliente);

                // Crear registros de tipo MCC
                CC_MCC__c  tematicaMCC = new CC_MCC__c (Name = 'Tematica MCC Test', CC_Tipo_Cliente__c = 'Cliente');
                CC_MCC__c  productoMCC = new CC_MCC__c (Name = 'Producto MCC Test', CC_Tipo_Cliente__c = 'Cliente');
                CC_MCC__c  motivoMCC = new CC_MCC__c (Name = 'Motivo MCC Test', CC_Tipo_Cliente__c = 'Cliente');
                CC_MCC__c  causaMCC = new CC_MCC__c (Name = 'Causa MCC Test', CC_Tipo_Cliente__c = 'Cliente');
                CC_MCC__c  solucionMCC = new CC_MCC__c (Name = 'Solucion MCC Test', CC_Tipo_Cliente__c = 'Cliente');
                insert new List<CC_MCC__c >{tematicaMCC, productoMCC, motivoMCC, causaMCC, solucionMCC};

                // Creamos objeto extension
                CBK_Case_Extension__c caseExtension = new CBK_Case_Extension__c();
                    caseExtension.CC_IA_Cumple_Condiciones_Prompts__c = true;
                insert(caseExtension);

                casoCliente.CBK_Case_Extension_Id__c = caseExtension.Id;
                update(casoCliente);

                // Crear un Custom Setting (CC_IA_Einstein_Config__c)
                CC_IA_Einstein_Config__c configSetting = new CC_IA_Einstein_Config__c(
                    Name = 'Test Config',
                    CC_IA_ON_OFF__c = true, 
                    CC_IA_Canal_de_Procedencia__c = 'CaixaBankNow'
                );
                insert configSetting;
            }
        }

@isTest
    public static void testGetKnowledgeArticles() {
    User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true Limit 1];
    Knowledge__kav articulo = [SELECT Id, KnowledgeArticleId, PublishStatus, Title FROM Knowledge__kav WHERE Title = 'Articulo test de prueba'];
    KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
    List<Knowledge__kav> articles;

    System.runAs(usuario){
        Test.startTest();
        articles = CC_IA_EinsteinUtils.getKnowledgeArticles('CaixaBankNow');
        Test.stopTest();
    }

    System.assertEquals('CaixaBankNow', articles[0].CC_Canal_Resolucion__c, 'Canal Coincide');
    System.assertEquals(1, articles.size(), 'Tamaño Coincide');
    }
@isTest
    public static void testFilterArticles() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true Limit 1];
        Knowledge__kav articulo = [SELECT Id, KnowledgeArticleId, PublishStatus, Title, CC_IA_EtiquetadoGPT__c FROM Knowledge__kav WHERE Title = 'Articulo test de prueba'];
        KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);
        List<Knowledge__kav> articles = new List<Knowledge__kav>{ articulo };
        List<Knowledge__kav> filteredArticles;
        String resumenAI = '<b>producto</b> y <b>procedimiento</b>';

        System.runAs(usuario){
            Test.startTest();
            filteredArticles = CC_IA_EinsteinUtils.filterArticles(resumenAI, articles);
            Test.stopTest();
        }

        System.assertEquals(1, filteredArticles.size(), 'Articulos Filtrados Coincide');
    }
    @isTest
    public static void testGetRecordUrl() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true Limit 1];
        Account accPrueba = [SELECT id FROM Account WHERE Name = 'PRUEBA TEST' Limit 1];

        System.runAs(usuario){
            Test.startTest();
            String recordUrl = CC_IA_EinsteinUtils.getRecordUrl(accPrueba.Id);
            Test.stopTest();

            // Obtener la URL del dominio de la organización
        String expectedBaseUrl = URL.getOrgDomainURL().toExternalForm();

        // Validar que la URL generada sea correcta
        System.assert(recordUrl.startsWith(expectedBaseUrl), 'La URL no comienza con el dominio esperado.');
        System.assert(recordUrl.endsWith('/' + accPrueba.Id), 'La URL no contiene el ID del registro.');
        }       
    }
    @isTest
    public static void testMarcarCheckPromptSiCumple() {
        // Ejecutamos el test en un contexto con el usuario adecuado
        User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true Limit 1];
        
        System.runAs(usuario) {
            // Obtenemos el caso de prueba
            Case casoCliente = [SELECT Id, CC_Canal_Procedencia__c, CBK_Case_Extension_Id__c, RecordTypeId FROM Case WHERE Subject = 'Caso cliente MCC Test' LIMIT 1];
            Test.startTest();
            // Llamamos al método marcarCheckPromptSiCumple
            CC_IA_EinsteinUtils.marcarCheckPromptSiCumple(casoCliente.CBK_Case_Extension_Id__c, casoCliente.CC_Canal_Procedencia__c, casoCliente.RecordTypeId);
            Test.stopTest();
            // Verificamos que la extensión de caso fue marcada correctamente
            CBK_Case_Extension__c extension = [SELECT CC_IA_Cumple_Condiciones_Prompts__c FROM CBK_Case_Extension__c WHERE Id = :casoCliente.CBK_Case_Extension_Id__c];
            System.assertEquals(true, extension.CC_IA_Cumple_Condiciones_Prompts__c, 'El campo CC_IA_Cumple_Condiciones_Prompts__c debe ser verdadero');
        }
    }

    @isTest
    public static void testCreateCaseExtensionRecord() {
        // Ejecutamos el test en un contexto con el usuario adecuado
        User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true Limit 1];

        System.runAs(usuario) {
            Test.startTest();
            // Llamamos al método createCaseExtensionRecord
            Id caseExtensionId = CC_IA_EinsteinUtils.createCaseExtensionRecord();
            Test.stopTest();
            // Verificamos que el registro de la extensión de caso fue creado
            CBK_Case_Extension__c caseExtension = [SELECT Id FROM CBK_Case_Extension__c WHERE Id = :caseExtensionId];
            System.assertNotEquals(null, caseExtensionId, 'El ID de la extensión del caso no debe ser nulo');
        }
    }
}