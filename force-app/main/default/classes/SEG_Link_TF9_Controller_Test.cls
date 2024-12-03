@isTest
public with sharing class SEG_Link_TF9_Controller_Test {

    @testSetup
    static void dataSetUp() {
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

        Account cuentaSEG = new Account();
        cuentaSEG.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG.Name = 'test segmentos';
        cuentaSEG.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG.CC_Numero_Documento__c = '111111114';
        cuentaSEG.SEG_No_enviar_Acuse_Recibo_Empresa__c = false;
        cuentaSEG.AV_NumPerso__c = '123456789';
        insert cuentaSEG;

        Contact contactoSEG = new Contact();
        contactoSEG.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Empleado').getRecordTypeId();
        contactoSEG.FirstName = 'Yaiza';
        contactoSEG.LastName = 'Contacto 2';
        contactoSEG.Email = 'testasdas@test.com';
        contactoSEG.AccountId = cuentaSEG.Id;
        contactoSEG.SEG_No_enviar_Acuse_Recibo__c = false;
        insert contactoSEG;

        Account cuentaSEG2= new Account();
        cuentaSEG2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
        cuentaSEG2.Name = 'Cliente PA Segmentos';
        cuentaSEG2.AV_NumPerso__c = '113456789';
        insert cuentaSEG2;
    }

	@isTest
    public static void testGetLinks_Particular() {

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        Account cuenta = [SELECT Id FROM Account WHERE Name = 'test segmentos' LIMIT 1];

        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso.Subject = 'Prueba Grupo Alternativo';
        caso.Status = 'Cerrado';
        caso.SEG_Organizacion__c = 'Banca Corporativa';
        caso.SEG_Zona__c = 'Corporativa';
        caso.SEG_Buz_n_de_la_zona__c = 'segmentosdevservice@gmail.com';
        caso.OwnerId = usuarioTest.Id;
        caso.AccountId = cuenta.Id;
        insert caso;

        System.runAs(usuarioTest) {
            Test.startTest();
            List<SEG_Link_TF9_Controller.LinkOperativo> result = SEG_Link_TF9_Controller.getLinks('case', caso.Id);
            Test.stopTest();

            // Se comprueba que se obtienen links
            Integer numEnlaces = [SELECT Id FROM SEG_Link_TF9__mdt WHERE SEG_Activo__c = TRUE AND SEG_VisibleDinamica__c = FALSE AND SEG_Link__c != NULL].size();
            numEnlaces += [SELECT Id FROM SEG_Link_TF9__mdt WHERE label = 'Acceso a buzón OWA'].size();
            System.assertEquals(numEnlaces, result.size());
            System.assertNotEquals(null, result[0].url);
        }
    }

    @isTest
    public static void testGetLinks_Empresa() {

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        Account cuenta = [SELECT Id FROM Account WHERE Name = 'test segmentos' LIMIT 1];

        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso.Subject = 'Prueba Grupo Alternativo';
        caso.Status = 'Cerrado';
        caso.SEG_Organizacion__c = 'Banca Corporativa';
        caso.SEG_Zona__c = 'Corporativa';
        caso.OwnerId = usuarioTest.Id;
        caso.AccountId = cuenta.Id;
        insert caso;

        System.runAs (usuarioTest) {
            Test.startTest();
            List<SEG_Link_TF9_Controller.LinkOperativo> result = SEG_Link_TF9_Controller.getLinks('case', caso.Id);
            Test.stopTest();

            // Se comprueba que se obtienen links
            Integer numEnlaces = [SELECT Id FROM SEG_Link_TF9__mdt WHERE SEG_Activo__c = TRUE AND SEG_VisibleDinamica__c = FALSE AND SEG_Link__c != NULL].size();
            numEnlaces += [SELECT Id FROM SEG_Link_TF9__mdt WHERE label = 'Acceso a buzón OWA'].size();
            System.assertEquals(numEnlaces, result.size());
            System.assertNotEquals(null, result[0].url);
        }
    }

    @isTest
    static void testInsertarChatter() {

        User usuarioTest = [SELECT Id FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        Account cuenta = [SELECT Id FROM Account WHERE Name = 'test segmentos' LIMIT 1];

        Case caso = new Case();
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso.Subject = 'Prueba Grupo Alternativo';
        caso.Status = 'Cerrado';
        caso.SEG_Organizacion__c = 'Banca Corporativa';
        caso.SEG_Zona__c = 'Corporativa';
        caso.OwnerId = usuarioTest.Id;
        caso.AccountId = cuenta.Id;
        insert caso;

        // Definir datos de prueba
        String seccion = 'Case';
        Id customerId = caso.OwnerId; 
        String title = 'Título de Prueba';
        String nif = '12345678A';
        Boolean trazadoNif = true;

        System.runAs (usuarioTest) {
            Test.startTest();
            // Llamar al método insertarChatter
            SEG_Link_TF9_Controller.insertarChatter(seccion, customerId, title, nif, trazadoNif);
            Test.stopTest();
        }

        // Obtener los FeedItem creados
        List<FeedItem> feedItems = [SELECT Id, ParentId, Type, Body FROM FeedItem WHERE ParentId = :customerId];

        // Verificar que se haya creado un FeedItem
        System.assertEquals(1, feedItems.size(), 'Se esperaba que se creara un FeedItem.');

        // Verificar los detalles del FeedItem creado
        FeedItem feedItem = feedItems[0];
        System.assertEquals('TextPost', feedItem.Type, 'Tipo de FeedItem incorrecto.');
        System.assertEquals('Enlace a ' + title + ' NIF ' + nif, feedItem.Body, 'Cuerpo del FeedItem incorrecto.');
        
    }

}