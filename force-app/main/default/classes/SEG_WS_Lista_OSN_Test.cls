@isTest
public with sharing class SEG_WS_Lista_OSN_Test implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {   
        
        String sFakeRespuesta = '{"hasMore":false,"syndicatedList":[{"syndicatedId":9340650010011,"operationType":"PARTICIPANT","amountGranted":15000000,"ccy":"JPY","dateFrom":"2023-04-12","status":"CURRENT","accreditedName":"INDUSTRIA ESTEVE BALAGUER","contractSoeId":9380690000384,"contractSoeArea":"","originatorName":"Alberto Carabias"},{"syndicatedId":9340650009392,"operationType":"AGENT","amountGranted":38000000,"ccy":"EUR","dateFrom":"2021-01-05","status":"CURRENT","accreditedName":"INMUEBLES PELAYO PELAYO","contractSoeId":9380690000384,"contractSoeArea":"Project Finance","originatorName":"VIRGINIA GOMEZ DOMENECH GarGon"}]}';

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
            csOSN.Name = 'SEG_LST_OSN';
            csOSN.NamedCredential__c = 'callout:API_SEG_TST_OSN/tradeBanking/projectFinance/syndicates/bulk/request';
            insert csOSN;
    }

    @isTest
    static void testObtencionListaOSN() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        // Crea datos de prueba
        CC_TrazaInt__c traZaTest = new CC_TrazaInt__c(
            Name = 'SEG_Lista_OSN',
            CC_Identificador__c = '000001'
        );
        insert traZaTest;

        System.runAs (usuarioTest) {
            Test.startTest();
            // Llama al método que se va a probar
            SEG_WS_Lista_OSN.Lista_OSN result = SEG_WS_Lista_OSN.obtencionListaOSN('estado', 'numOSN', 'numSOE', 'numperso', 'caseNumber');
            Test.stopTest();
            
            // Asserts
            System.assertNotEquals(null, result.error); // Verifica que el resultado no sea nulo

        }
    }

    @isTest
    static void testObtencionListaOSNNulos() {

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        // Crea datos de prueba
        CC_TrazaInt__c traZaTest = new CC_TrazaInt__c(
            Name = 'SEG_Lista_OSN',
            CC_Identificador__c = '000001'
        );
        insert traZaTest;

        System.runAs (usuarioTest) {
            Test.startTest();
            // Llama al método que se va a probar
            SEG_WS_Lista_OSN.Lista_OSN result = SEG_WS_Lista_OSN.obtencionListaOSN('estado', null, null, 'numperso', 'caseNumber');
            Test.stopTest();
            
            // Asserts
            // Realiza afirmaciones (assertions) para verificar el resultado
            System.assertNotEquals(null, result, 'El resultado no debe ser nulo'); // Verifica que el resultado no sea nulo
            System.assertNotEquals(null, result.error, 'El campo "error" no debe ser nulo'); // Verifica que el campo 'error' no sea nulo
            System.assertEquals(null, result.responseOSN, 'El campo "responseOSN" debe ser nulo'); // Verifica que el campo 'responseOSN' sea nulo

        }
    }

    @isTest 
    public static void getStatus(){ //Se comprueba el funcionamiento OK normal del WS obteniendo una clasificación rápida.

        User usuarioTest = [SELECT Id, Profile.Name, UserRole.Name FROM User WHERE Username = 'testSEGBI@acme.com' LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new SEG_WS_Lista_OSN_Test());
        
        System.runAs (usuarioTest) {
            Test.startTest();
            SEG_WS_Lista_OSN.Lista_OSN result = SEG_WS_Lista_OSN.obtencionListaOSN('estado', 'numOSN', 'numSOE', 'numperso', 'caseNumber');
            Test.stopTest();
        }
        CC_TrazaInt__c trazaInsertada = [SELECT Id FROM CC_TrazaInt__c LIMIT 1];

        System.AssertNotEquals(null, trazaInsertada, 'No se ha creado traza');
    }

}