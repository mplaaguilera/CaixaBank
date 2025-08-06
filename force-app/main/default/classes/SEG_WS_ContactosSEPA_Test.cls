@isTest
public with sharing class SEG_WS_ContactosSEPA_Test {

    @testSetup
    static void datosIniciales() {

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];
            User thisUser = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
                emailencodingkey='UTF-8', lastname='Smith',
                languagelocalekey='en_US',
                localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
                timezonesidkey='America/Los_Angeles',
                username='testSEGBI@acme.com');
            insert thisUser;
            List<PermissionSetAssignment> listPermissionSetAssignment = new List<PermissionSetAssignment>();
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor', 'SEG_ContactosSEPA')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        System.runAs (usuarioTest) {
            Account cuentaSEG1= new Account();
            cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
            cuentaSEG1.Name = 'Empresa segmentos';
            cuentaSEG1.CC_Numero_Documento__c = '00000000T';
            insert cuentaSEG1;

            Contact contactoSEG1 = new Contact();
            contactoSEG1.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
            contactoSEG1.LastName = 'Contacto SEG 1';
            contactoSEG1.AccountId = cuentaSEG1.Id;
            contactoSEG1.Email = 'test@test.com';
            insert contactoSEG1;

            CC_Canal_Com__c canalCom = new CC_Canal_Com__c();
            canalCom.CC_ContactoId__c = contactoSEG1.Id;
            canalCom.CC_Email__c = 'canalcom@test.com';
            insert canalCom;

            AccountContactRelation relacionACSEG1= [SELECT Id, AccountId, ContactId, SEG_Reportar_temas_nuevos__c FROM AccountContactRelation WHERE AccountId= :cuentaSEG1.Id AND ContactId = :contactoSEG1.Id];
            //relacionACSEG1.AccountId = cuentaSEG1.Id;
            //relacionACSEG1.ContactId = contactoSEG1.Id;
            relacionACSEG1.SEG_Reportar_temas_nuevos__c = 'SEPA';
            update relacionACSEG1;
            }
        }
    
	//Test para verificar que un cif esta asociado a un contacto, y existe relacion entre esta y una cuenta, y tema SEPA
	@isTest
    public static void SEG_WS_ContactosSEPA_Test_Correcto() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        
        SEG_WS_ContactosSEPA.Input datosEntrada = new SEG_WS_ContactosSEPA.Input();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/ContactosSEPA/*';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs (usuarioTest) {
            Test.startTest();
            SEG_WS_ContactosSEPA.Output output =  SEG_WS_ContactosSEPA.solicitarContacto();
            Test.stopTest();
            System.assertEquals(output.mensaje, 'Datos encontrados correctamente.', 'No se encontraron los datos correctamente');
        }
    }

    //Test que verifica que cuando no hay un contacto asociado a un cif, se devolvera un mensaje de Error por el output
    @isTest
    public static void SEG_WS_ContactosSEPA_ListaVacia_Test() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        SEG_WS_ContactosSEPA.Input datosEntrada = new SEG_WS_ContactosSEPA.Input();
        datosEntrada.cif = null;
        AccountContactRelation accountList = [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE SEG_Reportar_temas_nuevos__c ='SEPA' LIMIT 1];
        Contact contacto = [SELECT id, Email FROM Contact WHERE id = :accountList.ContactId];
        DELETE contacto;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/ContactosSEPA/*';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs (usuarioTest) {
            Test.startTest();
            SEG_WS_ContactosSEPA.Output output =  SEG_WS_ContactosSEPA.solicitarContacto();
            Test.stopTest();
            System.assertEquals(output.mensaje, 'No se encuentra ningún Contacto con el CIF 00000000T', 'Se encontro un contacto asociado al cif');
        }
    }
    
    //Test que devolvera un mensaje de Error por el output en caso de que el contacto relacionado con el cif no tenga email
    @isTest
    public static void SEG_WS_ContactosSEPA_ContactoSinEmail_Test() {
        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];
        SEG_WS_ContactosSEPA.Input datosEntrada = new SEG_WS_ContactosSEPA.Input();
        datosEntrada.cif = null;
        AccountContactRelation accountList = [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE SEG_Reportar_temas_nuevos__c ='SEPA' LIMIT 1];
        Contact contacto = [SELECT id, Email FROM Contact WHERE id = :accountList.ContactId];
        contacto.Email = null;
        update contacto;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/ContactosSEPA/*';
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueOf(JSON.serialize(datosEntrada));
        RestContext.request = req;
        RestContext.response = res;
        System.runAs (usuarioTest) {
            Test.startTest();
            SEG_WS_ContactosSEPA.Output output =  SEG_WS_ContactosSEPA.solicitarContacto();
            Test.stopTest();
            System.assertEquals(output.mensaje, 'No se encuentra ningún Contacto con Email con el CIF 00000000T', 'Se encontro un contacto con email asociado al cif');
        }
    }
}