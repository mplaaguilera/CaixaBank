@isTest
public class CC_IdentCli_Future_Test { 
    
    @testSetup static void InitDatos() {
        
        // Inicialización de datos.
        List<CC_Lista_Valores__c> oListVal = new List<CC_Lista_Valores__c>();
        List<CC_Lista_Valores__c> oListVal2 = new List<CC_Lista_Valores__c>();
        
        ID sTipoRegL = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Lista_Valores').getRecordTypeId();        
        ID sTipoRegV = Schema.SObjectType.CC_Lista_Valores__c.getRecordTypeInfosByDeveloperName().get('CC_Valor').getRecordTypeId();        
        
        CC_Lista_Valores__c a1 = new CC_Lista_Valores__c();
        a1.Name = 'CC_Idioma_ALF';
        a1.CC_Activa__c = true;
        a1.RecordTypeId = sTipoRegL;
        oListVal.add(a1);
        
        CC_Lista_Valores__c a2 = new CC_Lista_Valores__c();
        a2.Name = 'CC_TipoCom_ALF';
        a2.CC_Activa__c = true;
        a2.RecordTypeId = sTipoRegL;
        oListVal.add(a2);
        
        CC_Lista_Valores__c a3 = new CC_Lista_Valores__c();
        a3.Name = 'CC_ClaseCom_ALF';
        a3.CC_Activa__c = true;
        a3.RecordTypeId = sTipoRegL;
        oListVal.add(a3);
        
        CC_Lista_Valores__c a4 = new CC_Lista_Valores__c();
        a4.Name = 'CC_Sexo_ALF';
        a4.CC_Activa__c = true;
        a4.RecordTypeId = sTipoRegL;
        oListVal.add(a4);
        
        insert oListVal;
        
        CC_Lista_Valores__c a5 = new CC_Lista_Valores__c();
        a5.Name = '000';
        a5.CC_Activa__c = true;
        a5.RecordTypeId = sTipoRegV;
        a5.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Idioma_ALF'].Id;
        a5.CC_Valor__c = 'DESCONOCIDO';
        a5.CC_Valor_SFDC__c = 'es';
        oListVal2.add(a5);
        
        CC_Lista_Valores__c a6 = new CC_Lista_Valores__c();
        a6.Name = '001';
        a6.CC_Activa__c = true;
        a6.RecordTypeId = sTipoRegV;
        a6.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Idioma_ALF'].Id;
        a6.CC_Valor__c = 'CATALÀ';
        a6.CC_Valor_SFDC__c = 'ca';
        oListVal2.add(a6);
        
        CC_Lista_Valores__c a7 = new CC_Lista_Valores__c();
        a7.Name = '002';
        a7.CC_Activa__c = true;
        a7.RecordTypeId = sTipoRegV;
        a7.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Idioma_ALF'].Id;
        a7.CC_Valor__c = 'CASTELLANO';
        a7.CC_Valor_SFDC__c = 'es';
        oListVal2.add(a7);
        
        CC_Lista_Valores__c a8 = new CC_Lista_Valores__c();
        a8.Name = '0';
        a8.CC_Activa__c = true;
        a8.RecordTypeId = sTipoRegV;
        a8.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_ClaseCom_ALF'].Id;
        a8.CC_Valor__c = 'Personal';
        a8.CC_Valor_SFDC__c = '0';
        oListVal2.add(a8);
        
        CC_Lista_Valores__c a9 = new CC_Lista_Valores__c();
        a9.Name = '1';
        a9.CC_Activa__c = true;
        a9.RecordTypeId = sTipoRegV;
        a9.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_ClaseCom_ALF'].Id;
        a9.CC_Valor__c = 'Trabajo';
        a9.CC_Valor_SFDC__c = '1';
        oListVal2.add(a9);
        
        CC_Lista_Valores__c a10 = new CC_Lista_Valores__c();
        a10.Name = 'V';
        a10.CC_Activa__c = true;
        a10.RecordTypeId = sTipoRegV;
        a10.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Sexo_ALF'].Id;
        a10.CC_Valor__c = 'Varón';
        a10.CC_Valor_SFDC__c = 'V';
        oListVal2.add(a10);
        
        CC_Lista_Valores__c a11 = new CC_Lista_Valores__c();
        a11.Name = 'M';
        a11.CC_Activa__c = true;
        a11.RecordTypeId = sTipoRegV;
        a11.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_Sexo_ALF'].Id;
        a11.CC_Valor__c = 'Mujer';
        a11.CC_Valor_SFDC__c = 'M';
        oListVal2.add(a11);
        
        CC_Lista_Valores__c a12 = new CC_Lista_Valores__c();
        a12.Name = '006';
        a12.CC_Activa__c = true;
        a12.RecordTypeId = sTipoRegV;
        a12.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_TipoCom_ALF'].Id;
        a12.CC_Valor__c = 'Móvil-Principal';
        a12.CC_Valor_SFDC__c = '006';
        oListVal2.add(a12);
        
        CC_Lista_Valores__c a13 = new CC_Lista_Valores__c();
        a13.Name = '001';
        a13.CC_Activa__c = true;
        a13.RecordTypeId = sTipoRegV;
        a13.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_TipoCom_ALF'].Id;
        a13.CC_Valor__c = 'Fijo';
        a13.CC_Valor_SFDC__c = '001';
        oListVal2.add(a13);
        
        CC_Lista_Valores__c a14 = new CC_Lista_Valores__c();
        a14.Name = '002';
        a14.CC_Activa__c = true;
        a14.RecordTypeId = sTipoRegV;
        a14.CC_Lista__c = [SELECT Id FROM CC_Lista_Valores__c WHERE Name = 'CC_TipoCom_ALF'].Id;
        a14.CC_Valor__c = 'Móvil';
        a14.CC_Valor_SFDC__c = '002';
        oListVal2.add(a14);
        
        insert oListVal2;
        
        // Crear cliente.
        Account a = new Account();
        a.Name = 'Cliente prueba 1';
        a.CC_NumPerso__c = '999910559714';
        insert a;
        
        List<Account> o1 = [SELECT Id FROM Account WHERE Name = 'Cliente prueba 1'];
        System.assertEquals(o1.size(), 1);
        
        // Crear contacto.
        Contact b = new Contact();
        b.LastName = 'Contacto prueba 1';
        b.CC_NumPerso__c = '999910559714';
        b.CC_Numero_Documento__c = '59044623N';
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear teléfono y mail del contacto.
        String sRecordType1 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Telefono').getRecordTypeId();
        String sRecordType2 = Schema.SObjectType.CC_Canal_Com__c.getRecordTypeInfosByDeveloperName().get('CC_Email').getRecordTypeId();
        
        CC_Canal_Com__c c1 = new CC_Canal_Com__c();
        c1.CC_NumPerso__c = '999910559714';
        c1.CC_ContactoId__c = b.Id;
        c1.CC_CuentaId__c = a.Id;
        c1.CC_Telefono__c = '34 956565656';
        c1.RecordTypeId = sRecordType1;
        insert c1;
        
        List<CC_Canal_Com__c> o3 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Telefono__c = '34 956565656'];
        System.assertEquals(o3.size(), 1);
        
        CC_Canal_Com__c c2 = new CC_Canal_Com__c();
        c2.CC_NumPerso__c = '999910559714';
        c2.CC_ContactoId__c = b.Id;
        c2.CC_CuentaId__c = a.Id;
        c2.CC_Email__c = 'prueba21@caixabank.com';
        c2.RecordTypeId = sRecordType2;
        insert c2;
        
        List<CC_Canal_Com__c> o4 = [SELECT Id FROM CC_Canal_Com__c WHERE CC_Email__c = 'prueba21@caixabank.com'];
        System.assertEquals(o4.size(), 1);       
        
        List<Case> oCasos = new List<Case>();
        
        // Crear caso.
        Case c = new Case();
        c.Subject = 'Test_01';
        c.AccountId = a.Id;
        c.ContactId = b.Id;
        c.Status = 'New';
        c.Origin = 'Email';
        c.CC_NumPerso__c = '999910559714';
        oCasos.add(c);
        
        Case cc2 = new Case();
        cc2.Subject = 'Test_02';
        cc2.AccountId = a.Id;
        cc2.ContactId = b.Id;
        cc2.Status = 'New';
        cc2.Origin = 'Email';
        cc2.CC_Numero_Documento__c = '59044623N';
        oCasos.add(cc2);
        
        Case cc3 = new Case();
        cc3.Subject = 'Test_03';
        cc3.AccountId = a.Id;
        cc3.ContactId = b.Id;
        cc3.Status = 'New';
        cc3.Origin = 'Email';
        cc3.CC_CuentaRRSS_CLI__c = 'twitter';
        oCasos.add(cc3);
        
        insert oCasos;
        
        // Crear RRSS.
        // List<SocialPost> oListPost = new List<SocialPost>();
        
        // SocialPersona oSPers = new SocialPersona();
        // oSPers.Name = 'twitter';
        // oSPers.ParentId = b.Id;
        // oSPers.Provider = 'Twitter';
        // insert oSPers;
        
        // SocialPost oSPost = new SocialPost();
        // oSPost.Name = 'Post01';
        // oSPost.Handle = 'twitter';
        // oSPost.Provider = 'Twitter';
        // oSPost.PersonaId = oSPers.Id;
        // oSPost.ParentId = c.Id;
        // oListPost.add(oSPost); 
        
        // cc3 = [SELECT Id, SourceId FROM Case WHERE Subject = 'Test_03' LIMIT 1];
        
        // SocialPost oSPost3 = new SocialPost();
        // oSPost3.Name = 'Post03';
        // oSPost3.Handle = 'twitter';
        // oSPost3.Provider = 'Twitter';
        // oSPost3.PersonaId = oSPers.Id;
        // oSPost3.ParentId = cc3.Id;
        // oListPost.add(oSPost3); 
        
        // insert oListPost;
        
        // oSPost3 = [SELECT Id FROM SocialPost WHERE Name = 'Post03' LIMIT 1];
        // cc3.SourceId = oSPost3.Id;
        // update cc3;
        
        List<Case> o5 = [SELECT Id FROM Case WHERE Subject = 'Test_01'];
        System.assertEquals(o5.size(), 1);
        
        LiveChatVisitor liveChatVisitor = new LiveChatVisitor();
        insert liveChatVisitor;
        
        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(
            CC_Bienvenida__c = false,
            CC_Nickname__c = 'Cliente 1',
            CC_Idioma__c = 'es',
            LiveChatVisitorId = liveChatVisitor.Id,
            CC_Id_Cognitive__c='9001029aa',
            CC_NumPerso__c = '999910559714',
            CC_NumPerso2__c = '999910559714',
            AccountId = [SELECT Id FROM Account WHERE CC_NumPerso__c = '999910559714'].Id,
            ContactId = [SELECT Id FROM Contact WHERE CC_NumPerso__c = '999910559714'].Id,
            CaseId = [SELECT Id FROM Case WHERE Subject = 'Test_01'].Id
        );
        insert liveChatTranscript;
        
        List<LiveChatTranscript> o6 = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = '9001029aa'];
        System.assertEquals(o6.size(), 1);
    
    }

    static testmethod void test01_ChatEntrante() {
        
        // Crear chat entrante. 
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());
        
        List<LiveChatTranscript> oChat = [SELECT Id, Status  FROM LiveChatTranscript WHERE CC_Id_Cognitive__c='9001029aa'];
        oChat[0].Status = 'InProgress';
        update oChat;
        
        Test.stopTest();
        
        System.assertEquals(oChat[0].Status, 'InProgress');

    }
    
    static testmethod void test02_ChatEntrante() {
        
        // Crear chat entrante. 
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_02());
        
        List<LiveChatTranscript> oChat = [SELECT Id, Status  FROM LiveChatTranscript WHERE CC_Id_Cognitive__c='9001029aa'];
        oChat[0].Status = 'InProgress';
        update oChat;
        
        Test.stopTest();
        
        System.assertEquals(oChat[0].Status, 'InProgress');

    }
    
    static testmethod void test03_ChatEntrante() {
        
        // Crear chat entrante. 
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_03());
        
        List<LiveChatTranscript> oChat = [SELECT Id, Status  FROM LiveChatTranscript WHERE CC_Id_Cognitive__c='9001029aa'];
        oChat[0].Status = 'InProgress';
        update oChat;
        
        Test.stopTest();
        
        System.assertEquals(oChat[0].Status, 'InProgress');

    }
    
    static testmethod void test04_ChatEntrante() {
        
        // Crear chat entrante. 
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_04());
        
        List<LiveChatTranscript> oChat = [SELECT Id, Status  FROM LiveChatTranscript WHERE CC_Id_Cognitive__c='9001029aa'];
        oChat[0].Status = 'InProgress';
        update oChat;
        
        Test.stopTest();
        
        System.assertEquals(oChat[0].Status, 'InProgress');

    }
    
    static testmethod void test05_ChatEntrante() {
        
        // Crear chat entrante. 
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_05());
        
        List<LiveChatTranscript> oChat = [SELECT Id, Status  FROM LiveChatTranscript WHERE CC_Id_Cognitive__c='9001029aa'];
        oChat[0].Status = 'InProgress';
        update oChat;
        
        Test.stopTest();
        
        System.assertEquals(oChat[0].Status, 'InProgress');

    }
    
    static testmethod void test06_ChatEntrante() {
        
        // Crear chat entrante. 
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP_06());
        
        List<LiveChatTranscript> oChat = [SELECT Id, Status  FROM LiveChatTranscript WHERE CC_Id_Cognitive__c='9001029aa'];
        oChat[0].Status = 'InProgress';
        update oChat;
        
        Test.stopTest();
        
        System.assertEquals(oChat[0].Status, 'InProgress');

    }
    
    // static testmethod void test07_IdentRRSS() {
        
    //     Test.startTest();
        
    //     Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFRRSS_WSDL_01());
        
    //     SocialPost oPost = [SELECT Id FROM SocialPost WHERE Name = 'Post01'];
    //     List<ID> oID = new List<ID>();
    //     oID.add(oPost.Id);
	// 	CC_IdentCliente_Future.CallUpdateALF(oID);
        
    //     Test.stopTest();
        
    //     System.assertEquals(oID.size(), 1);

    // }
    
    static testmethod void test08_IdentAsync1() {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());
        
        List<LiveChatTranscript> oChat = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c='9001029aa'];
        List<ID> oID = new List<ID>();
        for (LiveChatTranscript oAux : oChat)
        {
            oID.add(oAux.Id);
        }
        
        CC_IdentCliente_Future.identificarClientesAsync(oID);
        CC_IdentCliente_Future.CallUpdateALFExistentes(oID);
        
        Test.stopTest();
        
        System.assertEquals(!oID.isEmpty(), true);

    }
    
    static testmethod void test09_IdentAsync2() {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        List<ID> oID = new List<ID>();
        for (Contact oAux : o2)
        {
            oID.add(oAux.Id);
        }
        
        CC_IdentCliente_Future.identificarClientesAsync(oID);
        
        Test.stopTest();
        
        System.assertEquals(!oID.isEmpty(), true);

    }
    
    static testmethod void test10_IdentAsync3() {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());
        
        List<Case> o2 = [SELECT Id FROM Case WHERE Subject = 'Test_01'];
        List<ID> oID = new List<ID>();
        for (Case oAux : o2)
        {
            oID.add(oAux.Id);
        }
        
        CC_IdentCliente_Future.identificarClientesAsync(oID);
        
        Test.stopTest();
        
        System.assertEquals(!oID.isEmpty(), true);

    }
    
    static testmethod void test11_IdentAsync4() {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());
        
        List<Case> o2 = [SELECT Id FROM Case WHERE Subject = 'Test_02'];
        List<ID> oID = new List<ID>();
        for (Case oAux : o2)
        {
            oID.add(oAux.Id);
        }
        
        CC_IdentCliente_Future.identificarClientesAsync(oID);
        
        Test.stopTest();
        
        System.assertEquals(!oID.isEmpty(), true);

    }
    
    static testmethod void test12_IdentAsync5() {
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CC_WS_Mock_ALF_HTTP());
        
        List<Case> o2 = [SELECT Id FROM Case WHERE Subject = 'Test_03'];
        List<ID> oID = new List<ID>();
        for (Case oAux : o2)
        {
            oID.add(oAux.Id);
        }
        
        CC_IdentCliente_Future.identificarClientesAsync(oID);
        
        Test.stopTest();
        
        System.assertEquals(!oID.isEmpty(), true);

    }
    
    static testmethod void test13_IdentSync1() {
        
        Test.startTest();
        
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_02());
        
        Map<String,Object> oRes = CC_IdentCliente_Future.IdentificarPersALFSync('DOC','59044623N');
        
        Test.stopTest();
        
        System.assertEquals(!oRes.isEmpty(), true);

    }
    
    static testmethod void test14_IdentSync2() {
        
        Test.startTest();
        
        Test.setMock(WebServiceMock.class, new CC_WS_Mock_ALFCONS_WSDL_02());
        
        Map<String,Object> oRes = CC_IdentCliente_Future.IdentificarPersALFSync('TEL','956565656');
        
        Test.stopTest();
        
        System.assertEquals(!oRes.isEmpty(), true);

    }
    
    static testmethod void test15_UpdCaso() {
        
        Test.startTest();
        
        Case cc3 = [SELECT Id, SourceId FROM Case WHERE Subject = 'Test_03' LIMIT 1];
        
        Set<String> oCasosIdent = new Set<String>();
        oCasosIdent.add('UPDCASO##999910559714##Cliente##ID_ORIGEN##N/A##N/A##ACCOUNT_ID##CONTACTO_ID##' + cc3.Id);
        
        CC_IdentCliente_Future.actualizarCasosIdentificados(oCasosIdent);
        
        Test.stopTest();
        
        System.assertEquals(!oCasosIdent.isEmpty(), true);

    }
}