@isTest
public with sharing class SEG_Buscador_OSN_Test implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {   
        
        String sFakeRespuesta = '{"syndicatedId":9340650010017,"syndicatedReference":"CAIXESBBOSN9340650010017","operationType":"AGENT","agentEntity":"CAIXABANK S.A.","amountGranted":28000000,"ccy":"EUR","dateFrom":"2023-08-11","dateTo":"2033-07-31","status":"CURRENT","accreditedName":"RESTAURANT HEREDIA MENDE","contractSoeId":9380690000110,"contractSoeArea":"Structured Trade Finance","originatorName":"Nom Originador Caixa Ape1 Originador Ape2 Originador","contactList":[{"name":"Nom Cto Caixa Part Vig Ape1 Cto Caixa Part","email":"ctoCaixaPart@hotmail.com","entityType":"PARTICIPANT","entityName":"CAIXABANK S.A."},{"name":"NomCtoSabadellVig asdf asdf","email":"NomCtoSabadellVig@gmail.com","entityType":"PARTICIPANT","entityName":"BANCO DE SABADELL, S.A."},{"name":"TitHerediaVigContacto asdf asfd","email":"TitHerediaVigContacto@view.com","entityType":"HOLDER","entityName":"RESTAURANT HEREDIA MENDE"}]}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }

    @testSetup
    static void testSetup() {
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
            for (PermissionSetGroupComponent permisoUnitario : [SELECT Id, PermissionSetGroupId, PermissionSetId, PermissionSet.Name FROM PermissionSetGroupComponent WHERE PermissionSetGroup.DeveloperName IN ('SEG_Operativo','SEG_Supervisor')]){
                PermissionSetAssignment nuevoPermiso = new PermissionSetAssignment();
                nuevoPermiso.PermissionSetId = permisoUnitario.PermissionSetId;
                nuevoPermiso.AssigneeId = thisUser.id;
                listPermissionSetAssignment.add(nuevoPermiso);
            }
            if (listPermissionSetAssignment.isEmpty()){
                insert listPermissionSetAssignment;
            }
        }
        CBK_IntegrationSetting__c csOSN = new CBK_IntegrationSetting__c();
        csOSN.Name = 'SEG_Contactos_OSN';
        csOSN.NamedCredential__c = 'callout:API_SEG_TST_OSN/tradeBanking/projectFinance/salesforce/contracts/{contractId}/syndicates';
        insert csOSN;
    }

    @isTest
    static void testGetResultadoListaOSN() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        System.runAs (usuarioTest) {

            Test.startTest();
    
            SEG_WS_Lista_OSN.Lista_OSN result = SEG_Buscador_OSN.getResultadoListaOSN('estado', 'numOSN', 'numSOE', 'numperso', 'caseNumber');

            Test.stopTest();

        System.assertNotEquals(null, result); // Verifica que el resultado no sea nulo
        }
    }
    
    @isTest
    static void getResultadoContactosOSNTest() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        System.runAs (usuarioTest) {

            Test.startTest();
    
            SEG_WS_Contactos_OSN.Contactos_OSN result = SEG_Buscador_OSN.getResultadoContactosOSN('numperso', 'caseNumber');

            Test.stopTest();

            System.assertNotEquals(null, result); // Verifica que el resultado sea el numero esperado
        }
    }

    @isTest
    static void getNumpersoTest() {

        Account cuentaSEG1 = new Account();
            cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
            cuentaSEG1.Name = 'Empresa segmentos 2';
            cuentaSEG1.AV_NumPerso__c = '123456';

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        System.runAs (usuarioTest) {

            Test.startTest();

            insert cuentaSEG1;
            List<Id> resultadosSOSLTest = new List<Id>();
            resultadosSOSLTest.add([SELECT Id FROM Account WHERE Name = 'Empresa segmentos 2'].Id);

            Test.setFixedSearchResults(resultadosSOSLTest);

            List<Account> result = SEG_Buscador_OSN.getNumperso('Empresa');

            Test.stopTest();

        System.assertNotEquals(null, result); // Verifica que el resultado no sea nulo
        }
    }
    
}