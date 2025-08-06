@isTest
public class SEG_AOR_addComment_Test implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {   
        
        String sFakeRespuesta = '{"sr": "2-912076545","model_name": "model-001","category": "Credit Cards","categories": [{"category": "Credit Cards", "ratio": "0.52114"},{"category": "Credit Cards", "ratio": "0.22389"},{"category": "Credit Cards", "ratio": "0.20729"},{"category": "Credit Cards", "ratio": "0.02778"},{"category": "Credit Cards", "ratio": "0.01109"},{"category": "Credit Cards", "ratio": "0.00698"},{"category": "Credit Cards", "ratio": "0.00155"},{"category": "Robot no encontrado", "ratio": "0.00027"}]}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }

    @testSetup
    static void testSetup() {
        // Crea un Case de prueba

        Account cuentaSEG1 = new Account();
        cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
        cuentaSEG1.Name = 'Empresa segmentos';
        cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
        cuentaSEG1.CC_Numero_Documento__c = '11111171H';
        insert cuentaSEG1;

        
        String jsonResults = 'Pruebadebody';
        System.JSONParser parserSR = System.JSON.createParser(String.valueOf(jsonResults));

        Case caso = new Case();
        caso.OwnerId = UserInfo.getUserId();
        caso.SEG_Numero_centro__c = cuentaSEG1.id;
        caso.Subject = 'Test Case';
        caso.Description = 'Test Description';
        caso.AccountId = cuentaSEG1.id;
        caso.SEG_Numero_de_centro__c = cuentaSEG1.id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SEG_Cliente').getRecordTypeId();
        caso.Origin = 'Email';
        caso.CC_Canal_Procedencia__c = 'Formulario web';
        caso.Status = 'Activo';
        caso.SEG_Subestado__c = 'En curso';
        caso.SEG_Zona__c = 'Corporativa';
        caso.SEG_Organizacion__C = 'Banca Corporativa';
        caso.SEG_Identificador_AOR__c = parserSR.getText();
        insert caso;

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            // Crea un User de prueba
            Profile perfil = [SELECT Id FROM Profile WHERE Name='SEG_Usuario_CaixaBank'];
            UserRole rol = [SELECT Id FROM UserRole WHERE Name='Segmentos + FFEE'];

            User usuario = new User(alias = 'tsegmen', email='testSEGBI@acme.com',
            emailencodingkey='UTF-8', lastname='Smith',
            languagelocalekey='en_US',
            localesidkey='en_US', profileid = perfil.Id, userroleid = rol.Id,
            timezonesidkey='America/Los_Angeles',
            username='testSEGBI@acme.com');
            insert usuario;
        

            // Asigna el Case al User de prueba
            caso.OwnerId = usuario.Id;
            update caso;

            // Crea una instancia de DatosEnvioComentarioAOR para el comentario de prueba
            SEG_AOR_addComment.DatosEnvioComentarioAOR sendComment = new SEG_AOR_addComment.DatosEnvioComentarioAOR();
            sendComment.user = usuario.EmployeeNumber;
            sendComment.comment = 'Test Comment';
            sendComment.caseId = caso.Id;
        

            // Serializa el objeto sendComment a JSON
            String jsonToCognitive = JSON.serialize(sendComment);

            // Activa la traza de la interfaz para pruebas
            CC_InterfaceSettings__mdt config = new CC_InterfaceSettings__mdt(
                DeveloperName = 'SEG_AOR_Comment',
                CC_TrazaActiva__c = true
            );
            
            CBK_IntegrationSetting__c csAOR = new CBK_IntegrationSetting__c();
            csAOR.Name = 'SEG_AOR_Comment';
            csAOR.NamedCredential__c = 'callout:SEG_AOR/api/sicb/sfaor/addcomment/';
            insert csAOR;
        }

    }
    
    @IsTest
    static void testSEG_AOR_addCommentSend() {
        User usuario = [SELECT Id FROM user WHERE alias = 'tsegmen'];
        Case caso = [SELECT Id FROM case WHERE Subject = 'Test Case'];
		
        Test.setMock(HttpCalloutMock.class, new SEG_AOR_Altapeticion_Test());

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            // Llama al método SEG_AOR_addCommentSend
            Test.startTest();
            SEG_AOR_addComment.SEG_AOR_addCommentSend(caso.Id, 'Test Comment');
            Test.stopTest();

            // Verifica que se haya insertado la traza
            List<CC_TrazaInt__c> trazas = [SELECT Id,CC_FinOK__c, CC_DetalleError__c, CC_MensajeSalida__c FROM CC_TrazaInt__c];
            System.assertEquals(1, trazas.size());
        }
    }

    @IsTest
    static void testSEG_AOR_addCommentSend_KO() {
        User usuario = [SELECT Id FROM user WHERE alias = 'tsegmen'];
        Case caso = [SELECT Id FROM case WHERE Subject = 'Test Case'];

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('myStaticResourceName');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');


        System.runAs ( new User(Id = UserInfo.getUserId()) ) {

            // Llama al método SEG_AOR_addCommentSend
            Test.startTest();
            SEG_AOR_addComment.SEG_AOR_addCommentSend(caso.Id, 'Test Comment');
            Test.stopTest();

            // Verifica que se haya insertado la traza
            List<CC_TrazaInt__c> trazas = [SELECT Id, CC_FinOK__c, CC_DetalleError__c FROM CC_TrazaInt__c];

            System.assertEquals(1, trazas.size());
            System.assertEquals(false, trazas.get(0).CC_FinOK__c);
        }
    }
}