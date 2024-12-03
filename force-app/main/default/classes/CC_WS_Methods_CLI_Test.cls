@isTest(SeeAllData=true)
public class CC_WS_Methods_CLI_Test {
	/*static testmethod void test01_ChatEntrante() {
        
        // Crear chat entrante. 
        Test.startTest();
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        // Crear contacto.
        Contact b = new Contact();
     	Id RecordType = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('CC_Cliente').getRecordTypeId();
		b.RecordTypeId = RecordType;
        b.AccountId = a.Id;
        b.LastName = 'Contacto prueba 1'; 
        b.CC_NumPerso__c = '999910559714';
        b.CC_Matricula__c = 'U0144565';
        b.FirstName = 'Cliente prueba 1';
        insert b;
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
               
        // Crear caso.
         /*
        Case c = new Case();
        c.Subject = 'Test_01';
        c.AccountId = a.Id;
        c.ContactId = b.Id;
        c.Status = 'New';
        c.Origin = 'Email';        
        insert c;
        */
        /*Id usuarioId = [SELECT Id FROM User LIMIT 1].Id;
         Case c = new Case(
            Origin = 'Chat',
            Status = 'Activo',
            CC_Idioma__c = 'es',
            CC_Canal_Respuesta__c = 'Email',
            OwnerId = usuarioId,
            AccountId = a.Id,
            ContactId = b.Id,
            Subject = 'Test_01',
            CC_Grupo_3N__c = 'Grupo 3N',
            CC_Canal_Procedencia__c = 'Web'
        );        
        insert c;
         
        //Crear Lista de Valores
        CC_Lista_Valores__c listaSegmento2 = new CC_Lista_Valores__c();
        listaSegmento2.Name = 'CC_Segmento_CLI';
        insert listaSegmento2;
                
        CC_Lista_Valores__c listaSubSegmento2 = new CC_Lista_Valores__c();
        listaSubSegmento2.Name = 'CC_Subsegmento_CLI';
        insert listaSubSegmento2;
         
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CC_Id_Cognitive__c='aaaaaa',
            CC_NumPerso__c = '999910559714',
            CC_NumPerso2__c = '999910559714',
            AccountId = [SELECT Id FROM Account WHERE CC_NumPerso__c = '999910559714'].Id,
            ContactId = [SELECT Id FROM Contact WHERE CC_NumPerso__c = '999910559714'].Id,
            CaseId = [SELECT Id FROM Case WHERE Subject = 'Test_01'].Id
        );
        insert liveChatTranscript;
        
        List<LiveChatTranscript> oChat = [SELECT Id, Status  FROM LiveChatTranscript WHERE ID = :liveChatTranscript.Id];
        oChat[0].Status = 'InProgress';
        update oChat;
        
        Test.stopTest();
        
        System.assertEquals(oChat[0].Status, 'InProgress');
    }*/
    
    static testmethod void testDatosCLI_HTTP() {        
        List<String> oListaCLI = new List<String>();
        oListaCLI.add('CC_Segmento_CLI');
        oListaCLI.add('CC_Subsegmento_CLI');
        Map<String, Object> oParamAuxCLI = CC_MetodosUtiles.getLOV(oListaCLI);
        // Testar datos de la respuesta
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_CLI_WSDL());
        CC_InterfaceSettings__mdt configCLI = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_CLI');
        Map<String,SObject> oData = CC_WS_Methods_CLI.getDataCLIWSbyNumPerso ('10559714', 'INTCLI', '999910559714', null, oParamAuxCLI, null, configCLI);
        Test.stopTest();
        
        System.assertNotEquals(oData.size(),0);
    }
    
    static testmethod void testDatosCLI_HTTP2() {        
        List<String> oListaCLI = new List<String>();
        oListaCLI.add('CC_Segmento_CLI');
        oListaCLI.add('CC_Subsegmento_CLI');
        Map<String, Object> oParamAuxCLI = CC_MetodosUtiles.getLOV(oListaCLI);
        // Testar datos de la respuesta
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_CLI_WSDL2());
        CC_InterfaceSettings__mdt configCLI = CC_MetodosUtiles.getInterfazConfigBody ('CC_Int_CLI');
        Map<String,SObject> oData = CC_WS_Methods_CLI.getDataCLIWSbyNumPerso ('10559714', 'INTCLI', '999910559714', null, oParamAuxCLI, null, configCLI);
        Test.stopTest();
        
        System.assertNotEquals(oData.size(),0);
    }
    
    
}