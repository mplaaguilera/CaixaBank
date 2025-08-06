@isTest
public with sharing class CC_IA_KnowledgeArticlesChatGpt_Test {

    @TestSetup
      private  static void testSetup(){
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
        usuarioGestor.Alias = 'aliºas';
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

          Case casoCliente = new Case();
          casoCliente.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
          casoCliente.Subject = 'Caso cliente MCC Test';
          casoCliente.Origin = 'Phone';
          casoCliente.CC_Canal_Respuesta__c = 'Phone';
          casoCliente.CC_Tipo_Cliente__c = 'Cliente';
          casoCliente.CC_No_Identificado__c = true;
          casoCliente.CC_Canal_Procedencia__c = 'CaixaBankNow';
          casoCliente.CC_Resumen_AI__c='<b>producto</b> y <b>procedimiento</b>';
          insert(casoCliente);

          // Crear un artículo de conocimiento
          Id recordTypeKav = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('CC_Informacion_General').getRecordTypeId();
            // Insertar datos de prueba
          Knowledge__kav testArticle = new Knowledge__kav();
          testArticle.RecordTypeId = recordTypeKav;
          testArticle.URLName = 'Apex-Test' + System.now().getTime();
          testArticle.Title = 'Articulo test de prueba';
          testArticle.Answer__c = 'Contenido Articulo test de prueba';
          testArticle.CC_IA_EtiquetadoGPT__c = 'producto;información;procedimiento';
          testArticle.CC_Fecha_Inicio_Publicacion__c = fechaInicio;
          testArticle.CC_Fecha_Caducidad__c = fechaCaducidad;
          testArticle.CC_Canal_Resolucion__c = 'CaixaBankNow';
          testArticle.CC_Tipo__c = 'Cliente';
          testArticle.ValidationStatus = 'Validated';
          testArticle.Language = 'es';
          insert testArticle;

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
      }
    }

    @isTest 
    static void testBuscarArticulos() {
      Case casoCliente = [SELECT Id, CC_Canal_Procedencia__c, CC_Resumen_AI__c FROM Case LIMIT 1];
      User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true Limit 1];
      Knowledge__kav articulo = [SELECT Id, KnowledgeArticleId, PublishStatus, Title FROM Knowledge__kav WHERE Title = 'Articulo test de prueba'];
      KbManagement.PublishingService.publishArticle(articulo.KnowledgeArticleId, true);

      System.runAs(usuario) {
        Test.startTest();
        CC_IA_KnowledgeArticlesChatGpt.Request request = new CC_IA_KnowledgeArticlesChatGpt.Request();
        request.objectToSummarize = casoCliente;

        List<CC_IA_KnowledgeArticlesChatGpt.Response> responses = CC_IA_KnowledgeArticlesChatGpt.buscarArticulos(new List<CC_IA_KnowledgeArticlesChatGpt.Request> { request });

        Test.stopTest();
        // Verificar la respuesta
        System.assertEquals(1, responses.size(), 'Debe haber una sola respuesta');
        System.assertNotEquals(CC_IA_KnowledgeArticlesChatGpt.NO_ARTICLES_FOUND_MESSAGE, responses[0].Prompt, 'La respuesta no debe indicar que no se encontraron artículos');
        System.assert(responses[0].Prompt.contains('Articulo test de prueba'), 'El resultado debe incluir el artículo esperado');
      }
    }
    @isTest
    static void testNoArticulosRelacionados() {
        Case casoCliente = [SELECT Id, CC_Canal_Procedencia__c, CC_Resumen_AI__c FROM Case LIMIT 1];
        casoCliente.CC_Resumen_AI__c = '<b>noexiste</b>';
        update casoCliente;
        User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            CC_IA_KnowledgeArticlesChatGpt.Request request = new CC_IA_KnowledgeArticlesChatGpt.Request();
            request.objectToSummarize = casoCliente;

            List<CC_IA_KnowledgeArticlesChatGpt.Response> responses = CC_IA_KnowledgeArticlesChatGpt.buscarArticulos(new List<CC_IA_KnowledgeArticlesChatGpt.Request> { request });

            Test.stopTest();
            // Verificar que no se encontraron artículos
            System.assertEquals(1, responses.size(), 'Debe haber una sola respuesta');
            System.assertEquals(CC_IA_KnowledgeArticlesChatGpt.NO_ARTICLES_FOUND_MESSAGE, responses[0].Prompt, 'Debe retornar el mensaje de que no se encontraron artículos');
        }
    }
    @isTest
    static void testCanalProcedenciaNulo() {
        Case casoCliente = [SELECT Id, CC_Canal_Procedencia__c, CC_Resumen_AI__c FROM Case LIMIT 1];
        casoCliente.CC_Canal_Procedencia__c = 'ImaginBank';
        update casoCliente;

        User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            CC_IA_KnowledgeArticlesChatGpt.Request request = new CC_IA_KnowledgeArticlesChatGpt.Request();
            request.objectToSummarize = casoCliente;

            List<CC_IA_KnowledgeArticlesChatGpt.Response> responses = CC_IA_KnowledgeArticlesChatGpt.buscarArticulos(new List<CC_IA_KnowledgeArticlesChatGpt.Request> { request });

            Test.stopTest();
            // Verificar que no se encontraron artículos
            System.assertEquals(1, responses.size(), 'Debe haber una sola respuesta');
            System.assertEquals(CC_IA_KnowledgeArticlesChatGpt.NO_ARTICLES_FOUND_MESSAGE, responses[0].Prompt, 'Debe retornar el mensaje de que no se encontraron artículos');
        }
    }
    @isTest
    static void testListaVacia() {
        User usuario = [SELECT id FROM User WHERE FirstName = 'Gestor CC' AND isActive = true LIMIT 1];

        System.runAs(usuario) {
            Test.startTest();
            try {
                CC_IA_KnowledgeArticlesChatGpt.buscarArticulos(new List<CC_IA_KnowledgeArticlesChatGpt.Request>());
                System.assert(false, 'Debe lanzar una excepción si la lista de requests está vacía');
            } catch (ListException e) {
                System.assert(e.getMessage().contains('La petición debe contener un solo elemento'), 'Debe lanzar la excepción correcta');
            }
            Test.stopTest();
        }
    }
}