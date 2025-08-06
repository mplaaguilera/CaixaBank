@isTest
public class SEG_WS_Cognitive_FFEE_Test {
@testSetup
    static void datosIniciales() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User thisUser = new User(
                alias = 'tsegmen',
                email = 'testSEGBI@acme.com',
                emailencodingkey = 'UTF-8',
                lastname = 'Smith',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                profileid = [SELECT Id FROM Profile WHERE Name= 'System administrator'].Id,
                userroleid = [SELECT Id FROM UserRole WHERE Name = 'Segmentos + FFEE'].Id,
                timezonesidkey ='America/Los_Angeles',
                username ='testSEGBI@acme.com'
            );
            insert thisUser;

            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT PermissionSetGroupId, PermissionSetId, PermissionSet.Name
                                                                FROM PermissionSetGroupComponent
                                                                WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]) {
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()) {
                insert listPermissionSetAssignment;
            }
        }

        Set<String> objetos = new Set<String>{'CC_Grupo_Colaborador__c'};
		Map<String,Map<String,Schema.RecordTypeInfo>> rtObjetos = SEG_GetRT.getRecordTypesObjects(objetos);
		 Id grupoOpSegId = rtObjetos.get('CC_Grupo_Colaborador__c').get('SEG_GrupoOperativoSegmentos').getRecordTypeId();
        
        List<CC_Grupo_Colaborador__c> lstGruposCol = new List<CC_Grupo_Colaborador__c>();
            CC_Grupo_Colaborador__c grupoColab = new CC_Grupo_Colaborador__c();
            grupoColab.Name = 'GrupoColabSeg';
            grupoColab.SEG_Tipologia__c = 'BO';
            grupoColab.RecordTypeId = grupoOpSegId;
            grupoColab.SEG_GrupoSegmentos__c = true;
            grupoColab.SEG_envio_a_TaskConnect__c = true;
            grupoColab.OS_Negocio__c = 'SEGMENTOS';
            lstGruposCol.add(grupoColab);
        
        CC_Grupo_Colaborador__c grupoRTGrupoCol = new CC_Grupo_Colaborador__c();
            grupoRTGrupoCol.Name='Grupo Colaborador';
            grupoRTGrupoCol.RecordTypeId = grupoOpSegId;
            grupoRTGrupoCol.SEG_envio_a_TaskConnect__c = true;
            grupoRTGrupoCol.SEG_GrupoSegmentos__c = true;
            grupoRTGrupoCol.OS_Negocio__c = 'SEGMENTOS';
            lstGruposCol.add(grupoRTGrupoCol);
        
        insert lstGruposCol;


        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111171H';
        insert cuentaSEG1;
        
        // Crear contactos para cuentas SEG.
        Contact contactoSEG1 = new Contact();
        contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        contactoSEG1.LastName = 'Contacto SEG 1';
        contactoSEG1.AccountId = cuentaSEG1.Id;
        contactoSEG1.Email = 'test@test.com';
        insert contactoSEG1;
        
        Case caso = new Case(
            AccountId = cuentaSEG1.id,
            SEG_Numero_de_centro__c = cuentaSEG1.id,
            RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId(),
            SEG_Grupo__c = grupoColab.id,
            Origin = 'Email',
            CC_Canal_Procedencia__c = 'Formulario web',
            Status = 'Activo',
            SEG_Subestado__c = 'En curso',
            SEG_Zona__c = 'Corporativa',
            SEG_Organizacion__C = 'Banca Corporativa',
            Subject = 'test 2',
            ContactId = contactoSEG1.Id
        );
        insert caso;
        
        // CR
        SEG_ClasificacionRapida__c clasRapida = new SEG_ClasificacionRapida__c(
            name = 'Test CR',
            SEG_Nombre_CR_Cognitive__c = 'Credit Cards',
            SEG_Canaldeentrada__c = 'Email',
            CBK_Negocio__c = 'Segmentos',
            SEG_Organizacion__C = 'Banca Corporativa'
        );
        insert clasRapida;
    }

	@isTest
    public static void clasificarCasoConOwnerIndicado() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        Case caso = [SELECT Id, CaseNumber, Status, SEG_Subestado__c FROM Case LIMIT 1];

        SEG_WS_Cognitive_FFEE.Input datosEntrada = new SEG_WS_Cognitive_FFEE.Input();
        
		datosEntrada.pkCodSr = String.valueOf(caso.CaseNumber);
        datosEntrada.pkIdSalesforce = String.valueOf(caso.Id);
        datosEntrada.model = '';
        datosEntrada.hasAttachments = true;
        datosEntrada.category = '';
        
        // Inicializar la lista de categorías
        datosEntrada.categories = new List<SEG_WS_Cognitive_FFEE.Categorias>();
        
        // Crear instancias de la clase Categorias
        SEG_WS_Cognitive_FFEE.Categorias category1 = new SEG_WS_Cognitive_FFEE.Categorias();
        category1.category = 'Category1';
        category1.prob = '0.95';
        
        SEG_WS_Cognitive_FFEE.Categorias category2 = new SEG_WS_Cognitive_FFEE.Categorias();
        category2.category = 'Category2';
        category2.prob = '0.85';
        
        // Añadir las categorías a la lista
        datosEntrada.categories.add(category1);
        datosEntrada.categories.add(category2);

        //datosEntrada.ContenidoAdicional
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/clasificarCasoFFEE/*';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs (usuarioTest) {
            Test.startTest();
            	SEG_WS_Cognitive_FFEE.Output output =  SEG_WS_Cognitive_FFEE.clasificarCaso();
            Test.stopTest();
            
        System.assertNotEquals(null, output, 'El output no debe ser nulo');
        }
    }
    
    @isTest
    public static void clasificarCasoCrNoExistente() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' ];
        Case caso = [SELECT Id, CaseNumber, Status, SEG_Subestado__c FROM Case LIMIT 1];
        caso.OwnerId = colasBO[0].id;
        update caso;

        SEG_WS_Cognitive_FFEE.Input datosEntrada = new SEG_WS_Cognitive_FFEE.Input();
        
		datosEntrada.pkCodSr = String.valueOf(caso.CaseNumber);
        datosEntrada.pkIdSalesforce = String.valueOf(caso.Id);
        datosEntrada.model = '';
        datosEntrada.hasAttachments = true;
        datosEntrada.category = 'TestNoExiste';
        
        // Inicializar la lista de categorías
        datosEntrada.categories = new List<SEG_WS_Cognitive_FFEE.Categorias>();
        
        // Crear instancias de la clase Categorias
        SEG_WS_Cognitive_FFEE.Categorias category1 = new SEG_WS_Cognitive_FFEE.Categorias();
        category1.category = 'Category1';
        category1.prob = '0.95';
        
        SEG_WS_Cognitive_FFEE.Categorias category2 = new SEG_WS_Cognitive_FFEE.Categorias();
        category2.category = 'Category2';
        category2.prob = '0.85';
        
        // Añadir las categorías a la lista
        datosEntrada.categories.add(category1);
        datosEntrada.categories.add(category2);

        //datosEntrada.ContenidoAdicional
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/clasificarCasoFFEE/*';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs (new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            	SEG_WS_Cognitive_FFEE.Output output =  SEG_WS_Cognitive_FFEE.clasificarCaso();
            Test.stopTest();
            
        // Assert para verificar el resultado
        System.assertNotEquals(null, output, 'El output no debe ser nulo');      
        }
    }
        
    @isTest
    public static void clasificarCasoConOwnerNoIndicado() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' ];
        Case caso = [SELECT Id, CaseNumber, Status, SEG_Subestado__c FROM Case LIMIT 1];
        caso.OwnerId = colasBO[0].id;
        update caso;
        
        SEG_WS_Cognitive_FFEE.Input datosEntrada = new SEG_WS_Cognitive_FFEE.Input();
        
		datosEntrada.pkCodSr = String.valueOf(caso.CaseNumber);
        datosEntrada.pkIdSalesforce = String.valueOf(caso.Id);
        datosEntrada.model = '';
        datosEntrada.hasAttachments = true;
        datosEntrada.category = 'Credit Cards';
        
        // Inicializar la lista de categorías
        datosEntrada.categories = new List<SEG_WS_Cognitive_FFEE.Categorias>();
        
        // Crear instancias de la clase Categorias
        SEG_WS_Cognitive_FFEE.Categorias category1 = new SEG_WS_Cognitive_FFEE.Categorias();
        category1.category = 'Category1';
        category1.prob = '0.95';
        
        SEG_WS_Cognitive_FFEE.Categorias category2 = new SEG_WS_Cognitive_FFEE.Categorias();
        category2.category = 'Category2';
        category2.prob = '0.85';
        
        // Añadir las categorías a la lista
        datosEntrada.categories.add(category1);
        datosEntrada.categories.add(category2);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/clasificarCasoFFEE/*';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(usuarioTest) {
            Test.startTest();
            	SEG_WS_Cognitive_FFEE.Output output =  SEG_WS_Cognitive_FFEE.clasificarCaso();
            Test.stopTest();
            
        // Assert para verificar el resultado
        System.assertNotEquals(null, output, 'El output no debe ser nulo'); 
        }
    }
    
        @isTest
    public static void clasificarCasoSinCategoria() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        List<Group> colasBO = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'SEG_BO' ];
        Case caso = [SELECT Id, CaseNumber, Status, SEG_Subestado__c FROM Case LIMIT 1];
        caso.OwnerId = colasBO[0].id;
        update caso;
        
        SEG_WS_Cognitive_FFEE.Input datosEntrada = new SEG_WS_Cognitive_FFEE.Input();
        
		datosEntrada.pkCodSr = String.valueOf(caso.CaseNumber);
        datosEntrada.pkIdSalesforce = String.valueOf(caso.Id);
        datosEntrada.model = '';
        datosEntrada.hasAttachments = true;
        datosEntrada.category = '';
        
        // Inicializar la lista de categorías
        datosEntrada.categories = new List<SEG_WS_Cognitive_FFEE.Categorias>();
        
        // Crear instancias de la clase Categorias
        SEG_WS_Cognitive_FFEE.Categorias category1 = new SEG_WS_Cognitive_FFEE.Categorias();
        category1.category = 'Category1';
        category1.prob = '0.95';
        
        SEG_WS_Cognitive_FFEE.Categorias category2 = new SEG_WS_Cognitive_FFEE.Categorias();
        category2.category = 'Category2';
        category2.prob = '0.85';
        
        // Añadir las categorías a la lista
        datosEntrada.categories.add(category1);
        datosEntrada.categories.add(category2);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/clasificarCasoFFEE/*';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs (usuarioTest) {
            Test.startTest();
            	SEG_WS_Cognitive_FFEE.Output output =  SEG_WS_Cognitive_FFEE.clasificarCaso();
            Test.stopTest();
            
        // Assert para verificar el resultado
        System.assertNotEquals(null, output, 'El output no debe ser nulo'); 
        }
    }
    
    @isTest
    public static void clasificarCasoSinCaso() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        SEG_WS_Cognitive_FFEE.Input datosEntrada = new SEG_WS_Cognitive_FFEE.Input();
        
		datosEntrada.pkCodSr = String.valueOf('');
        datosEntrada.pkIdSalesforce = String.valueOf('');
        datosEntrada.model = '';
        datosEntrada.hasAttachments = true;
        datosEntrada.category = '';
        
        // Inicializar la lista de categorías
        datosEntrada.categories = new List<SEG_WS_Cognitive_FFEE.Categorias>();
        
        // Crear instancias de la clase Categorias
        SEG_WS_Cognitive_FFEE.Categorias category1 = new SEG_WS_Cognitive_FFEE.Categorias();
        category1.category = 'Category1';
        category1.prob = '0.95';
        
        SEG_WS_Cognitive_FFEE.Categorias category2 = new SEG_WS_Cognitive_FFEE.Categorias();
        category2.category = 'Category2';
        category2.prob = '0.85';
        
        // Añadir las categorías a la lista
        datosEntrada.categories.add(category1);
        datosEntrada.categories.add(category2);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/clasificarCasoFFEE/*';
        req.httpMethod = 'PUT';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs (usuarioTest) {
            Test.startTest();
            	SEG_WS_Cognitive_FFEE.Output output =  SEG_WS_Cognitive_FFEE.clasificarCaso();
            Test.stopTest();
            
        // Assert para verificar el resultado
        System.assertNotEquals(null, output, 'El output no debe ser nulo'); 
        }
    }
}