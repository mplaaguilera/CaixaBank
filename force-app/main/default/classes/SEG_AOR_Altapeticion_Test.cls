@isTest
public class SEG_AOR_Altapeticion_Test implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {   
        
        String sFakeRespuesta = '{"result":{"request":"RITM0244498","id_ref":"5005r00000Cf25QAAR","description":"00: RITM successfully created","codigo":"200"}}';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(sFakeRespuesta);
        res.setStatusCode(200);
        return res;
    }
    
    @testSetup
    static void testSetup() {
        System.runAs(new User(Id = UserInfo.getUserId())) {

            Account cuentaSEG1 = new Account();
            cuentaSEG1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('CC_ClienteSEG').getRecordTypeId();
            cuentaSEG1.Name = 'Empresa segmentos';
            cuentaSEG1.SEG_DominioMail__c = '@cuentaSEG';
            cuentaSEG1.CC_Numero_Documento__c = '11111171H';
            insert cuentaSEG1;
    
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
            insert caso;

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
                DeveloperName = 'SEG_AOR',
                CC_TrazaActiva__c = true
            );
            
            CBK_IntegrationSetting__c csAOR = new CBK_IntegrationSetting__c();
            csAOR.Name = 'SEG_AOR';
            csAOR.NamedCredential__c = 'callout:SEG_AOR/api/sicb/sfaor/create';
            insert csAOR;
        }
    }

    @IsTest
    static void testSEG_AOR_AltapeticionSend() {
        
        Test.setMock(HttpCalloutMock.class, new SEG_AOR_Altapeticion_Test());
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case'];

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_AOR_Altapeticion.SEG_AOR_AltapeticionSend(caso.Id, 'typology1AOR', 'typology2AOR', 'consultaAORaura');
            Test.stopTest();

            Case updatedCase = [SELECT SEG_Identificador_AOR__c, SEG_AORTipologiaN1__c, SEG_AORTipologia_N2__c, SEG_Consulta_AOR__c FROM Case WHERE Id = :caso.Id];
            System.assertEquals(null, updatedCase.SEG_Identificador_AOR__c);
        }
    }
    
    @IsTest
    static void testSEG_AOR_AltapeticionSendError() {
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('myStaticResourceName');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json');
     
        Test.setMock(HttpCalloutMock.class, mock);   
        
        Case caso = [SELECT Id FROM Case WHERE Subject = 'Test Case'];

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            SEG_AOR_Altapeticion.SEG_AOR_AltapeticionSend(caso.Id, 'typology1AOR', 'typology2AOR', 'consultaAORaura');
            Test.stopTest();

            Case updatedCase = [SELECT SEG_Identificador_AOR__c, SEG_AORTipologiaN1__c, SEG_AORTipologia_N2__c, SEG_Consulta_AOR__c FROM Case WHERE Id = :caso.Id];
            System.assertEquals(null, updatedCase.SEG_Identificador_AOR__c);
        }
    }
}