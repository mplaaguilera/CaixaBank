@isTest
public class CC_IdentClienteExis_Future_Test {
    
    @isTest
    static void test01_getContactExistente() {
		// Testar la llamada futura.
        
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
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear caso.
        Case c = new Case();
        c.Subject = 'Test_01';
        c.AccountId = a.Id;
        c.ContactId = b.Id;
        c.Status = 'New';
        c.Origin = 'Email';
        insert c;
        
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
    
    @isTest
    static void test02_getContactNewALF() {
		// Testar que no se llama al método futuro.
        
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
        insert b;
        
        List<Contact> o2 = [SELECT Id FROM Contact WHERE LastName = 'Contacto prueba 1'];
        System.assertEquals(o2.size(), 1);
        
        // Crear caso.
        Case c = new Case();
        c.Subject = 'Test_01';
        c.AccountId = a.Id;
        c.ContactId = b.Id;
        c.Status = 'New';
        c.Origin = 'Email';
        insert c;
        
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
            AccountId = [SELECT Id FROM Account WHERE CC_NumPerso__c = '999910559714'].Id,
            ContactId = [SELECT Id FROM Contact WHERE CC_NumPerso__c = '999910559714'].Id,
            CaseId = [SELECT Id FROM Case WHERE Subject = 'Test_01'].Id
        );
        insert liveChatTranscript;
        
        List<LiveChatTranscript> o6 = [SELECT Id FROM LiveChatTranscript WHERE CC_Id_Cognitive__c = '9001029aa'];
        System.assertEquals(o6.size(), 1);
    }
}